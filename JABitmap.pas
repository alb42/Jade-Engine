unit JABitmap;
{$mode objfpc}{$H+}
{$i JA.inc}

interface

uses
   {Amiga} Exec, Intuition, AGraphics, layers, Utility,
   {JAE} JATypes, JAList;

type
   TJABitmap = record
     Width : SInt16;
     Height : SInt16;
     Depth : SInt16;
     Bitmap : pBitmap;
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
   end;
   PJABitmap = ^TJABitmap;

function JABitmapCreate(AWidth, AHeight, ADepth : SInt16; AColourMap : pColorMap) : PJABitmap;
function JABitmapDestroy(ABitmap : PJABitmap) : boolean;
function JABitmapBlit(ASourceBitmap, ADestinationBitmap : PJABitmap; ARect : TJRectSInt32) : boolean;

implementation

function JABitmapCreate(AWidth, AHeight, ADepth : SInt16; AColourMap : pColorMap) : PJABitmap;
var
   TextAttributes : TTextAttr;
   Font : PTextFont;
begin
   Result := PJABitmap(JAMemGet(SizeOf(TJABitmap)));

   with Result^ do
   begin
      Width := AWidth;
      Height := AHeight;
      Depth := ADepth;
      ColourMap := AColourMap;

      {TODO : currently gets chip memory for standard graphics, probably different for picasso/RTG}
      {allocate memory for the bitmap}
      Bitmap := AllocBitMap(AWidth, AHeight, ADepth, BMF_CLEAR or BMF_INTERLEAVED, nil);
      //Result^.Bitmap := PBitMap(AllocVec(SizeOf(TBitMap), MEMF_CHIP or MEMF_CLEAR));
	   {error check and exit}
	   if (Bitmap=nil) then
      begin
         JAMemFree(Result,SizeOf(TJABitmap));
         exit(nil);
      end;
      //
      {Setup Layer Clipping Region}
      Result^.LayerInfo := NewLayerInfo();
      Result^.Layer := CreateUpfrontLayer(Result^.LayerInfo, Result^.Bitmap, 0, 0, Result^.Width-1, Result^.Height-1, LAYERSIMPLE, nil);
      Result^.RasterPort := Result^.Layer^.RP;
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

      TmpRasBufferSize := AWidth * AHeight;
      //TmpRasBufferSize := 1024*4;
      TmpRasBuffer := AllocVec(TmpRasBufferSize, MEMF_CHIP or MEMF_CLEAR);
      InitTmpRas(@TmpRas, TmpRasBuffer, TmpRasBufferSize);
      RasterPort^.TmpRas := @TmpRas;

      {The size of the region pointed to by buffer  should be five (5) times as
      large as maxvectors. This size is in bytes.}
      AreaInfoVerticesCount := 12800;
      AreaInfoVertices := AllocVec(AreaInfoVerticesCount*5, {MEMF_CHIP or }MEMF_CLEAR);
      InitArea(@AreaInfo, AreaInfoVertices, AreaInfoVerticesCount);
      RasterPort^.AreaInfo := @AreaInfo;
   end;
end;

function JABitmapDestroy(ABitmap : PJABitmap) : boolean;
begin
   if (ABitmap=nil) then exit(false);
   with ABitmap^ do
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
      if (ABitmap^.Bitmap<>nil) then
      begin
         {Note that the AutoDoc FreeBitMap() recommends calling WaitBlit() before releasing
         the Bitmap to be sure that nothing is being written in it.}
         WaitBlit();
         FreeBitMap(ABitmap^.Bitmap);
      end;
   end;
   JAMemFree(ABitmap, SizeOf(TJABitmap));
end;

function JABitmapBlit(ASourceBitmap, ADestinationBitmap : PJABitmap; ARect : TJRectSInt32) : boolean;
begin

end;

end.

