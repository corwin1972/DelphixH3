unit USnBuyBuild;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene, UConst;

type

  TSnBuyBuild= class (TDxScene)
  private
    fText:string;
  public
    CT, BU:integer;
    constructor Create(aCT, aBU:integer);
    procedure BtnBuy(Sender: TObject);
    procedure SnDraw(Sender: TObject);
  end;

var
  SnBuyBuild:TSnBuyBuild;

implementation

uses UMain, USnHero, USnSelect, USnDialog, UType, UCT;

{----------------------------------------------------------------------------}
Constructor TSnBuyBuild.create(aCT, aBU :integer);
var
  ResCount: integer;
  i,j,v,tp, a,b, x,y: integer;

begin
  inherited Create('SnBuyBuild');
  BU:=aBU;
  CT:=aCT;
  tp:=mCitys[CT].t;
  Left:=204;
  Top:=50;
  HintY:=Top+498;
  HintX:=Left+30;
  AddBackground('TPUBuild');
  AddTitleScene('Build ' + iBuild[tp][BU].name,20);
  fText:=iBuild[tp][BU].desc;

  ResCount:=0;
  for i:=0 to MAX_RES-1 do
    if  iBuild[tp][BU].resnec[i] > 0 then inc(ResCount);

  b:=3* (ResCount div 5);
  a:=ResCount-b;
  j:=0;
  for i:=0 to MAX_RES-1 do
  begin
    v:=iBuild[tp][BU].resnec[i];
    if v > 0
    then
    begin
      if j < a then
      begin
      x:=200 + (50*j - 25*a);
      y:=300 + 30 * (1- b div 3) ;
      end
      else
      begin
      x:=200  + (50*(j-a)-25*b);
      y:=300+ 60 ;
      end;
      AddSprPanel('RESOURCE',x, y);
      TDxWPanel(ObjectList[objectList.Count-1]).Tag:=i;
      AddLabel_Center(inttostr(v),x-5,y+35,40);
      inc(j);
    end;
  end;

  AddSprPanel('HALL'+TNext[tp],124, 50);
  TDxWPanel(ObjectList[objectList.Count-1]).Tag:=BU;
  if Cmd_CT_CanBuild(CT,BU) =1  then
    ObjectList[AddButton('IBY6432',37,435,BtnBuy)].name:='Build '+iBuild[tp][BU].name;
    ObjectList[AddButton('ICANCEL',283,435,BtnOK)].name:='Do not Build '+iBuild[tp][BU].name;
  UpdateColor(mPL,1);
  OnDraw:=SnDraw;
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyBuild.BtnBuy(Sender: TObject);
begin
  //Parent.AutoRefresh:=true;
  CloseScene;
  Parent.CloseScene;
  cmd_CT_BuyBuild(CT,BU);
end;
{----------------------------------------------------------------------------}
procedure TSnBuyBuild.SnDraw(sender: TObject);
var
  dt: cardinal;
  fRect: TRect;
begin
  ImageList.Items[Background].Draw(DxSurface, Left, Top, 0); //DXDraw.Surface
  ObjectList.DoDraw;
  with DxSurface.Canvas do   //DxDraw.Surface
  begin
    Brush.Style := bsClear;
    Font.Color := clwhite; //clText;
    Font.Size := 10;
    Font.Name:=H3Font; //'Arial';
    dt:=DT_WORDBREAK or DT_CENTER;
    frect:=rect(Left+40, Top+ 145, Left+360,Top+250);
    drawText(DxSurface.Canvas.Handle,Pchar(FText),length(FText),frect,dt);
    frect:=rect(Left+40, Top+ 235, Left+360,Top+330);
    drawText(DxSurface.Canvas.Handle,Pchar(mdialog.mes),length(mdialog.mes),frect,dt);
    Release;
  end;
end;
{----------------------------------------------------------------------------}
end.
