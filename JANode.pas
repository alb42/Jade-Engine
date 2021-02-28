unit JANode;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   {amiga} exec, agraphics,
   JATypes, JAGlobal, JAList, JAMath, JALog, JASpatial, JAPolygon, JASketch, JAShadow,
   JARender, JAPalette;

type
   {Node Types}

   TJANodeType = (
      JANode_Root=0,
      JANode_Sketch=1,
      JANode_Emitter=2,
      JANode_Light=3,
      JANode_Camera=4,
      JANode_Sound=5
      );

   TJANodeDataRoot = record
      StopHere : boolean;
   end;
   PJANodeDataRoot = ^TJANodeDataRoot;

   TJANodeDataSketch = record
      Sketch : PJASketch;
   end;
   PJANodeDataSketch = ^TJANodeDataSketch;

   TJANodeDataEmitter = record
      Colour : TJColour;
      Rate : Float32;
   end;
   PJANodeDataEmitter = ^TJANodeDataEmitter;

   TJANodeDataLight = record
      Radius : Float32; {Radius of the Light Source}
      ConeRadius : Float32; {Extent of the Light}
      ConeAngle : Float32; {Angle of the Light Cone}
      Colour : TJColour;
      PaletteLightIndex : UInt8; {Palette Light Index}
   end;
   PJANodeDataLight = ^TJANodeDataLight;

   TJANodeDataCamera = record
      Zoom : Float32;
   end;
   PJANodeDataCamera = ^TJANodeDataCamera;

   TJANodeDataSound = record
      SoundID : SInt32;
   end;
   PJANodeDataSound = ^TJANodeDataSound;

   PJANode = ^TJANode;
   PPJANode = ^PJANode;

   TJASceneLink = record
      Scene : pointer;
      OnNodeCreate : procedure(AScene : pointer; ANode : PJANode);
      OnNodeDestroy : procedure(AScene : pointer; ANode : PJANode);
   end;
   PJASceneLink = ^TJASceneLink;

   TJANode = record
      NodeType : TJANodeType;
      Name : string;
      Data : pointer; {pointer to a type specific record}
      DataSize : UInt32; {size of the data record type}
      Spatial : TJASpatial; {position,worldmatrix etc}
      Parent : PJANode; {The parent node. Can be nil (root)}
      Nodes : PJAList; {Child nodes}
      ListItem : PJAListItem;
      SceneLink : PJASceneLink;
   end;


function JANodeCreate(ANodeType : TJANodeType; ASceneLink : PJASceneLink) : PJANode;
function JANodeDestroy(ANode : PJANode) : boolean;

function JANodeRootPath(ANode : PJANode) : string;

function JANodeNodeCreate(ANode : PJANode; ANodeType : TJANodeType) : PJANode;
function JANodeNodeDestroy(ANode : PJANode; ANodeChild : PJANode) : boolean;

procedure JANodeSetLocalPosition(ANode : PJANode; APosition : TVec2);
procedure JANodeSetLocalRotation(ANode : PJANode; ARotation : Float32);
procedure JANodeSetLocalScale(ANode : PJANode; AScale : Float32);

{update node - dirty aware. Return execution time in MS}
function JANodeUpdateRecurse(ANode : PJANode; ADelta : Float32) : Float32;
{render node and its children. Return execution time in MS}
function JANodeRenderRecurse(ANode : PJANode) : Float32;
{render a pass of a given node. Return execution time in MS}
function JANodeRenderPass(ANode : PJANode; ARenderPass : SInt16) : Float32;

function JANodeTypeToString(ANodeType : TJANodeType) : string;

procedure JANodeDataInitRoot(ANodeDataRoot : PJANodeDataRoot);
procedure JANodeDataInitSketch(ANodeDataSketch : PJANodeDataSketch);
procedure JANodeDataInitEmitter(ANodeDataEmitter : PJANodeDataEmitter);
procedure JANodeDataInitLight(ANodeDataLight : PJANodeDataLight);
procedure JANodeDataInitCamera(ANodeDataCamera : PJANodeDataCamera);
procedure JANodeDataInitSound(ANodeDataSound : PJANodeDataSound);

