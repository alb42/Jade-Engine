unit JAShadow;
{$mode objfpc}{$H+}

interface

uses
   sysutils, math,
   JATypes, JAGlobal, JAMath, JAPolygon, JARender;

function JAPolygonShadowVertexAdd(APolygon : PJAPolygon) : PVec2SInt16;
function JAPolygonShadowPenumbra0VertexAdd(APolygon : PJAPolygon) : PVec2SInt16;
function JAPolygonShadowPenumbra1VertexAdd(APolygon : PJAPolygon) : PVec2SInt16;

procedure JAPolygonShadowGenerate(APolygon: PJAPolygon; AShadowIndex : SInt16; APolygonPosition : TVec2; ALightPosition : TVec2; ALightRadius : Float32; AViewMatrix : TMat3; ClipRect : TJRectSInt16);

implementation

function JAPolygonShadowVertexAdd(APolygon : PJAPolygon): PVec2SInt16;
var
   NewCapacity : SInt32;
begin
   NewCapacity := APolygon^.ShadowVertexCapacity;
   if (NewCapacity=0) then NewCapacity := JAPool_BlockSize else
   if (APolygon^.ShadowVertexCount+1) > NewCapacity then NewCapacity += JAPool_BlockSize;
   if NewCapacity<>APolygon^.ShadowVertexCapacity then
   begin
      if APolygon^.ShadowVertexCapacity=0 then
      begin
         APolygon^.ShadowVertex := JAMemGet(SizeOf(TVec2SInt16)*NewCapacity);
      end else
      begin
         APolygon^.ShadowVertex := reallocmem(APolygon^.ShadowVertex, SizeOf(TVec2SInt16)*NewCapacity);
      end;
     APolygon^.ShadowVertexCapacity := NewCapacity;
   end;

   Result := @APolygon^.ShadowVertex[APolygon^.ShadowVertexCount];

   APolygon^.ShadowVertexCount += 1;
end;

function JAPolygonShadowPenumbra0VertexAdd(APolygon: PJAPolygon): PVec2SInt16;
var
   NewCapacity : SInt32;
begin
   NewCapacity := APolygon^.ShadowPenumbra0VertexCapacity;
   if (NewCapacity=0) then NewCapacity := JAPool_BlockSize else
   if (APolygon^.ShadowPenumbra0VertexCount+1) > NewCapacity then NewCapacity += JAPool_BlockSize;
   if NewCapacity<>APolygon^.ShadowPenumbra0VertexCapacity then
   begin
      if APolygon^.ShadowPenumbra0VertexCapacity=0 then
      begin
         APolygon^.ShadowPenumbra0Vertex := JAMemGet(SizeOf(TVec2SInt16)*NewCapacity);
      end else
      begin
         APolygon^.ShadowPenumbra0Vertex := reallocmem(APolygon^.ShadowPenumbra0Vertex, SizeOf(TVec2SInt16)*NewCapacity);
      end;
     APolygon^.ShadowPenumbra0VertexCapacity := NewCapacity;
   end;

   Result := @APolygon^.ShadowPenumbra0Vertex[APolygon^.ShadowPenumbra0VertexCount];

   APolygon^.ShadowPenumbra0VertexCount += 1;
end;

function JAPolygonShadowPenumbra1VertexAdd(APolygon: PJAPolygon): PVec2SInt16;
var
   NewCapacity : SInt32;
begin
   NewCapacity := APolygon^.ShadowPenumbra1VertexCapacity;
   if (NewCapacity=0) then NewCapacity := JAPool_BlockSize else
   if (APolygon^.ShadowPenumbra1VertexCount+1) > NewCapacity then NewCapacity += JAPool_BlockSize;
   if NewCapacity<>APolygon^.ShadowPenumbra1VertexCapacity then
   begin
      if APolygon^.ShadowPenumbra1VertexCapacity=0 then
      begin
         APolygon^.ShadowPenumbra1Vertex := JAMemGet(SizeOf(TVec2SInt16)*NewCapacity);
      end else
      begin
         APolygon^.ShadowPenumbra1Vertex := reallocmem(APolygon^.ShadowPenumbra1Vertex, SizeOf(TVec2SInt16)*NewCapacity);
      end;
     APolygon^.ShadowPenumbra1VertexCapacity := NewCapacity;
   end;

   Result := @APolygon^.ShadowPenumbra1Vertex[APolygon^.ShadowPenumbra1VertexCount];

   APolygon^.ShadowPenumbra1VertexCount += 1;
