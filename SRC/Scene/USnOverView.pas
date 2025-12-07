unit USnOverView;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnOverView= class (TDxScene)
  private
    DxO_Pnl: integer;
    DxO_City: integer;
    DxO_Hero: integer;
    DxO_Res:integer;
    DxO_Pskill: integer;
    DxO_Title: integer;
    OffsetH, OffsetC: integer;
    procedure BtnArt_E(Sender: TObject);
    procedure BtnArt_M(Sender: TObject);
    procedure BtnArt_P(Sender: TObject);
    procedure ArtUpdate(Line,List:byte);
    procedure TownRefresh;
    procedure HeroRefresh;
    procedure PnlTown(Sender: TObject);
    procedure PnlHero(Sender: TObject);
    procedure BtnTown(Sender: TObject);
    procedure BtnHero(Sender: TObject);
    procedure BtnUp(Sender: TObject);
    procedure BtnDn(Sender: TObject);
  public
    constructor Create;
  end;

const
  nHEOB=46;
  nCTOB=37;
var
  SnOverView: TSnOverView;


implementation

uses UMain, USnHero,  Utype, USnTown,  UMap, UCT, UPL;

{----------------------------------------------------------------------------}
constructor TSnOverView.Create;
var
  i,j: integer;
begin
  inherited  Create('SnOverview');
  AllClient:=true;
  AddBackground('Overview');
  AddPanel('KRESBAR',8,576);
  AddButton('OVBUTN2',4,1,BtnUP);
  AddButton('OVBUTN2',4,470,BtnDN);
  DxO_Title:=ObjectList.Count;
  AddLabel_Yellow('Title',100,6);
  AddLabel_Yellow('Title',330,6);
  AddLabel_Yellow('Title',550,6);
  DxO_Pnl:=ObjectList.Count;
  for i:=0 to 3 do
  begin
    AddSprPanel('OVSLOT',23,26+116*i);
    TDXWPanel(ObjectList[DxO_Pnl+i]).Tag:=6;
  end;

  AddButton('OVBUTN1',748,492,BtnHero);
  AddButton('OVBUTN6',748,527,BtnTown);
  AddButton('OVBUTN7',748,565,BtnOK);    //HSBTNS

  with mPlayers[mPL] do
  begin
    Cmd_PL_CountMine(mPL);
    Cmd_PL_Income(mPL);
    for i :=0 to MAX_RES-1 do
    begin
      AddSprPanel('OVMINES',45+87*i,491);
      TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=i;
      AddLabel(inttostr(Mine[i]),72+87*i,535);
    end;

    AddSprPanel('RESOURCE',40+87*7,495);
    TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=6; //OR
    AddLabel(inttostr(Income[6]),40+87*7,535);

    DxO_Res:=ObjectList.Count;
    for i:=0 to MAX_RES-1 do
      AddLabel_Center(inttostr(RES[i]),35+75*i,578, 54);

    AddLabel_Center(Cmd_Map_GetDate,560,580,180);

    DxO_City:=ObjectList.Count;
    for i:=0 to 3 do
    begin
      AddSprPanel('ITPT',28,31+116*i,PnlTown);
      AddLabel('TownName',98,34+116*i);
      AddSPRPanel('ITMTLS',94,59+116*i);
      AddSPRPanel('ITMCLS',137,59+116*i);
      AddLabel_Center('500',175,81+116*i,70);
      AddSprPanel('HPL',266,31+116*i,PnlHero);    //vis hero
      AddSprPanel('HPL',498,31+116*i,PnlHero);    //gar hero
      //prodarmys
      for j:=0 to MAX_ARMY do AddSprPanel('CPRSMALL',79+37*j,104+116*i);
      //dsparmys
      for j:=0 to MAX_ARMY do AddSprPanel('CPRSMALL',432+37*j,104+116*i);
      //garnison crea and hero
      for j:=0 to 3 do AddSprPanel('CPRSMALL',335+36*j,28+116*i);
      for j:=0 to 2 do AddSprPanel('CPRSMALL',354+36*j,65+116*i);
      //visiting crea and hero
      for j:=0 to 3 do AddSprPanel('CPRSMALL',231+335+36*j,28+116*i);
      for j:=0 to 2 do AddSprPanel('CPRSMALL',231+354+36*j,65+116*i);
      AddLabel_YellowCenter('Creature Bonuses',24,104+116*i,54);
      AddLabel_YellowCenter('Creature Available',374,104+116*i,54);
    end;

    DxO_Hero:=ObjectList.Count;
    for i:=0 to 3 do
    begin
      AddSprPanel('HPL',28,31+116*i,PnlHero);
      AddLabel('HeroName',98,35+116*i);
      for j:=0 to MAX_ARMY  do
        AddSprPanel('CPRSMall',28+36*j,103+116*i);
      for j:=0 to 3 do
      begin
        AddSprPanel('PSKIL32',101+36*j ,51+116*i);
        TDxWPanel(Objectlist[Objectlist.Count-1]).Tag:=j;
      end;

      for j:=0 to 3 do
        AddLabel_Center('0',105+35*j ,85+116*i,25);

      AddSprPanel('PSKIL32',302,31+116*i);
      TDxWPanel(Objectlist[Objectlist.Count-1]).Tag:=5;
      AddSprPanel('PSKIL32',352,31+116*i);
      TDxWPanel(Objectlist[Objectlist.Count-1]).Tag:=4;

      AddLabel_Center('PTM',291 ,51+116*i,50,8);
      AddLabel_Center('EXP',343 ,51+116*i,50,8);

      AddSprPanel('UN32',396,31+116*i);

      for j:=0 to 7 do
        AddSprPanel('SECSK32',432+36*j,31+116*i);

      AddLabel('Artefact',305,71+116*i);
      AddLabel('Equipped',395,71+116*i);
      AddLabel('Misc',505,71+116*i);
      AddLabel('Pack',615,71+116*i);
      For j:=0 to 8 do
      AddSprPanel('ARTIFACT',290+48*j,93+116*i);

      AddFrame(108,19,388,71+116*i,BtnART_E);
      TDxWPanel(Objectlist[Objectlist.Count-1]).selected:=True;
      AddFrame(108,18,499,71+116*i,BtnART_M);
      AddFrame(108,19,610,71+116*i,BtnART_P);
    end;

  end;
  TDXWButton(ObjectList[DxO_Pnl+4]).enabled:=true;
  TDXWButton(ObjectList[DxO_Pnl+5]).enabled:=false;
  TownRefresh;         //town by default
  AddScene;
  UpdateColor(mPL,2);
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.BtnTown(Sender: TObject);
begin
  TDXWButton(ObjectList[DxO_Pnl+4]).enabled:=true;
  TDXWButton(ObjectList[DxO_Pnl+5]).enabled:=false;
  TownRefresh; 
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.TownRefresh;
var
  i,j , t,n: integer;
  CT, HE: integer;
  s: string;

