unit JAMath;
{$mode objfpc}{$H+}
{$PACKRECORDS 2} {required for compatibility with various amiga APIs}

interface

uses
   math, JATypes;

{--------------------------------------------------------------General Routines}

function JMax(const A, B : UInt8) : UInt8; {$I JAInline.inc} overload;
function JMax(const A, B, C : UInt8) : UInt8; {$I JAInline.inc} overload;
function JMax(const A, B, C, D : UInt8) : UInt8; {$I JAInline.inc} overload;
function JMax(const A, B : SInt16) : SInt16; {$I JAInline.inc} overload;
function JMax(const A, B, C : SInt16) : SInt16; {$I JAInline.inc} overload;
function JMax(const A, B, C, D : SInt16) : SInt16; {$I JAInline.inc} overload;
function JMax(const A, B : SInt32) : SInt32; {$I JAInline.inc} overload;
function JMax(const A, B, C : SInt32) : SInt32; {$I JAInline.inc} overload;
function JMax(const A, B, C, D : SInt32) : SInt32; {$I JAInline.inc} overload;
function JMax(const A, B : Float32) : Float32; {$I JAInline.inc} overload;
function JMax(const A, B, C : Float32) : Float32; {$I JAInline.inc} overload;
function JMax(const A, B, C, D : Float32) : Float32; {$I JAInline.inc} overload;
function JMin(const A, B : UInt8) : UInt8; {$I JAInline.inc} overload;
function JMin(const A, B, C : UInt8) : UInt8; {$I JAInline.inc} overload;
function JMin(const A, B, C, D : UInt8) : UInt8; {$I JAInline.inc} overload;
function JMin(const A, B : SInt16) : SInt16; {$I JAInline.inc} overload;
function JMin(const A, B, C : SInt16) : SInt16; {$I JAInline.inc} overload;
function JMin(const A, B, C, D : SInt16) : SInt16; {$I JAInline.inc} overload;
function JMin(const A, B : SInt32) : SInt32; {$I JAInline.inc} overload;
function JMin(const A, B, C : SInt32) : SInt32; {$I JAInline.inc} overload;
function JMin(const A, B, C, D : SInt32) : SInt32; {$I JAInline.inc} overload;
function JMin(const A, B : Float32) : Float32; {$I JAInline.inc} overload;
function JMin(const A, B, C : Float32) : Float32; {$I JAInline.inc} overload;
function JMin(const A, B, C, D : Float32) : Float32; {$I JAInline.inc} overload;

function JClamp(const AValue, LowerBound, UpperBound : SInt8) : SInt8; {$I JAInline.inc} overload;
function JClamp(const AValue, LowerBound, UpperBound : UInt8) : UInt8; {$I JAInline.inc} overload;
function JClamp(const AValue, LowerBound, UpperBound : SInt16) : SInt16; {$I JAInline.inc} overload;
function JClamp(const AValue, LowerBound, UpperBound : UInt16) : UInt16; {$I JAInline.inc} overload;
function JClamp(const AValue, LowerBound, UpperBound : SInt32) : SInt32; {$I JAInline.inc} overload;
function JClamp(const AValue, LowerBound, UpperBound : UInt32) : UInt32; {$I JAInline.inc} overload;
function JClamp(const AValue, LowerBound, UpperBound : Float32) : Float32; {$I JAInline.inc} overload;
function JInRange(const AValue, LowerBound, UpperBound : SInt8) : boolean; {$I JAInline.inc} overload;
function JInRange(const AValue, LowerBound, UpperBound : UInt8) : boolean; {$I JAInline.inc} overload;
function JInRange(const AValue, LowerBound, UpperBound : SInt16) : boolean; {$I JAInline.inc} overload;
function JInRange(const AValue, LowerBound, UpperBound : UInt16) : boolean; {$I JAInline.inc} overload;
function JInRange(const AValue, LowerBound, UpperBound : SInt32) : boolean; {$I JAInline.inc} overload;
function JInRange(const AValue, LowerBound, UpperBound : UInt32) : boolean; {$I JAInline.inc} overload;
function JInRange(const AValue, LowerBound, UpperBound : Float32) : boolean; {$I JAInline.inc} overload;

function JRepeat(AValue, LowerBound, UpperBound : SInt16) : SInt16; overload;
function JRepeat(AValue, LowerBound, UpperBound : SInt32) : SInt32; overload;



function JRandomUInt8(LowerBound, UpperBound : UInt8) : UInt8; {$I JAInline.inc}
function JRandomSInt16(LowerBound, UpperBound : SInt16) : SInt16; {$I JAInline.inc}
function JRandomSInt32(LowerBound, UpperBound : SInt32) : SInt32; {$I JAInline.inc}
function JRandomFloat32(LowerBound, UpperBound : Float32) : Float32; {$I JAInline.inc}



(*
function JArcCos(const A : Float32) : Float32; {ArcCosine}
function Float32Mod(const A, B: Float32) : Float32; {$I JAInline.inc} {Floating Point Modulus}
function Float32Rem(const A, B: Float32) : Float32; {$I JAInline.inc} {Floating Point Remainder}
function JInterpolate(const F1,F2, Alpha : Float32):Float32; {$I JAInline.inc}
*)

{-----------------------------------------------------------------Vec2 Routines}

function Vec2Dot(const A, B : TVec2) : Float32; {$I JAInline.inc}
function Vec2Cross(const A, B : TVec2) : Float32; {$I JAInline.inc} overload;
function Vec2Cross(const A : TVec2; const S : Float32) : TVec2; {$I JAInline.inc} overload;
function Vec2Cross(const S : Float32; const A : TVec2) : TVec2; {$I JAInline.inc} overload;
function Vec2LengthSquared(const V : TVec2) : Float32; {$I JAInline.inc}
function Vec2Length(const V : TVec2) : Float32; {$I JAInline.inc}
function Vec2Distance(Const A, B : TVec2) : Float32; {$I JAInline.inc}
function Vec2Normalize(const V : TVec2) : TVec2; {$I JAInline.inc}
function Vec2Angle(const A, B: TVec2) : Float32; {$I JAInline.inc}
function Vec2Reflect(const V, N: TVec2) : TVec2; {$I JAInline.inc}
function Vec2Rotate(const V : TVec2; const A: Float32) : TVec2; {$I JAInline.inc}
function Vec2Rotate(const V, Axis : TVec2; const A : Float32) : TVec2; {$I JAInline.inc}
function Vec2Lerp(const A, B: TVec2; const W : Float32) : TVec2; {$I JAInline.inc}

(*
function Vec2Transform(const V : TVec2; const M : TJMatrix): TVec2;{$I jinline.inc} overload;
function Vec2ITransform(const V : TVec2I; const M : TJMatrix): TVec2I;{$I jinline.inc} overload;
function Vec2InvTransform(const V: TVec2; const M: TJMatrix): TVec2;{$I jinline.inc} overload;
function Vec2IInvTransform(const V: TVec2I; const M: TJMatrix): TVec2I;{$I jinline.inc}

function Vec2MatrixRotate(const V: TVec2; const M: TJMatrix): TVec2;{$I jinline.inc} overload;
function Vec2InvMatrixRotate(const V: TVec2; const M: TJMatrix): TVec2;{$I jinline.inc} overload;

function Vec2CatmullRom(const A,B,C,D : TVec2; const W : Float32) : TVec2;
function Vec2Hermite(const PosA,TanA,PosB,TanB : TVec2; const W : Float32):TVec2;
function Vec2BezierDeg2(const A,B,C : TVec2; const W : Float32) : TVec2;
function Vec2BezierDeg3(const A,B,C,D : TVec2; const W : Float32) : TVec2;

function Vec2ParallelComponent(const A, unitBasis : TVec2) : TVec2;
function Vec2PerpendicularComponent(const A, unitBasis : TVec2) : TVec2;
function Vec2DistanceFromLine(const AVertex : TVec2; const lineOrigin : TVec2; const lineUnitTangent:TVec2) : Float32;
function Vec2DistanceFromLineSegment(Const AVertex : TVec2; const LineA, LineB : TVec2) : Float32;
*)

{-----------------------------------------------------------------Mat2 Routines}


function Mat2Rotation(const F : Float32) : TMat2; overload; {$I JAInline.inc}
function Mat2Rotation(const V : TVec2) : TMat2; overload; {$I JAInline.inc}
function Mat2Scale(const F : Float32) : TMat2; overload; {$I JAInline.inc}
function Mat2Scale(const V : TVec2) : TMat2; overload; {$I JAInline.inc}
function Mat2Determinant(m0 : TMat2) : Float32; {$I JAInline.inc}
function Mat2Negative(m0 : TMat2) : TMat2; {$I JAInline.inc}
function Mat2Transpose(m0 : TMat2) : TMat2; {$I JAInline.inc}
function Mat2CoFactor(m0 : TMat2) : TMat2; {$I JAInline.inc}
function Mat2Adjugate(m0 : TMat2) : TMat2; {$I JAInline.inc}
function Mat2Multiply(m0, m1 : TMat2) : TMat2; {$I JAInline.inc}
function Mat2MultiplyF(m0 : TMat2; f : Float32) : TMat2; {$I JAInline.inc}
function Mat2Inverse(m0 : TMat2) : TMat2; {$I JAInline.inc}
function Mat2Lerp(m0, m1 : TMat2; f : Float32) : TMat2; {$I JAInline.inc}

function Vec2DotMat2(const V : TVec2; const A : TMat2) : TVec2; {$I JAInline.inc}

{-----------------------------------------------------------------Mat3 Routines}

function Mat3Transpose(const A : TMat3) : TMat3; {$I JAInline.inc}
function Mat3ScaleFloat(const A : TMat3; const F : Float32) : TMat3; {$I JAInline.inc}
function Mat3Multiply(const A, B : TMat3) : TMat3; {$I JAInline.inc}
function Mat3Determinant(const A : TMat3) : Float32; {$I JAInline.inc}
function Mat3Adjoint(const A : TMat3) : TMat3; {$I JAInline.inc}
function Mat3AdjointScale(const A : TMat3; const F : Float32) : TMat3; {$I JAInline.inc}
function Mat3Inverse(const A : TMat3) : TMat3; {$I JAInline.inc}
function Mat3Translation(const V : TVec2) : TMat3; {$I JAInline.inc}
function Mat3Rotation(const F : Float32) : TMat3; {$I JAInline.inc}
function Mat3Scale(const F : Float32) : TMat3; {$I JAInline.inc}

function Vec2DotMat3(const V : TVec2; const A : TMat3) : TVec2; {$I JAInline.inc}
function Vec2DotInvMat3(const V : TVec2; const A : TMat3) : TVec2; {$I JAInline.inc}
function Vec2DotMat3Affine(const V : TVec2; const A : TMat3) : TVec2; {$I JAInline.inc}


function JRectIntersectCircle(AOrigin : TVec2; ARadius : Float32; ARect : TJRectSInt16): Boolean; {$I JAInline.inc} overload;
function JRectIntersectVertex(AOrigin : TVec2; ARect : TJRectSInt16): Boolean; {$I JAInline.inc} overload;
function JRectIntersectLine(A,B : TVec2; ARect : TJRectSInt16): Boolean; {$I JAInline.inc} overload;


function JLineIntersectLine(p1, q1, p2, q2 : TVec2) : boolean;
function LineLineIntersect(A, B, C, D : TVec2; var iOut : TVec2) : boolean;
function JRectIntersectLineResult(ALine0 : TVec2SInt16; ALine1 : TVec2; var ARect : TJRectSInt16; var AResultSide : TJRectSide; var AResultVertex : TVec2) : boolean;
function JRectSideClipping(SideA,SideB : TJRectSide; ClipRect : TJRect; var AVec1,AVec2 : TVec2; var AVecCount : SInt16) : boolean;



