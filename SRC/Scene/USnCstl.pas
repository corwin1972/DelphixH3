unit USnCstl;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DxWLoad , DXWScene,UConst;

type
  TSnCstl= class (TDxScene)
  private
    DxO_Build, DxO_Res, DxO_Crea: integer;
    CT: integer;
  public
    constructor Create(City: integer);
    procedure Sndraw(sender: TObject);
    procedure BtnBuy(Sender: TObject);
  end;

implementation

uses UMain, UFile, USnDialog, Utype,USnBuyCrea, UMap, UCT;

{----------------------------------------------------------------------------}
constructor TSnCstl.Create(City: integer);
var
  i,j ,x,y, id: integer;
  MO: integer;
  ext: string;
begin
  inherited Create('SnCstl');
  AllClient:=true;
  Left:=0;
  Top:=0;
  HintX:=70;
  HintY:=560;
  AddBackground('TPCASTL7');
  AddTitleScene('FORT',2);
  AddPanel('KRESBAR',5,575);
  CT:=City;
  for i:=0 to 5 do
    AddPanel('TPCAINFO',169+394 *(i mod 2)+104, 25+133 * (i div 2));
  AddPanel('TPCAINFO',365+104, 425);

  DxO_Crea:=ObjectList.Count;
  for i:=0 to 5 do
  begin
    AddPanel('TPCAS'+TNext2[mCitys[CT].t],169+394 *(i mod 2), 25+133 * (i div 2),BtnBuy);
    if mCitys[CT].ProdArmys[i].t <> -1
    then MO:=mCitys[CT].ProdArmys[i].t
    else MO:=14*mCitys[CT].t+2*i;

    //AddSprPanel(iDef[946+MO].name,180+394 *(i mod 2), 50+133 * (i div 2),BtnBuy);
    ObjectList.Add(TDXWPanel.Create(self));
    id:=ObjectList.Count-1;

    with TDXWPanel(ObjectList[id]) do
    begin
      Name:=inttostr(MO);
      LoadUnit(MO,MO,ImageList);
      Image:=ImageList.Items.Find(inttostr(MO));
      Width:=Image.Width;
      Height:=Image.Height;
      Left:=394 *(i mod 2);
      Top:=-130+133 * (i div 2);
      Surface:=DxSurface;
      enabled:=false;
    end;

  end;
  AddPanel('TPCAS'+TNext2[mCitys[CT].t],365, 425,BtnBuy);
  if mCitys[CT].ProdArmys[6].t <> -1
  then MO:=mCitys[CT].ProdArmys[6].t
  else MO:=14*mCitys[CT].t+2*6;

    ObjectList.Add(TDXWPanel.Create(self));
    id:=ObjectList.Count-1;

    with TDXWPanel(ObjectList[id]) do
    begin
      Name:=inttostr(MO);
      LoadUnit(MO,MO,ImageList);
      Image:=ImageList.Items.Find(inttostr(MO));
      Width:=Image.Width;
      Height:=Image.Height;
      Left:=376-180;
      Top:=450-180;
      Surface:=DxSurface;
      enabled:=false;
    end;

  ext:=TNext[mCitys[CT].t];

  DxO_Build:= Objectlist.Count;
  for i:=0 to MAX_ARMY do
  begin
    x:=TDXWPanel(ObjectList[DxO_Crea+2*i]).left;
    y:=TDXWPanel(ObjectList[DxO_Crea+2*i]).top;
    AddSprPanel('HALL'+ext,x-155 , y+18);
    AddLabel_Center('HALL'+ext, x-160 , y+90,160,8);

    j:=cmd_CT_ShowWhatToBuild(City,11+i);
    TDxWPanel(objectlist[DxO_Build+2*i]).tag:=j;
    TDxWLabel(Objectlist[DxO_Build+2*i+1]).caption:=iBuild[mCitys[City].t,j].name;
  end;

  DxO_Res:=ObjectList.Count;
  for i:=0 to MAX_RES-1 do
  AddLabel('ResX',35+76*i,578);
  AddLabel_Center('Day Week Month',555,578,180);

  for i:=0 to MAX_RES-1 do
    TDXWLabel(ObjectList[DxO_Res+i]).caption:=inttostr(mPlayers[mPL].RES[i]);

  TDXWLabel(ObjectList[ObjectList.Count-1]).caption:=Cmd_Map_GetDate;

  AddButton('TPMAGE1',747,556,BtnOK);
  UpdateColor(mPL,2);
  OnDraw:=SnDraw;
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnCstl.BtnBuy(Sender: TObject);
var
  Slot,CR,nCR : integer;
