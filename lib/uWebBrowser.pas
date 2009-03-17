unit uWebBrowser;

interface

uses
   SysUtils, Forms, Graphics, Windows, Classes, ShDocVw, MSHTML, ActiveX,
   IntfDocHostUIHandler, UContainer;

function doURLEncode(const S: string; const InQueryString: Boolean = true): string;
function ColorToHTML(const Color: TColor): string;

type
  TOnGetExternalProc = function(out ppDispatch: IDispatch): HResult of object; stdcall;

{$M+}
  TWBWrapper = class(TWBContainer, IDocHostUIHandler, IOleClientSite)
  private
    fOnGetExternal: TOnGetExternalProc;
  protected
    function GetExternal(out ppDispatch: IDispatch): HResult; stdcall;
  public
    procedure ExecJS(const javascript: String);
    procedure FocusWebBrowser(WB: TWebBrowser);
    procedure LoadHTML(const aHTMLCode: String; const aSetLocationAsLocalhost: Boolean = false);
  published
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

procedure TWBWrapper.ExecJS(const javascript: String);
var
   aHTMLDocument2: IHTMLDocument2;
begin
   if Supports(HostedBrowser.Document, IHTMLDocument2, aHTMLDocument2) then
      aHTMLDocument2.parentWindow.execScript(javascript, 'JavaScript');
end;

procedure TWBWrapper.FocusWebBrowser(WB: TWebBrowser);
var
   aHTMLDocument2: IHTMLDocument2;
begin
   if Supports(HostedBrowser.Document, IHTMLDocument2, aHTMLDocument2) then
      aHTMLDocument2.parentWindow.focus;
end;

function TWBWrapper.GetExternal(out ppDispatch: IDispatch): HResult;
begin
   ppDispatch := nil;
   Result := E_FAIL;

   if Assigned (fOnGetExternal) then
      Result := fOnGetExternal(ppDispatch);
end;

procedure TWBWrapper.LoadHTML(const aHTMLCode: String; const aSetLocationAsLocalhost: Boolean = false);
var
   aPersistStreamInit: IPersistStreamInit;
   sl: TStringList;
   ms: TMemoryStream;
begin
   HostedBrowser.Navigate('about:blank');

   // pretend we're at localhost, so google doesn't complain about the API key
   if aSetLocationAsLocalhost then
      (HostedBrowser.Document as IHTMLDocument2).URL := 'http://localhost';

   while HostedBrowser.ReadyState < READYSTATE_INTERACTIVE do
      Forms.Application.ProcessMessages;

   sl := TStringList.Create;
   try
      ms := TMemoryStream.Create;
      try
         sl.Text := aHTMLCode;
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
