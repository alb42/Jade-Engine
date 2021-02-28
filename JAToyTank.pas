unit JAToyTank;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   JATypes, JAPolygon, JAPolygonTools, JASketch, JASketchTools,
   JANode, JAScene, JAToy;

type
   TJAToyTank = record
      BodyNode : PJANode;
      TurretNode : PJANode;
      BarrelNode : PJANode;
      BarrelTipNode : PJANode;
      Scene : PJAScene;
      Parent : PJANode;
   end;
   PJAToyTank = ^TJAToyTank;

function JAToyTankCreate(AScene : PJAScene; AParentNode : PJANode) : PJAToyTank;
function JAToyTankDestroy(AToyTank : PJAToyTank) : boolean;

implementation

function JAToyTankCreate(AScene : PJAScene; AParentNode : PJANode) : PJAToyTank;
var
   Polygon : PJAPolygon;
begin
   Result := JAMemGet(SizeOf(TJAToyTank));
   with Result^ do
   begin
      Scene := AScene; {store local reference}
      Parent := AParentNode;

      BodyNode := JANodeNodeCreate(AParentNode, JANode_Sketch);
      Polygon := JASketchPolygonCreate(PJANodeDataSketch(BodyNode^.Data)^.Sketch);
      JAPolygonMakeRect(Polygon, JRect(-30,-55,30,55));
      Polygon^.Style.PenIndex := 5;
      //JAPolygonMakeSpaceShip(Polygon, 50);

      TurretNode := JANodeNodeCreate(BodyNode, JANode_Sketch);
      Polygon := JASketchPolygonCreate(PJANodeDataSketch(TurretNode^.Data)^.Sketch);
      JAPolygonMakeCircle(Polygon,vec2(0,0),30,9);
      Polygon^.Style.PenIndex := 5;

      BarrelNode := JANodeNodeCreate(TurretNode, JANode_Sketch);
      Polygon := JASketchPolygonCreate(PJANodeDataSketch(BarrelNode^.Data)^.Sketch);
      JAPolygonMakeRect(Polygon, JRect(-2,0,2,70));
      Polygon^.Style.PenIndex := 5;

   end;
end;

function JAToyTankDestroy(AToyTank : PJAToyTank) : boolean;
begin
   JAMemFree(AToyTank,SizeOf(TJAToyTank));
end;

end.

