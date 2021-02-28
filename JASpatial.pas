unit JASpatial;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   sysutils,
   JATypes, JAMath, JALog;

type
   PJASpatial = ^TJASpatial;
   TJASpatial = record
      Parent : PJASpatial; {the parent spatial of this spatial}
      Node : pointer; {the node this spatial belongs to}
      Cell : pointer; {the leaf cell of this spatial}

      InitialPosition : TVec2;
      InitialRotation : Float32;
      InitialScale : Float32;

      LocalPosition : TVec2;
      LocalRotation : Float32;
      LocalScale : Float32;
      LocalBBox : TJBBox;
      LocalBRadius : Float32;

      LocalVelocity : TVec2;
      LocalVelocityRotation : Float32;

      Dirty : boolean;

      WorldPosition : TVec2;
      WorldRotation : Float32;
      WorldScale : Float32;
      WorldBBox : TJBBox;
      WorldBRadius : Float32;

      ScreenPosition : TVec2SInt16;
      ScreenRotation : UInt16;
      ScreenBBox : TJBBoxSInt16;
      ScreenBRadius : UInt16;
      ScreenDirty : boolean;

      {$IFDEF JA_SCENE_MAT2}
      LocalMatrix2 : TMat2;
      WorldMatrix2 : TMat2;
      WorldMatrixInverse2 : TMat2;
      {$ENDIF}
      {$IFDEF JA_SCENE_MAT3}
      LocalMatrix : TMat3;
      WorldMatrix : TMat3;
      WorldMatrixInverse : TMat3;
      {$ENDIF}
   end;

const
   JASpatialDefault : TJASpatial = (
      Parent : nil;
      Node : nil;
      Cell : nil;
      InitialPosition : (X:0;Y:0);
      InitialRotation : 0.0;
      InitialScale : 1.0;
      LocalPosition : (X:0;Y:0);
      LocalRotation : 0.0;
      LocalScale : 1.0;
      LocalBBox : (MinX:0;MinY:0;MaxX:0;MaxY:0);
      LocalBRadius : 0;
      LocalVelocity : (X:0;Y:0);
      LocalVelocityRotation : 0.0;
      Dirty : false;
      WorldPosition : (X:0;Y:0);
      WorldRotation : 0.0;
      WorldScale : 1.0;
      WorldBBox : (MinX:0;MinY:0;MaxX:0;MaxY:0);
      WorldBRadius : 0.0;
      ScreenPosition : (X:0;Y:0);
      ScreenRotation : 0;
      ScreenBBox : (MinX:0;MinY:0;MaxX:0;MaxY:0);
      ScreenBRadius : 0;
      ScreenDirty : false;
      {$IFDEF JA_SCENE_MAT2}
      LocalMatrix2 : (_00:1;_01:0;_10:0;_11:1;);
      WorldMatrix2 : (_00:1;_01:0;_10:0;_11:1;);
      WorldMatrixInverse2 : (_00:1;_01:0;_10:0;_11:1;);
      {$ENDIF}
      {$IFDEF JA_SCENE_MAT3}
      LocalMatrix : (_00:1;_01:0;_02:0;_10:0;_11:1;_12:0;_20:0;_21:0;_22:1);
      WorldMatrix : (_00:1;_01:0;_02:0;_10:0;_11:1;_12:0;_20:0;_21:0;_22:1);
      WorldMatrixInverse : (_00:1;_01:0;_02:0;_10:0;_11:1;_12:0;_20:0;_21:0;_22:1);
      {$ENDIF}
   );

procedure JASpatialSetLocalPosition(ASpatial : PJASpatial; ALocalPosition : TVec2);
procedure JASpatialSetLocalRotation(ASpatial : PJASpatial; ALocalRotation : Float32);
procedure JASpatialSetLocalScale(ASpatial : PJASpatial; ALocalScale : Float32);
procedure JASpatialSetLocalBRadius(ASpatial : PJASpatial; ABRadius : Float32);
procedure JASpatialSetLocalBBox(ASpatial : PJASpatial; ABBox : TJBBox);
procedure JASpatialSetParent(ASpatial : PJASpatial; AParent : PJASpatial);

procedure JASpatialDirtyUpdate(ASpatial : PJASpatial);
procedure JASpatialUpdate(ASpatial : PJASpatial; ADelta : Float32);

implementation

