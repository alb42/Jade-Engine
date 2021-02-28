program JA;
{$mode objfpc}{$H+}
{$PACKRECORDS 2} { 2=WORD required for alignment compatibility with plain 68000}
{$i JA.inc}

uses
   {FPC}
   SysUtils,

   {Amiga}
	Exec, timer, Intuition, AGraphics, GadTools, Utility,

   {JA}
   JATypes, JAMath, JAList, JATimer, JALog, JASysInfo,
   JAGlobal, JAScreen, JAWindow, JAPalette, JABitmap, JARender,

   JAPolygon, JAPolygonTools, JASketch, JASketchTools,

   JAEngine, JAScene, JASpatial, JANode,
   JAShadow, JACell,

   JAToy,
   JAToyTank, JAToyFish, JAToyStarSystem, JAGalaxy;

var
   {engine instance}
   Engine : PJAEngine;
   EngineProperties : TJAEngineProperties; {Only for startup. Use Engine^.Properties for managed values}

   {local references}
   Scene : PJAScene;

   {Toys}
   StarSystem : PJAToyStarSystem;
   Galaxy : PJAGalaxy;
   Tank : PJAToyTank;

   Floor : PJANode;
   Caster0 : PJANode;
   Caster1 : PJANode;
   Caster2 : PJANode;
   Caster3 : PJANode;

   ResCurrent,ResLow,ResMedium,ResHigh : TVec2SInt16;


function DoCreate(AEngine : PJAEngine) : Float32; {Called after internal Create. Return processing time in MS}
var
   Polygon : PJAPolygon;
   Vec : TVec2;
