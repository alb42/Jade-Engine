unit JAWindow;
{$mode objfpc}{$H+}

interface

uses
   {Amiga} Exec, amigados, Intuition, AGraphics, GadTools, Utility, picasso96api, cybergraphics,
   {FPC} sysutils, math,
   {JA} JATypes, JALog, JAScreen;

type
   TJAWindowProperties = record
      API : TJAGraphicsAPI;
      Width : UInt16;
      WidthMin : UInt16;
      WidthMax : UInt16;
      Height : UInt16;
      HeightMin : UInt16;
      HeightMax : UInt16;
      Left : UInt16;
      Top : UInt16;
      Title : string;
      Border : boolean;
   end;

   TJAWindow = record
      Properties : TJAWindowProperties;
      Screen : PJAScreen; {the screen this window is on}
      {common to both intuition and picasso}
      BorderLeft : UInt16;
      BorderTop : UInt16;
      BorderRight : UInt16;
      BorderBottom : UInt16;
      Window : pWindow;

      RasterPort : pRastPort; {for the window bitmap}
  	   ViewPort : pViewPort;
  	   ColourMap : pColorMap;
      UserPort : pMsgPort;

   end;
   PJAWindow = ^TJAWindow;

const
   JAWindowPropertiesDefault : TJAWindowProperties = (
      API : JAGraphicsAPI_Auto;
      Width : 350;
      WidthMin : 50;
      WidthMax : 1000;
      Height : 150;
      HeightMin : 50;
      HeightMax : 1000;
      Left : 100;
      Top : 100;
      Title : 'JAWindow';
      Border : true);

function JAWindowCreate(AWindowProperties : TJAWindowProperties; AScreen : PJAScreen) : PJAWindow;
function JAWindowDestroy(AWindow : PJAWindow) : boolean;

implementation

function JAWindowCreate(AWindowProperties : TJAWindowProperties; AScreen : PJAScreen) : PJAWindow;
var
   WB : Pchar = 'Workbench';
   //PubScreenName : Array [0..80] Of Char;
   //template    :   string = 'Width=W/N,Height=H/N,Pubscreen=PS/K';
   //vecarray    :   Array[0..2] of longint = (0,0,0);
   //height,width : longint;
   //rda :   pRDArgs;
   PIPErrorCode : longword;
   //ANewWindow : TNewWindow;

begin
   Result := PJAWindow(JAMemGet(SizeOf(TJAWindow)));

   with Result^ do
   begin
      Properties := AWindowProperties;
      Screen := AScreen;

      case Properties.API of
         JAGraphicsAPI_Intuition :
         begin
            Log('JAWindowCreate','Creating Intuition Window [%s] [%dx%dx%d]',[Properties.Title,Properties.Width,Properties.Height, round(power(2,AScreen^.Properties.Depth))]);
            {create new window}
            Window := OpenWindowTags(nil{@ANewWindow},[
               //WA_PubScreen, astag(Result^.Screen^.Screen),
               WA_CustomScreen, astag(Result^.Screen^.Screen),
		         WA_Title, AsTag(pchar(Result^.Properties.Title)),

               WA_Left, AWindowProperties.Left,
		         Wa_Top, AWindowProperties.Top,

               WA_Width, AWindowProperties.Width,
               WA_Height, AWindowProperties.Height,

               WA_MinWidth, AWindowProperties.WidthMin,
               WA_MaxWidth, AWindowProperties.WidthMax,
     	         WA_MinHeight, AWindowProperties.HeightMin,
               WA_MaxHeight, AWindowProperties.HeightMax,

		         WA_Activate, ltrue,
               WA_DragBar, ltrue,
		         WA_CloseGadget, ltrue,
               WA_SizeGadget, ltrue,
		         WA_SizeBBottom, ltrue,

               WA_GimmeZeroZero, longword(AWindowProperties.Border),

		         //WA_SuperBitmap, ltrue,
               //WA_SimpleRefresh, ltrue,
               //WA_SmartRefresh, ltrue,
               WA_NoCareRefresh, ltrue,

               //WA_Backdrop, ltrue,
               //WA_Backfill, lfalse,

               //WA_NewLookMenus, lfalse,
               WA_ReportMouse, ltrue,
               WA_RMBTrap, ltrue,

		         WA_IDCMP,
               BUTTONIDCMP or
               IDCMP_MOUSEMOVE or
               IDCMP_MOUSEBUTTONS or
               IDCMP_CLOSEWINDOW or
               IDCMP_NEWSIZE or
               IDCMP_VANILLAKEY or
               IDCMP_MENUPICK or
               IDCMP_INTUITICKS, // or IDCMP_REFRESHWINDOW,
		         //WA_Flags, WFLG_WINDOWREFRESH or WFLG_REFRESHBITS,
               TAG_END]);

            if (Result^.Window = nil) then
            begin
               Log('JAWindowCreate','Failed To Create Intuition Window');
               JAMemFree(Result,SizeOf(TJAWindow));
               exit(nil);
            end;

            {store local references}
            RasterPort := Window^.RPort;

            RasterPort^.Flags := DBUFFER; {Indicate that the raster port is double buffered.}

            ViewPort := @Screen^.Screen^.ViewPort;
            UserPort := Window^.UserPort;

            ColourMap := Viewport^.ColorMap;

            //FreeColorMap(ViewPort^.ColorMap);
            //ColourMap := GetColorMap(32);
            ////ViewPort^.ColorMap := ColourMap;
            //ColourMap^.cm_vp := ViewPort;


            //SetRGB4CM(ColourMap,50,15,0,0);
         end;
         JAGraphicsAPI_Picasso :
         begin
            Log('JAWindowCreate','Creating Picasso PIP Window [%s] [%dx%dx%d]',[Properties.Title,Properties.Width,Properties.Height, round(power(2,AScreen^.Properties.Depth))]);


            //StrCopy(@PubScreenName,WB);

            {rda := ReadArgs(pchar(template),@vecarray,Nil);
            If rda<>Nil Then
            begin
               If (vecarray[0] <> 0) then width := plong(vecarray[0])^;
               If (vecarray[1] <> 0) then height := long(@vecarray[1]);
               If (vecarray[2] <> 0) then StrCopy(@PubScreenName,@vecarray[2]);
               FreeArgs(rda);
               Log('JAWindowCreate','ReadArgs Width = ' + inttostr(width));
               Log('JAWindowCreate','ReadArgs Height = ' + inttostr(height));
               Log('JAWindowCreate','ReadArgs PubScreenName = ' + PubScreenName);
            end;}

            //StrCopy(@PubScreenName,WB);

            {P96PIP_SourceBitMap
            P96PIP_SourceRPort
            P96PIP_RenderFunc}
            
