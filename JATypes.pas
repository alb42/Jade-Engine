unit JATypes;
{$mode objfpc}{$H+}
{$PACKRECORDS 2} {required for compatibility with various amiga APIs}
{$i JA.inc}

interface

uses
   {Amiga} Exec;

type
   {32-bit float}
   Float32 = Single;
   PFloat32 = ^Float32;

   {64-bit float}
   Float64 = Double;
   PFloat64 = ^Float64;

   {unsigned 8-bit integer}
   UInt8 = Byte;
   PUInt8 = ^UInt8;

   {signed 8-bit integer}
   SInt8 = ShortInt;
   PSInt8 = ^SInt8;

   {unsigned 16-bit integer}
   UInt16 = Word;
   PUInt16 = ^UInt16;

   {signed 16-bit integer}
   SInt16 = SmallInt;
   PSInt16 = ^SInt16;

   {unsigned 32-bit integer}
   UInt32 = LongWord;
   PUInt32 = ^UInt32;

   {signed 32-bit integer}
   SInt32 = LongInt;
   PSInt32 = ^SInt32;

   {16-bit DualByte helper}
   TDualByte = record
      case UInt8 of
      0 : (DB : array[0..1] of UInt8);
      1 : (DC : array[0..1] of Char);
      2 : (High, Low : UInt8);
      3 : (U16 : UInt16);
      4 : (S16 : SInt16);
   end;
   PDualByte = ^TDualByte;

   {32-bit QuadByte helper}
   TQuadByte = record
      case UInt8 of
      0 : (QB : array[0..3] of UInt8);
      1 : (QC : array[0..3] of Char);
      2 : (High, Low : UInt16);
      3 : (U32 : UInt32);
      4 : (S32 : SInt32);
   end;
   PQuadByte = ^TQuadByte;

   {32-bit float 2D Vector/Vertex}
   TVec2 = record
      case UInt8 of
      1:(X,Y : Float32);
      2:(V : array[0..1] of Float32);
   end;
   PVec2 = ^TVec2;

   {signed 16-bit Integer 2D Vector/Vertex}
   TVec2SInt16 = record
      case UInt8 of
      1:(X,Y : SInt16);
      2:(V : array[0..1] of SInt16);
   end;
   PVec2SInt16 = ^TVec2SInt16;

   {signed 32-bit Integer 2D Vector/Vertex}
   TVec2SInt32 = record
      case UInt8 of
      1:(X,Y : SInt32);
      2:(V : array[0..1] of SInt32);
   end;
   PVec2SInt32 = ^TVec2SInt32;

   {32-bit Float Rect Type}
   TJRect = record
      case UInt8 of
      1:(Left,Top,Right,Bottom : Float32);
      2:(LT,RB : TVec2);
      3:(R : array[0..3] of Float32);
   end;
   PJRect = ^TJRect;

   {Signed 16-bit Integer Rect Type}
   TJRectSInt16 = record
      case UInt8 of
      1:(Left,Top,Right,Bottom : SInt16);
      2:(LT,RB : TVec2SInt16);
      3:(R : array[0..3] of SInt16);
   end;
   PJRectSInt16 = ^TJRectSInt16;

   {Signed 32-bit Integer Rect Type}
   TJRectSInt32 = record
      case UInt8 of
      1:(Left,Top,Right,Bottom : SInt32);
      2:(LT,RB : TVec2SInt32);
      3:(R : array[0..3] of SInt32);
   end;
   PJRectSInt32 = ^TJRectSInt32;

   {32-bit Float Bounding Box Type}
   TJBBox = record
      case UInt8 of
      1:(MinX,MinY,MaxX,MaxY : Float32);
      2:(Min, Max : TVec2);
      3:(B : array[0..3] of Float32);
   end;
   PJBBox = ^TJBBox;

   {Signed 16-bit Integer Bounding Box Type}
   TJBBoxSInt16 = record
      case UInt8 of
      1:(MinX,MinY,MaxX,MaxY : SInt16);
      2:(Min, Max : TVec2SInt16);
      3:(B : array[0..3] of SInt16);
   end;
   PJBBoxSInt16 = ^TJBBoxSInt16;

   {Signed 32-bit Integer Bounding Box Type}
   TJBBoxSInt32 = record
      case UInt8 of
      1:(MinX,MinY,MaxX,MaxY : SInt32);
      2:(Min, Max : TVec2SInt32);
      3:(B : array[0..3] of SInt32);
   end;
   PJBBoxSInt32 = ^TJBBoxSInt32;

   {32-bit Float Circle Definition}
   TJCircle = record
      Origin : TVec2;
      Radius : Float32;
   end;
   PJCircle = ^TJCircle;

   {Signed 16-bit Integer Circle Definition}
   TJCircleSInt16 = record
      Origin : TVec2SInt16;
      Radius : SInt16;
   end;
   PJCircleSInt16 = ^TJCircleSInt16;

   {Signed 32-bit Integer Circle Definition}
   TJCircleSInt32 = record
      Origin : TVec2SInt32;
      Radius : SInt32;
   end;
   PJCircleSInt32 = ^TJCircleSInt32;

   {32-bit float 2x2 Matrix}
   TMat2 = record
      case UInt8 of
      1:(_00, _01,
         _10, _11 : Float32);
      2 : (M : array[0..3] of Float32);
      3 : (RC : array[0..1, 0..1] of Float32);
   end;
   PMat2 = ^TMat2;

   {32-bit float 3x3 Matrix}
   TMat3 = record
      case UInt8 of
      1:(_00, _01, _02,
         _10, _11, _12,
         _20, _21, _22 : Float32);
      2 : (M : array[0..8] of Float32);
      3 : (RC : array[0..2, 0..2] of Float32);
   end;
   PMat3 = ^TMat3;

   {Ray Type}
   TJRay = record
      case UInt8 of
      1:(Origin : TVec2; Vector : TVec2);
      2:(OV : array[0..1] of TVec2);
   end;
   PJRay = ^TJRay;

   {3 unsigned 8-bit Integer colour}
   TJColour3UInt8 = record
   case UInt8 of
      1:(R,G,B: UInt8);
      2:(RGB : array [0..2] of UInt8);
   end;
   PJColour3UInt8 = ^TJColour3UInt8;

   {4 unsigned 8-bit Integer colour}
   TJColourUInt8 = record
      case UInt8 of
      1:(RGB: TJColour3UInt8);
      2:(R,G,B,A: UInt8);
      3:(RGBA: array [0..3] of UInt8);
      4:(RGBA32 : UInt32);
   end;
   PJColourUInt8 = ^TJColourUInt8;

   {3 32-bit Float colour}
   TJColour3 = record
   case UInt8 of
      1:(R,G,B: Float32);
      2:(RGB: array [0..2] of Float32);
   end;
   PJColour3 = ^TJColour3;

   {4 32-bit Float Colour}
   TJColour = record
      case UInt8 of
      1:(RGB: TJColour3);
      2:(R,G,B,A: Float32);
      3:(RGBA: array [0..3] of Float32);
   end;
   PJColour = ^TJColour;

   TJRectSide = (JRect_Left=0, JRect_Top=1, JRect_Right=2, JRect_Bottom=3);

   TJAGraphicsAPI = (
      JAGraphicsAPI_Intuition=0,
      JAGraphicsAPI_Picasso=1,
      JAGraphicsAPI_CyberGraphics=2,
      JAGraphicsAPI_Auto=3);