begin
   Log('OnCreate','Engine Create Callback');

   {Floor := JANodeNodeCreate(AEngine^.Scene^.RootNode, JANode_Sketch);
   Polygon := JASketchPolygonCreate(PJANodeDataSketch(Floor^.Data)^.Sketch);
   Floor^.Spatial.LocalBRadius := 400;
   JAPolygonMakeRect(Polygon,JRect(-400,-400,400,400));
   Polygon^.Style.PenIndex := AEngine^.Palette^.PenYellow;}

   {
   {Setup Light}
   JANodeLight0 := JANodeNodeCreate(AEngine^.Scene^.RootNode, JANode_Light);
   JANodeSetLocalPosition(JANodeLight0, vec2(160,-300));
   {Set Light Colour}
   PJANodeDataLight(JANodeLight0^.Data)^.PaletteLightIndex := 0;
   PJANodeDataLight(JANodeLight0^.Data)^.Radius := 20;
   PJANodeDataLight(JANodeLight0^.Data)^.ConeAngle := 120;


   JANodeLight1 := JANodeNodeCreate(AEngine^.Scene^.RootNode, JANode_Light);
   JANodeSetLocalPosition(JANodeLight1, vec2(-160,-300));
   {Set Light Colour}
   PJANodeDataLight(JANodeLight1^.Data)^.PaletteLightIndex := 1;
   PJANodeDataLight(JANodeLight1^.Data)^.Radius := 20;
  }
   {Caster0 := JANodeNodeCreate(AEngine^.Scene^.RootNode, JANode_Sketch);
   Polygon := JASketchPolygonCreate(PJANodeDataSketch(Caster0^.Data)^.Sketch);
   JAPolygonMakeCircle(Polygon,vec2(0,0),50,13);
   Polygon^.Style.PenIndex := AEngine^.Palette^.PenRed;
   Polygon^.ShadowCast := false;
   JANodeSetLocalPosition(Caster0,Vec2(0,100));
   }

   {Setup Shadow Casters}
   {Caster0 := JANodeNodeCreate(AEngine^.Scene^.RootNode, JANode_Sketch);
   Polygon := JASketchPolygonCreate(PJANodeDataSketch(Caster0^.Data)^.Sketch);
   JAPolygonMakeCircle(Polygon,vec2(0,0),30,4);
   Polygon^.Style.PenIndex := AEngine^.Palette^.PenRed;
   Polygon^.ShadowCast := true;

   JANodeSetLocalPosition(Caster0,Vec2(-100,-100));


   Caster1 := JANodeNodeCreate(AEngine^.Scene^.RootNode, JANode_Sketch);
   Polygon := JASketchPolygonCreate(PJANodeDataSketch(Caster1^.Data)^.Sketch);
   JAPolygonMakeCircle(Polygon,vec2(0,0),30,3);
   Polygon^.Style.PenIndex := AEngine^.Palette^.PenGreen;
   Polygon^.ShadowCast := true;

   JANodeSetLocalPosition(Caster1,Vec2(-100,100));

   Caster2 := JANodeNodeCreate(AEngine^.Scene^.RootNode, JANode_Sketch);
   Polygon := JASketchPolygonCreate(PJANodeDataSketch(Caster2^.Data)^.Sketch);
   //JAPolygonMakeCircle(Polygon,vec2(0,0),30,7);
   JAPolygonMakeRect(Polygon,JRect(-35,-10,35,10));
   Polygon^.Style.PenIndex := AEngine^.Palette^.PenBlue;
   Polygon^.ShadowCast := true;

   JANodeSetLocalPosition(Caster2,Vec2(100,100));


   Caster3 := JANodeNodeCreate(AEngine^.Scene^.RootNode, JANode_Sketch);
   Polygon := JASketchPolygonCreate(PJANodeDataSketch(Caster3^.Data)^.Sketch);
   //   JAPolygonMakeCircle(Polygon,vec2(0,0),30,7);
   JAPolygonMakeRect(Polygon,JRect(-35,-10,35,10));
   Polygon^.Style.PenIndex := AEngine^.Palette^.PenWhite;
   Polygon^.ShadowCast := true;

   JANodeSetLocalPosition(Caster3,Vec2(100,-100));
   }

   StarSystem := JAToyStarSystemCreate(AEngine^.Scene,AEngine^.Scene^.RootNode);

   //Tank := JAToyTankCreate(AEngine^.Scene,AEngine^.Scene^.RootNode);
   //Galaxy := JAGalaxyCreate(AEngine);

   {Setup the camera}
   JANodeSetLocalPosition(AEngine^.Scene^.Camera,Vec2(0,0));
   JANodeSetLocalScale(AEngine^.Scene^.Camera, 8);
	JANodeSetLocalRotation(AEngine^.Scene^.Camera, 0);

   Result := 0.0;
end;
function DoDestroy(AEngine : PJAEngine) : Float32; {Called before internal Destroy. Return processing time in MS}
var
   I : SInt32;
begin
   Log('OnDestroy','Engine Destroy Callback');

   JAToyStarSystemDestroy(StarSystem);
   //JAGalaxyDestroy(Galaxy);

   Result := 0.0;
end;

function DoUpdate(ADelta : Float32) : Float32; {Called after internal update. Return processing time in MS}
var
   I : SInt32;
   Node,NodePrevious : PJANode;
   TransformVec : TVec2;
begin
   Result := 0.0;

   //NodePrevious := Engine^.Scene^.RootNode;

   JAToyStarSystemUpdate(StarSystem, ADelta);

   {Track the Second Planet With the Camera}
   //TransformVec := Vec2DotMat3Affine(Vec2Zero, StarSystem^.Bodies[2]^.Spatial.WorldMatrix);
   //JANodeSetLocalPosition(Engine^.Scene^.Camera, TransformVec);

   {Rotate Camera}
   //JANodeSetLocalRotation(Engine^.Scene^.Camera, Engine^.Scene^.Camera^.Spatial.LocalRotation - 22*ADelta);
   //JANodeSetLocalRotation(Caster0, Caster0^.Spatial.LocalRotation + (30*ADelta));
   //JANodeSetLocalRotation(Caster1, Caster0^.Spatial.LocalRotation + (40*ADelta));
   //JANodeSetLocalRotation(Caster2, Caster0^.Spatial.LocalRotation + (50*ADelta));
   //JANodeSetLocalRotation(Caster3, Caster0^.Spatial.LocalRotation + (60*ADelta));


   //JANodeSetLocalPosition(JANodeLight0, Engine^.Scene^.MousePosition);
