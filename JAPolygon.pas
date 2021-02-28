unit JAPolygon;
{$mode objfpc}{$H+}
{$PACKRECORDS 2} {required for compatibility with various amiga APIs}
{$i JA.inc}

{Polygons wrap up the storage of Vertex data along with with the polygon
style. Shadow Hull data is stored here as polygons can be shadow casters,
so it's a good spot for now.}

interface

uses
   JATypes, JAGlobal, JAMath;

type
   {Polygon vertex type}
   TJAVertex = record
      Position : TVec2;
      Normal : TVec2;
   end;
   PJAVertex = ^TJAVertex;

   {Polygon Style}
   TJAPolygonStyle = record
      Visible : boolean;
      Fill : TJColourUInt8;
      Stroke : TJColourUInt8;
      PenIndex : SInt32;
   end;
   PJAPolygonStyle = ^TJAPolygonStyle;

   TJAVertexPool = record
      Vertex : PVec2SInt16;
      VertexCapacity : SInt32;
      VertexCount : sInt32;
   end;
   PJAVertexPool = ^TJAVertexPool;

   TJAPolygonShadow = record

      {Umbra}
      ShadowVertex : PVec2SInt16; {Shadow Vertices are in Screen Space}
      ShadowVertexCapacity : SInt32;
      ShadowVertexCount : SInt32;
      ShadowVertexStart : SInt32; {First vertex of first back facing face}
      ShadowVertexEnd : SInt32; {Last vertex of last back facing face}

      {Penumbra (always solid)}
      StartUmbra,StartPenumbra : TVec2;
      EndUmbra,EndPenumbra : TVec2;
      ShadowPenumbra0Index : SInt32;
      ShadowPenumbra1Index : SInt32;

      {'Solid' Penumbras} 
      ShadowPenumbra0Vertex : PVec2SInt16;
      ShadowPenumbra0VertexCapacity : SInt32;
      ShadowPenumbra0VertexCount : SInt32;
      ShadowPenumbra1Vertex : PVec2SInt16;
      ShadowPenumbra1VertexCapacity : SInt32;
      ShadowPenumbra1VertexCount : SInt32;

      {Penumbra Bands}
      ShadowPenumbra0Fins : PJAVertexPool;
      ShadowPenumbra0FinsCapacity : SInt32;
      ShadowPenumbra0FinsCount : SInt32;
      ShadowPenumbra1Fins : PJAVertexPool;
      ShadowPenumbra1FinsCapacity : SInt32;
      ShadowPenumbra1FinsCount : SInt32;

   end;
   PJAPolygonShadow = ^TJAPolygonShadow;



   {2D Polygon}
   TJAPolygon = record

      {Polygon Data}

      {Local Space Vertices}
      Vertex : PJAVertex;
      VertexCapacity : SInt32;
      VertexCount : SInt32;
      {World Space Vertices}
      WorldVertex : PVec2;
      {Screen Space vertices}
      WorldVertexI : PVec2SInt16;

      {Vertex Indicies}
      Index : PUInt32;
      IndexCapacity : SInt32;
      IndexCount : SInt32;

      {Polygon Fill/Stroke Colors}
      Style : TJAPolygonStyle;

      {Enable/Disable Shadow volume construction for this polygon}
      ShadowCast : boolean;

      {Shadow Volumes Per Light}
      Shadows : PJAPolygonShadow;
      ShadowsCount : SInt16;

      {Umbras (always solid)}
      ShadowVertex : PVec2SInt16; {Shadow Vertices are in Screen Space}
      ShadowVertexCapacity : SInt32;
      ShadowVertexCount : SInt32;
      
      {Umbra Variables}
      ShadowVertexStart : SInt32; {First vertex of first back facing face}
      ShadowVertexEnd : SInt32; {Last vertex of last back facing face}

      {Penumbra Variables}
      ShadowPenumbra0Index : SInt32;
      ShadowPenumbra1Index : SInt32;
      StartUmbra,StartPenumbra : TVec2;
      EndUmbra,EndPenumbra : TVec2;
      ShadowPenumbra0CrossEdgeFinIndex : SInt16;
      ShadowPenumbra1CrossEdgeFinIndex : SInt16;
            
      {'Solid' Penumbra Geometry}
      ShadowPenumbra0Vertex : PVec2SInt16;
      ShadowPenumbra0VertexCapacity : SInt32;
      ShadowPenumbra0VertexCount : SInt32;
      ShadowPenumbra1Vertex : PVec2SInt16;
      ShadowPenumbra1VertexCapacity : SInt32;
      ShadowPenumbra1VertexCount : SInt32;

      {'Blended' Shadow Fin Geometry} 
      ShadowPenumbra0Fins : PJAVertexPool;
      ShadowPenumbra0FinsCapacity : SInt32;
      ShadowPenumbra0FinsCount : SInt32;
      ShadowPenumbra1Fins : PJAVertexPool;
      ShadowPenumbra1FinsCapacity : SInt32;
      ShadowPenumbra1FinsCount : SInt32;

   end;
   PJAPolygon = ^TJAPolygon;

function JAVertexPoolVertexAdd(AVertexPool : PJAVertexPool) : PVec2SInt16;
function JAVertexPoolClear(AVertexPool : PJAVertexPool) : PJAVertexPool;

function JAPolygonVertexCreate(APolygon : PJAPolygon) : PJAVertex;
function JAPolygonIndexCreate(APolygon : PJAPolygon) : PUInt32;
function JAPolygonClear(APolygon : PJAPolygon) : PJAPolygon;


function JAPolygonIntersectVertex(APolygon : PJAPolygon; AVertex : TVec2) : boolean;

procedure JAShadowFinsCountSet(AShadow: PJAPolygonShadow; AFinsCount : SInt16);
function JAShadowVertexAdd(AShadow : PJAPolygonShadow) : PVec2SInt16;
function JAShadowPenumbra0Add(AShadow : PJAPolygonShadow) : PVec2SInt16;
function JAShadowPenumbra1Add(AShadow : PJAPolygonShadow) : PVec2SInt16;

function JAShadowClear(AShadow : PJAPolygonShadow) : PJAPolygonShadow;

implementation

function JAVertexPoolVertexAdd(AVertexPool: PJAVertexPool) : PVec2SInt16;
var
   NewCapacity : SInt32;
begin
   NewCapacity := AVertexPool^.VertexCapacity;
   if (NewCapacity=0) then NewCapacity := JAPool_BlockSize else
   if (AVertexPool^.VertexCount+1) > NewCapacity then NewCapacity += JAPool_BlockSize;
   if NewCapacity<>AVertexPool^.VertexCapacity then
   begin
     if AVertexPool^.VertexCapacity=0 then
     AVertexPool^.Vertex := JAMemGet(SizeOf(UInt32)*NewCapacity) else
     AVertexPool^.Vertex := reallocmem(AVertexPool^.Vertex, SizeOf(UInt32)*NewCapacity);
     AVertexPool^.VertexCapacity := NewCapacity;
   end;

   {return pointer to Vertexed element}
   Result := @AVertexPool^.Vertex[AVertexPool^.VertexCount];
   AVertexPool^.VertexCount += 1;
end;

function JAVertexPoolClear(AVertexPool: PJAVertexPool) : PJAVertexPool;
begin
   {Leave Memory and Capacity intact ready for reuse}
   AVertexPool^.VertexCount := 0;
end;

function JAPolygonVertexCreate(APolygon : PJAPolygon) : PJAVertex;
var
   NewCapacity : SInt32;
begin
   NewCapacity := APolygon^.VertexCapacity;
   if (NewCapacity=0) then NewCapacity := JAPool_BlockSize else
   if (APolygon^.VertexCount+1) > NewCapacity then NewCapacity += JAPool_BlockSize;
   if NewCapacity<>APolygon^.VertexCapacity then
   begin
      if APolygon^.VertexCapacity=0 then
      begin
         APolygon^.Vertex := JAMemGet(SizeOf(TJAVertex)*NewCapacity);
         APolygon^.WorldVertex := JAMemGet(SizeOf(TVec2)*NewCapacity);
         APolygon^.WorldVertexI := JAMemGet(SizeOf(TVec2SInt16)*NewCapacity);
      end else
      begin
         APolygon^.Vertex := reallocmem(APolygon^.Vertex, SizeOf(TJAVertex)*NewCapacity);
         APolygon^.WorldVertex := reallocmem(APolygon^.WorldVertex, SizeOf(TVec2)*NewCapacity);
         APolygon^.WorldVertexI := reallocmem(APolygon^.WorldVertexI, SizeOf(TVec2SInt16)*NewCapacity);
      end;
     APolygon^.VertexCapacity := NewCapacity;
   end;

   {return pointer to Vertex structure}
   Result := @APolygon^.Vertex[APolygon^.VertexCount];

   {set defaults}
   Result^.Position := vec2zero;
   Result^.Normal := vec2zero;

   APolygon^.WorldVertex[APolygon^.VertexCount] := Vec2(0,0);
   APolygon^.WorldVertexI[APolygon^.VertexCount] := Vec2SInt16(0,0);

   APolygon^.VertexCount += 1;
end;

function JAPolygonIndexCreate(APolygon : PJAPolygon) : PUInt32;
var
   NewCapacity : SInt32;
begin
   NewCapacity := APolygon^.IndexCapacity;
   if (NewCapacity=0) then NewCapacity := JAPool_BlockSize else
   if (APolygon^.IndexCount+1) > NewCapacity then NewCapacity += JAPool_BlockSize;
   if NewCapacity<>APolygon^.IndexCapacity then
   begin
     if APolygon^.IndexCapacity=0 then
     APolygon^.Index := JAMemGet(SizeOf(UInt32)*NewCapacity) else
     APolygon^.Index := reallocmem(APolygon^.Index, SizeOf(UInt32)*NewCapacity);
     APolygon^.IndexCapacity := NewCapacity;
   end;
   {return pointer to indexed element}
   Result := @APolygon^.Index[APolygon^.IndexCount];
   APolygon^.IndexCount += 1;
end;

function JAPolygonClear(APolygon : PJAPolygon) : PJAPolygon;
var
   I : SInt16;
begin
   APolygon^.VertexCount := 0;
   APolygon^.IndexCount := 0;
   APolygon^.Style.Visible := true;
   APolygon^.Style.Fill := JColourUInt8(255,0,255,255);
   APolygon^.Style.Stroke := JColourUInt8(0,0,0,255);
   APolygon^.Style.PenIndex := -1;

   {$IFDEF JA_ENABLE_SHADOW}
   APolygon^.ShadowCast := false;
   {Setup Shadow Array}
   if (APolygon^.Shadows=nil) then
   begin
      APolygon^.ShadowsCount := JAShadowsPerPolygon;
      APolygon^.Shadows := JAMemGet(SizeOf(TJAPolygonShadow)*APolygon^.ShadowsCount);
   end;

   {Reset Shadows}
   if (APolygon^.Shadows<>nil) then
      for I := 0 to APolygon^.ShadowsCount-1 do
      begin
         {Umbras (always solid)}
         APolygon^.Shadows[I].ShadowVertexCount := 0;
         APolygon^.Shadows[I].ShadowVertexCapacity := 0;
         APolygon^.Shadows[I].ShadowVertex := nil;

         {'Solid' Penumbras}
         APolygon^.Shadows[I].ShadowPenumbra0Vertex := nil;
         APolygon^.Shadows[I].ShadowPenumbra0VertexCapacity := 0;
         APolygon^.Shadows[I].ShadowPenumbra0VertexCount := 0;
         APolygon^.Shadows[I].ShadowPenumbra1Vertex := nil;
         APolygon^.Shadows[I].ShadowPenumbra1VertexCapacity := 0;
         APolygon^.Shadows[I].ShadowPenumbra1VertexCount := 0;

         {'Blended' Shadow Fins}
         APolygon^.Shadows[I].ShadowPenumbra0Fins := nil;
         APolygon^.Shadows[I].ShadowPenumbra0FinsCount := 0;
         APolygon^.Shadows[I].ShadowPenumbra0FinsCapacity := 0;
         APolygon^.Shadows[I].ShadowPenumbra1Fins := nil;
         APolygon^.Shadows[I].ShadowPenumbra1FinsCount := 0;
         APolygon^.Shadows[I].ShadowPenumbra1FinsCapacity := 0;

         JAShadowClear(@APolygon^.Shadows[I]);
         JAShadowFinsCountSet(@APolygon^.Shadows[I], 3);
      end;
   {$ENDIF}

   Result := APolygon;
end;

function JAPolygonIntersectVertex(APolygon: PJAPolygon; AVertex: TVec2): boolean;
var
   I, J, NVert : SInt32;
   C : Boolean;
begin
   NVert := APolygon^.VertexCount;
   C := false;
   I := 0;
   J := NVert-1;
   with APolygon^ do
   for I := 0 to APolygon^.VertexCount-1 do
   begin
      if ((WorldVertex[I].Y >= AVertex.Y) <> (WorldVertex[J].Y >= AVertex.Y)) and
         (AVertex.X <= (WorldVertex[J].X - WorldVertex[I].X) * (AVertex.Y - WorldVertex[I].Y) /
         (WorldVertex[J].Y - WorldVertex[I].Y) + WorldVertex[I].X) then
         C := not C;
      J := I;
   end;
   Result := C;
end;

procedure JAShadowFinsCountSet(AShadow: PJAPolygonShadow; AFinsCount : SInt16);
var
   NewCapacity : SInt32;
   I : SInt16;
begin
   NewCapacity := AShadow^.ShadowPenumbra0FinsCapacity;
   if (NewCapacity=0) then NewCapacity := JAPool_BlockSize else
   if (AFinsCount) > NewCapacity then NewCapacity += JAPool_BlockSize;

   if NewCapacity<>AShadow^.ShadowPenumbra0FinsCapacity then
   begin
      if AShadow^.ShadowPenumbra0FinsCapacity=0 then
      begin
         AShadow^.ShadowPenumbra0Fins := JAMemGet(SizeOf(TJAVertexPool)*NewCapacity);
      end else
      begin
         AShadow^.ShadowPenumbra0Fins := reallocmem(AShadow^.ShadowPenumbra0Fins, SizeOf(TJAVertexPool)*NewCapacity);
      end;
   end;

   if NewCapacity<>AShadow^.ShadowPenumbra1FinsCapacity then
   begin
      if AShadow^.ShadowPenumbra1FinsCapacity=0 then
      begin
         AShadow^.ShadowPenumbra1Fins := JAMemGet(SizeOf(TJAVertexPool)*NewCapacity);
      end else
      begin
         AShadow^.ShadowPenumbra1Fins := reallocmem(AShadow^.ShadowPenumbra1Fins, SizeOf(TJAVertexPool)*NewCapacity);
      end;
   end;

   if NewCapacity>AShadow^.ShadowPenumbra0FinsCapacity then
   for I := AShadow^.ShadowPenumbra0FinsCapacity to NewCapacity-1 do
   begin
      AShadow^.ShadowPenumbra0Fins[I].Vertex := nil;
      AShadow^.ShadowPenumbra0Fins[I].VertexCapacity := 0;
      AShadow^.ShadowPenumbra0Fins[I].VertexCount := 0;
   end;

   if NewCapacity>AShadow^.ShadowPenumbra1FinsCapacity then
   for I := AShadow^.ShadowPenumbra1FinsCapacity to NewCapacity-1 do
   begin
      AShadow^.ShadowPenumbra1Fins[I].Vertex := nil;
      AShadow^.ShadowPenumbra1Fins[I].VertexCapacity := 0;
      AShadow^.ShadowPenumbra1Fins[I].VertexCount := 0;
   end;

   AShadow^.ShadowPenumbra0FinsCapacity := NewCapacity;
   AShadow^.ShadowPenumbra0FinsCount := AFinsCount;
   AShadow^.ShadowPenumbra1FinsCapacity := NewCapacity;
   AShadow^.ShadowPenumbra1FinsCount := AFinsCount;
end;

function JAShadowVertexAdd(AShadow : PJAPolygonShadow) : PVec2SInt16;
var
   NewCapacity : SInt32;
begin
   NewCapacity := AShadow^.ShadowVertexCapacity;
   if (NewCapacity=0) then NewCapacity := JAPool_BlockSize else
   if (AShadow^.ShadowVertexCount+1) > NewCapacity then NewCapacity += JAPool_BlockSize;
   if NewCapacity<>AShadow^.ShadowVertexCapacity then
   begin
      if AShadow^.ShadowVertexCapacity=0 then
      begin
         AShadow^.ShadowVertex := JAMemGet(SizeOf(TVec2SInt16)*NewCapacity);
      end else
      begin
         AShadow^.ShadowVertex := reallocmem(AShadow^.ShadowVertex, SizeOf(TVec2SInt16)*NewCapacity);
      end;
     AShadow^.ShadowVertexCapacity := NewCapacity;
   end;

   Result := @AShadow^.ShadowVertex[AShadow^.ShadowVertexCount];

   AShadow^.ShadowVertexCount += 1;
end;

function JAShadowPenumbra0Add(AShadow: PJAPolygonShadow): PVec2SInt16;
begin

end;

function JAShadowPenumbra1Add(AShadow: PJAPolygonShadow): PVec2SInt16;
begin

end;

function JAShadowClear(AShadow: PJAPolygonShadow): PJAPolygonShadow;
begin
   {Leave Memory and Capacity intact ready for reuse}
   AShadow^.ShadowVertexCount := 0;
   AShadow^.ShadowVertexStart := -1;
   AShadow^.ShadowVertexEnd := -1;  
   AShadow^.ShadowPenumbra0FinsCount := 0;
   AShadow^.ShadowPenumbra1FinsCount := 0;
   AShadow^.ShadowPenumbra0Index := 0;
   AShadow^.ShadowPenumbra1Index := 0;          
end;

end.
