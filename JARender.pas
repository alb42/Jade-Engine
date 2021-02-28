unit JARender;
{$mode objfpc}{$H+}
{$i JA.inc}

{This unit contains functions for rendering graphics primatives}

interface

uses
   sysutils,
   {Amiga} Exec, Intuition, AGraphics, Utility, picasso96api,
   {JAE} JATypes, JAGlobal, JAMath, JALog, JAScreen, JAWindow, JAPolygon, JASketch, JABitmap,
   JAPalette;

type
   TJARenderMode = (
      JARenderMode_Screen=0,
      JARenderMode_Window=1,
      JARenderMode_File=2,
      JARenderMode_None=3);

var
   {Rendering functions Operate on these Global Variables}
   JARenderBitmap : PJABitmap; {RenderTarget Bitmap}
   JARenderRasterPort : pRastPort; {RenderTarget RasterPort}
   JARenderClipRect : TJRectSInt16; {Shadows, Lights - are clipped to this}

   {Current Render Matricies}
   JARenderModelMatrix : TMat3;
   JARenderViewMatrix : TMat3;
   JARenderMVP : TMat3;

   {Global Render Properties}
   JARenderPassCount : SInt16;





procedure JARenderPixel(APixel : TVec2);
procedure JARenderLine(A, B : TVec2);

procedure JARenderPolygon(APolygon : PJAPolygon);
procedure JARenderSketch(ASketch : PJASketch);

procedure JARenderCircle(APosition: TVec2SInt16; ARadius : SInt16);
procedure JARenderCone(APosition : TVec2; ARotation : Float32; AConeAngle : Float32; ARadius : Float32);

procedure JARenderConeClipped(APosition : TVec2; ARotation : Float32; AConeAngle : Float32; ARadius : Float32);

procedure JARenderLightFan(APosition: TVec2; AAngle0, AAngle1 : Float32; ARadius: Float32);

implementation


procedure JARenderPixel(APixel : TVec2);
var
   Pixel : TVec2SInt16;
begin
   //APixel := Vec2DotMat3Affine(APixel, JARenderMVP);
   Pixel.X := round(JARenderMVP._00*APixel.X + JARenderMVP._01*APixel.Y  + JARenderMVP._02);
   Pixel.Y := round(JARenderMVP._10*APixel.X + JARenderMVP._11*APixel.Y  + JARenderMVP._12);

   {reject any offscreen pixels}
   if (Pixel.X >= JARenderClipRect.Left) and (Pixel.X <= JARenderClipRect.Right) and (Pixel.Y >= JARenderClipRect.Top) and (Pixel.Y <= JARenderClipRect.Bottom) then
      WritePixel(JARenderRasterPort, Pixel.X, Pixel.Y);
end;

procedure JARenderLine(A, B : TVec2);
var
   Ai : TVec2SInt16;
   Bi : TVec2SInt16;
begin
   Ai.X := round(JARenderMVP._00*A.X + JARenderMVP._01*A.Y  + JARenderMVP._02);
   Ai.Y := round(JARenderMVP._10*A.X + JARenderMVP._11*A.Y  + JARenderMVP._12);
   Bi.X := round(JARenderMVP._00*B.X + JARenderMVP._01*B.Y  + JARenderMVP._02);
   Bi.Y := round(JARenderMVP._10*B.X + JARenderMVP._11*B.Y  + JARenderMVP._12);

   //A := Vec2DotMat3Affine(A, JARenderMVP);
   //B := Vec2DotMat3Affine(B, JARenderMVP);

   {reject any offscreen lines}
   if not (
      ((Ai.X < JARenderClipRect.Left) and (Bi.X < JARenderClipRect.Left)) or
      ((Ai.Y < JARenderClipRect.Top) and (Bi.Y < JARenderClipRect.Top)) or
      ((Ai.X > JARenderClipRect.Right) and (Bi.X > JARenderClipRect.Right)) or
      ((Ai.Y > JARenderClipRect.Bottom) and (Bi.Y > JARenderClipRect.Bottom))
   ) then
   begin
      GfxMove(JARenderRasterPort, Ai.X, Ai.Y);
      Draw(JARenderRasterPort, Bi.X, Bi.Y);
   end;
end;

procedure JARenderSketch(ASketch : PJASketch);
var
   I : SInt32;
begin
   for I := 0 to ASketch^.PolygonCount-1 do
   begin
      JARenderPolygon(@ASketch^.Polygon[I]);
   end;
end;

procedure JARenderPolygon(APolygon : PJAPolygon);
var
   I,J : SInt32;
   AreaInfo : TAreaInfo;
   Buffer : PSInt16;
   TransformVec : TVec2;
   FaceNormal : TVec2;
   BackIndex : SInt32;
   AVec : TVec2;
   AShadow : PJAPolygonShadow;
   DitherPattern : array[0..1] of UInt16;
