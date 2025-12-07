unit USnTown;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene, UType,  USnBuyHero, USnBuyCrea,
  USnHero, USnMage, USnHall, USnCstl, USnBuyRes, USnBuyForge, USnDialog,USnBuyArtf,USnBuyShip,UPL,USnGame, USnTownBuild;

type

  TSnTown= class (TDxScene)
  private
    FocusedHero: integer;
    FocusedSlot:integer;                          
    CT, CTidx, Offset, DxO_Res: integer;
    SelectedBuild: integer;
    DxO_City, DxO_Vis,DxO_Gar, DxO_Hero,  DxO_Prod, Dxo_sep: integer;
    function HintCrea(a,slot:integer):string;
    function HintHero(a:integer):string;
    procedure SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SnMouseUp(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BtnSep(Sender: TObject);
    procedure ProdInfo(Sender: TObject);
    procedure PnlTown(Sender: TObject);
    procedure BtnHero(Sender: TObject);
    procedure BtnOK(Sender: TObject);
    procedure PnlGarCrea(Sender: TObject);
    procedure PnlVisCrea(Sender: TObject);
    procedure SnRefresh(Sender:TObject);
    procedure SnDraw(Sender:TObject);
    procedure SelectCT(NewCTidx: integer);
    procedure UpdateCityList;
    procedure UpdateCityProd;
    procedure UpdateCityGar;
    procedure UpdateCityVis;
    procedure OffsetUp(Sender: TObject);
    procedure OffsetDown(Sender: TObject);
  public
    constructor Create(_CT: integer);
    procedure   Update(_CT: integer);
  end;

const
  GAR=1;
  VIS=2;
var
  SnTownBuild: TSnTownBuild;

implementation

uses UMain, USnInfoCrea,  UMap, UCT, UHE, UArmy;

{----------------------------------------------------------------------------}
procedure TSnTown.SnDraw(sender : TObject);
begin
  if Background>-1
  then ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DoDraw;
  SnTownBuild.Redraw:=true;
  SnTownBuild.DoDraw;
end;
{----------------------------------------------------------------------------}
constructor TSnTown.Create(_CT: integer);
var
  i: integer;
  t: integer;
begin
  inherited Create('SnTown');
  AllClient:=true;
  SelectedBuild:=-1;
  fText:=TxtTCommand;
  CT:=_CT;
  Offset:=0;
  for i:=0 to mPlayers[mPL].ncity -1 do
  begin
    if mPlayers[mPL].lstcity[i]=CT then
    begin Offset:=min(i,max(0,mPlayers[mPL].ncity-3));
    end;
  end;
  t:=mCitys[CT].t;
  gArmy.initCT(CT);

  AddPanel('TOWNSCRN',0,375);
  AddPanel('ARESBAR',3,576);
  // player flag
  AddSprPanel('CREST58',240,388,NIL,11);

  DxO_Hero:=ObjectList.Count;
  AddSprPanel('HPL',240,388,BtnHero);
  AddSprPanelSelectedImage(DxO_Hero,'CPrLXXX');
  AddSprPanel('HPL',240,483,BtnHero);
  AddSprPanelSelectedImage(DxO_Hero+1,'CPrLXXX');
  FocusedHero:=-1;
  FocusedSlot:=-1;

  DxO_Gar:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
     AddSprPanel('TWCRPORT',304+62*i,388,PnlGarCrea);
     AddSprPanelSelectedImage(Objectlist.count-1,'CPrLXXX');
  end;

  DxO_Vis:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
    AddSprPanel('TWCRPORT',304+62*i,483,PnlVisCrea);
    AddSprPanelSelectedImage(Objectlist.count-1,'CPrLXXX');
  end;

  AddSPRPanel('ITMTL',80,414);
  AddSPRPanel('ITMCL',124,414);
  AddSPRPanel('ITPT',14,388);
  AddLabel('CityName',85,390);
  AddLabel_Center('Income',162,436,64);

  DxO_City:=ObjectList.Count;
  for i:=0 to 2 do begin
    AddSprPanel('ITPA',743,432+32*i,PnlTown);
    AddSprPanelSelectedImage(Objectlist.count-1,'HPSyyy');
  end;

  DxO_Prod:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
    AddSprPanel('CPRSMALL',20 + 56*(i mod 4) ,461 + 48 * (i div 4),ProdInfo);
    AddLabel_Center('0',14+ 55*(i mod 4),493+ 48 * (i div 4),50);
  end;

  DxO_Res:=ObjectList.Count;
  for i:=0 to MAX_RES-1 do
    AddLabel_Center('ResX',35+84*i,578, 54);

  AddLabel(Cmd_Map_GetDate,630,578);
  AddButton('IAM014',743,416,OffSetUp);
  AddButton('IAM015',743,528,OffSetDown);
  if mPlayers[mCitys[CT].pid].ncity <4 then
  begin
  TDXWButton(Objectlist[ObjectList.count-1]).enabled:=false;
  TDXWButton(Objectlist[ObjectList.count-2]).enabled:=false;
  end;
  Dxo_sep:=ObjectList.count;
  AddButton('TSBTNS',743,384,BtnSep,0);
  TDXwButton(Objectlist[Dxo_sep]).enabled:=false;
  AddButton('TSBTNS1',743,546,BtnOK);

  UpdateColor(mPL,2);
  AutoRefresh:=true;
  OnMouseMove:=SnMouseMove;
  OnMouseDown:=SnMouseDown;
  OnMouseUp:=SnMouseUp;
  OnRefresh:=SnRefresh;
  OnDraw:=SnDraw;
  DxMouse.Id:=CrDef;
  DxMouse.Style:=CrDef;
  AddScene;
  SnTownBuild:=TSnTownBuild.Create(CT,true);
end;
{----------------------------------------------------------------------------}
procedure TSnTown.BtnHero(Sender: TObject);
begin
  FocusedSlot:=-1;
  if FocusedHero=-1
  then
  begin
    FocusedHero:= TDxWPanel(sender).tag;
    if FocusedHero > -1 then TDxWPanel(sender).Focused:=true;
  end
  else
    if FocusedHero=TDxWPanel(sender).tag
    then
      TSnHero.Create(FocusedHero,false)
    else
    begin
      Cmd_CT_SwitchHero(CT);
      Update(CT);
      TDxWPanel(sender).Focused:=false;
      FocusedHero:=-1;
    end;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.PnlGarCrea(Sender: TObject);
begin
  FocusedHero:=-1;
  FocusedSlot:=ObjectList.DxO_MouseOver-(DxO_Gar);
  TDxWPanel(sender).Focused:=gArmy.Select(1,FocusedSlot); //1= Gar
  TDXWButton(ObjectList[DxO_Sep]).enabled:=true;
  AutoRefresh:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.PnlVisCrea(Sender: TObject);
begin
  FocusedHero:=-1;
  FocusedSlot:=ObjectList.DxO_MouseOver-(DxO_Vis);
  TDxWPanel(sender).Focused:=gArmy.Select(2,FocusedSlot);  //2=vis
  TDXWButton(ObjectList[DxO_Sep]).enabled:=true;
  AutoRefresh:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.BtnSep(Sender: TObject);
var
  i: integer;
begin
  if FocusedSlot=-1 then exit;
  gArmy.sep:=true;
  for i:=0 to MAX_ARMY do
  begin
    if TDXWPanel(ObjectList[DxO_Vis+i]).tag=0 then TDXWPanel(ObjectList[DxO_Vis+i]).Focused:=true;
    if TDXWPanel(ObjectList[DxO_Gar+i]).tag=0 then TDXWPanel(ObjectList[DxO_Gar+i]).Focused:=true;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.PnlTown(Sender: TObject);
var
  i: integer;
  NewCTidx : integer;
  NewCT: integer;
begin
  NewCTidx:=(TDXWPanel(sender).top-430) div 32;
  SelectCT(NewCTidx);
end;

procedure TSnTown.SelectCT(NewCTidx: integer);
var
  i: integer;
  NewCT: integer;
begin
  if Offset+NewCTidx >= mPlayers[mPL].nCity then exit;
  SnTownBuild.Destroy;
  FocusedHero:=-1;
  FocusedSlot:=-1;
  NewCT:=mPlayers[mPL].lstcity[Offset+NewCTidx];
  mPlayers[mPL].ActiveCity:=NewCT;
  SnTownBuild:=TSnTownBuild.Create(NewCT,true);
  Update(NewCT);
  for i:=0 to 2 do
    TDXWPanel(ObjectList[DxO_City+i]).Selected:=false;
  TDXWPanel(ObjectList[DxO_City+NewCTidx]).Selected:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.SnRefresh(Sender:TObject);
begin
  Update(CT);
end;
{----------------------------------------------------------------------------}
procedure TSnTown.UpdateCityList;
var
  i,id: integer;
begin
  for i:=0 to 2 do
    TDXWPanel(ObjectList[DxO_City+i]).Selected:=false;
  for i:=0 to 2 do
  begin
    if Offset+i < mPlayers[mPL].nCity
    then
    begin
      id:=mPlayers[mPL].LstCity[Offset+i];
      TDXWPanel(ObjectList[DxO_City+i]).Tag:=2+2*mCitys[id].t + mCitys[id].hasbuild;
      //TDXWPanel(ObjectList[DxO_City+i]).Focused:=(id = CT) ;
      if id=CT then
      begin
        CTidx:=i;
        TDXWPanel(ObjectList[DxO_City+CTidx]).Selected:=true;
      end
      else
        TDXWPanel(ObjectList[DxO_City+i]).Selected:=false;

    end
    else
      TDXWPanel(ObjectList[DxO_City+i]).Tag:=0;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.UpdateCityProd;
var
  i, CR, n: integer;
  s:string;
begin
  with mCitys[CT] do
  begin
  for i:=0 to MAX_ARMY do
    begin
      CR:= ProdArmys[i].t;
      n:=cmd_CT_ProdArmy(CT,i,s);

      if ((n>0) and (CR > -1) and (CR < 128))
      then
      begin
        TDXWPanel(ObjectList[DxO_Prod+2*i]).visible:=true;
        TDXWPanel(ObjectList[DxO_Prod+2*i]).tag:=CR+2;
        TDXWPanel(ObjectList[DxO_Prod+2*i+1]).visible:=true;
        TDXWLabel(ObjectList[DxO_Prod+2*i+1]).caption:='+'+inttostr(n);
        //TDXWLabel(ObjectList[DxO_Prod+2*i]).hint:='s';
      end
      else
      begin
        TDXWPanel(ObjectList[DxO_Prod+2*i]).visible:=false;
        TDXWPanel(ObjectList[DxO_Prod+2*i+1]).visible:=false;
      end;

    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.UpdateCityVis;
var
  i, CR, n: integer;
  s:string;
begin
  with mCitys[CT] do
  begin
    if VisHero > -1
    then
      with mHeros[VisHero] do
      begin
        for i:=0 to MAX_ARMY do
        begin
          TDXWPanel(ObjectList[DxO_Vis+i]).visible:=true;
          CR:= Armys[i].t;
          n:=  Armys[i].n;
          if CR > -1
          then
          begin
            TDXWPanel(ObjectList[DxO_Vis+i]).tag:=CR+2;
            TDXWPanel(ObjectList[DxO_Vis+i]).caption:=inttostr(n);
          end
          else
          begin
            TDXWPanel(ObjectList[DxO_Vis+i]).tag:=0;
            TDXWPanel(ObjectList[DxO_Vis+i]).caption:='';
          end;
        end;
      end
    else
      for i:=0 to MAX_ARMY do
      begin
        TDXWPanel(ObjectList[DxO_Vis+i]).visible:=false;
      end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.UpdateCityGar;
var
  i, CR, n: integer;
  s:string;
begin
  with mCitys[CT] do
  begin
    TDXWPanel(ObjectList[DxO_Hero]).tag:=GarHero;
    // dont use Hero GAr but City gar army
    for i:=0 to MAX_ARMY do
    begin
      CR:= gArmy.pArmys[1,i].t;
      n:=  gArmy.pArmys[1,i].n;
      if CR > -1
      then
      begin
        TDXWPanel(ObjectList[DxO_Gar+i]).tag:=CR+2;
        TDXWPanel(ObjectList[DxO_Gar+i]).caption:=inttostr(n);
      end
      else
      begin
        TDXWPanel(ObjectList[DxO_Gar+i]).tag:=0;
        TDXWPanel(ObjectList[DxO_Gar+i]).caption:='';
      end;
    end;
  end;
end;

{----------------------------------------------------------------------------}
procedure TSnTown.Update(_CT: integer);
var
  i,id: integer;
  CR, n: integer;
  s,pic:string;
begin
  if CT<>_CT then
  begin
    CT:=_CT;
    gArmy.initCT(CT);
  end;

  TDXWPanel(ObjectList[DxO_Hero-1]).Tag:= mCitys[CT].pid;

  UpdateCityList;

  for i:=0 to MAX_RES-1 do
  TDXWLabel(ObjectList[DxO_Res+i]).caption:=inttostr(mPlayers[mPL].RES[i]);

  with mCitys[CT] do
  begin
    TDXWlabel(ObjectList[DxO_City-1]).caption:=inttostr(cmd_CT_Income(CT));
    TDXWlabel(objectlist[DxO_City-2]).caption:=name;
    TDXWPanel(ObjectList[DxO_City-3]).tag:=2*t+hasBuild;
    TDXWPanel(ObjectList[DxO_City-4]).tag:=cmd_CT_FortLevel(CT)-1;
    TDXWPanel(ObjectList[DxO_City-5]).tag:=cmd_CT_CityLevel(CT);

    TDXWPanel(ObjectList[DxO_Hero+1]).tag:=VisHero;
    UpdateCityVis;
    UpdateCityGar;
    UpdateCityProd;
  end;

  SnTownBuild.AutoRefresh:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.ProdInfo(Sender: TObject);
var
  slot: integer;
  s:string;
begin
  slot:=(ObjectList.DxO_MouseOver-DxO_Prod) div 2;
  cmd_CT_ProdArmy(CT,slot,s);
  ProcessInfo(s);
end;
{----------------------------------------------------------------------------}
function TSnTown.HintHero(a:integer):string;             //a hero  1 gzr 2  vis
begin
 result:='empty';
 // gere les cas de hero in tow (vis or gar)
 if gArmy.pHE[a] > -1 then
 begin
    if focusedhero=-1 then
       result:= 'Select ' + mHeros[gArmy.pHE[a]].name;
    if focusedHero >-1 then
    begin
       if focusedHero = gArmy.pHE[a] then
       result:= 'View ' + mHeros[gArmy.pHE[a]].name else
       result:= 'Exchange ' + mHeros[focusedHero].name  + ' with ' + mHeros[gArmy.pHE[a]].name;
    end;
 end
 else
   if focusedhero>-1 then
       result:= 'Move ' + mHeros[focusedHero].name;

end;
{----------------------------------------------------------------------------}
function TSnTown.HintCrea(a,slot:integer):string;        //a army 1 gzr - 2 vis
var
  t: shortint;
begin
  result:=gArmy.hint(a,slot);
end;
{----------------------------------------------------------------------------}
procedure TSnTown.SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SnTownBuild.MouseDown(Button, Shift, X, Y);
end;
{----------------------------------------------------------------------------}
procedure TSnTown.SnMouseUp(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SnTownBuild.MouseUp(Button, Shift, X, Y);
  if  (ObjectList.DxO_MouseOver<> DxO_Hero)
  and (ObjectList.DxO_MouseOver<> DxO_Hero+1) then
  FocusedHero:=-1;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  slot: integer;
begin
  slot:=ObjectList.DxO_MouseOver;
  Hint:='';
  case slot of
    3: Hint:=HintHero(1) + ' (garnison)';
    4: Hint:=HintHero(2) + ' (visiting)';
    5 ..  5 + MAX_ARMY: Hint:=HintCrea(1,slot-DxO_Gar);
    12.. 12 + MAX_ARMY: Hint:=HintCrea(2,slot-DxO_Vis);
    53..53+14 :  if mCitys[CT].prodArmys[(slot-83) mod 7].t > -1 then Hint:='Recruit ' +iCrea[mCitys[CT].prodArmys[(slot-53) mod 7].t].name;
  end;
  Hint:=inttostr(slot)+' - '+   Hint;
  if Y < 375 then  SnTownBuild.MouseMove(Shift, X, Y);
  {if selectedbuild <>-1 then
  begin
    TDXWPanel(ObjectList[selectedbuild]).left:=mouse.x;
    TDXWPanel(ObjectList[selectedbuild]).top:=mouse.y;
    TDXWPanel(ObjectList[selectedbuild]).caption:= format('id=%d, pos %d, %d',[selectedbuild-DxO_Build,mouse.X,mouse.y]);
  end;  }
end;

{----------------------------------------------------------------------------}
procedure TSnTown.BtnOK;
begin
  //SnTownBuild.Destroy;
  SnTownBuild.AutoDestroy:=true;
  AutoDestroy:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.OffsetUp(Sender: TObject);
begin
  if Offset + CTidx-1 >=0
  then begin
    if CTidx=0
    then dec(offset)
    else dec(CTidx);
    SelectCT(CTidx);
    UpdateCityList;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnTown.OffsetDown(Sender: TObject);
begin
  if Offset + CTidx+1 <  mPlayers[mPL].nCity
  then begin
    if CTidx=2
    then inc(offset)
    else inc(CTidx);
    SelectCT(CTidx);
    UpdateCityList;
  end;
end;
{----------------------------------------------------------------------------}
end.
