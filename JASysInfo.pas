unit JASysInfo;
{$mode objfpc}{$H+}

interface

uses
   sysutils,
   exec, amigados, Intuition, AGraphics, layers, GadTools, Utility, picasso96api, cybergraphics, linklist,
   JATypes, JALog;


type
   TJASysInfoCPU = (
      JACPU_86000=0,
      JACPU_86010=1,
      JACPU_86020=2,
      JACPU_86030=3,
      JACPU_86040=4,
      JACPU_86060=5,
      JACPU_86080=6
   );
   TJASysInfoFPU = (
      JAFPU_None = 0,
      JAFPU_CPU = 1,
      JAFPU_68881 = 2,
      JAFPU_68882 = 3
   );
   TJASysInfoMMU = (
      JAMMU_None = 0,
      JAMMU_MMU = 1,
      JAMMU_EC = 2
   );

   TJASysInfoPicassoBoard = record
      Name : string;
      RGBFormats : SInt32;
      MemorySize : SInt32;
      FreeMemory : SInt32;
      LargestFreeMemory : SInt32;
      MemoryClock : SInt32;
      MoniSwitch : SInt32;
   end;

   TJAVideoStandard = (JAVIDEO_NTSC = 1, JAVIDEO_GENLOC = 2, JAVIDEO_PAL = 4, JAVIDEO_TODA_SAFE = 8, JAVIDEO_REALLY_PAL = 16);

   TJASysInfo = record
      CPU : TJASysInfoCPU;
      CPUName : string;
      FPU : boolean;
      FPUName : string;
      MMU : TJASysInfoMMU;
      MMUName : string;
      MemoryChip : UInt32;
      MemoryFast : UInt32;
      MemorySlow : UInt32;
      MemoryGraphics : UInt32;
      VideoStandard : TJAVideoStandard;
      PicassoAPI : boolean;
      PicassoBoards : array of TJASysInfoPicassoBoard;
      PicassoBoardsCount : SInt32;

      CybergraphicsAPI : boolean;
   end;


const
   TJASysInfoCPUNames : array[0..6] of string = (
      '86000',
      '86010',
      '86020',
      '86030',
      '86040',
      '86060',
      '86080'
   );
   TJASysInfoFPUNames : array[0..3] of string = (
      'None',
      'CPU',
      '68881',
      '68882'
   );
   TJASysInfoMMUNames : array[0..2] of string = (
      'None',
      'MMU',
      'EC'
   );

var
   SysInfo : TJASysInfo;

procedure JASysInfoQuery();

implementation

{
identify library - if we have it - contains tons of sysinfo style stuff.
IDENTIFYNAME    : PChar = 'identify.library';
}

