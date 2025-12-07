unit USnMenu;

interface

uses
  Classes, Controls, DXWScene;

type
  TSnMenu= class (TDxScene)
  private
    procedure BtnNewGame(Sender: TObject);
    procedure BtnSelect(Sender: TObject);
    procedure BtnQuit(Sender: TObject);
    procedure ShowHintClick(Sender: TObject); override;
  public
    constructor Create;
  end;

implementation

uses Forms, USnSelect, USnLoadingMap, USnGame, UType, UsnDialog , DXWControls;

{----------------------------------------------------------------------------}
constructor TSnMenu.Create;
begin
  inherited Create('SnMenu');
  FText:=TxtHelp;
  AddBackground('Title');
  AddButton('MMENUNG',551,  5,BtnNewGame,3);
  AddButton('MMENULG',551,111,BtnSelect,4);
  AddButton('MMENUHS',551,222,BtnQuit,5);
  AddButton('MMENUCR',581,338,BtnQuit,6);
  AddButton('MMENUQT',611,452,BtnQuit,7);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnMenu.BtnNewGame(Sender: TObject);
begin
  mHeader.custom:=false;
  mData.fName:='1game.h3m';
  mData.loadStep:=-1;
  SnGame:=TSnGame.Create;
end;
{----------------------------------------------------------------------------}
procedure TSnMenu.BtnSelect(Sender: TObject);
begin
  SnSelect:=TSnSelect.Create;
end;
{----------------------------------------------------------------------------}
procedure TSnMenu.BtnQuit(Sender: TObject);
begin
  Application.Terminate;
end;

{----------------------------------------------------------------------------}
procedure TSnMenu.ShowHintClick(Sender: TObject);
begin
   processPreGameInfo(TDxwObject(sender).name);   // to have neutral blue dialog
end;
end.
