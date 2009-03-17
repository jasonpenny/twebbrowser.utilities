program JQueryTableSorter;

{$R 'jquery.res' 'jquery.rc'}

uses
  Forms,
  fMain in 'fMain.pas' {frmMain},
  uWebBrowser in '..\lib\uWebBrowser.pas',
  IntfDocHostUIHandler in '..\lib\Others\IntfDocHostUIHandler.pas',
  UContainer in '..\lib\Others\UContainer.pas',
  UNulContainer in '..\lib\Others\UNulContainer.pas';

{$R *.res}

begin
  Application.Initialize;
{$IF CompilerVersion > 18.0}
  Application.MainFormOnTaskbar := True;
{$IFEND}
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