const
   {Math Constants}
   JEpsilon  : Float32 = 1e-40;
   JPI : Float32 = 3.141592653589793238462643383279502;
   JPI2 : Float32 = 6.283185307179586476925286766558;
   JPIDiv2 : Float32 = 1.5707963267948966192313216916395;
   JPIDiv180 : Float32 = 0.017453292519943295769236907684883;
   J180DivPI : Float32 = 57.295779513082320876798154814114;
   JDegToRad : Float32 = 0.017453292519943295769236907684883;
   JRadToDeg : Float32 = 57.295779513082320876798154814114;

   {Vec2 Constants}
   Vec2Zero : TVec2 = (X:0; Y:0);
   Vec2Up : TVec2 = (X:0; Y:1);
   Vec2Down : Tvec2 = (X:0; Y:-1);
   Vec2Left : TVec2 = (X:-1; Y:0);
   Vec2Right : TVec2 = (X:1; Y:0);

   {Rect Constants}
   JRectZero : TJRect = (Left : 0; Top : 0; Right : 0; Bottom : 0);
   JRectSInt16Zero : TJRectSInt16 = (Left : 0; Top : 0; Right : 0; Bottom : 0);
   JRectSInt32Zero : TJRectSInt32 = (Left : 0; Top : 0; Right : 0; Bottom : 0);

   {BBox Constants}
   JBBoxZero : TJBBox = (MinX : 0; MinY : 0; MaxX : 0; MaxY : 0);
   JBBoxSInt16Zero : TJBBoxSInt16 = (MinX : 0; MinY : 0; MaxX : 0; MaxY : 0);
   JBBoxSInt32Zero : TJBBoxSInt32 = (MinX : 0; MinY : 0; MaxX : 0; MaxY : 0);

   {Matrix Constants}
   Mat2Identity: TMat2 = (
      _00:1; _01:0;
      _10:0; _11:1);

   Mat2Zero: TMat2 = (
      _00:1; _01:0;
      _10:0; _11:1);

   Mat3Identity: TMat3 = (
      _00:1; _01:0; _02:0;
      _10:0; _11:1; _12:0;
      _20:0; _21:0; _22:1);

   Mat3One: TMat3 = (
      _00:1; _01:1; _02:1;
      _10:1; _11:1; _12:1;
      _20:1; _21:1; _22:1);

   Mat3Zero: TMat3 = (
      _00:0; _01:0; _02:0;
      _10:0; _11:0; _12:0;
      _20:0; _21:0; _22:0);

   {default blocksize for list/array/memory growth etc}
   JAPool_BlockSize = 32;

	{Amiga Library Names}
	JALibNameExec : PChar  = 'exec.library';
	JALibNameIntuition : PChar  = 'intuition.library';
   JALibNameGraphics : PChar  = 'graphics.library';
   JALibNameLayers : PChar  = 'layers.library';
   JALibNamePicasso96API : PChar = 'Picasso96API.library';
	JALibNameCybergraphics : PChar = 'cybergraphics.library';

   {Amiga Device Names}
	JADeviceNameTimer : PChar = 'timer.device';
	JADeviceNameNarrator : PChar = 'narrator.device';
	JADeviceNameSerial : PChar = 'serial.device';
	JADeviceNameParallel : PChar = 'parallel.device';

   {MouseWheel Defines}
   NM_WHEEL_UP = $7A;
   NM_WHEEL_DOWN = $7B;
   NM_WHEEL_LEFT = $7C;
   NM_WHEEL_RIGHT = $7D;
   NM_BUTTON_FOURTH = $7E;

