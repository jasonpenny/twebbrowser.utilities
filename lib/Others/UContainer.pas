{
  This demo application accompanies the article
  "How to customise the TWebBrowser user interface" on
  http://www.delphidabbler.com/articles?article=18.

  The demo implements the 2nd phase of the sample application presented in the
  article. It mimics a dialog box that uses the web browser control. The browser
  takes on the appearance of the dialog box.

  This code is copyright (c) P D Johnson (www.delphidabbler.com), 2004-2006.

  v1.0 of 2006/02/06 - original version
}


{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}


unit UContainer;

interface

uses
  Windows, ActiveX, ShDocVw,
  UNulContainer, IntfDocHostUIHandler;

type

  TWBContainer = class(TNulWBContainer, IDocHostUIHandler, IOleClientSite)
  private
    fUseCustomCtxMenu: Boolean;
    fShowScrollBars: Boolean;
    fShow3DBorder: Boolean;
    fAllowTextSelection: Boolean;
    fCSS: string;
  protected
    { Re-implemented IDocHostUIHandler methods }
    function ShowContextMenu(
      const dwID: DWORD;
      const ppt: PPOINT;
      const pcmdtReserved: IUnknown;
      const pdispReserved: IDispatch): HResult; stdcall;
    function GetHostInfo(
      var pInfo: TDocHostUIInfo): HResult; stdcall;
  public
    constructor Create(const HostedBrowser: TWebBrowser);
    property UseCustomCtxMenu: Boolean
      read fUseCustomCtxMenu write fUseCustomCtxMenu default False;
    property Show3DBorder: Boolean
      read fShow3DBorder write fShow3DBorder default True;
    property ShowScrollBars: Boolean
      read fShowScrollBars write fShowScrollBars default True;
    property AllowTextSelection: Boolean
      read fAllowTextSelection write fAllowTextSelection default True;
    property CSS: string
      read fCSS write fCSS;
  end;

implementation

uses
  SysUtils, Themes;

{
  TaskAllocWideString is taken from the CodeSnip database at
  http://www.delphidabbler.com/codesnip
}

function TaskAllocWideString(const S: string): PWChar;
var
  StrLen: Integer;  // length of string in bytes
begin
  // Store length of string in characters, allowing for terminal #0
  StrLen := Length(S) + 1;
  // Allocate buffer for wide string using task allocator
  Result := CoTaskMemAlloc(StrLen * SizeOf(WideChar));
  if Assigned(Result) then
    // Convert string to wide string and store in buffer
    StringToWideChar(S, Result, StrLen);
end;

{ TWBContainer }

constructor TWBContainer.Create(const HostedBrowser: TWebBrowser);
begin
  inherited;
  fUseCustomCtxMenu := False;
  fShowScrollBars := True;
  fShow3DBorder := True;
  fAllowTextSelection := True;
  fCSS := '';
end;

function TWBContainer.GetHostInfo(
  var pInfo: TDocHostUIInfo): HResult;
{These constants are defined in IntfUIHandlers
const
  DOCHOSTUIFLAG_SCROLL_NO = $00000008;
  DOCHOSTUIFLAG_NO3DBORDER = $00000004;
  DOCHOSTUIFLAG_DIALOG = $00000001;
  DOCHOSTUIFLAG_THEME = $00040000;
  DOCHOSTUIFLAG_NOTHEME = $00080000;
}
begin
  try
    // Clear structure and set size
    ZeroMemory(@pInfo, SizeOf(TDocHostUIInfo));
    pInfo.cbSize := SizeOf(TDocHostUIInfo);
    // Set scroll bar visibility
    if not fShowScrollBars then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_SCROLL_NO;
    // Set border visibility
    if not fShow3DBorder then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_NO3DBORDER;
    // Decide if text can be selected
    if not fAllowTextSelection then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_DIALOG;
    // Ensure browser uses XP themes if application is doing
    if ThemeServices.ThemesEnabled then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_THEME
    else if ThemeServices.ThemesAvailable then
      pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_NOTHEME;
    // Record default CSS as Unicode
    pInfo.pchHostCss := TaskAllocWideString(fCSS);
    if not Assigned(pInfo.pchHostCss) then
      raise Exception.Create('Task allocator can''t allocate CSS string');
    // Return S_OK to indicate we've made changes
    Result := S_OK;
  except
    // Return E_FAIL on error
    Result := E_FAIL;
  end;
end;

function TWBContainer.ShowContextMenu(
  const dwID: DWORD;
  const ppt: PPOINT;
  const pcmdtReserved: IInterface;
  const pdispReserved: IDispatch): HResult;
begin
  if fUseCustomCtxMenu then
  begin
    // tell IE we're handling the context menu
    Result := S_OK;
    if Assigned(HostedBrowser.PopupMenu) then
      // browser has a pop up menu so activate it
      HostedBrowser.PopupMenu.Popup(ppt.X, ppt.Y);
  end
  else
    // tell IE to use default action: display own menu
    Result := S_FALSE;
end;

end.
