unit fSeadragon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls, JPEG,
  GR32, GR32_Backends;

type
  TfrmSeadragon = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    fTile: TBitmap;
    fTileJPEG: TJPEGImage;
    fMaxLevel: Integer;
    fZoomLevels: array of TBitmap32;

    procedure CalcAndFillZoomLevels(const aFilename: String);
    function CalcMaxLevel(aWidth, aHeight: Integer): Integer;

    procedure SeadragonHandler(aURL: String; var aMIMEType: String; const aPostMIMEType: String; const aPostData: array of byte; aMemoryStream: TCustomMemoryStream); // TProtocolCallback
    procedure HandleTile(aPartialURL: String; aMemoryStream: TCustomMemoryStream);
  public
    { Public declarations }
  end;

var
  frmSeadragon: TfrmSeadragon;

implementation

uses
   Math, GR32_Resamplers,
   uAsyncPlugProto, uStaticHtml;
const
   TILE_SIZE = 100;

{$R *.dfm}

function TfrmSeadragon.CalcMaxLevel(aWidth, aHeight: Integer): Integer;
var
   iDimension: Integer;
begin
   iDimension := Math.Max(aWidth, aHeight);
   Result := Math.Ceil(Ln(iDimension) / Ln(2));
end;

procedure TfrmSeadragon.CalcAndFillZoomLevels(const aFilename: String);
var
   bmp32: TBitmap32;
   nextW, nextH: Double;
   i: Integer;
begin
   bmp32 := TBitmap32.Create; // Free'd in FormDestroy

   bmp32.LoadFromFile(aFilename);
   fMaxLevel := CalcMaxLevel(bmp32.Width, bmp32.Height);

   SetLength(fZoomLevels, fMaxLevel);

   TDraftResampler.Create(bmp32);
   fZoomLevels[High(fZoomLevels)] := bmp32;

   nextW := bmp32.Width;
   nextH := bmp32.Height;
   for i := High(fZoomLevels)-1 downto Low(fZoomLevels) do
   begin
      nextW := nextW / 2;
      nextH := nextH / 2;
      fZoomLevels[i] := TBitmap32.Create;
      fZoomLevels[i].SetSize(Floor(nextW), Floor(nextH));
      bmp32.DrawTo(fZoomLevels[i], fZoomLevels[i].BoundsRect);
   end;
end;

procedure TfrmSeadragon.FormCreate(Sender: TObject);
begin
   fTile := TBitmap.Create;
   fTileJPEG := TJPEGImage.Create;

   CalcAndFillZoomLevels('earth-map-huge.jpg');

   NewHttpProtocolHandler('local', SeadragonHandler);
   WebBrowser1.Navigate('local://app');
end;

procedure TfrmSeadragon.FormDestroy(Sender: TObject);
var
   i: Integer;
begin
   for i := Low(fZoomLevels) to High(fZoomLevels) do
      fZoomLevels[i].Free;
   SetLength(fZoomLevels, 0);
   ReportMemoryLeaksOnShutdown := true;

   fTileJPEG.Free;
   fTile.Free;
end;

procedure TfrmSeadragon.HandleTile(aPartialURL: String; aMemoryStream: TCustomMemoryStream);
var
   idx, level, x, y: Integer;
   newWidth, newHeight: Integer;
begin
   idx := Pos('/', aPartialURL); level := StrToInt(Copy(aPartialURL, 1, idx-1)); Delete(aPartialURL, 1, idx);
   idx := Pos('/', aPartialURL); x     := StrToInt(Copy(aPartialURL, 1, idx-1)); Delete(aPartialURL, 1, idx);
                                 y     := StrToInt(     aPartialURL);

   fTile.Height := TILE_SIZE;
   fTile.Width := TILE_SIZE;
   fTile.Canvas.FillRect(Rect(0, 0, fTile.Width, fTile.Height));

   fZoomLevels[level-1].DrawTo(fTile.Canvas.Handle,
      Rect(0, 0, TILE_SIZE, TILE_SIZE),
      Rect(x * TILE_SIZE, y * TILE_SIZE, (x * TILE_SIZE) + TILE_SIZE, (y * TILE_SIZE) + TILE_SIZE)
   );

   if ((x + 1) * TILE_SIZE) > fZoomLevels[level-1].Width then
   begin
      newWidth := Floor(fZoomLevels[level-1].Width - (x * TILE_SIZE));
      if newWidth < 1 then
         fTile.Width := 1
      else
         fTile.Width := newWidth;
   end;
   if ((y + 1) * TILE_SIZE) > fZoomLevels[level-1].Height then
   begin
      newHeight := Floor(fZoomLevels[level-1].Height - (y * TILE_SIZE));
      if newHeight < 1 then
         fTile.Height := 1
      else
         fTile.Height := newHeight;
   end;

   fTileJPEG.Assign(fTile);
   fTileJPEG.Compress;
   fTileJPEG.SaveToStream(aMemoryStream);
end;

procedure TfrmSeadragon.SeadragonHandler(aURL: String; var aMIMEType: String; const aPostMIMEType: String; const aPostData: array of byte;
  aMemoryStream: TCustomMemoryStream);
   procedure WriteOutString(const aStr: String);
   var
      utf8Out: UTF8String;
   begin
      utf8Out := UTF8Encode(aStr);
      aMemoryStream.WriteBuffer(Pointer(utf8Out)^, Length(utf8Out) * SizeOf(AnsiChar));
   end;
   procedure WriteOutFile(const aFilename: String);
   var
      ms: TMemoryStream;
   begin
      ms := TMemoryStream.Create;
      try
         ms.LoadFromFile(aFilename);
         ms.SaveToStream(aMemoryStream);
      finally
         ms.Free;
      end;
   end;
begin
   if SameText(aURL, '//app/') then
   begin
      WriteOutString(
         StringReplace(uStaticHtml.MAIN_PAGE, '%W_H%', Format('%d, %d',[fZoomLevels[fMaxlevel-1].Width, fZoomLevels[fMaxlevel-1].Height]), [])
      )
   end
   else if SameText(aURL, '//app/seadragon-min.js') then
   begin
      aMIMEType := 'application/javascript';
      WriteOutFile('seadragon-min.js')
   end
   else if SameText(Copy(aURL,1,Length('//app/imgs/')), '//app/imgs/') then
   begin
      // these are the images for Seadragon the "buttons" "+" "-" "home" "full screen"
      aMIMEType := 'application/png';
      WriteOutFile(Copy(aURL, 7));
   end
   else if SameText(Copy(aURL,1,Length('//app/getTile/')), '//app/getTile/') then
   begin
      aMIMEType := 'image/jpeg';
      HandleTile(Copy(aURL, Length('//app/getTile/')+1), aMemoryStream);
   end
   else
   begin
      WriteOutString('URL: ' + aURL);
   end;
end;

end.