procedure JASpatialSetLocalPosition(ASpatial : PJASpatial; ALocalPosition : TVec2);
begin
   ASpatial^.LocalPosition := ALocalPosition;

   {$IFDEF JA_SCENE_MAT2}
   ASpatial^.LocalMatrix2 := Mat2Multiply(
      Mat2Rotation(ASpatial^.LocalRotation),Mat2Scale(ASpatial^.LocalScale));
   {$ENDIF}
   {$IFDEF JA_SCENE_MAT3}
   ASpatial^.LocalMatrix := Mat3Multiply(
      Mat3Multiply(Mat3Translation(ASpatial^.LocalPosition), Mat3Rotation(ASpatial^.LocalRotation)),
      Mat3Scale(ASpatial^.LocalScale));
   {$ENDIF}

   ASpatial^.Dirty := true;

   {TEMP}
   with ASpatial^ do
   begin
      if Parent<>nil then
      begin
         {$IFDEF JA_SCENE_MAT2}
         WorldMatrix2 := Mat2Multiply(Parent^.WorldMatrix2, LocalMatrix2);
         WorldMatrixInverse2 := Mat2Inverse(WorldMatrix2);
         WorldPosition := Parent^.WorldPosition + Vec2DotMat2(LocalPosition, LocalMatrix2);
         {$ENDIF}
         {$IFDEF JA_SCENE_MAT3}
         WorldMatrix := Mat3Multiply(Parent^.WorldMatrix, LocalMatrix);
         WorldMatrixInverse := Mat3Inverse(WorldMatrix);
         WorldPosition := Vec2DotMat3(LocalPosition, WorldMatrixInverse);
         {$ENDIF}
      end else
      begin
         {$IFDEF JA_SCENE_MAT2}
         WorldMatrix2 := LocalMatrix2;
         WorldMatrixInverse2 := Mat2Inverse(WorldMatrix2);
			WorldPosition := Vec2DotMat2(LocalPosition, LocalMatrix2);
         {$ENDIF}
         {$IFDEF JA_SCENE_MAT3}
         WorldMatrix := LocalMatrix;
         WorldMatrixInverse := Mat3Inverse(WorldMatrix);
         WorldPosition := LocalPosition;
         {$ENDIF}
      end;

      WorldRotation := LocalRotation;
      WorldScale := LocalScale;
      WorldBRadius := LocalBRadius;
      WorldBBox := LocalBBox;
      Dirty := false;
   end;
end;

procedure JASpatialSetLocalRotation(ASpatial : PJASpatial; ALocalRotation : Float32);
begin
   if (ALocalRotation < 0) then ALocalRotation += 360;
   if (ALocalRotation > 360) then ALocalRotation -= 360;

   ASpatial^.LocalRotation := ALocalRotation;

   {$IFDEF JA_SCENE_MAT2}
   ASpatial^.LocalMatrix2 := Mat2Multiply(
      Mat2Rotation(ASpatial^.LocalRotation),Mat2Scale(ASpatial^.LocalScale));
   {$ENDIF}
   {$IFDEF JA_SCENE_MAT3}
   ASpatial^.LocalMatrix := Mat3Multiply(
      Mat3Multiply(Mat3Translation(ASpatial^.LocalPosition), Mat3Rotation(ASpatial^.LocalRotation)),
      Mat3Scale(ASpatial^.LocalScale));
   {$ENDIF}

   ASpatial^.Dirty := true;

   {TEMP}
   with ASpatial^ do
   begin
      if Parent<>nil then
      begin
         {$IFDEF JA_SCENE_MAT2}
         WorldMatrix2 := Mat2Multiply(Parent^.WorldMatrix2, LocalMatrix2);
         WorldMatrixInverse2 := Mat2Inverse(WorldMatrix2);
         WorldPosition := Parent^.WorldPosition + Vec2DotMat2(LocalPosition, LocalMatrix2);
         {$ENDIF}
         {$IFDEF JA_SCENE_MAT3}
         WorldMatrix := Mat3Multiply(Parent^.WorldMatrix, LocalMatrix);
         WorldMatrixInverse := Mat3Inverse(WorldMatrix);
         WorldPosition := Vec2DotMat3(LocalPosition, WorldMatrixInverse);
         {$ENDIF}
      end else
      begin
         {$IFDEF JA_SCENE_MAT2}
         WorldMatrix2 := LocalMatrix2;
         WorldMatrixInverse2 := Mat2Inverse(WorldMatrix2);
			WorldPosition := Vec2DotMat2(LocalPosition, LocalMatrix2);
         {$ENDIF}
         {$IFDEF JA_SCENE_MAT3}
         WorldMatrix := LocalMatrix;
         WorldMatrixInverse := Mat3Inverse(WorldMatrix);
         WorldPosition := LocalPosition;
         {$ENDIF}
      end;

      WorldRotation := LocalRotation;
      WorldScale := LocalScale;
      WorldBRadius := LocalBRadius;
      WorldBBox := LocalBBox;
      Dirty := false;
   end;
