unit USnBuyRes;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScroll, DXWScene;

type

  TSnBuyRes= class (TDxScene)
  private
    DxO_Res, DxO_Scroll, DxO_Sell,  DxO_Buy, DxO_SellPic, DxO_BuyPic: integer;
    DxO_Info,DxO_TotalMkt: integer;
  public
    qty, resId:integer;
    BRes,SRes : integer;
    constructor Create;
    procedure SnChange(Sender: TObject);
    procedure BtnAchat(Sender: TObject);
    procedure BtnMax(Sender: TObject);
    procedure BtnVRes(Sender: TObject);
    procedure BtnARes(Sender: TObject);
    procedure Update;
    procedure ComputeRate;
    procedure PrepareTrade;
    procedure HideTrade;
    procedure ShowTrade;
  end;

var
  SnBuyRes:TSnBuyRes;

implementation

uses UMain, USnHero,  USnSelect, UPL, UType;

var
 change: array [0..6] of real;

{    wd,   me,   st,   sf,   cr,   ge,   go
0    -1,   20,   10,   20,   20,   20, =>25
1     5,   -1,    5,   10,   10,   10, =>50
2    10,   20,   -1,   20,   20,   20, =>25
3     5,   10,    5,   -1,   10,   10, =>50
4     5,   10,    5,   10,   -1,   10, =>50
5     5,   10,    5,   10,   10,   -1, =>50
6  2500, 5000, 2500, 5000, 5000, 5000,   -1
}

const
  cost: array [0..6] of integer = (25,50,25,50,50,50,1);

{----------------------------------------------------------------------------}
Constructor TSnBuyRes.create;
var
  i: integer;
begin
  inherited Create('SnBuyRes');

  Left:=90;
  Top:=0;
  HintY:=Top+545;
  HintX:=Left+45;
  AddBackground('TPMRKRES');
  AddTitleScene('MarketPlace',18);

  DxO_Res:=ObjectList.count;
  AddLabel_Center('',49,229,50);
  AddLabel_Center('',133,229,50);
  AddLabel_Center('',217,229,50);
  AddLabel_Center('',49,308,50);
  AddLabel_Center('',133,308,50);
  AddLabel_Center('',217,308,50);
  AddLabel_Center('',133,388,50);
  AddLabel_Center('',335,229,50);
  AddLabel_Center('',421,229,50);
  AddLabel_Center('',503,229,50);
  AddLabel_Center('',337,308,50);
  AddLabel_Center('',421,308,50);
  AddLabel_Center('',503,308,50);
  AddLabel_Center('',421,388,50);

  DxO_SellPic:=ObjectList.count;
  AddSPRPanel('RESOURCE',56,191, BtnVRes);
  AddSPRPanel('RESOURCE',139,191,BtnVRes);
  AddSPRPanel('RESOURCE',222,191,BtnVRes);
  AddSPRPanel('RESOURCE',56,270, BtnVRes);
  AddSPRPanel('RESOURCE',139,270,BtnVRes);
  AddSPRPanel('RESOURCE',222,270,BtnVRes);
  AddSPRPanel('RESOURCE',139,350,BtnVRes);

  DxO_BuyPic:=ObjectList.count;
  AddSPRPanel('RESOURCE',344,191,BtnARes);
  AddSPRPanel('RESOURCE',429,191,BtnARes);
  AddSPRPanel('RESOURCE',510,191,BtnARes);
  AddSPRPanel('RESOURCE',344,270,BtnARes);
  AddSPRPanel('RESOURCE',429,270,BtnARes);
  AddSPRPanel('RESOURCE',510,270,BtnARes);
  AddSPRPanel('RESOURCE',429,350,BtnARes);

  for i:=0 to 13 do
  begin
    TDXWPanel(ObjectList[DxO_Res+14+i]).tag:=(i mod 7);
  end;

  DxO_TotalMkt:=ObjectList.count;
  AddLabel_Center('Kingdom Ressource',30,142,250);
  DxO_Info:=ObjectList.count;
  AddMemo('Please inspect our fine wares',315,70,250,200);
  LoadBmp(imageList,'CrSCROLL');
  LoadSprite(ImageList,'IGPCRDIV');
  LoadSprite(ImageList,'IGPCLDIV');
  LoadBmp(ImageList,'iGPCrDSn');
  DxO_Scroll:=ObjectList.Add(TDXWHzScroll.Create(self));
  with TDXWHzScroll(ObjectList[DxO_Scroll]) do
  begin
    Image:=ImageList.Items.Find('CrSCROLL');
    Btn1Image:=ImageList.Items.Find('IGPCRDIV');
    Btn2Image:=ImageList.Items.Find('IGPCLDIV');
    ThumbImage:=ImageList.Items.Find('iGPCrDSn');
    Left:=319;
    Top:=490;
    Surface:=DxSurface;
    visible:=true;
    Max:=5;
    onChange:=SnChange;
  end;

  DxO_Sell:=ObjectList.count;
  AddLabel_Center('LblVente',49,448,50);
  AddLabel_Center('LblQtV',133,496,50);
  AddSPRPanel('RESOURCE',141,455);
  AddPanel('TPMRKSE1',134,452);
  TDXWPanel(ObjectList[ObjectList.Count-1]).Visible:=false;

  DxO_Buy:=ObjectList.count;
  AddLabel_Center('LblAchat',510,448,50);
  AddLabel_Center('LblQtA',421,496,50);
  AddSPRPanel('RESOURCE',429,455);
  AddPanel('TPMRKSE1',134,452);
  TDXWPanel(ObjectList[ObjectList.Count-1]).Visible:=false;

  AddButton('IRCBTNS',228,520,BtnMax);
  AddButton('TPMRKB',309,520,BtnAchat);
  AddButton('IOK6432',495,520,BtnOK);
  AddLabel_Center('Available for Trade',316,142,250);
  BRes:=-1;
  SRes:=-1;
  UpdateColor(mPL,1);
  Update;
  AddScene;
  HideTrade;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyRes.Update;