{ 
 LOOK HERE !!! - struct ExecBase
 /* The next ULONG contains the system "E" clock frequency,
	** expressed in Hertz.	The E clock is used as a timebase for
	** the Amiga's 8520 I/O chips. (E is connected to "02").
	** Typical values are 715909 for NTSC, or 709379 for PAL.
	*/
	ULONG	ex_EClockFrequency;	/* (readable) 
	
 
 While we're talking about CPUs: you can also differentiate the various processors that the different versions of AmigaOS run on. For the earlier 68k CPUs a single bit from "ExecBase->AttnFlags" was enough to distinguish a 68000 from a 68030 or a 68060. Since bits tend to run out eventually and it's only a very rough method there's also a function to get the processor's name string. You can call IExec->GetCPUInfoTags() with GCIT_xxx tags (from exec/exectags.h). As the function was introduced with AmigaOS 4 this program can never run on older versions. See the complete example "DeterminateProcessor.c" for details.
} 
 
{
IExpansion->GetMachineInfo()
 
 AttnFlags
 
 ******* Bit defines for AttnFlags (see above) *******************************

*  Processors and Co-processors:
	BITDEF	AF,68010,0	; also set for 68020
	BITDEF	AF,68020,1	; also set for 68030
	BITDEF	AF,68030,2	; also set for 68040
	BITDEF	AF,68040,3
	BITDEF	AF,68881,4	; also set for 68882
	BITDEF	AF,68882,5
	BITDEF	AF,FPU40,6	; Set if 68040 FPU
;
; The AFB_FPU40 bit is set when a working 68040 FPU
; is in the system.  If this bit is set and both the
; AFB_68881 and AFB_68882 bits are not set, then the 68040
; math emulation code has not been loaded and only 68040
; FPU instructions are available.  This bit is valid *ONLY*
; if the AFB_68040 bit is set.
;
;	BITDEF	AF,RESERVED8,8
;	BITDEF	AF,RESERVED9,9
	BITDEF	AF,PRIVATE,15	; Just what it says
}	

procedure JASysInfoQueryCPU();
begin

end;

procedure JASysInfoQueryMemory();
begin
   {
   MEMF_ANY      = %000000000000000000000000;   { * Any type of memory will do * }
   MEMF_PUBLIC   = %000000000000000000000001;
   MEMF_CHIP     = %000000000000000000000010;
   MEMF_FAST     = %000000000000000000000100;
   MEMF_LOCAL    = %000000000000000100000000;
   MEMF_24BITDMA = %000000000000001000000000;   { * DMAable memory within 24 bits of address * }
   MEMF_KICK     = %000000000000010000000000;   { Memory that can be used for KickTags }

   MEMF_CLEAR    = %000000010000000000000000;
   MEMF_LARGEST  = %000000100000000000000000;
   MEMF_REVERSE  = %000001000000000000000000;
   MEMF_TOTAL    = %000010000000000000000000;   { * AvailMem: return total size of memory * }
   MEMF_NO_EXPUNGE = $80000000;   {AllocMem: Do not cause expunge on failure }

   MEM_BLOCKSIZE = 8;
   MEM_BLOCKMASK = MEM_BLOCKSIZE-1;
   }

   SysInfo.MemoryChip := AvailMem(MEMF_CHIP);
   SysInfo.MemoryFast := AvailMem(MEMF_FAST);
   {TODO : this obviously isn't right - but lookup how to query and figure out all the memory correctly}
   SysInfo.MemoryGraphics := AvailMem(MEMF_PUBLIC);
end;

procedure JASysInfoQueryGraphics();
var
   I : SInt32;
   BoardName : Pchar;
   BoardNameTemp : array[0..200] of char;
   PixelFormatsString : string;
   clock  : Longint;
   tmp       : Longint;
   RGBFormats,
   MemorySize,
   FreeMemory,
   LargestFreeMemory,
   MemoryClock,
   MoniSwitch  : Longint;

   width,
    height,
    depth,
    DisplayID   :   longint;
    dim         :   tDimensionInfo;
    rda         :   pRDArgs;

const
   template    :   pchar = 'Width=W/N,Height=H/N,Depth=D/N';
   vecarray    :   Array[0..2] of longint = (0,0,0);

   function RGBTest(ABoardIndex : SInt32; ARGBFormat : SInt32) : boolean;
   begin
      Result := (SysInfo.PicassoBoards[ABoardIndex].RGBFormats and ARGBFormat) <> 0;
   end;

begin
   {PAL or NTSC startup mode detection}
   if ((pGfxBase(GfxBase)^.DisplayFlags and PAL) <> 0) then SysInfo.VideoStandard := JAVIDEO_PAL else
   if ((pGfxBase(GfxBase)^.DisplayFlags and NTSC) <> 0) then SysInfo.VideoStandard := JAVIDEO_NTSC else
   if ((pGfxBase(GfxBase)^.DisplayFlags and GENLOC) <> 0) then SysInfo.VideoStandard := JAVIDEO_GENLOC else
   if ((pGfxBase(GfxBase)^.DisplayFlags and TODA_SAFE) <> 0) then SysInfo.VideoStandard := JAVIDEO_TODA_SAFE else
   if ((pGfxBase(GfxBase)^.DisplayFlags and 16) <> 0) then SysInfo.VideoStandard := JAVIDEO_REALLY_PAL;

   case SysInfo.VideoStandard of
      JAVIDEO_PAL : Log('JASysInfo','System is PAL');
      JAVIDEO_NTSC : Log('JASysInfo','System is NTSC');
      JAVIDEO_GENLOC : Log('JASysInfo','System is GENLOC');
      JAVIDEO_TODA_SAFE : Log('JASysInfo','System is TODA SAFE');
      JAVIDEO_REALLY_PAL : Log('JASysInfo','System is REALLY PAL');
   end;

   {intuition.library version}
   Log('JASysInfo', JALibNameIntuition + ' v' + inttostr(pIntuitionBase(IntuitionBase)^.libnode.lib_version) + '.' + inttostr(pIntuitionBase(IntuitionBase)^.libnode.lib_Revision) + ' found');

   {graphics.library version}
   Log('JASysInfo',JALibNameGraphics + ' v' + inttostr(pGfxBase(GfxBase)^.libnode.lib_version) + '.' + inttostr(pGfxBase(GfxBase)^.libnode.lib_Revision) + ' found');

   {layers.library version}
   Log('JASysInfo', JALibNameLayers + ' v' + inttostr(LayersBase^.lib_Version) + '.' + inttostr(LayersBase^.lib_Revision) + ' found');

   {Query Picasso}
   if P96Base=nil then
   begin
      SysInfo.PicassoAPI := false;
      Log('JASysInfo',JALibNamePicasso96API + ' not found');
   end else
   begin
      SysInfo.PicassoAPI := true;

      Log('JASysInfo',JALibNamePicasso96API + ' v' + inttostr(P96Base^.lib_Version) + '.' + inttostr(P96Base^.lib_Revision) + ' found');

      //p96GetRTGDataTagList
      //p96GetBoardDataTagList
      BoardName := @BoardNameTemp;
      tmp := p96GetRTGDataTags([P96RD_NumberOfBoards, AsTag(@SysInfo.PicassoBoardsCount), TAG_END]);
      SetLength(SysInfo.PicassoBoards, SysInfo.PicassoBoardsCount);

      Log('JASysInfo','Found ' + inttostr(SysInfo.PicassoBoardsCount) + ' Picasso96 Boards');

      for I := 0 to SysInfo.PicassoBoardsCount-1 do
      begin
         p96GetBoardDataTags(I, [P96BD_BoardName, AsTag(@BoardName),
            P96BD_RGBFormats, AsTag(@SysInfo.PicassoBoards[I].RGBFormats),
            P96BD_TotalMemory, AsTag(@SysInfo.PicassoBoards[I].MemorySize),
            P96BD_FreeMemory, AsTag(@SysInfo.PicassoBoards[I].FreeMemory),
            P96BD_LargestFreeMemory, AsTag(@SysInfo.PicassoBoards[I].LargestFreeMemory),
            P96BD_MemoryClock, AsTag(@SysInfo.PicassoBoards[I].MemoryClock),
            P96BD_MonitorSwitch, AsTag(@SysInfo.PicassoBoards[I].MoniSwitch),
            TAG_END]);

         SysInfo.PicassoBoards[I].Name := BoardName;

         Log('JASysInfo','Board[' + inttostr(i) + '].Name = ' + SysInfo.PicassoBoards[I].Name);
         Log('JASysInfo','Board[' + inttostr(i) + '].MemorySize = ' + inttostr(SysInfo.PicassoBoards[I].MemorySize));
         Log('JASysInfo','Board[' + inttostr(i) + '].FreeMemory = ' + inttostr(SysInfo.PicassoBoards[I].FreeMemory));
         Log('JASysInfo','Board[' + inttostr(i) + '].LargestFreeMemory = ' + inttostr(SysInfo.PicassoBoards[I].LargestFreeMemory));


         clock := (SysInfo.PicassoBoards[I].MemoryClock+50000) div 100000;
         Log('JASysInfo','Board[' + inttostr(i) + '].MemoryClock = ' + inttostr(clock div 10) + '.' + inttostr(clock mod 10) + 'Mhz');

        PixelFormatsString := '';

        if RGBTest(I, RGBFF_NONE) then PixelFormatsString += 'PLANAR ' else
        if RGBTest(I, RGBFF_CLUT) then PixelFormatsString += 'CHUNKY ' else
        if RGBTest(I, RGBFF_R5G5B5) then PixelFormatsString += 'tR5G5B5 ' else
        if RGBTest(I, RGBFF_R5G5B5PC) then PixelFormatsString += 'R5G5B5PC ' else
        if RGBTest(I, RGBFF_B5G5R5PC) then PixelFormatsString += 'B5G5R5PC ' else
        if RGBTest(I, RGBFF_R5G6B5) then PixelFormatsString += 'R5G6B5 ' else
        if RGBTest(I, RGBFF_R5G6B5PC) then PixelFormatsString += 'R5G6B5PC ' else
        if RGBTest(I, RGBFF_B5G6R5PC) then PixelFormatsString += 'B5G6R5PC ' else
        if RGBTest(I, RGBFF_R8G8B8) then PixelFormatsString += 'R8G8B8 ' else
        if RGBTest(I, RGBFF_B8G8R8) then PixelFormatsString += 'B8G8R8 ' else
        if RGBTest(I, RGBFF_A8R8G8B8) then PixelFormatsString += 'A8R8G8B8 ' else
        if RGBTest(I, RGBFF_A8B8G8R8) then PixelFormatsString += 'A8B8G8R8 ' else
        if RGBTest(I, RGBFF_R8G8B8A8) then PixelFormatsString += 'R8G8B8A8 ' else
        if RGBTest(I, RGBFF_B8G8R8A8) then PixelFormatsString += 'B8G8R8A8 ' else
        if RGBTest(I, RGBFF_Y4U2V2) then PixelFormatsString += 'Y4U2V2 ' else
        if RGBTest(I, RGBFF_Y4U1V1) then PixelFormatsString += 'Y4U1V1 ';

  
        Log('JASysInfo','Board[' + inttostr(i) + '].RGBFormats = ' + PixelFormatsString);

      end;
   end;

   {Query Cybergraphics}
   if CyberGfxBase=nil then
   begin
       SysInfo.CybergraphicsAPI := false;
      Log('JASysInfo',JALibNameCybergraphics + ' not found');
   end else
   begin
      Log('JASysInfo',JALibNameCybergraphics + ' v' + inttostr(CyberGfxBase^.lib_Version) + '.' + inttostr(CyberGfxBase^.lib_Revision) + ' found');
   end;

end;

procedure JASysInfoQueryAudio();
begin

end;

procedure JASysInfoQueryVolumes();
begin

end;

procedure JASysInfoQuery();
begin
   JASysInfoQueryCPU();
   JASysInfoQueryMemory();
   JASysInfoQueryGraphics();
   JASysInfoQueryAudio();
   JASysInfoQueryVolumes();
end;

initialization
   JASysInfoQuery();

finalization
   SetLength(SysInfo.PicassoBoards, SysInfo.PicassoBoardsCount);

end.

