unit USnMeet;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DXWScene, DxWLoad , UFile;

type
  TSnMeet= class (TDxScene)
  private
    DxO_Hero,
    DxO_Crea1,DxO_Crea2,
    DxO_Art,DxO_Art2,
    DxO_PSkill, DxO_SSkill: integer;
    hid,mid: integer;
    FocusedSlot:integer;
    procedure BtnBook(Sender:Tobject);
    procedure BtnArt(Sender:Tobject);
    procedure BtnArtR(Sender:Tobject);
    procedure BtnSSkil(Sender:Tobject);
    procedure PnlHero(Sender: TObject);
    procedure PnlCrea1(Sender: TObject);
    procedure PnlCrea2(Sender: TObject);
    procedure BtnSep(Sender: TObject);
  public
    constructor Create(ahid,amid: integer);
    procedure Update;
    procedure SnDraw(sender:TObject);
    procedure SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  end;

var
  SnMeet:TSnMeet;

implementation

uses UMain, USnInfoCrea, USnBook, USnDialog, UType, UArmy, UHE;

const

  SEL_ART =127;
  SEL_HERO=131;

{-----------------------------------------------------------------------------}
procedure TSnMeet.SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  slot,AR: integer;
begin
  slot:=ObjectList.DxO_MouseOver-DxO_Crea1;
  if ((slot>=0 )and  (slot <= MAX_Army)) then
        Hint:=gArmy.Hint(1,slot);

  slot:=ObjectList.DxO_MouseOver-DxO_Crea2;
  if ((slot>=0 )and  (slot <= Max_Army)) then
        Hint:=gArmy.Hint(2,slot);

  case slot of
    0..45:   begin
      // Hint:=iArt[mHeros[hid].Arts[i]].name; //TDXWPanel(ObjectList[DxO_Art+i]).Tag:=AR;;
      AR:=TDXWPanel(ObjectList[slot]).Tag;
      if AR > -1 then
      Hint:=inttostr(slot)+'-'+iArt[AR].name;
    end;
  end;
end;
{-----------------------------------------------------------------------------}
constructor TSnMeet.Create(ahid,amid: integer);
var
  i: integer;
