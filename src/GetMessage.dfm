object GetMessageForm: TGetMessageForm
  Left = 316
  Top = 169
  BorderIcons = [biSystemMenu]
  Caption = 'Enter Message'
  ClientHeight = 373
  ClientWidth = 431
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    431
    373)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 327
    Height = 13
    Caption = 
      'Copy and paste the message to encrypt, decrypt, sign or verify b' +
      'elow:'
  end
  object Memo: TMemo
    Left = 8
    Top = 24
    Width = 417
    Height = 305
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object OKButton: TButton
    Left = 263
    Top = 340
    Width = 75
    Height = 25
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = OKButtonClick
  end
  object Button2: TButton
    Left = 351
    Top = 340
    Width = 75
    Height = 25
    Anchors = [akLeft, akTop, akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