var
   JAMemAllocated : UInt32 = 0;
   JAMemReleased : UInt32 = 0;

{Memory Allocation}
function JAMemGet(ASize : UInt32) : Pointer;
procedure JAMemFree(AMemory : Pointer; ASize : UInt32);
function JAMemRealloc(AMemory : Pointer; ASize : UInt32) : Pointer;

{Type Constuctors}
function Vec2(X,Y : Float32) : TVec2; overload;
function Vec2(V : TVec2SInt16) : TVec2; overload;

function Vec2SInt16(V : TVec2) : TVec2SInt16; overload;
function Vec2SInt16(X,Y : SInt16) : TVec2SInt16; overload;

function Vec2SInt32(X,Y : SInt32) : TVec2SInt32;

function JRect(Left, Top, Right, Bottom : Float32) : TJRect; overload;
function JRect(ARect : TJRectSInt16) : TJRect; overload;
function JRectSInt16(Left, Top, Right, Bottom : SInt16) : TJRectSInt16;
function JRectSInt32(Left, Top, Right, Bottom : SInt32) : TJRectSInt32;

function JColour3UInt8(Red,Green,Blue : UInt8) : TJColour3UInt8;
function JColourUInt8(Red,Green,Blue,Alpha : UInt8) : TJColourUInt8;

