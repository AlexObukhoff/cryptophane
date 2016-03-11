object EncryptSignForm: TEncryptSignForm
  Left = 195
  Top = 107
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Encrypt/Sign Data'
  ClientHeight = 472
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    505
    472)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 76
    Height = 13
    Caption = 'Read data from:'
  end
  object Label2: TLabel
    Left = 8
    Top = 42
    Width = 71
    Height = 13
    Caption = 'Output into file:'
  end
  object InNameLabel: TLabel
    Left = 88
    Top = 17
    Width = 361
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'C:\Documents and Settings\Mog\Desktop\a file.txt'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object OutNameLabel: TLabel
    Left = 88
    Top = 42
    Width = 361
    Height = 13
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'C:\Documents and Settings\Mog\Desktop\a file.txt.gpg'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object OutFileChangeButton: TButton
    Left = 464
    Top = 40
    Width = 33
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 0
    OnClick = OutFileChangeButtonClick
  end
  object EncryptGroup: TGroupBox
    Left = 8
    Top = 96
    Width = 489
    Height = 199
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    DesignSize = (
      489
      199)
    object Label4: TLabel
      Left = 8
      Top = 24
      Width = 403
      Height = 13
      Caption = 
        'Encrypting your data will ensure only the recipients checked bel' +
        'ow can read the data.'
    end
    object Label6: TLabel
      Left = 8
      Top = 43
      Width = 22
      Height = 13
      Caption = 'Filter'
    end
    object EncryptCheck: TCheckBox
      Left = 8
      Top = 0
      Width = 131
      Height = 17
      Caption = '&Encrypt with public key'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = EncryptCheckClick
    end
    object ListView: TListView
      Left = 8
      Top = 64
      Width = 473
      Height = 125
      Anchors = [akLeft, akTop, akRight, akBottom]
      Checkboxes = True
      Columns = <
        item
          Caption = 'User ID'
          Width = 275
        end
        item
          Caption = 'Key ID'
          Width = 115
        end
        item
          Caption = 'Created'
          Width = 70
        end
        item
          Caption = 'Expires'
          Width = 70
        end>
      ReadOnly = True
      RowSelect = True
      SortType = stText
      TabOrder = 3
      ViewStyle = vsReport
      OnChange = ListViewChange
    end
    object AllowUntrustedCheck: TCheckBox
      Left = 336
      Top = 41
      Width = 145
      Height = 17
      Anchors = [akTop, akRight]
      Caption = '&Allow untrusted recipients'
      TabOrder = 2
    end
    object FilterEdit: TEdit
      Left = 40
      Top = 40
      Width = 281
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      Text = 'FilterEdit'
      OnChange = FilterEditChange
    end
  end
  object SignGroup: TGroupBox
    Left = 8
    Top = 304
    Width = 489
    Height = 129
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 3
    object Label3: TLabel
      Left = 8
      Top = 24
      Width = 472
      Height = 13
      Caption = 
        'Signing your data allows your recipients to verify the data came' +
        ' from you and was not tampered with.'
    end
    object Label5: TLabel
      Left = 8
      Top = 51
      Width = 101
      Height = 13
      Caption = 'Sign with private key:'
    end
    object SecretIDLabel: TLabel
      Left = 408
      Top = 72
      Width = 68
      Height = 13
      Alignment = taRightJustify
      Caption = 'SecretIDLabel'
    end
    object SecretCreatedLabel: TLabel
      Left = 382
      Top = 88
      Width = 94
      Height = 13
      Alignment = taRightJustify
      Caption = 'SecretCreatedLabel'
    end
    object SecretExpiresLabel: TLabel
      Left = 385
      Top = 104
      Width = 91
      Height = 13
      Alignment = taRightJustify
      Caption = 'SecretExpiresLabel'
    end
    object ComboBox: TComboBox
      Left = 120
      Top = 48
      Width = 361
      Height = 21
      Style = csDropDownList
      TabOrder = 1
      OnChange = ComboBoxChange
    end
    object DataSigRadio: TRadioButton
      Left = 8
      Top = 72
      Width = 209
      Height = 17
      Caption = 'Output file contains &data and signature'
      TabOrder = 2
      OnClick = DataSigRadioClick
    end
    object PlainSigRadio: TRadioButton
      Left = 8
      Top = 88
      Width = 313
      Height = 17
      Caption = 'Output file contains plaintext data &and signature'
      TabOrder = 3
      OnClick = PlainSigRadioClick
    end
    object SigRadio: TRadioButton
      Left = 8
      Top = 104
      Width = 249
      Height = 17
      Caption = 'Output file contains signature &only'
      TabOrder = 4
      OnClick = SigRadioClick
    end
    object SignCheck: TCheckBox
      Left = 8
      Top = 0
      Width = 117
      Height = 17
      Caption = '&Sign with secret key'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = SignCheckClick
    end
  end
  object ArmourOutputCheck: TCheckBox
    Left = 8
    Top = 436
    Width = 241
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Output 7-bit ASCII data instead of binary data'
    TabOrder = 4
    OnClick = ArmourOutputCheckClick
  end
  object ProcessButton: TButton
    Left = 336
    Top = 440
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Process'
    Default = True
    TabOrder = 5
    OnClick = ProcessButtonClick
  end
  object Button6: TButton
    Left = 424
    Top = 440
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object SymmetricCheck: TCheckBox
    Left = 16
    Top = 72
    Width = 281
    Height = 17
    Caption = 'Encrypt with shared passphrase (symmetric encryption)'
    TabOrder = 1
  end
  object OpenDialog: TOpenDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 472
    Top = 8
  end
  object SaveDialog: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 448
    Top = 8
  end
end
