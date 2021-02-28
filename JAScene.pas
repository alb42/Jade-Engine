unit JAScene;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   {amiga} exec, agraphics,

   JATypes, JAMath, JAList, JALog, JARender, JAPalette,
   JACell, JASpatial, JANode;

type
   TJAScene = record
      Name : string;
      Nodes : PJAList; {LinkedList of all Nodes}
      Toys : PJAList; {LinkedList of all Toys}
      Lights : PJAList; {LinkedList of all Lights}
      RootNode : PJANode; {Root Node of SceneGraph}
      RootCell : PJACell; {Root Cell of QuadTree}
      
      Camera : PJANode; {The active camera for this scene}

      {viewport dimensions}
      ViewWidth : SInt16;
      ViewWidthDiv2 : SInt16;
      ViewHeight : SInt16;
      ViewHeightDiv2 : SInt32;
      ViewVecDiv2 : TVec2;

      MousePosition : TVec2; {The camera-scene-space mouse position}

      SceneLink : TJASceneLink;

   end;
   PJAScene = ^TJAScene;

function JASceneCreate(AName : string; AViewWidth, AViewHeight : SInt16) : PJAScene;
function JASceneDestroy(AScene : PJAScene) : boolean;

function JASceneUpdate(AScene : PJAScene; ADelta : Float32) : Float32;
function JASceneRender(AScene : PJAScene) : Float32;

{Render a given stage/pass of all nodes except lights}
function JASceneRenderPass(AScene : PJAScene; ARenderPass : SInt16) : Float32;

{Render a given stage/pass of all lights}
function JASceneRenderLightPass(AScene : PJAScene; ARenderPass : SInt16) : Float32;
{Render All Shadows for a Given Light}
function JASceneRenderShadowPass(AScene : PJAScene; ALight : PJANode) : FLoat32;

function JASceneRenderGrid(AScene : PJAScene) : Float32;
function JASceneRenderCameraPosition(AScene : PJAScene) : Float32;

function JAScenePointToCoord(AScene : PJAScene; APoint : TVec2SInt32) : TVec2;
function JASceneCoordToPoint(AScene : PJAScene; ACoord : TVec2) : TVec2SInt32;

procedure JASceneOnNodeCreate(AScene : pointer; ANode : PJANode);
procedure JASceneOnNodeDestroy(AScene : pointer; ANode : PJANode);


implementation

function JASceneCreate(AName : string; AViewWidth, AViewHeight : SInt16) : PJAScene;
begin
   Log('JASceneCreate','Creating Scene');
   Result := PJAScene(JAMemGet(SizeOf(TJAScene)));

   JANodeRoot := nil;
   JANodeCamera := nil;
   JANodeLight0 := nil;

   with Result^ do
   begin
      Name := AName;

      {Store viewport dimensions}
      ViewWidth := AViewWidth;
      ViewWidthDiv2 := AViewWidth div 2;
      ViewHeight := AViewHeight;
      ViewHeightDiv2 := AViewHeight Div 2;
      ViewVecDiv2 := Vec2(ViewWidthDiv2, ViewHeightDiv2);

      {Setup Node List}
      Nodes := JAListCreate();
      {Setup Toy List}
      Toys := JAListCreate();
      {Setup Light List}
      Lights := JAListCreate();
      JANodeLights := Lights; {Store Global Reference}

      SceneLink.Scene := Result;
      SceneLink.OnNodeCreate := @JASceneOnNodeCreate;
      SceneLink.OnNodeDestroy := @JASceneOnNodeDestroy;

      {Setup Root Cell}
      RootCell := JACellCreate();

      {Setup Camera}
      {NOTE : This Camera 'Node' is not created in the SceneGraph}
      Camera := JANodeCreate(JANode_Camera, @Result^.SceneLink);

      {Set the Render ViewMatrix to the Camera Matrix}
      {$IFDEF JA_SCENE_MAT3}
      JARenderViewMatrix := Camera^.Spatial.WorldMatrix;
      {$ENDIF}

      MousePosition := Vec2Zero;

      JANodeRoot := RootNode;
      JANodeCamera := Camera;

      {Setup Root Node}
      RootNode := JANodeCreate(JANode_Root, @Result^.SceneLink);

      //JASceneGenerateBackgroundStars(Result);
   end;
