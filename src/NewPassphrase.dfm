object NewPassphraseForm: TNewPassphraseForm
  Left = 286
  Top = 195
  BorderStyle = bsDialog
  Caption = 'New Passphrase'
  ClientHeight = 184
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
    Width = 234
    Height = 13
    Caption = 'Enter a passphrase to encrypt your message with:'
  end
  object Label2: TLabel
    Left = 8
    Top = 56
    Width = 205
    Height = 13
    Caption = 'Confirm the passphrase by entering it again:'
  end
  object Label3: TLabel
    Left = 8
    Top = 104
    Width = 336
    Height = 39
    Caption = 
      'Please note this is NOT your secret key passphrase.  You need to' +
      ' give this passphrase to your recipients (via a secure means) so' +
      ' they can decrypt your message.'
    WordWrap = True
  end
  object PassphraseEdit: TEdit
    Left = 8
    Top = 24
    Width = 345
    Height = 21
    MaxLength = 64
    PasswordChar = '*'
    TabOrder = 0
  end
  object OKButton: TButton
    Left = 192
    Top = 152
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 2
    OnClick = OKButtonClick
  end
  object Button2: TButton
    Left = 280
    Top = 152
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object ConfirmEdit: TEdit
    Left = 8
    Top = 72
    Width = 345
    Height = 21
    MaxLength = 64
    PasswordChar = '*'
    TabOrder = 1
  end
end
