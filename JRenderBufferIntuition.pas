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
      RegionRect : tRectangle;
      Region : pRegion;

      {RasterPort}
      RasterPort : TRastPort;
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

function BitmapFreePlanes(ABitmap : PBitmap; AWidth, AHeight, ADepth : UInt16) : boolean;
var
	PlaneI : UInt16;
begin
	for PlaneI := 0 to ADepth-1 do
	begin
   	if (ABitmap^.Planes[PlaneI] <> nil) then
   	begin
   		FreeRaster(ABitmap^.Planes[PlaneI], AWidth, AHeight);
   		ABitmap^.Planes[PlaneI] := nil; {TODO : does FreeRaster() do this for us?}
   	end;
	end;
	Result := true;
end;

function BitmapSetupPlanes(ABitmap : PBitMap; AWidth, AHeight, ADepth : UInt16) : boolean;
var
	PlaneI : UInt16;
begin
	for PlaneI := 0 to ADepth-1 do
	begin
		ABitmap^.Planes[PlaneI] := AllocRaster(AWidth, AHeight);
		
		if (ABitmap^.Planes[PlaneI] <> nil) then
		begin
			BltClear(ABitmap^.Planes[PlaneI], (AWidth div 8) * AHeight, 1);
		end else
		begin
		  BitmapFreePlanes(ABitmap, AWidth, AHeight, ADepth);
		  exit(false);
		end;
	end;  	 	
	Result := true;
end;

function BufferBitmapsSetup(ARenderBuffer : PJRenderBufferIntuition; AWidth, AHeight, ADepth : UInt16) : boolean;
var
	PlaneResult : boolean;
begin
	{TODO : currently gets chip memory for standard graphics, probably different for picasso/RTG}

	{allocate memory for the bitmap}
   ARenderBuffer^.Bitmap := AllocBitMap(AWidth, AHeight, ADepth, 0, {BMF_CLEAR,} nil);
    {
	ARenderBuffer^.Bitmap := nil;
	ARenderBuffer^.Bitmap := PBitMap(AllocVec(SizeOf(TBitMap), MEMF_CHIP or MEMF_CLEAR)); 	
	
	{error check and exit}
	if (ARenderBuffer^.Bitmap=nil) then exit(false);
		 		
	{initalize the bitmap}
	InitBitMap(ARenderBuffer^.Bitmap, ADepth, AWidth, AHeight);
   
   {setup the planes}
   PlaneResult := BitmapSetupPlanes(ARenderBuffer^.Bitmap, ADepth, AWidth, AHeight);
   
   {error check and clean exit}
	if (PlaneResult=false) then
	begin   			
		if (ARenderBuffer^.Bitmap<>nil) then FreeVec(ARenderBuffer^.Bitmap);//, SizeOf(TBitMap));		
		exit(false);
	end;  }

	Result := true;	
end;

function BufferBitmapsFree(ARenderBuffer : PJRenderBufferIntuition; AWidth, AHeight, ADepth : UInt16) : boolean;
begin
	if (ARenderBuffer^.Bitmap<>nil) then
	begin
		BitmapFreePlanes(ARenderBuffer^.Bitmap, ADepth, AWidth, AHeight);
		FreeVec(ARenderBuffer^.Bitmap);//, SizeOf(TBitMap));
	end;	
	Result := true;
end;

{AScreenBufferType = SB_SCREEN_BITMAP or SB_COPY_BITMAP}
function CreateRenderBufferIntuition(AIndex : UInt32; AWidth,AHeight,ADepth : UInt32; AScreen : pScreen; AScreenBufferType : UInt32; AColourMap : pColorMap; ADoubleBufferMessagePort : pMsgPort) : PJRenderBufferIntuition;
var
   TextAttributes : TTextAttr;
   Font : PTextFont;
begin
	{get memory for structure}
	Result := PJRenderBufferIntuition(AllocVec(SizeOf(TJRenderBufferIntuition), MEMF_ANY or MEMF_CLEAR));

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

	{init raster port}
   InitRastPort(@Result^.RasterPort);
   {attach the screenbuffer bitmap to the rasterport}
	Result^.RasterPort.Bitmap := Result^.Bitmap; //Result^.ScreenBuffer^.sb_BitMap;
	{set rasterport to doublebuffered}
	Result^.RasterPort.Flags := DBUFFER;

   {Setup the font}
   TextAttributes.ta_Name := 'courier.font'; //11
   //TextAttributes.ta_Name := 'topaz.font'; //8
   TextAttributes.ta_YSize := 13;
   TextAttributes.ta_Style := 0;
   TextAttributes.ta_Flags := 0;
   Font := OpenFont(@TextAttributes);
   SetFont(@Result^.RasterPort, Font);


   {Setup Layer Clipping Region}
   Result^.LayerInfo := NewLayerInfo();
   Result^.Layer := CreateUpfrontLayer(Result^.LayerInfo, Result^.Bitmap, 0, 0, Result^.Width-1, Result^.Height-1, 0, nil);
   Result^.Region := NewRegion();
   Result^.RegionRect.MinX := 0;
   Result^.RegionRect.MinY := 0;
   Result^.RegionRect.MaxX := Result^.Width-1;
   Result^.RegionRect.MaxY := Result^.Height-1;
   OrRectRegion(Result^.Region, @Result^.RegionRect);
   InstallClipRegion(Result^.Layer, Result^.Region);

   {Attach the Clipping Layer to the RasterPort}
   Result^.RasterPort.Layer := Result^.Layer;

   {Setup the TmpRas for Area Fill Functions}

   {TODO : we need to pass the renderbuffer dimensions. docs say 8 - is this
   an assumed bitdepth or it's 8 per pixel across the board for tmpras?}
   {Width * Height * 8}
   {Apparently this is the space for one scanline, setting at least a
   4K TmpRas can apparently trick/force the last blit operation performed
   to exit early allowing for some concurrent CPU execution at that time}

   //TmpRasBufferSize := 1024*4;
   Result^.TmpRasBufferSize := 1024*768*4;
   Result^.TmpRasBuffer := AllocVec(Result^.TmpRasBufferSize, MEMF_CHIP or MEMF_CLEAR);
   InitTmpRas(@Result^.TmpRas, Result^.TmpRasBuffer, Result^.TmpRasBufferSize);
   Result^.RasterPort.TmpRas := @Result^.TmpRas;

   {The size of the region pointed to by buffer  should be five (5) times as
   large as maxvectors. This size is in bytes.}
   Result^.AreaInfoVerticesCount := 128;
   Result^.AreaInfoVertices := AllocVec(Result^.AreaInfoVerticesCount*5, MEMF_CHIP or MEMF_CLEAR);
   InitArea(@Result^.AreaInfo, Result^.AreaInfoVertices, Result^.AreaInfoVerticesCount);
   Result^.RasterPort.AreaInfo := @Result^.AreaInfo;


   {set initial status to render}
   Result^.Status := BufferStatus_Render;
end;

function DestroyRenderBufferIntuition(ARenderBufferIntuition : PJRenderBufferIntuition) : boolean;
begin
	Result := true;

	//BufferBitmapsFree(ARenderBufferIntuition, AScreen^.Width, AScreen.Height, AScreen^.dri_depth);
	FreeVec(ARenderBufferIntuition);
end;

end.
