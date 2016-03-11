object SymPassphraseForm: TSymPassphraseForm
  Left = 249
  Top = 186
  BorderStyle = bsDialog
  Caption = 'Passphrase'
  ClientHeight = 121
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
    Width = 253
    Height = 13
    Caption = 'This message has been encrypted with a passphrase.'
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 161
    Height = 13
    Caption = 'Enter the passphrase to decrypt it:'
  end
  object PassphraseEdit: TEdit
    Left = 8
    Top = 48
    Width = 345
    Height = 21
    MaxLength = 1024
    PasswordChar = '*'
    TabOrder = 0
  end
  object Button1: TButton
    Left = 192
    Top = 88
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 280
    Top = 88
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