end;

procedure JAPolygonShadowGenerate(APolygon: PJAPolygon; AShadowIndex: SInt16; APolygonPosition: TVec2; ALightPosition: TVec2; ALightRadius: Float32; AViewMatrix: TMat3; ClipRect: TJRectSInt16);
var
   I,J : SInt32;
   AVec,Vec1 : TVec2;
   ANormal : TVec2;
   A,B : TVec2;
   VecCount : SInt16;
   Angle0,Angle1,F0 : Float32;

   LightVector : TVec2; {From the centre of the light to the current polygon vertex}
   LightDirection : TVec2; {Normalized LightVector}

   EdgeVector : TVec2; {Vector of Face}
   UmbraVector : TVec2; {Inner Edge}
   PenumbraVector : TVec2; {Outer Edge}
   UmbraDirection : TVec2; {Normalized UmbraVector}
   PenumbraDirection : TVec2; {Normalized PenumbraVector}
   FaceBack, FaceBackPrevious : boolean;
   UmbraPrevious : TVec2; {To save having to calculate it during fin movement}

   BackIndex : SInt32;
   Intersect : TVec2;

   AShadow : PJAPolygonShadow;

   ShadowHullStart, ShadowHullEnd : TVec2SInt16;
   ShadowHullStartSide, ShadowHullEndSide : TJRectSide;

   Penumbra0Start : TVec2SInt16;
   Penumbra1Start : TVec2SInt16;
   Penumbra0StartSide, Penumbra1StartSide : TJRectSide;

   Penumbra0HotFin : SInt16;
   Penumbra1HotFin : SInt16;

   Penumbra0FinVectors : array[0..3] of TVec2;
   Penumbra1FinVectors : array[0..3] of TVec2;

   procedure CalcultePolygonVertex(AVertexIndex : SInt32);
   begin
      LightVector := ALightPosition - APolygon^.WorldVertex[AVertexIndex];
      LightDirection := Vec2Normalize(LightVector);
      {Umbra and Penumbra Vector Calculation}
      {Get Perpendicular Vector}
      AVec.Y := -LightDirection.X;
      AVec.X := LightDirection.Y;

      {Get Poly Centre to Vertex Vector}
      ANormal := Vec2Normalize(APolygon^.WorldVertex[AVertexIndex]-APolygonPosition);
      {Ensure Correct Orientation of Vector}
      if (Vec2Dot(ANormal, AVec) < 0) then AVec := -AVec;
      {Scale the perpendicular vector by the radius of the light}
      AVec *= ALightRadius;
      UmbraVector := LightVector + AVec;
      PenumbraVector := LightVector + (-Avec);
      UmbraDirection := Vec2Normalize(UmbraVector);
      PenumbraDirection := Vec2Normalize(PenumbraVector);
      {Get Face Normal}
      EdgeVector := APolygon^.WorldVertex[AVertexIndex]-APolygon^.WorldVertex[(AVertexIndex+1) mod APolygon^.VertexCount];
      ANormal.Y := -EdgeVector.X;
      ANormal.X := EdgeVector.Y;
      ANormal := Vec2Normalize(ANormal);
      {Determine if Face is Pointing backwards from Outer Edge of the Light (UmbraDirection)}
      FaceBack := (Vec2Dot(ANormal, PenumbraDirection) < 0);
   end;

