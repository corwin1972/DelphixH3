unit USnBuyForge;
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnBuyForge= class (TDxScene)
  private
    CT,AR,HE,CR: integer;
    canBuy: boolean;
    procedure define_ammo(aCT: integer);
  public
    constructor Create(aCT:integer);
    procedure BtnBuy(Sender: TObject);
  end;

var
  SnBuyForge:TSnBuyForge;

implementation

uses UMain, USnHero,  USnSelect, UType, UHE, UCT;


procedure TSnBuyForge.define_ammo(aCT: integer);
begin
  CT:= aCT;
  case mCitys[CT].t of
    0:  AR:=4;  //balliste
    1:  AR:=6;  //dispensaire
    2:  AR:=5;  //chariot
    3:  AR:=6;  //dispensaire
    4:  AR:=6;  //balliste
    5:  AR:=4;  //balliste
    6:  AR:=4;  //balliste
    7:  AR:=6;  //dispensaire
  end;

  //MO118_Catapult;
  case mCitys[CT].t of
    0:  CR:=MO119_Ballista;       //balliste
    1:  CR:=MO120_FirstAidTent;   //dispensaire
    2:  CR:=MO121_AmmoCart;       //chariot
    3:  CR:=MO120_FirstAidTent;   //dispensaire
    4:  CR:=MO120_FirstAidTent;   //dispensaire
    5:  CR:=MO119_Ballista;       //balliste
    6:  CR:=MO119_Ballista;       //balliste
    7:  CR:=MO120_FirstAidTent;   //dispensaire
  end;


  //get ammo type
  //catapult    112   3
  //balliste    113   4
  //dispensaire 114   6
  //chariot     115   5

  CanBuy:= false;
  HE:= mCitys[CT].visHero;
  if HE > -1 then
    if  Cmd_HE_FindART(HE,AR) = 0 then
      if mPlayers[mPL].res[6] > 1000 then   CanBuy:= true;

end;

Constructor TSnBuyForge.create(aCT:integer);
var
  id,t,imgid: integer;
begin
  inherited Create('BuyForge');
  define_ammo(aCT);
  Left:=204;
  Top:=50;
  HintY:=Top+365;
  HintX:=Left+65;
  AddBackground('Tpsmith');
  AddPanel('TPSMITBK',64,50);
  AddTitleScene('Buy a new blacksmith',20);
  AddLabel('Ressource cost',125,211,10);
  AddSPRPanel('RESOURCE',145,240);
  TDXWPanel(ObjectList[ObjectList.count-1]).tag:=6;
  AddLabel('1000',150,285,10);

  AddButton('IBY6432',42,311,BtnBuy);
  TDXWButton(ObjectList[ObjectList.count-1]).enabled:=CanBuy;
  AddButton('ICANCEL',224,312,BtnOK);

  ObjectList.Add(TDXWPanel.Create(self));
  id:=ObjectList.Count-1;
  with TDXWPanel(ObjectList[id]) do
  begin
    Name:='Forge';
    imgid:=LoadUnit(CR,CR,ImageList);
    Image:=ImageList.Items[imgid];
    Width:=Image.Width;
    Height:=Image.Height;
    Left:=150;
    Top:=-30;
    Surface:=DxSurface;
  end;

  UpdateColor(mPL,1);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyForge.BtnBuy(Sender: TObject);
begin
  cmd_HE_BuyForge(mCitys[CT].visHero,AR);
  mDialog.res:=1;
  Closescene;
end;
{----------------------------------------------------------------------------}


end.