{TVec2 Operators}
operator + (const A, B : TVec2) : TVec2; {$I JAInline.inc}
operator + (const A : TVec2; B : TVec2SInt16) : TVec2; {$I JAInline.inc}
operator + (const A : TVec2SInt16; B : TVec2) : TVec2; {$I JAInline.inc}
operator + (const A : TVec2; B : TVec2SInt32) : TVec2; {$I JAInline.inc}
operator + (const A : TVec2SInt32; B : TVec2) : TVec2; {$I JAInline.inc}
operator + (const A : TVec2SInt32; B : TVec2SInt32) : TVec2SInt32; {$I JAInline.inc}
operator - (const A, B : TVec2) : TVec2; {$I JAInline.inc}
operator - (const A, B : TVec2SInt32) : TVec2SInt32; {$I JAInline.inc}
operator * (const A, B : TVec2) : TVec2; {$I JAInline.inc}
operator * (const A : TVec2; const F : Float32) : TVec2; {$I JAInline.inc}
operator / (const A : TVec2; const F : Float32) : TVec2; {$I JAInline.inc}
operator + (const V : TVec2; const F : Float32) : TVec2; {$I JAInline.inc}
operator - (const V : TVec2; const F : Float32) : TVec2; {$I JAInline.inc}
operator := (const V : TVec2SInt16) : TVec2; {$I JAInline.inc}
operator := (const V : TVec2SInt32) : TVec2; {$I JAInline.inc}
operator = (const A, B : TVec2) : boolean; {$I JAInline.inc} {comparator}
operator - (const A : TVec2) : TVec2; {$I JAInline.inc} {Unary minus}

{TMat2 Operators}
operator * (const A, B : TMat2) : TMat2; {$I JAInline.inc}

{TMat3 Operators}
operator * (const A, B : TMat3) : TMat3; {$I JAInline.inc}

{TJColour3UInt8 Operators}
operator + (const A, B : TJColour3UInt8) : TJColour3UInt8; {$I JAInline.inc}
operator - (const A, B : TJColour3UInt8) : TJColour3UInt8; {$I JAInline.inc}
operator * (const A, B : TJColour3UInt8) : TJColour3UInt8; {$I JAInline.inc}

{TJColourUInt8 Operators}
operator + (const A, B : TJColourUInt8) : TJColourUInt8; {$I JAInline.inc}
operator - (const A, B : TJColourUInt8) : TJColourUInt8; {$I JAInline.inc}


{
{TJRect Operators}
operator + (const A : TJRect; B : TVec2) : TJRect; {$I JAInline.inc}
operator - (const A : TJRect; B : TVec2) : TJRect; {$I JAInline.inc}

{TJRectI Operators}
operator = (const A, B : TJRectI) : boolean; {$I JAInline.inc}
operator + (const A : TJRectI; B : TVec2I) : TJRectI; {$I JAInline.inc}
operator - (const A : TJRectI; B : TVec2I) : TJRectI; {$I JAInline.inc}

{TJBBox Operators}
operator * (const B : TJBBox; const F : Float32) : TJBBox; {$I JAInline.inc}
operator / (const B : TJBBox; const F : Float32) : TJBBox; {$I JAInline.inc}
operator + (const B : TJBBox; const V : TVec3) : TJBBox; {$I JAInline.inc}
operator - (const B : TJBBox; const V : TVec3) : TJBBox; {$I JAInline.inc}
operator := (const B : TJBBoxSInt16) : TJBBox; {$I JAInline.inc}
operator := (const B : TJBBoxI) : TJBBox; {$I JAInline.inc}

{TJColour Operators}
operator + (const A, B : TJColour) : TJColour; {$I JAInline.inc}
operator - (const A, B : TJColour) : TJColour; {$I JAInline.inc}
operator * (const A : TJColour; const B : Float32) : TJColour; {$I JAInline.inc}
operator * (const A,B : TJColour) : TJColour; {$I JAInline.inc}
operator / (const A : TJColour; const B : Float32) : TJColour; {$I JAInline.inc}

{TJColour3 Operators}
operator + (const A, B : TJColour3) : TJColour3; {$I JAInline.inc}
operator - (const A, B : TJColour3) : TJColour3; {$I JAInline.inc}
operator * (const A : TJColour3; const B : Float32) : TJColour3; {$I JAInline.inc}
operator * (const A,B : TJColour3) : TJColour3; {$I JAInline.inc}
operator / (const A : TJColour3; const B : Float32) : TJColour3; {$I JAInline.inc}

{TJColour3UInt8 Operators}
operator + (const A, B : TJColour3UInt8) : TJColour3UInt8; {$I JAInline.inc}
operator - (const A, B : TJColour3UInt8) : TJColour3UInt8; {$I JAInline.inc}

{TJColourUInt8 Operators}
operator + (const A, B : TJColourUInt8) : TJColourUInt8; {$I JAInline.inc}
operator - (const A, B : TJColourUInt8) : TJColourUInt8; {$I JAInline.inc}
 }

