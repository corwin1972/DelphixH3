unit USnBuyCrea;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls,DXWScroll, DXWScene;

type

  TSnBuyCrea= class (TDxScene)
  private
    procedure SnChange(Sender: TObject);
    procedure SnDraw(Sender:TObject);
  public
    DxO_Scroll, DxO_Total:integer;
    CrMax: integer;
    CrCost:integer;
    Qty,Cost: integer;
    Constructor Create(CR,NB:integer);
    procedure BtnBuy(Sender: TObject);
    procedure BtnMax(Sender: TObject);
  end;

var
  SnBuyCrea:TSnBuyCrea;

implementation

uses UMain, USnHero,  USnSelect, UType;


{----------------------------------------------------------------------------}
procedure TSnBuyCrea.SnChange(Sender: TObject);
begin
  qty:=TDXWHzScroll(ObjectList[DxO_Scroll]).position;
  cost:=Qty*crCost;
  TDXWLabel(ObjectList[DxO_Total]).caption:=  inttostr(qty);
  TDXWLabel(ObjectList[DxO_Total-1]).caption:=inttostr(CrMax-qty);
  TDXWLabel(ObjectList[DxO_Total+1]).caption:=inttostr(cost);
end;
{----------------------------------------------------------------------------}
Constructor TSnBuyCrea.Create(CR,NB:integer);
const
 tn: array [0..7] of string =('CAS','RAM','TOW','INF','NEC','DUN','STR','FOR');
var
  id,DxO,i: integer;
begin
  inherited Create('SnBuyCrea');
  Left:=154;
  Top:=50;
  HintY:=Top+375;
  HintX:=Left+30;
  AddBackground('TPrcrt');
  AddPanel('TPCAS'+tn[CR div 14],190,80);
  CrMax:=NB;
  Qty:=0;
  CrCost:=iCrea[CR].cost;
  Cost:=Qty*crCost;

  //AddSprPanel(iDef[946+CrId].name,200,120);

  ObjectList.Add(TDXWPanel.Create(self));
  DxO:=ObjectList.Count-1;

    with TDXWPanel(ObjectList[DxO]) do
    begin
      Name:=inttostr(CR);
      LoadUnit(CR,CR,ImageList);
      Image:=ImageList.Items.Find(inttostr(CR));
      Width:=Image.Width;
      Height:=Image.Height;
      Left:=182;
      Top:=-25;
      Surface:=DxSurface;   //DXDraw.Surface;
  end;

  AddTitleScene('Recruit ' + iCrea[CR].name,20);
  AddLabel_Center('Cost Per Troop',66,224,94);
  AddLabel_Center('Available',    172,224,65);
  AddLabel_Center('Recruit',      247,224,65);
  AddLabel_Center('Total cost',   324,224,95);

  AddLabel_Center(inttostr(crCost),66,280,94);
  AddLabel_Center(inttostr(NB), 172,246,65);

  DxO_Total:=ObjectList.count;
  AddLabel_Center(inttostr(Qty), 247,246,65);
  AddLabel_Center(inttostr(Cost),324,280,94);

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
    Left:=328;
    Top:=330;
    Surface:=DxSurface; // DXDraw.Surface;
    visible:=true;
    Max:=NB;
    onChange:=SnChange;
  end;
  AddSprPanel('RESOURCE',100,245);
  TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=6;
  AddSprPanel('RESOURCE',356,245);
  TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=6;
  AddButton('IRCBTNS',136,312,BtnMax);
  if (NB < 1) then TDXWPanel(ObjectList[ObjectList.count-1]).enabled:=false;
  AddButton('IBY6432',216,312,BtnBuy);          //IBY6432 ICANCEL
  if (NB < 1) then TDXWPanel(ObjectList[ObjectList.count-1]).enabled:=false;
  AddButton('ICANCEL',296,312,BtnCancel);       //res=0 and quit
  DxO:=ObjectList.count;
  AddFrame(100,120,190,80);
  AddFrame(96,75,66,223);
  AddFrame(96,75,324,223);
  AddFrame(65,40,172,223);
  AddFrame(65,40,247,223);
  for i:=0 to 4 do
  TDxWFrame(ObjectList[DxO+i]).selected:=true;
  UpdateColor(mPL,1);
  AddScene;
  OnDraw:=SnDraw;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyCrea.BtnBuy(Sender: TObject);
begin
  mDialog.res:=Qty;
  Closescene;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyCrea.SnDraw(sender : TObject);
begin
  if Background>-1
  then ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DoDraw;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyCrea.BtnMax(Sender: TObject);
begin
  TDXWHzScroll(ObjectList[DxO_Scroll]).Position:=TDXWHzScroll(ObjectList[DxO_Scroll]).Max;
  SnChange(sender);
end;


end.