//function LineLineIntersect(a1, a2, b3, b4 : TVec2; var iOut : TVec2) : boolean;
(*
{Rect Routines}
function JRectContain(const P: TVec2; const R: TJRect): Boolean; {$I JAInline.inc} overload;
function JRectContain(const P: TVec2I; const R: TJRect): Boolean; {$I JAInline.inc} overload;
function JRectContain(const A, B: TJRect): Boolean; {$I JAInline.inc} overload;
function JRectOverlap(const A, B: TJRect): Boolean; {$I JAInline.inc} overload;
function JRectOverlap(const A, B: TJRect; OffSetB: TVec2): Boolean; {$I JAInline.inc} overload;
function JRectOverlap(const A, B: TJRect; OffsetA, OffSetB: TVec2): Boolean; {$I JAInline.inc} overload;
function JRectTranslate(const R: TJRect; const V: TVec2): TJRect; {$I JAInline.inc}
function JRectTranslate(const R: TJRect; const X,Y : Float32): TJRect; {$I JAInline.inc} overload;
function JRectScale(const R: TJRect; const F: Float32): TJRect; {$I JAInline.inc}
function JRectScale(const R: TJRect; const X,Y : Float32): TJRect; {$I JAInline.inc} overload;
function JRectTransform(const R: TJRect; const M: TJMatrix): TJRect; overload;
function JRectInvTransform(const R: TJRect; const M: TJMatrix): TJRect; {$I JAInline.inc} overload;
function JRectRandomVec2(const ARect : TJRect):TVec2; {$I JAInline.inc}
function JRectClip(const A, B : TJRect) : TJRect; {$I JAInline.inc} overload;

function JRectIContain(const P: TVec2; const R: TJRectI): Boolean; {$I JAInline.inc}overload;
function JRectIContain(const P: TVec2I; const R: TJRectI): Boolean; {$I JAInline.inc}overload;
function JRectIContain(const A, B: TJRectI): Boolean; {$I JAInline.inc}overload;
function JRectIOverlap(const A, B: TJRectI): Boolean; {$I JAInline.inc}overload;
function JRectIOverlap(const A, B: TJRectI; OffSetB: TVec2I): Boolean; {$I JAInline.inc}overload;
function JRectIOverlap(const A, B: TJRectI; OffsetA, OffSetB: TVec2I): Boolean; {$I JAInline.inc}overload;
function JRectITranslate(const R: TJRectI; const V: TVec2I): TJRectI; {$I JAInline.inc}
function JRectITranslate(const R: TJRectI; const X,Y : SInt32): TJRectI; {$I JAInline.inc}overload;
function JRectIScale(const R: TJRectI; const F: SInt32): TJRectI; {$I JAInline.inc}
function JRectIScale(const R: TJRectI; const X,Y : SInt32): TJRectI; {$I JAInline.inc}overload;
function JRectITransform(const R: TJRectI; const M: TJMatrix): TJRectI; {$I JAInline.inc} overload;
function JRectIInvTransform(const R: TJRectI; const M: TJMatrix): TJRectI; {$I JAInline.inc} overload;
function JRectIRandomVec2I(const ARect : TJRectI):TVec2I; {$I JAInline.inc}
function JRectIClip(const A, B : TJRectI) : TJRectI; {$I JAInline.inc} overload;

{TJRay Routines}
function JRayVector(const R : TJRay):TVec3; {$I JAInline.inc}
function JRayPick(const ScreenV : TVec2I; const Width, Height : Float32; const Projection, ModelView : TJMatrix):TJRay;
function JRayDistance(const R : TJRay;const V : TVec3):Float32;

function JRayIntersectPlane(const R : TJRay; const P : TJPlane; const Intersection : PVec3 = nil) : SInt32;
function JRayIntersectXZPlane(const R : TJRay; const PlaneY : Float32; const Intersection : PVec3 = nil) : Boolean;
function JRayIntersectTriangle(const ARay : TJRay; const ATri : TJTriangle3; const Intersection : PVec3=nil; IntersectionNormal : PVec3=nil) : boolean;
function JRayIntersectSphere(const ARay : TJRay; const ASphere : TJSphere; const IntersectionA : PVec3; IntersectionB : PVec3) : SInt32;overload;
function JRayIntersectSphere(const ARay : TJRay; const ASphere : TJSphere) : boolean;overload;
function JRayIntersectBBox(const ARay : TJRay; const BBox : TJBBox; const Intersection : PVec3=nil):boolean;

{TJSphere Routines}
function JSphereVisibleRadius(const Distance, Radius : Float32) : Float32;
function JSphereToBBox(const ASphere : TJSphere) : TJBBox;
function JSphereContain(const ASphere : TJSphere; const AVertex : TVec3):boolean;overload;
function JSphereContain(const ASphere : TJSphere; const BSphere : TJSphere):boolean;overload;
function JSphereContain(const ASphere : TJSphere; const ABBox : TJBBox):boolean;overload;
function JSphereIntersect(const ASphere : TJSphere; const BSphere : TJSphere):TJIntersectResult;overload;
function JSphereIntersect(const ASphere : TJSphere; const ABBox : TJBBox):TJIntersectResult;overload;

{TJFrustum Routines}
function JFrustumFromViewProjectionMatrix(const M : TJMatrix) : TJFrustum;
function JFrustumContain(const AFrustum : TJFrustum; const AVertex : TVec3):boolean;overload;
function JFrustumContain(const AFrustum : TJFrustum; const ASphere : TJSphere):boolean;overload;
function JFrustumContain(const AFrustum : TJFrustum; const ABBox : TJBBox):boolean;overload;
function JFrustumIntersect(const AFrustum : TJFrustum; const ASphere : TJSphere):TJIntersectResult;overload;

function JFrustumIntersectFast(const AFrustum : TJFrustum; const ABBox: TJBBox) : Boolean;
function JFrustumIntersect(const AFrustum : TJFrustum; const ABBox : TJBBox):TJIntersectResult;overload;

{TJBBox Routines}
function JBBoxCenter(const ABBox : TJBBox) : TVec3; {$I JAInline.inc}
function JBBoxToSphere(const ABBox : TJBBox) : TJSphere;
function JBBoxExtractCorners(const ABBox : TJBBox) : TJBBoxCorners;
function JBBoxInclude(const ABBox : TJBBox; BBBox : TJBBox):TJBBox;overload; {expand to include}
function JBBoxInclude(const ABBox : TJBBox; V : TVec3):TJBBox;overload;
function JBBoxContain(const ABBox : TJBBox; const V : TVec3):boolean;overload; {test if fully contain}
function JBBoxContain(const ABBox : TJBBox; const ASphere : TJSphere):boolean;overload;
function JBBoxContain(const ABBox : TJBBox; const BBbox : TJBBox):boolean;overload;
function JBBoxIntersect(const ABBox : TJBBox; const ASphere : TJSphere):TJIntersectResult;overload;
function JBBoxIntersect(const ABBox : TJBBox; const BBbox : TJBBox):TJIntersectResult;overload;

{TJColour Routines}
function JColourClamp(const AColour : TJColour; const ALowerChannelBound, AUpperChannelBound : Float32):TJColour; {$I JAInline.inc}overload;
function JColourClamp(const AColour : TJColour; const ALowerColour, AUpperColour : TJColour):TJColour; {$I JAInline.inc}overload;
function JColour3FromHSV(const H,S,V: Float32) : TJColour3;
procedure JColour3ToHSV(const AColour : TJColour3; var H,S,V: Float32);
*)

implementation

{------------------------------------------------------------- General Routines}

function JMax(const A, B : UInt8) : UInt8; {$I JAInline.inc}
begin
   if (A > B) then Result := A else Result := B;
end;

function JMax(const A, B, C : UInt8) : UInt8; {$I JAInline.inc}
begin
   Result := JMax(JMax(A, B), C);
end;

function JMax(const A, B, C, D : UInt8) : UInt8; {$I JAInline.inc}
begin
   Result := JMax(JMax(A, B), JMax(C, D));
end;

function JMax(const A, B : SInt16) : SInt16; {$I JAInline.inc}
begin
   if (A > B) then Result := A else Result := B;
end;

function JMax(const A, B, C : SInt16) : SInt16; {$I JAInline.inc}
begin
   Result := JMax(JMax(A, B), C);
end;

function JMax(const A, B, C, D : SInt16) : SInt16; {$I JAInline.inc}
begin
   Result := JMax(JMax(A, B), JMax(C, D));
end;

function JMax(const A, B : SInt32) : SInt32; {$I JAInline.inc}
begin
   if (A > B) then Result := A else Result := B;
end;

function JMax(const A, B, C : SInt32) : SInt32; {$I JAInline.inc}
begin
   Result := JMax(JMax(A, B), C);
end;

function JMax(const A, B, C, D : SInt32) : SInt32; {$I JAInline.inc}
begin
   Result := JMax(JMax(A, B), JMax(C, D));
end;

function JMax(const A, B : Float32) : Float32; {$I JAInline.inc}
begin
   if (A > B) then Result := A else Result := B;
end;

function JMax(const A, B, C : Float32) : Float32; {$I JAInline.inc}
begin
   Result := JMax(JMax(A, B), C);
end;

function JMax(const A, B, C, D : Float32) : Float32; {$I JAInline.inc}
begin
   Result := JMax(JMax(A, B), JMax(C, D));
end;

function JMin(const A, B : UInt8) : UInt8;
begin
   if (A < B) then Result := A else Result := B;
end;

function JMin(const A, B, C : UInt8) : UInt8;
begin
   Result := JMin(JMin(A, B), C);
end;

function JMin(const A, B, C, D : UInt8) : UInt8;
begin
   Result := JMin(JMin(A, B), JMin(C, D));
end;

function JMin(const A, B : SInt16) : SInt16; {$I JAInline.inc}
begin
   if (A < B) then Result := A else Result := B;
end;

function JMin(const A, B, C : SInt16) : SInt16; {$I JAInline.inc}
begin
   Result := JMin(JMin(A, B), C);
end;

function JMin(const A, B, C, D : SInt16) : SInt16; {$I JAInline.inc}
begin
   Result := JMin(JMin(A, B), JMin(C, D));
end;

function JMin(const A, B : SInt32) : SInt32; {$I JAInline.inc}
begin
  if (A < B) then Result := A else Result := B;
end;

function JMin(const A, B, C : SInt32) : SInt32; {$I JAInline.inc}
begin
   Result := JMin(JMin(A, B), C);
end;

function JMin(const A, B, C, D : SInt32) : SInt32; {$I JAInline.inc}
begin
   Result := JMin(JMin(A, B), JMin(C, D));
end;

function JMin(const A, B : Float32) : Float32; {$I JAInline.inc}
begin
   if (A < B) then Result := A else Result := B;
end;

function JMin(const A, B, C : Float32) : Float32; {$I JAInline.inc}
begin
   Result := JMin(JMin(A, B), C);
end;

function JMin(const A, B, C, D : Float32) : Float32; {$I JAInline.inc}
begin
   Result := JMin(JMin(A, B), JMin(C, D));
end;

function JClamp(const AValue, LowerBound, UpperBound : SInt8) : SInt8; {$I JAInline.inc}
begin
   if (AValue < LowerBound) then Result := LowerBound else
   if (AValue > UpperBound) then Result := UpperBound else
   Result := AValue;
end;

function JClamp(const AValue, LowerBound, UpperBound : UInt8) : UInt8; {$I JAInline.inc}
begin
   if (AValue < LowerBound) then Result := LowerBound else
   if (AValue > UpperBound) then Result := UpperBound else
   Result := AValue;
end;

function JClamp(const AValue, LowerBound, UpperBound : SInt16) : SInt16; {$I JAInline.inc}
begin
   if (AValue < LowerBound) then Result := LowerBound else
   if (AValue > UpperBound) then Result := UpperBound else
   Result := AValue;
end;

function JClamp(const AValue, LowerBound, UpperBound : UInt16) : UInt16; {$I JAInline.inc}
begin
   if (AValue < LowerBound) then Result := LowerBound else
   if (AValue > UpperBound) then Result := UpperBound else
   Result := AValue;
end;

function JClamp(const AValue, LowerBound, UpperBound : SInt32) : SInt32; {$I JAInline.inc}
begin
   if (AValue < LowerBound) then Result := LowerBound else
   if (AValue > UpperBound) then Result := UpperBound else
   Result := AValue;
end;

function JClamp(const AValue, LowerBound, UpperBound : UInt32) : UInt32; {$I JAInline.inc}
begin
   if (AValue < LowerBound) then Result := LowerBound else
   if (AValue > UpperBound) then Result := UpperBound else
   Result := AValue;
end;

function JClamp(const AValue, LowerBound, UpperBound : Float32) : Float32; {$I JAInline.inc}
begin
   if (AValue < LowerBound) then Result := LowerBound else
   if (AValue > UpperBound) then Result := UpperBound else
   Result := AValue;
end;

function JInRange(const AValue, LowerBound, UpperBound : SInt8) : boolean; {$I JAInline.inc}
begin
   Result := (AValue >= LowerBound) and (AValue <= UpperBound);
end;

function JInRange(const AValue, LowerBound, UpperBound : UInt8) : boolean; {$I JAInline.inc}
begin
   Result := (AValue >= LowerBound) and (AValue <= UpperBound);
end;

function JInRange(const AValue, LowerBound, UpperBound : SInt16) : boolean; {$I JAInline.inc}
begin
   Result := (AValue >= LowerBound) and (AValue <= UpperBound);
end;

function JInRange(const AValue, LowerBound, UpperBound : UInt16) : boolean; {$I JAInline.inc}
begin
   Result := (AValue >= LowerBound) and (AValue <= UpperBound);
end;

function JInRange(const AValue, LowerBound, UpperBound : SInt32) : boolean; {$I JAInline.inc}
begin
   Result := (AValue >= LowerBound) and (AValue <= UpperBound);
end;

function JInRange(const AValue, LowerBound, UpperBound : UInt32) : boolean; {$I JAInline.inc}
begin
   Result := (AValue >= LowerBound) and (AValue <= UpperBound);
end;

function JInRange(const AValue, LowerBound, UpperBound : Float32): boolean; {$I JAInline.inc}
begin
   Result := (AValue >= LowerBound) and (AValue <= UpperBound);
end;

function JRepeat(AValue, LowerBound, UpperBound: SInt16): SInt16;
var
   W : SInt16;
begin
   W := UpperBound-LowerBound+1;
   Result := ((AValue-LowerBound) mod (W) + (W)) mod (W) + LowerBound;
end;

function JRepeat(AValue, LowerBound, UpperBound: SInt32): SInt32;
var
   W : SInt16;
begin
   W := UpperBound-LowerBound+1;
   Result := ((AValue-LowerBound) mod (W) + (W)) mod (W) + LowerBound;
end;

function JRandomUInt8(LowerBound, UpperBound : UInt8) : UInt8; {$I JAInline.inc}
begin
   Result := LowerBound + Random(UpperBound - LowerBound);
end;

function JRandomSInt16(LowerBound, UpperBound : SInt16) : SInt16; {$I JAInline.inc}
begin
   Result := LowerBound + Random(UpperBound - LowerBound);
