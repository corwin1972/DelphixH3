unit USnHero;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DXWScene, DxWLoad , UFile;

type
  TSnHero= class (TDxScene)
  private
    DxO_Art, DxO_HeroList, DxO_Hero, DxO_Crea, DxO_PSkill,DxO_SSkill, DxO_LuckMoral,
    DxO_Btn, DxO_Lose: integer;
    HE: integer;
    InTavern:boolean;
    procedure BtnSep(Sender: TObject);
    procedure BtnDel(Sender:Tobject);
    procedure BtnBook(Sender:Tobject);
    procedure BtnArt(Sender:Tobject);
    procedure BtnArtR(Sender:Tobject);
    procedure BtnBio(Sender:Tobject);
    procedure BtnSpec(Sender:Tobject);
    procedure BtnPSkil(Sender:Tobject);
    procedure BtnExp(Sender:Tobject);
    procedure BtnPtMana(Sender:Tobject);
    procedure BtnSSkil(Sender:Tobject);
    procedure PnlHero(Sender: TObject);
    procedure PnlCrea(Sender: TObject);
    procedure BtnLuck(Sender:Tobject);
    procedure BtnMoral(Sender:Tobject);
    procedure BtnOK2(Sender:Tobject);
    procedure RefreshList;
  public
    constructor Create(Value: integer;InTavern: boolean);
    procedure SnRefresh(Sender:TObject);
    procedure SnDraw(sender:TObject);
    procedure SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

var
  SnHero:TSnHero;

implementation

uses UMain, USnInfoCrea, USnBook, USnDialog, UType, UArmy, UHE;

const
  SEL_ART =127;
  SEL_HERO=131;
{----------------------------------------------------------------------------}
constructor TSnHero.Create(Value: integer;InTavern: boolean);
var
  i: integer;