begin
   DitherPattern[1] := %0101010101010101;
   DitherPattern[0] := %1010101010101010;

   {Set Polygon Colour}
   SetAPen(JARenderRasterPort, APolygon^.Style.PenIndex);

   {$IFDEF JA_ENABLE_SHADOW}
   SetWrMsk(JARenderRasterPort, %00000111); {Disable writing to Shadow Channel}
   {$ENDIF}

   {$IFDEF JA_ENABLE_POLYGON}
   {Filled}
   AreaMove(JARenderRasterPort, APolygon^.WorldVertexI[0].X, APolygon^.WorldVertexI[0].Y);
   for I := 1 to APolygon^.VertexCount-1 do
      AreaDraw(JARenderRasterPort, APolygon^.WorldVertexI[I].X, APolygon^.WorldVertexI[I].Y);
   AreaEnd(JARenderRasterPort);
   {$ELSE}
   {Wireframe}
   GfxMove(JARenderRasterPort, APolygon^.WorldVertexI[0].X, APolygon^.WorldVertexI[0].Y);
   for I := 1 to APolygon^.VertexCount-1 do
   begin
      Draw(JARenderRasterPort, APolygon^.WorldVertexI[I].X, APolygon^.WorldVertexI[I].Y);
   end;
   Draw(JARenderRasterPort, APolygon^.WorldVertexI[0].X, APolygon^.WorldVertexI[0].Y);
   {$ENDIF}

   {$IFDEF JA_ENABLE_SHADOW}

   {Draw Shadows}
   if APolygon^.ShadowCast then
   begin
      for I := 0 to APolygon^.ShadowsCount-1 do
      begin
         AShadow := @APolygon^.Shadows[I];
         if AShadow^.ShadowVertexCount > 0 then
         begin
            if I=0 then
            begin
            SetWriteMask(JARenderRasterPort, %00111000); {Write to Shadow Channel}
            SetAPen(JARenderRasterPort, {24} %00000000); {write 1s}
            end else
            begin
            SetWriteMask(JARenderRasterPort, %01011000); {Write to Shadow Channel}
            SetAPen(JARenderRasterPort, {24} %00000000); {write 1s}
            end;

            AreaMove(JARenderRasterPort, round(AShadow^.ShadowVertex[0].X), round(AShadow^.ShadowVertex[0].Y));
            for J := 1 to AShadow^.ShadowVertexCount-1 do
               AreaDraw(JARenderRasterPort, round(AShadow^.ShadowVertex[J].X), round(AShadow^.ShadowVertex[J].Y));
            AreaEnd(JARenderRasterPort);

            if AShadow^.ShadowPenumbra0FinsCount > 0 then
            begin
               SetAfPt(JARenderRasterPort, nil, 0);
               SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
               SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
               AreaMove(JARenderRasterPort, AShadow^.ShadowPenumbra0Fins[0].Vertex[0].X, AShadow^.ShadowPenumbra0Fins[0].Vertex[0].Y);
               for J := 1 to AShadow^.ShadowPenumbra0Fins[0].VertexCount-1 do
               AreaDraw(JARenderRasterPort, AShadow^.ShadowPenumbra0Fins[0].Vertex[J].X, AShadow^.ShadowPenumbra0Fins[0].Vertex[J].Y);
               AreaEnd(JARenderRasterPort);

               SetAfPt(JARenderRasterPort, @DitherPattern, 1);
               SetWriteMask(JARenderRasterPort, Palette^.Bands[2].Mask);
               SetAPen(JARenderRasterPort, Palette^.Bands[2].Mask);
               AreaMove(JARenderRasterPort, AShadow^.ShadowPenumbra0Fins[0].Vertex[0].X, AShadow^.ShadowPenumbra0Fins[0].Vertex[0].Y);
               for J := 1 to AShadow^.ShadowPenumbra0Fins[0].VertexCount-1 do
               AreaDraw(JARenderRasterPort, AShadow^.ShadowPenumbra0Fins[0].Vertex[J].X, AShadow^.ShadowPenumbra0Fins[0].Vertex[J].Y);
               AreaEnd(JARenderRasterPort);

               SetAfPt(JARenderRasterPort, nil, 0);
               SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
               SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
               AreaMove(JARenderRasterPort, AShadow^.ShadowPenumbra0Fins[1].Vertex[0].X, AShadow^.ShadowPenumbra0Fins[1].Vertex[0].Y);
               for J := 1 to AShadow^.ShadowPenumbra0Fins[1].VertexCount-1 do
               AreaDraw(JARenderRasterPort, AShadow^.ShadowPenumbra0Fins[1].Vertex[J].X, AShadow^.ShadowPenumbra0Fins[1].Vertex[J].Y);
               AreaEnd(JARenderRasterPort);

               SetAfPt(JARenderRasterPort, @DitherPattern, 1);
               SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
               SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
               AreaMove(JARenderRasterPort, AShadow^.ShadowPenumbra0Fins[2].Vertex[0].X, AShadow^.ShadowPenumbra0Fins[2].Vertex[0].Y);
               for J := 1 to AShadow^.ShadowPenumbra0Fins[2].VertexCount-1 do
               AreaDraw(JARenderRasterPort, AShadow^.ShadowPenumbra0Fins[2].Vertex[J].X, AShadow^.ShadowPenumbra0Fins[2].Vertex[J].Y);
               AreaEnd(JARenderRasterPort);
            end;

            if AShadow^.ShadowPenumbra1FinsCount > 0 then
            begin
               SetAfPt(JARenderRasterPort, nil, 0);
               SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
               SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
               AreaMove(JARenderRasterPort, AShadow^.ShadowPenumbra1Fins[0].Vertex[0].X, AShadow^.ShadowPenumbra1Fins[0].Vertex[0].Y);
               for J := 1 to AShadow^.ShadowPenumbra1Fins[0].VertexCount-1 do
               AreaDraw(JARenderRasterPort, AShadow^.ShadowPenumbra1Fins[0].Vertex[J].X, AShadow^.ShadowPenumbra1Fins[0].Vertex[J].Y);
               AreaEnd(JARenderRasterPort);

               SetAfPt(JARenderRasterPort, @DitherPattern, 1);
               SetWriteMask(JARenderRasterPort, Palette^.Bands[2].Mask);
               SetAPen(JARenderRasterPort, Palette^.Bands[2].Mask);
               AreaMove(JARenderRasterPort, AShadow^.ShadowPenumbra1Fins[0].Vertex[0].X, AShadow^.ShadowPenumbra1Fins[0].Vertex[0].Y);
               for J := 1 to AShadow^.ShadowPenumbra1Fins[0].VertexCount-1 do
               AreaDraw(JARenderRasterPort, AShadow^.ShadowPenumbra1Fins[0].Vertex[J].X, AShadow^.ShadowPenumbra1Fins[0].Vertex[J].Y);
               AreaEnd(JARenderRasterPort);

               SetAfPt(JARenderRasterPort, nil, 0);
               SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
               SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
               AreaMove(JARenderRasterPort, AShadow^.ShadowPenumbra1Fins[1].Vertex[0].X, AShadow^.ShadowPenumbra1Fins[1].Vertex[0].Y);
               for J := 1 to AShadow^.ShadowPenumbra1Fins[1].VertexCount-1 do
               AreaDraw(JARenderRasterPort, AShadow^.ShadowPenumbra1Fins[1].Vertex[J].X, AShadow^.ShadowPenumbra1Fins[1].Vertex[J].Y);
               AreaEnd(JARenderRasterPort);

               SetAfPt(JARenderRasterPort, @DitherPattern, 1);
               SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
               SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
               AreaMove(JARenderRasterPort, AShadow^.ShadowPenumbra1Fins[2].Vertex[0].X, AShadow^.ShadowPenumbra1Fins[2].Vertex[0].Y);
               for J := 1 to AShadow^.ShadowPenumbra1Fins[2].VertexCount-1 do
               AreaDraw(JARenderRasterPort, AShadow^.ShadowPenumbra1Fins[2].Vertex[J].X, AShadow^.ShadowPenumbra1Fins[2].Vertex[J].Y);
               AreaEnd(JARenderRasterPort);
            end;

            {Disable area fill pattern}
            SetAfPt(JARenderRasterPort, nil, 0);
            SetWrMsk(JARenderRasterPort, %00000111); {Disable writing to Shadow Channel}
         end;
      end;
   end;

   {$ENDIF}

   {
   if APolygon^.ShadowCast then
   begin
      //JARenderRasterPort := @JARenderPenSet^.PenGreen^.RasterPort;

      {draw Face Normals}
      {for I := 0 to APolygon^.VertexCount-2 do
      begin
         {Calculate Face Normal}
         FaceNormal.Y := (-(APolygon^.WorldVertexI[I].X-APolygon^.WorldVertexI[I+1].X))/2;
         FaceNormal.X := ((APolygon^.WorldVertexI[I].Y-APolygon^.WorldVertexI[I+1].Y))/2;
         GfxMove(JARenderRasterPort, APolygon^.WorldVertexI[I].X, APolygon^.WorldVertexI[I].Y);
         Draw(JARenderRasterPort, APolygon^.WorldVertexI[I].X + Round(FaceNormal.X), APolygon^.WorldVertexI[I].Y + Round(FaceNormal.Y));
      end;}


      {Draw Boundry Points}
      {WritePixel(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowVertexStart].X, APolygon^.WorldVertexI[APolygon^.ShadowVertexStart].Y);
      WritePixel(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowVertexEnd].X, APolygon^.WorldVertexI[APolygon^.ShadowVertexEnd].Y);}




      {if (APolygon^.ShadowVertexStart > -1) and (APolygon^.ShadowVertexEnd > -1) then
      begin

         {draw back facing edges}
         JARenderRasterPort := @JARenderPenSet^.PenRed^.RasterPort;

         BackIndex := APolygon^.ShadowVertexStart;
         GfxMove(JARenderRasterPort, APolygon^.WorldVertexI[BackIndex].X, APolygon^.WorldVertexI[BackIndex].Y);
         repeat
            BackIndex := (BackIndex + 1) mod (APolygon^.VertexCount);
            Draw(JARenderRasterPort, APolygon^.WorldVertexI[BackIndex].X, APolygon^.WorldVertexI[BackIndex].Y);
         until (BackIndex = APolygon^.ShadowVertexEnd);

         {draw start and end umbras/penumbras}

         {Start}
         JARenderRasterPort := @JARenderPenSet^.PenYellow^.RasterPort;

         AVec := Vec2DotMat3(APolygon^.StartUmbra, JARenderMVP);
         GfxMove(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowVertexStart].X, APolygon^.WorldVertexI[APolygon^.ShadowVertexStart].Y);
         Draw(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowVertexStart].X + round(AVec.X), APolygon^.WorldVertexI[APolygon^.ShadowVertexStart].Y +round(AVec.Y));
         JARenderRasterPort := @JARenderPenSet^.PenCyan^.RasterPort;

         AVec := Vec2DotMat3(APolygon^.StartPenumbra, JARenderMVP);
         GfxMove(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowPenumbra0Index].X, APolygon^.WorldVertexI[APolygon^.ShadowPenumbra0Index].Y);
         Draw(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowPenumbra0Index].X + round(AVec.X), APolygon^.WorldVertexI[APolygon^.ShadowPenumbra0Index].Y +round(AVec.Y));

         //GfxMove(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowVertexStart].X, APolygon^.WorldVertexI[APolygon^.ShadowVertexStart].Y);
         //Draw(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowVertexStart].X + round(AVec.X), APolygon^.WorldVertexI[APolygon^.ShadowVertexStart].Y +round(AVec.Y));

         JARenderRasterPort := @JARenderPenSet^.PenYellow^.RasterPort;

         AVec := Vec2DotMat3(APolygon^.EndUmbra, JARenderMVP);
         GfxMove(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowVertexEnd].X, APolygon^.WorldVertexI[APolygon^.ShadowVertexEnd].Y);
         Draw(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowVertexEnd].X + round(AVec.X), APolygon^.WorldVertexI[APolygon^.ShadowVertexEnd].Y +round(AVec.Y));
         JARenderRasterPort := @JARenderPenSet^.PenCyan^.RasterPort;

         AVec := Vec2DotMat3(APolygon^.EndPenumbra, JARenderMVP);
         GfxMove(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowPenumbra1Index].X, APolygon^.WorldVertexI[APolygon^.ShadowPenumbra1Index].Y);
         Draw(JARenderRasterPort, APolygon^.WorldVertexI[APolygon^.ShadowPenumbra1Index].X + round(AVec.X), APolygon^.WorldVertexI[APolygon^.ShadowPenumbra1Index].Y +round(AVec.Y));

      end; }


      if APolygon^.ShadowVertexCount > 0 then
      begin


         {Draw shadow volume}

         {GfxMove(JARenderRasterPort, round(APolygon^.ShadowVertex[0].X), round(APolygon^.ShadowVertex[0].Y));
         for I := 1 to APolygon^.ShadowVertexCount-1 do
            Draw(JARenderRasterPort, round(APolygon^.ShadowVertex[I].X), round(APolygon^.ShadowVertex[I].Y));
         Draw(JARenderRasterPort, round(APolygon^.ShadowVertex[0].X), round(APolygon^.ShadowVertex[0].Y));}

                  //SetAPen(JARenderRasterPort, 0); // Clear the Extra-Half-Brite bit
         //RectFill(JARenderRasterPort, JARenderClipRect.Left, JARenderClipRect.Top, JARenderClipRect.Right, JARenderClipRect.Bottom);

         SetWriteMask(JARenderRasterPort, %11000); {Write to Shadow Channel}
         SetAPen(JARenderRasterPort, {24} %11000); {write 1s}

         AreaMove(JARenderRasterPort, round(APolygon^.ShadowVertex[0].X), round(APolygon^.ShadowVertex[0].Y));
         for I := 1 to APolygon^.ShadowVertexCount-1 do
            AreaDraw(JARenderRasterPort, round(APolygon^.ShadowVertex[I].X), round(APolygon^.ShadowVertex[I].Y));
         AreaEnd(JARenderRasterPort);


         {Use dither Pattern}
         DitherPattern[1] := %0101010101010101;
         DitherPattern[0] := %1010101010101010;
         //DitherPattern[0] := $5555;
         //DitherPattern[1] := $AAAA;
         //SetAfPt(JARenderRasterPort, @DitherPattern, 1);
         SetDrMd(JARenderRasterPort, JAM1);

         SetWriteMask(JARenderRasterPort, %01000); {Write to Shadow Channel}
         SetAPen(JARenderRasterPort, {8} %01000); {write 1s}


         //JARenderLightFan(ANode^.Spatial.WorldPosition, OuterConeRotation, OuterConeRotation+OuterConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);

         //JARenderLightFan(APolygon^.ShadowPenumbra0Vertex[0], 30, 50, 10000);


         if APolygon^.ShadowPenumbra0VertexCount > 0 then
         begin

            SetAfPt(JARenderRasterPort, nil, 0);
            SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
            SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
            AreaMove(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[0].Vertex[0].X, APolygon^.ShadowPenumbra0Fins[0].Vertex[0].Y);
            for J := 1 to APolygon^.ShadowPenumbra0Fins[0].VertexCount-1 do
            AreaDraw(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[0].Vertex[J].X, APolygon^.ShadowPenumbra0Fins[0].Vertex[J].Y);
            AreaEnd(JARenderRasterPort);

            SetAfPt(JARenderRasterPort, @DitherPattern, 1);
            SetWriteMask(JARenderRasterPort, Palette^.Bands[2].Mask);
            SetAPen(JARenderRasterPort, Palette^.Bands[2].Mask);
            AreaMove(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[0].Vertex[0].X, APolygon^.ShadowPenumbra0Fins[0].Vertex[0].Y);
            for J := 1 to APolygon^.ShadowPenumbra0Fins[0].VertexCount-1 do
            AreaDraw(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[0].Vertex[J].X, APolygon^.ShadowPenumbra0Fins[0].Vertex[J].Y);
            AreaEnd(JARenderRasterPort);

            SetAfPt(JARenderRasterPort, nil, 0);
            SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
            SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
            AreaMove(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[1].Vertex[0].X, APolygon^.ShadowPenumbra0Fins[1].Vertex[0].Y);
            for J := 1 to APolygon^.ShadowPenumbra0Fins[1].VertexCount-1 do
            AreaDraw(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[1].Vertex[J].X, APolygon^.ShadowPenumbra0Fins[1].Vertex[J].Y);
            AreaEnd(JARenderRasterPort);

            SetAfPt(JARenderRasterPort, @DitherPattern, 1);
            SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
            SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
            AreaMove(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[2].Vertex[0].X, APolygon^.ShadowPenumbra0Fins[2].Vertex[0].Y);
            for J := 1 to APolygon^.ShadowPenumbra0Fins[2].VertexCount-1 do
            AreaDraw(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[2].Vertex[J].X, APolygon^.ShadowPenumbra0Fins[2].Vertex[J].Y);
            AreaEnd(JARenderRasterPort);


          { for I := 0 to JARenderLightFinCount-1 do
            begin

               if (I=0) then
               begin
                  SetAfPt(JARenderRasterPort, nil, 0);
                  SetWriteMask(JARenderRasterPort, Palette^.Bands[2-I-1].Mask);
                  SetAPen(JARenderRasterPort, Palette^.Bands[2-I-1].Mask);
                  AreaMove(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[I].Vertex[0].X, APolygon^.ShadowPenumbra0Fins[I].Vertex[0].Y);

                  for J := 1 to APolygon^.ShadowPenumbra0Fins[I].VertexCount-1 do
                  AreaDraw(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[I].Vertex[J].X, APolygon^.ShadowPenumbra0Fins[I].Vertex[J].Y);

                  AreaEnd(JARenderRasterPort);
               end;

               if ((I+1) mod 2 = 1) then
                  SetAfPt(JARenderRasterPort, @DitherPattern, 1) else
                  SetAfPt(JARenderRasterPort, nil, 0);


               SetWriteMask(JARenderRasterPort, Palette^.Bands[2-I].Mask);
               SetAPen(JARenderRasterPort, Palette^.Bands[2-I].Mask);

               AreaMove(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[I].Vertex[0].X, APolygon^.ShadowPenumbra0Fins[I].Vertex[0].Y);

               for J := 1 to APolygon^.ShadowPenumbra0Fins[I].VertexCount-1 do
                  AreaDraw(JARenderRasterPort, APolygon^.ShadowPenumbra0Fins[I].Vertex[J].X, APolygon^.ShadowPenumbra0Fins[I].Vertex[J].Y);

               AreaEnd(JARenderRasterPort);
            end; }




            {Draw shadow volume}

            {GfxMove(JARenderRasterPort, round(APolygon^.ShadowVertex[0].X), round(APolygon^.ShadowVertex[0].Y));
            for I := 1 to APolygon^.ShadowVertexCount-1 do
               Draw(JARenderRasterPort, round(APolygon^.ShadowVertex[I].X), round(APolygon^.ShadowVertex[I].Y));
            Draw(JARenderRasterPort, round(APolygon^.ShadowVertex[0].X), round(APolygon^.ShadowVertex[0].Y));}

            //SetWriteMask(JARenderRasterPort, %100000); {Disable Planes 1-5}

            //SetAPen(JARenderRasterPort, 0); // Clear the Extra-Half-Brite bit
            //RectFill(JARenderRasterPort, JARenderClipRect.Left, JARenderClipRect.Top, JARenderClipRect.Right, JARenderClipRect.Bottom);

            //SetAPen(JARenderRasterPort, 32); {Set the EHB bit}

            {AreaMove(JARenderRasterPort, round(APolygon^.ShadowPenumbra0Vertex[0].X), round(APolygon^.ShadowPenumbra0Vertex[0].Y));
            for I := 1 to APolygon^.ShadowPenumbra0VertexCount-1 do
               AreaDraw(JARenderRasterPort, round(APolygon^.ShadowPenumbra0Vertex[I].X), round(APolygon^.ShadowPenumbra0Vertex[I].Y));
            AreaEnd(JARenderRasterPort);}

            //SetWrMsk(JARenderRasterPort, %011111); { Enable Planes 1-5}
         end;

          if APolygon^.ShadowPenumbra1VertexCount > 0 then
         begin

            SetAfPt(JARenderRasterPort, nil, 0);
            SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
            SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
            AreaMove(JARenderRasterPort, APolygon^.ShadowPenumbra1Fins[0].Vertex[0].X, APolygon^.ShadowPenumbra1Fins[0].Vertex[0].Y);
            for J := 1 to APolygon^.ShadowPenumbra1Fins[0].VertexCount-1 do
            AreaDraw(JARenderRasterPort, APolygon^.ShadowPenumbra1Fins[0].Vertex[J].X, APolygon^.ShadowPenumbra1Fins[0].Vertex[J].Y);
            AreaEnd(JARenderRasterPort);

            SetAfPt(JARenderRasterPort, @DitherPattern, 1);
            SetWriteMask(JARenderRasterPort, Palette^.Bands[2].Mask);
            SetAPen(JARenderRasterPort, Palette^.Bands[2].Mask);
            AreaMove(JARenderRasterPort, APolygon^.ShadowPenumbra1Fins[0].Vertex[0].X, APolygon^.ShadowPenumbra1Fins[0].Vertex[0].Y);
            for J := 1 to APolygon^.ShadowPenumbra1Fins[0].VertexCount-1 do
            AreaDraw(JARenderRasterPort, APolygon^.ShadowPenumbra1Fins[0].Vertex[J].X, APolygon^.ShadowPenumbra1Fins[0].Vertex[J].Y);
            AreaEnd(JARenderRasterPort);

            SetAfPt(JARenderRasterPort, nil, 0);
            SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
            SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
            AreaMove(JARenderRasterPort, APolygon^.ShadowPenumbra1Fins[1].Vertex[0].X, APolygon^.ShadowPenumbra1Fins[1].Vertex[0].Y);
            for J := 1 to APolygon^.ShadowPenumbra1Fins[1].VertexCount-1 do
            AreaDraw(JARenderRasterPort, APolygon^.ShadowPenumbra1Fins[1].Vertex[J].X, APolygon^.ShadowPenumbra1Fins[1].Vertex[J].Y);
            AreaEnd(JARenderRasterPort);

            SetAfPt(JARenderRasterPort, @DitherPattern, 1);
            SetWriteMask(JARenderRasterPort, Palette^.Bands[1].Mask);
            SetAPen(JARenderRasterPort, Palette^.Bands[1].Mask);
            AreaMove(JARenderRasterPort, APolygon^.ShadowPenumbra1Fins[2].Vertex[0].X, APolygon^.ShadowPenumbra1Fins[2].Vertex[0].Y);
            for J := 1 to APolygon^.ShadowPenumbra1Fins[2].VertexCount-1 do
            AreaDraw(JARenderRasterPort, APolygon^.ShadowPenumbra1Fins[2].Vertex[J].X, APolygon^.ShadowPenumbra1Fins[2].Vertex[J].Y);
            AreaEnd(JARenderRasterPort);


            {SetWriteMask(JARenderRasterPort, %01000); {Write to Shadow Channel}
            SetAPen(JARenderRasterPort, {8} %01000); {write 1s}

            {Draw shadow volume}

            {GfxMove(JARenderRasterPort, round(APolygon^.ShadowVertex[0].X), round(APolygon^.ShadowVertex[0].Y));
            for I := 1 to APolygon^.ShadowVertexCount-1 do
               Draw(JARenderRasterPort, round(APolygon^.ShadowVertex[I].X), round(APolygon^.ShadowVertex[I].Y));
            Draw(JARenderRasterPort, round(APolygon^.ShadowVertex[0].X), round(APolygon^.ShadowVertex[0].Y));}

            //SetWriteMask(JARenderRasterPort, %100000); {Disable Planes 1-5}

            //SetAPen(JARenderRasterPort, 0); // Clear the Extra-Half-Brite bit
            //RectFill(JARenderRasterPort, JARenderClipRect.Left, JARenderClipRect.Top, JARenderClipRect.Right, JARenderClipRect.Bottom);

            //SetAPen(JARenderRasterPort, 32); {Set the EHB bit}

            AreaMove(JARenderRasterPort, round(APolygon^.ShadowPenumbra1Vertex[0].X), round(APolygon^.ShadowPenumbra1Vertex[0].Y));
            for I := 1 to APolygon^.ShadowPenumbra1VertexCount-1 do
               AreaDraw(JARenderRasterPort, round(APolygon^.ShadowPenumbra1Vertex[I].X), round(APolygon^.ShadowPenumbra1Vertex[I].Y));
            AreaEnd(JARenderRasterPort);

            //SetWrMsk(JARenderRasterPort, %011111); { Enable Planes 1-5} }
         end;


         {Disable area fill pattern}
         SetAfPt(JARenderRasterPort, nil, 0);
         SetWrMsk(JARenderRasterPort, %00000111); {Disable writing to Shadow Channel}



      end;
   end;

   {
	TransformVec := Vec2DotMat3Affine(APolygon^.Vertex[0].Position, JARenderMVP);
   AreaMove(JARenderRasterPort, round(TransformVec.X), round(TransformVec.Y));
   for I := 1 to APolygon^.VertexCount-1 do
   begin
      TransformVec := Vec2DotMat3Affine(APolygon^.Vertex[I].Position, JARenderMVP);
      AreaDraw(JARenderRasterPort, round(TransformVec.X), round(TransformVec.Y));
   end;
   TransformVec := Vec2DotMat3Affine(APolygon^.Vertex[0].Position, JARenderMVP);
   AreaEnd(JARenderRasterPort);
   }
    }

   //WaitBlit();


    {Wireframe}

	{TODO : use polydraw with a pretransformed buffer}
   {
   To turn off the outline function, you have to set the RastPort Flags variable back to 0 with BNDRYOFF():
   #include <graphics/gfxmacros.h>
   BNDRYOFF(&rastPort);
   Otherwise, every subsequent area-fill or rectangle-fill operation will outline their rendering with the outline pen (AOlPen)
   }

   {
   TransformVec := Vec2DotMat3Affine(APolygon^.Vertex[0].Position, JARenderMVP);
   GfxMove(JARenderRasterPort, round(TransformVec.X), round(TransformVec.Y));

   for I := 1 to APolygon^.VertexCount-1 do
   begin
      TransformVec := Vec2DotMat3Affine(APolygon^.Vertex[I].Position, JARenderMVP);
      Draw(JARenderRasterPort, round(TransformVec.X), round(TransformVec.Y));
   end;
   
   TransformVec := Vec2DotMat3Affine(APolygon^.Vertex[0].Position, JARenderMVP);
   Draw(JARenderRasterPort, round(TransformVec.X), round(TransformVec.Y))
   }