implementation

function JAMemGet(ASize: UInt32): Pointer;
begin
   JAMemAllocated += ASize;
   //Result := AllocVec(ASize, MEMF_CHIP or MEMF_CLEAR);
   Result := AllocMem(ASize);
end;

procedure JAMemFree(AMemory : Pointer; ASize : UInt32);
begin
   JAMemReleased += ASize;
   Freemem(AMemory);
end;

function JAMemRealloc(AMemory: Pointer; ASize: UInt32): Pointer;
begin
   Result := reallocmem(AMemory, ASize);
end;

{--------------------------------------------------------------Type constuctors}

function Vec2(X, Y : Float32) : TVec2;
begin
   Result.X := X;
   Result.Y := Y;
end;

function Vec2(V: TVec2SInt16): TVec2;
begin
   Result.X := V.X;
   Result.Y := V.Y;
end;

function Vec2SInt16(V: TVec2): TVec2SInt16;
begin
   Result.X := Round(V.X);
   Result.Y := Round(V.Y);
end;

function Vec2SInt16(X, Y: SInt16) : TVec2SInt16;
begin
   Result.X := X;
   Result.Y := Y;
end;

function Vec2SInt32(X, Y : SInt32) : TVec2SInt32;
begin
   Result.X := X;
   Result.Y := Y;
end;

function JRect(Left, Top, Right, Bottom : Float32) : TJRect;
begin
   Result.Left := Left;
   Result.Top := Top;
   Result.Right := Right;
   Result.Bottom := Bottom;
end;

function JRect(ARect: TJRectSInt16): TJRect;
begin
   Result.Left := ARect.Left;
   Result.Top := ARect.Top;
   Result.Right := ARect.Right;
   Result.Bottom := ARect.Bottom;
end;

function JRectSInt16(Left, Top, Right, Bottom : SInt16) : TJRectSInt16;
begin
   Result.Left := Left;
   Result.Top := Top;
   Result.Right := Right;
   Result.Bottom := Bottom;
end;

function JRectSInt32(Left, Top, Right, Bottom : SInt32) : TJRectSInt32;
begin
   Result.Left := Left;
   Result.Top := Top;
   Result.Right := Right;
   Result.Bottom := Bottom;
end;

function JColour3UInt8(Red, Green, Blue: UInt8): TJColour3UInt8;
begin
   Result.R := Red;
   Result.G := Green;
   Result.B := Blue;
end;

function JColourUInt8(Red,Green,Blue,Alpha : UInt8) : TJColourUInt8;
begin
   Result.R := Red;
   Result.G := Green;
   Result.B := Blue;
   Result.A := Alpha;
end;

{--------------------------------------------------------------- Vec2 Operators}

operator = (const A, B: TVec2): boolean;
begin
   Result :=
   (abs(A.X-B.X) < JEpsilon) and
   (abs(A.Y-B.Y) < JEpsilon);
end;

operator + (const A, B : TVec2) : TVec2; {$I JAInline.inc}
begin
   Result.X := A.X + B.X;
   Result.Y := A.Y + B.Y;
end;

operator + (const A : TVec2; B : TVec2SInt16) : TVec2; {$I JAInline.inc}
begin
   Result.X := A.X + B.X;
   Result.Y := A.Y + B.Y;
end;

operator + (const A : TVec2SInt16; B : TVec2) : TVec2; {$I JAInline.inc}
begin
   Result.X := A.X + B.X;
   Result.Y := A.Y + B.Y;
end;

