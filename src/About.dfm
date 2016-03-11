object AboutForm: TAboutForm
  Left = 399
  Top = 217
  BorderStyle = bsDialog
  Caption = 'About Cryptophane'
  ClientHeight = 240
  ClientWidth = 345
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  DesignSize = (
    345
    240)
  PixelsPerInch = 96
  TextHeight = 13
  object TitleLabel: TLabel
    Left = 16
    Top = 16
    Width = 60
    Height = 13
    Caption = 'Cryptophane'
  end
  object Label2: TLabel
    Left = 16
    Top = 32
    Width = 114
    Height = 13
    Caption = 'Copyright 2005 eCOSM.'
  end
  object Label3: TLabel
    Left = 16
    Top = 160
    Width = 304
    Height = 26
    Caption = 
      'This program is provided free of charge and as such comes with a' +
      'bsolutely no warranty.'
    WordWrap = True
  end
  object UsesLabel: TLabel
    Left = 16
    Top = 56
    Width = 131
    Height = 13
    Caption = 'Uses GnuPG executable in '
  end
  object EXEPathLabel: TLabel
    Left = 32
    Top = 72
    Width = 69
    Height = 13
    Caption = 'EXEPathLabel'
  end
  object Label1: TLabel
    Left = 16
    Top = 136
    Width = 247
    Height = 13
    Caption = 'Contact the developer at cryptophane@ecosm.com.'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 196
    Width = 329
    Height = 2
    Anchors = [akLeft, akBottom]
  end
  object Label4: TLabel
    Left = 16
    Top = 92
    Width = 152
    Height = 13
    Caption = 'Using key files from the directory'
  end
  object HomeDirLabel: TLabel
    Left = 32
    Top = 108
    Width = 67
    Height = 13
    Caption = 'HomeDirLabel'
  end
  object Button1: TButton
    Left = 260
    Top = 207
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
end
