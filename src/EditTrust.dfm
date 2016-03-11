object EditTrustForm: TEditTrustForm
  Left = 195
  Top = 107
  Caption = 'Edit Level of Trust'
  ClientHeight = 398
  ClientWidth = 558
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
    Top = 8
    Width = 307
    Height = 13
    Caption = 
      'You can assign each key in your public key ring a level of "trus' +
      't".'
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 548
    Height = 39
    Caption = 
      'The trust that you give to a key indicates how much you trust th' +
      'at user to carefully check other people'#39's keys before signing th' +
      'em.  It has nothing else to do with how you trust them as a pers' +
      'on beyond their ability to verify keys before they sign them!'
    WordWrap = True
  end
  object Label3: TLabel
    Left = 34
    Top = 240
    Width = 452
    Height = 13
    Caption = 
      'If three people I trust marginally have signed a key, I will tru' +
      'st that key as if I had signed it myself.'
  end
  object Label4: TLabel
    Left = 34
    Top = 288
    Width = 320
    Height = 13
    Caption = 
      'If this user signs a key, I will trust that key as if I had sign' +
      'ed it myself.'
  end
  object Label5: TLabel
    Left = 33
    Top = 336
    Width = 249
    Height = 13
    Caption = 'Only use this for keys that you have created yourself.'
  end
  object Label6: TLabel
    Left = 8
    Top = 80
    Width = 532
    Height = 39
    Caption = 
      'The purpose of this is so that you do not have to independently ' +
      'verify each key in your keyring.  If users you trust have signed' +
      ' the key, you will implicitly trust their signatures as if you h' +
      'ad signed the key yourself.  For this reason, these options must' +
      ' be used with care.'
    WordWrap = True
  end
  object Label7: TLabel
    Left = 8
    Top = 128
    Width = 59
    Height = 13
    Caption = 'For the user '
  end
  object UserLabel: TLabel
    Left = 69
    Top = 128
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
  object UnknownRadio: TRadioButton
    Left = 16
    Top = 160
    Width = 337
    Height = 17
    Caption = 'I do not know how much I trust this user.'
    TabOrder = 0
  end
  object NoRadio: TRadioButton
    Left = 16
    Top = 192
    Width = 193
    Height = 17
    Caption = 'I do not trust this user at all.'
    TabOrder = 1
  end
  object MarginalRadio: TRadioButton
    Left = 16
    Top = 224
    Width = 169
    Height = 17
    Caption = 'I trust this user marginally.'
    TabOrder = 2
  end
  object FullyRadio: TRadioButton
    Left = 16
    Top = 272
    Width = 113
    Height = 17
    Caption = 'I trust this user fully.'
    TabOrder = 3
  end
  object UltimatelyRadio: TRadioButton
    Left = 16
    Top = 320
    Width = 145
    Height = 17
    Caption = 'I trust this user ultimately.'
    TabOrder = 4
  end
  object Button1: TButton
    Left = 368
    Top = 376
    Width = 99
    Height = 25
    Caption = '&Update Trust'
    Default = True
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 480
    Top = 376
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 6
  end
end
