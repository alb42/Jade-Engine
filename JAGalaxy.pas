unit JAGalaxy;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   JATypes, JAMath, JAList,
   JARender, JAPolygon, JAPolygonTools, JASketch,
   JASpatial, JANode,
   JAEngine;

type
   PJAGalaxySystem = ^TJAGalaxySystem;
   TJAGalaxySystem = record
      Node : PJANode; {Node in scene graph}
      Spatial : PJASpatial; {Spatial of Node}
      HyperLanes : array[0..3] of PJAGalaxySystem; {Array of Lanes to other Systems}
      HyperLanesCount : UInt16;
   end;

   TJAGalaxySystemQuery = record
      System : PJAGalaxySystem;
      DistanceCrow : Float32;
      DistancePath : Float32;
   end;
   PJAGalaxySystemQuery = ^TJAGalaxySystemQuery;


   TJAGalaxyHyperLane = record
      SystemA : PJAGalaxySystem;
      SystemB : PJAGalaxySystem;
      LaneLength : Float32;
   end;
   PJAGalaxyHyperLane = ^TJAGalaxyHyperLane;

   TJAGalaxy = record
      Systems : PJAGalaxySystem; {Array of Systems}
      SystemsCount : SInt16;
      SystemsQuery : PJAGalaxySystemQuery;
      SystemsQueryCount : SInt16;

      HyperLanes : PJAGalaxyHyperLane; {Array of HyperLanes}
      HyperLanesCount : UInt16;

      {Generator Variables}
      GenRings : PUInt16;
      GenRingsCount : UInt16;
   end;
   PJAGalaxy = ^TJAGalaxy;

function JAGalaxyCreate(AEngine : PJAEngine) : PJAGalaxy;
function JAGalaxyDestroy(AGalaxy : PJAGalaxy) : boolean;

function JAGalaxyRender(AGalaxy : PJAGalaxy) : Float32;

function SystemQueryClosest(AGalaxy : PJAGalaxy; ASystem : PJAGalaxySystem; ALo, AHi: SInt32) : UInt16;

function LinkSystems(AGalaxy : PJAGalaxy; ASystemA, ASystemB : PJAGalaxySystem) : PJAGalaxyHyperLane;
function SystemsAreLinked(ASystemA, ASystemB : PJAGalaxySystem) : boolean;
function LinkWouldCrossLink(AGalaxy : PJAGalaxy; ASystemA, ASystemB : PJAGalaxySystem) : boolean;
function LinkWouldCreateShallowAngle(AGalaxy : PJAGalaxy; ASystemA, ASystemB : PJAGalaxySystem; MinAngle : Float32) : boolean;


implementation

function JAGalaxyCreate(AEngine : PJAEngine) : PJAGalaxy;
var
   I,J,K : SInt32;
   Vec : TVec2;
   Polygon : PJAPolygon;
   NodeRoot,Node,NodePrevious : PJANode;

   RingDivisionAngle : Float32;
   RingAngle : Float32;

   SystemsIndex : UInt16;
   System : PJAGalaxySystem;

   SystemA, SystemB, SystemC, SystemD, SystemE : PJAGalaxySystem;