procedure JANodeWidgetLightRender(ALight : PJANode);
procedure JANodeWidgetSpatialRender(ANode : PJANode);

var
   {Global Node References}
   JANodeRoot : PJANode;
   JANodeCamera : PJANode;

   JANodeLights : PJAList;

   JANodeLight0 : PJANode;
   JANodeLight1 : PJANode;

implementation

function JANodeCreate(ANodeType: TJANodeType; ASceneLink: PJASceneLink): PJANode;
begin
   //Log('JANodeCreate','Creating ' + JANodeTypeToString(ANodeType) + ' Node');

   Result := JAMemGet(SizeOf(TJANode));

   Result^.NodeType := ANodeType;
   SetLength(Result^.Name, 0);
   Result^.Data := nil;
   Result^.DataSize := 0;
   Result^.Parent := nil;
   Result^.Spatial := JASpatialDefault;
   Result^.Nodes := JAListCreate();
   Result^.ListItem := nil;
   Result^.SceneLink := ASceneLink;


   case ANodeType of
      JANode_Root :
      begin
         Result^.Name := 'Root';
         Result^.DataSize := SizeOf(TJANodeDataRoot);
         Result^.Data := JAMemGet(Result^.DataSize);
         JANodeDataInitRoot(PJANodeDataRoot(Result^.Data));
      end;
      JANode_Sketch :
      begin
         Result^.Name := 'Sketch';
         Result^.DataSize := SizeOf(TJANodeDataSketch);
         Result^.Data := JAMemGet(Result^.DataSize);
         JANodeDataInitSketch(PJANodeDataSketch(Result^.Data));
         PJANodeDataSketch(Result^.Data)^.Sketch := JASketchCreate();
      end;
      JANode_Emitter :
      begin
         Result^.Name := 'Emitter';
         Result^.DataSize := SizeOf(TJANodeDataEmitter);
         Result^.Data := JAMemGet(Result^.DataSize);
         JANodeDataInitEmitter(PJANodeDataEmitter(Result^.Data));
      end;
      JANode_Light :
      begin
         Result^.Name := 'Light';
         Result^.DataSize := SizeOf(TJANodeDataLight);
         Result^.Data := JAMemGet(Result^.DataSize);
         JANodeDataInitLight(PJANodeDataLight(Result^.Data));
      end;
      JANode_Camera :
      begin
         Result^.Name := 'Camera';
         Result^.DataSize := SizeOf(TJANodeDataCamera);
         Result^.Data := JAMemGet(Result^.DataSize);
         JANodeDataInitCamera(PJANodeDataCamera(Result^.Data));
      end;
      JANode_Sound :
      begin
         Result^.Name := 'Sound';
         Result^.DataSize := SizeOf(TJANodeDataSound);
         Result^.Data := JAMemGet(Result^.DataSize);
         JANodeDataInitSound(PJANodeDataSound(Result^.Data));
      end;
   end;
end;

function JANodeDestroy(ANode : PJANode) : boolean;
var
   I : SInt32;
   ListItem : PJAListItem;
   BNode : PJANode;
begin
   {Recursively Destroy Children}
   ListItem := ANode^.Nodes^.Head^.Next;
   while (ListItem <> ANode^.Nodes^.Tail) do
   begin
      BNode := PJANode(ListItem^.Data); {get child}
      ListItem := ListItem^.Next; {get the next item}
      JANodeDestroy(BNode); {destroy child}
   end;

   ANode^.SceneLink^.OnNodeDestroy(ANode^.SceneLink^.Scene, ANode);
   
   //Log('JANodeDestroy','Destroying ' + JANodeRootPath(ANode));

   {Destroy the now 'empty' list}
   JAListDestroy(ANode^.Nodes);

   {Remove From Parent List}
   if (ANode^.Parent<>nil) then
   begin
      JAListExtract(ANode^.Parent^.Nodes, ANode^.ListItem); {extract the listitem}
      JAListItemDestroy(ANode^.ListItem); {destroy the extracted item}
   end;

   {Free Node Specifics}
   case ANode^.NodeType of
      JANode_Sketch :
      begin
         JASketchDestroy(PJANodeDataSketch(ANode^.Data)^.Sketch);
      end;
   end;

   {Free node type specific data}
   if (ANode^.Data<>nil) then JAMemFree(ANode^.Data, ANode^.DataSize);

   {Free strings}
   SetLength(ANode^.Name, 0);

   {Free node}
   JAMemFree(ANode,SizeOf(TJANode));

   Result := true;
