program AsyncPlugProtoDemo;

uses
  Forms,
  fAsyncPlugProtoDemo in 'fAsyncPlugProtoDemo.pas' {frmMain},
  uAsyncPlugProto in '..\lib\uAsyncPlugProto.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
