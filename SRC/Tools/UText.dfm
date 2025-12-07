object TextFrm: TTextFrm
  Left = 156
  Top = 120
  Width = 800
  Height = 600
  Caption = 'TextFrm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Split: TSplitter
    Left = 101
    Top = 0
    Width = 3
    Height = 542
    Cursor = crHSplit
  end
  object fText: TRichEdit
    Left = 104
    Top = 0
    Width = 680
    Height = 542
    Align = alClient
    HideScrollBars = False
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object fList: TFileListBox
    Left = 0
    Top = 0
    Width = 101
    Height = 542
    Align = alLeft
    ItemHeight = 13
    Mask = '*.dpr;*.pas;*.txt;*.log'
    TabOrder = 1
    OnClick = fListClick
  end
  object MainMenu1: TMainMenu
    Left = 152
    Top = 144
    object MnFile: TMenuItem
      Caption = 'File'
      object MnOpen: TMenuItem
        Caption = 'Open'
        OnClick = MnOpenClick
      end
      object MnSave: TMenuItem
        Caption = 'Save'
        OnClick = MnSaveClick
      end
    end
  end
end
