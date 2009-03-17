unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw, ExtCtrls, StdCtrls, uWebBrowser;

type
  TfrmMain = class(TForm)
    WebBrowser1: TWebBrowser;
    Timer1: TTimer;
    btnInject: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure btnInjectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    fWBWrapper: TWBWrapper;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btnInjectClick(Sender: TObject);
   function GetResourceAsString(const resource_name: String): String;
   var
      rs: TResourceStream;
      ss: TStringStream;
   begin
      rs := TResourceStream.Create(hInstance, resource_name, RT_RCDATA);
      try
         ss := TStringStream.Create('');
         try
            rs.SaveToStream(ss);
            ss.Seek(0, soBeginning);

            Result := ss.DataString;
         finally
            ss.Free;
         end;
      finally
         rs.Free;
      end;
   end;
var
   exe_file: String;
begin
   fWBWrapper.ExecJS(GetResourceAsString('JQUERY'));
   fWBWrapper.ExecJS(GetResourceAsString('JQCSSRULE'));

   exe_file := ExtractFileName(Forms.Application.ExeName);
   fWBWrapper.ExecJS(
      Format(
         '$.cssRule({"table.tablesorter thead tr .header": "background-image: url(res|//%s/IMAGEBG); ' +
                                                           'background-repeat: no-repeat; ' +
                                                           'background-position: center right; ' +
                                                           'cursor: pointer; ' +
                                                           'padding-right: 20px; ' +
                                                           'border-right: 1px solid #dad9c7; ' +
                                                           'margin-left: -1px;", ' +
         '"table.tablesorter thead tr th.headerSortUp":   "background-image: url(res|//%s/IMAGEASC);", ' +
         '"table.tablesorter thead tr th.headerSortDown": "background-image: url(res|//%s/IMAGEDESC);" });',
         [exe_file,exe_file,exe_file])
   );

   fWBWrapper.ExecJS('$("#t1").addClass("tablesorter");');

   fWBWrapper.ExecJS(GetResourceAsString('TABLESORT'));

   fWBWrapper.ExecJS('$("#t1").tablesorter();');
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
   fWBWrapper := TWBWrapper.Create(WebBrowser1);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
   fWBWrapper.Free;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
const
   html_doc =
      '<html>                                                                                      '#13#10 +
      '<body>                                                                                      '#13#10 +
      ' <table id="t1" border="1">                                                                 '#13#10 +
      '  <thead>                                                                                   '#13#10 +
      '   <tr>                                                                                     '#13#10 +
      '    <th class="header">number</th>                                                          '#13#10 +
      '    <th class="header">letter</th>                                                          '#13#10 +
      '    <th class="header">name</th>                                                            '#13#10 +
      '   </tr>                                                                                    '#13#10 +
      '  </thead>                                                                                  '#13#10 +
      '  <tbody>                                                                                   '#13#10 +
      '   <tr>                                                                                     '#13#10 +
      '    <td>1</td>                                                                              '#13#10 +
      '    <td>a</td>                                                                              '#13#10 +
      '    <td>zood</td>                                                                           '#13#10 +
      '   </tr>                                                                                    '#13#10 +
      '   <tr>                                                                                     '#13#10 +
      '    <td>2</td>                                                                              '#13#10 +
      '    <td>c</td>                                                                              '#13#10 +
      '    <td>craig</td>                                                                          '#13#10 +
      '   </tr>                                                                                    '#13#10 +
      '   <tr>                                                                                     '#13#10 +
      '    <td>3</td>                                                                              '#13#10 +
      '    <td>b</td>                                                                              '#13#10 +
      '    <td>joe</td>                                                                            '#13#10 +
      '   </tr>                                                                                    '#13#10 +
      '  </tbody>                                                                                  '#13#10 +
      ' </table>                                                                                   '#13#10 +
      '</body>                                                                                     '#13#10 +
      '</html>                                                                                     ';
begin
   TTimer(Sender).Enabled := false;

   fWBWrapper.LoadHTML(html_doc);
end;

end.
