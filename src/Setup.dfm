object SetupForm: TSetupForm
  Left = 196
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Cryptophane Options'
  ClientHeight = 402
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    464
    402)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 4
    Top = 357
    Width = 456
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  object Label1: TLabel
    Left = 8
    Top = 18
    Width = 89
    Height = 13
    Caption = 'Default secret key:'
  end
  object Label3: TLabel
    Left = 8
    Top = 290
    Width = 198
    Height = 13
    Caption = 'Save encrypted/signed files by default as:'
  end
  object KeyInfoLabel: TLabel
    Left = 104
    Top = 40
    Width = 62
    Height = 13
    Caption = 'KeyInfoLabel'
  end
  object OKButton: TButton
    Left = 295
    Top = 369
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 0
    OnClick = OKButtonClick
  end
  object Button2: TButton
    Left = 383
    Top = 369
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object DefaultKeyCombo: TComboBox
    Left = 104
    Top = 16
    Width = 351
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    OnChange = DefaultKeyComboChange
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 64
    Width = 448
    Height = 209
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Keyservers'
    TabOrder = 3
    object Label2: TLabel
      Left = 312
      Top = 88
      Width = 121
      Height = 26
      Caption = 'The topmost keyserver is used as the default.'
      WordWrap = True
    end
    object Label4: TLabel
      Left = 16
      Top = 160
      Width = 82
      Height = 13
      Caption = 'Use proxy server:'
    end
    object ProxyHostLabel: TLabel
      Left = 16
      Top = 184
      Width = 52
      Height = 13
      Caption = 'Proxy host:'
    end
    object ProxyPortLabel: TLabel
      Left = 248
      Top = 184
      Width = 50
      Height = 13
      Caption = 'Proxy port:'
    end
    object KeyServersList: TListBox
      Left = 16
      Top = 24
      Width = 281
      Height = 89
      ItemHeight = 13
      TabOrder = 0
      OnClick = KeyServersListClick
    end
    object AddButton: TButton
      Left = 304
      Top = 24
      Width = 65
      Height = 25
      Caption = '&Add'
      TabOrder = 1
      OnClick = AddButtonClick
    end
    object DeleteButton: TButton
      Left = 304
      Top = 56
      Width = 65
      Height = 25
      Caption = '&Delete'
      TabOrder = 2
      OnClick = DeleteButtonClick
    end
    object KeyServersEdit: TEdit
      Left = 16
      Top = 120
      Width = 281
      Height = 21
      TabOrder = 3
      Text = 'KeyServersEdit'
      OnChange = KeyServersEditChange
      OnKeyDown = KeyServersEditKeyDown
    end
    object UpButton: TButton
      Left = 376
      Top = 24
      Width = 65
      Height = 25
      Caption = 'Up'
      TabOrder = 4
      OnClick = UpButtonClick
    end
    object DownButton: TButton
      Left = 376
      Top = 56
      Width = 65
      Height = 25
      Caption = 'Down'
      TabOrder = 5
      OnClick = DownButtonClick
    end
    object ProxyNoneRadio: TRadioButton
      Left = 104
      Top = 160
      Width = 65
      Height = 17
      Caption = 'None'
      TabOrder = 6
      OnClick = ProxyNoneRadioClick
    end
    object ProxyWindowsRadio: TRadioButton
      Left = 168
      Top = 160
      Width = 121
      Height = 17
      Caption = 'Use window settings'
      TabOrder = 7
      OnClick = ProxyWindowsRadioClick
    end
    object ProxyManualRadio: TRadioButton
      Left = 304
      Top = 160
      Width = 137
      Height = 17
      Caption = 'Manually specify proxy'
      TabOrder = 8
      OnClick = ProxyManualRadioClick
    end
    object ProxyHostEdit: TEdit
      Left = 72
      Top = 180
      Width = 161
      Height = 21
      TabOrder = 9
    end
    object ProxyPortEdit: TEdit
      Left = 304
      Top = 180
      Width = 49
      Height = 21
      TabOrder = 10
    end
  end
  object GPGRadio: TRadioButton
    Left = 216
    Top = 288
    Width = 49
    Height = 17
    Caption = '.gpg'
    TabOrder = 5
  end
  object PGPRadio: TRadioButton
    Left = 272
    Top = 288
    Width = 49
    Height = 17
    Caption = '.pgp'
    TabOrder = 6
  end
  object Show16DigitIDsCheck: TCheckBox
    Left = 8
    Top = 312
    Width = 137
    Height = 17
    Caption = 'Show 16 digit key IDs'
    TabOrder = 7
  end
  object DebugCheck: TCheckBox
    Left = 8
    Top = 328
    Width = 137
    Height = 17
    Caption = 'Show debug information'
    TabOrder = 4
  end
  object ShowSuccessDialogsCheck: TCheckBox
    Left = 175
    Top = 311
    Width = 281
    Height = 17
    Caption = 'Show a dialog upon successful encryption/decryption'
    TabOrder = 8
  end
  object UseUntrustedKeyCheck: TCheckBox
    Left = 175
    Top = 328
    Width = 130
    Height = 17
    Caption = 'Allow to encrypt by unknowns keys'
    TabOrder = 9
  end
end