begin
  OffsetH:=0;
  TDXWLabel(ObjectList[DxO_Title]).caption:=TxtOverView[3];
  TDXWLabel(ObjectList[DxO_Title+1]).caption:=TxtOverView[4];
  TDXWLabel(ObjectList[DxO_Title+2]).caption:=TxtOverView[5];
  for i:=DxO_Hero to ObjectList.count-1 do
  TDXWObject(ObjectList[i]).visible:=false;

  for i:=0 to 3 do
  begin
    if i < mPlayers[mPL].nCity
    then
    begin
      CT:=mPlayers[mPL].LstCity[OffsetC+i];
      TDXWPanel(ObjectList[DxO_City+nCTOB*i]).visible:=true;
      TDXWPanel(ObjectList[DxO_City+nCTOB*i]).Tag:=2*mcitys[CT].t;
      TDXWPanel(ObjectList[DxO_Pnl+i]).Tag:=6;
      TDXWLabel(ObjectList[DxO_City+nCTOB*i+1]).Caption:=mcitys[CT].name;
      TDXWLabel(ObjectList[DxO_City+nCTOB*i+1]).Visible:=true;
      TDXWPanel(ObjectList[DxO_City+nCTOB*i+2]).tag:=cmd_CT_CityLevel(CT);
      TDXWLabel(ObjectList[DxO_City+nCTOB*i+2]).Visible:=true;
      TDXWPanel(ObjectList[DxO_City+nCTOB*i+3]).tag:=cmd_CT_FortLevel(CT);
      TDXWLabel(ObjectList[DxO_City+nCTOB*i+3]).Visible:=true;
      TDXWlabel(ObjectList[DxO_City+nCTOB*i+4]).caption:=inttostr(cmd_CT_Income(CT));
      TDXWLabel(ObjectList[DxO_City+nCTOB*i+4]).Visible:=true;
      TDXWPanel(ObjectList[DxO_City+nCTOB*i+5]).tag:=mcitys[CT].GarHero;
      TDXWLabel(ObjectList[DxO_City+nCTOB*i+5]).Visible:=true;
      TDXWPanel(ObjectList[DxO_City+nCTOB*i+6]).tag:=mcitys[CT].VisHero;
      TDXWLabel(ObjectList[DxO_City+nCTOB*i+6]).Visible:=true;
      for j:=0 to MAX_ARMY do
      begin
        t:=mCitys[CT].ProdArmys[j].t;
        n:=cmd_CT_ProdArmy(CT,j,s);
        //n:=mCitys[CT].ProdArmys[j].n;
        if t = -1 then
        TDXWPanel(ObjectList[DxO_City+nCTOB*i+7+j]).Visible:=false
        else begin
        TDXWPanel(ObjectList[DxO_City+nCTOB*i+7+j]).tag:=t+2;
        TDXWPanel(ObjectList[DxO_City+nCTOB*i+7+j]).Caption:='+' + inttostr(n);
        TDXWPanel(ObjectList[DxO_City+nCTOB*i+7+j]).Visible:=true;
        end;
      end;


      for j:=0 to MAX_ARMY do
      begin
        t:=mCitys[CT].ProdArmys[j].t;
        n:=mCitys[CT].DispArmys[j].n;
        if t = -1 then
        TDXWPanel(ObjectList[DxO_City+nCTOB*i+14+j]).Visible:=false
        else begin
        TDXWPanel(ObjectList[DxO_City+nCTOB*i+14+j]).tag:=t+2;
        TDXWPanel(ObjectList[DxO_City+nCTOB*i+14+j]).Caption:=inttostr(n);
        TDXWPanel(ObjectList[DxO_City+nCTOB*i+14+j]).Visible:=true;
        end;
      end;

      //gar hero
      if  mcitys[CT].GarHero > -1 then
      begin
        for j:=0 to MAX_ARMY do
        begin
          HE:=mCitys[CT].GarHero;
          t:=mHeros[HE].Armys[j].t;
          n:=mHeros[HE].Armys[j].n;
          if t = -1 then
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+21+j]).Visible:=false
          else begin
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+21+j]).tag:=t+2;
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+21+j]).Caption:=inttostr(n);
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+21+j]).Visible:=true;
          end;
        end;
      end
      else
       for j:=0 to MAX_ARMY do
        begin
          t:=mCitys[CT].garArmys[j].t;
          n:=mCitys[CT].garArmys[j].n;
          if t = -1 then
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+21+j]).Visible:=false
          else begin
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+21+j]).tag:=t+2;
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+21+j]).Caption:=inttostr(n);
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+21+j]).Visible:=true;
          end;
        end;


    //vis hero
    if  mCitys[CT].VisHero > -1 then
    begin
        for j:=0 to MAX_ARMY do
        begin
          HE:=mCitys[CT].VisHero;
          t:=mHeros[HE].Armys[j].t;
          n:=mHeros[HE].Armys[j].n;
          if t = -1 then
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+28+j]).Visible:=false
          else begin
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+28+j]).tag:=t+2;
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+28+j]).Caption:=inttostr(n);
            TDXWPanel(ObjectList[DxO_City+nCTOB*i+28+j]).Visible:=true;
          end;
        end;
      end;

    TDXWLabel(ObjectList[DxO_City+nCTOB*i+35]).Visible:=true;
    TDXWLabel(ObjectList[DxO_City+nCTOB*i+36]).Visible:=true;
    end else
    begin
      TDXWPanel(ObjectList[DxO_Pnl+i]).Tag:=i;
      for j:=0 to nCTOB-1 do
        TDXWPanel(ObjectList[DxO_City+nCTOB*i+j]).visible:=false;
    end;

  end;
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.BtnArt_E(Sender: TObject);
var
  i,l :integer;