begin
   Result := JAMemGet(SizeOf(TJAGalaxy));

   with Result^ do
   begin
      SystemsIndex := 0;
      SystemsCount := 32; {will change}
      HyperLanesCount := 2048; {will change}

      {Generator Variables}
      GenRingsCount := 6;//SystemsCount div 4;
      GenRings := JAMemGet(SizeOf(UInt16) * GenRingsCount);
      GenRings[0] := 3; {inner ring has 3 systems}

      SystemsCount := GenRings[0];
      {Set Ring System Counts}
      for I := 1 to GenRingsCount-1 do
      begin
         GenRings[I] := GenRings[I-1]+3; {three more than previous ring}
         SystemsCount += GenRings[I];
      end;

      SystemsQueryCount := SystemsCount;

      Systems := JAMemGet(SizeOf(TJAGalaxySystem) * SystemsCount); {Array of Systems / Pointers to Nodes}
      SystemsQuery := JAMemGet(SizeOf(TJAGalaxySystemQuery) * SystemsCount);

      HyperLanes := JAMemGet(SizeOf(TJAGalaxyHyperLane) * HyperLanesCount); {Array of HyperLane Records}
      HyperLanesCount := 0; {Index}

      {Generate Systems}
      NodeRoot := AEngine^.Scene^.RootNode;
      for J := 0 to GenRingsCount-1 do
      begin
         RingAngle := ((360/GenRingsCount)/3) * (J+1);
         RingDivisionAngle := 360 / GenRings[J];

         for I := 0 to GenRings[J]-1 do
         begin
            Node := JANodeNodeCreate(NodeRoot, JANode_Sketch);
            RingAngle := RingAngle + RingDivisionAngle;// - (Random * RingDivisionAngle * 2);
            Vec := Vec2Rotate( (Vec2Up) * (400*(J+1) - (100*random)), RingAngle -(Random*(RingDivisionAngle/3)));
            JANodeSetLocalPosition(Node, Vec);
            Polygon := JASketchPolygonCreate(PJANodeDataSketch(Node^.Data)^.Sketch);
            JAPolygonMakeCircle(Polygon,vec2(0,0),10,5);
            Polygon^.Style.PenIndex := 1;//JARenderPenSet^.PenGreen^.Index;
            Node^.Spatial.LocalBRadius := 10;

            Systems[SystemsIndex].Node := Node;
            Systems[SystemsIndex].Spatial := @Node^.Spatial;
            Systems[SystemsIndex].HyperLanesCount := 0;
            SystemsQuery[SystemsIndex].System := @Systems[SystemsIndex];
            SystemsQuery[SystemsIndex].DistanceCrow := 0;
            SystemsQuery[SystemsIndex].DistancePath := 0;
            SystemsIndex += 1;
         end;
      end;


      {Generate HyperLanes}

      for I := 0 to SystemsCount-1 do
      begin
         System := @Systems[I];

         {calculate the distances}
         for K := 0 to Result^.SystemsCount-1 do
         begin
            if SystemsQuery[K].System = System then
               SystemsQuery[K].DistanceCrow := 0.0 else
               SystemsQuery[K].DistanceCrow := Vec2Length(System^.Spatial^.LocalPosition - SystemsQuery[K].System^.Spatial^.LocalPosition);
         end;

         SystemQueryClosest(Result, System, 0, SystemsCount-1);

         for K := 1 to 5 do
         begin
            if not SystemsAreLinked(System, SystemsQuery[K].System) then
            if not LinkWouldCrossLink(Result, System, SystemsQuery[K].System) then
            if not LinkWouldCreateShallowAngle(Result, System, SystemsQuery[K].System, 25) then
   				LinkSystems(Result, System, SystemsQuery[K].System);
         end;
      end;
   end;
end;

function JAGalaxyDestroy(AGalaxy : PJAGalaxy) : boolean;
begin
   JAMemFree(AGalaxy,SizeOf(TJAGalaxy));
end;

function JAGalaxyRender(AGalaxy : PJAGalaxy) : Float32;
begin

end;

function SystemQueryClosest(AGalaxy : PJAGalaxy; ASystem : PJAGalaxySystem; ALo, AHi: SInt32) : UInt16;
var
   I : SInt16;
   SystemDistance : Float32;
   Lo, Hi : SInt32;
   Pivot,T : TJAGalaxySystemQuery;
