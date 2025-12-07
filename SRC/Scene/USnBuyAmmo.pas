unit USnbuyAmmo;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls,DXWScroll, DXWScene;

type

  TSnBuyAmmo= class (TDxScene)
  private
    procedure SnChange(Sender: TObject);
    procedure SnDraw(Sender:TObject);
  public
    DxO_Scroll, DxO_Total:integer;
    CrMax: integer;
    CrCost:integer;
    Qty,Cost: integer;
    Constructor Create;
    procedure BtnBuy(Sender: TObject);
    procedure BtnMax(Sender: TObject);
  end;

var
  SnBuyAmmo:TSnBuyAmmo;

implementation

uses UMain, USnHero,  USnSelect, UType;


{----------------------------------------------------------------------------}
procedure TSnBuyAmmo.SnChange(Sender: TObject);
begin
  qty:=TDXWHzScroll(ObjectList[DxO_Scroll]).position;
  cost:=Qty*crCost;
  TDXWLabel(ObjectList[DxO_Total]).caption:=  inttostr(qty);
  TDXWLabel(ObjectList[DxO_Total]).caption:=inttostr(cost);
end;
{----------------------------------------------------------------------------}
Constructor TSnBuyAmmo.Create;
var
  DxO_CR, CR: integer;
begin
  //TODO check equipped Ammo before proposing new Ammo
  inherited Create('BuyAmmo');
  Left:=154;
  Top:=50;
  HintY:=Top+375;
  HintX:=Left+30;
  AddBackground('TPrcrt');
  AddPanel('TPSMITBK',140,61);
  AddTitleScene('Buy a new Ammo',20);

  //MO118_Catapult;
  CR:=MO119_Ballista;
  //MO120_FirstAidTent;
  //MO121_AmmoCart;

  CrMax:=1;
  Qty:=0;
  CrCost:=iCrea[CR].cost;
  Cost:=Qty*crCost;

  DxO_CR:=ObjectList.Add(TDXWPanel.Create(self));
  with TDXWPanel(ObjectList[DxO_CR]) do
  begin
    Name:=inttostr(CR);
    LoadUnit(CR,CR,ImageList);
    Image:=ImageList.Items.Find(inttostr(CR));
    Width:=Image.Width;
    Height:=Image.Height;
    Left:=182;
    Top:=-25;
    Surface:=DxSurface; // DXDraw.Surface;
  end;

  AddLabel_Center('Cost Per Ammo',66,224,94);
  AddLabel_Center('Available',    172,224,65);
  AddLabel_Center('Recruit',      247,224,65);
  AddLabel_Center('Total cost',   324,224,95);

  AddLabel_Center(inttostr(crCost),66,280,94);
  AddLabel_Center(inttostr(crMax), 172,246,65);

  DxO_Total:=ObjectList.count;
  AddLabel_Center(inttostr(Qty), 247,246,65);
  AddLabel_Center(inttostr(Cost),324,280,94);

  LoadBmp(imageList,'CrSCROLL');
  LoadSprite(ImageList,'IGPCRDIV');
  LoadSprite(ImageList,'IGPCRDIV');
  LoadBmp(ImageList,'iGPCrDSn');
  DxO_Scroll:=ObjectList.Add(TDXWHzScroll.Create(self));
  with TDXWHzScroll(ObjectList[DxO_Scroll]) do
  begin
    Image:=ImageList.Items.Find('CrSCROLL');
    Btn1Image:=ImageList.Items.Find('IGPCRDIV');
    Btn2Image:=ImageList.Items.Find('IGPCRDIV');
    ThumbImage:=ImageList.Items.Find('iGPCrDSn');
    Left:=328;
    Top:=329;
    Surface:=DxSurface; // DXDraw.Surface;
    visible:=true;
    Max:=CrMax;
    onChange:=SnChange;
  end;
  AddSprPanel('RESOURCE',100,245);
  TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=6;
  AddSprPanel('RESOURCE',356,245);
  TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=6;
  AddButton('IRCBTNS',136,312,BtnMax);
  AddButton('IBY6432',216,312,BtnBuy);          //IBY6432 ICANCEL
  AddButton('ICANCEL',296,312,BtnCancel);       //res=0 and quit
  AddFrame(100,120,190,80);
  AddFrame(96,75,66,223);
  AddFrame(96,75,324,223);
  AddFrame(65,40,172,223);
  AddFrame(65,40,247,223);
  UpdateColor(mPL,1);
  AddScene;
  OnDraw:=SnDraw;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyAmmo.BtnBuy(Sender: TObject);
begin
  mDialog.res:=Qty;   //should be selected AMMO
  Closescene;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyAmmo.SnDraw(sender : TObject);
begin
  if Background>-1
  then ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DoDraw;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyAmmo.BtnMax(Sender: TObject);
begin
  TDXWHzScroll(ObjectList[DxO_Scroll]).Position:=TDXWHzScroll(ObjectList[DxO_Scroll]).Max;
  SnChange(sender);
end;
{----------------------------------------------------------------------------}

end.
