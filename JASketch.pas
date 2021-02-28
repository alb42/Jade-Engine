unit JASketch;
{$mode objfpc}{$H+}
{$PACKRECORDS 2} {required for compatibility with various amiga APIs}
{$i JA.inc}

{A Sketch is a collection of Polygons. It is arranged as such so different
coloured/styled polygons can make up a single object while also having a
defined order of rendering, the order of the Polygon array, for controlling
which polygons lie above or below one another, if required.}

interface

uses
   JATypes, JAMath, JAList, JAPolygon;

type
   TJASketch = record
      Polygon : PJAPolygon;
      PolygonCapacity : SInt32;
      PolygonCount : SInt32;
   end;
   PJASketch = ^TJASketch;

function JASketchCreate() : PJASketch;
function JASketchDestroy(ASketch : PJASketch) : boolean;
function JASketchClear(ASketch : PJASketch) : boolean;

function JASketchPolygonCreate(ASketch : PJASketch) : PJAPolygon;
function JASketchPolygonDestroy(ASketch : PJASketch; APolygon : PJAPolygon) : boolean;

implementation

function JASketchCreate() : PJASketch;
begin
   Result := PJASketch(JAMemGet(SizeOf(TJASketch)));
   Result^.Polygon := nil;
   Result^.PolygonCapacity := 0;
   Result^.PolygonCount := 0;
end;

function JASketchDestroy(ASketch : PJASketch) : boolean;
begin
   if (ASketch=nil) then exit(false);
   JASketchClear(ASketch);
   JAMemFree(ASketch,SizeOf(TJASketch));
   Result := true;
end;

function JASketchClear(ASketch : PJASketch) : boolean;
var
   I : SInt32;
begin
   if (ASketch=nil) then exit(false);
   for I := 0 to ASketch^.PolygonCount-1 do
   begin
      if (ASketch^.Polygon[I].VertexCapacity > 0) then
      begin
         JAMemFree(ASketch^.Polygon[I].Vertex, SizeOf(TJAVertex) * ASketch^.Polygon[I].VertexCapacity);
         JAMemFree(ASketch^.Polygon[I].WorldVertex, SizeOf(TVec2) * ASketch^.Polygon[I].VertexCapacity);
         JAMemFree(ASketch^.Polygon[I].WorldVertexI, SizeOf(TVec2SInt16) * ASketch^.Polygon[I].VertexCapacity);
      end;
      ASketch^.Polygon[I].Vertex := nil;
      ASketch^.Polygon[I].VertexCapacity := 0;
      ASketch^.Polygon[I].VertexCount := 0;
      ASketch^.Polygon[I].WorldVertex := nil;
      ASketch^.Polygon[I].WorldVertexI := nil;

      if (ASketch^.Polygon[I].IndexCapacity > 0) then
         JAMemFree(ASketch^.Polygon[I].Index, SizeOf(UInt32) * ASketch^.Polygon[I].IndexCapacity);
      ASketch^.Polygon[I].Index := nil;
      ASketch^.Polygon[I].IndexCapacity := 0;
      ASketch^.Polygon[I].IndexCount := 0;
   end;
   if (ASketch^.PolygonCapacity > 0) then
   JAMemFree(ASketch^.Polygon, SizeOf(TJAPolygon) * ASketch^.PolygonCapacity);
   ASketch^.Polygon := nil;
   ASketch^.PolygonCapacity := 0;
   ASketch^.PolygonCount := 0;
   Result := true;
end;

function JASketchPolygonCreate(ASketch : PJASketch) : PJAPolygon;
var
   NewCapacity : SInt32;
begin
   NewCapacity := ASketch^.PolygonCapacity;
   if (NewCapacity=0) then NewCapacity := JAPool_BlockSize else
   if (ASketch^.PolygonCount+1) > NewCapacity then NewCapacity += JAPool_BlockSize;
   if NewCapacity<>ASketch^.PolygonCapacity then
   begin
     if ASketch^.PolygonCapacity=0 then
     ASketch^.Polygon := JAMemGet(SizeOf(TJAPolygon)*NewCapacity) else
     ASketch^.Polygon := reallocmem(ASketch^.Polygon, SizeOf(TJAPolygon)*NewCapacity);
     ASketch^.PolygonCapacity := NewCapacity;
   end;

   {return pointer to polygon structure}
   Result := @ASketch^.Polygon[ASketch^.PolygonCount];

   {Set Initial Shadow Array State}
   Result^.Shadows := nil;
   Result^.ShadowsCount := 0;
   Result^.ShadowPenumbra0Fins := nil;
   Result^.ShadowPenumbra0FinsCapacity := 0;
   Result^.ShadowPenumbra0FinsCount := 0;
   Result^.ShadowPenumbra1Fins := nil;
   Result^.ShadowPenumbra1FinsCapacity := 0;
   Result^.ShadowPenumbra1FinsCount := 0;

   {Set Polygon Inital State}
   Result^.Vertex := nil;
   Result^.WorldVertex := nil;
   Result^.WorldVertexI := nil;
   Result^.Index := nil;

   JAPolygonClear(Result);

   ASketch^.PolygonCount += 1;
end;

function JASketchPolygonDestroy(ASketch : PJASketch; APolygon : PJAPolygon) : boolean;
var
   I : SInt32;
begin
   Result := false;
   for I := 0 to ASketch^.PolygonCount-1 do
   begin
      if (@ASketch^.Polygon[I] = ASketch) then Result := true;
      if Result and (I < ASketch^.PolygonCount-1) then
         ASketch^.Polygon[I] := ASketch^.Polygon[I+1];
   end;
   if Result then ASketch^.PolygonCount +=1;
   {Something should probably be here}
   Result := false;
end;

end.

