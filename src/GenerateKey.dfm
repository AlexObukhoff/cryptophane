object GenerateKeyForm: TGenerateKeyForm
  Left = 195
  Top = 107
  BorderStyle = bsDialog
  Caption = 'Generate Secret Key'
  ClientHeight = 209
  ClientWidth = 481
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 43
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object Label2: TLabel
    Left = 8
    Top = 67
    Width = 71
    Height = 13
    Caption = 'E-mail address:'
  end
  object Label3: TLabel
    Left = 8
    Top = 91
    Width = 47
    Height = 13
    Caption = 'Comment:'
  end
  object Label5: TLabel
    Left = 8
    Top = 120
    Width = 82
    Height = 13
    Caption = 'New passphrase:'
  end
  object Label6: TLabel
    Left = 8
    Top = 144
    Width = 95
    Height = 13
    Caption = 'Confirm passphrase:'
  end
  object Label4: TLabel
    Left = 304
    Top = 123
    Width = 77
    Height = 13
    Caption = 'DSA key length:'
  end
  object Label7: TLabel
    Left = 304
    Top = 147
    Width = 94
    Height = 13
    Caption = 'ElGamal key length:'
  end
  object StatusLabel: TLabel
    Left = 12
    Top = 184
    Width = 56
    Height = 13
    Caption = 'StatusLabel'
  end
  object Label8: TLabel
    Left = 8
    Top = 14
    Width = 350
    Height = 13
    Caption = 
      'Enter your details below to create a new key for your Cryptophan' +
      'e keyring.'
  end
  object NameEdit: TEdit
    Left = 88
    Top = 40
    Width = 193
    Height = 21
    TabOrder = 0
    Text = 'NameEdit'
  end
  object AddressEdit: TEdit
    Left = 88
    Top = 64
    Width = 193
    Height = 21
    TabOrder = 1
    Text = 'AddressEdit'
  end
  object CommentEdit: TEdit
    Left = 88
    Top = 88
    Width = 193
    Height = 21
    TabOrder = 2
    Text = 'CommentEdit'
  end
  object ExpiresCheck: TCheckBox
    Left = 304
    Top = 91
    Width = 97
    Height = 17
    Caption = 'Key expires'
    TabOrder = 5
    OnClick = ExpiresCheckClick
  end
  object PassphraseEdit: TEdit
    Left = 112
    Top = 120
    Width = 169
    Height = 21
    PasswordChar = '*'
    TabOrder = 3
    Text = 'PassphraseEdit'
  end
  object ConfirmEdit: TEdit
    Left = 112
    Top = 144
    Width = 169
    Height = 21
    PasswordChar = '*'
    TabOrder = 4
    Text = 'ConfirmEdit'
  end
  object ExpiryPicker: TDateTimePicker
    Left = 384
    Top = 88
    Width = 89
    Height = 21
    Date = 38132.920322997680000000
    Time = 38132.920322997680000000
    TabOrder = 6
  end
  object GenerateButton: TButton
    Left = 312
    Top = 176
    Width = 75
    Height = 25
    Caption = '&Generate'
    TabOrder = 9
    OnClick = GenerateButtonClick
  end
  object CancelButton: TButton
    Left = 400
    Top = 176
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 10
  end
  object DSACombo: TComboBox
    Left = 400
    Top = 120
    Width = 73
    Height = 21
    Style = csDropDownList
    TabOrder = 7
  end
  object ElGamalCombo: TComboBox
    Left = 400
    Top = 144
    Width = 73
    Height = 21
    Style = csDropDownList
    TabOrder = 8
  end
end
