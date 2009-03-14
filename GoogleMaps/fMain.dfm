object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'GoogleMaps in Delphi, with Geo-coding'
  ClientHeight = 455
  ClientWidth = 757
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    757
    455)
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 8
    Top = 8
    Width = 610
    Height = 422
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 8
    ControlData = {
      4C0000000C3F00009D2B00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object btnAddMarker: TButton
    Left = 624
    Top = 232
    Width = 125
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Add Marker'
    TabOrder = 6
    OnClick = btnAddMarkerClick
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 436
    Width = 757
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object btnGeocode: TButton
    Left = 624
    Top = 55
    Width = 125
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Geocode'
    TabOrder = 1
    OnClick = btnGeocodeClick
  end
  object leLat: TLabeledEdit
    Left = 624
    Top = 144
    Width = 125
    Height = 21
    Anchors = [akTop, akRight]
    EditLabel.Width = 39
    EditLabel.Height = 13
    EditLabel.Caption = 'Latitude'
    TabOrder = 4
    Text = '37.05173494'
  end
  object leLng: TLabeledEdit
    Left = 624
    Top = 184
    Width = 125
    Height = 21
    Anchors = [akTop, akRight]
    EditLabel.Width = 47
    EditLabel.Height = 13
    EditLabel.Caption = 'Longitude'
    TabOrder = 5
    Text = '-122.03160858'
  end
  object mmGeocode: TMemo
    Left = 624
    Top = 8
    Width = 126
    Height = 41
    Anchors = [akTop, akRight]
    Lines.Strings = (
      'Rego Park, NY')
    TabOrder = 0
  end
  object btnCenterMap: TButton
    Left = 624
    Top = 263
    Width = 125
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Center map on'
    TabOrder = 7
    OnClick = btnCenterMapClick
  end
  object rbAPI: TRadioButton
    Left = 624
    Top = 88
    Width = 33
    Height = 17
    Hint = 'The "correct" way to do it'
    Anchors = [akTop, akRight]
    Caption = 'API'
    Checked = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    TabStop = True
  end
  object rbCheat: TRadioButton
    Left = 680
    Top = 88
    Width = 49
    Height = 17
    Hint = 'Seems to be more accurate'
    Anchors = [akTop, akRight]
    Caption = 'Cheat'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object btnDirections: TButton
    Left = 624
    Top = 311
    Width = 125
    Height = 25
    Hint = 
      'Map directions for from: "500 Memorial Drive, Cambridge, MA to: ' +
      '4 Yawkey Way, Boston, MA 02215 (Fenway Park)"'
    Anchors = [akTop, akRight]
    Caption = 'Directions'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
    OnClick = btnDirectionsClick
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 16
    Top = 16
  end
end