begin
   if (APolygon^.VertexCount <= 1) then exit;

   {if JAPolygonIntersectVertex(APolygon, ALightPosition) then
   begin {Don't generate shadow for the polygon if the light is inside the polygon}
      APolygon^.ShadowVertexCount := 0;
      exit;
   end;  }
   AShadow := @APolygon^.Shadows[AShadowIndex];
   with AShadow^ do
   begin
      {Find backfacing edges and shadow start and end indices}

      ShadowVertexStart := -1;
      ShadowVertexEnd := -1;

      FaceBack := false;
      FaceBackPrevious := false;

      Penumbra0HotFin := 1000;
      Penumbra1HotFin := 1000;

      CalcultePolygonVertex(APolygon^.VertexCount-1);

      {Find Back-facing Boundry Indices}
      for I := 0 to APolygon^.VertexCount-1 do
      begin
         {Set High as default}


         FaceBackPrevious := FaceBack;
         UmbraPrevious := UmbraVector; {store the previous umbra for later use}

         CalcultePolygonVertex(I);

         if (ShadowVertexStart = -1) and not FaceBackPrevious and FaceBack then
         begin
            {Store State}
            ShadowVertexStart := I;
            StartUmbra := -UmbraVector*10;
            StartPenumbra := -PenumbraVector*10;
            ShadowPenumbra0Index := I;

            {Snap Umbra Edge to Face Edge if overlapping Face Edge}
            Angle0 := Vec2Angle(StartPenumbra, -EdgeVector);
            Angle1 := Vec2Angle(StartPenumbra, StartUmbra);
            if (Angle1 < Angle0) then
            begin
               StartUmbra := -EdgeVector;

               ShadowVertexStart := JRepeat(I+1,0,APolygon^.VertexCount-1); {Move the shadow backwards}

               {Calculate Next Umbra}
               LightVector := ALightPosition - APolygon^.WorldVertex[ShadowVertexStart];
               LightDirection := Vec2Normalize(LightVector);
               {Umbra and Penumbra Vector Calculation}
               {Get Perpendicular Vector}
               AVec.Y := -LightDirection.X;
               AVec.X := LightDirection.Y;
               {Scale the perpendicular vector by the radius of the light}
               AVec *= ALightRadius;
               {Get Poly Centre to Vertex Vector}
               ANormal := Vec2Normalize(APolygon^.WorldVertex[ShadowVertexStart]-APolygonPosition);
               {Ensure Correct Orientation of Vector}
               if (Vec2Dot(ANormal, AVec) < 0) then AVec := -AVec;
               UmbraVector := LightVector + AVec;
               Startumbra := -UmbraVector*10;

               //Angle1 := abs(Angle1);
               Angle1 := abs(Vec2Angle(StartPenumbra, StartUmbra));
               Angle1 /= (JARenderLightFinCount);

               {F0 := 0;
               Penumbra0HotFin := 0;
               while F0 < abs(Angle0) do
               begin
                  F0 += Angle1;
                  Penumbra0HotFin += 1;
               end;
               Penumbra0HotFin := 3-Penumbra0HotFin;//
               }

               Penumbra0HotFin := 2-floor((abs(Angle0)/(abs(Angle1))));
            end;

            Penumbra0FinVectors[0] := StartUmbra;
            for J := 1 to JARenderLightFinCount-1 do
            begin
               Penumbra0FinVectors[J] := Vec2Lerp(StartUmbra,StartPenumbra,(J)/JARenderLightFinCount);

               Angle0 := Vec2Angle(Penumbra0FinVectors[J], -EdgeVector);
               Angle1 := Vec2Angle(Penumbra0FinVectors[J], Penumbra0FinVectors[J-1]);
               if (Angle1 < Angle0) then
               begin
                  Penumbra0FinVectors[J] := -EdgeVector;
               end;
            end;

         end;
         if (ShadowVertexEnd = -1) and FaceBackPrevious and not FaceBack then
         begin
            {Store State}
            ShadowVertexEnd := I;
            EndUmbra := -UmbraVector*10;
            EndPenumbra := -PenumbraVector*10;

            ShadowPenumbra1Index := I;

            {Calculate Previous Edge Vector}
            if (I-1) < 0 then J := APolygon^.VertexCount-1 else J := I-1;
            EdgeVector := APolygon^.WorldVertex[J]-APolygon^.WorldVertex[I];

            //EdgeVector := APolygon^.WorldVertex[JRepeat(I-1,0,APolygon^.VertexCount-1)]-APolygon^.WorldVertex[I];

            {Snap Umbra Edge to Face Edge if overlapping Face Edge}
            Angle0 := Vec2Angle(EdgeVector, EndPenumbra);
            Angle1 := Vec2Angle(EndUmbra, EndPenumbra);
            if (Angle1 < Angle0) then
            begin
               EndUmbra := EdgeVector;
               ShadowVertexEnd := JRepeat(I-1,0,APolygon^.VertexCount-1); {Move the shadow backwards}
               Endumbra := -umbraPrevious*10; {Use the Previous}

               Angle1 := abs(Vec2Angle(EndUmbra, EndPenumbra));
               Angle1 /= (JARenderLightFinCount);

               Penumbra1HotFin := 2-floor((abs(Angle0)/(abs(Angle1))));
            end;
         end;
         if (ShadowVertexStart > -1) and (ShadowVertexEnd > -1) then break;
      end;

      if (ShadowVertexStart <= -1) or (ShadowVertexEnd <= -1) then
      begin
         ShadowVertexCount := 0;
         exit;
      end;




     {Hard Edge Casting}

     {FaceBack := false;
      FaceBackPrevious := false;
      {Get Last Vertex -> First Vertex Face State}
      ANormal.Y := -(APolygon^.WorldVertex[APolygon^.VertexCount-1].X-APolygon^.WorldVertex[0].X);
      ANormal.X := (APolygon^.WorldVertex[APolygon^.VertexCount-1].Y-APolygon^.WorldVertex[0].Y);
      ANormal := Vec2Normalize(ANormal);
      LightDirection := Vec2Normalize(ALightPosition - APolygon^.WorldVertex[APolygon^.VertexCount-1]);
      FaceBack := (Vec2Dot(ANormal, LightDirection) < 0);

      {Find Back-facing Boundry Indices}
      for I := 0 to APolygon^.VertexCount-1 do
      begin
         FaceBackPrevious := FaceBack;

         {Normal is perpendicular to face}
         ANormal.Y := -(APolygon^.WorldVertex[I].X-APolygon^.WorldVertex[(I+1) mod APolygon^.VertexCount].X);
         ANormal.X := (APolygon^.WorldVertex[I].Y-APolygon^.WorldVertex[(I+1) mod APolygon^.VertexCount].Y);
         ANormal := Vec2Normalize(ANormal);
         LightDirection := Vec2Normalize(ALightPosition - APolygon^.WorldVertex[I]);
         FaceBack := (Vec2Dot(ANormal, LightDirection) < 0);

         {Detect Boundry Points - where front facing becomes back facing, where back facing becomes front facing}
         {Note : We're only dealing with convex polys atm - you can handle concave polys by detecting multiple
         sets of boundries and generating a shadow hull for each one}

         if (ShadowVertexStart = -1) and not FaceBackPrevious and FaceBack then ShadowVertexStart := I;
         if (ShadowVertexEnd = -1) and FaceBackPrevious and not FaceBack then ShadowVertexEnd := I;
         if (ShadowVertexStart > -1) and (ShadowVertexEnd > -1) then break;
      end; }



      {Reset Shadow Vertex Count - Memory not freed}
      AShadow^.ShadowVertexCount := 0;

      {Calculate Projected Shadow Hull Penumbra Vertices}

      {TODO : a fixed scale of 1000 is dodgy,
      we should calculate the direction vector, then Set its length
      so that it will be about two cliprects max width or height away,
      when we optimize for integer maths? we'll want the numbers constrained and managed.
      Like good little numbers.}

      {From Light Towards Boundry, pick a spot on that line far off in the distance}
      AVec.X := APolygon^.WorldVertex[ShadowVertexEnd].X + ((EndUmbra.X) * 1000 );
      AVec.Y := APolygon^.WorldVertex[ShadowVertexEnd].Y + ((EndUmbra.Y) * 1000 );
      AVec := Vec2DotMat3(AVec, AViewMatrix); {translate to screen space}

      {Calculate intersection with clipping Rect}
      if JRectIntersectLineResult(APolygon^.WorldVertexI[ShadowVertexEnd], AVec, ClipRect, ShadowHullEndSide, Intersect) then
         AVec := Intersect;

      ShadowHullEnd := Vec2SInt16(AVec);

      AVec.X := APolygon^.WorldVertex[ShadowVertexStart].X + ((StartUmbra.X) * 1000 );
      AVec.Y := APolygon^.WorldVertex[ShadowVertexStart].Y + ((StartUmbra.Y) * 1000 );
      AVec := Vec2DotMat3(AVec, AViewMatrix); {translate to screen space}

      {Calculate intersection with clipping Rect}
      if JRectIntersectLineResult(APolygon^.WorldVertexI[ShadowVertexStart], AVec, ClipRect, ShadowHullStartSide, Intersect) then
         AVec := Intersect;

      ShadowHullStart := Vec2SInt16(AVec);

      {Construct Shadow Geometry using Screen Space Coordinates}
      if (ShadowVertexStart > -1) and (ShadowVertexEnd > -1) then
      begin
         BackIndex := AShadow^.ShadowVertexStart;
         if not JRectIntersectVertex(APolygon^.WorldVertexI[BackIndex], ClipRect) then
         begin {Don't Render Offscreen shadows. No seriously, don't do it - it crashes. }
            ShadowVertexCount := 0;
            exit;
         end;
         JAShadowVertexAdd(AShadow)^ := APolygon^.WorldVertexI[BackIndex];
         repeat
            BackIndex := (BackIndex + 1) mod (APolygon^.VertexCount);
            if not JRectIntersectVertex(APolygon^.WorldVertexI[BackIndex], ClipRect) then
            begin
               ShadowVertexCount := 0;
               exit;
            end;
            JAShadowVertexAdd(AShadow)^ := APolygon^.WorldVertexI[BackIndex];
         until (BackIndex = AShadow^.ShadowVertexEnd);
      end;


      {Add First Point}
      JAShadowVertexAdd(AShadow)^ := ShadowHullEnd;
      {Query Side Spanning}
      if JRectSideClipping(ShadowHullStartSide, ShadowHullEndSide, JRect(ClipRect), A, B, VecCount) then
      begin
         JAShadowVertexAdd(AShadow)^ := Vec2SInt16(A);
         if VecCount=2 then
         JAShadowVertexAdd(AShadow)^ := Vec2SInt16(B);
      end;
      {Add Last Point}
      JAShadowVertexAdd(AShadow)^ := ShadowHullStart;




      {-------------------------------------------------------- Build Penumbras}


      //AVec.X := WorldVertex[ShadowPenumbra0Index].X + ((StartPenumbra.X) * 1000 );
      //AVec.Y := WorldVertex[ShadowPenumbra0Index].Y + ((StartPenumbra.Y) * 1000 );



      {Reset Penumbra Vertex Count}
      ShadowPenumbra0VertexCount := 0;
      ShadowPenumbra1VertexCount := 0;



      {Calculate Penumbra0 Polygon}
      AVec.X := APolygon^.WorldVertex[ShadowPenumbra0Index].X + ((StartPenumbra.X) * 1000 );
      AVec.Y := APolygon^.WorldVertex[ShadowPenumbra0Index].Y + ((StartPenumbra.Y) * 1000 );
      AVec := Vec2DotMat3(AVec, AViewMatrix); {translate to screen space}
      {Calculate intersection with clipping Rect}
      if JRectIntersectLineResult(APolygon^.WorldVertexI[ShadowPenumbra0Index], AVec, ClipRect, Penumbra0StartSide, Intersect) then
         AVec := Intersect;
      Penumbra0Start := Vec2SInt16(AVec);

      {Calculate Penumbra1 Polygon}
      AVec.X := APolygon^.WorldVertex[ShadowPenumbra1Index].X + ((EndPenumbra.X) * 1000 );
      AVec.Y := APolygon^.WorldVertex[ShadowPenumbra1Index].Y + ((EndPenumbra.Y) * 1000 );
      AVec := Vec2DotMat3(AVec, AViewMatrix); {translate to screen space}
      {Calculate intersection with clipping Rect}
      if JRectIntersectLineResult(APolygon^.WorldVertexI[ShadowPenumbra1Index], AVec, ClipRect, Penumbra1StartSide, Intersect) then
         AVec := Intersect;
      Penumbra1Start := Vec2SInt16(AVec);





      {Calculate Penumbra Fins}
      {for J := 0 to JARenderLightFinCount-1 do
      begin
         Penumbra0Fins[J] := Vec2Lerp(StartPenumbra, StartUmbra, J / JARenderLightFinCount);
         if (Vec2Angle(StartPenumbra, Penumbra0Fins[0]) < Vec2Angle(StartPenumbra, -EdgeVector)) then
         begin
            Penumbra0HotFin := J;
         end;
      end; }



      AVec := ShadowHullStart;
      for I := 0 to JARenderLightFinCount-1 do
      begin
         JAVertexPoolClear(@AShadow^.ShadowPenumbra0Fins[I]);


         if (I <= Penumbra0HotFin) then
         JAVertexPoolVertexAdd(@AShadow^.ShadowPenumbra0Fins[I])^ := APolygon^.WorldVertexI[ShadowVertexStart] else
         JAVertexPoolVertexAdd(@AShadow^.ShadowPenumbra0Fins[I])^ := APolygon^.WorldVertexI[ShadowPenumbra0Index];

         if (I = Penumbra0HotFin) then
         begin
            JAVertexPoolVertexAdd(@AShadow^.ShadowPenumbra0Fins[I])^ := APolygon^.WorldVertexI[ShadowPenumbra0Index];
         end;

         {Vec1 := Vec2Rotate(StartPenumbra, -(Vec2Angle(StartUmbra, StartPenumbra)/3)*JRadToDeg*I);
         Vec1 += APolygon^.WorldVertexI[ShadowPenumbra0Index];
         }
         //Vec1 := Startumbra

         {Calc Fin Start Position}
         Vec1 := Vec2Lerp(
            Vec2(ShadowHullStart),
            Vec2(Penumbra0Start),
            (I+1) / (JARenderLightFinCount));

         JAVertexPoolVertexAdd(@AShadow^.ShadowPenumbra0Fins[I])^ := Vec2SInt16(Vec1);


         JAVertexPoolVertexAdd(@AShadow^.ShadowPenumbra0Fins[I])^ := Vec2SInt16(AVec);
         AVec := Vec1;
      end;


      AVec := ShadowHullEnd;
      for I := 0 to JARenderLightFinCount-1 do
      begin
         JAVertexPoolClear(@AShadow^.ShadowPenumbra1Fins[I]);


         if (I <= Penumbra1HotFin) then
         JAVertexPoolVertexAdd(@AShadow^.ShadowPenumbra1Fins[I])^ := APolygon^.WorldVertexI[ShadowVertexEnd] else
         JAVertexPoolVertexAdd(@AShadow^.ShadowPenumbra1Fins[I])^ := APolygon^.WorldVertexI[ShadowPenumbra1Index];

         if (I = Penumbra1HotFin) then
         begin
            JAVertexPoolVertexAdd(@AShadow^.ShadowPenumbra1Fins[I])^ := APolygon^.WorldVertexI[ShadowPenumbra1Index];
         end;

         {Vec1 := Vec2Rotate(StartPenumbra, -(Vec2Angle(StartUmbra, StartPenumbra)/3)*JRadToDeg*I);
         Vec1 += APolygon^.WorldVertexI[ShadowPenumbra0Index];
         }
         //Vec1 := Startumbra

         {Calc Fin Start Position}
         Vec1 := Vec2Lerp(
            Vec2(ShadowHullEnd),
            Vec2(Penumbra1Start),
            (I+1) / (JARenderLightFinCount));

         JAVertexPoolVertexAdd(@AShadow^.ShadowPenumbra1Fins[I])^ := Vec2SInt16(Vec1);


         JAVertexPoolVertexAdd(@AShadow^.ShadowPenumbra1Fins[I])^ := Vec2SInt16(AVec);
         AVec := Vec1;
      end;



      {If Penumbra0 casts along an edge}
      {if not (ShadowPenumbra0Index<>ShadowVertexStart) then
      begin
         {which band cast from the root would overlap the edge}
         {all bands until this, cast from the root}

         {this band gets snapped to edge, first half}

         {remainder of this band is cast from next edge}

         {remainder of bands cast from next edge}

         {is it a garuntee that there is only one band with a special case?}
      end else
      begin
      }


     {
      {Add Penumbra 0 Root Vertex}
      JAPolygonShadowPenumbra0VertexAdd(APolygon)^ := APolygon^.WorldVertexI[ShadowPenumbra0Index];
      {Add Penumbra Projected Start Vertex}
      JAPolygonShadowPenumbra0VertexAdd(APolygon)^ := Penumbra0Start;

      {Query Side Spanning}
      if JRectSideClipping(ShadowHullStartSide, Penumbra0StartSide, JRect(ClipRect), A, B, VecCount) then
      begin
         JAPolygonShadowPenumbra0VertexAdd(APolygon)^ := Vec2SInt16(A);
         if VecCount=2 then
         JAPolygonShadowPenumbra0VertexAdd(APolygon)^ := Vec2SInt16(B);
      end;
      {Add Penumbra 0 End Vertex}
      JAPolygonShadowPenumbra0VertexAdd(APolygon)^ := ShadowHullStart;

      {If the Umbra was shifted back, add the Shadow Start point}
      if (ShadowPenumbra0Index<>ShadowVertexStart) then
      JAPolygonShadowPenumbra0VertexAdd(APolygon)^ := APolygon^.WorldVertexI[ShadowVertexStart];

      {
      {If Penumbra1 casts along an edge}
      if (ShadowPenumbra1Index<>ShadowVertexEnd) then
      begin

      end;
      }
      {Add Penumbra 1 Root Vertex}
      JAPolygonShadowPenumbra1VertexAdd(APolygon)^ := APolygon^.WorldVertexI[ShadowPenumbra1Index];

      {If the Umbra was shifted back, add the Shadow End Point}
      if (ShadowPenumbra1Index<>ShadowVertexEnd) then
      JAPolygonShadowPenumbra1VertexAdd(APolygon)^ := APolygon^.WorldVertexI[ShadowVertexEnd];

      {Add Penumbra 1 End Vertex}
      JAPolygonShadowPenumbra1VertexAdd(APolygon)^ := ShadowHullEnd;
      {Query Side Spanning}
      if JRectSideClipping(ShadowHullEndSide, Penumbra1StartSide, JRect(ClipRect), A, B, VecCount) then
      begin
         JAPolygonShadowPenumbra1VertexAdd(APolygon)^ := Vec2SInt16(A);
         if VecCount=2 then
         JAPolygonShadowPenumbra1VertexAdd(APolygon)^ := Vec2SInt16(B);
      end;
      {Add Penumbra 1 Projected Start Vertex}
      JAPolygonShadowPenumbra1VertexAdd(APolygon)^ := Penumbra1Start;

      }
   end;
end;

end.