operator + (const A : TVec2; B : TVec2SInt32) : TVec2; {$I JAInline.inc}
begin
   Result.X := A.X + B.X;
   Result.Y := A.Y + B.Y;
end;

operator + (const A : TVec2SInt32; B : TVec2) : TVec2; {$I JAInline.inc}
begin
   Result.X := A.X + B.X;
   Result.Y := A.Y + B.Y;
end;

operator + (const A : TVec2SInt32; B : TVec2SInt32) : TVec2SInt32; {$I JAInline.inc}
begin
   Result.X := A.X + B.X;
   Result.Y := A.Y + B.Y;
end;

operator - (const A, B : TVec2) : TVec2; {$I JAInline.inc}
begin
   Result.X := A.X - B.X;
   Result.Y := A.Y - B.Y;
end;

operator - (const A, B : TVec2SInt32) : TVec2SInt32; {$I JAInline.inc}
begin
   Result.X := A.X - B.X;
   Result.Y := A.Y - B.Y;
end;

operator * (const A, B : TVec2) : TVec2; {$I JAInline.inc}
begin
  Result.X := A.X * B.X;
  Result.Y := A.Y * B.Y;
end;

operator * (const A : TVec2; const F : Float32) : TVec2; {$I JAInline.inc}
begin
   Result.X := A.X * F;
   Result.Y := A.Y * F;
end;

operator / (const A : TVec2; const F : Float32) : TVec2; {$I JAInline.inc}
begin
   Result.X := A.X / F;
   Result.Y := A.Y / F;
end;

operator - (const A : TVec2) : TVec2; {$I JAInline.inc}
begin
   Result.X := -A.X;
   Result.Y := -A.Y;
end;

operator + (const V : TVec2; const F : Float32):TVec2; {$I JAInline.inc}
begin
   Result.X := V.X + F;
   Result.Y := V.Y + F;
end;

operator - (const V : TVec2; const F : Float32):TVec2; {$I JAInline.inc}
begin
   Result.X := V.X - F;
   Result.Y := V.Y - F;
end;

operator := (const V: TVec2SInt16): TVec2;
begin
   Result.X := V.X;
   Result.Y := V.Y;
end;

operator := (const V: TVec2SInt32): TVec2;
begin
   Result.X := V.X;
   Result.Y := V.Y;
end;

{---------------------------------------------------------- TMat2 Operators}

operator * (const A, B : TMat2) : TMat2;
begin

end;

{---------------------------------------------------------- TMat3 Operators}

operator * (const A, B : TMat3) : TMat3; {$I JAInline.inc}
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

{----------------------------------------------------- TJColour3UInt8 Operators}

operator + (const A, B : TJColour3UInt8) : TJColour3UInt8; {$I JAInline.inc}
begin
   Result.R := A.R+B.R;
   Result.G := A.G+B.G;
   Result.B := A.B+B.B;
end;

operator - (const A, B : TJColour3UInt8) : TJColour3UInt8; {$I JAInline.inc}
begin
   Result.R := A.R-B.R;
   Result.G := A.G-B.G;
   Result.B := A.B-B.B;
end;

operator * (const A, B: TJColour3UInt8): TJColour3UInt8;
begin
   Result.R := (A.R * B.R) div 255;
   Result.G := (A.G * B.G) div 255;
   Result.B := (A.B * B.B) div 255;
end;

{------------------------------------------------------ TJColourUInt8 Operators}
operator + (const A, B : TJColourUInt8) : TJColourUInt8; {$I JAInline.inc}
begin
   Result.R := A.R+B.R;
   Result.G := A.G+B.G;
   Result.B := A.B+B.B;
   Result.A := A.A+B.A;
end;

operator - (const A, B : TJColourUInt8) : TJColourUInt8; {$I JAInline.inc}
begin
   Result.R := A.R-B.R;
   Result.G := A.G-B.G;
   Result.B := A.B-B.B;
   Result.A := A.A-B.A;
end;

