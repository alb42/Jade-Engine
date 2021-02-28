unit JAScreen;
{$mode objfpc}{$H+}

interface

uses
   {FPC} math,
   {Amiga} Exec, Intuition, AGraphics, Utility, GadTools, picasso96api, cybergraphics,
   {JA} JATypes, JALog;

type
   TJAScreenProperties = record
      API : TJAGraphicsAPI;
      Width : UInt16;
      Height : UInt16;
      Depth : UInt16;
      Title : string;
   end;

   TJAScreen = record
      Properties : TJAScreenProperties;
      Screen : pScreen;
      VisualInfo : pointer;
      DrawInfo : pDrawInfo;
      ExistingScreen : boolean;
   end;
   PJAScreen = ^TJAScreen;

const
   JAScreenPropertiesDefault : TJAScreenProperties = (
      API : JAGraphicsAPI_Auto;
      Width : 320;
      Height : 200;
      Depth : 5;
      Title : 'JAScreen');

function JAScreenCreate(AScreenProperties : TJAScreenProperties; AExistingScreen : pScreen) : PJAScreen;
function JAScreenDestroy(AScreen : PJAScreen) : boolean;

implementation

function JAScreenCreate(AScreenProperties : TJAScreenProperties; AExistingScreen : pScreen) : PJAScreen;
var
   DisplayID : UInt16;
   NewMode : UInt16;
begin
   Result := PJAScreen(JAMemGet(SizeOf(TJAScreen)));

   Result^.Properties := AScreenProperties;

   if AExistingScreen=nil then
   begin
      Result^.ExistingScreen := false;
      case AScreenProperties.API of
         JAGraphicsAPI_Intuition :
         begin
            Log('JAScreenCreate','Creating Intuition Screen [%s] [%dx%dx%d]',[AScreenProperties.Title,AScreenProperties.Width,AScreenProperties.Height, round(power(2,AScreenProperties.Depth))]);
	         Result^.Screen := OpenScreenTags(nil,[
               SA_Width, AScreenProperties.Width,
               SA_Height, AScreenProperties.Height,
               SA_Depth, AScreenProperties.Depth,
               SA_Title, AsTag(pchar(Result^.Properties.Title)),

               //SA_LikeWorkbench,lTRUE,
               SA_FullPalette, lfalse,
               SA_SharePens, ltrue, {we're managing the pens ourselves, leave slots unallocated}
               SA_Pens, -1,
               {TODO : this determines our resolution for lores / hires ec}

               SA_DisplayID, LORES_KEY,
               //SA_DisplayID, EXTRAHALFBRITE_KEY, {320x200 NTSC}
               //SA_DisplayID, HIRESEHB_KEY, {640x200 NTSC}
               //SA_DisplayID, HIRESEHBLACE_KEY, {640x400 NTSC}


               TAG_END]);

           // NewMode := CoerceMode(@Result^.Screen^.ViewPort, NTSC_MONITOR_ID, AVOID_FLICKER);


            if Result=nil then
            begin
               Log('JAScreenCreate','Failed To Create Intuition Screen');
               JAMemFree(Result, SizeOf(TJAScreen));
               exit(nil);
            end;
         end;
         JAGraphicsAPI_Picasso :
         begin
            {DisplayID := p96BestModeIDTags([
                                 P96BIDTAG_NominalWidth, AScreenProperties.Width,
                                 P96BIDTAG_NominalHeight, AScreenProperties.Height,
                                 P96BIDTAG_Depth, AScreenProperties.Depth,
                                 P96BIDTAG_FormatsAllowed, RGBFF_HICOLOR or RGBFF_TRUECOLOR,//RGBFF_CLUT or RGBFF_R8G8B8,
                                 TAG_DONE]);}

            Log('JAScreenCreate','Creating Picasso Screen [%s] [%dx%dx%d]',[AScreenProperties.Title,AScreenProperties.Width,AScreenProperties.Height, round(power(2,AScreenProperties.Depth))]);

            Result^.Screen := p96OpenScreenTags([
               P96SA_Width, AScreenProperties.Width,
               P96SA_Height, AScreenProperties.Height,

               //P96SA_DisplayID, DisplayID,
               //P96SA_RGBFormat, RGBFF_R8G8B8,//RGBFF_CLUT,
               //SA_DisplayID, EXTRAHALFBRITE_KEY,

               P96SA_Depth, AScreenProperties.Depth,
               P96SA_Title, AsTag(pchar(@AScreenProperties.Title)),

               SA_FullPalette, lfalse,
               P96SA_SharePens, ltrue, {we're managing the pens ourself, leave slots unallocated}
               P96SA_Pens, -1,
               //P96SA_AutoScroll, lTRUE,
               //P96SA_Pens, AsTag(@Pens),
               TAG_DONE]);

            if Result=nil then
               begin
                  Log('JAScreenCreate','Failed To Create Picasso Screen');
                  JAMemFree(Result, SizeOf(TJAScreen));
                  exit(nil);
               end;
         end;
      end;
   end else
   begin
      Log('JAScreenCreate','Attaching to Existing Screen [%s] [%dx%dx%d]',[AExistingScreen^.Title,AExistingScreen^.Width,AExistingScreen^.Height, round(power(2, AExistingScreen^.Bitmap.Depth))]);

      Result^.ExistingScreen := true;

      {copy over existing screen properties}
      Result^.Screen := AExistingScreen;
      Result^.Properties.Title := AExistingScreen^.Title;
      Result^.Properties.Width := AExistingScreen^.Width;
      Result^.Properties.Height := AExistingScreen^.Height;
   end;

   {get visual and draw info for the screen}
	Result^.VisualInfo := GetVisualInfoA(Result^.Screen, nil); {get screen visualinfo}
	Result^.DrawInfo := GetScreenDrawInfo(Result^.Screen); {get screen drawinfo}

   {update/copy screen depth}
   Result^.Properties.Depth := Result^.DrawInfo^.dri_depth;
end;

function JAScreenDestroy(AScreen : PJAScreen) : boolean;
begin
   if AScreen=nil then exit(false);

   {free visual and draw info}
   FreeScreenDrawInfo(AScreen^.Screen, AScreen^.DrawInfo);
   FreeVisualInfo(AScreen^.VisualInfo);

   if not AScreen^.ExistingScreen then
   begin
      case AScreen^.Properties.API of
         JAGraphicsAPI_Intuition :
         begin
            Log('JAScreenDestroy','Destroying Intuition Screen [%s]',[AScreen^.Properties.Title]);
            CloseScreen(AScreen^.Screen);
         end;
         JAGraphicsAPI_Picasso :
         begin
            Log('JAScreenDestroy','Destroying Picasso Screen [%s]',[AScreen^.Properties.Title]);
            p96CloseScreen(AScreen^.Screen);
         end;
      end;
   end else
      Log('JAScreenDestroy','Detaching From Existing Screen [%s]',[AScreen^.Properties.Title]);

   {Free Strings}
   SetLength(AScreen^.Properties.Title, 0);
   {Free Memory}
   JAMemFree(AScreen, SizeOf(TJAScreen));
   Result := true;
end;

end.