begin
  l:=(TDxWObject(sender).top - 71) div 116;
  ARTUpdate(l,0);
  for i:=0 to 2 do  TDxWObject(Objectlist[Dxo_Hero+46*l+46-3+i]).selected:=false;
  TDxWObject(sender).selected:=True;
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.BtnArt_M(Sender: TObject);
var
  i,l :integer;
begin
  l:=(TDxWObject(sender).top - 71) div 116;
  ARTUpdate(l,1);
  for i:=0 to 2 do  TDxWObject(Objectlist[Dxo_Hero+46*l+46-3+i]).selected:=false;
  TDxWObject(sender).selected:=True;
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.BtnArt_P(Sender: TObject);
var
  i,l :integer;
begin
  l:=(TDxWObject(sender).top - 71) div 116;
  ARTUpdate(l,2);
  for i:=0 to 2 do  TDxWObject(Objectlist[Dxo_Hero+46*l+46-3+i]).selected:=false;
  TDxWObject(sender).selected:=True;
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.ArtUpdate(Line,List:byte);
var
  AR,HE,k:Integer;
begin
  HE:=mPlayers[mPL].LstHero[Line];
  DxO_Pskill:=DxO_Hero+nHEOB*Line+9;
  case List of
  0: //equipped
  for k:=0 to 8 do
      begin
        AR:=mHeros[HE].Arts[k];
        if AR>0 then
        begin
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).visible:=true;
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).tag:=AR;
        end
        else
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).visible:=false;
      end;
  1:  //misc
  for k:=0 to 8 do
      begin
        AR:=mHeros[HE].Arts[k+9];
        if AR>0 then
        begin
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).visible:=true;
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).tag:=AR;
        end
        else
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).visible:=false;
      end;
  2:
  for k:=0 to 8 do
      begin
        AR:=mHeros[HE].Arts[k+18];
        if AR>0 then
        begin
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).visible:=true;
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).tag:=AR;
        end
        else
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).visible:=false;
      end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.BtnUP(Sender: TObject);
