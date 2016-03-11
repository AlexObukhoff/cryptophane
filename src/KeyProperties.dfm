object KeyPropertiesForm: TKeyPropertiesForm
  Left = 195
  Top = 107
  BorderStyle = bsDialog
  Caption = 'KeyPropertiesForm'
  ClientHeight = 504
  ClientWidth = 409
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
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 52
    Height = 13
    Caption = 'Fingerprint:'
  end
  object FingerprintLabel: TLabel
    Left = 72
    Top = 40
    Width = 75
    Height = 13
    Caption = 'FingerprintLabel'
  end
  object UserLabel: TLabel
    Left = 8
    Top = 16
    Width = 58
    Height = 13
    Caption = 'UserLabel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LongLabel: TLabel
    Left = 72
    Top = 56
    Width = 50
    Height = 13
    Caption = 'LongLabel'
  end
  object Label3: TLabel
    Left = 8
    Top = 56
    Width = 35
    Height = 13
    Caption = 'Key ID:'
  end
  object Label4: TLabel
    Left = 8
    Top = 88
    Width = 40
    Height = 13
    Caption = 'Created:'
  end
  object Label5: TLabel
    Left = 8
    Top = 104
    Width = 37
    Height = 13
    Caption = 'Expires:'
  end
  object CreatedLabel: TLabel
    Left = 72
    Top = 88
    Width = 63
    Height = 13
    Caption = 'CreatedLabel'
  end
  object ExpiresLabel: TLabel
    Left = 72
    Top = 104
    Width = 60
    Height = 13
    Caption = 'ExpiresLabel'
  end
  object TLabel
    Left = 8
    Top = 120
    Width = 3
    Height = 13
  end
  object Label6: TLabel
    Left = 8
    Top = 72
    Width = 44
    Height = 13
    Caption = 'Key type:'
  end
  object KeyTypeLabel: TLabel
    Left = 72
    Top = 72
    Width = 68
    Height = 13
    Caption = 'KeyTypeLabel'
  end
  object Label7: TLabel
    Left = 200
    Top = 88
    Width = 48
    Height = 13
    Caption = 'User trust:'
  end
  object Label8: TLabel
    Left = 200
    Top = 104
    Width = 76
    Height = 13
    Caption = 'Calculated trust:'
  end
  object UserTrustLabel: TLabel
    Left = 288
    Top = 88
    Width = 72
    Height = 13
    Caption = 'UserTrustLabel'
  end
  object CalcTrustLabel: TLabel
    Left = 288
    Top = 104
    Width = 71
    Height = 13
    Caption = 'CalcTrustLabel'
  end
  object Label9: TLabel
    Left = 8
    Top = 128
    Width = 53
    Height = 13
    Caption = 'Signatures:'
  end
  object Label1: TLabel
    Left = 8
    Top = 296
    Width = 47
    Height = 13
    Caption = 'Sub keys:'
  end
  object Label10: TLabel
    Left = 200
    Top = 72
    Width = 66
    Height = 13
    Caption = 'Key algorithm:'
  end
  object KeyAlgorithmLabel: TLabel
    Left = 288
    Top = 72
    Width = 87
    Height = 13
    Caption = 'KeyAlgorithmLabel'
  end
  object Label11: TLabel
    Left = 200
    Top = 56
    Width = 46
    Height = 13
    Caption = 'Key uses:'
  end
  object KeyUsesLabel: TLabel
    Left = 288
    Top = 56
    Width = 68
    Height = 13
    Caption = 'KeyUsesLabel'
  end
  object Label12: TLabel
    Left = 8
    Top = 384
    Width = 97
    Height = 13
    Caption = 'Alternative User IDs:'
  end
  object Button2: TButton
    Left = 326
    Top = 472
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Close'
    Default = True
    ModalResult = 2
    TabOrder = 0
  end
  object ListView: TListView
    Left = 8
    Top = 144
    Width = 393
    Height = 145
    Columns = <
      item
        Caption = 'Name'
        Width = 100
      end
      item
        Caption = 'E-mail'
        Width = 150
      end
      item
        Caption = 'Key ID'
        Width = 118
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = ListViewDblClick
  end
  object SubKeysLV: TListView
    Left = 8
    Top = 312
    Width = 393
    Height = 65
    Columns = <
      item
        Caption = 'Key Type'
        Width = 120
      end
      item
        Width = 100
      end
      item
        Caption = 'Key ID'
        Width = 150
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
    OnDblClick = SubKeysLVDblClick
  end
  object UIDListView: TListView
    Left = 8
    Top = 400
    Width = 393
    Height = 57
    Columns = <
      item
        Caption = 'User ID'
        Width = 182
      end
      item
        Caption = 'Created'
        Width = 70
      end
      item
        Caption = 'Key ID'
        Width = 118
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
    OnDblClick = UIDListViewDblClick
  end
end