begin
  if mPLayers[mPL].isCPU then
  begin
    mDialog.res:=1;
    exit;
  end;

  inherited Create('SnMeet');

  HintY:=Top+578;
  hid:=ahid;
  mid:=amid;
  gArmy.initmeet(hid,mid); 
  FText:=LoadTxt('HEROSCRN');
  AddBackground('TRADE');
  AddImage('HPSYYY');

  //=============================================
  DxO_Art:=ObjectList.Count;
  AddSprPanel('ARTIFACT',174,180,BtnArt);    //Tete 0

  AddSprPanel('ARTIFACT',233,392,BtnArt);    //Epaules
  AddSprPanel('ARTIFACT',174,231,BtnArt);    //Cou
  AddSprPanel('ARTIFACT', 48,219,BtnArt);    //Main Droite
  AddSprPanel('ARTIFACT',230,335,BtnArt);    //Main Gauche

  AddSprPanel('ARTIFACT',174,282,BtnArt);    //Torse
  AddSprPanel('ARTIFACT',96,220,BtnArt);     //Anneau D.
  AddSprPanel('ARTIFACT',276,335,BtnArt);    //Anneau G.
  AddSprPanel('ARTIFACT',180,445,BtnArt);    //Pieds

  AddSprPanel('ARTIFACT', 49,293,BtnArt);    //DIVER 9
  AddSprPanel('ARTIFACT', 63,343,BtnArt);    //10
  AddSprPanel('ARTIFACT', 81,395,BtnArt);    //11
  AddSprPanel('ARTIFACT', 96,445,BtnArt);    //12

  AddSprPanel('ARTIFACT',229,180,BtnArt);    //15
  AddSprPanel('ARTIFACT',276,180,BtnArt);    //16
  AddSprPanel('ARTIFACT',276,227,BtnArt);    //MACHINE 13
  AddSprPanel('ARTIFACT',276,272,BtnArt);    //14

  AddSprPanel('ARTIFACT',274,462,BtnBook,14);     //Livre de Sorts
  // pack
  for i:=0 to 4 do
  AddSprPanel('ARTIFACT',70+46*i,516,BtnArt);

  //=============================================
  DxO_Art2:=ObjectList.Count;
  AddSprPanel('ARTIFACT',432+174,180,BtnArt);    //Tete 0

  AddSprPanel('ARTIFACT',432+233,392,BtnArt);    //Epaules
  AddSprPanel('ARTIFACT',432+174,231,BtnArt);    //Cou
  AddSprPanel('ARTIFACT',432+ 48,219,BtnArt);    //Main Droite
  AddSprPanel('ARTIFACT',432+230,335,BtnArt);    //Main Gauche

  AddSprPanel('ARTIFACT',432+174,282,BtnArt);    //Torse
  AddSprPanel('ARTIFACT',432+96,220,BtnArt);     //Anneau D.
  AddSprPanel('ARTIFACT',432+276,335,BtnArt);    //Anneau G.
  AddSprPanel('ARTIFACT',432+180,445,BtnArt);    //Pieds

  AddSprPanel('ARTIFACT',432+ 49,293,BtnArt);    //DIVER 9
  AddSprPanel('ARTIFACT',432+ 63,343,BtnArt);    //10
  AddSprPanel('ARTIFACT',432+ 81,395,BtnArt);    //11
  AddSprPanel('ARTIFACT',432+ 96,445,BtnArt);    //12

  AddSprPanel('ARTIFACT',432+229,180,BtnArt);    //MACHINE 13
  AddSprPanel('ARTIFACT',432+276,180,BtnArt);    //14
  AddSprPanel('ARTIFACT',432+276,227,BtnArt);    //15
  AddSprPanel('ARTIFACT',432+276,272,BtnArt);    //16

  AddSprPanel('ARTIFACT',432+274,462,BtnBook,14);     //Livre de Sorts
  // pack
  for i:=0 to 4 do
  AddSprPanel('ARTIFACT',432+ 70+46*i,516,BtnArt);

  for i:=DxO_Art to DxO_Art+33 do
  TDXWPanel(Objectlist[i]).OnclickR:=BtnArtR;

  //=============================================
  DxO_Hero:=ObjectList.Count;
  AddSprPanel('HPL',256,14);
  AddLabel_right('HeroName',85,18,160);

  AddSprPanel('HPL',485,14);
  AddLabel('HeroName',555,18);

  AddButton('HSBTNS9',5,132,BtnSep);
  AddButton('HSBTNS9',740,132,BtnSep);

  DxO_Crea1:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
    AddSprPanel('CPRSMALL',67+36*i,132,PnlCrea1);
    AddSprPanelSelectedImage(Objectlist.count-1,'TRADESEL');
  end;
  //for i:=0 to MAX_ARMY do AddLabel('0',84+36*i,150);

  for i:=0 to 3 do AddSprPanel('PSKIL32',384,20+36*i);
  for i:=0 to 3 do TDxWPanel(Objectlist[Objectlist.Count-1-i]).Tag:=3-i;

  DxO_PSkill:=ObjectList.Count;
  for i:=0 to 3 do AddLabel_Center('0',330,28+36*i,45);
  for i:=0 to 3 do AddLabel_Center('0',425,28+36*i,45);

  DxO_SSkill:=ObjectList.Count;
  for i:=0 to 7 do AddSprPanel('SECSK32',30+36*i,88);
  for i:=0 to 7 do AddSprPanel('SECSK32',484+36*i,88);

  DxO_Crea2:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
    AddSprPanel('CPRSMALL',417+67+36*i,132,PnlCrea2);
    AddSprPanelSelectedImage(Objectlist.count-1,'TRADESEL' );
  end;
  //for i:=0 to MAX_ARMY do AddLabel('0',416+84+36*i,150);

  AddButton('IOKAY',732,566,BtnOK,17);

  OnDraw:=SnDraw;
  OnMouseDown:=SnMousedown;
  OnMouseMove:=SnMouseMove;
  UpdateColor(mPL,1);
  Update;
  AddScene;
end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.BtnSep(Sender: TObject);
var
  i: integer;
begin
  if FocusedSlot=-1 then exit;
  gArmy.sep:=true;
  for i:=0 to MAX_ARMY do
  begin
    if TDXWPanel(ObjectList[DxO_Crea1+i]).tag=0 then TDXWPanel(ObjectList[DxO_Crea1+i]).Focused:=true;
    if TDXWPanel(ObjectList[DxO_Crea2+i]).tag=0 then TDXWPanel(ObjectList[DxO_Crea2+i]).Focused:=true;
  end;
end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.BtnBook(Sender:Tobject);
begin
  TSnBook.Create(1);
end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.BtnArtR(Sender:Tobject);
var
  DxO,slot,HE,i: integer;
  newART: integer;
  oldART:integer;
begin
  if DxMouse.style=msArt then exit;
  DxO:= Objectlist.DxO_MouseOver;
  slot:= DxO - DxO_Art;
  newART:=TDXWPanel(sender).Tag;
    if slot > MAX_PACK
  then
  begin
    HE:=mid;
    slot:=slot -(MAX_PACK+1);
  end
  else
  begin
    HE:=hid;
  end;
  ProcessDialog('{'+inttostr(slot)+ ' - ' + iArt[newART].name+'}'+iArt[newART].desc,dsArt,newART);
  DxMouse.id:=CrDef;
  DxMouse.style:=msAdv;