end;

procedure JARenderCircle(APosition: TVec2SInt16; ARadius : SInt16);
begin
   DrawCircle(JARenderRasterPort, round(APosition.X), round(APosition.Y), ARadius);

   //DrawCircle(&rastPort, center_x, center_y, radius);
   //IGraphics->AreaCircle(&rastPort, center_x, center_y, radius);
end;

procedure JARenderCone(APosition: TVec2; ARotation: Float32; AConeAngle: Float32; ARadius: Float32);
var
   A, B : TVec2;
   Rooti,Ai,Bi : TVec2SInt16;
begin
   A := APosition + (Vec2Rotate(Vec2Up, ARotation - (AConeAngle / 2)) * ARadius);
   B := APosition + (Vec2Rotate(Vec2Up, ARotation + (AConeAngle / 2)) * ARadius);

   Rooti.X := round(JARenderMVP._00*APosition.X + JARenderMVP._01*APosition.Y  + JARenderMVP._02);
   Rooti.Y := round(JARenderMVP._10*APosition.X + JARenderMVP._11*APosition.Y  + JARenderMVP._12);
   Ai.X := round(JARenderMVP._00*A.X + JARenderMVP._01*A.Y  + JARenderMVP._02);
   Ai.Y := round(JARenderMVP._10*A.X + JARenderMVP._11*A.Y  + JARenderMVP._12);
   Bi.X := round(JARenderMVP._00*B.X + JARenderMVP._01*B.Y  + JARenderMVP._02);
   Bi.Y := round(JARenderMVP._10*B.X + JARenderMVP._11*B.Y  + JARenderMVP._12);

   AreaMove(JARenderRasterPort, Rooti.X, Rooti.Y);
   AreaDraw(JARenderRasterPort, Ai.X, Ai.Y);
   AreaDraw(JARenderRasterPort, Bi.X, Bi.Y);
   AreaEnd(JARenderRasterPort);
