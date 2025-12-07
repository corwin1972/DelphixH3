unit USnInfoPlayer;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type
  TSnInfoPlayer= class (TDxScene)
  private
    DxO_Flag: integer;
    DxO_City: integer;
  public
    Constructor Create(SUB: boolean=false);
    procedure Update(PL: integer);
  end;

implementation

uses UMain, USnHero, UType, UPL;

{----------------------------------------------------------------------------}
Constructor TSnInfoPlayer.Create(SUB: boolean);
var
  i,j:integer;
begin
  inherited Create('SnInfoPlayer');
  Left:=614;
  Top:=400;
  AddBackground('ADSTATIN');

  DxO_City:=ObjectList.count;
  for i:=0 to 3 do
  begin
    AddSPRPanel('ITMTL',7+42*i,12);
    AddLabel('',22+42*i,56);
    TDXWPanel(ObjectList[DxO_City+2*i]).tag:=i;
  end;
  AddLabel('Allies',11,104);
  AddLabel('Enemies',11,132);
  DxO_Flag:=ObjectList.count;
  for j:=0 to 1 do
  for i:=0 to MAX_PLAYER-1 do
    AddSPRPanel('ITGFLAGS',65 + 16* i,102+32*j);
   if SUB then AddSubScene else AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoPlayer.Update(PL: integer);
var
  i, p, allies, enemies:integer;
begin
  for i:=0 to 3 do
  TDXWPanel(ObjectList[DxO_City+2*i+1]).caption:=Cmd_PL_CountCT(PL,i);
  allies:=0;
  enemies:=0;
  for p:=0 to MAX_PLAYER-1 do
  begin
    if mPlayers[p].isAlive then
    begin
      if mPlayers[p].team=mPlayers[PL].team then
      begin
        TDXWPanel(ObjectList[DxO_Flag+allies]).visible:=true;
        TDXWPanel(ObjectList[DxO_Flag+allies]).tag:=p;
        inc(allies)
      end
      else
      begin
        TDXWPanel(ObjectList[DxO_Flag+MAX_PLAYER+enemies]).visible:=true;
        TDXWPanel(ObjectList[DxO_Flag+MAX_PLAYER+enemies]).tag:=p;
        inc(enemies)
      end;
    end;
  end;

  for p:=allies to MAX_PLAYER-1 do
    TDXWPanel(ObjectList[DxO_Flag+p]).visible:=false;
  for p:=enemies to MAX_PLAYER-1 do
    TDXWPanel(ObjectList[DxO_Flag+MAX_PLAYER+p]).visible:=false;
  Show;
end;
{----------------------------------------------------------------------------}


end.