end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.BtnArt(Sender:Tobject);
var
  DxO,slot,i: integer;
  newART: integer;
  oldART:integer;
  HE:integer;
begin
  DxO:= Objectlist.DxO_MouseOver;
  slot:= DxO - DxO_Art;
  newART:=TDXWPanel(sender).Tag;
  // adapting HE and SLOT to meethero
  if slot > MAX_PACK
  then
  begin
    HE:=mid;
    slot:=slot -(MAX_PACK+1);
  end
  else
  begin
    HE:=hid;
  end;

  if mbleft=mbLeft
  then
  begin
    if DxMouse.style=msArt // Trying drag and drop
    then
    begin
      oldART:=DxMouse.id;
      if Cmd_HE_PossbileARTPos(HE,oldART,slot)
      then
      begin
        Cmd_HE_FreeARTPos(HE,newART,slot);
        Cmd_He_SetART(HE,oldART ,slot);
        TDXWPanel(sender).Tag:=oldART;
        if newART=-1 then
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
          if iArt[oldArt].slotok[i] then begin
             TDXWPanel(Objectlist[DxO_Art+i]).selected:=true;
             TDXWPanel(Objectlist[DxO_Art+MAX_PACK+1+i]).selected:=true;
          end;
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
      for i:=0 to MAX_PACK do
      if iArt[NewArt].slotok[i] then  begin
        TDXWPanel(Objectlist[DxO_Art+i]).selected:=true;
        TDXWPanel(Objectlist[DxO_Art+MAX_PACK+1+i]).selected:=true;
      end;
    end;
  end;

  end;
  TDXWPanel(sender).selected:=True;
  Update; //SnRefresh;
end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.BtnSSkil(Sender:Tobject);
var
  skid:integer;
begin
  skid:=(TDXWPanel(sender).tag-3) div 3;
  ProcessDialog('{SkilInfo} You have clicked on ',dsSecSkill,skid);
end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.SnDraw;
var
  i:integer;
  x,y: integer;
begin
  ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DoDraw;
  for i:=0 to 2*MAX_PACK+1 do
  begin
    x:=TDXWPanel(ObjectList[i]).left;
    y:=TDXWPanel(ObjectList[i]).top;
    if TDXWPanel(ObjectList[i]).selected
    then Imagelist.Items.Find('ARTIFACT').Draw(DxSurface,x,y,SEL_ART)
  end;

  for i:=0 to 7 do
  begin
    x:=TDXWPanel(ObjectList[DxO_Hero+i]).left;
    y:=TDXWPanel(ObjectList[DxO_Hero+i]).top;
    if TDXWPanel(ObjectList[DxO_Hero+i]).selected
      then Imagelist.Items.Find('HPSYYY').Draw(DxSurface,x,y,0)
  end;

  if DxMouse.style=msArt then
    ImageList.Items.find('ARTIFACT').Draw(DxSurface, DxMouse.x-16, DxMouse.y-16, DxMouse.id);

end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
begin
  //Mouse.id:=0;
  for i:=0 to MAX_Pack do begin
  TDXWPanel(ObjectList[DxO_Art+i]).selected:=false;
  TDXWPanel(ObjectList[DxO_Art+MAX_PACK+1+i]).selected:=false;
  end;
end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.PnlHero(Sender: TObject);
var
  i:integer;
begin
  for i:=0 to 7 do
    TDXWPanel(ObjectList[DxO_Hero+i]).selected:=false;
  TDXWPanel(sender).selected:=true;

  hid:=TDXWPanel(sender).tag;
  mPlayers[mPL].ActiveHero:=hid;
  Update;
end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.Update;
var
  i,j:integer;
  CR,n,AR:integer;
