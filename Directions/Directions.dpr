program Directions;

uses
  Forms,
  fDirections in 'fDirections.pas' {frmDirections},
  uSimpleDirections in 'uSimpleDirections.pas',
  Automation in '..\lib\Others\Automation.pas',
  uWBGoogleMaps in '..\lib\uWBGoogleMaps.pas',
  IntfDocHostUIHandler in '..\lib\Others\IntfDocHostUIHandler.pas',
  UContainer in '..\lib\Others\UContainer.pas',
  UNulContainer in '..\lib\Others\UNulContainer.pas';

{$R *.res}

begin
  Application.Initialize;
  // only Delphi 2007+
{$IF CompilerVersion > 18.0}
  Application.MainFormOnTaskbar := True;
{$IFEND}
  Application.CreateForm(TfrmDirections, frmDirections);
  Application.Run;
end.
