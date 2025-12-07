unit USnBuyShip;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnBuyShip= class (TDxScene)
  private
    FAnim: integer;
  public
    DxO_Ship:integer;
    constructor Create;
    procedure SnDraw(Sender:TObject);
    procedure BtnBuy(Sender: TObject);
  end;

var
  SnBuyShip:TSnBuyShip;

implementation

uses UMain, USnHero, USnSelect, UType, USnGame;

Constructor TSnBuyShip.create;
begin
  inherited Create('SnBuyShip');

  FAnim:=0;
  Left:=204;
  Top:=50;
  HintY:=Top+365;
  HintX:=Left+65;
  AddBackground('TPSHIP');
  DxO_Ship:=ObjectList.Count;
  AddPanel('AB01_',114,80);
  //TDXWPanel(ObjectList[ObjectList.count-1]).tag:=10;
  AddTitleScene('Build a new Ship',20);
  AddLabel('Ressource cost',120,211,10);
  AddSPRPanel('RESOURCE',95,248);
  TDXWPanel(ObjectList[ObjectList.count-1]).tag:=6;
  AddLabel('1000',100,285,10);

  AddSPRPanel('RESOURCE',195,248);
  TDXWPanel(ObjectList[ObjectList.count-1]).tag:=0;
  AddLabel('10',200,285,10);

  AddButton('IBY6432',42,311,BtnBuy);
  AddButton('ICANCEL',224,312,BtnOK);
  UpdateColor(mPL,1);
  OnDraw:=SnDraw;
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyShip.BtnBuy(Sender: TObject);
begin
  mDialog.res:=1;
  Closescene;
end;
{----------------------------------------------------------------------------}
procedure TSnBuyShip.SnDraw(Sender:TObject);
var
  i,j:integer;
begin
  ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  for i:=0 to 3 do
  for j:=0 to 2 do
  SnGame.ImageList.Items.Find('WATRTL').Draw(DxSurface, Left+100+32*i, Top+69+j*32, 4*i+4*j+88);
  ObjectList.DoDraw;
  //FAnim:=(FAnim+1) mod 70 ;
  //TDXWPanel(ObjectList[DxO_Ship]).tag:=21+ (fanim div 10) ;
end;

end.