begin
  inherited Create('SnHero');
  HE:=Value;
  gArmy.initHE(HE);
  Left:=50;
  FText:=LoadTxt('HEROSCRN');
  AddBackground('HEROSCR3');
  AddImage('HPSYYY');

  DxO_LuckMoral:=ObjectList.count;
  AddSprPanel('ILCK42',242,182,BtnLuck);
  AddSprPanel('IMRL42',182,182,BtnMoral);

  DxO_Art:=ObjectList.count;
  AddSprPanel('ARTIFACT',443,21,BtnArt);    //Tete 0

  AddSprPanel('ARTIFACT',502,234,BtnArt);   //Epaules
  AddSprPanel('ARTIFACT',443, 70,BtnArt);   //Cou
  AddSprPanel('ARTIFACT',317, 60,BtnArt);   //Main Droite
  AddSprPanel('ARTIFACT',498,175,BtnArt);   //Main Gauche

  AddSprPanel('ARTIFACT',443,120,BtnArt);   //Torse
  AddSprPanel('ARTIFACT',365, 60,BtnArt);   //Anneau D.
  AddSprPanel('ARTIFACT',545,175,BtnArt);   //Anneau G.
  AddSprPanel('ARTIFACT',450,286,BtnArt);   //Pieds

  AddSprPanel('ARTIFACT',317,135,BtnArt);   //12
  AddSprPanel('ARTIFACT',333,185,BtnArt);   //11
  AddSprPanel('ARTIFACT',349,235,BtnArt);   //10
  AddSprPanel('ARTIFACT',365,286,BtnArt);   //DIVER 9

  AddSprPanel('ARTIFACT',498, 21,BtnArt);   //MACHINE 13
  AddSprPanel('ARTIFACT',545, 21,BtnArt);   //MACHINE 14
  AddSprPanel('ARTIFACT',545, 67,BtnArt);   //MACHINE 15
  AddSprPanel('ARTIFACT',545,114,BtnArt);   //MACHINE 16

  AddSprPanel('ARTIFACT',545,303,BtnBook,14); //Livre de Sorts

  AddSprPanel('ARTIFACT',337,356,BtnArt);
  AddSprPanel('ARTIFACT',383,356,BtnArt);
  AddSprPanel('ARTIFACT',429,356,BtnArt);
  AddSprPanel('ARTIFACT',475,356,BtnArt);
  AddSprPanel('ARTIFACT',521,356,BtnArt);

  for i:=DxO_Art to DxO_Art+22 do
    TDXWPanel(Objectlist[i]).OnclickR:=BtnArtR;

  DxO_Hero:=ObjectList.Count;
  AddSprPanel('HPL',18,18,BtnBio);
  AddLabel_YellowCenter('HeroName',80,30, 200);
  AddLabel_Center('Level',80,50, 200, 8);

  DxO_Crea:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
    AddSprPanel('TWCRPORT',15+66*i,485,PnlCrea);
    AddSprPanelSelectedImage(Objectlist.count-1,'CPrLXXX');
  end;
  for i:=0 to MAX_ARMY do
    AddLabel_Right('0',15+66*i,535,54,10);

  for i:=0 to 3 do
    AddLabel_YellowCenter(TxtPRISKILL[i],32+70*i-10,90,44+20,8);
  for i:=0 to 3 do
    AddSprPanel('PSKIL42',32+70*i,111,BtnPSkil);
    AddSprPanel('PSKIL42',19,230,BtnExp);
    AddSprPanel('PSKIL42',19+143,230,BtnPtMana);
  for i:=0 to 5 do
    TDxWPanel(Objectlist[Objectlist.Count-6+i]).Tag:=i;
    TDxWPanel(Objectlist[Objectlist.Count-3]).Tag:=5;
    TDxWPanel(Objectlist[Objectlist.Count-1]).Tag:=3;

  AddLabel_Yellow('Speciality',71 ,186,8);
  AddLabel_Yellow('Experience',71 ,234,8);
  AddLabel_Yellow('Pts de magie',214 ,234,8);

  //speciality
  AddSprPanel('UN44',18,179,BtnSpec);    // it is an ID to text and UN44 pic
  AddLabel('SpecName',71,206,8);

  DxO_PSkill:=ObjectList.Count;
  for i:=0 to 3 do
    AddLabel_Center('0',32+70*i,158,44,8);
  for i:=0 to 1 do
    AddLabel('0',71+143*i ,254,8);

  DxO_SSkill:=ObjectList.Count;
  for i:=0 to 7 do
    AddSprPanel('SECSKILL',19+143*(i mod 2),276 + 48 * (i div 2),BtnSSkil);
  for i:=0 to 7 do
    AddLabel('',71+143*(i mod 2),300 + 48 * (i div 2),8);
  for i:=0 to 7 do
    AddLabel('',71+143*(i mod 2),280 + 48 * (i div 2),8);



  if (inTavern)
  then
  begin
    AddSprPanel('CREST58',606,8);
    TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=8
  end
  else
  begin
    AddSprPanel('CREST58',606,8);
    TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=mPL;
    DxO_HeroList:=ObjectList.Count;
    for i:=0 to 7 do AddSprPanel('HPS',611,87+54*i,PnlHero);
    AddButton('HSBTNS2',535,430,BtnDel);
  end;

  AddButton('HSBTNS4',314,430);
  AddButton('HSBTNS3',314,356);
  AddButton('HSBTNS5',566,356);
  AddButton('HSBTNS6',480,484);
  AddButton('HSBTNS7',480,518);
  AddButton('HSBTNS8',546,484);
  DxO_Btn:=ObjectList.Count;
  AddButton('HSBTNS9',546,518,BtnSep);
  AddButton('HSBTNS',610,512,BtnOK2,17);

  OnDraw:=SnDraw;
  OnMouseMove:=SnMouseMove;
  OnMouseDown:=SnMousedown;
  OnRefresh:=SnRefresh;
  UpdateColor(mPL,1);
  AutoRefresh:=true;
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnSep(Sender: TObject);
var
  i: integer;
begin
  if DxMouse.style=msArt then exit;
  //if FocusedSlot=-1 then exit;
  gArmy.sep:=true;
  for i:=0 to MAX_ARMY do
  begin
    if TDXWPanel(ObjectList[DxO_Crea+i]).tag=0 then TDXWPanel(ObjectList[DxO_Crea+i]).Focused:=true;
  end;
  if mHeros[HE].VisTown > -1 then
  parent.AutoRefresh:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnBook(Sender:Tobject);
begin
  if DxMouse.style=msArt then exit;
  TSnBook.Create(HE);
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnBio(Sender:Tobject);
begin
  if DxMouse.style=msArt then exit;
  ProcessInfo(mHeros[HE].desc);
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnLuck(Sender:Tobject);
var
  s, bonus :string;
  l: integer;