(*
{-------------------------------------------------------------- JRect Operators}

operator + (const A: TJRect; B: TVec2): TJRect; {$I JAInline.inc}
begin
   Result.LT := A.LT+B;
   Result.RB := A.RB+B;
end;

operator - (const A: TJRect; B: TVec2): TJRect; {$I JAInline.inc}
begin
   Result.LT := A.LT-B;
   Result.RB := A.RB-B;
end;

{------------------------------------------------------------- JRectI Operators}

operator = (const A, B : TJRectI): boolean;
begin
   Result := (A.LT = B.LT) and (A.RB = B.RB);
end;

operator + (const A: TJRectI; B: TVec2I): TJRectI; {$I JAInline.inc}
begin
   Result.LT := A.LT+B;
   Result.RB := A.RB+B;
end;

operator - (const A: TJRectI; B: TVec2I): TJRectI; {$I JAInline.inc}
begin
   Result.LT := A.LT-B;
   Result.RB := A.RB-B;
end;

{------------------------------------------------------------- TJBBox Operators}
operator * (const B : TJBBox; const F : Float32) : TJBBox; {$I JAInline.inc}
begin
   Result.Min := B.Min * F;
   Result.Max := B.Max * F;
end;

operator / (const B : TJBBox; const F : Float32) : TJBBox; {$I JAInline.inc}
begin
   Result.Min := B.Min / F;
   Result.Max := B.Max / F;
end;

operator + (const B : TJBBox; const V : TVec3) : TJBBox; {$I JAInline.inc}
begin
   Result.Min := B.Min + V;
   Result.Max := B.Max + V;
end;

operator - (const B : TJBBox; const V : TVec3) : TJBBox; {$I JAInline.inc}
begin
   Result.Min := B.Min - V;
   Result.Max := B.Max - V;
end;

operator := (const B: TJBBoxSInt16) : TJBBox;
begin
   Result.Min := B.Min;
   Result.Max := B.Max;
end;

operator:=(const B: TJBBoxI): TJBBox;
begin
  Result.Min := B.Min;
  Result.Max := B.Max;
end;

{----------------------------------------------------------- TJColour Operators}
operator + (const A, B : TJColour) : TJColour; {$I JAInline.inc}
begin
   Result.R := A.R+B.R;
   Result.G := A.G+B.G;
   Result.B := A.B+B.B;
   Result.A := A.A+B.A;
end;

operator - (const A, B : TJColour) : TJColour; {$I JAInline.inc}
begin
   Result.R := A.R-B.R;
   Result.G := A.G-B.G;
   Result.B := A.B-B.B;
   Result.A := A.A-B.A;
end;

operator * (const A : TJColour; const B : Float32) : TJColour; {$I JAInline.inc}
begin
   Result.R := A.R*B;
   Result.G := A.G*B;
   Result.B := A.B*B;
   Result.A := A.A*B;
end;

operator * (const A, B: TJColour): TJColour;
begin
  Result.R := A.R*B.R;
  Result.G := A.G*B.G;
  Result.B := A.B*B.B;
  Result.A := A.A*B.A;
end;

operator / (const A : TJColour; const B : Float32) : TJColour; {$I JAInline.inc}
begin
   Result.R := A.R/B;
   Result.G := A.G/B;
   Result.B := A.B/B;
   Result.A := A.A/B;
end;

{----------------------------------------------------------- TJColour3 Operators}

operator + (const A, B : TJColour3) : TJColour3; {$I JAInline.inc}
begin
   Result.R := A.R+B.R;
   Result.G := A.G+B.G;
   Result.B := A.B+B.B;
end;

operator - (const A, B : TJColour3) : TJColour3; {$I JAInline.inc}
begin
   Result.R := A.R-B.R;
   Result.G := A.G-B.G;
   Result.B := A.B-B.B;
end;

operator * (const A : TJColour3; const B : Float32) : TJColour3; {$I JAInline.inc}
begin
   Result.R := A.R*B;
   Result.G := A.G*B;
   Result.B := A.B*B;
end;

operator * (const A, B: TJColour3): TJColour3;
begin
  Result.R := A.R*B.R;
  Result.G := A.G*B.G;
  Result.B := A.B*B.B;
end;

operator / (const A : TJColour3; const B : Float32) : TJColour3; {$I JAInline.inc}
begin
   Result.R := A.R/B;
   Result.G := A.G/B;
   Result.B := A.B/B;
end;

*)

end.