end;

function JRandomSInt32(LowerBound, UpperBound : SInt32) : SInt32; {$I JAInline.inc}
begin
   Result := LowerBound + Random(UpperBound - LowerBound);
end;

function JRandomFloat32(LowerBound, UpperBound : Float32) : Float32; {$I JAInline.inc}
begin
   Result := LowerBound + (Random() * (UpperBound - LowerBound));
end;

{
function JArcCos(const A : Float32) : Float32;
begin
   if A = 0.0 then
   Result := JPIDiv2
   else
   Result := ArcTan ( Sqrt ( 1 - A*A ) / A );
   if A < 0.0 then
   Result := JPI - Result;
end;

{Floating Point Modulus}
function Float32Mod(const A, B: Float32) : Float32; {$I JAInline.inc}
begin
    Result := A - Floor ( A / B ) * B;
end;

{Floating Point Remainder}
function Float32Rem(const A, B: Float32) : Float32; {$I JAInline.inc}
begin
    Result := A - Int ( A / B ) * B;
end;

function JInterpolate(const F1,F2, Alpha : Float32):Float32; {$I JAInline.inc}
begin
   Result := F1 + ((F2 - F1) * Alpha);
end;

}

{-----------------------------------------------------------------Vec2 Routines}

function Vec2Dot(const A, B : TVec2) : Float32; {$I JAInline.inc}
begin
   Result := (A.X * B.X) + (A.Y * B.Y);
end;

function Vec2Cross(const A, B : TVec2) : Float32; {$I JAInline.inc}
begin
   Result := (A.X * B.Y) - (A.Y * B.X);
end;

function Vec2Cross(const A : TVec2; const S : Float32) : TVec2; {$I JAInline.inc}
begin
   Result.X :=  S * A.Y;
   Result.Y := -S * A.X;
end;

function Vec2Cross(const S : Float32; const A : TVec2) : TVec2; {$I JAInline.inc}
begin
   Result.X := -S * A.Y;
   Result.Y :=  S * A.X;
end;

function Vec2LengthSquared(const V : TVec2) : Float32; {$I JAInline.inc}
begin
   Result := Vec2Dot(V,V);
end;

function Vec2Length(const V : TVec2) : Float32; {$I JAInline.inc}
begin
   Result := Sqrt(Vec2LengthSquared(V));
end;

function Vec2Distance(Const A, B : TVec2) : Float32; {$I JAInline.inc}
begin
   Result := Vec2Length(A-B);
end;

function Vec2Normalize(const V : TVec2) : TVec2; {$I JAInline.inc}
begin
   Result.X := Vec2Length(V);
   if (Result.X > 0) then Result := (V / Result.X) else Result := V;
end;

function Vec2Angle(const A, B: TVec2) : Float32; {$I JAInline.inc}
begin
  //Result := arccos(Vec2Dot(Vec2Normalize(A),Vec2Normalize(B)));
  Result := arctan2(a.x*b.y-b.x*a.y,a.x*b.x+a.y*b.y);
end;

{Vector reflection, V is the vector to reflect, N is the normal of the 'wall'}
Function Vec2Reflect(const V, N : TVec2 ) : TVec2; {$I JAInline.inc}
var
   d : Float32;
begin
   D:= Vec2Dot(N, V);
   Result.X:= V.X - 2 * N.X * d;
   Result.Y:= V.Y - 2 * N.Y * d;
end;

function Vec2Rotate(const V : TVec2; const A : Float32) : TVec2; {$I JAInline.inc}
var
   CosValue : Float32;
   SinValue : Float32;
   ARadians : Float32;
begin
   ARadians := A*JDegToRad;
   CosValue := Cos(ARadians);
   SinValue := Sin(ARadians);
   Result.X := (V.X * CosValue) + (V.Y * SinValue);
   Result.Y := -(V.X * SinValue) + (V.Y * CosValue);
end;

function Vec2Rotate(const V : TVec2; const Axis : TVec2; const A : Float32) : TVec2;
begin
   Result := V - Axis;
   Vec2Rotate(Result,A);
   Result := V + Axis;
end;

function Vec2Lerp(const A, B: TVec2; const W : Float32) : TVec2;
begin
  Result := A + ((B - A) * w);
end;



{
function Vec2Transform(const V : TVec2; const M : TJMatrix): TVec2; {$I JAInline.inc}
begin
   result.X := V.x * M._11 + V.y * M._21 + M._41;
	result.Y := V.x * M._12 + V.y * M._22 + M._42;
end;

function Vec2ITransform(const V : TVec2I; const M : TJMatrix): TVec2I; {$I JAInline.inc}
begin
  result.X := round(V.x * M._11 + V.y * M._21 + M._41);
  result.Y := round(V.x * M._12 + V.y * M._22 + M._42);
end;

function Vec2InvTransform(const V: TVec2; const M: TJMatrix): TVec2; {$I JAInline.inc}
var
   Temp: TVec2;
begin
   Temp.X:= V.X - M._41;
   Temp.Y:= V.Y - M._42;
   Result.X:= Temp.X * M._11 + Temp.Y * M._12;
   Result.Y:= Temp.X * M._21 + Temp.Y * M._22;
end;

function Vec2IInvTransform(const V: TVec2I; const M: TJMatrix): TVec2I; {$I JAInline.inc}
var
   Temp: TVec2;
begin
   Temp.X:= V.X - M._41;
   Temp.Y:= V.Y - M._42;
   Result.X:= round(Temp.X * M._11 + Temp.Y * M._12);
   Result.Y:= round(Temp.X * M._21 + Temp.Y * M._22);
end;

function Vec2MatrixRotate(const V: TVec2; const M: TJMatrix): TVec2; {$I JAInline.inc}
begin
   Result.X:= V.X * M.M[0] + V.Y * M.M[4];
   Result.Y:= V.X * M.M[1] + V.Y * M.M[5];
end;

function Vec2InvMatrixRotate(const V: TVec2; const M: TJMatrix): TVec2; {$I JAInline.inc}
begin
   Result.X:= V.X * M._11 + V.Y * M._12;
   Result.Y:= V.X * M._21 + V.Y * M._22;
end;

function Vec2CatmullRom(const A, B, C, D: TVec2; const W: Float32): TVec2;
var
   Af,Bf,Cf,Df : Float32;
begin
	af := -(w*w*w) + 2.0*(w*w) - w;
	bf := 3.0*w*w*w - 5.0*(w*w) + 2.0;
	cf := -3.0*(w*w*w) + 4.0*(w*w) + w;
	df := (w*w*w) - (w*w);
	Result.x := 0.5 * (Af*A.x + Bf*B.x + Cf*C.x + Df*D.x);
	Result.y := 0.5 * (Af*A.y + Bf*B.y + Cf*C.y + Df*D.y);
end;

function Vec2Hermite(const PosA, TanA, PosB, TanB: TVec2; const W: Float32): TVec2;
var
   Af,Bf,Cf,Df : Float32;
begin
   Af := 2.0*(w*w*w) - 3.0*(w*w) + 1.0;
	Bf := (w*w*w) - 2.0 * (w*w) + w;
	Cf := -2.0 *(w*w*w) + 3.0*(w*w);
	Df := (w*w*w) - (w*w);
	Result.x := Af * (PosA.x) + Bf * (TanA.x) + Cf * (PosB.x) + Df * (TanB.x);
	Result.y := Af * (PosA.y) + Bf * (TanA.y) + Cf * (PosB.y) + Df * (TanB.y);
end;

function Vec2BezierDeg2(const A, B, C: TVec2; const W: Float32): TVec2;
var
   Af,Bf,Cf : Float32;
begin
	af := ( 1.0 - w )*( 1.0 - w );
   bf := 2.0*w*( 1.0 - w );
	cf := (w*w);
	Result.x := af * (A.x) + bf * (B.x) + cf * (C.x);
	Result.y := af * (A.y) + bf * (B.y) + cf * (C.y);
end;

function Vec2BezierDeg3(const A, B, C, D: TVec2; const W: Float32): TVec2;
var
   Af,Bf,Cf,Df : Float32;
begin
	Af := ( 1.0 - w )*( 1.0 - w )*( 1.0 - w );
	Bf := 3.0*w*( 1.0 - w )*( 1.0 - w );
	Cf := 3.0*w*w*( 1.0 - w );
	Df := (w*w*w);
	Result.x := Af * (A.x) + Bf * (B.x) + Cf * (C.x) + Df * (D.x);
	Result.y := Af * (A.y) + Bf * (B.y) + Cf * (C.y) + Df * (D.y);
end;


function Vec2ParallelComponent(const A, unitBasis : Tvec2) : Tvec2;
var
   Projection : Float32;
begin
   Projection := Vec2Dot(A,unitBasis);
   Result := unitBasis * projection;
end;

function Vec2PerpendicularComponent(const A, unitBasis: TVec2): TVec2;
begin
   result :=  A - Vec2parallelComponent(A, unitBasis);
end;

{infinte line}
function Vec2DistanceFromLine(const AVertex: TVec2; const lineOrigin: TVec2; const lineUnitTangent: TVec2): Float32;
var
   offset : TVec2;
   perp : TVec2;
begin
     offset := AVertex - lineOrigin;
     perp := Vec2perpendicularComponent(offset,lineUnitTangent);
     result := Vec2Length(perp);
end;

function Vec2DistanceFromLineSegment(const AVertex: TVec2; const LineA, LineB: TVec2): Float32;
var
   Length2,T : Float32;
   Proj : TVec2;
begin
   Length2 := Vec2LengthSquared(LineB-LineA);
   T := Vec2Dot(AVertex - LineA, LineB - LineA) / Length2;
   if (T < 0.0) then exit(Vec2Length(AVertex-LineA));
   if (T > 1.0) then exit(Vec2Length(AVertex-LineB));
   Proj := LineA + ((LineB - LineA) * T);
   Result := Vec2Length(AVertex-Proj);
end;
}


{-----------------------------------------------------------------Mat2 Routines}

{
function Mat2Translation(const V : TVec2) : TMat2; {$I JAInline.inc}
begin
   THERE IS NO SUCH THING.
   A 2x2 Matrix can't represent a translation in 2D space.
end;
}

function Mat2Rotation(const F : Float32) : TMat2; overload; {$I JAInline.inc}
var
   ACos, ASin : Float32;
begin
   ACos := Cos(F * JDegToRad);
   ASin := Sin(F * JDegToRad);
   Result._00 := ACos;
   Result._01 := -ASin;
   Result._10 := ASin;
   Result._11 := ACos;
end;

function Mat2Rotation(const V : TVec2) : TMat2; overload; {$I JAInline.inc}
var
   F : Float32;
   ACos, ASin : Float32;
begin
   F := Vec2Angle(Vec2Up,V);
   ACos := Cos(F * JDegToRad);
   ASin := Sin(F * JDegToRad);
   Result._00 := ACos;
   Result._01 := -ASin;
   Result._10 := ASin;
   Result._11 := ACos;
end;

function Mat2Scale(const F : Float32) : TMat2; overload;  {$I JAInline.inc}
begin
   Result := Mat2Identity;
   Result._00 := F;
   Result._11 := F;
end;

function Mat2Scale(const V : TVec2) : TMat2; overload;  {$I JAInline.inc}
begin
   Result := Mat2Identity;
   Result._00 := V.X;
   Result._11 := V.Y;
end;

function Mat2Determinant(m0 : TMat2) : Float32; {$I JAInline.inc}
begin
	Result := m0._00 * m0._11 - m0._10 * m0._01;
end;

function Mat2Negative(m0 : TMat2) : TMat2; {$I JAInline.inc}
begin
	Result.M[0] := -m0.M[0];
	Result.M[1] := -m0.M[1];
	Result.M[2] := -m0.M[2];
	Result.M[3] := -m0.M[3];
end;

function Mat2Transpose(m0 : TMat2) : TMat2; {$I JAInline.inc}
begin
	Result.M[0] := m0.M[0];
	Result.M[1] := m0.M[2];
	Result.M[2] := m0.M[1];
	Result.M[3] := m0.M[3];
end;

function Mat2CoFactor(m0 : TMat2) : TMat2; {$I JAInline.inc}
begin
	Result.M[0] := m0.M[3];
	Result.M[1] := -m0.M[2];
	Result.M[2] := -m0.M[1];
	Result.M[3] := m0.M[0];
end;

function Mat2Adjugate(m0 : TMat2) : TMat2; {$I JAInline.inc}
begin
	Result.M[0] := m0.M[3];
	Result.M[1] := -m0.M[1];
	Result.M[2] := -m0.M[2];
	Result.M[3] := m0.M[0];
end;

function Mat2Multiply(m0, m1 : TMat2) : TMat2; {$I JAInline.inc}
begin
	Result.M[0] := m0.M[0] * m1.M[0] + m0.M[2] * m1.M[1];
	Result.M[1] := m0.M[1] * m1.M[0] + m0.M[3] * m1.M[1];
	Result.M[2] := m0.M[0] * m1.M[2] + m0.M[2] * m1.M[3];
	Result.M[3] := m0.M[1] * m1.M[2] + m0.M[3] * m1.M[3];
end;

function Mat2MultiplyF(m0 : TMat2; f : Float32) : TMat2; {$I JAInline.inc}
begin
	Result.M[0] := m0.M[0] * f;
	Result.M[1] := m0.M[1] * f;
	Result.M[2] := m0.M[2] * f;
	Result.M[3] := m0.M[3] * f;