end;

function DoRender() : Float32; {Called after internal render. Return processing time in MS}
var
   I : SInt16;
   Ai,Bi : TVec2;
begin
   Result := 0.0;

   //JARenderLightFan(Vec2(0,0),90,180, 1000);

   //Result += JAGalaxyRender(Galaxy);

   //JARenderViewMatrix :=  Mat3Translation(Scene^.ViewVecDiv2) * Scene^.Camera^.Spatial.WorldMatrixInverse;
   //JARenderModelMatrix := Mat3Identity;
   //JARenderMVP := JARenderViewMatrix;// * JARenderModelMatrix; {we know it's an identity matrix here}


   //WaitBlit();
   //uint32 result = IGraphics->SetWriteMask(&rastPort, $FB); // disable bitplane 2

   {
   SetWriteMask(JARenderRasterPort, $E0); // Disable planes 1 through 5.
   //SetAPen(JARenderRasterPort, 0); // Clear the Extra-Half-Brite bit
   //RectFill(JARenderRasterPort, JARenderClipRect.Left, JARenderClipRect.Top, JARenderClipRect.Right, JARenderClipRect.Bottom);
   SetAPen(JARenderRasterPort, 32); // Set the Extra-Half-Brite bit
   RectFill(JARenderRasterPort, JARenderClipRect.Left+70, JARenderClipRect.Top+40, JARenderClipRect.Right-70, JARenderClipRect.Bottom-40);
   SetWrMsk(JARenderRasterPort, -1); // Re-enable all planes.
   }

   //WaitBlit();

   {Render HyperLanes}
   {for I := 0 to Galaxy^.HyperLanesCount-1 do
   begin
      Ai.X := round(JARenderMVP._00*Galaxy^.HyperLanes[I].SystemA^.Spatial^.LocalPosition.X + JARenderMVP._01*Galaxy^.HyperLanes[I].SystemA^.Spatial^.LocalPosition.Y + JARenderMVP._02);
      Ai.Y := round(JARenderMVP._10*Galaxy^.HyperLanes[I].SystemA^.Spatial^.LocalPosition.X + JARenderMVP._11*Galaxy^.HyperLanes[I].SystemA^.Spatial^.LocalPosition.Y + JARenderMVP._12);
      Bi.X := round(JARenderMVP._00*Galaxy^.HyperLanes[I].SystemB^.Spatial^.LocalPosition.X + JARenderMVP._01*Galaxy^.HyperLanes[I].SystemB^.Spatial^.LocalPosition.Y + JARenderMVP._02);
      Bi.Y := round(JARenderMVP._10*Galaxy^.HyperLanes[I].SystemB^.Spatial^.LocalPosition.X + JARenderMVP._11*Galaxy^.HyperLanes[I].SystemB^.Spatial^.LocalPosition.Y + JARenderMVP._12);

      {compiler should resolve IF early for the cheaper first arguments}
      if JRectIntersectVertex(Ai, JARenderClipRect) or
         JRectIntersectVertex(Bi, JARenderClipRect) or
         JRectIntersectLine(Ai, Bi, JaRenderClipRect) then
      JARenderLine(Galaxy^.HyperLanes[I].SystemA^.Spatial^.LocalPosition, Galaxy^.HyperLanes[I].SystemB^.Spatial^.LocalPosition);
   end;
   }

   {Render Test Sketch}
   //SetDrMd(@Engine^.RenderBuffer^.PenGreen^.RasterPort, JAM2);
   //JARenderSketch(@Engine^.RenderBuffer^.PenGreen^.RasterPort, TestSketch);
end;