{
This is nothing special. RTG games can support windowed mode but using overlay adds some nice extra features compared to fullscreen/overlay mode:
- PIP overlay can support scaling for free. (This is very useful for video players)
- PIP overlay can support different color depths (overlay can for example use 16-bit mode when WB is using 32-bit mode)
Overlay is basically separate "fullscreen mode" overlayed in top of normal screen, position and size can be freely chosen. Overlays were supported in hardware in most VGA chips. Later models used 3D hardware to do the overlay and dropped the hardware level bitmap overlay support.
}

            {open a picasso PIP window}
            Result^.Window := p96PIP_OpenTags([
               WA_CustomScreen, astag(Result^.Screen^.Screen),

               P96PIP_ErrorCode, astag(@PIPErrorCode),

               WA_Title, AsTag(pchar(Result^.Properties.Title)),

               P96PIP_SourceFormat, long(RGBFB_R5G5B5),
               //P96PIP_SourceFormat, long(RGBFB_R5G5B5),
               //P96PIP_SourceFormat, long(RGBFF_R8G8B8),

               P96PIP_SourceWidth, long(AWindowProperties.Width),
               P96PIP_SourceHeight, long(AWindowProperties.Height),
               P96PIP_AllowCropping, ltrue,

               //P96PIP_Type, long(P96PIPT_MemoryWindow),
               //P96PIP_Type, long(P96PIPT_VideoWindow),

               //P96PIP_Width, long(AWindowProperties.Width),
               //P96PIP_Height, long(AWindowProperties.Height),
               WA_InnerWidth, long(AWindowProperties.Width),
               WA_InnerHeight, long(AWindowProperties.Height),
               //WA_Width, long(AWindowProperties.Width),
               //WA_Height, long(AWindowProperties.Height),

               WA_GimmeZeroZero, longword(AWindowProperties.Border),

               WA_Activate, ltrue,
               WA_NoCareRefresh, ltrue,
               WA_SimpleRefresh,lTRUE,

               WA_CloseGadget,lTRUE,

               WA_ReportMouse, ltrue,
               WA_RMBTrap, ltrue,

               WA_IDCMP, BUTTONIDCMP or IDCMP_MOUSEMOVE or IDCMP_CLOSEWINDOW or IDCMP_NEWSIZE or IDCMP_VANILLAKEY or IDCMP_MENUPICK or IDCMP_INTUITICKS, //or IDCMP_REFRESHWINDOW,

               TAG_DONE]);

            if (Result^.Window = nil) then
            begin
               Log('JAWindowCreate','Failed To Create Picasso PIP Window [PIPErrorCode = %d]',[PIPErrorCode]);
               JAMemFree(Result,SizeOf(TJAWindow));
               exit(nil);
            end;

            {store local references}
            p96PIP_GetTags(Window,[P96PIP_SourceRPort, AsTag(@RasterPort), TAG_END]); {get the picasso pip window raster Port}
            RasterPort^.Flags := DBUFFER; {Indicate that the raster port is double buffered.}
            ViewPort := @Screen^.Screen^.ViewPort;
	         ColourMap := ViewPort^.Colormap;
            UserPort := Window^.UserPort;
         end;
      end;

      {for GimmieZeroZero}
	   BorderLeft := 0;
      BorderTop := 0;
      BorderRight := Properties.Width - (Window^.BorderRight + Window^.BorderLeft);
      BorderBottom := Properties.Height - (Window^.BorderBottom + Window^.BorderTop);

      //Result^.BorderLeft := Result^.Window^.BorderLeft;
      //Result^.BorderTop := Result^.Window^.BorderTop;
	   {BorderLeft := FAmigaWindow^.BorderLeft;
      BorderTop := FAmigaWindow^.BorderTop;
	   BorderRight := 300 - FAmigaWindow^.BorderRight;
      BorderBottom := 150 - FAmigaWindow^.BorderBottom;}
   end;
end;

function JAWindowDestroy(AWindow : PJAWindow) : boolean;
begin
   if (AWindow=nil) then exit(false);
   if (AWindow^.Window=nil) then exit(false);

   {close the window}
   case AWindow^.Properties.API of
      JAGraphicsAPI_Intuition :
      begin
         Log('JAWindowDestroy','Destroying Intuition Window [%s]',[AWindow^.Properties.Title]);
         CloseWindow(AWindow^.Window);
      end;
      JAGraphicsAPI_Picasso :
      begin
         Log('JAWindowDestroy','Destroying Picasso PIP Window [%s]',[AWindow^.Properties.Title]);
         p96PIP_Close(AWindow^.Window);
      end;
   end;

   {Free Strings}
   SetLength(AWindow^.Properties.Title, 0);

 	JAMemFree(AWindow,SizeOf(TJAWindow));
   Result := true;
end;

end.

