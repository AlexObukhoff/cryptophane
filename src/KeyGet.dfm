object KeyGetForm: TKeyGetForm
  Left = 195
  Top = 107
  BorderStyle = bsDialog
  Caption = 'Get Key from Keyserver'
  ClientHeight = 97
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 11
    Width = 83
    Height = 13
    Caption = 'Search keyserver'
  end
  object Label2: TLabel
    Left = 8
    Top = 35
    Width = 46
    Height = 13
    Caption = 'for key ID'
  end
  object KeyserverCombo: TComboBox
    Left = 104
    Top = 8
    Width = 385
    Height = 21
    TabOrder = 0
    Text = 'KeyserverCombo'
  end
  object KeyEdit: TEdit
    Left = 104
    Top = 32
    Width = 289
    Height = 21
    TabOrder = 1
    Text = 'KeyEdit'
  end
  object GetKeyButton: TButton
    Left = 320
    Top = 64
    Width = 81
    Height = 25
    Caption = '&Get Key'
    Default = True
    TabOrder = 2
    OnClick = GetKeyButtonClick
  end
  object Button1: TButton
    Left = 416
    Top = 64
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
