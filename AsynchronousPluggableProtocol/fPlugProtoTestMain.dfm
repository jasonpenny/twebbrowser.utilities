object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Asynchronous Pluggable Protocol Test'
  ClientHeight = 509
  ClientWidth = 849
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    849
    509)
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 8
    Top = 8
    Width = 752
    Height = 493
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    ControlData = {
      4C000000B94D0000F43200000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Button1: TButton
    Left = 766
    Top = 8
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Register'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button3: TButton
    Left = 766
    Top = 56
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Navigate'
    TabOrder = 2
    OnClick = Button3Click
  end
end
