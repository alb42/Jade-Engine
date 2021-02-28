program JAMake;
{$mode objfpc}{$H+}
{$PACKRECORDS 2} {required for compatibility with various amiga APIs}

uses
   {FPC}
   SysUtils,
   {Amiga}
	exec, amigados, wbargs, amsgbox, timer, Intuition, AGraphics, GadTools, Utility,
	JATypes, JALog;

var	
	I : SInt32;
   FPCBin : string;
   PathBin : string;
   ProgramName : string;
   UnitMain : string;

   PathUnits : string;

   PathBinOut : string;
   PathLibOut : string;
   PathUnitOut : string;

const
   CPU_020 = ' -Cp68020';
   CPU_030 = ' -Cp68030';
   CPU_040 = ' -Cp68040';
   CPU_060 = ' -Cp68060';

   FPU_SOFT = ' -CfSOFT';
   FPU_68881 = ' -Cf68881';
   
	FPC_LIBRARY_SMARTLINK = ' -CX';   

   FPC_OPTIMIZE = ' -OoFASTMATH';
   FPC_OPTIMIZE_1 = ' -O1'; {quick and debugger friendly}
   FPC_OPTIMIZE_2 = ' -O2'; {-O1 and quick optimizations}
   FPC_OPTIMIZE_3 = ' -O3'; {-O2 and slow optimizations}
   FPC_OPTIMIZE_4 = ' -O4'; {-O3 and risky optimizations}

   FPC_LIBRARYPATH = ' -Fl';
   FPC_OBJECTPATH = ' -Fo';
   FPC_INCLUDEPATH = ' -Fi';
   FPC_UNITPATH = ' -Fu';
   FPC_UNITOUTPATH = ' -FU';

   FPC_HEAPTRACE = ' -gh';
   FPC_DEBUG_STABS = ' -gs';
   FPC_DEBUG_DWARF2 = ' -gw2';
   FPC_DEBUG_DWARF3 = ' -gw3';

   FPC_LINKER_EXTERNAL = ' -Xe';
   FPC_LINKER_VLINK = ' -XV';
   FPC_STRIP_SYMBOLS = ' -Xs';

   FPC_LINKER_DYNAMIC = ' -XD';
   FPC_UNIT_SMARTLINK = ' -XX';
   
   //-e | set path to executable

                                                                                        	

begin

   //fpc -Cp68060 -CfSOFT -OoFASTMATH ja.pas

   Log('JAMake', 'Begin');
   //log('ParamCount', IntToStr(ParamCount));

   FPCBin := 'fpc';
   PathBin := ParamStr(0);

   if (ParamCount>0) then
      ProgramName := ParamStr(1) else
      ProgramName := 'JA';

   UnitMain := ProgramName + '.pas';

   PathUnits := '/JAE; /';
   PathLibOut := '/lib';
   PathUnitOut := '/lib';

   PathBinOut := UnitMain;// + '.exe';


   //Log('PathBin', PathBin);
   //Log('ProgramName', ProgramName);
  // Log('UnitMain', UnitMain);
   //Log('PathUnits', PathUnits);
   //Log('PathLibOut', PathLibOut);
   //Log('PathUnitOut', PathUnitOut);

   for I := 1 to ParamCount do
   begin
      Log('Param'+IntToStr(I),ParamStr(I));
   end;

   Log('FPCExecute', FPCBin +
   CPU_060 +
   FPU_68881 + 
   FPC_OPTIMIZE_3 +
   FPC_LIBRARYPATH + PathLibOut +
   FPC_OBJECTPATH + PathLibOut +
   FPC_UNITOUTPATH + PathUnitOut + ' ' +
   UnitMain);

   Execute(FPCBin +
   CPU_060 + 
   FPU_68881 +
   FPC_OPTIMIZE_3 + 
   FPC_LIBRARYPATH + PathLibOut +
   FPC_OBJECTPATH + PathLibOut +
   FPC_UNITOUTPATH + PathUnitOut + ' ' +
   UnitMain, 0 ,0);

   Log('JAMake', 'End');
end. 	
