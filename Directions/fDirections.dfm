object frmDirections: TfrmDirections
  Left = 0
  Top = 0
  Caption = 'GoogleMaps Directions'
  ClientHeight = 609
  ClientWidth = 809
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 605
    Top = 0
    Height = 609
    Align = alRight
    Beveled = True
    ResizeStyle = rsUpdate
  end
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 0
    Width = 605
    Height = 609
    Align = alClient
    TabOrder = 0
    ControlData = {
      4C000000873E0000F13E00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object pnlRight: TPanel
    Left = 608
    Top = 0
    Width = 201
    Height = 609
    Align = alRight
    TabOrder = 1
    DesignSize = (
      201
      609)
    object lblDirections: TLabel
      Left = 11
      Top = 176
      Width = 182
      Height = 13
      Caption = 'Click a step to show the map "blowup"'
    end
    object lblFrom: TLabel
      Left = 11
      Top = 5
      Width = 28
      Height = 13
      Caption = 'From:'
    end
    object lblTo: TLabel
      Left = 11
      Top = 51
      Width = 16
      Height = 13
      Caption = 'To:'
    end
    object lblTo2: TLabel
      Left = 11
      Top = 99
      Width = 16
      Height = 13
      Caption = 'To:'
    end
    object btnDirections: TButton
      Left = 11
      Top = 145
      Width = 75
      Height = 25
      Caption = 'Directions'
      Default = True
      TabOrder = 3
      OnClick = btnDirectionsClick
    end
    object eFrom: TEdit
      Left = 11
      Top = 24
      Width = 182
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = '500 Memorial Dr, Cambridge MA 02139'
    end
    object eTo: TEdit
      Left = 11
      Top = 70
      Width = 182
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      Text = '4 Yawkey Way, Boston, MA 02215'
    end
    object eTo2: TEdit
      Left = 11
      Top = 118
      Width = 182
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      Text = 'Brookline'
    end
    object ListBox1: TListBox
      Left = 11
      Top = 192
      Width = 182
      Height = 409
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 4
      OnClick = ListBox1Click
    end
  end
end
