object SignKeyForm: TSignKeyForm
  Left = 195
  Top = 107
  BorderStyle = bsDialog
  Caption = 'Sign Key'
  ClientHeight = 298
  ClientWidth = 442
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
    Top = 16
    Width = 142
    Height = 13
    Caption = 'You are about to sign the key:'
  end
  object KeyLabel: TLabel
    Left = 24
    Top = 40
    Width = 53
    Height = 13
    Caption = 'KeyLabel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LongIDLabel: TLabel
    Left = 24
    Top = 56
    Width = 61
    Height = 13
    Caption = 'LongIDLabel'
  end
  object Label2: TLabel
    Left = 8
    Top = 154
    Width = 413
    Height = 26
    Caption = 
      'By signing this key, you are testifying to the entire cryptograp' +
      'hic community that you are completely sure that this key belongs' +
      ' to the person indicated in the key name above.'
    WordWrap = True
  end
  object Label3: TLabel
    Left = 8
    Top = 190
    Width = 417
    Height = 26
    Caption = 
      'You can be certain by contacting the key owner by phone or in pe' +
      'rson and getting them to read out their key'#39's fingerprint.  If i' +
      't is the same as above, the key is the same.'
    WordWrap = True
  end
  object FingerprintLabel: TLabel
    Left = 24
    Top = 80
    Width = 75
    Height = 13
    Caption = 'FingerprintLabel'
  end
  object Label4: TLabel
    Left = 8
    Top = 107
    Width = 118
    Height = 13
    Caption = 'Sign key with secret key:'
  end
  object SelectedKeyInfoLabel: TLabel
    Left = 136
    Top = 128
    Width = 104
    Height = 13
    Caption = 'SelectedKeyInfoLabel'
  end
  object KeyCombo: TComboBox
    Left = 136
    Top = 104
    Width = 289
    Height = 21
    Style = csDropDownList
    TabOrder = 0
    OnChange = KeyComboChange
  end
  object Button1: TButton
    Left = 8
    Top = 264
    Width = 305
    Height = 25
    Caption = 'I am POSITIVE that this key belongs to its indicated owner'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 328
    Top = 264
    Width = 105
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object MatchCheck: TCheckBox
    Left = 24
    Top = 232
    Width = 369
    Height = 17
    Caption = 
      'I have checked the above fingerprint with the key owner and they' +
      ' match.'
    TabOrder = 1
  end
end