end;

procedure JARenderConeClipped(APosition: TVec2; ARotation: Float32; AConeAngle: Float32; ARadius: Float32);
var
   A, B, Root : TVec2;
   A2, B2 : TVec2;
   SideA, SideB : TJRectSide;
   Intersect : TVec2;
   VecCount : SInt16;
begin
   A := APosition + (Vec2Rotate(Vec2Up, ARotation - (AConeAngle / 2)) * ARadius);
   B := APosition + (Vec2Rotate(Vec2Up, ARotation + (AConeAngle / 2)) * ARadius);

   Root.X := JARenderMVP._00*APosition.X + JARenderMVP._01*APosition.Y  + JARenderMVP._02;
   Root.Y := JARenderMVP._10*APosition.X + JARenderMVP._11*APosition.Y  + JARenderMVP._12;
   A2.X := JARenderMVP._00*A.X + JARenderMVP._01*A.Y  + JARenderMVP._02;
   A2.Y := JARenderMVP._10*A.X + JARenderMVP._11*A.Y  + JARenderMVP._12;
   B2.X := JARenderMVP._00*B.X + JARenderMVP._01*B.Y  + JARenderMVP._02;
   B2.Y := JARenderMVP._10*B.X + JARenderMVP._11*B.Y  + JARenderMVP._12;

   {Calculate intersection with clipping Rect}
   if JRectIntersectLineResult(Vec2SInt16(Root), A2, JARenderClipRect, SideA, Intersect) then
      A2 := Intersect;

   if JRectIntersectLineResult(Vec2SInt16(Root), B2, JARenderClipRect, SideB, Intersect) then
      B2 := Intersect;

   AreaMove(JARenderRasterPort, round(Root.X), round(Root.Y));
   AreaDraw(JARenderRasterPort, round(B2.X), round(B2.Y));

   {Query Side Spanning}
   if JRectSideClipping(SideA, SideB, JRect(JARenderClipRect), A, B, VecCount) then
   begin
      AreaDraw(JARenderRasterPort, round(A.X), round(A.Y));
      if VecCount=2 then
      AreaDraw(JARenderRasterPort, round(B.X), round(B.Y));
   end;

   AreaDraw(JARenderRasterPort, round(A2.X), round(A2.Y));
   AreaEnd(JARenderRasterPort);
