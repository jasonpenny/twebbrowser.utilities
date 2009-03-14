unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls,
  ComCtrls, IdTCPConnection, IdTCPClient, IdHTTP, IdURI, ExtCtrls, IdBaseComponent, IdComponent;

type
  TfrmMain = class(TForm)
    WebBrowser1: TWebBrowser;
    btnAddMarker: TButton;
    StatusBar1: TStatusBar;
    btnGeocode: TButton;
    IdHTTP1: TIdHTTP;
    leLat: TLabeledEdit;
    leLng: TLabeledEdit;
    mmGeocode: TMemo;
    btnCenterMap: TButton;
    rbAPI: TRadioButton;
    rbCheat: TRadioButton;
    btnDirections: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnAddMarkerClick(Sender: TObject);
    procedure btnCenterMapClick(Sender: TObject);
    procedure btnGeocodeClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnDirectionsClick(Sender: TObject);
  private
    { Private declarations }
    procedure geocode(const s: String; out lat, lng: String);
    procedure geocodeCheat(const s: String; out lat, lng: String);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
   MSHTML, StrUtils, ActiveX;

const
   GOOGLE_MAPS_API_KEY =
      '';

{$R *.dfm}

const
   rootDoc: String =
      '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'#13#10 +
      '<html xmlns="http://www.w3.org/1999/xhtml">'#13#10 +
      '  <head>'#13#10 +
      '    <meta http-equiv="content-type" content="text/html"/>'#13#10 +
      '    <title>Google Maps JavaScript API Example</title>'#13#10 +
      '    <script src="http://maps.google.com/maps?file=api&amp;v=2" type="text/javascript"></script>'#13#10 +
      '    <script type="text/javascript">'#13#10 +
      ''#13#10 +
      '      var map;'#13#10 + // need this global so Delphi can access it. (at least for now.)
      '    //<![CDATA['#13#10 +
      ''#13#10 +
      '    function load() {'#13#10 +
      '      if (GBrowserIsCompatible()) {'#13#10 +
      '        map = new GMap2(document.getElementById("map"));'#13#10 +
      '        map.addControl(new GLargeMapControl());'#13#10 +
      '        map.addControl(new GMapTypeControl());'#13#10 +
      '        map.addControl(new GScaleControl());'#13#10 +
      '        map.setCenter(new GLatLng(37.05173494, -122.03160858), 13);'#13#10 +
      '      }'#13#10 +
      '    }'#13#10 +
      ''#13#10 +
      '    //]]>'#13#10 +
      '    </script>'#13#10 +
      '  </head>'#13#10 +
      ''#13#10 +
      '  <body onload="load()" onunload="GUnload()" style="margin:0">'#13#10 +
      '    <div id="map" style="width: 100%; height: 300px"></div>'#13#10 +
      '  </body>'#13#10 +
      '</html>';

   function doURLEncode(const S: string; const InQueryString: Boolean = true): string;
   var
     Idx: Integer; // loops thru characters in string
   begin
     Result := '';
     for Idx := 1 to Length(S) do
     begin
       case S[Idx] of
         'A'..'Z', 'a'..'z', '0'..'9', '-', '_', '.', ',':
           Result := Result + S[Idx];
         ' ':
           if InQueryString then
             Result := Result + '+'
           else
             Result := Result + '%20';
         else
           Result := Result + '%' + SysUtils.IntToHex(Ord(S[Idx]), 2);
       end;
     end;
   end;

   procedure ExecJS(const script: String);
   var
      Doc2: IHTMLDocument2;
      Win2: IHTMLWindow2;
   begin
      Doc2 := frmMain.WebBrowser1.Document as IHTMLDocument2;
      Win2 := Doc2.parentWindow;
      Win2.execScript(script, 'JavaScript');
   end;

procedure TfrmMain.FormCreate(Sender: TObject);
   procedure WBLoadHTML(WebBrowser: TWebBrowser; HTMLCode: string) ;
   var
      sl: TStringList;
      ms: TMemoryStream;
   begin
      WebBrowser.Navigate('about:blank') ;
      // pretend we're at localhost, so google doesn't complain about the API key
      (WebBrowser.Document as IHTMLDocument2).URL := 'http://localhost/';

      while WebBrowser.ReadyState < READYSTATE_INTERACTIVE do
         Forms.Application.ProcessMessages;

      if Assigned(WebBrowser.Document) then
      begin
         sl := TStringList.Create;
         try
            ms := TMemoryStream.Create;
            try
               sl.Text := HTMLCode;
               sl.SaveToStream(ms);
               ms.Seek(0, 0);
               (WebBrowser.Document as IPersistStreamInit).Load(TStreamAdapter.Create(ms));
            finally
               ms.Free;
            end;
         finally
            sl.Free;
         end;
      end;
   end;
begin
   WBLoadHTML(WebBrowser1, rootDoc);
   FormResize(Sender);
end;

procedure TfrmMain.FormResize(Sender: TObject);
var
   newMapHeight: Integer;
   script: String;