end;

procedure JASpatialSetLocalScale(ASpatial : PJASpatial; ALocalScale : Float32);
begin
   ASpatial^.LocalScale := ALocalScale;

   {$IFDEF JA_SCENE_MAT2}
   ASpatial^.LocalMatrix2 := Mat2Multiply(
      Mat2Rotation(ASpatial^.LocalRotation),Mat2Scale(ASpatial^.LocalScale));
   {$ENDIF}
   {$IFDEF JA_SCENE_MAT3}
   ASpatial^.LocalMatrix := Mat3Multiply(
      Mat3Multiply(Mat3Translation(ASpatial^.LocalPosition), Mat3Rotation(ASpatial^.LocalRotation)),
      Mat3Scale(ASpatial^.LocalScale));
   {$ENDIF}

   ASpatial^.Dirty := true;

   {TEMP}
   with ASpatial^ do
   begin
      if Parent<>nil then
      begin
         {$IFDEF JA_SCENE_MAT2}
         WorldMatrix2 := Mat2Multiply(Parent^.WorldMatrix2, LocalMatrix2);
         WorldMatrixInverse2 := Mat2Inverse(WorldMatrix2);
         WorldPosition := Parent^.WorldPosition + Vec2DotMat2(LocalPosition, LocalMatrix2);
         {$ENDIF}
         {$IFDEF JA_SCENE_MAT3}
         WorldMatrix := Mat3Multiply(Parent^.WorldMatrix, LocalMatrix);
         WorldMatrixInverse := Mat3Inverse(WorldMatrix);
         WorldPosition := Vec2DotMat3(LocalPosition, WorldMatrixInverse);
         {$ENDIF}
      end else
      begin
         {$IFDEF JA_SCENE_MAT2}
         WorldMatrix2 := LocalMatrix2;
         WorldMatrixInverse2 := Mat2Inverse(WorldMatrix2);
			WorldPosition := Vec2DotMat2(LocalPosition, LocalMatrix2);
         {$ENDIF}
         {$IFDEF JA_SCENE_MAT3}
         WorldMatrix := LocalMatrix;
         WorldMatrixInverse := Mat3Inverse(WorldMatrix);
         WorldPosition := LocalPosition;
         {$ENDIF}
      end;

      WorldRotation := LocalRotation;
      WorldScale := LocalScale;
      WorldBRadius := LocalBRadius;
      WorldBBox := LocalBBox;
      Dirty := false;
   end;
end;

procedure JASpatialSetLocalBRadius(ASpatial : PJASpatial; ABRadius : Float32);
begin
   ASpatial^.LocalBRadius := ABRadius;
   ASpatial^.Dirty := true;
end;

procedure JASpatialSetLocalBBox(ASpatial : PJASpatial; ABBox : TJBBox);
begin
   ASpatial^.LocalBBox := ABBox;
   ASpatial^.Dirty := true;
end;

procedure JASpatialSetParent(ASpatial : PJASpatial; AParent : PJASpatial);
begin
   ASpatial^.Parent := AParent;
end;

procedure JASpatialDirtyUpdate(ASpatial : PJASpatial);
begin

end;

procedure JASpatialUpdate(ASpatial : PJASpatial; ADelta : Float32);
begin
   {update this node}
   //if ASpatial^.Dirty then
   with ASpatial^ do
   begin
      {$IFDEF JA_SCENE_MAT2}
      if Parent<>nil then WorldMatrix2 := Mat2Multiply(Parent^.WorldMatrix2,LocalMatrix2)
      else WorldMatrix2 := LocalMatrix2;
      WorldMatrixInverse2 := Mat2Inverse(WorldMatrix2);
      WorldPosition := Parent^.WorldPosition + Vec2DotMat2(LocalPosition, LocalMatrix2);
      {$ENDIF}
      {$IFDEF JA_SCENE_MAT3}
      if Parent<>nil then WorldMatrix := Parent^.WorldMatrix * LocalMatrix
      else WorldMatrix := LocalMatrix;
      WorldMatrixInverse := Mat3Inverse(WorldMatrix);
      WorldPosition := Vec2DotMat3Affine(LocalPosition, WorldMatrixInverse);
      {$ENDIF}

		WorldRotation := LocalRotation;
      WorldScale := LocalScale;
      WorldBRadius := LocalBRadius;
      WorldBBox := LocalBBox;

      Dirty := false;
   end;
end;

end.