end;

procedure JARenderLightFan(APosition: TVec2; AAngle0, AAngle1 : Float32; ARadius: Float32);
var
   I,CurrentBand : SInt16;
   AngleTotal,AngleStep,AngleCurrent : Float32;
   BandStep : SInt16;

   Rotation : SInt16;
   DitherPattern : array[0..1] of UInt16;

begin
   {$IFDEF JA_ENABLE_SHADOW}
   DitherPattern[1] := %0101010101010101;
   DitherPattern[0] := %1010101010101010;


   AngleTotal := AAngle1 - AAngle0;
   AngleStep := AngleTotal / JARenderLightFinCount;

   {need :
   WriteMask for each Shadow Level
   compatible WriteValue for each WriteMask.
   dither alternator}

   AngleCurrent := AAngle0;
   CurrentBand := 1;
   I := 0;

   SetWriteMask(JARenderRasterPort, Palette^.Bands[CurrentBand].Mask);
   SetAPen(JARenderRasterPort, Palette^.Bands[CurrentBand].Mask);

   {Draw Dither Fin}
   SetAfPt(JARenderRasterPort, @DitherPattern, 1);
   JARenderConeClipped(APosition, AngleCurrent - (AngleStep/2), AngleStep, ARadius);

   AngleCurrent -= AngleStep;

   {Draw Solid Fin}
   SetAfPt(JARenderRasterPort, nil, 0);
   JARenderConeClipped(APosition, AngleCurrent - (AngleStep/1), AngleStep*2, ARadius);

   AngleCurrent -= AngleStep;

   CurrentBand += 1;
   SetWriteMask(JARenderRasterPort, Palette^.Bands[CurrentBand].Mask);
   SetAPen(JARenderRasterPort, Palette^.Bands[CurrentBand].Mask);

   {Draw Dither Fin}
   SetAfPt(JARenderRasterPort, @DitherPattern, 1);
   JARenderConeClipped(APosition, AngleCurrent - (AngleStep/2), AngleStep, ARadius);

   SetWriteMask(JARenderRasterPort, %00001111); {Don't Write to LightPlanes}

   AngleCurrent -= AngleStep;
   {$ENDIF}
end;

end.