end;

function Mat2Inverse(m0 : TMat2) : TMat2; {$I JAInline.inc}
begin
	Result := Mat2CoFactor(m0);
	Result := Mat2MultiplyF(Result, 1.0 / Mat2Determinant(m0));
end;

function Mat2Lerp(m0, m1 : TMat2; f : Float32) : TMat2; {$I JAInline.inc}
begin
	result.M[0] := m0.M[0] + (m1.M[0] - m0.M[0]) * f;
	result.M[1] := m0.M[1] + (m1.M[1] - m0.M[1]) * f;
	result.M[2] := m0.M[2] + (m1.M[2] - m0.M[2]) * f;
	result.M[3] := m0.M[3] + (m1.M[3] - m0.M[3]) * f;
end;

function Vec2DotMat2(const V : TVec2; const A : TMat2) : TVec2; {$I JAInline.inc}
begin
   Result.X := A._00*V.X + A._01*V.Y;
   Result.Y := A._10*V.X + A._11*V.Y;
end;

{-----------------------------------------------------------------Mat3 Routines}

{matrix transpose}
function Mat3Transpose(const A : TMat3) : TMat3; {$I JAInline.inc}
begin
   Result._00 := A._00;
   Result._01 := A._10;
   Result._02 := A._20;
   Result._10 := A._01;
   Result._11 := A._11;
   Result._12 := A._21;
   Result._20 := A._02;
   Result._21 := A._12;
   Result._22 := A._22;
end;

{matrix scale by float}
function Mat3ScaleFloat(const A : TMat3; const F : Float32) : TMat3; {$I JAInline.inc}
begin
   Result._00 := A._00 * F;
   Result._01 := A._01 * F;
   Result._02 := A._02 * F;
   Result._10 := A._10 * F;
   Result._11 := A._11 * F;
   Result._12 := A._12 * F;
   Result._20 := A._20 * F;
   Result._21 := A._21 * F;
   Result._22 := A._22 * F;
end;

{matrix muliplication}
function Mat3Multiply(const A, B : TMat3) : TMat3; {$I JAInline.inc}
{var
   M : array[0..23] of Float32; // not off by one, just wanted to match the index from the paper
begin
   m[1] := (A._00+A._01+A._02-A._10-A._11-A._21-A._22)*B._11;
   m[2] := (A._00-A._10)*(-B._01+B._11);
   m[3] := A._11*(-B._00+B._01+B._10-B._11-B._12-B._20+B._22);
   m[4] := (-A._00+A._10+A._11)*(B._00-B._01+B._11);
   m[5] := (A._10+A._11)*(-B._00+B._01);
   m[6] := A._00*B._00;
   m[7] := (-A._00+A._20+A._21)*(B._00-B._02+B._12);
   m[8] := (-A._00+A._20)*(B._02-B._12);
   m[9] := (A._20+A._21)*(-B._00+B._02);
   m[10]:= (A._00+A._01+A._02-A._11-A._12-A._20-A._21)*B._12;
   m[11]:= A._21*(-B._00+B._02+B._10-B._11-B._12-B._20+B._21);
   m[12]:= (-A._02+A._21+A._22)*(B._11+B._20-B._21);
   m[13]:= (A._02-A._22)*(B._11-B._21);
   m[14]:= A._02*B._20;
   m[15]:= (A._21+A._22)*(-B._20+B._21);
   m[16]:= (-A._02+A._11+A._12)*(B._12+B._20-B._22);
   m[17]:= (A._02-A._12)*(B._12-B._22);
   m[18]:= (A._11+A._12)*(-B._20+B._22);
   m[19]:= A._01*B._10;
   m[20]:= A._12*B._21;
   m[21]:= A._10*B._02;
   m[22]:= A._20*B._01;
   m[23]:= A._22*B._22;
   Result._00 := m[6]+m[14]+m[19];
   Result._01 := m[1]+m[4]+m[5]+m[6]+m[12]+m[14]+m[15];
   Result._02 := m[6]+m[7]+m[9]+m[10]+m[14]+m[16]+m[18];
   Result._10 := m[2]+m[3]+m[4]+m[6]+m[14]+m[16]+m[17];
   Result._11 := m[2]+m[4]+m[5]+m[6]+m[20];
   Result._12 := m[14]+m[16]+m[17]+m[18]+m[21];
   Result._20 := m[6]+m[7]+m[8]+m[11]+m[12]+m[13]+m[14];
   Result._21 := m[12]+m[13]+m[14]+m[15]+m[22];
   Result._22 := m[6]+m[7]+m[8]+m[9]+m[23];
}
begin
   Result._00 := A._00*B._00+A._01*B._10+A._02*B._20;
   Result._01 := A._00*B._01+A._01*B._11+A._02*B._21;
   Result._02 := A._00*B._02+A._01*B._12+A._02*B._22;
   Result._10 := A._10*B._00+A._11*B._10+A._12*B._20;
   Result._11 := A._10*B._01+A._11*B._11+A._12*B._21;
   Result._12 := A._10*B._02+A._11*B._12+A._12*B._22;
   Result._20 := A._20*B._00+A._21*B._10+A._22*B._20;
   Result._21 := A._20*B._01+A._21*B._11+A._22*B._21;
   Result._22 := A._20*B._02+A._21*B._12+A._22*B._22;
end;

function Mat3MultiplyLaderman(const A, B : TMat3) : TMat3; {$I JAInline.inc}
var
   M : array[0..23] of Float32; // not off by one, just wanted to match the index from the paper
begin
   m[1] := (A._00+A._01+A._02-A._10-A._11-A._21-A._22)*B._11;
   m[2] := (A._00-A._10)*(-B._01+B._11);
   m[3] := A._11*(-B._00+B._01+B._10-B._11-B._12-B._20+B._22);
   m[4] := (-A._00+A._10+A._11)*(B._00-B._01+B._11);
   m[5] := (A._10+A._11)*(-B._00+B._01);
   m[6] := A._00*B._00;
   m[7] := (-A._00+A._20+A._21)*(B._00-B._02+B._12);
   m[8] := (-A._00+A._20)*(B._02-B._12);
   m[9] := (A._20+A._21)*(-B._00+B._02);
   m[10]:= (A._00+A._01+A._02-A._11-A._12-A._20-A._21)*B._12;
   m[11]:= A._21*(-B._00+B._02+B._10-B._11-B._12-B._20+B._21);
   m[12]:= (-A._02+A._21+A._22)*(B._11+B._20-B._21);
   m[13]:= (A._02-A._22)*(B._11-B._21);
   m[14]:= A._02*B._20;
   m[15]:= (A._21+A._22)*(-B._20+B._21);
   m[16]:= (-A._02+A._11+A._12)*(B._12+B._20-B._22);
   m[17]:= (A._02-A._12)*(B._12-B._22);
   m[18]:= (A._11+A._12)*(-B._20+B._22);
   m[19]:= A._01*B._10;
   m[20]:= A._12*B._21;
   m[21]:= A._10*B._02;
   m[22]:= A._20*B._01;
   m[23]:= A._22*B._22;
   Result._00 := m[6]+m[14]+m[19];
   Result._01 := m[1]+m[4]+m[5]+m[6]+m[12]+m[14]+m[15];
   Result._02 := m[6]+m[7]+m[9]+m[10]+m[14]+m[16]+m[18];
   Result._10 := m[2]+m[3]+m[4]+m[6]+m[14]+m[16]+m[17];
   Result._11 := m[2]+m[4]+m[5]+m[6]+m[20];
   Result._12 := m[14]+m[16]+m[17]+m[18]+m[21];
   Result._20 := m[6]+m[7]+m[8]+m[11]+m[12]+m[13]+m[14];
   Result._21 := m[12]+m[13]+m[14]+m[15]+m[22];
   Result._22 := m[6]+m[7]+m[8]+m[9]+m[23];
end;

{vec2 multiply by non-affine mat3 (no translation)}
function Vec2DotMat3(const V : TVec2; const A : TMat3) : TVec2; {$I JAInline.inc}
begin
   Result.X := A._00*V.X + A._01*V.Y;
   Result.Y := A._10*V.X + A._11*V.Y;
end;

{vec2 multiply by affine mat3 (including translation)}
function Vec2DotMat3Affine(const V : TVec2; const A : TMat3) : TVec2; {$I JAInline.inc}
begin
   Result.X := A._00*V.X + A._01*V.Y + A._02;
   Result.Y := A._10*V.X + A._11*V.Y + A._12;
end;

{vec2 multiply by inverse of non-affine mat3 (effectively (optimized), input mat3 will be inverted, no translation)}
function Vec2DotInvMat3(const V : TVec2; const A : TMat3) : TVec2; {$I JAInline.inc}
var
   det : Float32;
begin
   Result.X := A._11*V.X - A._10*V.Y;
   Result.Y := -A._01*V.X + A._00*V.Y;
   {if matrix not singular and not orthonormal, then renormalize}
   det := A._00*A._11 - A._01*A._10;
   if ((det<>1.0) and (det <> 0.0))  then
   begin
      det := 1.0 / det;
      Result.X *= det;
      Result.Y *= det;
   end;
end;

{determinant of matrix}
function Mat3Determinant(const A : TMat3) : Float32; {$I JAInline.inc}
begin
   Result := A._00 * (A._11*A._22 - A._12 * A._21);
   Result -= A._01 * (A._10*A._22 - A._12 * A._20);
   Result += A._02 * (A._10*A._21 - A._11 * A._20);
end;

{adjoint of matrix (adjoint is just the transpose of the cofactor matrix)}
function Mat3Adjoint(const A : TMat3) : TMat3; {$I JAInline.inc}
begin
   Result._00 := A._11*A._22 - A._12*A._21;
   Result._10 := -(A._10*A._22 - A._20*A._12);
   Result._20 := A._10*A._21 - A._11*A._20;
   Result._01 := -(A._01*A._22 - A._02*A._21);
   Result._11 := A._00*A._22 - A._02*A._20;
   Result._21 := -(A._00*A._21 - A._01*A._20);
   Result._02 := A._01*A._12 - A._02*A._11;
   Result._12 := -(A._00*A._12 - A._02*A._10);
   Result._22 := A._00*A._11 - A._01*A._10;
end;

{adjoint of matrix with scale}
function Mat3AdjointScale(const A : TMat3; const F : Float32) : TMat3; {$I JAInline.inc}
begin
   Result._00 := (A._11 * A._22 - A._12 * A._21) * F;
   Result._10 := (A._12 * A._20 - A._10 * A._22) * F;
   Result._20 := (A._10 * A._21 - A._11 * A._20) * F;
   Result._01 := (A._02 * A._21 - A._01 * A._22) * F;
   Result._11 := (A._00 * A._22 - A._02 * A._20) * F;
   Result._21 := (A._01 * A._20 - A._00 * A._21) * F;
   Result._02 := (A._01 * A._12 - A._02 * A._11) * F;
   Result._12 := (A._02 * A._10 - A._00 * A._12) * F;
   Result._22 := (A._00 * A._11 - A._01 * A._10) * F;
end;

{inverse of matrix}
function Mat3Inverse(const A : TMat3) : TMat3; {$I JAInline.inc}
begin
   Result := Mat3AdjointScale(A, (1.0 / Mat3Determinant(A)));
   {DETERMINANT_3X3(det, a);
   tmp = 1.0 / (det);
   SCALE_ADJOINT_3X3(b, tmp, a);}
end;

function Mat3Translation(const V : TVec2) : TMat3; {$I JAInline.inc}
begin
   Result := Mat3Identity;
   Result._02 := V.X;
   Result._12 := V.Y;
end;

function Mat3Scale(const F : Float32) : TMat3; {$I JAInline.inc}
begin
   Result := Mat3Identity;
   Result._00 := F;
   Result._11 := F;
end;

{
function JM2DTranslation(const V: TVec2): TJMatrix;{$I jinline.inc}
begin
   Result := JMatrixIdentity;
   Result._41 := V.X;
   Result._42 := V.Y;
   Result._43 := 0;
end;

function JM2DScaling(const X, Y : JFloat): TJMatrix;{$I jinline.inc}
begin
   Result := JMatrixZero;
   Result._11 := X;
   Result._22 := Y;
   Result._33 := 1;
   Result._44 := 1;
end;

function JM2DRotationZ(A : JFloat):TJMatrix;{$I jinline.inc} {Around -Z axis}
var
   CA, SA : JFloat;
begin
   CA := Cos(A * JDegToRad);
   SA := Sin(A * JDegToRad);
   Result := JMatrixZero;
   Result._11 := CA;
   Result._12 := SA;
   Result._21 := -SA;
   Result._22 := CA;
   Result._33 := 1;
   Result._44 := 1;
end;
}

function Mat3Rotation(const F : Float32) : TMat3; {$I JAInline.inc}
var
   ACos, ASin : Float32;
begin
   ACos := Cos(F * JDegToRad);
   ASin := Sin(F * JDegToRad);
   Result := Mat3Identity;
   Result._00 := ACos;
   Result._10 := ASin;
   Result._01 := -ASin;
   Result._11 := ACos;
end;

