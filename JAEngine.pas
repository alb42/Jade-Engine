unit JAEngine;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   {FPC} sysutils,
   {Amiga} exec, utility, intuition, inputevent, AGraphics, gadtools, layers,

   JATypes, JAList, JALog, JASysInfo, JAMath, JATimer, JAScreen, JAWindow,

   JARender, JABitmap, JRenderBufferIntuition, JAPalette,

   JAPolygon, JASketch,
   JASpatial, JAScene, JANode, JAShadow;

type
   PJAEngine = ^TJAEngine;

   TJAEngineModule = (
      JAEngineModule_Screen=0,   {create screen (else use public/workbench screen)}
      JAEngineModule_Window=1,   {create a window}
      JAEngineModule_Scene=2,    {use the scenegraph}
      JAEngineModule_Audio=3     {init the audio engine}
   );

   TJAEngineProperties = record
      Title : string;
      API : TJAGraphicsAPI;
      Modules : set of TJAEngineModule;
      ScreenProperties : TJAScreenProperties;
      WindowProperties : TJAWindowProperties;
      OnUpdate : function(ADelta : Float32) : Float32;
      OnRender : function() : Float32;
      OnCreate : function(AEngine : PJAEngine) : Float32;
      OnDestroy : function(AEngine : PJAEngine) : Float32;
   end;
   PJAEngineProperties = ^TJAEngineProperties;

   TJAEnginePerformance = record
      TimeLastSecond : Float32; {per-second trigger. IE performance update}
      TimeDeltaCurrent : Float32;
      TimeDeltaPrevious : Float32;

      CurrentDelta : Float32;
      CurrentRenderMS : Float32;
      CurrentUpdateMS : Float32;

      WindowDelta : Float32;
      WindowRenderMS : Float32;
      WindowFPS : SInt32;
      WindowUpdateMS : Float32;
      WindowUPS : SInt32;
      WindowSwapWait : Float32; {this is how long we could have spent processing things}

      AverageDelta : Float32;
      AverageRenderMS : Float32;
      AverageFPS : Float32;
      AverageUpdateMS : Float32;
      AverageUPS : Float32;
      AverageSwapWait : Float32;
   end;

   TJAEngine = record
      Terminated : boolean; {trigger destruction of engine}
      Properties : TJAEngineProperties;
      Performance : TJAEnginePerformance;

      ScreenPublic : PJAScreen;
      Screen : PJAScreen;
      Window : PJAWindow;
      Timer : PJATimer;
      Scene : PJAScene;

      CursorBitmap : PJABitmap;

      {Text HUD}
      HUDLine1 : string;
      HUDLine1Length : SInt32;
      HUDLine2 : string;
      HUDLine2Length : SInt32;
      HUDLine3 : string;
      HUDLine3Length : SInt32;
      HUDLine4 : string;
      HUDLine4Length : SInt32;
      HUDLine5 : string;
      HUDLine5Length : SInt32;
      HUDLine6 : string;
      HUDLine6Length : SInt32;

      {mouse state tracking}
      MousePosition : TVec2SInt32;
      MouseCoord : TVec2;
      MousePositionPrevious : TVec2SInt32;
      MouseRelative : TVec2SInt32;

      MouseDragLeft : boolean;
      MouseDragLeftStartPos : TVec2SInt32;
      MouseDragLeftStartCoord : TVec2;
      MouseDragLeftRelative : TVec2SInt32;

      MouseDragRight : boolean;
      MouseDragRightStartPos : TVec2SInt32;
      MouseDragRightStartCoord : TVec2;
      MouseDragRightRelative : TVec2SInt32;

      MouseDragCameraPositionStart : TVec2;
      MouseDragCameraRotationStart : Float32;
      MouseDragScaleStart : Float32;

      {intuition message handling}
      AmigaIDCMPMessage : pMessage;
      AmigaDoubleBufferPort : pMsgPort;
      AmigaDoubleBufferMessage : pMessage;

      Palette : PJAPalette; {Palette manager}

      {Window Mode Render buffer}
      RenderBuffer : PJABitmap;
      {Screen Mode swap buffers}
      Buffers : array[0..1] of PJRenderBufferIntuition;
      BufferNextRender : UInt8;
      BufferNextSwap : UInt8;

      CursorMemoryPointer: Pointer;
   end;

