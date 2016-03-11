object DisplayDataForm: TDisplayDataForm
  Left = 195
  Top = 107
  BorderIcons = [biSystemMenu]
  Caption = 'Output'
  ClientHeight = 442
  ClientWidth = 680
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    680
    442)
  PixelsPerInch = 96
  TextHeight = 13
  object CopiedLabel: TLabel
    Left = 128
    Top = 424
    Width = 237
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'The above data has been copied to the clipboard.'
  end
  object Memo: TMemo
    Left = 8
    Top = 8
    Width = 673
    Height = 401
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    WantReturns = False
  end
  object Button1: TButton
    Left = 584
    Top = 420
    Width = 97
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object SaveButton: TButton
    Left = 8
    Top = 420
    Width = 105
    Height = 25
    Caption = '&Save to File'
    TabOrder = 2
    OnClick = SaveButtonClick
  end
  object SaveDialog: TSaveDialog
    Left = 448
    Top = 424
  end
end