{Use Stipple Mask to draw umbra regions into shadow plane}

{TODO : the size of tmpras is for area filling polygons in an external buffer!!!
So the REASON shadows were fucking shit up - isn't because the projections
were creating infinities - it's because they were creating a filled polygon
larger than the tmpras - which is just an offscreen buffer used, because
the flood fill of the amiga, relies on a 'clean slate' to operate correctly,
if it tried to do a filled poly into a populated buffer? the fill operation would bleed through}

{TODO : take screen rect / poly intersections into account, use them as end points for the boundry
during shadow hull generation - or otherwise come up with a better solution - generate
short fixed shadow lengths for edge intersecting objects?
would not allow for light casters to be off screen}

{Draw light lines across front facing polys, use dot product to calculate the light level}

begin
   Randomize();

   EngineProperties := JAEnginePropertiesDefault;

   With EngineProperties do
   begin
      {Engine Modules}
      Modules := [
         //JAEngineModule_Screen, {Enable Custom Screen}
         JAEngineModule_Window, {Enable Window}
         JAEngineModule_Scene, {Enable Scenegraph}
         JAEngineModule_Audio {Enable Audio}
         ];

      {Screen Properties}
      ScreenProperties := JAScreenPropertiesDefault;
      ScreenProperties.Title := 'JAScreen v1.0';
      ScreenProperties.API := JAGraphicsAPI_Auto;

      {Window Properties}
      WindowProperties := JAWindowPropertiesDefault;
      WindowProperties.Title := 'JAWindow v1.0';
      WindowProperties.API := JAGraphicsAPI_Auto;

      {Remove Border if We're FullScreen}
      if (JAEngineModule_Screen in Modules) then
         WindowProperties.Border := false;

      {Default Resolutions}
      if ((pGfxBase(GfxBase)^.DisplayFlags and PAL) <> 0) then
         ResLow := Vec2SInt16(320,256) {PAL} else
      if ((pGfxBase(GfxBase)^.DisplayFlags and NTSC) <> 0) then
         ResLow := Vec2SInt16(320,200) {NTSC} else
         ResLow := Vec2SInt16(320,200);
      ResMedium := Vec2SInt16(640,480);
      ResHigh := Vec2SInt16(1024,768);

      ResCurrent := ResMedium;

      {Debug - Quick Switching Between Profiles}
      if (1=0) then
      begin
         ScreenProperties.API := JAGraphicsAPI_Picasso;
         ScreenProperties.Depth := 8; {2^8 = 256 Colours}
         WindowProperties.API := JAGraphicsAPI_Intuition;
         ResCurrent := ResMedium;
      end else
      begin
         ScreenProperties.API := JAGraphicsAPI_Intuition;
         ScreenProperties.Depth := 5; {2^5 = 32 Colours}
         WindowProperties.API := JAGraphicsAPI_Intuition;
         ResCurrent := ResLow;
      end;

      ScreenProperties.Width := ResCurrent.X;
      ScreenProperties.Height := ResCurrent.Y;
      WindowProperties.Width := ResCurrent.X;
      WindowProperties.Height := ResCurrent.Y;

      {Engine Callbacks}
      OnCreate := @DoCreate;
      OnDestroy := @DoDestroy;
      OnUpdate := @DoUpdate;
      OnRender := @DoRender;
   end;

   {TODO : These should be passed in EngineProperties}
   {Resides in JARender}
   JARenderPassCount := 4;
   {Resides in JAGlobal}
   JARenderLightLevelCount := 3;
   JARenderLightFinCount := 3;
   JARenderLightDither := true;
   JAShadowsPerPolygon := 2;

   {Create Engine}
   Engine := JAEngineCreate(@EngineProperties);

   if (Engine<>nil) then
   begin
      {store Local reference}
      Scene := Engine^.Scene;
   
      {pass execution to engine}
      JAEngineExecute(Engine);

      {destroy engine}
      JAEngineDestroy(Engine);
   end;
end.