const
   JAEnginePropertiesDefault : TJAEngineProperties = (
         Title : 'JAEngine';
         API : JAGraphicsAPI_Auto;
         Modules : [JAEngineModule_Screen,
            JAEngineModule_Window,
            JAEngineModule_Scene,
            JAEngineModule_Audio];
         ScreenProperties : (
            API : JAGraphicsAPI_Auto;
            Width : 320;
            Height : 200;
            Depth : 5;
            Title : 'JAScreen');
         WindowProperties : (
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
         OnUpdate : nil;
         OnRender : nil;
         OnCreate : nil;
         OnDestroy : nil);

function JAEngineCreate(AEngineProperties : PJAEngineProperties) : PJAEngine;
function JAEngineDestroy(AEngine : PJAEngine) : boolean;
function JAEngineExecute(AEngine : PJAEngine) : Float32; {main loop}

function JAEngineUpdate(AEngine : PJAEngine; ADelta : Float32) : Float32; {returns execution time in MS}

function JAEngineRenderScreen(AEngine : PJAEngine) : Float32; {returns execution time in MS}
function JAEngineRenderSwapScreen(AEngine : PJAEngine) : Float32; {returns execution time in MS}

function JAEngineRenderWindow(AEngine : PJAEngine) : Float32; {returns execution time in MS}
function JAEngineRenderSwapWindow(AEngine : PJAEngine) : Float32; {returns execution time in MS}

function JAEngineRenderHUD(AEngine : PJAEngine) : Float32; {returns execution time in MS}

{Intuition Message Handlers}
procedure ProcessIDCMPMessage(AEngine : PJAEngine; AMessage : pIntuiMessage);
procedure ProcessDoubleBufferMessage(AEngine : PJAEngine; AMessage : pMessage);

var
   {Bound to Either Screen or Window specific versions}
   JAEngineRender : function(AEngine : PJAEngine) : Float32;
   JAEngineRenderSwap : function(AEngine : PJAEngine) : Float32;

implementation

function JAEngineCreate(AEngineProperties : PJAEngineProperties) : PJAEngine;
var
   PubScreen : PScreen;
   I,K : SInt32;

   CursorSpriteIndex : SInt32;
   CursorColourRegister : SInt32;
   CursorPenI : SInt32; {amiga pen}

   CursorRasterPort : TRastPort;
   CursorColourMap : pColormap;
   QBR,QBG,QBB : TQuadByte;
   Tags : packed array[0..1] of Tag;

   MyPointer : PUInt16;
begin
   writeln('');
   Log('JAEngine','Jade Engine v1.0 starting up');

   {Default Properties}
   {JARenderPassCount := 4;
   JARenderLightLevelCount := 3;
   JARenderLightFinCount := 3;
   JARenderLightDither := true;}


   {These are bound to either Screen or Window Specific versions}
   JAEngineRender := nil;
   JAEngineRenderSwap := nil;

   Result := PJAEngine(JAMemGet(SizeOf(TJAEngine)));

   With Result^ do
   begin
      Terminated := false;
      Properties := AEngineProperties^;
      with Performance do
      begin
         CurrentDelta := 0;
         CurrentRenderMS := 0;
         CurrentUpdateMS := 0;
         WindowDelta := 0;
         WindowRenderMS := 0;
         WindowFPS := 0;
         WindowUpdateMS := 0;
         WindowUPS := 0;
         WindowSwapWait := 0; {this is how long we could of spent processing things}
         AverageDelta := 0;
         AverageRenderMS := 0;
         AverageFPS := 0;
         AverageUpdateMS := 0;
         AverageUPS := 0;
         AverageSwapWait := 0;
      end;
      HUDLine1 := '';
      HUDLine1Length := 0;
      HUDLine2 := '';
      HUDLine2Length := 0;
      HUDLine3 := '';
      HUDLine3Length := 0;
      HUDLine4 := '';
      HUDLine4Length := 0;
      HUDLine5 := '';
      HUDLine5Length := 0;
      HUDLine6 := '';
      HUDLine6Length := 0;

      Timer := JATimerCreate();

      {Setup Public Screen}

      {TODO : do we need to lock the public screen if we create our own?}
	   {lock the public screen if we need to}
	   PubScreen := LockPubScreen(nil);

	   if (PubScreen<>nil) then
      begin
         Log('JAScreenCreate','Locked Public Screen [%s]',[pchar(PubScreen^.Title)]);
         {wrap public screen in our screen structure}
         ScreenPublic := JAScreenCreate(Properties.ScreenProperties, PubScreen);
      end else
      begin
         Log('JAEngine','Failed To Lock Public Screen');
         ScreenPublic := nil;
      end;

      {Setup Custom Screen}
      if (JAEngineModule_Screen in Result^.Properties.Modules) then
      begin
         {Create JAScreen}
         Screen := JAScreenCreate(Properties.ScreenProperties,nil);
         if (Screen=nil) then
         begin
            {unlock the public screen if we were using it}
            Log('JAScreenCreate','Unlocking Public Screen "%s"',[pchar(ScreenPublic^.Screen^.Title)]);
            UnlockPubScreen(nil, ScreenPublic^.Screen);
            JAScreenDestroy(ScreenPublic);
            JATimerDestroy(Timer);
            JAMemFree(Result,SizeOf(TJAEngine));
            exit(nil);
         end;

         {set the screen border to black}
         //SetRGB4CM(Screen^.Screen^.Viewport.ColorMap, 0, 0, 0, 0);

      end else Screen := ScreenPublic; {use public screen for window}

      {Setup Window}

      if (JAEngineModule_Window in Result^.Properties.Modules) then
      begin
         {Create JAWindow}
         Window := JAWindowCreate(Properties.WindowProperties, Screen);
         if (Window=nil) then
         begin
            Log('JAEngine','Failed To Create Window');
            if Screen<>ScreenPublic then {seperate instance, not a copy of the public screen}
               JAScreenDestroy(Screen);
            Log('JAScreenCreate','Unlocking Public Screen [%s]',[pchar(ScreenPublic^.Screen^.Title)]);
            UnlockPubScreen(nil, ScreenPublic^.Screen);
            JAScreenDestroy(ScreenPublic);
            JATimerDestroy(Timer);
            JAMemFree(Result,SizeOf(TJAEngine));
            exit(nil);
         end;
      end;

      {unlock the public screen if we were using it}
      Log('JAScreenCreate','Unlocking Public Screen [%s]',[pchar(ScreenPublic^.Screen^.Title)]);
      UnlockPubScreen(nil, ScreenPublic^.Screen);

      {Setup JARender}

      if (JAEngineModule_Window in Result^.Properties.Modules) {$ifndef JA_SAVESWAP} and not (JAEngineModule_Screen in Result^.Properties.Modules){$endif} then
      begin {Desktop Mode - Setup Blit Buffer}

         {Setup Active Render Calls}
         JAEngineRender := @JAEngineRenderWindow;
         JAEngineRenderSwap := @JaEngineRenderSwapWindow;

         //writeln('Screen.dri_depth = '+inttostr(Screen^.DrawInfo^.dri_depth));
         RenderBuffer := JABitmapCreate(
           Window^.BorderRight-Window^.BorderLeft, Window^.BorderBottom-Window^.BorderTop,
           Screen^.DrawInfo^.dri_depth,
           Window^.ColourMap,
           0,
           Window^.Window^.RPort^.BitMap);

         {Window Blit Double Buffering}
         JARenderBitmap := RenderBuffer;
         JARenderRasterPort := RenderBuffer^.RasterPort;

         {Setup Main Clipping Rect}
         JARenderClipRect := JRectSInt16(0,0,(Window^.BorderRight-Window^.BorderLeft)-0,(Window^.BorderBottom-Window^.BorderTop)-0);
         //JARenderClipRect := JRectSInt16(50,50,(Window^.BorderRight-Window^.BorderLeft)-50,(Window^.BorderBottom-Window^.BorderTop)-50);
      end else
      if (JAEngineModule_Window in Result^.Properties.Modules) and (JAEngineModule_Screen in Result^.Properties.Modules) then
      begin {Screen Mode - Setup Swap Buffers}

         {Setup Active Render Calls}
         JAEngineRender := @JAEngineRenderScreen;
         JAEngineRenderSwap := @JaEngineRenderSwapScreen;

         {set the screen border to black}
         //SetRGB4(Window^.Viewport, 0, 0, 0, 0);
         //SetRGB4(Window^.Viewport, 230, 15, 0, 0);

   	   {Screen Switching Double Buffering}
   		AmigaDoubleBufferPort := CreateMsgPort(); {create double buffer message port}



         case AEngineProperties^.ScreenProperties.API of
            JAGraphicsAPI_Intuition :
            begin
               Buffers[0] := CreateRenderBufferIntuition(0, Window^.Properties.Width, Window^.Properties.Height, Screen^.DrawInfo^.dri_depth, Screen^.Screen, SB_SCREEN_BITMAP, Window^.ColourMap, AmigaDoubleBufferPort);
               Buffers[1] := CreateRenderBufferIntuition(1, Window^.Properties.Width, Window^.Properties.Height, Screen^.DrawInfo^.dri_depth, Screen^.Screen, SB_COPY_BITMAP, Window^.ColourMap, AmigaDoubleBufferPort);
            end;
            JAGraphicsAPI_Picasso :
            begin
               {Picasso wants two copy bitmaps}
               Buffers[0] := CreateRenderBufferIntuition(0, Window^.Properties.Width, Window^.Properties.Height, Screen^.DrawInfo^.dri_depth, Screen^.Screen, SB_COPY_BITMAP, Window^.ColourMap, AmigaDoubleBufferPort);
               Buffers[1] := CreateRenderBufferIntuition(1, Window^.Properties.Width, Window^.Properties.Height, Screen^.DrawInfo^.dri_depth, Screen^.Screen, SB_COPY_BITMAP, Window^.ColourMap, AmigaDoubleBufferPort);
            end;
         end;


   	   BufferNextRender := 0;
   	   BufferNextSwap := 0;

         {Set initial visible bitmaps if we're using ScreenBuffer vs Viewport swapping}
         JARenderRasterPort := Buffers[BufferNextRender]^.RasterPort;

         Window^.RasterPort^.BitMap := Buffers[BufferNextSwap]^.BitMap;
         Window^.ViewPort^.RasInfo^.Bitmap := Buffers[BufferNextSwap]^.BitMap;

         {Setup Main Clipping Rect}
         JARenderClipRect := JRectSInt16(0,0, Window^.Properties.Width-1, Window^.Properties.Height-1);
         //JARenderClipRect := JRectSInt16(15,15, Window^.Properties.Width-1-15, Window^.Properties.Height-1-15);

      end;


      {Setup Palette}

      Palette := JAPaletteCreate(Window^.ViewPort, Screen^.Screen^.ViewPort.ColorMap, 256, 16, 2, not (JAEngineModule_Screen in Result^.Properties.Modules));
      JAPalette.Palette := Palette;

      //Palette := JAPaletteCreate(Window^.ViewPort, Window^.ColourMap, 8,2);

      {$IFDEF JA_ENABLE_CURSOR}

      {Setup Cursor}

      {Setup Cursor ColourMap}
      CursorSpriteIndex := 0; {The cursor is Sprite 0}
      CursorColourRegister := 16 + ((CursorSpriteIndex and $06) shl 1);
      //SetRGB4(Window^.ViewPort,CursorColourRegister + 0,0,0,0); {Cursor Pal 0 Transparent - Can't change}
      SetRGB4(Window^.ViewPort, CursorColourRegister + 1,15,0,0); {Cursor Pal 1}
      SetRGB4(Window^.ViewPort, CursorColourRegister + 2,0,0,0); {Cursor Pal 2}
      SetRGB4(Window^.ViewPort, CursorColourRegister + 3,15,0,15); {Cursor Pal 3}

      {Setup the cursor Bitmap}
      CursorBitmap := JABitmapCreate(16,16,2, Window^.ColourMap, BMF_INTERLEAVED, nil);
      MyPointer := PUInt16(AllocVec(SizeOf(UInt16)*36, MEMF_CHIP or MEMF_CLEAR));
      CursorMemoryPointer := Pointer(MyPointer); // to free it later

      InitRastPort(@CursorRasterPort);

      CursorRasterPort.Bitmap := CursorBitmap^.Bitmap;
      CursorRasterPort.Layer := CursorBitmap^.Layer;

      {Render Cursor}

      {draw X cross}
      SetAPen(@CursorRasterPort, 1);
      GfxMove(@CursorRasterPort, 0, 1);
      Draw(@CursorRasterPort, 14, 15);
      GfxMove(@CursorRasterPort, 14, 1);
      Draw(@CursorRasterPort, 0, 15);

      WaitBlit(); {wait for the blitter to finish before we copy the memory}

      {copy our bitmap into the cursor format}
      {expected cursor format is BMF_INTERLEAVED - 2 bitplanes - one Dword per plane-scanline}
      {TODO : Expand JABitmap to take flags such as BMF_INTERLEAVED and report back,
      so we know if we need to convert non-interleaved data for the cursor}
      {copy non-interleaved bitmap data into interleaved format}
      {K := 2;
      for I := 0 to 31 do
      begin
         move(CursorBitmap^.Bitmap^.Planes[0][I*2], MyPointer[K], SizeOf(UInt16));
         move(CursorBitmap^.Bitmap^.Planes[1][I*2], MyPointer[K+1], SizeOf(UInt16));
         K+=2;
      end;}

      {copy interleaved bitmap data directly}
      move(CursorBitmap^.Bitmap^.Planes[0]^, MyPointer[2], 32*2);
      {cursor format requires 2 blank words each side of the bitmap data}
      MyPointer[0] := 0;
      MyPointer[1] := 0;
      MyPointer[34] := 0;
      MyPointer[35] := 0;
      {Set the created pointer}
      SetPointer(Window^.Window,@MyPointer[0], 16, 16, -8, -8);

      {$ENDIF}

      {Performance Logging}
      JATimerGetTicksMS(Timer, @Performance.TimeDeltaCurrent); {grab an initial stamp}
      Performance.TimeLastSecond := Performance.TimeDeltaCurrent;

      {Create SceneGraph}
      Scene := JASceneCreate('Scene', Window^.BorderRight-Window^.BorderLeft, Window^.BorderBottom-Window^.BorderTop);

      {Mouse State Tracking}
      MouseDragRight := false;
      MouseDragRightStartPos := Vec2SInt32(0,0);
      MouseDragLeft := false;
      MouseDragLeftStartPos := Vec2SInt32(0,0);
   end;

   {OnCreate Callback}
   if (Result^.Properties.OnCreate<>nil) then Result^.Properties.OnCreate(Result);
end;

function JAEngineDestroy(AEngine : PJAEngine) : boolean;
begin
   if AEngine=nil then exit(false);

   with AEngine^ do
   begin
      {OnDestroy Callback}
      if (Properties.OnDestroy<>nil) then Properties.OnDestroy(AEngine);

      {Destroy the SceneGraph}
      JASceneDestroy(Scene);

      {Destroy Palette}
      JAPaletteDestroy(Palette);

      if (JAEngineModule_Window in AEngine^.Properties.Modules) {$ifndef JA_SAVESWAP} and not (JAEngineModule_Screen in Result^.Properties.Modules){$endif} then
      begin {Desktop Mode - Destroy Blit Buffer}
         JABitmapDestroy(RenderBuffer);
         //JAPenSetDestroy(JARenderPenSet);
      end else
      if (JAEngineModule_Window in AEngine^.Properties.Modules) and (JAEngineModule_Screen in AEngine^.Properties.Modules) then
      begin {Screen Mode - Destroy Swap Buffers}
         DestroyRenderBufferIntuition(Buffers[0]);
         DestroyRenderBufferIntuition(Buffers[1]);

         {delete double buffer message port}
         DeleteMsgPort(AmigaDoubleBufferPort);
      end;

      {$IFDEF JA_ENABLE_CURSOR}
      JABitmapDestroy(CursorBitmap);
      {$ENDIF}

      if (JAEngineModule_Window in AEngine^.Properties.Modules) then
         if not JAWindowDestroy(Window) then Log('JAEngine','Failed to destroy window');

      if (JAEngineModule_Screen in AEngine^.Properties.Modules) then
      if AEngine^.Screen<>ScreenPublic then {seperate instance, not a copy of the public screen}
         if not JAScreenDestroy(Screen) then Log('JAEngine','Failed to destroy screen');


      {destroy our reference to the public screen. (flagged at creation not to close attached existing screens)}
      JAScreenDestroy(ScreenPublic);

      JATimerDestroy(Timer);

      {Free Strings}
      SetLength(Properties.Title, 0);
      SetLength(HUDLine1, 0);
      SetLength(HUDLine2, 0);
      SetLength(HUDLine3, 0);
      SetLength(HUDLine4, 0);
      SetLength(HUDLine5, 0);
      SetLength(HUDLine6, 0);

   end;

   if Assigned(AEngine^.CursorMemoryPointer) then
     FreeVec(AEngine^.CursorMemoryPointer);

   JAMemFree(AEngine, SizeOf(TJAEngine));
   Result := true;

   //How are we closing our libraries?
   //CloseLibrary(IntuitionBase);

   Log('JAEngine','Memory Allocated [%d Bytes]',[JAMemAllocated]);
   Log('JAEngine','Memory Released [%d Bytes]',[JAMemReleased]);
   Log('JAEngine','Jade Engine v1.0 shut down');
   writeln('');
end;

function JAEngineUpdate(AEngine : PJAEngine; ADelta    : Float32) : Float32;
var
   I : SInt32;
begin
   Result := 0.0;

   {Update Scene}
   Result += JASceneUpdate(AEngine^.Scene, ADelta);

   {OnUpdate Callback}
   if AEngine^.Properties.OnUpdate<>nil then
      Result += AEngine^.Properties.OnUpdate(ADelta);
end;

function JAEngineRenderScreen(AEngine : PJAEngine) : Float32;
var
	CurrentRasterPort : pRastPort;
   I : SInt32;
begin
   Result := 0;
   {Render}
   with AEngine^ do
   if (Buffers[BufferNextRender]^.Status = BufferStatus_Render) then
	begin
      JARenderRasterPort := Buffers[BufferNextRender]^.RasterPort;

      {Weve already cleared this frame, or at least, issued the operation}

      {Method 1 - Clear Each Plane, assumes 4 planes here - 8 colours}
      {BltClear(Buffers[BufferNextRender]^.Bitmap^.Planes[0], (Buffers[BufferNextRender]^.width div 8) * Buffers[BufferNextRender]^.height, 0);
      BltClear(Buffers[BufferNextRender]^.Bitmap^.Planes[1], (Buffers[BufferNextRender]^.width div 8) * Buffers[BufferNextRender]^.height, 0);
      BltClear(Buffers[BufferNextRender]^.Bitmap^.Planes[2], (Buffers[BufferNextRender]^.width div 8) * Buffers[BufferNextRender]^.height, 0);
      BltClear(Buffers[BufferNextRender]^.Bitmap^.Planes[3], (Buffers[BufferNextRender]^.width div 8) * Buffers[BufferNextRender]^.height, 0);
      }
      {Method 2 - SetRast sets the entire rasterport to a given pen colour}

      //SetWriteMask(JARenderRasterPort, %11110000); {Write to LightPlanes}
      //SetRast(JARenderRasterPort,AEngine^.Palette^.PenGrey or 24); {or 24 = write 1s to shadow planes}

      SetWriteMask(JARenderRasterPort, %11111111); {Write to All Planes}
      SetRast(JARenderRasterPort,0); {Set Light Band 0}
      SetWriteMask(JARenderRasterPort, %00000111); {Don't Write to LightPlanes}
      SetRast(JARenderRasterPort,0); {Black}

      {Method 3 - RectFill fills arbitary rects within the rasterport}
      //RectFill(@JARenderPenSet^.PenBlack^.Rasterport, JARenderClipRect.Left, JARenderClipRect.Top, JARenderClipRect.Right, JARenderClipRect.Bottom);

      //but for example I can use the Blitter to clear the framebuffer while the CPU
      //is computing the transformation matrices to use while drawing the next frame.
      //TODO : so here - the blitter could be busy.

      //OwnBlitter();

      {Render Scene}
      Result += JASceneRender(Scene);

      {OnRender Callback}
      if AEngine^.Properties.OnRender<>nil then
         Result += AEngine^.Properties.OnRender();

      JARenderModelMatrix := Mat3Identity;
      JARenderViewMatrix := Mat3Identity;

      {Render HUD}
      {$ifdef JA_RENDER_HUD}
      Result += JAEngineRenderHUD(AEngine);
      {$endif}
      {Render Buffer Outline rect}
      {JARenderLine(Vec2SInt32(0,0), Vec2SInt32(0,RenderBuffer^.Height-1));
      JARenderLine(Vec2SInt32(RenderBuffer^.Width-1,0), Vec2SInt32(RenderBuffer^.Width-1,RenderBuffer^.Height-1));
      JARenderLine(Vec2SInt32(0,0), Vec2SInt32(RenderBuffer^.Width-1,0));
      JARenderLine(Vec2SInt32(0,RenderBuffer^.Height-1), Vec2SInt32(RenderBuffer^.Width-1,RenderBuffer^.Height-1));}

      {Ensure all rendering completes}
      WaitBlit();

      {Screen Mode - Flag Buffers}

      {swap the buffer index}
      Buffers[BufferNextRender]^.Status := BufferStatus_Swap;
   	if BufferNextRender=0 then BufferNextRender := 1 else BufferNextRender := 0;
   end;
end;

function JAEngineRenderSwapScreen(AEngine : PJAEngine) : Float32; {returns execution time in MS}
begin
   Result := 0;
   with AEngine^ do
   begin
      {Screen Switching Double Buffering}
	   if (Buffers[BufferNextSwap]^.Status = BufferStatus_Swap) then
	   begin
         Buffers[BufferNextSwap]^.Status := BufferStatus_Busy;

         //BeginRefresh(Window^.Window);
         //EndRefresh(Window^.Window,true);


         //OwnBlitter();

         {ChangeVPBitMap}
			ChangeVPBitMap(Window^.ViewPort,Buffers[BufferNextSwap]^.Bitmap, Buffers[BufferNextSwap]^.ScreenBuffer^.sb_DBufInfo);
         MakeScreen(Screen^.Screen); {Inform intuition that screen has changed}
         RethinkDisplay(); {Intuition compatible MrgCop & LoadView. also calls waitTOF()}

         if BufferNextSwap=0 then BufferNextSwap := 1 else BufferNextSwap := 0;

         //TODO : Investigate queued blits
         //QBlit()
         //QBSBlit()

         //TODO : Investigate interleaved bitmaps for single blit operations.

         {ChangeScreenBuffer}
         {if ChangeScreenBuffer(Screen^.Screen, Buffers[BufferNextSwap]^.ScreenBuffer)<>0 then
		   begin
            {we shouldn't have to do this - so we're missing a screen/buffer creation param?}
            Window^.ViewPort^.RasInfo^.Bitmap := Buffers[BufferNextSwap]^.BitMap;
            Window^.RasterPort^.BitMap := Buffers[BufferNextSwap]^.BitMap;
            Buffers[BufferNextSwap]^.Status := BufferStatus_Render;
			   if BufferNextSwap=0 then BufferNextSwap := 1 else BufferNextSwap := 0;

            {TODO : benchmark to see if it matters to try not to call MakeScreen for Picasso on Stock}
            //if (AEngine^.Properties.ScreenProperties.API = JAGraphicsAPI_Intuition) then
            //begin {not needed for Picasso Screens}
            //   MakeScreen(Screen^.Screen);
            //end;

            MakeScreen(Screen^.Screen); {Inform intuition that screen has changed}
            RethinkDisplay(); {Intuition compatible MrgCop & LoadView. also calls waitTOF()}

		   end;//else
		   begin
			   {couldn't swap, need to try again}
            {Waiting here causes flicker on Picasso}
            //WaitBOVP(Window^.Viewport);
			   //WaitTOF();
		   end;  }

         //DisownBlitter();
      end;
   end;
end;

function JAEngineRenderWindow(AEngine : PJAEngine) : Float32;
var
	CurrentRasterPort : pRastPort;
   I : SInt32;
begin
   Result := 0;
   {Render}
   with TJAEngine(AEngine^) do
   begin
      {RenderBuffer Target}
      JARenderRasterPort := RenderBuffer^.RasterPort;
      {WindowBuffer Target}
      //JARenderRasterPort := @Window^.RasterPort;

      {Method 2 - SetRast sets the entire rasterport to a given pen colour}

      //SetWriteMask(JARenderRasterPort, %11110000); {Write to LightPlanes}
      //SetRast(JARenderRasterPort,AEngine^.Palette^.PenGrey or 24); {or 24 = write 1s to shadow planes}


      SetWriteMask(JARenderRasterPort, %11111111); {Write to All Planes}
      SetRast(JARenderRasterPort,0); {Set Light Band 0}
      SetWriteMask(JARenderRasterPort, %00000111); {Don't Write to LightPlanes}
      SetRast(JARenderRasterPort,0); {Black}

      {Method 3 - RectFill fills arbitary rects within the rasterport}
      //SetAPen(JARenderRasterPort, 1);
      //SetBPen(JARenderRasterPort, 1);
      //SetAPen(JARenderRasterPort, AEngine^.Palette^.PenRed);
      //SetBPen(JARenderRasterPort, AEngine^.Palette^.PenRed);
      //RectFill(JARenderRasterPort, JARenderClipRect.Left, JARenderClipRect.Top, JARenderClipRect.Right, JARenderClipRect.Bottom);
      //so here - the blitter could be busy.

      {Render Scene}
      Result += JASceneRender(Scene);

      {OnRender Callback}
      if AEngine^.Properties.OnRender<>nil then
         Result += AEngine^.Properties.OnRender();

      JARenderModelMatrix := Mat3Identity;
      JARenderViewMatrix := Mat3Identity;

      {Render HUD}
      {$ifdef JA_RENDER_HUD}
      Result += JAEngineRenderHUD(AEngine);
      {$endif}

      {SetAPen(JARenderRasterPort, AEngine^.Palette^.PenRed);
      {Render Buffer Outline rect}
      JARenderLine(Vec2SInt32(0,0), Vec2SInt32(0,RenderBuffer^.Height-1));
      JARenderLine(Vec2SInt32(RenderBuffer^.Width-1,0), Vec2SInt32(RenderBuffer^.Width-1,RenderBuffer^.Height-1));
      JARenderLine(Vec2SInt32(0,0), Vec2SInt32(RenderBuffer^.Width-1,0));
      JARenderLine(Vec2SInt32(0,RenderBuffer^.Height-1), Vec2SInt32(RenderBuffer^.Width-1,RenderBuffer^.Height-1));
      }
      {Ensure all rendering completes}
      WaitBlit();
   end;
end;

function JAEngineRenderSwapWindow(AEngine : PJAEngine) : Float32; {returns execution time in MS}
begin
   Result := 0;
   with AEngine^ do
   begin
      {Window Blitting Double Buffering}

      {NOTE : Source Vec2,Dest Vec2 - then Width,Height}
      //BltBitMapRastPort(RenderBuffer^.Bitmap,0,0, Window^.RasterPort,0,0,RenderBuffer^.Width,RenderBuffer^.Height, $C0);
      //BltBitMap(RenderBuffer^.Bitmap,0,0,Window^.RasterPort^.Bitmap,0,0,Window^.Properties.Width,Window^.Properties.Height, $C0,0,nil);
      ClipBlit(RenderBuffer^.RasterPort,0,0,Window^.RasterPort,0,0,Window^.Properties.Width,Window^.Properties.Height, $C0);



      {wait for the blitter to finish - do this if result memory is to be accessed immediately}
      //WaitBlit();
   end;
end;

function JAEngineExecute(AEngine : PJAEngine) : Float32; {main loop}
var
   TimeNow : Float32;
begin
   Log('JAEngine','Execute Begin');
   Result := 0;
   JATimerGetTicksMS(AEngine^.Timer, @AEngine^.Performance.TimeLastSecond); {grab an initial stamp}
   JATimerGetTicksMS(AEngine^.Timer, @AEngine^.Performance.TimeDeltaCurrent); {grab an initial stamp}

   with AEngine^ do while not Terminated do
   begin
   	//crashme

   	//Forbid(); {Exec - turn off multi-tasking}
   	//Disable();

      {Calculate Delta}
      with Performance do
      begin
         TimeDeltaPrevious := TimeDeltaCurrent;
         JATimerGetTicksMS(Timer, @TimeDeltaCurrent);
         CurrentDelta := ((TimeDeltaCurrent-TimeDeltaPrevious) / 1000); {0.0<=>1.0 = 1 second}
         WindowDelta += CurrentDelta;
      end;

      {Try to get a window message}
      AmigaIDCMPMessage := GetMsg(Window^.UserPort);
     	while (AmigaIDCMPMessage<>nil) do
  		begin
  		   {pass window message to the event handler}
     		ProcessIDCMPMessage(AEngine, PIntuiMessage(AmigaIDCMPMessage));
      	{Reply to the OS}
      	ReplyMsg(AmigaIDCMPMessage);
      	AmigaIDCMPMessage := GetMsg(Window^.UserPort);
      end;

      if (JAEngineModule_Screen in AEngine^.Properties.Modules) then
      begin {Screen Switching Double Buffering}
         {try to get a doublebuffer message}
	      AmigaDoubleBufferMessage := GetMsg(AmigaDoubleBufferPort);
	      while (AmigaDoubleBufferMessage<>nil) do
	      begin
            {calls hook which flags finished buffer as renderable}
	   	   ProcessDoubleBufferMessage(AEngine, AmigaDoubleBufferMessage);
	   	   {we don't reply to this message}
	         AmigaDoubleBufferMessage := GetMsg(AmigaDoubleBufferPort);
	      end;

         {Wait on the Port}
	      //Wait(1 shl AmigaDoubleBufferPort^.mp_SigBit);
	      //FAmigaIDCMPMessage := WaitPort(FAmigaWindowUserPort);
 	      {wait for next message}
 	      //sigs = IExec->Wait( ( 1 << dbufport->mp_SigBit ) | ( 1 << userport->mp_SigBit ) );
	      //Wait( (1 shl FAmigaDoubleBufferPort^.mp_SigBit) or ( 1 shl FAmigaWindowUserPort^.mp_SigBit));
	      //WaitPort(AmigaDoubleBufferPort);
      end;

      {TODO : We should issue the blitter clear of the next frame here, so we can update while it's still operating}
      
      if (Buffers[BufferNextRender]^.Status = BufferStatus_Render) then
	   begin
         {Method 2 - SetRast sets the entire rasterport to a given pen colour}
         {Seems to ignore WriteMasks}
         //SetRast(JARenderRasterPort,1);
      end;

      {Update}
      JATimerLap(Timer);
      Result += JAEngineUpdate(AEngine, Performance.CurrentDelta);
      Performance.WindowUpdateMS += JATimerLap(Timer);
      Performance.WindowUPS += 1;

      {Render}
      JATimerLap(Timer);
      Result += JAEngineRender(AEngine);
      Performance.WindowRenderMS += JATimerLap(Timer);
      Performance.WindowFPS += 1;

      {Swap}
      JATimerLap(Timer);
      JAEngineRenderSwap(AEngine);
      Performance.WindowSwapWait += JATimerLap(Timer);

      {update performance stats}
      JATimerGetTicksMS(Timer, @TimeNow);
      if ((TimeNow-Performance.TimeLastSecond) > 1000) then
      with Performance do
      begin
         {calculate stats}
         AverageUpdateMS := WindowUpdateMS / WindowUPS;
         AverageRenderMS := WindowRenderMS / WindowFPS;
         AverageDelta := (WindowDelta / WindowUPS) * 1000; {Into MS}
         AverageSwapWait := WindowSwapWait / WindowFPS;
         AverageUPS := WindowUPS;
         AverageFPS := WindowFPS;

         {reset window}
         WindowUpdateMS := 0;
         WindowRenderMS := 0;
         WindowDelta := 0;
         WindowSwapWait := 0;
         WindowUPS := 0;
         WindowFPS := 0;

         {update the hud}
         HUDLine1 := 'ExecMS:' + floattostrf(AverageUpdateMS, ffGeneral, 4, 4);
         HUDLine1Length := length(HUDLine1);
         HUDLine2 := 'RendMS:' + floattostrf(AverageRenderMS, ffGeneral, 4, 4);
         HUDLine2Length := length(HUDLine2);
         HUDLine3 := 'SwapMS:' + floattostrf(AverageSwapWait, ffGeneral, 4, 4);
         HUDLine3Length := length(HUDLine3);
         HUDLine4 := 'DltaMS:' + floattostrf(AverageDelta, ffGeneral, 4, 4);
         HUDLine4Length := length(HUDLine4);
         HUDLine5 := 'FPS:' + floattostr(AverageFPS);
         HUDLine5Length := length(HUDLine5);
         //HUDLine4 := 'UPS: ' + floattostr(AverageUPS);
         //HUDLine4Length := length(HUDLine4);
         {$ifndef JA_RENDER_HUD}
         writeln(HUDLine5);
         {$endif}
         TimeLastSecond := TimeNow;
      end;

      //Enable();
      //Permit(); {Exec - enable multi-tasking}
   end;
   Log('JAEngine','Execute End');
end;

function JAEngineRenderHUD(AEngine : PJAEngine) : Float32; {returns execution time in MS}
var
   XPos,YPos : SInt32;
   Offset : TVec2SInt16;
   FH: Word;
begin
   if JARenderRasterPort=nil then exit(0);
   with AEngine^ do
   begin
      Offset.X := 5;
      Offset.Y := 5;

      //SetWrMsk(JARenderRasterPort, %111111); { Enable Planes 1-5}
      SetDrMd(JARenderRasterPort, JAM1); {1 colour - no background colour}
      SetAPen(JARenderRasterPort, AEngine^.Palette^.PenWhite); { First Colour In Palette (Red) }

      //JARenderLine(Vec2(20,20),Vec2(100,100));

      FH := 10;
      if Assigned(JARenderRasterPort^.Font) then
        FH := JARenderRasterPort^.Font^.tf_YSize;
      // just to make sure
      if FH > 100 then
        FH := 10;
      XPos := Window^.BorderLeft + Offset.X;
      YPos := Window^.BorderTop + ((FH div 2)+1) + Offset.Y;
      gfxMove(JARenderRasterPort, XPos, YPos);
      GfxText(JARenderRasterPort, pchar(HUDLine1), HUDLine1Length);
      //
      YPos += FH;
      gfxMove(JARenderRasterPort, XPos, YPos);
      GfxText(JARenderRasterPort, pchar(HUDLine2), HUDLine2Length);
      //
      YPos += FH;
      gfxMove(JARenderRasterPort, XPos, YPos);
      GfxText(JARenderRasterPort, pchar(HUDLine3), HUDLine3Length);
      //
      YPos += FH;
      gfxMove(JARenderRasterPort, XPos, YPos);
      GfxText(JARenderRasterPort, pchar(HUDLine4), HUDLine4Length);

      YPos += FH;
      gfxMove(JARenderRasterPort, XPos, YPos);
      GfxText(JARenderRasterPort, pchar(HUDLine5), HUDLine5Length);
      {YPos += HUD5Extent.te_Height;
      gfxMove(JARenderRasterPort, XPos, YPos);
      GfxText(JARenderRasterPort, pchar(HUDLine6), HUDLine6Length);}

      //WaitBlit(); {wait for the blitter to finish - do this if result memory is to be accessed immediately}
   end;
end;

procedure ProcessIDCMPMessage(AEngine : PJAEngine; AMessage : pIntuiMessage);
var
   AStr : string;
   V1,V2 : TVec2;
   V1L,V2L : Float32;
   V1A, V2A : Float32;
begin
   with AEngine^ do
   case AMessage^.IClass of
      BUTTONIDCMP : ; {button clicked}

      IDCMP_MOUSEMOVE :  {mouse motion}
      begin

         MousePositionPrevious := MousePosition;
         MousePosition.X := AMessage^.MouseX;
         MousePosition.Y := AMessage^.MouseY;
         MouseCoord := JAScenePointToCoord(AEngine^.Scene, MousePosition);
         MouseRelative := MousePosition - MousePositionPrevious;

         AEngine^.Scene^.MousePosition := JAScenePointToCoord(AEngine^.Scene, MousePosition);

         if MouseDragLeft then
         begin
            MouseDragLeftRelative.X := AMessage^.MouseX - MouseDragLeftStartPos.X;
            MouseDragLeftRelative.Y := AMessage^.MouseY - MouseDragLeftStartPos.Y;

            MouseDragLeftStartCoord := JAScenePointToCoord(AEngine^.Scene, MouseDragLeftStartPos);

            JANodeSetLocalPosition(AEngine^.Scene^.Camera, MouseDragCameraPositionStart + (MouseDragLeftStartCoord-MouseCoord)); {relative position}
         end;
         if MouseDragRight then
         begin
            MouseDragRightRelative.X := AMessage^.MouseX - MouseDragRightStartPos.X;
            MouseDragRightRelative.Y := AMessage^.MouseY - MouseDragRightStartPos.Y;

            MouseDragRightStartCoord := JAScenePointToCoord(AEngine^.Scene, MouseDragRightStartPos);

            V1 := MouseDragRightStartCoord - AEngine^.Scene^.Camera^.Spatial.LocalPosition;
            V2 := MouseCoord - AEngine^.Scene^.Camera^.Spatial.LocalPosition;
            V1L := Vec2Length(V1);
            V2L := Vec2Length(V2);
            V1A := Vec2Angle(Vec2Up, V1{/V1L}) * JRadToDeg;
            V2A := Vec2Angle(Vec2Up, V2{/V2L}) * JRadToDeg;

            JANodeSetLocalScale(AEngine^.Scene^.Camera, MouseDragScaleStart * (V1L/V2L));
            JANodeSetLocalRotation(AEngine^.Scene^.Camera, MouseDragCameraRotationStart + (V1A-V2A));
         end;

         //Log('ProcessIDCMPMessage','MouseX='+inttostr(AMessage^.MouseX)+' MouseY='+inttostr(AMessage^.MouseY));

      end;
      IDCMP_MOUSEBUTTONS : {mouse button}
      begin

         AStr := '';
         MousePositionPrevious := MousePosition;
         MousePosition.X := AMessage^.MouseX;
         MousePosition.Y := AMessage^.MouseY;
         MouseRelative := MousePosition-MousePositionPrevious;

         if (AMessage^.Qualifier and (IEQUALIFIER_CONTROL))<>0 then
         AStr += 'Ctrl ';

         if (AMessage^.Qualifier and (IEQUALIFIER_LALT or IEQUALIFIER_RALT))<>0 then
         AStr += 'Alt ';

         if (AMessage^.Qualifier and (IEQUALIFIER_LSHIFT or IEQUALIFIER_RSHIFT))<>0 then
         AStr += 'Shift ';

         case AMessage^.Code of
            SELECTDOWN :
            begin
               AStr += 'Left Down ';
               MouseDragLeft := true;
               MouseDragLeftStartPos.X := AMessage^.MouseX;
               MouseDragLeftStartPos.Y := AMessage^.MouseY;
               MouseDragLeftStartCoord := JAScenePointToCoord(AEngine^.Scene, MouseDragLeftStartPos);
               MouseDragCameraPositionStart := AEngine^.Scene^.Camera^.Spatial.WorldPosition;
            end;
            SELECTUP :
            begin
               AStr += 'Left Up ';
               MouseDragLeft := false;
            end;
            MENUDOWN :
            begin
               AStr += 'Right Down ';
               MouseDragRight := true;
               MouseDragRightStartPos.X := AMessage^.MouseX;
               MouseDragRightStartPos.Y := AMessage^.MouseY;
               MouseDragRightStartCoord := JAScenePointToCoord(AEngine^.Scene, MouseDragRightStartPos);
               MouseDragCameraRotationStart := AEngine^.Scene^.Camera^.Spatial.WorldRotation;
               MouseDragScaleStart := AEngine^.Scene^.Camera^.Spatial.WorldScale;
            end;
            MENUUP :
            begin
               AStr += 'Right Up ';
               MouseDragRight := false;
            end;
            MIDDLEDOWN : AStr += 'Middle Down ';
            MIDDLEUP : AStr += 'Middle Up ';
         end;
         AStr += '['+IntToStr(AMessage^.MouseX)+'x'+IntToStr(AMessage^.MouseY)+']';
         Log('ProcessIDCMPMessage',AStr);
      end;

      IDCMP_RAWKEY :
      begin
         case AMessage^.Code of
            NM_WHEEL_UP :
            begin
               {Position Relative To Camera Before Scale}

               V1 := Vec2DotMat3Affine(MouseCoord, AEngine^.Scene^.Camera^.Spatial.WorldMatrixInverse);

               JANodeSetLocalScale(AEngine^.Scene^.Camera,
                  AEngine^.Scene^.Camera^.Spatial.LocalScale * 0.9);

               V2 := Vec2DotMat3Affine(V1, AEngine^.Scene^.Camera^.Spatial.WorldMatrix);

               V2 := MouseCoord-V2;

               {Position Relative To Camera After Scale}
               //MouseCoord := JAScenePointToCoord(AEngine^.Scene, MousePosition);
               //V2 := (MouseCoord-AEngine^.Scene^.Camera^.Spatial.LocalPosition);

               //V2 := Vec2DotMat3Affine(V2-V1,AEngine^.Scene^.Camera^.Spatial.WorldMatrix);

               JANodeSetLocalPosition(AEngine^.Scene^.Camera, AEngine^.Scene^.Camera^.Spatial.LocalPosition + V2);

               //MouseCoord := JAScenePointToCoord(AEngine^.Scene, MousePosition);
            end;
            NM_WHEEL_DOWN :
            begin
               {Position Relative To Camera Before Scale}
               V1 := Vec2DotMat3Affine(MouseCoord, AEngine^.Scene^.Camera^.Spatial.WorldMatrixInverse);

               JANodeSetLocalScale(AEngine^.Scene^.Camera,
                  AEngine^.Scene^.Camera^.Spatial.LocalScale * 1.1);

               V2 := Vec2DotMat3Affine(V1, AEngine^.Scene^.Camera^.Spatial.WorldMatrix);

               V2 := MouseCoord-V2;

               {Position Relative To Camera After Scale}
               //MouseCoord := JAScenePointToCoord(AEngine^.Scene, MousePosition);
               //V2 := (MouseCoord-AEngine^.Scene^.Camera^.Spatial.LocalPosition);

               //V2 := Vec2DotMat3Affine(V2-V1,AEngine^.Scene^.Camera^.Spatial.WorldMatrix);

               JANodeSetLocalPosition(AEngine^.Scene^.Camera, AEngine^.Scene^.Camera^.Spatial.LocalPosition + V2);
            end;
            NM_WHEEL_LEFT : ;
            NM_WHEEL_RIGHT : ;
            NM_BUTTON_FOURTH : ;
         end;
      end;
      IDCMP_VANILLAKEY :
      begin {key pressed}

         //AEngine^.Terminated := true;
      end;
      IDCMP_NEWSIZE : ; {window resized}
      IDCMP_CLOSEWINDOW : AEngine^.Terminated := True;
      IDCMP_REFRESHWINDOW : ;
      IDCMP_INTUITICKS : ;
         //IDCMP_MENUPICK : ProcessMenu;
		//IDCMP_GADGETUP : EasyReq(wp, WIN_TITLE, 'You have clicked on the Gadget!', 'Wheeew!');
    end;
end;

procedure ProcessDoubleBufferMessage(AEngine : PJAEngine; AMessage : pMessage);
var
	ABuffer : UInt32;
begin
   {dbi_SafeMessage is immediately followed by dbi_UserData1 inside the DBufInfo structure.
	So if we offset the message pointer by the size of a TMessage, we're pointing at dbi_UserData1,
	we're casting and dereferencing this offset pointer to a UInt32, which is our Buffer Index.
	Hence why the following line looks stupid.}
	
   ABuffer := PUInt32(@AMessage[1])^;
      
	{flag the buffer as ready to render}
   AEngine^.Buffers[ABuffer]^.Status := BufferStatus_Render;

   //log('ProcessDoubleBufferMessage','ABuffer = ' + inttostr(ABuffer));
end;

end.
