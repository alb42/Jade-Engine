unit JAToy;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   JATypes, JANode;

type
   TJAToy = record
      RootNode : PJANode;
      Data : Pointer;
   end;
   PJAToy = ^TJAToy;

implementation

end.