var
  i: integer;
begin
  // update available ressource
  for i:=0 to 6 do
  begin
    TDXWLabel(ObjectList[DxO_Res+i]).caption:=inttostr(mPlayers[mPL].Res[i]);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyRes.BtnVRes(Sender: TObject);
begin
  sRes:=TDXWPanel(sender).ListId-DxO_SellPic;
  TDXWPanel(ObjectList[DxO_Sell+3]).left:= TDXWPanel(ObjectList[DxO_SellPic+sRes]).left-20;
  TDXWPanel(ObjectList[DxO_Sell+3]).top:=  TDXWPanel(ObjectList[DxO_SellPic+sRes]).top-12;
  TDXWPanel(ObjectList[DxO_Sell+3]).Visible:=true;
  TDXWLabel(ObjectList[DxO_Res+7+sRes]).caption:='n/a';
  ComputeRate;
  if bres <> -1 then PrepareTrade;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyRes.BtnARes(Sender: TObject);
begin
  bRes:=TDXWPanel(sender).listid-DxO_BuyPic;
  TDXWPanel(ObjectList[DxO_Buy+3]).left:= TDXWPanel(ObjectList[DxO_BuyPic+bRes]).left-20;
  TDXWPanel(ObjectList[DxO_Buy+3]).top:=  TDXWPanel(ObjectList[DxO_BuyPic+bRes]).top-12;
  TDXWPanel(ObjectList[DxO_Buy+3]).Visible:=true;
  ComputeRate;
  if sRes <> -1 then PrepareTrade;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyRes.BtnAchat(Sender: TObject);
var
  vres,ares: integer;
begin
  mPlayers[mPL].res[bRes]:=mPlayers[mPL].res[bRes]+qty ;
  mPlayers[mPL].res[sRes]:=mPlayers[mPL].res[sRes]- round(qty /  change[bRes]);
  Update;
  ComputeRate;
  PrepareTrade;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyRes.BtnMax(Sender: TObject);
begin
  TDXWHzScroll(ObjectList[DxO_Scroll]).position:=TDXWHzScroll(ObjectList[DxO_Scroll]).Max;
  SnChange(Sender);