end;

function JANodeRootPath(ANode : PJANode) : string;
var
   BNode : PJANode;
begin
   BNode := ANode;
   Result := BNode^.Name;
   BNode := BNode^.Parent;

   while BNode<>nil do
   begin
      Result := BNode^.Name + '.' + Result;
      BNode := BNode^.Parent;
   end;
end;

function JANodeNodeCreate(ANode : PJANode; ANodeType : TJANodeType) : PJANode;
begin
   //Log('JANodeNodeCreate','Creating ' + JANodeRootPath(ANode) + '->' + JANodeTypeToString(ANodeType));

   {Create the child node type}
   Result := JANodeCreate(ANodeType, ANode^.SceneLink);

   {Set parent of this child}
   Result^.Parent := ANode;
   Result^.Spatial.Parent := @ANode^.Spatial;

   {add to the parent node list}
   Result^.ListItem := JAListItemCreate();
   Result^.ListItem^.Data := Result;

   JAListPushTail(ANode^.Nodes, Result^.ListItem);

   Result^.SceneLink^.OnNodeCreate(Result^.SceneLink^.Scene, Result);
end;

function JANodeNodeDestroy(ANode : PJANode; ANodeChild : PJANode) : boolean;
begin
   //Log('JANodeNodeDestroy','Destroying ' + JANodeRootPath(ANode) + '->' + ANodeChild^.Name);

   {Extract and delete listitem}
   JAListExtract(ANode^.Nodes, ANodeChild^.ListItem);
   JAListItemDestroy(ANodeChild^.ListItem);
   ANodeChild^.ListItem := nil;

   {destroy node and any children}
   JANodeDestroy(ANodeChild);
end;

procedure JANodeSetLocalPosition(ANode : PJANode; APosition : TVec2);
begin
   JASpatialSetLocalPosition(@ANode^.Spatial, APosition);
end;

procedure JANodeSetLocalRotation(ANode : PJANode; ARotation : Float32);
begin
   JASpatialSetLocalRotation(@ANode^.Spatial, ARotation);
end;

procedure JANodeSetLocalScale(ANode : PJANode; AScale : Float32);
begin
   JASpatialSetLocalScale(@ANode^.Spatial, AScale);
end;

function JANodeUpdateRecurse(ANode : PJANode; ADelta : Float32) : Float32;
var
   CurrentItem : PJAListItem;

   I,J : SInt32;
   APoly : PJAPolygon;
   AVec : TVec2;
   AItem : PJAListItem;
   ALight : PJANode;