begin
  if TDXWButton(ObjectList[DxO_Pnl+5]).enabled then
  begin
  if mPlayers[mpl].nHero <= 4 then exit;
  OffsetH:=OffsetH-1;
  if offsetH<0 then offsetH:=0;
  HeroRefresh;
  end
  else
  begin
  if mPlayers[mpl].nCity <= 4 then exit;
  OffsetC:=OffsetC-1;
  if offsetC<0 then offsetC:=0;
  TownRefresh;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.BtnDn(Sender: TObject);
begin
  if TDXWButton(ObjectList[DxO_Pnl+5]).enabled then
  begin
  if MPlayers[mpl].nHero <= 4 then exit;
  OffsetH:=OffsetH+1;
  if offsetH+4 > MPlayers[mpl].nHero then OffsetH:=MPlayers[mpl].nHero-4;
  HeroRefresh;
  end
  else
  begin
  if mPlayers[mpl].nCity <= 4 then exit;
  OffsetC:=OffsetC+1;
  if offsetC+4 > MPlayers[mpl].nCity then OffsetC:=MPlayers[mpl].nCity-4;
  TownRefresh;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.BtnHero(Sender: TObject);
begin
  TDXWButton(ObjectList[DxO_Pnl+4]).enabled:=false;
  TDXWButton(ObjectList[DxO_Pnl+5]).enabled:=true;
  HeroRefresh;
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.HeroRefresh;
var
  i,j,k,t,n , HE,AR: integer;
