unit UText;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus, FileCtrl;

type
  TTextFrm = class(TForm)
    fText: TRichEdit;
    fList: TFileListBox;
    Split: TSplitter;
    MainMenu1: TMainMenu;
    MnFile: TMenuItem;
    MnOpen: TMenuItem;
    MnSave: TMenuItem;
    procedure fListClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShowDir(aDir: string);
    procedure MnOpenClick(Sender: TObject);
    procedure MnSaveClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  TextFrm: TTextFrm;

implementation

{$R *.DFM}


procedure TTextFrm.fListClick(Sender: TObject);
begin
  fText.PlainText := False;
  fText.Lines.LoadFromFile(fList.Filename);
end;

procedure TTextFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fText.Lines.Clear;
end;

procedure TTextFrm.FormShowDir(aDir: string);
begin
  fList.Directory:=aDir;
  if fList.SelCount <> 0 then ftext.lines.LoadFromFile(fList.Items[0]);
  ShowModal;
end;

procedure TTextFrm.MnOpenClick(Sender: TObject);
begin
  // blabla
end;

procedure TTextFrm.MnSaveClick(Sender: TObject);
begin
  ftext.lines.SaveToFile(fList.FileName);
end;

end.
