unit USnSepCrea;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls,DXWScroll, DXWScene;

type

  TSnSepCrea= class (TDxScene)
  private
    procedure SnChange(Sender: TObject);
  public
    DxO_Scroll, DxO_Total: integer;
    CrMax: integer;
    Qty: integer;
    constructor Create(CrId,CrQtyL,CrQtyR:integer);
    procedure BtnCancel(Sender: TObject);
    procedure BtnSplit(Sender: TObject);
  end;

var
  SnSepCrea: TSnSepCrea;

implementation

uses UMain, USnHero, USnSelect, UType;

{----------------------------------------------------------------------------}
procedure TSnSepCrea.SnChange(Sender: TObject);
begin
  qty:=TDXWHzScroll(ObjectList[DxO_Scroll]).position;
  TDXWLabel(ObjectList[DxO_Total]).caption:=  inttostr(CrMax-qty);
  TDXWLabel(ObjectList[DxO_Total+1]).caption:=inttostr(qty);
end;
{----------------------------------------------------------------------------}
Constructor TSnSepCrea.Create(CrId,CrQtyL,crQtyR:integer);
const
  tn: array [0..7] of string =('CAS','RAM','TOW','INF','NEC','DUN','STR','FOR');
begin
  inherited Create('SnSepCrea');
  Left:=204;
  Top:=50;
  HintY:=Top+315;
  HintX:=Left+20;
  AddBackground('GPUCRDIV');
  AddPanel('CRBKG'+tn[crId div 14], 20,54);
  AddPanel('CRBKG'+tn[crId div 14],177,54);
  CrMax:=CrQtyL+CrQtyR;
  Qty:=CrQtyL;

  AddSprPanel(iDef[946+CrId].name,28,82);
  AddSprPanel(iDef[946+CrId].name,190,82);
  AddTitleScene('Split ' + iCrea[CrId].name,20);

  DxO_Total:=ObjectList.count;
  AddLabel_Yellow(inttostr(Qty), 58,232);
  AddLabel_Yellow(inttostr(Crmax-Qty), 218,232);
  LoadBmp(imageList,'SepSCROLL');
  LoadSprite(ImageList,'IGPCRDIV');
  LoadSprite(ImageList,'IGPCRDIV');
  LoadBmp(ImageList,'iGPCrDSn');
  DxO_Scroll:=ObjectList.Add(TDXWHzScroll.Create(self));

  with TDXWHzScroll(ObjectList[DxO_Scroll]) do
  begin
    Image:=ImageList.Items.Find('SepSCROLL');
    Btn1Image:=ImageList.Items.Find('IGPCRDIV');
    Btn2Image:=ImageList.Items.Find('IGPCRDIV');
    ThumbImage:=ImageList.Items.Find('iGPCrDSn');
    Left:=224;
    Top:=244;
    Surface:=DxSurface; // DXDraw.Surface;
    visible:=true;
    Max:=CrqtyL+CrQtyR;
    position:=CrQtyR;
    onChange:=SnChange;
  end;

  AddButton('IOKAY',21,264,BtnSplit);
  AddButton('ICANCEL',214,264,BtnCancel);  //res=0 and quit
  UpdateColor(mPL,1);
  addScene;
end;
{----------------------------------------------------------------------------}
procedure TSnSepCrea.BtnCancel(Sender: TObject);
begin
  mDialog.res:=0;
  Closescene;
end;
{----------------------------------------------------------------------------}
procedure TSnSepCrea.BtnSplit(Sender: TObject);
begin
  mDialog.res:=Qty;
  Closescene;
end;

end.
