unit USnInfoTown;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnInfoTown= class (TDxScene)
  private
    DxO_CR: integer;
   public
    constructor Create(SUB: boolean=false);
    procedure Update(CT: integer);
  end;

var
  SnInfoTown:TSnInfoTown;

implementation

uses UMain, USnHero,  UType, USnInfoRes, UCT;

constructor TSnInfoTown.Create(SUB: boolean=false);
var
  i: integer;
begin
  inherited Create('SnInfoTown');
  Left:=605;
  Top:=389;
  AddBackground('TOWNQVBK');
  AddSPRPanel('ITPT',13,13);
  AddLabel('TownName',81,13);
  AddSPRPanel('ITMTLS',76,42);
  AddSPRPanel('ITMCLS',114,42);
  AddLabel('500',157,63);
  DxO_CR:=ObjectList.count;
  for i:=0 to 2 do AddSprPanel('CPRSMALL',46+36*i,84);
  for i:=0 to 3 do AddSprPanel('CPRSMALL',27+36*i,132);
  for i:=0 to 6 do TDxWPanel(Objectlist[DxO_CR+i]).Tag:=2+2*i;
  for i:=0 to 2 do AddLabel('0',54+36*i,116);
  for i:=0 to 3 do AddLabel('0',35+36*i,164);
  AddPanel('TOWNQKGH',158,87);
  if SUB
  then AddSubScene
  else AddPopScene;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoTown.Update(CT: integer);
var
  crId, crqty, i: integer;
begin
  //CityId:=mPlayers[mDate.pid].ActiveTown;
   redraw:=true;
   UpdateColor(mCitys[CT].pid,1);

  with mCitys[CT] do
  begin
    TDXWPanel(ObjectList[ObjectList.count-1]).visible:=(GarHero <> -1);
    TDXWPanel(ObjectList[0]).tag:=2*t;
    TDXWlabel(ObjectList[1]).caption:=Name; // + ' - ' + inttostr(cityid);
    TDXWPanel(ObjectList[2]).tag:=cmd_CT_CityLevel(CT);
    TDXWPanel(ObjectList[3]).tag:=cmd_CT_FortLevel(CT)-1;
    TDXWlabel(ObjectList[4]).caption:=inttostr(cmd_CT_Income(CT));
    for i:=0 to MAX_ARMY do
    begin
      crId:=GarArmys[i].t;
      crqty:=GarArmys[i].n;
      if crId > -1
      then
      begin
        TDXWPanel(ObjectList[DxO_CR+i]).tag:=Crid+2;
        TDXWLabel(ObjectList[DxO_CR+7+i]).caption:=inttostr(Crqty);
      end
      else
      begin
        TDXWPanel(ObjectList[DxO_CR+i]).tag:=0;
        TDXWLabel(ObjectList[DxO_CR+7+i]).caption:='';
      end;

    end;
  end;
  visible:=true;
end;
{----------------------------------------------------------------------------}

end.