begin
  if DxMouse.style=msArt then exit;
  case mHeros[HE].luck of
    -3 : l:=2;
    -2 : l:=2;
    -1 : l:=2;
    0  : l:=1;
    1  : l:=0;
    2  : l:=0;
    3  : l:=0;
  end;
  s:=format(TxtARRAYTXT[62],[TxtARRAYTXT[59+l]]);
  bonus:='';

  if Cmd_HE_FindART(HE,AR045_StillEyeoftheDragon) > 0
    then bonus:=bonus + NL + TxtARRAYTXT[63+0];
  if Cmd_He_FindART(HE,AR046_CloverofFortune) > 0
    then bonus:=bonus + NL + TxtARRAYTXT[63+1];
  if Cmd_He_FindART(HE, AR047_CardsofProphecy) > 0
    then bonus:=bonus + NL + TxtARRAYTXT[63+2];
  if Cmd_HE_FindART(HE, AR048_LadybirdofLuck) > 0
    then bonus:=bonus + NL + TxtARRAYTXT[63+3];
  if mHeros[HE].VisSwan
    then bonus:=bonus + NL + TxtARRAYTXT[63+4];
  if mHeros[HE].VisIdol
    then bonus:=bonus + NL + TxtARRAYTXT[63+5];
  if mHeros[HE].VisFortune
    then bonus:=bonus + NL + TxtARRAYTXT[63+6];
  if mHeros[HE].VisFaery
    then bonus:=bonus + NL + TxtARRAYTXT[63+8];
  if mHeros[HE].VisMermaid
    then bonus:=bonus + NL + TxtARRAYTXT[63+8];
  if mHeros[HE].SSK[SK09_Luck] > 0
    then bonus:=bonus + NL + TxtARRAYTXT[63+11+mHeros[HE].SSK[SK09_Luck]];

  if bonus =''
    then s:=s+ NL + 'No bonus'
    else s:=s+bonus;  
  ProcessDialog(s,dsLuck_p,mHeros[HE].luck);
{Oeil de Tranquillité +1"
"Trèfle à Quatre Feuille +1"
"Cartes du Destin +1"
"Oiseau Porte-Bonheur +1"
4"Etang des Cygnes visité +2"
5"Idole de Chance visitée +1"
"Fontaine des Espérances visitée %s"
"Pyramide visitée -2"
8"Cercle des Fées visité +1"
"Sirène visitée +1"
"Drapeau de Ralliement visité +1"
11"Novice en Chance +1"
"Disciple en Chance +2"
"Maître en Chance +3"
"Aucun}
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnOK2(Sender:Tobject);
begin
  if DxMouse.style=msArt then
     Cmd_HE_SetART(HE,DxMouse.id,-1);
  btnOK(sender)
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnMoral(Sender:Tobject);
var
  s, bonus :string ;
  m: integer;
begin
  if DxMouse.style=msArt then exit;
  case mHeros[HE].moral of
    -3 : m:=2;
    -2 : m:=2;
    -1 : m:=2;
    0  : m:=1;
    1  : m:=0;
    2  : m:=0;
    3  : m:=0;
  end;
  s:=format(TxtARRAYTXT[87],[TxtARRAYTXT[84+m]]);
  bonus:='';
  //if mHeros[HE].VisFaery then s:=s+ TxtARRAYTXT[88];
  if Cmd_HE_FindART(HE,AR045_StillEyeoftheDragon) > 0
    then bonus:=bonus + TxtARRAYTXT[88+0];
  if Cmd_HE_FindART(HE,AR049_BadgeofCourage) > 0
    then bonus:=bonus + TxtARRAYTXT[88+1];
  if Cmd_HE_FindART(HE, AR050_CrestofValor) > 0
    then bonus:=bonus + TxtARRAYTXT[88+3];
  if mHeros[HE].VisIdol
    then bonus:=bonus +  TxtARRAYTXT[88+4];
  if mHeros[HE].VisYough
    then bonus:=bonus + TxtARRAYTXT[88+14];
  if mHeros[HE].SSK[SK06_Leadership] > 0
    then bonus:=bonus + TxtARRAYTXT[88+16+mHeros[HE].SSK[SK06_Leadership]];
  if bonus =''
    then s:=s+ NL + 'No bonus'
    else s:=s+bonus;
  ProcessDialog(s,dsMorale_p,mHeros[HE].moral);

{Oeil de Tranquillité +1"
"Médaille du Courage +1"
"Croix du Mérite +1"
3"Glyphe d'Honneur +1"
"Idole de Chance visitée +1"
"Bouée visitée +1"
6"Oasis visité +1"
"Temple visité +1"
"Temple visité un dimanche +2"
9"Sépulture visitée -1"
"Epave visitée -1"
"Source visitée +1"
12"Bateau Abandonné visité -1"
"Drapeau de Ralliement visité +1"
"Fontaine de Jouvence visitée +1"
14"Tombe du Guerrier visitée -3"
"Novice en Charisme +1"
"Disciple en Charisme +1"
"Maître en Charisme +1"
"Aucun  }
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnExp(Sender:Tobject);
begin
  if DxMouse.style=msArt then exit;
  ProcessInfo('{Experience}' +
  NL + 'Current Level ' + inttostr(mHeros[HE].level) +
  NL + 'Next Level ' + inttostr(ExpLevel[mHeros[HE].level+1]) +
  NL + 'Current XP ' + inttostr(mHeros[HE].exp)
  );
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnPtMana(Sender:Tobject);
begin
  if DxMouse.style=msArt then exit;
  ProcessInfo('{Mana}' +
  NL + 'Current Mana ' + inttostr(mHeros[HE].PSKB.ptm) +
  NL + 'Max Mana ' + inttostr(mHeros[HE].PSKA.ptm)
);
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnSpec(Sender:Tobject);
begin
  if DxMouse.style=msArt then exit;
  ProcessInfo(mHeros[HE].spec);
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnDel(Sender:Tobject);
begin
  Cmd_HE_Del(HE);
  DxMouse.id:=CrDef;
  DxMouse.style:=msAdv;
  CloseScene;
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnArtR(Sender:Tobject);
var
  OB,slot: integer;
  AR: integer;

begin
  if DxMouse.style=msArt then exit;
  OB:= Objectlist.DxO_MouseOver;
  slot:= OB - DxO_Art;
  //newART:=TDXWPanel(sender).Tag;
  AR:=mHeros[HE].Arts[slot];
  if AR = -1
  then ProcessInfo('{ART Slot '+inttostr(slot) + '} ' +' is Free ')
  else ProcessDialog('{'+inttostr(slot)+ ' - ' + iArt[AR].name+'}'+iArt[AR].desc,dsArt,AR);
  DxMouse.id:=CrDef;
  DxMouse.style:=msAdv;
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnArt(Sender:Tobject);
var
  DxO,slot,i: integer;
  newART: integer;
  oldART:integer;
begin
  DxO:= Objectlist.DxO_MouseOver;
  slot:= DxO - DxO_Art;
  newART:=TDXWPanel(sender).Tag;

  if DxMouse.style=msArt // trying drag and drop
  then
  begin
    oldART:=DxMouse.id;
    if Cmd_HE_PossbileARTPos(HE,oldART,slot)
    then
    begin
      Cmd_HE_FreeARTPos(HE,newART,slot);
      Cmd_HE_SetART(HE,oldART ,slot);
      TDXWPanel(sender).Tag:=oldART;
      if ((newART=-1) or (newART=128)) then  //  avant ReadArt mettait 128 si nouvel ART> H3.1
      begin
      DxMouse.id:=CrDef;
      DxMouse.style:=msAdv;
      end
      else
      //taking the ART as current cursor
      DxMouse.id:=newART;
    end
    else
      for i:=0 to 17 do
      if iArt[oldArt].slotok[i] then  TDXWPanel(Objectlist[DxO_Art+i]).selected:=true;
  end

  else
  begin
    //Def cursor, so taking the ART as current cursor and clearing ART from heroes
    if newART=-1 then
    begin
      DxMouse.id:=CrDef;
      DxMouse.style:=msAdv;
    end
    else
    begin
      //taking the ART as current cursor
      DxMouse.id:=newART;
      DxMouse.style:=msArt;
      TDXWPanel(Objectlist[DxO]).Tag:=-1;  //127;
      Cmd_HE_FreeARTPos(HE,newART,slot);
      //try to find allow slot TDXWPanel(sender).selected:=True;
      for i:=0 to 17 do
      if iArt[NewArt].slotok[i] then  TDXWPanel(Objectlist[DxO_Art+i]).selected:=true;
    end;
  end;
  AutoRefresh:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnHero.BtnSSkil(Sender:Tobject);
var
  SK:integer;
begin
  if DxMouse.style=msArt then exit;
  SK:=TDXWPanel(sender).tag;
  ProcessDialog('',dsSecSkill,SK);
end;

{----------------------------------------------------------------------------}
procedure TSnHero.BtnPSkil(Sender:Tobject);
var
  PK, Value:integer;
begin
  //TODO:PBBBBB
  if DxMouse.style=msArt then exit;
  PK:=TDXWPanel(sender).tag;
  if PK=5 then PK:=3;
  Value:=strtoint(TDXWLabel(ObjectList[DxO_PSkill+PK]).caption);
  ProcessDialog('',dsPriSkill+PK, Value);
end;
{----------------------------------------------------------------------------}
procedure TSnHero.SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  slot: integer;
  AR : integer;
begin
  slot:=ObjectList.DxO_MouseOver-DxO_Crea;
  case slot of
    0..MAX_ARMY:   Hint:=gArmy.Hint(0,slot);
  end;
  slot:=ObjectList.DxO_MouseOver-DxO_Art;
  case slot of
    0..22:   begin
        // Hint:=iArt[mHeros[HE].Arts[i]].name; //TDXWPanel(ObjectList[DxO_Art+i]).Tag:=AR;;
        AR:=TDXWPanel(ObjectList[DxO_Art+slot]).Tag;
        if AR > -1 then Hint:=inttostr(slot) +'-'+iArt[AR].name;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnHero.SnDraw;
var
  i:integer;
  x,y: integer;
begin
  ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DoDraw;
  for i:=0 to 22 do
  begin
    x:=TDXWPanel(ObjectList[i]).left;
    y:=TDXWPanel(ObjectList[i]).top;
    if TDXWPanel(ObjectList[i]).selected
    then Imagelist.Items.Find('ARTIFACT').Draw(DxSurface,x,y,SEL_ART)
  end;

  for i:=0 to 7 do
  begin
    x:=TDXWPanel(ObjectList[DxO_HeroList+i]).left;
    y:=TDXWPanel(ObjectList[DxO_HeroList+i]).top;
    if TDXWPanel(ObjectList[DxO_HeroList+i]).selected
      then Imagelist.Items.Find('HPSYYY').Draw(DxSurface,x,y,0)
   end;

  if DxMouse.style=msArt then
    ImageList.Items.find('ARTIFACT').Draw(DxSurface, DxMouse.x-16, DxMouse.y-16, DxMouse.id);
end;
{----------------------------------------------------------------------------}
procedure TSnHero.SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
begin
  //unselect ART all the time and ARMYES if click out of ARMYES
  //Mouse.id:=0;
  for i:=0 to 22 do TDXWPanel(ObjectList[DxO_Art+i]).selected:=false;

  i:=ObjectList.DxO_MouseOver;
  if ((i<DxO_Crea) or (i>DxO_Crea+ MAX_ARMY)) and (i<>DxO_Btn)
  then gArmy.Select(0,-1);
end;
{----------------------------------------------------------------------------}
procedure TSnHero.PnlHero(Sender: TObject);
var
  i:integer;
begin
  if DxMouse.style=msArt then exit;
  for i:=0 to 7 do
    TDXWPanel(ObjectList[DxO_HeroList+i]).selected:=false;
  TDXWPanel(sender).selected:=true;

  HE:=TDXWPanel(sender).tag;
  mPlayers[mPL].ActiveHero:=HE;
  gArmy.initHE(HE);
  AutoRefresh:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnHero.RefreshList;
var
  i:integer;
begin
  TDXWButton(ObjectList[DxO_Lose]).enabled:=true;
  for i:=0 to 7  do
  begin
    if i < mPlayers[mPL].nHero
    then
    begin
      TDXWPanel(Objectlist[DxO_HeroList+i]).Tag:=mPlayers[mPL].LstHero[i];
      if HE=mPlayers[mPL].LstHero[i] then  TDXWPanel(Objectlist[DxO_HeroList+i]).selected:=true;
    end
    else
    begin
      TDXWPanel(ObjectList[DxO_HeroList+i]).Tag:=130;
      TDXWPanel(ObjectList[DxO_HeroList+i]).visible:=false;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnHero.SnRefresh(Sender:TObject);
var
  i,j:integer;
  CR,n,AR:integer;
begin
  if not(inTavern)
  then RefreshList;

  TDXWPanel(ObjectList[DxO_PSkill-2]).tag:=HE;
  TDXWLabel(ObjectList[DxO_PSkill-1]).caption:=mHeros[HE].spec1;
  TDXWLabel(ObjectList[DxO_PSkill+0]).caption:=inttostr(max(0,mHeros[HE].PSKB.att));
  TDXWLabel(ObjectList[DxO_PSkill+1]).caption:=inttostr(max(0,mHeros[HE].PSKB.def));
  TDXWLabel(ObjectList[DxO_PSkill+2]).caption:=inttostr(max(0,mHeros[HE].PSKB.pow));
  TDXWLabel(ObjectList[DxO_PSkill+3]).caption:=inttostr(max(0,mHeros[HE].PSKB.kno));
  TDXWPanel(ObjectList[DxO_LuckMoral]).tag:=  3+mHeros[HE].luck;      // luck 0..3
  TDXWPanel(ObjectList[DxO_LuckMoral+1]).tag:=3+mHeros[HE].moral;     // moral -3 .+3
  TDXWLabel(ObjectList[DxO_PSkill+4]).caption:=inttostr(mHeros[HE].exp);
  TDXWLabel(ObjectList[DxO_PSkill+5]).caption:=inttostr(mHeros[HE].PSKA.ptm)+'/'+ inttostr(mHeros[HE].PSKB.ptm);

  j:=0;
  for i:=0 to MAX_SSK do
  begin
    if mHeros[HE].SSK[i] > 0 then
    begin
      TDxWPanel(Objectlist[DxO_SSkill+j]).Tag:=3+3*i+mHeros[HE].SSK[i]-1;
      TDxWLabel(Objectlist[DxO_SSkill+j+8]).caption:=iSSK[i].name;
      TDxWLabel(Objectlist[DxO_SSkill+j+16]).caption:=TxtMasterName[mHeros[HE].SSK[i]-1];
      inc(j);
      if j=8 then break;
    end;
  end;

  for i:=j to 7 do
  begin
    TDxWPanel(Objectlist[DxO_SSkill+i]).Tag:=0;
    TDxWLabel(Objectlist[DxO_SSkill+i+8]).caption:='';
    TDxWLabel(Objectlist[DxO_SSkill+i+16]).caption:='';
  end;

  TDXWPanel(ObjectList[DxO_Hero]).tag:=HE;
  TDxWLabel(objectlist[DxO_Hero+1]).caption:=mHeros[HE].name;
  TDxWLabel(objectlist[DxO_Hero+2]).caption:=format('Level %d  %s',[mHeros[HE].level, mHeros[HE].classeName]);
  for i:=0 to MAX_ARMY do
  begin
    CR:=mHeros[HE].Armys[i].t;
    n:=mHeros[HE].Armys[i].n;
    if CR > -1
    then
    begin
      TDXWPanel(ObjectList[DxO_Crea+i]).tag:=CR+2;
      TDXWLabel(ObjectList[DxO_Crea+7+i]).caption:=inttostr(n);
    end
    else
    begin
      TDXWPanel(ObjectList[DxO_Crea+i]).tag:=0;
      TDXWLabel(ObjectList[DxO_Crea+7+i]).caption:='';
    end;
  end;

  for i:=0 to MAX_PACK do
  begin
    AR:=mHeros[HE].Arts[i];
    //TDXWPanel(ObjectList[DxO_Art+i]).Visible:= not(AR =-1);
    if
    AR=-1
    then
    TDXWPanel(ObjectList[DxO_Art+i]).Tag:=-1 //127
    else
    TDXWPanel(ObjectList[DxO_Art+i]).Tag:=AR;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnHero.PnlCrea(Sender: TObject);
var
  slot: integer;
begin
  if DxMouse.style=msArt then exit;
  slot:=ObjectList.DxO_MouseOver-DxO_Crea;
  TDxWPanel(sender).Focused:=gArmy.Select(0,Slot);
  AutoRefresh:=true;
  if mHeros[HE].VisTown > -1 then
  parent.autorefresh:=true;
end;
{----------------------------------------------------------------------------}
end.