{function JMTranslation(const V : TVec3):TJMatrix; {$I jinline.inc}
begin
	Result.M[0] := 1.0; Result.M[1] := 0.0; Result.M[2] := 0.0; Result.M[3] := 0.0;
	Result.M[4] := 0.0; Result.M[5] := 1.0; Result.M[6] := 0.0; Result.M[7] := 0.0;
	Result.M[8] := 0.0; Result.M[9] := 0.0; Result.M[10]:= 1.0; Result.M[11]:= 0.0;
	Result.M[12]:= V.x; Result.M[13]:= V.y; Result.M[14]:= V.z; Result.M[15]:= 1.0;
end;

function JMTranslation(const V: TVec2): TJMatrix;
begin
  Result.M[0] := 1.0; Result.M[1] := 0.0; Result.M[2] := 0.0; Result.M[3] := 0.0;
  Result.M[4] := 0.0; Result.M[5] := 1.0; Result.M[6] := 0.0; Result.M[7] := 0.0;
  Result.M[8] := 0.0; Result.M[9] := 0.0; Result.M[10]:= 1.0; Result.M[11]:= 0.0;
  Result.M[12]:= V.x; Result.M[13]:= V.y; Result.M[14]:= 0; Result.M[15]:= 1.0;
end;

function JMScaling(const X, Y, Z : JFloat):TJMatrix; {$I jinline.inc}
begin
	Result.M[0] := x; Result.M[1] := 0.0; Result.M[2] := 0.0; Result.M[3] := 0.0;
	Result.M[4] := 0.0; Result.M[5] := y; Result.M[6] := 0.0; Result.M[7] := 0.0;
	Result.M[8] := 0.0; Result.M[9] := 0.0; Result.M[10]:= z; Result.M[11]:= 0.0;
	Result.M[12]:= 0.0; Result.M[13]:= 0.0; Result.M[14]:= 0.0; Result.M[15]:= 1.0;
end;

function JMScaling(const V : TVec3):TJMatrix; {$I jinline.inc}
begin
	Result.M[0] := V.x; Result.M[1] := 0.0; Result.M[2] := 0.0; Result.M[3] := 0.0;
	Result.M[4] := 0.0; Result.M[5] := V.y; Result.M[6] := 0.0; Result.M[7] := 0.0;
	Result.M[8] := 0.0; Result.M[9] := 0.0; Result.M[10]:= V.z; Result.M[11]:= 0.0;
	Result.M[12]:= 0.0; Result.M[13]:= 0.0; Result.M[14]:= 0.0; Result.M[15]:= 1.0;
end;}

{
function JM2DMultiply(const A,B : TJMatrix):TJMatrix;  {$I JAInline.inc}
Begin
   Result.M[0 ]:= A.M[ 0] * B.M[ 0] + A.M[ 4] * B.M[ 1] + A.M[ 8] * B.M[2];
   Result.M[1 ]:= A.M[ 1] * B.M[ 0] + A.M[ 5] * B.M[ 1] + A.M[ 9] * B.M[2];
   Result.M[2 ]:= A.M[ 2] * B.M[ 0] + A.M[ 6] * B.M[ 1] + A.M[10] * B.M[2];
   Result.M[3 ]:= 0;
   Result.M[4 ]:= A.M[ 0] * B.M[ 4] + A.M[ 4] * B.M[5] + A.M[8 ] * B.M[6];
   Result.M[5 ]:= A.M[ 1] * B.M[ 4] + A.M[ 5] * B.M[5] + A.M[9 ] * B.M[6];
   Result.M[6 ]:= A.M[ 2] * B.M[ 4] + A.M[ 6] * B.M[5] + A.M[10] * B.M[6];
   Result.M[7 ]:= 0;
   Result.M[8 ]:= A.M[ 0] * B.M[ 8] + A.M[ 4] * B.M[ 9] + A.M[ 8] * B.M[10];
   Result.M[9 ]:= A.M[ 1] * B.M[ 8] + A.M[ 5] * B.M[ 9] + A.M[ 9] * B.M[10];
   Result.M[10]:= A.M[ 2] * B.M[ 8] + A.M[ 6] * B.M[ 9] + A.M[10] * B.M[10];
   Result.M[11]:= 0;
   Result.M[12]:= A.M[ 0] * B.M[12] + A.M[ 4] * B.M[13] + A.M[ 8] * B.M[14] + A.M[12];
   Result.M[13]:= A.M[ 1] * B.M[12] + A.M[ 5] * B.M[13] + A.M[ 9] * B.M[14] + A.M[13];
   Result.M[14]:= A.M[ 2] * B.M[12] + A.M[ 6] * B.M[13] + A.M[10] * B.M[14] + A.M[14];
   Result.M[15]:= 1;
end;

function JM2DTranslation(const X, Y : Float32): TJMatrix; {$I JAInline.inc}
begin
   Result := JMatrixIdentity;
   Result._41 := X;
   Result._42 := Y;
   Result._43 := 0;
end;

function JM2DTranslation(const V: TVec2): TJMatrix; {$I JAInline.inc}
begin
   Result := JMatrixIdentity;
   Result._41 := V.X;
   Result._42 := V.Y;
   Result._43 := 0;
end;

function JM2DScaling(const X, Y : Float32): TJMatrix; {$I JAInline.inc}
begin
   Result := JMatrixZero;
   Result._11 := X;
   Result._22 := Y;
   Result._33 := 1;
   Result._44 := 1;
end;

function JM2DRotationZ(A : Float32):TJMatrix; {$I JAInline.inc} {Around -Z axis}
var
   CA, SA : Float32;
begin
   CA := Cos(A * JDegToRad);
   SA := Sin(A * JDegToRad);
   Result := JMatrixZero;
   Result._11 := CA;
   Result._12 := SA;
   Result._21 := -SA;
   Result._22 := CA;
   Result._33 := 1;
   Result._44 := 1;
end;
}

{--------------------------------------------------------------- JRect Routines}

function JRectIntersectCircle(AOrigin : TVec2; ARadius : Float32; ARect : TJRectSInt16): Boolean; {$I JAInline.inc} overload;
begin
   Result :=
      ((AOrigin.X + ARadius) > ARect.Left) and ((AOrigin.X - ARadius) < ARect.Right) and
      ((AOrigin.Y + ARadius) > ARect.Top) and ((AOrigin.Y - ARadius) < ARect.Bottom);
end;

function JRectIntersectVertex(AOrigin : TVec2; ARect : TJRectSInt16): Boolean; {$I JAInline.inc} overload;
begin
   Result :=
         ((AOrigin.X) > ARect.Left) and ((AOrigin.X) < ARect.Right) and
         ((AOrigin.Y) > ARect.Top) and ((AOrigin.Y) < ARect.Bottom);
end;

function JRectIntersectLine(A,B : TVec2; ARect : TJRectSInt16) : Boolean; {$I JAInline.inc} overload;
begin
   Result := JLineIntersectLine(A, B, Vec2(ARect.Left,ARect.Top), Vec2(ARect.Right,ARect.Top)) or
      JLineIntersectLine(A, B, Vec2(ARect.Left,ARect.Bottom), Vec2(ARect.Right,ARect.Bottom)) or
      JLineIntersectLine(A, B, Vec2(ARect.Left,ARect.Top), Vec2(ARect.Left,ARect.Bottom)) or
      JLineIntersectLine(A, B, Vec2(ARect.Right,ARect.Top), Vec2(ARect.Right,ARect.Bottom));
end;

{--------------------------------------------------------------- JLine Routines}