begin
  OffsetC:=0;
  TDXWLabel(ObjectList[DxO_Title]).caption:=TxtOverView[0];
  TDXWLabel(ObjectList[DxO_Title+1]).caption:='';
  TDXWLabel(ObjectList[DxO_Title+2]).caption:=TxtOverView[1];
  for i:=DxO_City to DxO_Hero-1 do
    TDXWObject(ObjectList[i]).visible:=false;

  for i:=0 to 3 do
  begin
    if i < mPlayers[mPL].nHero
    then
    begin
      TDXWPanel(ObjectList[DxO_Hero+nHEOB*i]).visible:=true;
      HE:=mPlayers[mPL].LstHero[OffsetH+i];
      TDXWPanel(ObjectList[DxO_Hero+nHEOB*i]).Tag:=HE;
      TDXWPanel(ObjectList[DxO_Pnl+i]).Tag:=4;
      TDXWLabel(ObjectList[DxO_Hero+nHEOB*i+1]).Caption:=mHeros[HE].name;
      TDXWLabel(ObjectList[DxO_Hero+nHEOB*i+1]).Visible:=true;
      for j:=0 to MAX_ARMY do
      begin
        t:=mHeros[HE].Armys[j].t;
        n:=mHeros[HE].Armys[j].n;
        if t = -1 then
          TDXWPanel(ObjectList[DxO_Hero+nHEOB*i+2+j]).Visible:=false
        else begin
          TDXWPanel(ObjectList[DxO_Hero+nHEOB*i+2+j]).tag:=t+2;
          TDXWPanel(ObjectList[DxO_Hero+nHEOB*i+2+j]).caption:=inttostr(n);
          TDXWPanel(ObjectList[DxO_Hero+nHEOB*i+2+j]).Visible:=true;
        end;
      end;
      DxO_Pskill:=DxO_Hero+nHEOB*i+9;
      TDXWLabel(ObjectList[DxO_Pskill+4]).caption:=inttostr(mHeros[HE].PSKB.att);
      TDXWLabel(ObjectList[DxO_Pskill+5]).caption:=inttostr(mHeros[HE].PSKB.def);
      TDXWLabel(ObjectList[DxO_Pskill+6]).caption:=inttostr(mHeros[HE].PSKB.pow);
      TDXWLabel(ObjectList[DxO_Pskill+7]).caption:=inttostr(mHeros[HE].PSKB.kno);
      TDXWLabel(ObjectList[DxO_Pskill+10]).caption:=inttostr(mHeros[HE].PSKA.ptm)+'/'+ inttostr(mHeros[HE].PSKB.ptm);
      TDXWLabel(ObjectList[DxO_Pskill+11]).caption:=inttostr(mHeros[HE].exp);

      for j:=0 to 12 do
      begin
        TDXWObject(ObjectList[DxO_Pskill+j]).visible:=true;
      end;
      TDxWPanel(Objectlist[DxO_Pskill+12]).Tag:=HE;
      j:=0;
      for k:=0 to MAX_SSK do
      begin
        if mHeros[HE].SSK[k] > 0 then
        begin
          TDxWPanel(Objectlist[DxO_Pskill+13+j]).Tag:=3+3*k+mHeros[HE].SSK[k]-1;
          TDxWPanel(Objectlist[DxO_Pskill+13+j]).visible:=true;
          inc(j);
          if j=8 then break;
        end;
      end;
      for k:=j to 7 do
      begin
        TDxWPanel(Objectlist[DxO_Pskill+13+k]).Tag:=0;
      end;
      for k:=0 to 3 do
      begin
        TDxWLabel(Objectlist[DxO_Pskill+13+8+k]).visible:=true;
      end;
      for k:=0 to 8 do
      begin
        AR:=mHeros[HE].Arts[k];
        if AR>0 then
        begin
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).visible:=true;
          TDxWPanel(Objectlist[DxO_Pskill+13+8+4+k]).tag:=AR;
        end;
      end;
      for k:=0 to 2 do
        TDxWFrame(Objectlist[DxO_Pskill+13+8+4+9+k]).visible:=true;
    end
    else
    begin
      TDXWPanel(ObjectList[DxO_Hero+nHEOB*i]).visible:=false;
      TDXWPanel(ObjectList[DxO_Pnl+i]).Tag:=i;
      TDXWLabel(ObjectList[DxO_Hero+nHEOB*i+1]).visible:=false;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.PnlTown(Sender: TObject);
var
  CT: integer;
begin
  CT:=mPlayers[mPL].lstcity[OffSetC+(TDXWPanel(sender).top-31) div 116];
  TSnTown.Create(CT);
end;
{----------------------------------------------------------------------------}
procedure TSnOverView.PnlHero(Sender: TObject);
var
  HE: integer;
begin
  HE:=mPlayers[mPL].lsthero[OffSetH + (TDXWPanel(sender).top-31) div 116];
  TSnHero.Create(HE,false);
end;
{----------------------------------------------------------------------------}

end.
