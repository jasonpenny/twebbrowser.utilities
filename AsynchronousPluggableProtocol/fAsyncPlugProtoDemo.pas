unit fAsyncPlugProtoDemo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, StdCtrls;

type
  TfrmMain = class(TForm)
    WebBrowser1: TWebBrowser;
    Button1: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    procedure MyProtocolHandler(aURL: String; var aMIMEType: String; const aPostMIMEType: String; const aPostData: array of byte; aMemoryStream: TCustomMemoryStream); // TProtocolCallback
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
   uAsyncPlugProto;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
   NewHttpProtocolHandler('myhttp', MyProtocolHandler);
end;

procedure TfrmMain.Button3Click(Sender: TObject);
begin
   WebBrowser1.Navigate('myhttp://home');
end;

procedure TfrmMain.MyProtocolHandler(aURL: String; var aMIMEType: String; const aPostMIMEType: String; const aPostData: array of byte; aMemoryStream: TCustomMemoryStream);
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
var
   HTMLText: String;
begin
   // remove any slashes from the front
   while (aURL <> '') and (aURL[1] = '/') do
      Delete(aURL, 1, 1);
   // remove any slashes from the back
   while (aURL <> '') and (aURL[Length(aURL)] = '/') do
      Delete(aURL, Length(aURL), 1);

   if SameText(aURL, 'home/text') then
   begin
      aMIMEType := 'text/plain';
      HTMLText := 'URL: ' + aURL + #13#10'text/plain...';
      WriteOutString(HTMLText);
   end
   else if SameText(aURL, 'home/jpeg') then
   begin
      aMIMEType := 'image/jpeg';
      WriteOutFile('image.jpg');
   end
   else if SameText(AURL, 'home/posted') then
   begin
      aMIMEType := 'text/plain';
      HTMLText := 'Post MIME Type: ' + aPostMIMEType + #13#10#13#10 +
         UTF8ToString(PAnsiChar(@aPostData));
      WriteOutString(HTMLText);
   end
   else
   begin
      HTMLText :=
         '<html>' +
            '<body>' +
               'URL: ' + aURL + '<br /><br />' +
               '<a href="text">plain text</a><br /><br />' +

               'Image From Protocol handler:<br />' +
               '<img src="jpeg" title="image from protocol" /><br /><br />' +

               '<fieldset>' +
               '<legend>Form with default enctype</legend>' +
               '<form action="posted" method="POST">' +
               '  <input type="text" name="inputtext1" value="text1" />' +
               '  <input type="text" name="inputtext2" value="text2" />' +
               '  <input type="submit" value="Submit" />' +
               '</form>' +
               '</fieldset>' +

               '<fieldset>' +
               '<legend>Form with "Multipart/form-data" enctype</legend>' +
               '<form enctype="multipart/form-data" action="posted" method="POST">' +
               '  <input type="text" name="inputtext1" value="text1" />' +
               '  <input type="text" name="inputtext2" value="text2" />' +
               '  <input type="submit" value="Submit" />' +
               '</form>' +
               '</fieldset>' +

               'Image From the Internet:<br />' +
               '<img src="http://www.jasontpenny.com/images/lightning.jpg" height="100" width="100" title="image from internet" />' +
            '</body>' +
         '</html>';
      WriteOutString(HTMLText);
   end;
end;

end.
