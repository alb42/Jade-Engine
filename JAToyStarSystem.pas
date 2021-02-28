unit JAToyStarSystem;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   {amiga} exec, agraphics,
   JATypes, JAMath, JAPalette, JARender, JASpatial, JANode, JAScene,
   JASketch, JAPolygon, JAPolygonTools,
   JAToy;

type
   TJAToyStarSystem = record
      Scene : PJAScene;
      Bodies : array[0..4] of PJANode;
   end;
   PJAToyStarSystem = ^TJAToyStarSystem;

function JAToyStarSystemCreate(AScene : PJAScene; AParentNode : PJANode) : PJAToyStarSystem;
function JAToyStarSystemDestroy(AToyStarSystem : PJAToyStarSystem) : boolean;
function JAToyStarSystemUpdate(AToyStarSystem : PJAToyStarSystem; ADelta : Float32) : Float32;

function JASceneGenerateBackgroundStars(AScene : PJAScene) : Float32;
function JASceneRenderBackgroundStars(AScene : PJAScene) : Float32;

implementation

function JAToyStarSystemCreate(AScene : PJAScene; AParentNode : PJANode) : PJAToyStarSystem;
var
   I : SInt16;
   Polygon : PJAPolygon;
   Node,NodePrevious : PJANode;
   BodyOrbit : Float32;
   BodyRadius : Float32;

begin
   Result := JAMemGet(SizeOf(TJAToyStarSystem));

   NodePrevious := AParentNode;
   BodyOrbit := 0;
   BodyRadius := 20;
   with Result^ do
   begin
      Scene := AScene;
      for I := 0 to high(Bodies) do
      begin
         Node := JANodeNodeCreate(NodePrevious, JANode_Sketch);

         if I=0 then BodyOrbit := 0 else
         if I=1 then BodyOrbit := 300 else
         if I=2 then BodyOrbit := 100 else
         BodyOrbit /= 2;
         if I=0 then BodyRadius := 50 else
         BodyRadius /= 2.0;
         BodyOrbit -= (BodyOrbit/15)*I;

         JANodeSetLocalPosition(Node, vec2(BodyOrbit,0));
         //Node^.Spatial.LocalVelocityRotation := 0;
         //JANodeSetLocalRotation(Node, 45);

         Bodies[I] := Node;
         NodePrevious := Node;
         Polygon := JASketchPolygonCreate(PJANodeDataSketch(Node^.Data)^.Sketch);
         JAPolygonMakeCircle(Polygon,vec2(0,0),BodyRadius, 8);
         Node^.Spatial.LocalBRadius := BodyRadius;

         {$IFDEF JA_ENABLE_SHADOW}
         Polygon^.ShadowCast := true;
         {$ENDIF}

         case I of
            0 : Polygon^.Style.PenIndex := Palette^.PenYellow;
            1 : Polygon^.Style.PenIndex := Palette^.PenGreen;
            2 : Polygon^.Style.PenIndex := Palette^.PenBlue;
            3 : Polygon^.Style.PenIndex := Palette^.PenRed;
            4 : Polygon^.Style.PenIndex := Palette^.PenGrey;
         end;

      end;

      Bodies[0]^.Spatial.LocalVelocityRotation := -1;
      JANodeSetLocalPosition(Bodies[0], Vec2(0, 0));
   end;
end;

function JAToyStarSystemDestroy(AToyStarSystem : PJAToyStarSystem) : boolean;
var
   I : SInt16;
begin
   with AToyStarSystem^ do
   begin
      //JANodeDestroy(Bodies[0]);
      //JANodeNodeDestroy(Scene^.RootNode, Bodies[0]);
   end;
   JAMemFree(AToyStarSystem,SizeOf(TJAToyStarSystem));
   Result := true;
end;

function JAToyStarSystemUpdate(AToyStarSystem : PJAToyStarSystem; ADelta : Float32) : Float32;
var
   I : SInt16;
begin
   Result := 0;

   with AToyStarSystem^ do
   begin
      for I := 0 to high(Bodies) do
      begin
         JANodeSetLocalRotation(Bodies[I], Bodies[I]^.Spatial.LocalRotation + (30*(I*I+1))*ADelta);
      end;
   end;
end;

function JASceneRenderBackgroundStars(AScene : PJAScene) : Float32;
var
   I : SInt32;
   Pixel : TVec2SInt16;
	StarHigh : SInt16;
begin

	{StarHigh := high(AScene^.BackgroundStars);

   for I := 0 to StarHigh do
   begin
      Pixel.X := round(JARenderMVP._00*AScene^.BackgroundStars[I].X + JARenderMVP._01*AScene^.BackgroundStars[I].Y  + JARenderMVP._02);
      Pixel.Y := round(JARenderMVP._10*AScene^.BackgroundStars[I].X + JARenderMVP._11*AScene^.BackgroundStars[I].Y  + JARenderMVP._12);

      {reject any offscreen pixels}
      //if (Pixel.X >= 0) and (Pixel.X <= 320) and (Pixel.Y >= 0) and (Pixel.Y <= 200) then
      WritePixel(JARenderRasterPort, Pixel.X, Pixel.Y);

      //JARenderPixel(Vec2(AScene^.BackgroundStars[I].X,AScene^.BackgroundStars[I].Y));
   end;
   }
   Result := 0;
end;

function JASceneGenerateBackgroundStars(AScene : PJAScene) : Float32;
var
   I : SInt32;
   Vec : TVec2;
begin
   {for I := 0 to high(AScene^.BackgroundStars) do
   begin
      Vec := Vec2Rotate((Vec2Up * Random) * 2000, Random * 360);
      AScene^.BackgroundStars[I].X := trunc(Vec.X);
      AScene^.BackgroundStars[I].Y := trunc(Vec.Y);
   end; }
   Result := 0;
end;


end.

