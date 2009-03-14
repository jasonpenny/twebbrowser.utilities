unit uWBGoogleMaps;

interface

uses
   SysUtils, Forms, Graphics, Windows, Classes, ShDocVw, MSHTML, ActiveX,
   IntfDocHostUIHandler, UContainer;

function doURLEncode(const S: string; const InQueryString: Boolean = true): string;
function ColorToHTML(const Color: TColor): string;

type
  TOnGetExternalProc = function(out ppDispatch: IDispatch): HResult of object; stdcall;

  TWBGoogleMaps = class(TWBContainer, IDocHostUIHandler, IOleClientSite)
  private
    fLoadedGoogleMaps: Boolean;
    fOnGetExternal: TOnGetExternalProc;
  protected
    function GetExternal(out ppDispatch: IDispatch): HResult; stdcall;
  public
    constructor Create(const HostedBrowser: TWebBrowser);

    procedure ExecJS(const javascript: String);
    procedure FocusWebBrowser(WB: TWebBrowser);
    procedure LoadHTML(const HTMLCode: String);
    procedure LoadDefaultGoogleMapsDocument;

    property LoadedGoogleMaps: Boolean read fLoadedGoogleMaps;
    property OnGetExternal: TOnGetExternalProc read fOnGetExternal write fOnGetExternal;
  end;

implementation

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

function ColorToHTML(const Color: TColor): string;
var
  ColorRGB: Integer;
begin
  ColorRGB := ColorToRGB(Color);
  Result := Format('#%0.2X%0.2X%0.2X', [GetRValue(ColorRGB), GetGValue(ColorRGB), GetBValue(ColorRGB)]);
end;

constructor TWBGoogleMaps.Create(const HostedBrowser: TWebBrowser);
begin
   inherited;

   // my preferred defaults: no border, no scroll bars
   Show3DBorder := False;
   ShowScrollBars := False;
end;


procedure TWBGoogleMaps.ExecJS(const javascript: String);
var
   aHTMLDocument2: IHTMLDocument2;
begin
   if Supports(HostedBrowser.Document, IHTMLDocument2, aHTMLDocument2) then
      aHTMLDocument2.parentWindow.execScript(javascript, 'JavaScript');
end;

procedure TWBGoogleMaps.FocusWebBrowser(WB: TWebBrowser);
var
   aHTMLDocument2: IHTMLDocument2;
begin
   if Supports(HostedBrowser.Document, IHTMLDocument2, aHTMLDocument2) then
      aHTMLDocument2.parentWindow.focus;
end;

function TWBGoogleMaps.GetExternal(out ppDispatch: IDispatch): HResult;
begin
   ppDispatch := nil;
   Result := E_FAIL;

   if Assigned (fOnGetExternal) then
      Result := fOnGetExternal(ppDispatch);
end;

procedure TWBGoogleMaps.LoadDefaultGoogleMapsDocument;
   const
      rootDoc: String =
         '<html>'#13#10 +
         '  <head>'#13#10 +
         '    <meta http-equiv="content-type" content="text/html"/>'#13#10 +
         '    <title>Google Maps JavaScript API Example</title>'#13#10 +
         '    <script src="http://maps.google.com/maps?file=api&amp;v=2" type="text/javascript"></script>'#13#10 +
         '    <script type="text/javascript">'#13#10 +
         ''#13#10 +
         '      var map;'#13#10 +
         '    //<![CDATA['#13#10 +
         ''#13#10 +
         '    function load() {'#13#10 +
         '      if (GBrowserIsCompatible()) {'#13#10 +
         '        map = new GMap2(document.getElementById("map"));'#13#10 +
         '        map.addControl(new GLargeMapControl());'#13#10 +
         '        map.addControl(new GMapTypeControl());'#13#10 +
         '        map.addControl(new GScaleControl());'#13#10 +
         '        map.enableScrollWheelZoom();'#13#10 +
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
begin
   LoadHTML(rootDoc);
   fLoadedGoogleMaps := true;
end;

procedure TWBGoogleMaps.LoadHTML(const HTMLCode: String);
var
   aPersistStreamInit: IPersistStreamInit;
   sl: TStringList;
   ms: TMemoryStream;
begin
   HostedBrowser.Navigate('about:blank');

   // pretend we're at localhost, so google doesn't complain about the API key
   (HostedBrowser.Document as IHTMLDocument2).URL := 'http://localhost';

   while HostedBrowser.ReadyState < READYSTATE_INTERACTIVE do
      Forms.Application.ProcessMessages;

   sl := TStringList.Create;
   try
      ms := TMemoryStream.Create;
      try
         sl.Text := HTMLCode;
         sl.SaveToStream(ms);
         ms.Seek(0, 0);

         if Supports(HostedBrowser.Document, IPersistStreamInit, aPersistStreamInit) then
         begin
            if Succeeded(aPersistStreamInit.InitNew) then           /// without calling InitNew, I was getting intermittent error windows
               aPersistStreamInit.Load(TStreamAdapter.Create(ms));  ///   popping up, complaining something about Objects not existing in
         end;                                                       ///   for some windows dns error file
      finally
         ms.Free;
      end;
   finally
      sl.Free;
   end;
end;

end.
