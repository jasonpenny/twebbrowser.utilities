unit uAsyncPlugProto;

interface

{.$DEFINE TRACE_MSGS}

uses
   SysUtils, Windows, Classes, ComObj, UrlMon;

const
  Class_StdURLProtocol:          TGUID = '{79eac9e1-baf9-11ce-8c82-00aa004ba90b}';
  Class_HttpProtocol:            TGUID = '{79eac9e2-baf9-11ce-8c82-00aa004ba90b}';
  Class_FtpProtocol:             TGUID = '{79eac9e3-baf9-11ce-8c82-00aa004ba90b}';
  Class_GopherProtocol:          TGUID = '{79eac9e4-baf9-11ce-8c82-00aa004ba90b}';
  Class_HttpSProtocol:           TGUID = '{79eac9e5-baf9-11ce-8c82-00aa004ba90b}';
  Class_MKProtocol:              TGUID = '{79eac9e6-baf9-11ce-8c82-00aa004ba90b}';
  Class_FileProtocol:            TGUID = '{79eac9e7-baf9-11ce-8c82-00aa004ba90b}';

type
  TProtocolCallback = procedure (aURL: String; var aMIMEType: String; const aPostMIMEType: String; const aPostData: array of byte; aMemoryStream: TCustomMemoryStream) of object;

  TAsyncPlugProto = class(TComObject, IInternetProtocol)
  private
{$IFDEF TRACE_MSGS}
    fNumber: Integer;
{$ENDIF}
    procedure AddTrace(const aMsg: String);
  protected
    FProtSink: IInternetProtocolSink;
    FURL: String;
    FMemStrm : TMemoryStream;

    function ParseURL(const aURL: String): Boolean;
  public
    procedure Initialize; override;
    destructor Destroy; override;

    { IInternetProtocolRoot }
    function Start(szUrl: LPCWSTR; OIProtSink: IInternetProtocolSink; OIBindInfo: IInternetBindInfo; grfPI, dwReserved: DWORD): HResult; stdcall;
    function Continue(const ProtocolData: TProtocolData): HResult; stdcall;
    function Abort(hrReason: HResult; dwOptions: DWORD): HResult; stdcall;
    function Terminate(dwOptions: DWORD) : HResult; stdcall;
    function Suspend: HResult; stdcall;
    function Resume: HResult; stdcall;

    { IInternetProtocol }
    function Read(pv: Pointer; cb: ULONG; out cbRead: ULONG): HResult; stdcall;
    function Seek(dlibMove: LARGE_INTEGER; dwOrigin: DWORD; out libNewPosition: ULARGE_INTEGER): HResult; stdcall;
    function LockRequest(dwOptions: DWORD): HResult; stdcall;
    function UnlockRequest: HResult; stdcall;
  end;

const
  Class_AsyncPlugProto_Protocol: TGUID = '{215DD8F0-1D97-43BA-832A-23C74E48E049}';

procedure NewProtocolHandler(const aProtocolName: String; aProtocolCallback: TProtocolCallback; aProtocollType: TGUID);
procedure NewHttpProtocolHandler(const aProtocolName: String; aProtocolCallback: TProtocolCallback);
procedure EndProtocolHandler;

implementation

uses
   ComServ, ActiveX;

var
{$IFDEF TRACE_MSGS}
    gNumber: Integer = 0;
{$ENDIF}
  Factory: IClassFactory;
  InternetSession: IInternetSession;
  MyProtocol: IInternetProtocol;
  _protocol: String = '';
  _protocolCallback: TProtocolCallback;

procedure NewProtocolHandler(const aProtocolName: String; aProtocolCallback: TProtocolCallback; aProtocollType: TGUID);
begin
  if _protocol <> '' then
    raise Exception.Create('Currently only supports a single asynchronous pluggable protocol');

  _protocol := aProtocolName;
  _protocolCallback := aProtocolCallback;

  CoGetClassObject(Class_AsyncPlugProto_Protocol, CLSCTX_SERVER, nil, IClassFactory, Factory);
  CoInternetGetSession(0, InternetSession, 0);
  InternetSession.RegisterNameSpace(Factory, Class_AsyncPlugProto_Protocol, PChar(_protocol), 0, nil, 0);

  CoCreateInstance(aProtocollType, nil {was IUnknown(Self)}, CLSCTX_INPROC_SERVER, IUnknown, MyProtocol);
end;

