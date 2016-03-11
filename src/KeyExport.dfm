object KeyExportForm: TKeyExportForm
  Left = 195
  Top = 106
  BorderIcons = [biSystemMenu]
  Caption = 'Export Keys'
  ClientHeight = 305
  ClientWidth = 450
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  DesignSize = (
    450
    305)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 190
    Height = 13
    Caption = 'Select the keys you would like to export:'
  end
  object ListView: TListView
    Left = 8
    Top = 32
    Width = 433
    Height = 193
    Anchors = [akLeft, akTop, akRight, akBottom]
    Checkboxes = True
    Columns = <
      item
        Caption = 'Key'
        Width = 290
      end
      item
        Caption = 'Key ID'
        Width = 120
      end>
    ReadOnly = True
    RowSelect = True
    SortType = stText
    TabOrder = 0
    ViewStyle = vsReport
  end
  object ExportAllCheck: TCheckBox
    Left = 16
    Top = 236
    Width = 97
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Export all keys'
    TabOrder = 1
    OnClick = ExportAllCheckClick
  end
  object FileCheck: TCheckBox
    Left = 16
    Top = 256
    Width = 161
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Save output to a file'
    TabOrder = 2
  end
  object OKButton: TButton
    Left = 280
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 3
    OnClick = OKButtonClick
  end
  object Button2: TButton
    Left = 368
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object SaveDialog: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 216
    Top = 256
  end
end