begin
  Slot:=(Objectlist.DxO_MouseOver-DxO_Crea) div 2;
  CR:=mCitys[CT].prodArmys[Slot].t;
  if CR=-1 then exit;
  nCR:=Min(mCitys[CT].dispArmys[Slot].n, mPlayers[mPL].res[6] div iCrea[CR].cost);

  mDialog.res :=-1;
  TSnBuyCrea.Create(CR,nCR);
  repeat
    Application.HandleMessage
  until mDialog.res <> -1;
  if mDialog.res >0 then
  cmd_CT_AddCrea(CT,CR,mDialog.res);
end;
{----------------------------------------------------------------------------}
procedure TSnCstl.SnDraw(sender: TObject);
var
  i,x,y,l,n: integer;
  CR,nCR: integer;
  s:string;
begin
  for i:=0 to MAX_RES -1 do
     TDxWLabel(Objectlist[DxO_Res+i]).caption:= inttostr(mPlayers[MPL].res[i]);
  if Background>-1 then
    ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DoDraw;
  with DxSurface.Canvas do
  begin
    Brush.Style:=bsClear;
    Font.Color:=ClWhite;//Text;
    Font.Name:=H3Font;//'Arial';
    Font.Size:=8;
    for i:=0 to MAX_ARMY do
    begin
      x:=TDXWPanel(ObjectList[DxO_Crea+2*i]).left;
      y:=TDXWPanel(ObjectList[DxO_Crea+2*i]).top;
      if mCitys[CT].ProdArmys[i].t <> -1 then
      begin
        CR:=mCitys[CT].ProdArmys[i].t;
        nCR:=mCitys[CT].DispArmys[i].n;
        s:='Available :  ' +inttostr(nCR);
      end
      else
      begin
        CR:=14*mCitys[CT].t+2*i;
        nCR:=0;
        s:='' ;
      end;
      with iCrea[CR] do
      begin
        //s:='Available :  ' +inttostr(nCR);
        l:=DxSurface.canvas.TextWidth(s) div 2;
        Textout(x-80-l,y+108,s);

        s:=name;
        l:=DxSurface.canvas.TextWidth(s) div 2;
        Textout(x-80-l,y,s);


        Textout(x+132,y+21*0,TxtCastInfo[0]);
        s:=inttostr(atk);
        l:=DxSurface.canvas.TextWidth(s);
        Textout(x+224-l,y+21*0,s);
        Textout(x+132,y+21*1,TxtCastInfo[1]);
        s:=inttostr(def);
        l:=DxSurface.canvas.TextWidth(s);
        Textout(x+224-l,y+21*1,s);
        Textout(x+132,y+21*2,'Dégats');
        //TxtCastInfo[2]); //copy(TxtHelp[376],2,AnsiPos(chr(9),TxtHelp[376])-2));
        s:=format('%d - %d',[dmgMin,dmgMax]);
        l:=DxSurface.canvas.TextWidth(s);
        Textout(x+224-l,y+21*2,s);
        Textout(x+132,y+21*3,TxtCastInfo[3]);
        s:=inttostr(hit);
        l:=DxSurface.canvas.TextWidth(s);
        Textout(x+224-l,y+21*3,s);
        Textout(x+132,y+21*4,TxtCastInfo[4]);
        s:=inttostr(speed);
        l:=DxSurface.canvas.TextWidth(s);
        Textout(x+224-l,y+21*4,s);
        Textout(x+132,y+21*5,TxtCastInfo[5]);
        //s:=inttostr(growth);
        n:=cmd_CT_ProdArmy(CT,i,s);
        s:=inttostr(n);
        l:=DxSurface.canvas.TextWidth(s);
        Textout(x+224-l,y+21*5,s);
      end;
    end;
    release;
  end;
end;
{----------------------------------------------------------------------------}

end.