procedure NewHttpProtocolHandler(const aProtocolName: String; aProtocolCallback: TProtocolCallback);
begin
  NewProtocolHandler(aProtocolName, aProtocolCallback, Class_HttpProtocol);
end;

procedure EndProtocolHandler;
begin
  if Assigned(InternetSession) then
    InternetSession.UnregisterNameSpace(Factory, PChar(_protocol));

  MyProtocol := nil;
  InternetSession := nil;
  Factory := nil;

  _protocolCallback := nil;
  _protocol := '';
end;

{ TAsyncPlugProto }

function TAsyncPlugProto.Abort(hrReason: HResult; dwOptions: DWORD): HResult;
begin
  AddTrace('IN IInternetProtocolRoot::Abort');
  // hrReason is reported by the pluggable protocol if it successfully canceled the binding
  if Assigned(FProtSink) then
    FProtSink.ReportResult(hrReason, 0, nil);
  Result := S_OK;
end;

function TAsyncPlugProto.Continue(const ProtocolData: TProtocolData): HResult;
begin
  AddTrace('IN IInternetProtocolRoot::Continue');
  Result := E_FAIL;
end;

destructor TAsyncPlugProto.Destroy;
begin
  FMemStrm.Free;
  FProtSink := nil;
  AddTrace('TAsyncPlugProto::Destroy');
  inherited;
end;

procedure TAsyncPlugProto.Initialize;
begin
  inherited;
{$IFDEF TRACE_MSGS}
  Inc(gNumber);
  fNumber := gNumber;
{$ENDIF}

  AddTrace('TAsyncPlugProto::Initialize');
  FMemStrm := TMemoryStream.Create;
end;

function TAsyncPlugProto.LockRequest(dwOptions: DWORD): HResult;
begin
  AddTrace('IN IInternetProtocol::LockRequest');
  Result := S_OK;
end;

function TAsyncPlugProto.ParseURL(const aURL: String): Boolean;
begin
  AddTrace('IN ParseURL');

  if (Pos(':', aURL) = 0) then
  begin
    Result := False;
    Exit;
  end;

  // strip off the protocol:
  FURL := Copy(aURL, Pos(':', aURL)+1);
  Result := True;
end;

function TAsyncPlugProto.Read(pv: Pointer; cb: ULONG; out cbRead: ULONG): HResult;
  function Min(const A, B: Integer): Integer;
  begin
    if A < B then Result := A
    else          Result := B;
  end;
begin
  AddTrace('IN Read - cb = ' + IntToStr(cb));

  Result := S_OK;

  // calcualte the ammount of data to be read
  cbRead := Min(FMemStrm.Size-FMemStrm.Position, cb);

  // read in the data
  if (FMemStrm.Position < FMemStrm.Size) then
    FMemStrm.ReadBuffer(pv^, cbRead);

  // have we finished?
  if (FMemStrm.Position = FMemStrm.Size) then
  begin
    if Assigned(FProtSink) then
      FProtSink.ReportResult(S_OK, 0, nil);
    Result := S_FALSE;
  end;

  AddTrace(Format('OUT Read - pcbRead = %d Result = %d FMemStrm.Position = %d', [cbRead, Result, FMemStrm.Position]));
end;

function TAsyncPlugProto.Resume: HResult;
begin
  AddTrace('IN IInternetProtocolRoot::Resume');
  Result := E_NOTIMPL;
end;

function TAsyncPlugProto.Seek(dlibMove: LARGE_INTEGER; dwOrigin: DWORD; out libNewPosition: ULARGE_INTEGER): HResult;
begin
  AddTrace('IN IInternetProtocol::Seek');
  Result := E_NOTIMPL;
end;

function TAsyncPlugProto.Start(szUrl: LPCWSTR; OIProtSink: IInternetProtocolSink; OIBindInfo: IInternetBindInfo; grfPI, dwReserved: DWORD): HResult;
var
  LBindInfo: TBindInfo;
  BINDF: DWORD;
  mimeType, postMimeType: String;
  cPostData: UINT;
  pData: Pointer;
  hr: HRESULT;
  pszMIMEType: POleStrArray;
  dwSize: ULONG;
  postData: array of byte;