begin
   with AGalaxy^ do
   begin
      Lo := ALo;
      Hi := AHi;
      Pivot := SystemsQuery[(Lo + Hi) div 2];
      repeat
         while (SystemsQuery[Lo].DistanceCrow < Pivot.DistanceCrow) do
          Lo+=1;
        while (SystemsQuery[Hi].DistanceCrow > Pivot.DistanceCrow) do
          Hi-=1;
        if Lo <= Hi then
        begin
          T := SystemsQuery[Lo];
          SystemsQuery[Lo] := SystemsQuery[Hi];
          SystemsQuery[Hi] := T;
          Lo+=1;
          Hi-=1;
        end;
      until Lo > Hi;
      if Hi > aLo then
        SystemQueryClosest(AGalaxy, ASystem, ALo, Hi);
      if Lo < ahi then
        SystemQueryClosest(AGalaxy, ASystem, Lo, AHi);
   end;
end;

function LinkSystems(AGalaxy : PJAGalaxy; ASystemA, ASystemB : PJAGalaxySystem) : PJAGalaxyHyperLane;
var
   I : SInt16;
begin
   if (ASystemA^.HyperLanesCount < Length(ASystemA^.HyperLanes)) and
      (ASystemB^.HyperLanesCount < Length(ASystemB^.HyperLanes)) then
   begin
      ASystemA^.HyperLanes[ASystemA^.HyperLanesCount] := ASystemB;
      ASystemA^.HyperLanesCount += 1;

      ASystemB^.HyperLanes[ASystemB^.HyperLanesCount] := ASystemA;
      ASystemB^.HyperLanesCount += 1;

      AGalaxy^.HyperLanes[AGalaxy^.HyperLanesCount].SystemA := ASystemA;
      AGalaxy^.HyperLanes[AGalaxy^.HyperLanesCount].SystemB := ASystemB;

      AGalaxy^.HyperLanes[AGalaxy^.HyperLanesCount].LaneLength :=
         Vec2Distance(ASystemA^.Spatial^.LocalPosition, ASystemB^.Spatial^.LocalPosition);

      AGalaxy^.HyperLanesCount += 1;
   end;
end;

function SystemsAreLinked(ASystemA, ASystemB : PJAGalaxySystem) : boolean;
var
   I : SInt16;
begin
   Result := false;
   if ASystemA=nil then exit(true);
   if ASystemB=nil then exit(true);
   for I := 0 to ASystemA^.HyperLanesCount-1 do
   begin
      if (ASystemA^.HyperLanes[I] = ASystemB) then exit(true);
   end;
end;