begin
   Result := 0.0;
   if ANode=nil then exit();
   with ANode^ do
   begin
      {Update Spatial}
      if Spatial.Dirty then JASpatialUpdate(@Spatial, ADelta);

      case NodeType of
         JANode_Sketch : {Calculate Sketch world vertices}
         begin
            for I := 0 to PJANodeDataSketch(ANode^.Data)^.Sketch^.PolygonCount-1 do
            begin
               APoly := @PJANodeDataSketch(ANode^.Data)^.Sketch^.Polygon[I];
               for J := 0 to APoly^.VertexCount-1 do
               begin

                  {$IFDEF JA_SCENE_MAT3}
                  {Calculate World Position}
                  APoly^.WorldVertex[J] := Vec2DotMat3Affine(APoly^.Vertex[J].Position, ANode^.Spatial.WorldMatrix);
                  {Calculate ScreenSpace Position}
                  AVec := Vec2DotMat3Affine(APoly^.WorldVertex[J], JARenderViewMatrix);
                  {$ENDIF}
                  APoly^.WorldVertexI[J] := Vec2SInt16(AVec);


               end;

               {$IFDEF JA_ENABLE_SHADOW}
               {Generate Polygon Shadows}
               if APoly^.ShadowCast and (JANodeLights^.Count > 0) then
               begin
                  AItem := JANodeLights^.Head^.Next; {Get First Light Item}
                  ALight := PJANode(AItem^.Data);
                  for J := 0 to JANodeLights^.Count-1 do
                  begin
                     JAPolygonShadowGenerate(
                        APoly,
                        J,
                        ANode^.Spatial.WorldPosition,
                        ALight^.Spatial.WorldPosition,
                        PJANodeDataLight(ALight^.Data)^.Radius,
                        JARenderViewMatrix, JARenderClipRect);
                     AItem := AItem^.Next;
                     ALight := PJANode(AItem^.Data);
                  end;
               end;
               {$ENDIF}
            end;
         end;
      end;


      {update children}
      CurrentItem := Nodes^.Head^.Next;
      while (CurrentItem<>Nodes^.Tail) do
      begin
         Result += JANodeUpdateRecurse(PJANode(CurrentItem^.Data), ADelta);
         CurrentItem := CurrentItem^.Next;
      end;
   end;
end;

function JANodeRenderRecurse(ANode : PJANode) : Float32;
var
   Ai : TVec2;
   CurrentItem : PJAListItem;
   NNodes : PJAList;
   DitherPattern : array[0..1] of UInt16;

   OuterConeRotation : Float32;
   OuterConeAngle : Float32;
begin
   case ANode^.NodeType of
      JANode_Root : ;
      JANode_Sketch :
      begin
         //JARenderModelMatrix := ANode^.Spatial.WorldMatrix;
         //JARenderMVP := JARenderViewMatrix * JARenderModelMatrix;

         //Ai.X := round(JARenderMVP._00*ANode^.Spatial.WorldPosition.X + JARenderMVP._01*ANode^.Spatial.WorldPosition.Y  + JARenderMVP._02);
         //Ai.Y := round(JARenderMVP._10*ANode^.Spatial.WorldPosition.X + JARenderMVP._11*ANode^.Spatial.WorldPosition.Y  + JARenderMVP._12);

         //if JRectIntersectCircle(Ai,ANode^.Spatial.WorldBRadius,JARenderClipRect) then
         JARenderSketch(PJANodeDataSketch(ANode^.Data)^.Sketch);

      end;
      JANode_Emitter :;
      JANode_Light :
      begin

         {$IFDEF JA_ENABLE_SHADOW}
         Ai := Vec2DotMat3Affine(ANode^.Spatial.WorldPosition, JARenderViewMatrix);
         if not JRectIntersectVertex(Ai,JARenderClipRect) then exit;

         DitherPattern[1] := %0101010101010101;
         DitherPattern[0] := %1010101010101010;

         {TODO : Lights need to be rendered in two passes so that maximum light
         cones can overwrite the penumbra regions of other lights}

         {Maximum Light Cone}
         if (PJANodeDataLight(ANode^.Data)^.PaletteLightIndex = 0) then
         begin
            SetWriteMask(JARenderRasterPort, %00111000);
            SetAPen(JARenderRasterPort, %00100000);
         end else
         begin
            SetWriteMask(JARenderRasterPort, %01011000);
            SetAPen(JARenderRasterPort, %01000000);
         end;


         //SetWriteMask(JARenderRasterPort, Palette^.Lights[PJANodeDataLight(ANode^.Data)^.PaletteLightIndex].Mask); {Enable Shadow Planes}
         //SetAPen(JARenderRasterPort, Palette^.Lights[PJANodeDataLight(ANode^.Data)^.PaletteLightIndex].Mask + 1{white});

          //if (PJANodeDataLight(ANode^.Data)^.PaletteLightIndex = 0) then
         JARenderConeClipped(ANode^.Spatial.WorldPosition, ANode^.Spatial.WorldRotation, PJANodeDataLight(ANode^.Data)^.ConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);

         // if (PJANodeDataLight(ANode^.Data)^.PaletteLightIndex = 0) then exit;

         {Light Penumbra Region}

         OuterConeAngle := 3;
         OuterConeRotation := ANode^.Spatial.WorldRotation - ((PJANodeDataLight(ANode^.Data)^.ConeAngle/2) - (OuterConeAngle));

         JARenderLightFan(ANode^.Spatial.WorldPosition, OuterConeRotation, OuterConeRotation+OuterConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);


         OuterConeAngle := 3;
         OuterConeRotation := ANode^.Spatial.WorldRotation + ((PJANodeDataLight(ANode^.Data)^.ConeAngle/2) - (OuterConeAngle*2));

         JARenderLightFan(ANode^.Spatial.WorldPosition, OuterConeRotation+OuterConeAngle, OuterConeRotation, PJANodeDataLight(ANode^.Data)^.ConeRadius);

         SetWrMsk(JARenderRasterPort, %11111111); { Enable Planes 1-5}
         SetAPen(JARenderRasterPort, 1); //Restore Black Pen
         SetAfPt(JARenderRasterPort, nil, 0);
         {$ENDIF}


         JANodeWidgetLightRender(ANode);
      end;
      JANode_Camera :;
      JANode_Sound :;
   end;

	NNodes := ANode^.Nodes;
	{render children}
   CurrentItem := NNodes^.Head^.Next;
   while (CurrentItem<>NNodes^.Tail) do
   begin
   	{Result += }JANodeRenderRecurse(PJANode(CurrentItem^.Data));
      CurrentItem := CurrentItem^.Next;
   end;
   
   Result := 0.0;
