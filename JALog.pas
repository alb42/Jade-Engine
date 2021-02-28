unit JALog;
{$mode objfpc}{$H+}
{$i JA.inc}
interface

uses
   {fpc} SysUtils,
   {Amiga} Exec, Utility,
	{JAE} JATypes;

procedure Log(ACaller, AMessage : string); overload;
function Log(ACaller, AMessage : string; AValues : array of const) : boolean; overload;
implementation

const
   ConsoleReset = #27+'c';
   ConsoleBold = #27+'[1m';
   ConsoleItalic = #27+'[3m';
   ConsoleUnderline = #27+'[4m';
   ConsoleBoldOff = #27+'[22m';
   ConsoleItalicOff = #27+'[23m';
   ConsoleUnderlineOff = #27+'[24m';
   ConsoleClearToEndOfWindow = #27 + '[J';
   ConsoleMoveCursorHome = #27 + '[0;0H';

function ClearColour(AClearColour : SInt32) : string;
begin
   Result := #27 + '[>' + IntToStr(AClearColour) + 'm';
end;

function SetColours(AForeground, ABackground : SInt32) : string;
begin
   Result := #27+'[3' + IntToStr(AForeground)+ ';4' + IntToStr(ABackground) + 'm';
end;

function SetTextColour(AColorIndex : SInt32) : string;
begin
   Result := #27+'[3'+IntToStr(AColorIndex)+'m';
end;

function SetBackgroundColour(AColorIndex : SInt32) : string;
begin
   Result := #27+'[4'+IntToStr(AColorIndex)+'m';
end;

function SetTextPixelX(AX : SInt32) : string;
begin
   Result := #27+'['+IntToStr(AX)+'x';
end;

function SetTextPixelY(AY : SInt32) : string;
begin
   Result := #27+'['+IntToStr(AY)+'y';
end;

procedure Log(ACaller, AMessage : string);
begin
   writeln(SetTextColour(3)+ACaller + SetTextColour(2)+' - ' + SetTextColour(0)+AMessage);
end;

function Log(ACaller, AMessage : string; AValues : array of const) : boolean;
var
   FormattedMessage : string;
begin
   FormattedMessage := format(AMessage, AValues);
   Log(ACaller, FormattedMessage);
end;

initialization
   {Clear the screen}
   write(ClearColour(1)); {clear to black}
   write(SetColours(2,1)); {White on Black}
   write(ConsoleMoveCursorHome);
   write(ConsoleClearToEndOfWindow);

finalization
   write(SetColours(2,1));

end.

