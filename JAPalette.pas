unit JAPalette;
{$mode objfpc}{$H+}
{$i JA.inc}

{This is for managing the Amiga's Colour Registers. Each register is an
entry of a Palette. OCS Amiga's are limited to 32 Colour Registers.}

interface

uses
   sysutils, math,
   {Amiga} Exec, Intuition, AGraphics, Utility, picasso96api,
   {JAE} JATypes, JAMath, JALog;

type
   TJAPaletteMask = record
      Index : UInt8;
      Mask : UInt8;
   end;
   PJAPaletteMask = ^TJAPaletteMask;

   TJAPaletteLight = record
      Colour : TJColour3UInt8;
      Index : UInt8;
      Mask : UInt8;
   end;
   PJAPaletteLight = ^TJAPaletteLight;

   TJAPalette = record
      ViewPort : pViewPort; {Viewport of this Palette}
      ColourMap : pColorMap; {ColourMap of this Palette}

      SaveColorMap: Boolean;
      oldColours: array[0..255] of record
        r: LongWord;
        G: LongWord;
        B: LongWord;
      end;

      Colours : PJColour3UInt8; {1:1 Hardware/Software Palette Array}
      ColourCount : SInt16; {how many entries does the palette have}

      PenBlack : SInt16;
      PenRed : SInt16;
      PenGreen : SInt16;
      PenBlue : SInt16;
      PenWhite : SInt16;
      PenGrey : SInt16;

      PenYellow : SInt16;

      {$IFDEF JA_ENABLE_SHADOW}
      Bands : PJAPaletteMask; {Colour Bands - light levels, color mixing etc}
      BandCount : SInt16; {how many Bands is the palette divided into}
      BandColourCount : SInt16; {how many colours in each band}
      Lights : PJAPaletteLight; {Band Indices for Lights}
      LightCount : SInt16; {Number of Lights in this Palette}
      {$ENDIF}
   end;
   PJAPalette = ^TJAPalette;

var
   Palette : PJAPalette;

function JAPaletteCreate(AViewPort : pViewPort; AColourMap : pColorMap; AColourCount, ABandCount, ALightCount : SInt16; ASaveColorMap: Boolean) : PJAPalette;
function JAPaletteDestroy(APalette : PJAPalette) : boolean;

procedure JAPaletteSetColour(APalette : PJAPalette; AColourIndex : SInt16; AColour : TJColour3UInt8);
procedure JAPaletteBandModulate(APalette : PJAPalette; ASourceBand, ADestinationBand : SInt16; AModulation : TJColour3UInt8);
procedure JAPaletteLightSetColour(APalette : PJAPalette; ALightIndex : SInt16; AColour : TJColour3UInt8);

{Setup the a colour within all colour bands for band lighting mode}
procedure JAPaletteBandSetColour(AIndex : SInt16; AColour : TJColour3UInt8);
procedure JAPaletteBandLightCascade(APalette : PJAPalette; ARootBandIndex : SInt16; ACascadeCount : SInt16; ACascadeFactor : Float32);
{setup the palette for mixing the colour of multiple lights}
procedure JAPaletteSetupLights(ALight0, ALight1, ALight2 : TJColour; ABandIndexStart : SInt16);

implementation

function ColourMix(A,B : TJColour3UInt8) : TJColour3UInt8;
begin

   {Additive}
   Result.R := JClamp((A.R + B.R),0,255);
   Result.G := JClamp((A.G + B.G),0,255);
   Result.B := JClamp((A.B + B.B),0,255);

   {Average}
   {
   Result.R := (A.R + B.R) div 2;
   Result.G := (A.G + B.G) div 2;
   Result.B := (A.B + B.B) div 2;
   }
end;

function JAPaletteCreate(AViewPort: pViewPort; AColourMap: pColorMap; AColourCount, ABandCount, ALightCount : SInt16; ASaveColorMap: Boolean): PJAPalette;
var
   I,K : SInt16;
   ColourRegister : SInt16;

   ARed : TJColour3UInt8;
   AGreen : TJColour3UInt8;
   ABlue : TJColour3UInt8;
   AWhite : TJColour3UInt8;
   AGrey : TJColour3UInt8;
   AYellow : TJColour3UInt8;
   AModulate : TJColour3UInt8;

   L0,L1,L2 : UInt8;
begin

   Log('JAPaletteCreate','Creating Palette');
   Result := PJAPalette(JAMemGet(SizeOf(TJAPalette)));
   with Result^ do
   begin
      Viewport := AViewPort;
      ColourMap := AColourMap;
      ColourCount := AColourCount;
      SaveColorMap := ASaveColorMap;
      if ASaveColorMap then
      begin
        // save the old colormap if not on Screen
        GetRGB32(Viewport^.ColorMap, 0, 256, @oldColours[0]);
      end;

      {Get Memory for Arrays}
      Colours := JAMemGet(SizeOf(TJColour3UInt8) * ColourCount);


      {$IFDEF JA_ENABLE_SHADOW}
      BandCount := ABandCount;
      LightCount := ALightCount;
      BandColourCount := 8;


      Bands := JAMemGet(SizeOf(TJAPaletteMask) * BandCount);
      Lights := JAMemGet(SizeOf(TJAPaletteLight) * LightCount);

      {Setup Light Level Bands}
      for I := 0 to BandCount-1 do
      begin
         {we skip 16 as that block is reserved for the first hardware sprite,
         which we're using for the mouse cursor}
         //if I < 2 then
         Result^.Bands[I].Index := I * BandColourCount;// else
         //   Result^.Bands[I].Index := 8 + I * BandColourCount;
         Result^.Bands[I].Mask := Result^.Bands[I].Index;
      end;

      {Setup Light Colour Masks}
      for I := 0 to LightCount-1 do
      begin
         Result^.Lights[I].Index := (I+1) * (BandCount * BandColourCount);
         Result^.Lights[I].Mask := Result^.Lights[I].Index;
      end;

      {Setup Light Colours}
      {Red/Blue}
      //Lights[0].Colour := JColour3UInt8(160,60,60);
      //Lights[1].Colour := JColour3UInt8(60,60,160);
      {Grey}
      Lights[0].Colour := JColour3UInt8(128,128,128);
      Lights[1].Colour := JColour3UInt8(128,128,128);

      {$ENDIF}

      {Assign the Base Colour Registers}
      PenBlack := 0;
      PenRed := 1;
      PenGreen := 2;
      PenBlue := 3;
      PenWhite := 4;
      PenGrey := 5;
      PenYellow := 6;

      AModulate := JColour3UInt8(200,200,200);

      ARed := JColour3UInt8(255,0,0) * AModulate;
      AGreen := JColour3UInt8(0,255,0) * AModulate;
      ABlue := JColour3UInt8(0,0,255) * AModulate;
      AWhite := JColour3UInt8(255,255,255) * AModulate;
      AGrey := JColour3UInt8(175,175,175) * AModulate;
      AYellow := JColour3UInt8(255,255,0) * AModulate;

      {Setup Full-Bright Colours}
      JAPaletteSetColour(Result, PenBlack, JColour3UInt8(0,0,0)); {0=Screen Border Colour Also}
      JAPaletteSetColour(Result, PenRed, ARed);
      JAPaletteSetColour(Result, PenGreen, AGreen);
      JAPaletteSetColour(Result, PenBlue, ABlue);
      JAPaletteSetColour(Result, PenWhite, AWhite);
      JAPaletteSetColour(Result, PenGrey, AGrey);
      JAPaletteSetColour(Result, PenYellow, AYellow);

      {$IFDEF JA_ENABLE_SHADOW}
      {Cascade Light Level Bands}
      L0 := 220;
      L1 := 175;
      L2 := 55;
      JAPaletteBandModulate(Result, 0, 1, JColour3UInt8(L0,L0,L0));
      JAPaletteBandModulate(Result, 0, 2, JColour3UInt8(L1,L1,L1));
      JAPaletteBandModulate(Result, 0, 3, JColour3UInt8(L2,L2,L2));


      L0 := 220;
      L1 := 175;
      L2 := 55;
      JAPaletteBandModulate(Result, 0, 4, Lights[0].Colour);
      JAPaletteBandModulate(Result, 0, 5, Lights[0].Colour * JColour3UInt8(L0,L0,L0));
      JAPaletteBandModulate(Result, 0, 6, Lights[0].Colour * JColour3UInt8(L1,L1,L1));
      JAPaletteBandModulate(Result, 0, 7, Lights[0].Colour * JColour3UInt8(L2,L2,L2));

      L0 := 220;
      L1 := 175;
      L2 := 55;
      JAPaletteBandModulate(Result, 0, 8, Lights[1].Colour);
      JAPaletteBandModulate(Result, 0, 9, Lights[1].Colour * JColour3UInt8(L0,L0,L0));
      JAPaletteBandModulate(Result, 0, 10, Lights[1].Colour * JColour3UInt8(L1,L1,L1));
      JAPaletteBandModulate(Result, 0, 11, Lights[1].Colour * JColour3UInt8(L2,L2,L2));


      L0 := 220;
      L1 := 175;
      L2 := 55;
      JAPaletteBandModulate(Result, 0, 12, ColourMix(Lights[0].Colour, Lights[1].Colour));
      {JAPaletteBandModulate(Result, 0, 13, ColourMix(Lights[0].Colour, Lights[1].Colour) * JColour3UInt8(L0,L0,L0));
      JAPaletteBandModulate(Result, 0, 14, ColourMix(Lights[0].Colour, Lights[1].Colour) * JColour3UInt8(L1,L1,L1));
      JAPaletteBandModulate(Result, 0, 15, ColourMix(Lights[0].Colour, Lights[1].Colour) * JColour3UInt8(L2,L2,L2));}


      JAPaletteBandModulate(Result, 0, 13, ColourMix(Lights[0].Colour * JColour3UInt8(L0,L0,L0), Lights[1].Colour * JColour3UInt8(L0,L0,L0)));
      JAPaletteBandModulate(Result, 0, 14, ColourMix(Lights[0].Colour * JColour3UInt8(L1,L1,L1), Lights[1].Colour * JColour3UInt8(L1,L1,L1)));
      JAPaletteBandModulate(Result, 0, 15, ColourMix(Lights[0].Colour * JColour3UInt8(L2,L2,L2), Lights[1].Colour * JColour3UInt8(L2,L2,L2)));


      {TEST : Set First Band to be the darkest - for shadow blending}
      L2 := 55;
      JAPaletteSetColour(Result, PenBlack, JColour3UInt8(0,0,0)); {0=Screen Border Colour Also}
      JAPaletteSetColour(Result, PenRed, ARed * JColour3UInt8(L2,L2,L2));
      JAPaletteSetColour(Result, PenGreen, AGreen * JColour3UInt8(L2,L2,L2));
      JAPaletteSetColour(Result, PenBlue, ABlue * JColour3UInt8(L2,L2,L2));
      JAPaletteSetColour(Result, PenWhite, AWhite * JColour3UInt8(L2,L2,L2));
      JAPaletteSetColour(Result, PenGrey, AGrey * JColour3UInt8(L2,L2,L2));

      //PenRed := ObtainBestPenA(AColourMap, QBR.U32, 0, 0, nil);
      //PenGreen := ObtainPen(AColourMap, -1, 0, 0, 0, PEN_NO_SETCOLOR);
      //PenBlue := ObtainPen(AColourMap, -1, 0, 0, 0, PEN_EXCLUSIVE);
      //WriteLn('PenRed=' + IntToStr(PenRed));
      //WriteLn('PenGreen=' + IntToStr(PenGreen));
      //WriteLn('PenBlue=' + IntToStr(PenBlue));
      {SetRGB4CM(AColourMap, PenBlack, 0,0,0);
      SetRGB4CM(AColourMap, PenRed, 15,00,0);
      SetRGB4CM(AColourMap, 8 + PenRed, 15 div 2 ,00,0);
      SetRGB4CM(AColourMap, 8 + PenWhite, 15 div 2, 15 div 2,15 div 2);}
      {$ENDIF}

   end;
end;

function JAPaletteDestroy(APalette : PJAPalette) : boolean;
var
  i:Integer;
begin
   if (APalette=nil) then exit(false);
   Log('JAPaletteDestroy','Destroying Palette');
   with APalette^ do
   begin
      // restore old colormap
      if SaveColorMap then
        for i := 0 to 255 do
          SetRGB32(Viewport, i, oldColours[i].R, oldColours[i].G, oldColours[i].B);

      JAMemFree(Colours, SizeOf(TJColour3UInt8) * ColourCount);

      {$IFDEF JA_ENABLE_SHADOW}
      JAMemFree(Lights,SizeOf(TJAPaletteLight) * LightCount);
      JAMemFree(Bands,SizeOf(TJAPaletteMask) * BandCount);
      {$ENDIF}

   end;
   JAMemFree(APalette,SizeOf(TJAPalette));
   Result := true;
end;

procedure JAPaletteSetColour(APalette: PJAPalette; AColourIndex: SInt16; AColour: TJColour3UInt8);
begin
   with APalette^ do
   begin
      Colours[AColourIndex] := AColour;
      SetRGB4(ViewPort, AColourIndex, AColour.R shr 4, AColour.G shr 4, AColour.B shr 4);
   end;
end;

procedure JAPaletteBandModulate(APalette: PJAPalette; ASourceBand, ADestinationBand: SInt16; AModulation: TJColour3UInt8);
var
   I : SInt16;
   IndexSource,IndexDest : SInt16;
begin
   {$IFDEF JA_ENABLE_SHADOW}
   with APalette^ do
   begin
      for I := 0 to BandColourCount-1 do
      begin
         IndexSource := Bands[ASourceBand].Index+I;
         IndexDest := Bands[ADestinationBand].Index+I;

         JAPaletteSetColour(APalette, IndexDest, Colours[IndexSource] * AModulation);

         //Colours[IndexDest] := Colours[IndexSource] * AModulation;
         //SetRGB4(ViewPort, IndexDest,
         //   Colours[IndexDest].R shr 4,
         //   Colours[IndexDest].G shr 4,
         //   Colours[IndexDest].B shr 4);
      end;
   end;
   {$ENDIF}
end;

procedure JAPaletteLightSetColour(APalette: PJAPalette; ALightIndex: SInt16; AColour : TJColour3UInt8);
begin
   {$IFDEF JA_ENABLE_SHADOW}
   with APalette^ do
   begin
      Lights[ALightIndex].Colour := AColour;
   end;
   {$ENDIF}
end;

procedure JAPaletteBandSetColour(AIndex: SInt16; AColour: TJColour3UInt8);
begin
   {CursorSpriteIndex := 0; {The cursor is Sprite 0}
   CursorColourRegister := 16 + ((CursorSpriteIndex and $06) shl 1);
   //SetRGB4(Window^.ViewPort,CursorColourRegister + 0,0,0,0); {Cursor Pal 0 Transparent - Can't change}
   SetRGB4(Window^.ViewPort, CursorColourRegister + 1,15,0,0); {Cursor Pal 1}
   }
end;

procedure JAPaletteBandLightCascade(APalette: PJAPalette; ARootBandIndex: SInt16; ACascadeCount: SInt16; ACascadeFactor: Float32);
var
   I,J : SInt16;
   LightFactor : Float32;
begin
   {$IFDEF JA_ENABLE_SHADOW}
   LightFactor := ACascadeFactor;
   for I := ARootBandIndex+1 to (ARootBandIndex+ACascadeCount) do
   begin
      for J := 0 to APalette^.BandColourCount-1 do
      begin
         //APalette^.Bands[I+J].Colour := APalette^.Bands[ARootBandIndex+J].Colour;// * LightFactor;
      end;
      LightFactor *= ACascadeFactor;
   end;
   {$ENDIF}
end;

procedure JAPaletteSetupLights(ALight0, ALight1, ALight2: TJColour; ABandIndexStart: SInt16);
begin

end;

end.

