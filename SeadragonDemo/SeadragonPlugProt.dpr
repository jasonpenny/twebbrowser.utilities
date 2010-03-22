program SeadragonPlugProt;

uses
  Forms,
  fSeadragon in 'fSeadragon.pas' {frmSeadragon},
  uStaticHtml in 'uStaticHtml.pas',
  uAsyncPlugProto in '..\lib\uAsyncPlugProto.pas',
  GR32 in '..\lib\Others\graphics32\GR32.pas',
  GR32_System in '..\lib\Others\graphics32\GR32_System.pas',
  GR32_Blend in '..\lib\Others\graphics32\GR32_Blend.pas',
  GR32_Filters in '..\lib\Others\graphics32\GR32_Filters.pas',
  GR32_LowLevel in '..\lib\Others\graphics32\GR32_LowLevel.pas',
  GR32_Math in '..\lib\Others\graphics32\GR32_Math.pas',
  GR32_Resamplers in '..\lib\Others\graphics32\GR32_Resamplers.pas',
  GR32_Containers in '..\lib\Others\graphics32\GR32_Containers.pas',
  GR32_Backends in '..\lib\Others\graphics32\GR32_Backends.pas',
  GR32_Backends_Generic in '..\lib\Others\graphics32\GR32_Backends_Generic.pas',
  GR32_Bindings in '..\lib\Others\graphics32\GR32_Bindings.pas',
  GR32_Transforms in '..\lib\Others\graphics32\GR32_Transforms.pas',
  GR32_OrdinalMaps in '..\lib\Others\graphics32\GR32_OrdinalMaps.pas',
  GR32_VectorMaps in '..\lib\Others\graphics32\GR32_VectorMaps.pas',
  GR32_Rasterizers in '..\lib\Others\graphics32\GR32_Rasterizers.pas',
  GR32_Image in '..\lib\Others\graphics32\GR32_Image.pas',
  GR32_Layers in '..\lib\Others\graphics32\GR32_Layers.pas',
  GR32_RangeBars in '..\lib\Others\graphics32\GR32_RangeBars.pas',
  GR32_XPThemes in '..\lib\Others\graphics32\GR32_XPThemes.pas',
  GR32_RepaintOpt in '..\lib\Others\graphics32\GR32_RepaintOpt.pas',
  GR32_MicroTiles in '..\lib\Others\graphics32\GR32_MicroTiles.pas',
  GR32_Backends_VCL in '..\lib\Others\graphics32\GR32_Backends_VCL.pas',
  GR32_DrawingEx in '..\lib\Others\graphics32\GR32_DrawingEx.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmSeadragon, frmSeadragon);
  Application.Run;
end.