end;

function JANodeRenderPass(ANode: PJANode; ARenderPass: SInt16): Float32;
var
   V : TVec2;
   DitherPattern : array[0..1] of UInt16;

   OuterConeRotation : Float32;
   OuterConeAngle : Float32;

   CurrentBand : SInt16;

begin
   case ANode^.NodeType of
      JANode_Light :
      begin {Render the full-bright cone or individual fins, depending on ARenderPass}
         {If the Light source is off screen, don't render}
         {$IFDEF JA_SCENE_MAT3}
         V := Vec2DotMat3Affine(ANode^.Spatial.WorldPosition, JARenderViewMatrix);
         {$ENDIF}
         if not JRectIntersectVertex(V,JARenderClipRect) then exit;

         DitherPattern[1] := %0101010101010101;
         DitherPattern[0] := %1010101010101010;

         OuterConeAngle := 3;

         case ARenderPass of
            0 :
            begin
               if (PJANodeDataLight(ANode^.Data)^.PaletteLightIndex = 0) then
               begin
                  SetWriteMask(JARenderRasterPort, %00111000);
                  SetAPen(JARenderRasterPort, %00100000);
               end else
               begin
                  SetWriteMask(JARenderRasterPort, %01011000);
                  SetAPen(JARenderRasterPort, %01000000);
               end;


               {Maximum Light Cone}
               SetAfPt(JARenderRasterPort, nil, 0);
               JARenderConeClipped(ANode^.Spatial.WorldPosition, ANode^.Spatial.WorldRotation, PJANodeDataLight(ANode^.Data)^.ConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);
            end;

            3 :
            begin
              {
              if (PJANodeDataLight(ANode^.Data)^.PaletteLightIndex = 0) then
               begin
                  SetWriteMask(JARenderRasterPort, %00100000);
                  SetAPen(JARenderRasterPort, %00100000);
               end else
               begin
                  SetWriteMask(JARenderRasterPort, %01000000);
                  SetAPen(JARenderRasterPort, %01000000);
               end;

               {Maximum Light Cone}
               SetAfPt(JARenderRasterPort, nil, 0);
               JARenderConeClipped(ANode^.Spatial.WorldPosition, ANode^.Spatial.WorldRotation, PJANodeDataLight(ANode^.Data)^.ConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);
               }
            end;

            1 :
            begin

               CurrentBand := 2;
               if (PJANodeDataLight(ANode^.Data)^.PaletteLightIndex = 0) then
               begin
                  SetWriteMask(JARenderRasterPort, %00011000);
                  SetAPen(JARenderRasterPort, %00110000);
               end else
               begin
                  SetWriteMask(JARenderRasterPort, %00011000);
                  SetAPen(JARenderRasterPort, %01010000);
               end;

               OuterConeAngle := 3;

               //SetAfPt(JARenderRasterPort, @DitherPattern, 1); {Dither Enable}
               SetAfPt(JARenderRasterPort, nil, 0);  {Dither Disable}

               OuterConeRotation := ANode^.Spatial.WorldRotation - ((PJANodeDataLight(ANode^.Data)^.ConeAngle/2) - (OuterConeAngle/2));
               JARenderConeClipped(ANode^.Spatial.WorldPosition, OuterConeRotation, OuterConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);

               OuterConeRotation := ANode^.Spatial.WorldRotation + ((PJANodeDataLight(ANode^.Data)^.ConeAngle/2) - (OuterConeAngle/2));
               JARenderConeClipped(ANode^.Spatial.WorldPosition, OuterConeRotation, OuterConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);

            end;
            2 :
            begin
               CurrentBand := 1;
               if (PJANodeDataLight(ANode^.Data)^.PaletteLightIndex = 0) then
               begin
                  SetWriteMask(JARenderRasterPort, %00011000);
                  SetAPen(JARenderRasterPort, %00101000);
               end else
               begin
                  SetWriteMask(JARenderRasterPort, %00011000);
                  SetAPen(JARenderRasterPort, %01001000);
               end;

               OuterConeAngle := 3;

               //SetAfPt(JARenderRasterPort, @DitherPattern, 1); {Dither Enable}
               SetAfPt(JARenderRasterPort, nil, 0);  {Dither Disable}

               OuterConeRotation := ANode^.Spatial.WorldRotation - ((PJANodeDataLight(ANode^.Data)^.ConeAngle/2) - ((OuterConeAngle/2)*3));
               JARenderConeClipped(ANode^.Spatial.WorldPosition, OuterConeRotation, OuterConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);

               OuterConeRotation := ANode^.Spatial.WorldRotation + ((PJANodeDataLight(ANode^.Data)^.ConeAngle/2) - ((OuterConeAngle/2)*3));
               JARenderConeClipped(ANode^.Spatial.WorldPosition, OuterConeRotation, OuterConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);
            end;

         end;


         //SetWriteMask(JARenderRasterPort, Palette^.Lights[PJANodeDataLight(ANode^.Data)^.PaletteLightIndex].Mask); {Enable Shadow Planes}
         //SetAPen(JARenderRasterPort, Palette^.Lights[PJANodeDataLight(ANode^.Data)^.PaletteLightIndex].Mask + 1{white});

         //if (PJANodeDataLight(ANode^.Data)^.PaletteLightIndex = 0) then
         //JARenderConeClipped(ANode^.Spatial.WorldPosition, ANode^.Spatial.WorldRotation, PJANodeDataLight(ANode^.Data)^.ConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);

         // if (PJANodeDataLight(ANode^.Data)^.PaletteLightIndex = 0) then exit;

         {Light Penumbra Region}

         {OuterConeAngle := 3;
         OuterConeRotation := ANode^.Spatial.WorldRotation - ((PJANodeDataLight(ANode^.Data)^.ConeAngle/2) - (OuterConeAngle));

         JARenderLightFan(ANode^.Spatial.WorldPosition, OuterConeRotation, OuterConeRotation+OuterConeAngle, PJANodeDataLight(ANode^.Data)^.ConeRadius);

         OuterConeAngle := 3;
         OuterConeRotation := ANode^.Spatial.WorldRotation + ((PJANodeDataLight(ANode^.Data)^.ConeAngle/2) - (OuterConeAngle*2));

         JARenderLightFan(ANode^.Spatial.WorldPosition, OuterConeRotation+OuterConeAngle, OuterConeRotation, PJANodeDataLight(ANode^.Data)^.ConeRadius);
         }
         SetWrMsk(JARenderRasterPort, %11111111); { Enable Planes 1-5}
         SetAPen(JARenderRasterPort, 1); //Restore Black Pen
         SetAfPt(JARenderRasterPort, nil, 0);

         {Now Render Shadows for this Light}

      end;
   end;
end;

function JANodeTypeToString(ANodeType : TJANodeType) : string;
begin
   case ANodeType of
      JANode_Root : Result := 'Root';
      JANode_Sketch : Result := 'Sketch';
      JANode_Emitter : Result := 'Emitter';
      JANode_Light : Result := 'Light';
      JANode_Camera : Result := 'Camera';
      JANode_Sound : Result := 'Sound';
   end;
end;

procedure JANodeDataInitRoot(ANodeDataRoot : PJANodeDataRoot);
begin
   ANodeDataRoot^.StopHere := true;
end;

procedure JANodeDataInitSketch(ANodeDataSketch : PJANodeDataSketch);
begin
   ANodeDataSketch^.Sketch := nil;
end;

procedure JANodeDataInitEmitter(ANodeDataEmitter : PJANodeDataEmitter);
begin
   ANodeDataEmitter^.Rate := 10;
   ANodeDataEmitter^.Colour.R := 1;
   ANodeDataEmitter^.Colour.G := 1;
   ANodeDataEmitter^.Colour.B := 1;
   ANodeDataEmitter^.Colour.A := 1;
end;

procedure JANodeDataInitLight(ANodeDataLight : PJANodeDataLight);
begin
   ANodeDataLight^.Radius := 5;
   ANodeDataLight^.ConeRadius := 100000;
   ANodeDataLight^.ConeAngle := 90;
   ANodeDataLight^.Colour.R := 1;
   ANodeDataLight^.Colour.G := 1;
   ANodeDataLight^.Colour.B := 1;
   ANodeDataLight^.Colour.A := 1;
end;

procedure JANodeDataInitCamera(ANodeDataCamera : PJANodeDataCamera);
begin
   ANodeDataCamera^.Zoom := 1.0;
end;

procedure JANodeDataInitSound(ANodeDataSound : PJANodeDataSound);
begin
   ANodeDataSound^.SoundID := 1;
end;

procedure JANodeWidgetLightRender(ALight: PJANode);
var
   WorldVertexI : TVec2SInt16;
   AVec : TVec2;
   WorldRadiusI : SInt16;

begin
   with PJANodeDataLight(ALight^.Data)^ do
   begin
      {$IFDEF JA_SCENE_MAT3}
      JARenderModelMatrix := ALight^.Spatial.WorldMatrix;
      JARenderMVP := JARenderViewMatrix;// * JARenderModelMatrix;
      WorldVertexI.X := round(JARenderMVP._00*ALight^.Spatial.WorldPosition.X + JARenderMVP._01*ALight^.Spatial.WorldPosition.Y  + JARenderMVP._02);
      WorldVertexI.Y := round(JARenderMVP._10*ALight^.Spatial.WorldPosition.X + JARenderMVP._11*ALight^.Spatial.WorldPosition.Y  + JARenderMVP._12);
      {$ENDIF}
      {Scale Circle to World}
      AVec := Vec2(Radius, 0);
      AVec := Vec2DotMat3(AVec,  JARenderMVP);
      WorldRadiusI := round(Vec2Length(AVec));

      JARenderCircle(WorldVertexI, WorldRadiusI);
   end;
end;

procedure JANodeWidgetSpatialRender(ANode: PJANode);
begin

end;

end.