end;

function JASceneDestroy(AScene : PJAScene) : boolean;
begin
   Log('JASceneDestroy','Destroying Scene');
   with AScene^ do
   begin
      SetLength(Name, 0);

      JANodeDestroy(RootNode);

      JAListDestroy(Lights);
      JANodeLights := nil;

      JANodeDestroy(Camera);

      JACellDestroy(RootCell);

      JAListDestroy(Toys);
      JAListDestroy(Nodes);
   end;
   JAMemFree(AScene,SizeOf(TJAScene));
   Result := true;
end;

function JASceneUpdate(AScene : PJAScene; ADelta : Float32) : Float32;
begin
   {$IFDEF JA_SCENE_MAT3}
   {Set the Render ViewMatrix to the Camera (View) Matrix and offset by window middle (projection) matrix}
   JARenderViewMatrix := Mat3Translation(AScene^.ViewVecDiv2) * AScene^.Camera^.Spatial.WorldMatrixInverse;
	JARenderModelMatrix := Mat3Identity;
	JARenderMVP := JARenderViewMatrix;// * JARenderModelMatrix; {we know it's an identity matrix here}
   {$ENDIF}

   Result += JANodeUpdateRecurse(AScene^.RootNode, ADelta);
   Result := 0.0;
end;

function JASceneRender(AScene : PJAScene) : Float32;
var
   I : SInt16;
