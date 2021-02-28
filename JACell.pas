unit JACell;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   JATypes, JAList, JASpatial;

type
   PJACell = ^TJACell;
   
   TJACellLeaf = record
   	Cell : PJACell;
   	GridPosition : TVec2SInt16;
		Neighbours : PJACell; {}
	end;
	PJACellLeaf = ^TJACellLeaf;
   
   TJACell = record
      Split : boolean;
		Depth : SInt16;
			
		BoundsRect : TJRectSInt32;
		BoundsRadius : Float32;
		
		Cells : PJACell; {child cells}
		
		Leaf : PJACellLeaf; {assigned if leaf cell} 
		                
      Nodes : PJAList; {nodes inside this cell}
      NodesCount : UInt16;
      
      
      PathCost : Float32;
      PathBlock : boolean;
      
      Data : pointer;
   end;

function JACellCreate() : PJACell;
function JACellDestroy(ACell : PJACell) : boolean;

function JACellSplit(ACell : PJACell; AMinimumSize : Float32 =1.0) : SInt32; {recursively split down to a minimum size}
//procedure Split(AMinimumSize : JFloat32=1.0); virtual; abstract;
//procedure Combine; virtual; abstract;{collect all child entites then remove child nodes}
//function HitTest(APosition : TVec3):boolean; {test if vertex inside Node}
//function GetLeaf(APosition : TVec3):TJSpatialNode; virtual;
      
function JACellNodePush(ACell : PJACell; ANode : PJASpatial) : PJACell; {returns absolute leaf cell for the pushed node}
function JACellNodeExtract(ACell : PJACell; ANode : PJASpatial) : PJASpatial; {returns extracted node or nil on no extraction}
function JACellNodePick(ACell : PJACell; APosition : TVec2; ARadius : Float32) : PJASpatial; {returns result node or nil if no match}

implementation

function JACellCreate : PJACell;
begin
	Result := JAMemGet(SizeOf(TJACell));
end;

function JACellDestroy(ACell : PJACell) : boolean;
begin
	JAMemFree(ACell,SizeOf(TJACell));
end;

function JACellSplit(ACell : PJACell; AMinimumSize : Float32) : SInt32;
var
   I : SInt32;
   BoundingBoxes : array of TJBBox;
begin
   //ExtractAABBCorners(AABB,AABBCorners);
   {if any accuracy issues creep in, -0.1 from box width}
{   if (FNodeBoundingBox.Max.X-FNodeBoundingBox.Min.X) > AMinimumSize then {split}
   begin
      SetLength(BoundingBoxes, FNodeCount);
      with FNodeBoundingBox do
      begin
         BoundingBoxes[0].Min.X := Min.X;
         BoundingBoxes[0].Max.X := (Max.X-Min.X)*0.5+Min.X;
         BoundingBoxes[0].Min.Z := Min.Z;
         BoundingBoxes[0].Max.Z := (Max.Z-Min.Z)*0.5+Min.Z;

         BoundingBoxes[1].Min.X := (Max.X-Min.X)*0.5+Min.X;
         BoundingBoxes[1].Max.X := Max.X;
         BoundingBoxes[1].Min.Z := Min.Z;
         BoundingBoxes[1].Max.Z := (Max.Z-Min.Z)*0.5+Min.Z;

         BoundingBoxes[2].Min.X := Min.X;
         BoundingBoxes[2].Max.X := (Max.X-Min.X)*0.5+Min.X;
         BoundingBoxes[2].Min.Z := (Max.Z-Min.Z)*0.5+Min.Z;
         BoundingBoxes[2].Max.Z := Max.Z;

         BoundingBoxes[3].Min.X := (Max.X-Min.X)*0.5+Min.X;
         BoundingBoxes[3].Max.X := Max.X;
         BoundingBoxes[3].Min.Z := (Max.Z-Min.Z)*0.5+Min.Z;
         BoundingBoxes[3].Max.Z := Max.Z;

         BoundingBoxes[0].Min.Y := Min.Y;
         BoundingBoxes[1].Min.Y := Min.Y;
         BoundingBoxes[2].Min.Y := Min.Y;
         BoundingBoxes[3].Min.Y := Min.Y;

         BoundingBoxes[0].Max.Y := Max.Y;
         BoundingBoxes[1].Max.Y := Max.Y;
         BoundingBoxes[2].Max.Y := Max.Y;
         BoundingBoxes[3].Max.Y := Max.Y;
      end;

      for I := 0 to 3 do
      begin
         FNodes[I] := TJSpatialNodeQuad.Create(BoundingBoxes[I], Self, FNodeDepth+1);
         FNodes[I].Split(AMinimumSize);
      end;

      FNodeSplit := true;

   end;  }
end;

function JACellNodePush(ACell : PJACell; ANode : PJASpatial) : PJACell;
begin

end;

function JACellNodeExtract(ACell : PJACell; ANode : PJASpatial) : PJASpatial;
begin

end;

function JACellNodePick(ACell : PJACell; APosition : TVec2; ARadius : Float32) : PJASpatial;
begin

end;

end.

