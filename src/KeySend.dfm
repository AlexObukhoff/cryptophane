object KeySendForm: TKeySendForm
  Left = 195
  Top = 107
  BorderIcons = [biSystemMenu]
  Caption = 'Send Keys to Keyserver'
  ClientHeight = 318
  ClientWidth = 449
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
    449
    318)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 173
    Height = 13
    Caption = 'Send the following keys to keyserver'
  end
  object KeyserverCombo: TComboBox
    Left = 192
    Top = 8
    Width = 257
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'KeyserverCombo'
  end
  object ListView: TListView
    Left = 8
    Top = 40
    Width = 441
    Height = 249
    Anchors = [akLeft, akTop, akRight, akBottom]
    Checkboxes = True
    Columns = <
      item
        Caption = 'User ID'
        Width = 290
      end
      item
        Caption = 'Key ID'
        Width = 120
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
  object SendButton: TButton
    Left = 288
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Send'
    Default = True
    TabOrder = 2
    OnClick = SendButtonClick
  end
  object Button2: TButton
    Left = 376
    Top = 296
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