begin
 	Result := 0.0;

   //Result += JASceneRenderBackgroundStars(AScene);
   Result += JASceneRenderGrid(AScene);

   {Draw SceneSpace Mouse Position}
   //JARenderLine(AScene^.Camera^.Spatial.WorldPosition, AScene^.MousePosition);

   {SetDrMd(JARenderRasterPort, JAM1);
   SetWriteMask(JARenderRasterPort, %11000); {Disable Planes 1-5}
   SetAPen(JARenderRasterPort, 24); {Clear the Extra-Half-Brite bit}
   //SetAPen(JARenderRasterPort, 32); {Set the Extra-Half-Brite bit}
   RectFill(JARenderRasterPort, JARenderClipRect.Left, JARenderClipRect.Top, JARenderClipRect.Right, JARenderClipRect.Bottom);
   SetWrMsk(JARenderRasterPort, %00000111); { Enable Planes 1-5}
   //SetAPen(JARenderRasterPort, 1); //Restore Black Pen}


   {$IFDEF JA_ENABLE_SHADOW}
   {Render Lights}
   for I := 0 to JARenderPassCount-1 do
   begin
      JASceneRenderLightPass(AScene, I);
   end;
   {$ENDIF}

   {Render Scene Nodes}
   Result += JANodeRenderRecurse(AScene^.RootNode);

   {Render Camera Position}
   JASceneRenderCameraPosition(AScene);
end;

function JASceneRenderPass(AScene: PJAScene; ARenderPass: SInt16): Float32;
begin
   {Render Lights}
   JASceneRenderLightPass(AScene, ARenderPass);
end;

function JASceneRenderLightPass(AScene: PJAScene; ARenderPass: SInt16): Float32;
var
   I : SInt16;
   ItemLight : PJAListItem;
begin
   {Render Lights}
   Result := 0;
   ItemLight := AScene^.Lights^.Head^.Next;
   while (ItemLight<>AScene^.Lights^.Tail) do
   begin
      {Render Light Cones in Multiple passes to allow penumbra regions to blend better}
      Result += JANodeRenderPass(PJANode(ItemLight^.Data), ARenderPass);
      {Render All Shadows for this Light}

      ItemLight := ItemLight^.Next;
   end;
end;

function JASceneRenderShadowPass(AScene: PJAScene; ALight: PJANode): FLoat32;
begin

end;

function JASceneRenderGrid(AScene : PJAScene) : Float32;
var
   GridRect : TJRectSInt32;
   DivisionMajor : SInt32;
   DivisionMinor : SInt32;
   GridPos : TVec2SInt32;
begin
   Result := 0;
   JARenderModelMatrix := Mat3Identity;

   GridRect := JRectSInt32(-400,-400,400,400);
   DivisionMajor := 400;
   DivisionMinor := 200;

   {Minor Divisions}
   SetAPen(JARenderRasterPort, Palette^.PenGreen);

   GridPos.X := GridRect.Left;
   while GridPos.X <= GridRect.Right do
   begin
      if (GridPos.X+400) mod DivisionMajor <> 0 then
      JARenderLine(Vec2(GridPos.X,GridRect.Top), Vec2(GridPos.X,GridRect.Bottom));
      GridPos.X += DivisionMinor;
   end;
   GridPos.Y := GridRect.Top;
   while GridPos.Y <= GridRect.Bottom do
   begin
      if (GridPos.Y+400) mod DivisionMajor <> 0 then
      JARenderLine(Vec2(GridRect.Left,GridPos.Y), Vec2(GridRect.Right,GridPos.Y));
      GridPos.Y += DivisionMinor;
   end;

   SetAPen(JARenderRasterPort, Palette^.PenWhite);
   {Major Divisions}
   GridPos.X := GridRect.Left;
   while GridPos.X <= GridRect.Right do
   begin
      JARenderLine(Vec2(GridPos.X,GridRect.Top), Vec2(GridPos.X,GridRect.Bottom));
      GridPos.X += DivisionMajor;
   end;
   GridPos.Y := GridRect.Top;
   while GridPos.Y <= GridRect.Bottom do
   begin
      JARenderLine(Vec2(GridRect.Left,GridPos.Y), Vec2(GridRect.Right,GridPos.Y));
      GridPos.Y += DivisionMajor;
   end;
end;

function JASceneRenderCameraPosition(AScene : PJAScene) : Float32;
begin
   {$IFDEF JA_SCENE_MAT3}
   JARenderModelMatrix := AScene^.Camera^.Spatial.WorldMatrix;
   JARenderMVP := JARenderViewMatrix * JARenderModelMatrix;
   {$ENDIF}
   JARenderLine(Vec2(-5,0), Vec2(5,0));
   JARenderLine(Vec2(0,-5), Vec2(0,5));
   Result := 0;
end;

function JAScenePointToCoord(AScene : PJAScene; APoint : TVec2SInt32) : TVec2;
begin
   {$IFDEF JA_SCENE_MAT3}
   Result := Vec2DotMat3Affine(vec2(APoint.X,APoint.Y) - AScene^.ViewVecDiv2, AScene^.Camera^.Spatial.WorldMatrix);
   {$ENDIF}
end;

function JASceneCoordToPoint(AScene : PJAScene; ACoord : TVec2) : TVec2SInt32;
var
   Vec : TVec2;
begin
   {$IFDEF JA_SCENE_MAT3}
   Vec := Vec2DotMat3Affine(ACoord, AScene^.Camera^.Spatial.WorldMatrixInverse) + AScene^.ViewVecDiv2;
   {$ENDIF}
   Result := Vec2SInt32(round(Vec.X),round(Vec.Y));
end;

procedure JASceneOnNodeCreate(AScene: pointer; ANode: PJANode);
var
   ListItem : PJAListItem;
begin
   Log('JASceneOnNodeCreate','Create [%s]',[JANodeRootPath(ANode)]);

   case ANode^.NodeType of
      JANode_Light :
      begin
         ListItem := JAListItemCreate();
         ListItem^.Data := ANode;
         JAListPushTail(PJAScene(AScene)^.Lights, ListItem);
      end;
   end;
end;

procedure JASceneOnNodeDestroy(AScene: pointer; ANode: PJANode);
begin
   Log('JASceneOnNodeDestroy','Destroy [%s]',[JANodeRootPath(ANode)]);
end;

end.
