object KeySearchForm: TKeySearchForm
  Left = 270
  Top = 204
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Search Keyserver'
  ClientHeight = 369
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    492
    369)
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
    Width = 32
    Height = 13
    Caption = 'for key'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 64
    Width = 481
    Height = 2
    Anchors = [akLeft, akTop, akRight]
  end
  object KeyserverCombo: TComboBox
    Left = 104
    Top = 8
    Width = 385
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'KeyserverCombo'
    OnEnter = KeyserverComboEnter
  end
  object KeyEdit: TEdit
    Left = 104
    Top = 32
    Width = 289
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    Text = 'KeyEdit'
    OnEnter = KeyEditEnter
  end
  object ListView: TListView
    Left = 8
    Top = 80
    Width = 481
    Height = 249
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'User ID'
        Width = 250
      end
      item
        Caption = 'Created'
        Width = 75
      end
      item
        Caption = 'Key ID'
        Width = 75
      end
      item
        Caption = 'Type'
        Width = 55
      end>
    HideSelection = False
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    SortType = stText
    TabOrder = 2
    ViewStyle = vsReport
    OnColumnClick = ListViewColumnClick
    OnCompare = ListViewCompare
    OnEnter = ListViewEnter
  end
  object SearchButton: TButton
    Left = 408
    Top = 32
    Width = 81
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '&Search'
    Default = True
    TabOrder = 3
    OnClick = SearchButtonClick
  end
  object Button1: TButton
    Left = 416
    Top = 344
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 4
  end
  object AddButton: TButton
    Left = 8
    Top = 344
    Width = 129
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Add Selected Keys'
    TabOrder = 5
    OnClick = AddButtonClick
  end
end