begin

  //================================
  //first hero
  TDXWLabel(ObjectList[DxO_PSkill+0]).caption:=inttostr(mHeros[hid].PSKB.att);
  TDXWLabel(ObjectList[DxO_PSkill+1]).caption:=inttostr(mHeros[hid].PSKB.def);
  TDXWLabel(ObjectList[DxO_PSkill+2]).caption:=inttostr(mHeros[hid].PSKB.pow);
  TDXWLabel(ObjectList[DxO_PSkill+3]).caption:=inttostr(mHeros[hid].PSKB.kno);

  j:=0;
  for i:=0 to MAX_SSK do
  begin
    if mHeros[hid].SSK[i] > 0 then
    begin
      TDxWPanel(Objectlist[DxO_SSkill+j]).Tag:=3+3*i+mHeros[hid].SSK[i]-1;
      inc(j);
      if j=8 then break;
    end;
  end;
  for i:=j to 7 do
  begin
    TDxWPanel(Objectlist[DxO_SSkill+i]).Tag:=0;
  end;

  TDXWPanel(ObjectList[DxO_Hero]).tag:=hid;;
  TDXWLabel(Objectlist[DxO_Hero+1]).caption:=mHeros[hid].name;

  for i:=0 to MAX_ARMY do
  begin
    CR:= mHeros[hid].Armys[i].t;
    n:=mHeros[hid].Armys[i].n;
    if CR > -1
    then
    begin
      TDXWPanel(ObjectList[DxO_Crea1+i]).tag:=CR+2;
      TDXWLabel(ObjectList[DxO_Crea1+i]).caption:=inttostr(n);
    end
    else
    begin
      TDXWPanel(ObjectList[DxO_Crea1+i]).tag:=0;
      TDXWLabel(ObjectList[DxO_Crea1+i]).caption:='';
    end;
  end;

  for i:=0 to MAX_PACK do
  begin
    AR:=mHeros[hid].Arts[i];
    //TDXWPanel(ObjectList[DxO_Art+i]).Visible:= not(artid =-1);
    TDXWPanel(ObjectList[DxO_Art+i]).Tag:=AR;
    //if artid=-1 then TDXWPanel(ObjectList[DxO_Art2+i]).Tag:=127;
    //TDXWPanel(ObjectList[DxO_Art+i]).Caption:=inttostr(i);
  end;

  //================================
  //second hero
  TDXWPanel(ObjectList[DxO_Hero+2]).tag:=mid;;
  TDxWLabel(objectlist[DxO_Hero+3]).caption:=mHeros[mid].name;

   //================================
  //second hero
  TDXWLabel(ObjectList[DxO_PSkill+4+0]).caption:=inttostr(mHeros[mid].PSKB.att);
  TDXWLabel(ObjectList[DxO_PSkill+4+1]).caption:=inttostr(mHeros[mid].PSKB.def);
  TDXWLabel(ObjectList[DxO_PSkill+4+2]).caption:=inttostr(mHeros[mid].PSKB.pow);
  TDXWLabel(ObjectList[DxO_PSkill+4+3]).caption:=inttostr(mHeros[mid].PSKB.kno);

  j:=0;
  for i:=0 to MAX_SSK do
  begin
    if mHeros[mid].SSK[i] > 0 then
    begin
      TDxWPanel(ObjectList[DxO_SSkill+j+8]).Tag:=3+3*i+mHeros[mid].SSK[i]-1;
      inc(j);
      if j=8 then break;
    end;
  end;
  for i:=j to 7 do
  begin
    TDxWPanel(ObjectList[DxO_SSkill+i]).Tag:=0;
  end;

  for i:=0 to MAX_ARMY do
  begin
    CR:=mHeros[mid].Armys[i].t;
    n:=mHeros[mid].Armys[i].n;
    if CR > -1
    then
    begin
      TDXWPanel(ObjectList[DxO_Crea2+i]).tag:=CR+2;
      TDXWLabel(ObjectList[DxO_Crea2+i]).caption:=inttostr(n);
    end
    else
    begin
      TDXWPanel(ObjectList[DxO_Crea2+i]).tag:=0;
      TDXWLabel(ObjectList[DxO_Crea2+i]).caption:='';
    end;
  end;

  for i:=0 to MAX_PACK do
  begin
    AR:=mHeros[mid].Arts[i];
    //TDXWPanel(ObjectList[DxO_Art2+i]).Visible:= not(artid =-1);
    TDXWPanel(ObjectList[DxO_Art2+i]).Tag:=AR;
    //if artid=-1 then TDXWPanel(ObjectList[DxO_Art2+i]).Tag:=127;
    //TDXWPanel(ObjectList[DxO_Art2+i]).Caption:=inttostr(i);
  end;
end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.PnlCrea1(Sender: TObject);
var
  slot: integer;
begin
  slot:=ObjectList.DxO_MouseOver-DxO_Crea1;
  TDXWPanel(sender).Focused:=gArmy.Select(1,Slot);
  Update;
  AutoRefresh:=true;
end;
{-----------------------------------------------------------------------------}
procedure TSnMeet.PnlCrea2(Sender: TObject);
var
  slot: integer;
begin
  slot:=ObjectList.DxO_MouseOver-DxO_Crea2;
  TDXWPanel(sender).Focused:=gArmy.Select(2,Slot);
  Update;
  AutoRefresh:=true;
end;
{-----------------------------------------------------------------------------}

end.