begin
  AddTrace('IN IInternetProtocolRoot::Start - szURL = ' + szURL + ' grfPI = ' + IntToStr(grfPI));

  FProtSink := OIProtSink;

  ParseURL(szURL);

  // get the bind information
  LBindInfo.cbSize := SizeOf(LBindInfo);
  OIBindInfo.GetBindInfo(BINDF, LBindInfo);

  postMimeType := '';
  if LBindInfo.dwBindVerb = BINDVERB_POST then
  begin
    // translated from http://support.microsoft.com/default.aspx?scid=kb;en-us;280522
    if LBindInfo.stgmedData.tymed = TYMED_HGLOBAL then
    begin
      cPostData := LBindInfo.cbstgmedData;
      if cPostData <> 0 then
      begin
        pData := GlobalLock(LBindInfo.stgmedData.hGlobal);
        if pData <> nil then
        begin
          // Allocate space to store the POST data if required.
          // For instance, a member variable, m_postData,
          // declared as "BYTE *m_postData;", could be used
          // as below:
          // 	m_postData = new BYTE[cPostData];
          // 	memcpy(m_postData, pData, cPostData);

          SetLength(postData, cPostData+1);
          ZeroMemory(postData, cPostData+1);
          CopyMemory(postData, pData, cPostData);

          // After checking the data, unlock buffer.
          GlobalUnlock(LBindInfo.stgmedData.hGlobal);

          pszMIMEType := nil;
          // Retrieve MIME type of the post data.
          hr := OIBindInfo.GetBindString(BINDSTRING_POST_DATA_MIME, @pszMIMEType, 1, dwSize);

          if hr = S_OK then
          begin
            // pszMIMEType now contains the MIME type of the post data.
            // This would typically be "application/x-www-form-urlencoded"
            // for a POST. In general, it could be any (standard or
            // otherwise) MIME type. Many of the standard MIME type strings
            // are #defined in <URLMon.h>. For instance, CFSTR_MIME_TEXT
            // is L"text/plain".

            // Store the MIME type in a member variable here, if required.

            // Finally, free pszMIMEType via CoTaskMemFree.
            if pszMIMEType <> nil then
            begin
              postMimeType := PWideChar(pszMIMEType);

              CoTaskMemFree(pszMIMEType);
              pszMIMEType := nil;
            end;
          end
          else
          begin
             // Assume "application/x-www-form-urlencoded".
             postMimeType := 'application/x-www-form-urlencoded';
          end;
        end;
      end;
    end;
  end;

  FMemStrm.Clear;

  /// make callback.
  mimeType := 'text/html';
  _protocolCallback(FURL, mimeType, postMimeType, postData, FMemStrm);

  FMemStrm.Position := 0;

  FProtSink.ReportProgress(BINDSTATUS_FINDINGRESOURCE,            '');
  FProtSink.ReportProgress(BINDSTATUS_CONNECTING,                 '');
  FProtSink.ReportProgress(BINDSTATUS_SENDINGREQUEST,             '');
  FProtSink.ReportProgress(BINDSTATUS_VERIFIEDMIMETYPEAVAILABLE,  PChar(mimeType));

  AddTrace('IN IInternetProtocolSink::ReportData - ulProgress = ' + IntToStr(FMemStrm.Size));

  FProtSink.ReportData(UrlMon.BSCF_FIRSTDATANOTIFICATION or UrlMon.BSCF_LASTDATANOTIFICATION or BSCF_DATAFULLYAVAILABLE, FMemStrm.Size, FMemStrm.Size);

  Result := S_OK;
end;

function TAsyncPlugProto.Suspend: HResult;
begin
  AddTrace('IN IInternetProtocolRoot::Suspend');
  Result := E_NOTIMPL;
end;

function TAsyncPlugProto.Terminate(dwOptions: DWORD): HResult;
begin
  AddTrace('IN IInternetProtocolRoot::Terminate');
  FProtSink := nil;
  Result := S_OK;
end;

procedure TAsyncPlugProto.AddTrace(const aMsg: String);
begin
{$IFDEF TRACE_MSGS}
   OutputDebugString(PChar(Format('%.3d: %s', [fNumber,aMsg])));
{$ENDIF}
end;

function TAsyncPlugProto.UnlockRequest: HResult;
begin
  AddTrace('IN IInternetProtocol::UnlockRequest');
  Result := S_OK;
end;

initialization
  TComObjectFactory.Create(ComServer, TAsyncPlugProto, Class_AsyncPlugProto_Protocol, 'Protocol', '', ciMultiInstance, tmApartment);
finalization
  EndProtocolHandler;

end.