end;
{----------------------------------------------------------------------------}
procedure TsnBuyRes.SnChange(Sender: TObject);
begin
  qty:=TDXWHzScroll(ObjectList[DxO_Scroll]).position;
  TDXWLabel(ObjectList[DxO_Buy+1]).caption:=inttostr(qty);
  TDXWLabel(ObjectList[DxO_Sell+1]).caption:=inttostr(round(qty /change[bRes]));
end;
{----------------------------------------------------------------------------}
procedure TSnBuyRes.ComputeRate;
var
  Ok: boolean;
  r, nb: integer;
begin
  nb:=Cmd_PL_Market(mPL); // EdQtyMkt.Value;//1+random(6); //:=Player.nbmarket;

  for r:=0 to 5 do
    change[r]:=((1+nb) / 2)/round(10* cost[r]/cost[sRes]);
    change[6]:=((1+nb) / 2)*cost[sRes];
  for r:=0 to 5 do
    TDXWLabel(ObjectList[DxO_Res+7+r]).caption:='1 / ' + inttostr(round(1 / change[r]));
    TDXWLabel(ObjectList[DxO_Res+7+6]).caption:=inttostr(round(change[6]));

  TDXWLabel(ObjectList[DxO_Res+7+sRes]).caption:='N/A';

end;
{----------------------------------------------------------------------------}
procedure TSnBuyRes.HideTrade;
begin
  TDXWLabel(ObjectList[DxO_Sell]).visible:=false;
  TDXWLabel(ObjectList[DxO_Sell+1]).visible:=false;
  TDXWPanel(ObjectList[DxO_Sell+2]).visible:=false;
  TDXWLabel(ObjectList[DxO_Buy]).visible:=false;
  TDXWPanel(ObjectList[DxO_Buy+2]).visible:=false;
  TDXWLabel(ObjectList[DxO_Buy+1]).visible:=false;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyRes.ShowTrade;
begin
  TDXWLabel(ObjectList[DxO_Sell]).visible:=true;
  TDXWLabel(ObjectList[DxO_Sell+1]).visible:=true;
  TDXWPanel(ObjectList[DxO_Sell+2]).visible:=true;
  TDXWLabel(ObjectList[DxO_Buy]).visible:=true;
  TDXWLabel(ObjectList[DxO_Buy+1]).visible:=true;
  TDXWPanel(ObjectList[DxO_Buy+2]).visible:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyRes.PrepareTrade;
var
  CanTrade: boolean;
  nb: integer;
begin
  TDXWLabel(ObjectList[DxO_Sell]).caption:=iRes[sres].name;
  TDXWLabel(ObjectList[DxO_Sell+1]).caption:='0';
  TDXWPanel(ObjectList[DxO_Sell+2]).tag:=sRes;
  TDXWLabel(ObjectList[DxO_Buy]).caption:=iRes[bRes].name;
  TDXWLabel(ObjectList[DxO_Buy+1]).caption:='0';
  TDXWPanel(ObjectList[DxO_Buy+2]).tag:=bRes;
  CanTrade:=not(bRes=sRes);

  if CanTrade then
  begin
    qty:=0;
    TDXWHzScroll(ObjectList[DxO_Scroll]).position:=0 ;
    TDXWHzScroll(ObjectList[DxO_Scroll]).Max:=trunc(mPlayers[mPL].res[sRes] *  change[bRes]);
    TDXWHzScroll(ObjectList[DxO_Scroll]).FMinChange:=Max(round(change[bRes]), 1) ;
    if bRes=6
    then
    TDXWLabel(ObjectList[DxO_Info]).Caption:=format('Je peux vous offrir %d pièces d''%s' + ' pour 1 unité de %s',
       [round(change[bRes]), iRes[bRes].name, iRes[sRes].name])
    else
    TDXWLabel(ObjectList[DxO_Info]).Caption:=format('Je peux vous offrir 1 unité de %s' + ' pour %d unités de %s',
       [iRes[bRes].name,round(1/change[bRes]),iRes[sRes].name]);

    ShowTrade;
  end
  else
  begin
    TDXWLabel(ObjectList[DxO_Info]).Caption:='Select one of our fine Goodies';
    HideTrade;
  end;
end;
{----------------------------------------------------------------------------}


end.
