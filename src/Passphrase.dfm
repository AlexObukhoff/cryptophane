object PassphraseForm: TPassphraseForm
  Left = 195
  Top = 107
  BorderStyle = bsDialog
  Caption = 'Enter Passphrase'
  ClientHeight = 129
  ClientWidth = 365
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 123
    Height = 13
    Caption = 'Enter passphrase for user:'
  end
  object UserIDLabel: TLabel
    Left = 20
    Top = 24
    Width = 71
    Height = 13
    Caption = 'UserIDLabel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object KeyInfoLabel: TLabel
    Left = 20
    Top = 40
    Width = 62
    Height = 13
    Caption = 'KeyInfoLabel'
  end
  object PassphraseEdit: TEdit
    Left = 8
    Top = 64
    Width = 345
    Height = 21
    MaxLength = 1024
    PasswordChar = '*'
    TabOrder = 0
  end
  object Button1: TButton
    Left = 192
    Top = 96
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 280
    Top = 96
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
