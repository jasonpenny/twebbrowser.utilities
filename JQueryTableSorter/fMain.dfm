object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'JQuery with TableSorter plugin'
  ClientHeight = 634
  ClientWidth = 829
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    829
    634)
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 8
    Top = 8
    Width = 702
    Height = 618
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    ControlData = {
      4C0000008E480000DF3F00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object btnInject: TButton
    Left = 716
    Top = 8
    Width = 105
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Inject TableSorter'
    TabOrder = 1
    OnClick = btnInjectClick
  end
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 16
    Top = 16
  end
end