function JLineIntersectLine(p1, q1, p2, q2 : TVec2) : boolean;
var
   o1,o2,o3,o4 : SInt32;

   function onSegment(p, q, r : TVec2) : boolean;
   begin
      Result := (q.x <= max(p.x, r.x)) and (q.x >= min(p.x, r.x)) and (q.y <= max(p.y, r.y)) and (q.y >= min(p.y, r.y));
   end;

   function orientation(p, q, r : TVec2) : SInt32;
   var
      Val : Float32;
   begin
       Val := (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
       if (Val = 0) then exit(0); {colinear}
       if (Val > 0) then Result := 1 else Result := 2;  // clock or counterclock wise
   end;

begin
    Result := false;
    // Find the four orientations needed for general and special cases
    o1 := orientation(p1, q1, p2);
    o2 := orientation(p1, q1, q2);
    o3 := orientation(p2, q2, p1);
    o4 := orientation(p2, q2, q1);

    // General case
    if (o1 <> o2) and (o3 <> o4) then exit(true);

    // Special Cases
    // p1, q1 and p2 are colinear and p2 lies on segment p1q1
    if (o1 = 0) and onSegment(p1, p2, q1) then exit(true);

    // p1, q1 and q2 are colinear and q2 lies on segment p1q1
    if (o2 = 0) and onSegment(p1, q2, q1) then exit(true);

    // p2, q2 and p1 are colinear and p1 lies on segment p2q2
    if (o3 = 0) and onSegment(p2, p1, q2) then exit(true);

     // p2, q2 and q1 are colinear and q1 lies on segment p2q2
    if (o4 = 0) and onSegment(p2, q1, q2) then exit(true);
end;
      {
function LineLineIntersect(a1, a2, b3, b4 : TVec2; var iOut : TVec2) : boolean;

  function Slope(const a1, a2 : TVec2): Double;
  const
    SlopeVertical = 9999999999;
    //SlopeHorizontal = 0;
  begin
      if a1.X = a2.X then
        Result := SlopeVertical
      else
        Result := (a2.Y - a1.Y) / (a2.X - a1.X);
    if Abs(Result) >= SlopeVertical then
      Result := SlopeVertical;
  end;

  function HasLength(const a1, a2 : TVec2) : Boolean;
  begin
      Result := (a1.X <> a2.X) or (a1.Y <> a2.Y);
  end;

  function PointWithinLine(const APoint: TVec2; const A1, A2 : TVec2): Boolean;
  begin
      Result := (APoint.X >= JMin(a1.X, a2.X)) and (APoint.X <= JMax(a1.X, a2.X)) and
                (APoint.Y >= JMin(a1.Y, a2.Y)) and (APoint.Y <= JMax(a1.Y, a2.Y));
  end;

var
  Slope1: Double;
  Slope2: Double;
  Offset1: Double;
  Offset2: Double;
  IntersectX: Double;
  IntersectY: Double;
begin
  {if not (HasLength(a1, a2) and HasLength(b3, b4)) then
  begin
     exit(false);
  end;
  }
  Slope1 := Slope(a1, a2);
  Slope2 := Slope(b3, b4);
  if Slope1 = Slope2 then
  begin
    exit(false);
  end;
  Offset1 := a1.Y - (Slope1 * a1.X); //see formula 2 above
  Offset2 := b3.Y - (Slope2 * b3.X);
  IntersectX := (Offset2 - Offset1) / (Slope1 - Slope2); //see formula 3 above
  IntersectY := (Slope1 * IntersectX) + Offset1; //see formula 1 above

  iOut.X := IntersectX;
  iOut.Y := IntersectY;


  if PointWithinLine(iOut, A1, A2) and PointWithinLine(iOut, B3, B4) then
    exit(true)
  else
    exit(false);
end; }

{
function LineLineIntersect(a1, a2, b3, b4 : TVec2; var iOut : TVec2) : boolean;
var
	detL1 : Float32;
	detL2 : Float32;
	x1mx2 : Float32;
	x3mx4 : Float32;
	y1my2 : Float32;
	y3my4 : Float32;
	xnom : Float32;
	ynom : Float32;
	denom : Float32;

   function Det(a,b,c,d : Float32) : Float32;
   begin
	   Result := (a*d) - (b*c);
   end;

begin
	detL1 := Det(a1.x, a1.y, a2.x, a2.y);
	detL2 := Det(b3.x, b3.y, b4.x, b4.y);
	x1mx2 := a1.x - a2.x;
	x3mx4 := b3.x - b4.x;
	y1my2 := a1.y - a2.y;
	y3my4 := b3.y - b4.y;

	xnom := Det(detL1, x1mx2, detL2, x3mx4);
	ynom := Det(detL1, y1my2, detL2, y3my4);
	denom := Det(x1mx2, y1my2, x3mx4, y3my4);

    if(denom = 0.0) then
    begin {Lines don't cross}
		iOut.x := 0;
		iOut.y := 0;
		exit(false);
   end;

	iOut.x := xnom / denom;
	iOut.y := ynom / denom;

	Result := true;
end;  }

function LineLineIntersect(A, B, C, D : TVec2; var iOut : TVec2) : boolean;
var
    a1,b1,c1,a2,b2,c2 : Float32;
    determinant : Float32;

   function PointWithinLine(const APoint: TVec2; const A1, A2 : TVec2): Boolean;
   begin
      Result := (APoint.X >= JMin(a1.X, a2.X)) and (APoint.X <= JMax(a1.X, a2.X)) and
                (APoint.Y >= JMin(a1.Y, a2.Y)) and (APoint.Y <= JMax(a1.Y, a2.Y));
   end;

begin
   // Line AB represented as a1x + b1y = c1
   a1 := B.y - A.y;
   b1 := A.x - B.x;
   c1 := a1*(A.x) + b1*(A.y);

   // Line CD represented as a2x + b2y = c2
   a2 := D.y - C.y;
   b2 := C.x - D.x;
   c2 := a2*(C.x)+ b2*(C.y);

   determinant := a1*b2 - a2*b1;

   if (determinant <> 0) then
   begin
      iOut.x := ((b2*c1 - b1*c2)/determinant);
      iOut.y := ((a1*c2 - a2*c1)/determinant);
      Result := PointWithinLine(iOut, A, B) and PointWithinLine(iOut, C, D);
      //Result := true;
   end else
   begin
     iOut := B;
     Result := false;
   end;
end;

function JRectSideClipping(SideA,SideB : TJRectSide; ClipRect : TJRect; var AVec1,AVec2 : TVec2; var AVecCount : SInt16) : boolean;
begin
   Result := false;
   {Fill in any missing area from the now clipped shadow volume}
   if ((SideA=JRect_Right) and (SideB=JRect_Left)) then
   begin
      AVecCount := 2;
      AVec1 := Vec2(ClipRect.Left, ClipRect.Top);
      AVec2 := Vec2(ClipRect.Right, ClipRect.Top);
      exit(true);
   end else
   if ((SideA=JRect_Left) and (SideB=JRect_Right)) then
   begin
      AVecCount := 2;
      AVec1 := Vec2(ClipRect.Right, ClipRect.Bottom);
      AVec2 := Vec2(ClipRect.Left, ClipRect.Bottom);
      exit(true);
   end else
   if ((SideA=JRect_Top) and (SideB=JRect_Bottom)) then
   begin
      AVecCount := 2;
      AVec1 := Vec2(ClipRect.Left, ClipRect.Bottom);
      AVec2 := Vec2(ClipRect.Left, ClipRect.Top);
      exit(true);
   end else
   if ((SideA=JRect_Bottom) and (SideB=JRect_Top)) then
   begin
      AVecCount := 2;
      AVec1 := Vec2(ClipRect.Right, ClipRect.Top);
      AVec2 := Vec2(ClipRect.Right, ClipRect.Bottom);
      exit(true);
   end else
   if not (SideA = SideB) then
   begin {Shadow crosses a corner - insert one corner point}
      AVecCount := 1;
      case SideA of
         JRect_Left : AVec1.X := ClipRect.Left;
         JRect_Right : AVec1.X := ClipRect.Right;
         JRect_Top : AVec1.Y := ClipRect.Top;
         JRect_Bottom : AVec1.Y := ClipRect.Bottom;
      end;
      case SideB of
         JRect_Left : AVec1.X := ClipRect.Left;
         JRect_Right : AVec1.X := ClipRect.Right;
         JRect_Top : AVec1.Y := ClipRect.Top;
         JRect_Bottom : AVec1.Y := ClipRect.Bottom;
      end;
      exit(true);
   end;
end;

function JRectIntersectLineResult(ALine0 : TVec2SInt16; ALine1 : TVec2; var ARect : TJRectSInt16; var AResultSide : TJRectSide; var AResultVertex : TVec2) : boolean;
begin
   Result := false;
   if LineLineIntersect(ALine0, ALine1, Vec2(ARect.Left,ARect.Top), Vec2(ARect.Left,ARect.Bottom), AResultVertex) then
   begin
      AResultSide := JRect_Left;
      Result := true;
   end else
   if LineLineIntersect(ALine0, ALine1, Vec2(ARect.Right, ARect.Top), Vec2(ARect.Right, ARect.Bottom), AResultVertex) then
   begin
      AResultSide := JRect_Right;
      Result := true;
   end else
   if LineLineIntersect(ALine0, ALine1, Vec2(ARect.Left, ARect.Top), Vec2(ARect.Right, ARect.Top), AResultVertex) then
   begin
      AResultSide := JRect_Top;
      Result := true;
   end else
   if LineLineIntersect(ALine0, ALine1, Vec2(ARect.Left, ARect.Bottom), Vec2(ARect.Right, ARect.Bottom), AResultVertex) then
   begin
      AResultSide := JRect_Bottom;
      Result := true;
   end;
end;

(*

function JRectContain(const P: TVec2; const R: TJRect): Boolean; {$I JAInline.inc}
begin
   Result :=
   (P.X >= R.Left  ) and
   (P.X <= R.Right ) and
   (P.Y >= R.Top   ) and
   (P.Y <= R.Bottom);
end;

function JRectContain(const P: TVec2I; const R: TJRect): Boolean; {$I JAInline.inc}
begin
   Result :=
   (P.X >= R.Left  ) and
   (P.X <= R.Right ) and
   (P.Y >= R.Top   ) and
   (P.Y <= R.Bottom);
end;

function JRectContain(const A, B: TJRect): Boolean; {$I JAInline.inc}
begin
   Result :=
   (A.Left   >= B.Left  ) and
   (A.Right  <= B.Right ) and
   (A.Top    >= B.Top   ) and
   (A.Bottom <= B.Bottom);
end;


function JRectOverlap(const A, B: TJRect): Boolean; {$I JAInline.inc}
begin
   Result :=
   (A.Left   < B.Right ) and
   (A.Right  > B.Left  ) and
   (A.Top    < B.Bottom) and
   (A.Bottom > B.Top   );
end;

function JRectOverlap(const A, B: TJRect; OffSetB: TVec2): Boolean; {$I JAInline.inc}
begin
   Result :=
   (A.Left   < OffSetB.X + B.Right ) and
   (A.Right  > OffSetB.X + B.Left  ) and
   (A.Top    < OffSetB.Y + B.Bottom) and
   (A.Bottom > OffSetB.Y + B.Top   );
end;

function JRectOverlap(const A, B: TJRect; OffsetA, OffSetB: TVec2): Boolean; {$I JAInline.inc}
begin
   Result :=
   (OffsetA.X + A.Left   < OffSetB.X + B.Right ) and
   (OffsetA.X + A.Right  > OffSetB.X + B.Left  ) and
   (OffsetA.Y + A.Top    < OffSetB.Y + B.Bottom) and
   (OffsetA.Y + A.Bottom > OffSetB.Y + B.Top   );
end;

function JRectTranslate(const R: TJRect; const V: TVec2): TJRect; {$I JAInline.inc}
begin
   Result.Top := R.Top + V.Y;
   Result.Bottom := R.Bottom + V.Y;
   Result.Left := R.Left + V.X;
   Result.Right := R.Right + V.X;
end;

function JRectTranslate(const R: TJRect; const X,Y : Float32): TJRect; {$I JAInline.inc}
begin
   Result.Top := R.Top + Y;
   Result.Bottom := R.Bottom + Y;
   Result.Left := R.Left + X;
   Result.Right := R.Right + X;
end;

function JRectScale(const R: TJRect; const F: Float32): TJRect; {$I JAInline.inc}
begin
   Result.Top := R.Top * F;
   Result.Bottom := R.Bottom * F;
   Result.Left := R.Left * F;
   Result.Right := R.Right * F;
end;

function JRectScale(const R: TJRect; const X,Y : Float32): TJRect; {$I JAInline.inc}
begin
   Result.Top := R.Top * Y;
   Result.Bottom := R.Bottom * Y;
   Result.Left := R.Left * X;
   Result.Right := R.Right * X;
end;

function JRectTransform(const R: TJRect; const M: TJMatrix): TJRect;
var
   V: Array[0..1] of TVec2;
begin
   V[0].X:= R.Left;
   V[0].Y:= R.Top;
   V[1].X:= R.Right;
   V[1].Y:= R.Bottom;
   V[0]:= Vec2Transform(V[0], M);
   V[1]:= Vec2Transform(V[1], M);
   Result.Left  := V[0].X;
   Result.Top   := V[0].Y;
   Result.Right := V[1].X;
   Result.Bottom:= V[1].Y;
end;

function JRectInvTransform(const R: TJRect; const M: TJMatrix): TJRect; {$I JAInline.inc}
begin
   Result.LT := Vec2InvTransform(R.LT, M);
   Result.RB := Vec2InvTransform(R.RB, M);
end;

function JRectRandomVec2(const ARect : TJRect):TVec2; {$I JAInline.inc}
var
   FWidth,FHeight : Float32;
begin
   FWidth := (abs(ARect.Left)+ARect.right);
   FHeight := (abs(ARect.Top)+ARect.bottom);
   Result.X := ARect.Left + (FWidth * random);
   Result.Y := Arect.top + (FHeight * random);
end;

function JRectClip(const A, B: TJRect): TJRect;
begin
   Result.Left := JMin(A.Left,B.Left);
   Result.Right := JMax(A.Right,B.Right);
   Result.Top := JMin(A.Top,B.Top);
   Result.Bottom := JMax(A.Bottom, B.Bottom);
end;

{--------------------------------------------------------------- JRectI Routines}

function JRectIContain(const P: TVec2; const R: TJRectI): Boolean; {$I JAInline.inc}
begin
   Result :=
   (P.X >= R.Left  ) and
   (P.X <= R.Right ) and
   (P.Y >= R.Top   ) and
   (P.Y <= R.Bottom);
end;

function JRectIContain(const P: TVec2I; const R: TJRectI): Boolean; {$I JAInline.inc}
begin
   Result :=
   (P.X >= R.Left  ) and
   (P.X <= R.Right ) and
   (P.Y >= R.Top   ) and
   (P.Y <= R.Bottom);
end;

function JRectIContain(const A, B: TJRectI): Boolean; {$I JAInline.inc}
begin
   Result :=
   (A.Left   >= B.Left  ) and
   (A.Right  <= B.Right ) and
   (A.Top    >= B.Top   ) and
   (A.Bottom <= B.Bottom);
end;


function JRectIOverlap(const A, B: TJRectI): Boolean; {$I JAInline.inc}
begin
   Result :=
   (A.Left   < B.Right ) and
   (A.Right  > B.Left  ) and
   (A.Top    < B.Bottom) and
   (A.Bottom > B.Top   );
end;

function JRectIOverlap(const A, B: TJRectI; OffSetB: TVec2I): Boolean; {$I JAInline.inc}
begin
   Result :=
   (A.Left   < OffSetB.X + B.Right ) and
   (A.Right  > OffSetB.X + B.Left  ) and
   (A.Top    < OffSetB.Y + B.Bottom) and
   (A.Bottom > OffSetB.Y + B.Top   );
end;

function JRectIOverlap(const A, B: TJRectI; OffsetA, OffSetB: TVec2I): Boolean; {$I JAInline.inc}
begin
   Result :=
   (OffsetA.X + A.Left   < OffSetB.X + B.Right ) and
   (OffsetA.X + A.Right  > OffSetB.X + B.Left  ) and
   (OffsetA.Y + A.Top    < OffSetB.Y + B.Bottom) and
   (OffsetA.Y + A.Bottom > OffSetB.Y + B.Top   );
end;

function JRectITranslate(const R: TJRectI; const V: TVec2I): TJRectI; {$I JAInline.inc}
begin
   Result.Top := R.Top + V.Y;
   Result.Bottom := R.Bottom + V.Y;
   Result.Left := R.Left + V.X;
   Result.Right := R.Right + V.X;
end;

function JRectITranslate(const R: TJRectI; const X,Y : SInt32): TJRectI; {$I JAInline.inc}
begin
   Result.Top := R.Top + Y;
   Result.Bottom := R.Bottom + Y;
   Result.Left := R.Left + X;
   Result.Right := R.Right + X;
end;

function JRectIScale(const R: TJRectI; const F: SInt32): TJRectI; {$I JAInline.inc}
begin
   Result.Top := R.Top * F;
   Result.Bottom := R.Bottom * F;
   Result.Left := R.Left * F;
   Result.Right := R.Right * F;
end;

function JRectIScale(const R: TJRectI; const X,Y : SInt32): TJRectI; {$I JAInline.inc}
begin
   Result.Top := R.Top * Y;
   Result.Bottom := R.Bottom * Y;
   Result.Left := R.Left * X;
   Result.Right := R.Right * X;
end;

function JRectITransform(const R: TJRectI; const M: TJMatrix): TJRectI; {$I JAInline.inc}
var
   V: Array[0..1] of TVec2;
begin
   V[0].X:= R.Left;
   V[0].Y:= R.Top;
   V[1].X:= R.Right;
   V[1].Y:= R.Bottom;
   V[0]:= Vec2Transform(V[0], M);
   V[1]:= Vec2Transform(V[1], M);
   Result.Left  := trunc(V[0].X);
   Result.Top   := trunc(V[0].Y);
   Result.Right := trunc(V[1].X);
   Result.Bottom:= trunc(V[1].Y);
end;

function JRectIInvTransform(const R: TJRectI; const M: TJMatrix): TJRectI; {$I JAInline.inc}
var
   ARect : TJRect;
begin
   ARect.Left := R.Left;
   ARect.Right := R.Right;
   ARect.Top := R.Top;
   ARect.Bottom := R.Bottom;
   ARect.LT := Vec2InvTransform(ARect.LT, M);
   ARect.RB := Vec2InvTransform(ARect.RB, M);
   Result.Left := trunc(ARect.Left);
   Result.Right := trunc(ARect.Right);
   Result.Top := trunc(ARect.Top);
   Result.Bottom := trunc(ARect.Bottom);

end;

function JRectIRandomVec2I(const ARect : TJRectI):TVec2I; {$I JAInline.inc}
var
   FWidth,FHeight : SInt32;
begin
   FWidth := (abs(ARect.Left)+ARect.right);
   FHeight := (abs(ARect.Top)+ARect.bottom);
   Result.X := trunc(ARect.Left + (FWidth * random));
   Result.Y := trunc(Arect.top + (FHeight * random));
end;

function JRectIClip(const A, B: TJRectI): TJRectI;
begin
  Result.Left := JMax(A.Left,B.Left);
  Result.Right := JMin(A.Right,B.Right);
  Result.Top := JMax(A.Top,B.Top);
  Result.Bottom := JMin(A.Bottom, B.Bottom);
end;




{--------------------------------------------------------------- TJRay Routines}

function JRayVector(const R : TJRay):TVec3; {$I JAInline.inc}
begin
   Result := R.Origin + R.Vector;
end;

function JRayPick(const ScreenV : TVec2I; const Width, Height : Float32; const Projection, ModelView : TJMatrix):TJRay;
var
   IVM : TJMatrix;
   V : TVec3;
begin
   // Compute the vector of the pick ray in screen space
   V.X := -(((2.0*(ScreenV.X))/Width)-1) / Projection._11;
   V.Y := (((2.0*ScreenV.Y)/Height)-1) / Projection._22;
   V.Z := 1;

   // Get the inverse view matrix
   IVM := JMInverse(ModelView);
   // Transform the screen space pick ray into 3D space
   Result.Vector.x := V.x*IVM._11+V.y*IVM._21+V.z*IVM._31;
   Result.Vector.y := V.x*IVM._12+V.y*IVM._22+V.z*IVM._32;
   Result.Vector.z := V.x*IVM._13+V.y*IVM._23+V.z*IVM._33;
   Result.Vector := -Vec3Normalize(Result.Vector);
   Result.Origin.x := IVM._41;
   Result.Origin.y := IVM._42;
   Result.Origin.z := IVM._43;
End;

{
   Return value:
   0 : no intersection, line parallel to plane
   1 : res is valid
   -1 : line is inside plane
}

function JRayIntersectPlane(const R : TJRay; const P : TJPlane; const Intersection : PVec3 = nil) : SInt32;
var
   A, B : Float32;
   T : Float32;
begin
   A := Vec3Dot(P.XYZ, R.Vector);  // direction projected to plane normal
   B := P.X*R.Origin.X+P.Y*R.Origin.Y+P.Z*R.Origin.Z+P.W;
   if ( A = 0) then
   begin          // direction is parallel to plane
      if (B = 0) then
      Result:=-1           // line is inside plane
      else Result:=0;         // line is outside plane
   end else
   begin
      if Assigned(Intersection) then begin
         T := B/A; // parameter of intersection
         if T < 0 then Intersection^ := R.Origin + (-R.Vector * T);
      end;
      Result:=1;
   end;
end;


function JRayIntersectXZPlane(const R : TJRay; const PlaneY : Float32; const Intersection : PVec3 = nil) : Boolean;
var
   T : Float32;
begin

  //Result := JRayIntersectPlane(R,JPlane(vec3(0,PlaneY,0),vec3(0,1,0)),Intersection)=1;
   if (R.Vector.Y = 0) then Result := False else
   begin
      T := (R.Origin.Y-PlaneY)/R.Vector.Y;
      if (T < 0) then
      begin
         if Assigned(Intersection) then
         begin
            Intersection^ := R.Origin + (-R.Vector * T);
         end;
         Result:=True;
      end else Result := False;
   end;
end;

function JRayDistance(const R : TJRay;const V : TVec3):Float32;
var
   Proj : Float32;
begin
   Proj := (R.Vector.X*(V.X-R.Origin.X)+R.Vector.Y*(V.Y-R.Origin.Y)+R.Vector.Z*(V.Z-R.Origin.Z));
   if Proj <= 0 then Proj := 0; // rays don't go backward
   Result := Vec3Distance(V, R.Origin + (R.Vector * Proj));
end;

function JRayIntersectTriangle(const ARay : TJRay; const ATri : TJTriangle3; const Intersection : PVec3=nil; IntersectionNormal : PVec3=nil) : boolean;
var
   pvec : TVec3;
   v1, v2, qvec, tvec : TVec3;
   t, u, v, det, invDet : Float32;
begin
   v1 := ATri.B - ATri.A;
   v2 := ATri.C - ATri.A;
   pvec := Vec3Cross(ARay.Vector,v2);
   det := Vec3Dot(v1, pvec);

   if ((det < JEpsilon2) and (det > -JEpsilon2)) then
   begin // vector is parallel to triangle's plane
      Result:=False;
      Exit;
   end;
   invDet := 1.0 / det;
   tvec := ARay.Origin - ATri.A;
   u := Vec3Dot(tvec,pvec)*invDet;

   if (u < 0) or (u > 1) then Result:=False else
   begin
      qvec := Vec3Cross(tvec,v1);
      v := Vec3Dot(ARay.Vector, qvec)*invDet;
      Result := (v >= 0) and (u+v <= 1);
      if Result then
      begin
         t := Vec3Dot(v2, qvec)*invDet;
         if t>0 then
         begin
            if Intersection<>nil then
            Intersection^ := ARay.Origin + (ARay.Vector * t);
            if IntersectionNormal<>nil then
            IntersectionNormal^ := Vec3Cross(v1,v2);
         end else Result:=False;
      end;
   end;
end;

function JRayIntersectSphere(const ARay : TJRay; const ASphere : TJSphere; const IntersectionA : PVec3; IntersectionB : PVec3) : SInt32;
var
   proj, d2 : Float32;
   id2 : SInt32;
   projPoint : TVec3;
begin
   proj :=  ARay.Vector.X*(ASphere.Origin.X-ARay.Origin.X)+
            Aray.Vector.Y*(ASphere.Origin.Y-ARay.Origin.Y)+
            Aray.Vector.Z*(ASphere.Origin.Z-ARay.Origin.Z);

   projPoint := ARay.Origin + (ARay.Vector * proj);
   d2 := (ASphere.Radius*ASphere.Radius)-Vec3Distance2(ASphere.Origin, projPoint);
   id2 := floor(d2);

   if id2 >= 0 then
   begin
      if id2 = 0 then
      begin
         if floor(proj) > 0 then
         begin
            IntersectionA^ := projPoint;
            Result := 1;
            Exit;
         end;
      end else if id2 > 0 then
      begin
         d2:=Sqrt(d2);
         if proj >= d2 then
         begin
            IntersectionA^ := ARay.Origin + (ARay.Vector * (proj-d2));
            IntersectionB^ := ARay.Origin + (ARay.Vector * (proj+d2));
            Result:=2;
            Exit;
         end else if proj+d2 >= 0 then
         begin
            IntersectionA^ := ARay.Origin + (ARay.Vector * (proj+d2));
            Result:=1;
            Exit;
         end;
      end;
   end;
   Result:=0;
end;

function JRayIntersectSphere(const ARay : TJRay; const ASphere : TJSphere) : boolean;
var
   proj : Float32;
begin
   proj :=  ARay.Vector.X*(ASphere.Origin.X-ARay.Origin.X)+
            Aray.Vector.Y*(ASphere.Origin.Y-ARay.Origin.Y)+
            Aray.Vector.Z*(ASphere.Origin.Z-ARAy.Origin.Z);
   if proj <= 0 then proj := 0; // rays don't go backward
   Result := (Vec3Distance2(ASphere.Origin, ARay.Origin + (ARay.Vector * proj)) <= Sqr(ASphere.Radius));
end;

function JRayIntersectBBox(const ARay : TJRay; const BBox : TJBBox; const Intersection : PVec3=nil):boolean;
var
   i, planeInd : SInt32;
   ResAFV, MaxDist, Plane : TVec3;
   isMiddle : array [0..2] of Boolean;
begin
   // Find plane.
   Result := True;
   for i := 0 to 2 do
   if ARay.Origin.V[i] < BBox.Min.V[i] then
   begin
      Plane.V[i] := BBox.Min.V[i];
      isMiddle[i] := False;
      Result := False;
   end else if ARay.Origin.V[i] > BBox.Max.V[i] then
   begin
      Plane.V[i] := BBox.Max.V[i];
      isMiddle[i] := False;
      Result := False;
   end else
   begin
      isMiddle[i] := True;
   end;
   if Result then
   begin
      // rayStart inside box.
      if Intersection <> nil
      then Intersection^ := ARay.Origin;
	end else
   begin
      // Distance to plane.
      planeInd := 0;
      for i := 0 to 2 do
      if isMiddle[i] or (ARay.Vector.V[i] = 0) then MaxDist.V[i] := -1 else
      begin
         MaxDist.V[i] := (Plane.V[i] -Aray.Origin.V[i]) / ARay.Vector.V[i];
         if MaxDist.V[i] > 0 then
         begin
            if MaxDist.V[planeInd] < MaxDist.V[i] then planeInd := i;
            Result := True;
         end;
      end;
      // Inside box?
      if Result then
      begin
         for i := 0 to 2 do
         if planeInd = i then ResAFV.V[i] := Plane.V[i] else
         begin
            ResAFV.V[i] := ARay.Origin.V[i] +MaxDist.V[planeInd] *Aray.Vector.V[i];
            Result := (ResAFV.V[i] >= BBox.Min.V[i]) and (ResAFV.V[i] <= BBox.Max.V[i]);
            if not Result then exit;
         end;
         if Intersection <> nil then Intersection^ := ResAFV;
      end;
   end;
end;

{------------------------------------------------------------ TJSphere Routines}

function JSphereVisibleRadius(const Distance, Radius : Float32) : Float32;
var
   d2, r2, ir, tr : Float32;
begin
   d2 := distance*distance;
   r2 := radius*radius;
   ir := Sqrt(d2-r2);
   tr := (d2+r2-Sqr(ir))/(2*ir);
   Result := Sqrt(r2+Sqr(tr));
end;

function JSphereToBBox(const ASphere : TJSphere) : TJBBox;
begin
   Result.min := ASphere.Origin - ASphere.Radius;
   Result.max := ASphere.Origin + ASphere.Radius;
end;

function JSphereContain(const ASphere: TJSphere; const AVertex: TVec3): boolean;
begin
   Result := Vec3Distance(ASphere.Origin,AVertex) < ASphere.Radius;
end;

function JSphereContain(const ASphere: TJSphere; const BSphere: TJSphere): boolean;
begin
  Result := JSphereIntersect(ASphere, BSphere)=J_INTERSECTFULL;
end;

function JSphereContain(const ASphere: TJSphere; const ABBox: TJBBox): boolean;
begin
   Result := JSphereIntersect(ASphere, ABBox)=J_INTERSECTFULL;
end;

function JSphereIntersect(const ASphere: TJSphere; const BSphere: TJSphere): TJIntersectResult;
var
  d2 : Float32;
begin
   d2 := Vec3Distance2(ASphere.Origin, BSphere.Origin);
   if d2 < sqr(ASphere.Radius+BSphere.Radius) then
   begin
      if d2 < sqr(ASphere.Radius-BSphere.Radius) then result := J_INTERSECTFULL else result := J_INTERSECTPARTIAL;
   end else result := J_INTERSECTFAIL;
end;

function JSphereIntersect(const ASphere: TJSphere; const ABBox: TJBBox): TJIntersectResult;
var
  r2: Float32;
  ClippedCenter : TVec3;
  BBoxCorners : TJBBoxCorners;
  CornerHitCount : SInt32;
begin
   r2 := sqr(ASphere.Radius);
   ClippedCenter := Vec3Clip(ASphere.Origin, ABBox);
   if Vec3Distance2(ClippedCenter, ASphere.Origin) < r2 then
   begin
      BBoxCorners := JBBoxExtractCorners(ABBox);
      CornerHitCount := 0;
      if (Vec3Distance2(ASphere.Origin, BBoxCorners[0]) < r2) then inc(CornerHitCount);
      if (Vec3Distance2(ASphere.Origin, BBoxCorners[1]) < r2) then inc(CornerHitCount);
      if (Vec3Distance2(ASphere.Origin, BBoxCorners[2]) < r2) then inc(CornerHitCount);
      if (Vec3Distance2(ASphere.Origin, BBoxCorners[3]) < r2) then inc(CornerHitCount);
      if (Vec3Distance2(ASphere.Origin, BBoxCorners[4]) < r2) then inc(CornerHitCount);
      if (Vec3Distance2(ASphere.Origin, BBoxCorners[5]) < r2) then inc(CornerHitCount);
      if (Vec3Distance2(ASphere.Origin, BBoxCorners[6]) < r2) then inc(CornerHitCount);
      if (Vec3Distance2(ASphere.Origin, BBoxCorners[7]) < r2) then inc(CornerHitCount);
      if CornerHitCount=7 then result := J_INTERSECTFULL else result := J_INTERSECTPARTIAL;
   end else result := J_INTERSECTFAIL;
end;

{----------------------------------------------------------- TJFrustum Routines}
function JFrustumFromViewProjectionMatrix(const M : TJMatrix) : TJFrustum;
begin
   with Result do
   begin
      // extract left plane
      FLeft.x:=M.RC[0,3]+M.RC[0,0];
      FLeft.y:=M.RC[1,3]+M.RC[1,0];
      FLeft.z:=M.RC[2,3]+M.RC[2,0];
      FLeft.w:=M.RC[3,3]+M.RC[3,0];
      FLeft := JPlaneNormalize(FLeft);
      // extract top plane
      FTop.x:=M.RC[0,3]-M.RC[0,1];
      FTop.y:=M.RC[1,3]-M.RC[1,1];
      FTop.z:=M.RC[2,3]-M.RC[2,1];
      FTop.w:=M.RC[3,3]-M.RC[3,1];
      FTop := JPlaneNormalize(FTop);
      // extract right plane
      FRight.x:=M.RC[0,3]-M.RC[0,0];
      FRight.y:=M.RC[1,3]-M.RC[1,0];
      FRight.z:=M.RC[2,3]-M.RC[2,0];
      FRight.w:=M.RC[3,3]-M.RC[3,0];
      FRight := JPlaneNormalize(FRight);
      // extract bottom plane
      FBottom.x:=M.RC[0,3]+M.RC[0,1];
      FBottom.y:=M.RC[1,3]+M.RC[1,1];
      FBottom.z:=M.RC[2,3]+M.RC[2,1];
      FBottom.w:=M.RC[3,3]+M.RC[3,1];
      FBottom := JPlaneNormalize(FBottom);
      // extract far plane
      FFar.x:=M.RC[0,3]-M.RC[0,2];
      FFar.y:=M.RC[1,3]-M.RC[1,2];
      FFar.z:=M.RC[2,3]-M.RC[2,2];
      FFar.w:=M.RC[3,3]-M.RC[3,2];
      FFar := JPlaneNormalize(FFar);
      // extract near plane
      FNear.x:=M.RC[0,3]+M.RC[0,2];
      FNear.y:=M.RC[1,3]+M.RC[1,2];
      FNear.z:=M.RC[2,3]+M.RC[2,2];
      FNear.w:=M.RC[3,3]+M.RC[3,2];
      FNear := JPlaneNormalize(FNear);
   end;
end;

function JFrustumContain(const AFrustum : TJFrustum; const AVertex : TVec3):boolean;
var
   I : SInt32;
begin
   Result := False;
   // Loop through each side of the frustum and test if the point lies outside any of them.
   for I := 0 to 5 do
   if(JPlaneDot(AFrustum.F[i], AVertex) < 0) then Exit;
   Result := True;
end;

function JFrustumContain(const AFrustum : TJFrustum; const ASphere : TJSphere):boolean;
var
   I : SInt32;
   Distance : Float32;
begin
   Result := false;
   for i:=0 To 5 Do
   begin
      Distance := JPlaneDot(AFrustum.F[i], ASphere.Origin);
      if (Distance < -ASphere.Radius) then exit;
   end;
   Result := True;
end;

function JFrustumContain(const AFrustum : TJFrustum; const ABBox : TJBBox):boolean;
var
   I : SInt32;
begin
   result:=False;
   with ABBox Do
   for I:=0 To 5 Do
   begin
      if (JPlaneDot(AFrustum.F[i], Min.X, Min.Y, Min.Z) >= 0) then Continue;
      if (JPlaneDot(AFrustum.F[i], Max.X, Min.Y, Min.Z) >= 0) then Continue;
      if (JPlaneDot(AFrustum.F[i], Min.X, Max.Y, Min.Z) >= 0) then Continue;
      if (JPlaneDot(AFrustum.F[i], Max.X, Max.Y, Min.Z) >= 0) then Continue;
      if (JPlaneDot(AFrustum.F[i], Min.X, Min.Y, Max.Z) >= 0) then Continue;
      if (JPlaneDot(AFrustum.F[i], Max.X, Min.Y, Max.Z) >= 0) then Continue;
      if (JPlaneDot(AFrustum.F[i], Min.X, Max.Y, Max.Z) >= 0) then Continue;
      if (JPlaneDot(AFrustum.F[i], Max.X, Max.Y, Max.Z) >= 0) then Continue;
      Exit; {if we've reached here, it's failed}
   end;
   result:=True;
end;

function JFrustumIntersect(const AFrustum: TJFrustum; const ASphere: TJSphere): TJIntersectResult;
var
   I : SInt32;
   Distance : Float32;
   T : SInt32;
begin
   T := 0;
   for I:=0 To 5 Do
   begin
      Distance := JPlaneDot(AFrustum.F[i], ASphere.Origin);
      if (Distance < -ASphere.Radius) then T+=1;
   end;

   if T=0 then exit(J_INTERSECTFAIL);
   if T=6 then exit(J_INTERSECTFULL);
   exit(J_INTERSECTPARTIAL);
end;

function IsVolumeClipped(const objPos : TVec3; const objRadius : Single; const Frustum : TJFrustum) : Boolean;
var
negRadius : Single;
begin
negRadius:= -objRadius;
Result:= (JPlaneDistance(frustum.FLeft, objPos)<negRadius)
or (JPlaneDistance(frustum.FTop, objPos)<negRadius)
or (JPlaneDistance(frustum.FRight, objPos)<negRadius)
or (JPlaneDistance(frustum.FBottom, objPos)<negRadius)
or (JPlaneDistance(frustum.FNear, objPos)<negRadius)
or (JPlaneDistance(frustum.FFar, objPos)<negRadius);
end;

function JFrustumIntersectFast(const AFrustum : TJFrustum; const ABBox: TJBBox) : Boolean;
begin
// change box to sphere
   Result := not IsVolumeClipped((ABBox.min+ABBox.max)*0.5,
   Vec3Distance(ABBox.min, ABBox.max)*0.5, AFrustum);
end;

function JFrustumIntersect(const AFrustum: TJFrustum; const ABBox: TJBBox): TJIntersectResult;
var
   I : SInt32;
   T : SInt32;
begin
   T := 0;
   with ABBox Do
   for I:=0 To 5 Do
   begin
      if (JPlaneDot(AFrustum.F[i], Min.X, Min.Y, Min.Z) >=0) or
         (JPlaneDot(AFrustum.F[i], Max.X, Min.Y, Min.Z) >=0) or
         (JPlaneDot(AFrustum.F[i], Min.X, Max.Y, Min.Z) >=0) or
         (JPlaneDot(AFrustum.F[i], Max.X, Max.Y, Min.Z) >=0) or
         (JPlaneDot(AFrustum.F[i], Min.X, Min.Y, Max.Z) >=0) or
         (JPlaneDot(AFrustum.F[i], Max.X, Min.Y, Max.Z) >=0) or
         (JPlaneDot(AFrustum.F[i], Min.X, Max.Y, Max.Z) >=0) or
         (JPlaneDot(AFrustum.F[i], Max.X, Max.Y, Max.Z) >=0) then T+=1;
   end;

   if T=0 then exit(J_INTERSECTFAIL);
   if T=6 then exit(J_INTERSECTFULL);
   exit(J_INTERSECTPARTIAL);
end;

{-------------------------------------------------------------- TJBBox Routines}

function JBBoxCenter(const ABBox : TJBBox) : TVec3; {$I JAInline.inc}
Begin
  Result := (ABBox.min+ABBox.max)*0.5;
End;

function JBBoxToSphere(const ABBox : TJBBox) : TJSphere;
begin
  Result.Origin := (ABBox.min+ABBox.max)*0.5;
  Result.Radius := Vec3Distance(ABBox.min,ABBox.max)*0.5;
end;

function JBBoxExtractCorners(const ABBox: TJBBox): TJBBoxCorners;
begin
   with ABBox do
   begin
      Result[0] := vec3(min.X, min.Y, min.Z);
      Result[1] := vec3(min.X, min.Y, max.Z);
      Result[2] := vec3(min.X, max.Y, min.Z);
      Result[3] := vec3(min.X, max.Y, max.Z);
      Result[4] := vec3(max.X, min.Y, min.Z);
      Result[5] := vec3(max.X, min.Y, max.Z);
      Result[6] := vec3(max.X, max.Y, min.Z);
      Result[7] := vec3(max.X, max.Y, max.Z);
   end;
end;

function JBBoxInclude(const ABBox: TJBBox; BBBox: TJBBox): TJBBox;
begin
   Result := ABBox;
   if BBBox.Min.X < ABBox.Min.X then Result.Min.X := BBBox.Min.X;
   if BBBox.Min.Y < ABBox.Min.Y then Result.Min.Y := BBBox.Min.Y;
   if BBBox.Min.Z < ABBox.Min.Z then Result.Min.Z := BBBox.Min.Z;
   if BBBox.Max.X > ABBox.Max.X then Result.Max.X := BBBox.Max.X;
   if BBBox.Max.Y > ABBox.Max.Y then Result.Max.Y := BBBox.Max.Y;
   if BBBox.Max.Z > ABBox.Max.Z then Result.Max.Z := BBBox.Max.Z;
end;

function JBBoxInclude(const ABBox: TJBBox; V: TVec3): TJBBox;
begin
   Result := ABBox;
   if V.X < ABBox.Min.X then Result.Min.X := V.X;
   if V.Y < ABBox.Min.Y then Result.Min.Y := V.Y;
   if V.Z < ABBox.Min.Z then Result.Min.Z := V.Z;
   if V.X > ABBox.Max.X then Result.Max.X := V.X;
   if V.Y > ABBox.Max.Y then Result.Max.Y := V.Y;
   if V.Z > ABBox.Max.Z then Result.Max.Z := V.Z;
end;

function JBBoxContain(const ABBox: TJBBox; const V: TVec3): boolean;
begin
   Result := (V.X <= ABBox.max.X) and (V.X >= ABBox.min.X)
      and (V.Y <= ABBox.max.Y) and (V.Y >= ABBox.min.Y)
      and (V.Z <= ABBox.max.Z) and (V.Z >= ABBox.min.Z);
end;

function JBBoxContain(const ABBox: TJBBox; const ASphere: TJSphere): boolean;
begin
   Result := JBBoxIntersect(ABBox,ASphere)=J_INTERSECTFULL;
end;

function JBBoxContain(const ABBox: TJBBox; const BBbox: TJBBox): boolean;
begin
   Result := JBBoxIntersect(ABBox,BBBox)=J_INTERSECTFULL;
end;

function JBBoxIntersect(const ABBox: TJBBox; const ASphere: TJSphere): TJIntersectResult;
begin
   Result := JBBoxIntersect(ABBox,JSphereToBBox(ASphere));
end;

function JBBoxIntersect(const ABBox: TJBBox; const BBbox: TJBBox): TJIntersectResult;
begin
   if ((ABBox.min.X<BBbox.max.X) and
   (ABBox.min.Y<BBbox.max.Y) and
   (ABBox.min.Z<BBbox.max.Z) and
   (BBbox.min.X<ABBox.max.X) and
   (BBbox.min.Y<ABBox.max.Y) and
   (BBbox.min.Z<ABBox.max.Z)) then
   begin
      if(BBbox.min.X>=ABBox.min.X) and
      (BBbox.min.Y>=ABBox.min.Y) and
      (BBbox.min.Z>=ABBox.min.Z) and
      (BBbox.max.X<=ABBox.max.X) and
      (BBbox.max.Y<=ABBox.max.Y) and
      (BBbox.max.Z<=ABBox.max.Z) then
      result := J_INTERSECTFULL else
      result := J_INTERSECTPARTIAL;
   end else result := J_INTERSECTFAIL;
end;

{------------------------------------------------------------- JColour Routines}
function JColour3FromHSV(const H,S,V: Float32) : TJColour3;
var
   f : Float32;
   i : SInt32;
   hTemp : Float32;
   p,q,t : Float32;
begin
   if S = 0.0 then
   begin
      if IsNaN(H) then
      begin
         Result.R := V;
         Result.G := V;
         Result.B := V;
      end;
   end else
   begin
      if H = 360.0 then hTemp := 0.0 else hTemp := H;
      hTemp := hTemp / 60;
      i := trunc(hTemp);
      f := hTemp - i;
      p := V * (1.0 - S);
      q := V * (1.0 - (S * f));
      t := V * (1.0 - (S * (1.0 - f)));
      case I of
         0: begin Result.R := V;  Result.G := t;  Result.B := p; end;
         1: begin Result.R := q;  Result.G := V;  Result.B := p; end;
         2: begin Result.R := p;  Result.G := V;  Result.B := t; end;
         3: begin Result.R := p;  Result.G := q;  Result.B := V; end;
         4: begin Result.R := t;  Result.G := p;  Result.B := V; end;
         5: begin Result.R := V;  Result.G := p;  Result.B := q; end;
      end;
   end;
end;

procedure JColour3ToHSV(const AColour : TJColour3; var H,S,V: Float32);
var
   Delta:  Float32;
   Min  :  Float32;
begin
   Min := MinValue( [AColour.R, AColour.G, AColour.B] );
   V   := MaxValue( [AColour.R, AColour.G, AColour.B] );
   Min +=0.0000001; //add a tiny amount to keep solution valid
   Delta := V - Min;
   if ((V = 0.0)) then S := 0 else S := Delta / V;
   if S = 0.0 then H := 0 else
   begin
      if AColour.R = V then
      H := 60.0 * (AColour.G - AColour.B) / Delta
      else if AColour.G = V then
      H := 120.0 + 60.0 * (AColour.B - AColour.R) / Delta
      else if AColour.B = V then
      H := 240.0 + 60.0 * (AColour.R - AColour.G) / Delta;
      if H < 0.0 then H := H + 360.0;
   end;
end;

function JColourClamp(const AColour: TJColour; const ALowerChannelBound, AUpperChannelBound: Float32): TJColour;  {$I JAInline.inc}
begin
   Result.R := JClamp(AColour.R,ALowerChannelBound,AUpperChannelBound);
   Result.G := JClamp(AColour.G,ALowerChannelBound,AUpperChannelBound);
   Result.B := JClamp(AColour.B,ALowerChannelBound,AUpperChannelBound);
   Result.A := JClamp(AColour.A,ALowerChannelBound,AUpperChannelBound);
end;

function JColourClamp(const AColour: TJColour; const ALowerColour, AUpperColour: TJColour): TJColour;  {$I JAInline.inc}
begin
   Result.R := JClamp(AColour.R,ALowerColour.R,AUpperColour.R);
   Result.G := JClamp(AColour.G,ALowerColour.G,AUpperColour.G);
   Result.B := JClamp(AColour.B,ALowerColour.B,AUpperColour.B);
   Result.A := JClamp(AColour.A,ALowerColour.A,AUpperColour.A);
end;


*)

end.