(*
bool isIntersecting(Point& p1, Point& p2, Point& q1, Point& q2) {
    return (((q1.x-p1.x)*(p2.y-p1.y) - (q1.y-p1.y)*(p2.x-p1.x))
            * ((q2.x-p1.x)*(p2.y-p1.y) - (q2.y-p1.y)*(p2.x-p1.x)) < 0)
            &&
           (((p1.x-q1.x)*(q2.y-q1.y) - (p1.y-q1.y)*(q2.x-q1.x))
            * ((p2.x-q1.x)*(q2.y-q1.y) - (p2.y-q1.y)*(q2.x-q1.x)) < 0);
}

inline bool lines_intersect_2d(Vector2 const& p0, Vector2 const& p1, Vector2 const& p2, Vector2 const& p3, Vector2* i const = 0) {
    Vector2 const s1 = p1 - p0;
    Vector2 const s2 = p3 - p2;
    Vector2 const u = p0 - p2;

    float const ip = 1.f / (-s2.x * s1.y + s1.x * s2.y);

    float const s = (-s1.y * u.x + s1.x * u.y) * ip;
    float const t = ( s2.x * u.y - s2.y * u.x) * ip;
    
    if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
        if (i) *i = p0 + (s1 * t);
        return true;
    }
    return false;
}
*)
(*
float Signed2DTriArea(Point a, Point b, Point c)
{
    return (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
}

int Test2DSegmentSegment(Point a, Point b, Point c, Point d, float &t, Point &p)
{
    // signs of areas correspond to which side of ab points c and d are
    float a1 = Signed2DTriArea(a,b,d); // Compute winding of abd (+ or -)
    float a2 = Signed2DTriArea(a,b,c); // To intersect, must have sign opposite of a1

    // If c and d are on different sides of ab, areas have different signs
    if( a1 * a2 < 0.0f ) // require unsigned x & y values.
    {
        float a3 = Signed2DTriArea(c,d,a); // Compute winding of cda (+ or -)
        float a4 = a3 + a2 - a1; // Since area is constant a1 - a2 = a3 - a4, or a4 = a3 + a2 - a1

        // Points a and b on different sides of cd if areas have different signs
        if( a3 * a4 < 0.0f )
        {
            // Segments intersect. Find intersection point along L(t) = a + t * (b - a).
            t = a3 / (a3 - a4);
            p = a + t * (b - a); // the point of intersection
            return 1;
        }
    }

    // Segments not intersecting or collinear
    return 0;
}
*)


function lines_intersect_2d(p0, p1, p2, p3 : TVec2; I : PVec2=nil) : boolean;
var
	s1,s2,u : TVec2;
	ip : Float32;
	s,t : Float32;
begin
	result := false;
    s1 := p1 - p0;
    s2 := p3 - p2;
    u := p0 - p2;

    ip := 1.0 / (-s2.x * s1.y + s1.x * s2.y);

    s := (-s1.y * u.x + s1.x * u.y) * ip;
    t := ( s2.x * u.y - s2.y * u.x) * ip;
    
    {we shave a little off here since many lines are 'touching'}
    if ((s >= 0.02) and (s <= 0.98) and (t >= 0.02) and (t <= 0.98)) then
	 //if ((s >= 0) and (s <= 1) and (t >= 0) and (t <= 1)) then    
    begin
       if I<>nil then I^ := p0 + (s1 * t); 
       exit(true);      
    end    
end;

function LinkWouldCrossLink(AGalaxy : PJAGalaxy; ASystemA, ASystemB : PJAGalaxySystem) : boolean;
var
	I : SInt16;
begin
	Result := false;
	for I := 0 to AGalaxy^.HyperLanesCount-1 do
	begin
	   if lines_intersect_2d(
		ASystemA^.Spatial^.LocalPosition, ASystemB^.Spatial^.LocalPosition,
		AGalaxy^.HyperLanes[I].SystemA^.Spatial^.LocalPosition,
		AGalaxy^.HyperLanes[I].SystemB^.Spatial^.LocalPosition, nil) then 
			exit(true); 		
	end;
end;

function LinkWouldCreateShallowAngle(AGalaxy : PJAGalaxy;  ASystemA, ASystemB : PJAGalaxySystem; MinAngle : Float32) : boolean;
var
   I : SInt16;
   ProposedAngle : Float32;
   LinkAngle : Float32;
   ProposedVector : TVec2;
   LinkVector : TVec2;
begin
   Result := false;
   ProposedVector := Vec2Normalize(ASystemA^.Spatial^.LocalPosition - ASystemB^.Spatial^.LocalPosition);
   for I := 0 to ASystemA^.HyperLanesCount-1 do
   begin
      LinkVector := Vec2Normalize(ASystemA^.Spatial^.LocalPosition - ASystemA^.HyperLanes[I]^.Spatial^.LocalPosition);
      LinkAngle := Vec2Angle(ProposedVector, LinkVector) * JRadToDeg;
      if abs(LinkAngle) < MinAngle then exit(true);
   end;
   
   ProposedVector := Vec2Normalize(ASystemB^.Spatial^.LocalPosition - ASystemA^.Spatial^.LocalPosition);
   for I := 0 to ASystemB^.HyperLanesCount-1 do
   begin
      LinkVector := Vec2Normalize(ASystemB^.Spatial^.LocalPosition - ASystemB^.HyperLanes[I]^.Spatial^.LocalPosition);
      LinkAngle := Vec2Angle(ProposedVector, LinkVector) * JRadToDeg;
      if abs(LinkAngle) < MinAngle then exit(true);
   end;
end;

end.