begin
   if Visible then
   begin
      while WebBrowser1.ReadyState < READYSTATE_COMPLETE do
         Forms.Application.ProcessMessages;
   end;

   newMapHeight := WebBrowser1.ClientHeight - (4 * GetSystemMetrics(SM_CYBORDER));

   script :=
      'if (document) { ' +
      '  if (document.body) { ' +
      '    var m = document.getElementById("map"); ' +
      '    if (typeof(m) != "undefined") { ' +
      '      m.style.height = ' + IntToStr(newMapHeight) + '; ' +
      '    } ' +
      '  } ' +
      '} ';
   (WebBrowser1.Document as IHTMLDocument2).
      parentWindow.execScript(
         script,
         'JavaScript'
      );
end;

procedure TfrmMain.geocode(const s: String; out lat, lng: String);
var
   address, resp: String;
   p1, p2: Integer;
begin
   address := StringReplace(StringReplace(Trim(s), #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll]);

   address := doURLEncode(address);
   address := 'http://maps.google.com/maps/geo?q=' + address;
   address := TIDUri.UrlEncode(address + '&output=csv&key=' + GOOGLE_MAPS_API_KEY);
   // if you want more info, try output=JSON or output=xml, etc.

   resp := IdHTTP1.Get(address);

   // resp = StatusCode,Accuracy,Lat,Lng
   p1 := Pos(',', resp);
   p1 := PosEx(',', resp, p1+1);
   p2 := PosEx(',', resp, p1+1);

   // p1 is at the comma before Lat, p2 is at the comma before Lng
   lat := Copy(resp, p1+1, p2 - p1 - 1);
   lng := Copy(resp, p2+1, Length(resp) - p2);

end;

procedure TfrmMain.geocodeCheat(const s: String; out lat, lng: String);
const
   VIEWPORT: String = 'viewport:{center:{';
var
   address, strResponse, latlng, st: String;
   pStart, pEnd: Integer;
   ts: TStringList;
begin
   // Cheat at geocoding, retrieve the page that google responds with, as if we entered the text in the search box

   /// response (currently) contains this sort of thing:
   ///   viewport:{center:{lat:40.886159999999997,lng:-73.366669999999999}

   address := StringReplace(StringReplace(Trim(s), #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll]);

   address := doURLEncode(address);
   address := 'http://maps.google.com/maps?q=' + address;
   address := TIDUri.UrlEncode(address + '&output=csv'); // I don't know exactly why the &output=csv helps
                                                         // it was from a previous URL,
                                                         // but without it, I get error 302 - Found.
                                                         // which is rather odd.
   strResponse := IdHTTP1.Get(address);

   pStart := Pos(VIEWPORT, strResponse);
   pEnd := PosEx('}', strResponse, pStart + 1);
   if (pStart < 1) or (pEnd < 1) then
      raise Exception.Create('I think google changed the html, this is a problem.');

   pStart := pStart + Length(VIEWPORT);
   latlng := Copy(strResponse, pStart, pEnd - pStart);

   ts := TStringList.Create;
   try
      ts.LineBreak := ',';
      ts.Text := latlng;

      for st in ts do
      begin
         if Pos('lat:', st) = 1 then
         begin
            lat := Copy(st, 5, Length(st) - 5);
         end
         else if Pos('lng:', st) = 1 then
         begin
            lng := Copy(st, 5, Length(st) - 5);
         end;
      end;
   finally
      ts.Free;
   end;
end;

procedure TfrmMain.btnAddMarkerClick(Sender: TObject);
var
   Doc2: IHTMLDocument2;
   Win2: IHTMLWindow2;
   latlng: String;
begin
   Doc2 := WebBrowser1.Document as IHTMLDocument2;
   Win2 := Doc2.parentWindow;

   latlng := '"' + leLat.Text + '", "' + leLng.Text + '"';

   // no callback or anything, just a visual representation for proof of concept.
   Win2.execScript('map.addOverlay( new GMarker(new GLatLng(' + latlng + ')) );', 'JavaScript');
end;

procedure TfrmMain.btnCenterMapClick(Sender: TObject);
var
   Doc2: IHTMLDocument2;
   Win2: IHTMLWindow2;
   latlng: String;
begin
   Doc2 := WebBrowser1.Document as IHTMLDocument2;
   Win2 := Doc2.parentWindow;

   latlng := '"' + leLat.Text + '", "' + leLng.Text + '"';

   Win2.execScript('map.panTo(new GLatLng(' + latlng + '));', 'JavaScript');
end;

procedure TfrmMain.btnDirectionsClick(Sender: TObject);
begin
   ExecJS('var dirn = new GDirections(map);');
   ExecJS('dirn.load("from: 500 Memorial Drive, Cambridge, MA to: 4 Yawkey Way, Boston, MA 02215 (Fenway Park)");');
end;

procedure TfrmMain.btnGeocodeClick(Sender: TObject);
var
   latitude, longitude: String;
begin
   if rbAPI.Checked then
      geocode(mmGeocode.Lines.Text, latitude, longitude)
   else if rbCheat.Checked then
      geocodeCheat(mmGeocode.Lines.Text, latitude, longitude);

   leLat.Text := latitude;
   leLng.Text := longitude;
end;

end.
