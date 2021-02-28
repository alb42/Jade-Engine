unit JRenderBufferIntuition;
{$mode objfpc}{$H+}

interface

uses
	{FPC} SysUtils,
	{Amiga} Exec, Intuition, AGraphics, layers, GadTools, Utility,
   {JAE} JATypes, JABitmap;
	
type
	TJRenderBufferIntuitionStatus = (
		BufferStatus_Render = 0, {Buffer ready for render}
		BufferStatus_Swap = 1, {Buffer ready for swap}
		BufferStatus_Busy = 3 {Buffer is currently busy}
		);

	TJRenderBufferIntuition = record
      Width : SInt16;
      Height : SInt16;
      Depth : SInt16;
      Bitmap : pBitMap;
      ColourMap : pColorMap;

      {Layer Clipping Region}
      LayerInfo : pLayer_Info;
      Layer : pLayer;

      {RasterPort}
      RasterPort : PRastPort;
      TmpRas : TTmpRas;
      TmpRasBuffer : pointer;
      TmpRasBufferSize : UInt32;
      AreaInfo : TAreaInfo;
      AreaInfoVertices : pointer;
      AreaInfoVerticesCount : UInt32;


      ScreenBuffer : pScreenBuffer;
		Status : TJRenderBufferIntuitionStatus;
		Index : UInt16;

	end;
	PJRenderBufferIntuition = ^TJRenderBufferIntuition;


function CreateRenderBufferIntuition(
   AIndex : UInt32;
   AWidth, AHeight, ADepth : UInt32;
   AScreen : pScreen;
   AScreenBufferType : UInt32;
   AColourMap : pColorMap;
   ADoubleBufferMessagePort : pMsgPort) : PJRenderBufferIntuition;

function DestroyRenderBufferIntuition(ARenderBufferIntuition : PJRenderBufferIntuition) : boolean;

implementation

function BufferBitmapsSetup(ARenderBuffer : PJRenderBufferIntuition; AWidth, AHeight, ADepth : UInt16) : boolean;
begin
	{TODO : currently gets chip memory for standard graphics, probably different for picasso/RTG}

	{allocate memory for the bitmap}
  ARenderBuffer^.Bitmap := AllocBitMap(AWidth, AHeight, ADepth, 0, {BMF_CLEAR,} nil);

	Result := true;	
end;

{AScreenBufferType = SB_SCREEN_BITMAP or SB_COPY_BITMAP}
function CreateRenderBufferIntuition(AIndex : UInt32; AWidth,AHeight,ADepth : UInt32; AScreen : pScreen; AScreenBufferType : UInt32; AColourMap : pColorMap; ADoubleBufferMessagePort : pMsgPort) : PJRenderBufferIntuition;
var
   TextAttributes : TTextAttr;
   Font : PTextFont;
begin
	{get memory for structure}
	Result := PJRenderBufferIntuition(AllocMem(SizeOf(TJRenderBufferIntuition)));

   Result^.Width := AWidth;
   Result^.Height := AHeight;
   Result^.Depth := ADepth;
   Result^.ColourMap := AColourMap;

   {create bitmap}
	BufferBitmapsSetup(Result, AWidth, AHeight, ADepth);
	{allocate a screen buffer}
	Result^.ScreenBuffer := AllocScreenBuffer(AScreen, Result^.Bitmap, AScreenBufferType);
	{store the bufferIndex inside the userdata for identification from a message}
	Result^.ScreenBuffer^.sb_DBufInfo^.dbi_UserData1 := APTR(AIndex);
   {setup double-buffer safe message reply-port}
   Result^.ScreenBuffer^.sb_DBufInfo^.dbi_SafeMessage.mn_ReplyPort := ADoubleBufferMessagePort;
   // create layer take rastport
   Result^.LayerInfo := NewLayerInfo();
   Result^.Layer := CreateUpfrontLayer(Result^.LayerInfo, Result^.Bitmap, 0, 0, Result^.Width-1, Result^.Height-1, LAYERSIMPLE, nil);
   Result^.RasterPort :=  Result^.Layer^.RP;

	{set rasterport to doublebuffered}
	Result^.RasterPort^.Flags := DBUFFER;

   {Setup the font}
   TextAttributes.ta_Name := 'courier.font'; //11
   //TextAttributes.ta_Name := 'topaz.font'; //8
   TextAttributes.ta_YSize := 13;
   TextAttributes.ta_Style := 0;
   TextAttributes.ta_Flags := 0;
   Font := OpenFont(@TextAttributes);
   SetFont(Result^.RasterPort, Font);

   {Setup the TmpRas for Area Fill Functions}

   {TODO : we need to pass the renderbuffer dimensions. docs say 8 - is this
   an assumed bitdepth or it's 8 per pixel across the board for tmpras?}
   {Width * Height * 8}
   {Apparently this is the space for one scanline, setting at least a
   4K TmpRas can apparently trick/force the last blit operation performed
   to exit early allowing for some concurrent CPU execution at that time}

   //Result^.TmpRasBufferSize := 1024*4;
   Result^.TmpRasBufferSize := AWidth * AHeight;
   Result^.TmpRasBuffer := AllocVec(Result^.TmpRasBufferSize,  MEMF_CHIP or MEMF_CLEAR);
   InitTmpRas(@Result^.TmpRas, Result^.TmpRasBuffer, Result^.TmpRasBufferSize);
   Result^.RasterPort^.TmpRas := @(Result^.TmpRas);

   {The size of the region pointed to by buffer  should be five (5) times as
   large as maxvectors. This size is in bytes.}
   Result^.AreaInfoVerticesCount := 12800;
   Result^.AreaInfoVertices := AllocVec(Result^.AreaInfoVerticesCount*5, {MEMF_CHIP or }MEMF_CLEAR);
   InitArea(@Result^.AreaInfo, Result^.AreaInfoVertices, Result^.AreaInfoVerticesCount);
   Result^.RasterPort^.AreaInfo := @(Result^.AreaInfo);


   {set initial status to render}
   Result^.Status := BufferStatus_Render;
end;

function DestroyRenderBufferIntuition(ARenderBufferIntuition : PJRenderBufferIntuition) : boolean;
begin
	Result := true;

  if (ARenderBufferIntuition=nil) then exit(false);
   with ARenderBufferIntuition^ do
   begin
      RasterPort^.AreaInfo := nil;
      RasterPort^.Bitmap := nil;
      RasterPort^.TmpRas := nil;
      FreeVec(AreaInfoVertices);
      FreeVec(TmpRasBuffer);
      {Close the font}
      CloseFont(RasterPort^.Font);
      DeleteLayer(0, Layer);
      DisposeLayerInfo(LayerInfo);


      {free the system bitmap}
      if (ARenderBufferIntuition^.Bitmap<>nil) then
      begin
         {Note that the AutoDoc FreeBitMap() recommends calling WaitBlit() before releasing
         the Bitmap to be sure that nothing is being written in it.}
         WaitBlit();
         FreeBitMap(ARenderBufferIntuition^.Bitmap);
      end;
   end;

	FreeMem(ARenderBufferIntuition);
end;

end.
