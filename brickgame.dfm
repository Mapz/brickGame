object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'wallTenis'
  ClientHeight = 296
  ClientWidth = 544
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object statusText: TLabel
    Left = 16
    Top = 16
    Width = 52
    Height = 13
    Caption = 'statusText'
    OnClick = statusTextClick
  end
  object gamePanel: TPanel
    Left = 128
    Top = 0
    Width = 417
    Height = 297
    TabOrder = 0
    OnMouseEnter = gamePanelEnter
    OnMouseLeave = gamePanelExit
    OnMouseMove = gamePanelMouseMove
    object board: TButton
      Left = 0
      Top = 0
      Width = 9
      Height = 65
      TabOrder = 0
    end
    object ball: TButton
      Left = 200
      Top = 80
      Width = 10
      Height = 10
      TabOrder = 1
    end
  end
  object frameControl: TTimer
    Interval = 1
    OnTimer = frameControlTimer
    Left = 16
    Top = 256
  end
end
