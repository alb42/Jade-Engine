unit JAToyFish;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   JATypes, JANode, JAToy;

type
   TJAToyFish = record
      Node : PJANode;
   end;
   PJAToyFish = ^TJAToyFish;

function JAToyFishCreate() : PJAToyFish;
function JAToyFishDestroy(AToyFish : PJAToyFish) : boolean;
function JAToyFishUpdate(AToyFish : PJAToyFish; ADelta : Float32) : Float32;

implementation

function JAToyFishCreate() : PJAToyFish;
begin

end;

function JAToyFishDestroy(AToyFish : PJAToyFish) : boolean;
begin

end;

function JAToyFishUpdate(AToyFish : PJAToyFish; ADelta : Float32) : Float32;
begin

end;

end.

