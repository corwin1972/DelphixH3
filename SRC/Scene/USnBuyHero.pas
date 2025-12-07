unit USnBuyHero;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnBuyHero= class (TDxScene)
  private
    CT: integer;
    Slot:integer;
    DxO_Hero:integer;
  public
    constructor Create(aCT: integer);
    procedure BtnHero(Sender: TObject);
    procedure BtnBuy(Sender: TObject);
    procedure BtnPlayers(Sender: TObject);
  end;

var
  SnBuyHero:TSnBuyHero;

implementation

uses UMain, USnHero, USnGame, UPL, USnSelect, UType, USnPlayers, UCT, UHE;
{----------------------------------------------------------------------------}
Constructor TSnBuyHero.create(aCT: integer);
var
  s,t:string;
  HE,n:integer;
begin
  inherited Create('SnBuyHero');

  CT:=aCT;
  slot:=0;
  Left:=204;
  Top:=50;
  HintY:=Top+485;
  HintX:=Left+85;
  AddBackground('Tptavern');
  AddPanel('BCKTVRN',70,56);
  AddTitleScene('TAVERN' ,22);
  AddMemo(TxtRandTVRN[mData.rumor],37,195,320,200);
  AddLabel_Yellow('Heroes for Hire', 100, 275);
  DxO_Hero:=ObjectList.Count;

  AddSPRPanel('HPL',72,298,BtnHero);
  TDXWPanel(ObjectList[DxO_Hero]).tag:=mPlayers[mPL].TavHero[0];
  AddSprPanelSelectedImage(Objectlist.count-1,'TPTAVSEL');
  TDXWPanel(ObjectList[DxO_Hero]).selected:=true;

  AddSPRPanel('HPL',161,298,BtnHero);
  TDXWPanel(ObjectList[DxO_Hero+1]).tag:=mPlayers[mPL].TavHero[1];
  AddSprPanelSelectedImage(Objectlist.count-1,'TPTAVSEL');
  TDXWPanel(ObjectList[DxO_Hero+1]).selected:=false;

  HE:=mPlayers[mPL].TavHero[0];
  s:=mHeros[HE].name;
  n:=mHeros[HE].level;
  t:=inttostr(n)+ ' ' + mHeros[HE].classeName ;
  s:=s+ ' is a level ' + t;

  AddLabel(s,35,373);
  AddLabel('with ' + inttostr(cmd_HE_countART(HE)) + ' artefacts',35,390);
  AddLabel('2500',305,320);
  AddButton('TPTAV01',272,356,BtnBuy);
  if (mPlayers[mPL].Res[6] < 2500) or (mPlayers[mPL].nHero >= 8) or (mCitys[CT].VisHero <> -1)
  then TDXWPanel(ObjectList[ObjectList.count-1]).enabled:=false;
  AddButton('TPTAV02',22,428,BtnPlayers);
  AddButton('ICANCEL',310,429,BtnOK);
  UpdateColor(mPL,1);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyHero.BtnPlayers(Sender: TObject);
begin
  TSnPlayers.create;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyHero.BtnBuy(Sender: TObject);
const
  noday1: boolean = false;
begin
  if mPlayers[mPL].Res[6] < 2500 then exit;
  if mPlayers[mPL].nHero >= 8 then exit;
  if CT<0
  then
  begin
    CloseScene;
    Cmd_PL_BuyHero(mPL,slot,mOBJs[-CT].pos);
  end
  else
  begin
    if mCitys[CT].VisHero <> -1 then exit ;
    CloseScene;
    Cmd_CT_BuyHero(CT,slot);
  end;
  SnGame.AddHero(mPlayers[mPL].TavHero[slot]);
  mPlayers[mPL].TavHero[slot]:=Cmd_HE_NewHero(mCitys[CT].t,noday1);
  mDialog.res:=1;
end;

{----------------------------------------------------------------------------}
procedure TSnBuyHero.BtnHero(Sender: TObject);
var
  s,t:string;
  HE,n:integer;
begin
  slot:=Objectlist.DxO_MouseOver-DxO_Hero;
  HE:=mPlayers[mPL].TavHero[slot];
  //TDxWPanel(sender).Focused:=true;
  if TDxWPanel(TDXWPanel(ObjectList[DxO_Hero+slot])).selected
  then
    TSnHero.Create(HE,true)
  else
  begin
  TDxWPanel(TDXWPanel(ObjectList[DxO_Hero+slot])).selected:=true;
  TDxWPanel(TDXWPanel(ObjectList[DxO_Hero+(1-slot)])).selected:=false;
  s:=mHeros[HE].name;
  n:=mHeros[HE].level;
  t:=inttostr(n)+ ' ' + mHeros[HE].classeName ;
  s:=s+ ' is a level ' + t;
  TDXWLabel(ObjectList[DxO_Hero+2]).caption:=s;
  TDXWLabel(ObjectList[DxO_Hero+3]).caption:='with ' + inttostr(cmd_HE_countART(HE)) + ' artefacts';
  end;
end;
end.
