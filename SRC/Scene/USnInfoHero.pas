unit USnInfoHero;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnInfoHero= class (TDxScene)
  private
    DxO_Hero,
    DxO_Crea,
    DxO_PSkill,
    DxO_LuckMoral: integer;
  public
    constructor Create(SUB: boolean=false);
    procedure   Update(HE: integer);
  end;

var
  SnInfoHero:TSnInfoHero;

implementation

uses UMain, USnHero, UType, USnInfoRes;

{----------------------------------------------------------------------------}
constructor  TSnInfoHero.Create(SUB: boolean=false);
var
  i: integer;
begin
  inherited Create('SnInfoHero');

  Left:=605;
  Top:=389;
  AddBackground('HEROQVBK');

  DxO_Crea:=ObjectList.count;
  for i:=0 to 2 do AddSprPanel('CPRSMALL',46+36*i,84);
  for i:=0 to 3 do AddSprPanel('CPRSMALL',27+36*i,132);
  for i:=0 to 6 do TDxWPanel(Objectlist[DxO_Crea+i]).Tag:=2+2*i;
  for i:=0 to 2 do AddLabel_Center('0',45+36*i,117,33,8);
  for i:=0 to 3 do AddLabel_Center('0',27+36*i,165,33,8);

  DxO_PSkill:=ObjectList.count;
  for i:=0 to 3 do
    AddLabel_Center('0',73+28*i,62,25,8);
    AddLabel_Center('0',154,102,25,8);
  DxO_LuckMoral:=ObjectList.count;
  AddSPRPanel('ILCK22',14,13+89);
  AddSPRPanel('IMRL22',14,13+72);

  DxO_Hero:=ObjectList.count;
  AddSPRPanel('HPL',12,13);
  TDXWPanel(ObjectList[ObjectList.count-1]).Tag:=130;
  AddLabel('HeroName',81,13);
  if SUB then AddSubScene else AddPopScene;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoHero.Update(HE: integer);
var
  i: integer;
  CR, nCR: integer;
begin
  redraw:=true;
  UpdateColor(mHeros[HE].pid,1);
  with mHeros[HE] do
  begin
    TDXWPanel(ObjectList[DxO_Hero]).tag:=HE;
    TDXWlabel(ObjectList[DxO_Hero+1]).caption:=name + ' ' + inttostr(PSKA.mov) + '/' +  inttostr(PSKB.mov);
    TDXWLabel(ObjectList[DxO_PSkill+0]).caption:=inttostr(max(0,PSKB.att));
    TDXWLabel(ObjectList[DxO_PSkill+1]).caption:=inttostr(max(0,PSKB.def));
    TDXWLabel(ObjectList[DxO_PSkill+2]).caption:=inttostr(max(0,PSKB.pow));
    TDXWLabel(ObjectList[DxO_PSkill+3]).caption:=inttostr(max(0,PSKB.kno));
    TDXWLabel(ObjectList[DxO_PSkill+4]).caption:=inttostr(PSKA.ptm);
    TDXWPanel(ObjectList[DxO_LuckMoral]).tag:=  3+luck;
    TDXWPanel(ObjectList[DxO_LuckMoral+1]).tag:=3+moral;
    for i:=0 to MAX_ARMY do
    begin
      CR:=Armys[i].t;
      nCR:=Armys[i].n;
      if CR > -1
      then
      begin
        TDXWPanel(ObjectList[DxO_Crea+i]).tag:=CR+2;
        TDXWLabel(ObjectList[DxO_Crea+7+i]).caption:=inttostr(nCR);
      end
      else
      begin
        TDXWPanel(ObjectList[DxO_Crea+i]).tag:=0;
        TDXWLabel(ObjectList[DxO_Crea+7+i]).caption:='';
      end;
    end;
  end;
  show;
  Hint:='';
end;
{----------------------------------------------------------------------------}



end.
