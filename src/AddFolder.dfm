object AddFolderForm: TAddFolderForm
  Left = 263
  Top = 161
  BorderStyle = bsDialog
  Caption = 'Add Folder'
  ClientHeight = 85
  ClientWidth = 335
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
    Top = 20
    Width = 83
    Height = 13
    Caption = 'New folder name:'
  end
  object FolderEdit: TEdit
    Left = 104
    Top = 16
    Width = 217
    Height = 21
    TabOrder = 0
  end
  object OKButton: TButton
    Left = 160
    Top = 48
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = OKButtonClick
  end
  object Button2: TButton
    Left = 248
    Top = 48
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
