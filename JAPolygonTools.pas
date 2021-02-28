unit JAPolygonTools;
{$mode objfpc}{$H+}
{$PACKRECORDS 2} {required for compatibility with various amiga APIs}
{$i JA.inc}

interface

uses
   JATypes, JAMath, JAPolygon;

function JAPolygonMakeRect(APolygon : PJAPolygon; ARect : TJRect) : SInt32;
function JAPolygonMakeCircle(APolygon : PJAPolygon; AAxis : TVec2; ARadius : Float32; APointCount : SInt32) : SInt32;
function JAPolygonMakeSpaceShip(APolygon : PJAPolygon; AScale : Float32) : SInt32;

implementation

function JAPolygonMakeRect(APolygon : PJAPolygon; ARect : TJRect) : SInt32;
var
   Vertex : PJAVertex;
begin
   JAPolygonClear(APolygon);

   Vertex := JAPolygonVertexCreate(APolygon);
   Vertex^.Position := vec2(ARect.Left,ARect.Top);
   Vertex := JAPolygonVertexCreate(APolygon);
   Vertex^.Position := vec2(ARect.Left,ARect.Bottom);
   Vertex := JAPolygonVertexCreate(APolygon);
   Vertex^.Position := vec2(ARect.Right,ARect.Bottom);
   Vertex := JAPolygonVertexCreate(APolygon);
   Vertex^.Position := vec2(ARect.Right,ARect.Top);
end;

function JAPolygonMakeCircle(APolygon : PJAPolygon; AAxis : TVec2; ARadius : Float32; APointCount : SInt32) : SInt32;
var
   I : SInt32;
   Vertex : PJAVertex;
   RVec : TVec2;
begin
   JAPolygonClear(APolygon);
   for I := 0 to APointCount-1 do
   begin
     RVec := vec2(0,ARadius);
     Vertex := JAPolygonVertexCreate(APolygon);
     Vertex^.Position := AAxis + Vec2Rotate(RVec, (360/APointCount)*I);
   end;
end;

function JAPolygonMakeSpaceShip(APolygon : PJAPolygon; AScale : Float32) : SInt32;
var
   Vertex : PJAVertex;
begin
   JAPolygonClear(APolygon);

   Vertex := JAPolygonVertexCreate(APolygon);
   Vertex^.Position := vec2(-0.7,-1);
   Vertex^.Position *= AScale;
   Vertex := JAPolygonVertexCreate(APolygon);
   Vertex^.Position := vec2(0,1);
   Vertex^.Position *= AScale;
   Vertex := JAPolygonVertexCreate(APolygon);
   Vertex^.Position := vec2(0.7,-1);
   Vertex^.Position *= AScale;
   Vertex := JAPolygonVertexCreate(APolygon);
   Vertex^.Position := vec2(0,-0.3);
   Vertex^.Position *= AScale;
   Vertex := JAPolygonVertexCreate(APolygon);
   Vertex^.Position := vec2(-0.7,-1);
   Vertex^.Position *= AScale;
end;

end.

