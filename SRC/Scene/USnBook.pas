unit USnBook;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DxWLoad , DXWScene, UType;

type
  TSnBook= class(TDxScene)
  private
    DxO_Tab, DxO_Spell, DxO_Text, DxO_Level, DxO_Page: integer;
    HE, Page: integer;
    ShowCbt: boolean;
    SPORDER: Array [0..MAX_SPEL] of integer;
  public
    constructor Create(aHE:integer);
    procedure Refresh;
    procedure BtnSpells(Sender:TObject);
    procedure BtnSpellsR(Sender:TObject);
    procedure BtnTab(Sender:TObject);
    procedure BtnCbt(Sender:TObject);
    procedure BtnAdv(Sender:TObject);
    procedure BtnLeft(Sender:TObject);
    procedure BtnRight(Sender:TObject);
  end;

var
  SnBook: TSnBook;

Const
  SCHOOLLEVEL : array [0..3] of string = ('bas','nov', 'mas', 'exp');
implementation

uses UBattle, UMain, UFile, USnDialog,  UHE, USnBattleField;

{----------------------------------------------------------------------------}
constructor TSnBook.create(aHE:integer);
var
  c,l,j,k: integer;
begin
  inherited  Create('SnBook');
  HE:=aHE;
  Page:=0;
  Left:=50;
  HintX:=70;
  HintY:=570;
  ShowCbt:=true;
  AddBackground('SPELBACK');
  LoadSprite(ImageList,'SPELLS');

  AddFrame(32,44,480,406,BtnOk,false);
  ObjectList.Items[ObjectList.count-1].name:='btnok';
  AddFrame(32,44,360,406,BtnAdv,false);
  ObjectList.Items[ObjectList.count-1].name:='btnadv';
  AddFrame(32,44,220,406,BtnCbt,false);
  ObjectList.Items[ObjectList.count-1].name:='btncbt';

  DxO_Level:=ObjectList.Count; //SPLEV...

  AddSprPanel('SPLEVF',115,95);
  AddSprPanel('SPLEVF',205,95);
  AddSprPanel('SPLEVF',115,190);
  AddSprPanel('SPLEVF',205,190);
  AddSprPanel('SPLEVF',115,285);
  AddSprPanel('SPLEVF',205,285);
  AddSprPanel('SPLEVF',330,95);
  AddSprPanel('SPLEVF',420,95);
  AddSprPanel('SPLEVF',330,190);
  AddSprPanel('SPLEVF',420,190);
  AddSprPanel('SPLEVF',330,285);
  AddSprPanel('SPLEVF',420,285);

  AddSprPanel('SPLEVA',115,95);
  AddSprPanel('SPLEVA',205,95);
  AddSprPanel('SPLEVA',115,190);
  AddSprPanel('SPLEVA',205,190);
  AddSprPanel('SPLEVA',115,285);
  AddSprPanel('SPLEVA',205,285);
  AddSprPanel('SPLEVA',335,95);
  AddSprPanel('SPLEVA',425,95);
  AddSprPanel('SPLEVA',335,190);
  AddSprPanel('SPLEVA',420,190);
  AddSprPanel('SPLEVA',330,285);
  AddSprPanel('SPLEVA',420,285);

  AddSprPanel('SPLEVW',115,95);
  AddSprPanel('SPLEVW',205,95);
  AddSprPanel('SPLEVW',115,190);
  AddSprPanel('SPLEVW',205,190);
  AddSprPanel('SPLEVW',115,285);
  AddSprPanel('SPLEVW',205,285);
  AddSprPanel('SPLEVW',330,95);
  AddSprPanel('SPLEVW',420,95);
  AddSprPanel('SPLEVW',330,190);
  AddSprPanel('SPLEVW',420,190);
  AddSprPanel('SPLEVW',330,285);
  AddSprPanel('SPLEVW',420,285);

  AddSprPanel('SPLEVE',115,95);
  AddSprPanel('SPLEVE',205,95);
  AddSprPanel('SPLEVE',115,190);
  AddSprPanel('SPLEVE',205,190);
  AddSprPanel('SPLEVE',115,285);
  AddSprPanel('SPLEVE',205,285);
  AddSprPanel('SPLEVE',330,95);
  AddSprPanel('SPLEVE',420,95);
  AddSprPanel('SPLEVE',330,190);
  AddSprPanel('SPLEVE',420,190);
  AddSprPanel('SPLEVE',330,285);
  AddSprPanel('SPLEVE',420,285);

  DxO_Spell:=ObjectList.Count;
  AddSprPanel('SPELLS',115,95, BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',205,95, BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',115,190,BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',205,190,BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',115,285,BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',205,285,BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',330,95, BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',420,95, BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',330,190,BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',420,190,BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',330,285,BtnSPELLS,-1,BtnSPELLSR);
  AddSprPanel('SPELLS',420,285,BtnSPELLS,-1,BtnSPELLSR);

  DxO_Text:=ObjectList.Count;
  AddLabel_YellowCenter('',110,159,86,7);
  AddLabel_YellowCenter('',200,159,86,7);
  AddLabel_YellowCenter('',110,254,86,7);
  AddLabel_YellowCenter('',200,254,86,7);
  AddLabel_YellowCenter('',110,349,86,7);
  AddLabel_YellowCenter('',200,349,86,7);
  AddLabel_YellowCenter('',325,159,86,7);
  AddLabel_YellowCenter('',415,159,86,7);
  AddLabel_YellowCenter('',325,254,86,7);
  AddLabel_YellowCenter('',415,254,86,7);
  AddLabel_YellowCenter('',325,349,86,7);
  AddLabel_YellowCenter('',415,349,86,7);

  AddLabel_Center('',110,169,86,7);
  AddLabel_Center('',200,169,86,7);
  AddLabel_Center('',110,264,86,7);
  AddLabel_Center('',200,264,86,7);
  AddLabel_Center('',110,359,86,7);
  AddLabel_Center('',200,359,86,7);
  AddLabel_Center('',325,169,86,7);
  AddLabel_Center('',415,169,86,7);
  AddLabel_Center('',325,264,86,7);
  AddLabel_Center('',415,264,86,7);
  AddLabel_Center('',325,359,86,7);
  AddLabel_Center('',415,359,86,7);

  DxO_Tab:=ObjectList.Count;
  AddSprPanel('SPELTAB',530,90,BtnTab);
  TDXWPanel(ObjectList[DxO_Tab]).Tag:=4;   //SchoolAll
  AddLabel_Center('Pts=',416,416,34,8);

  DxO_Page:=ObjectList.Count;
  AddPanel('SPELTRNL',97,76,BtnLeft);
  AddPanel('SPELTRNR',486,75,BtnRight);
  AddLabel('',195,385,7);
  AddLabel('',405,385,7);

  k:=-1;
  for l:=1 to 5 do
  begin
    for c:=0 to 3 do
    begin
      for j:= 0 to MAX_SPEL do
      begin
        if (iSPEL[j].school=c) and (iSPEL[j].level= l)
        then begin
          k:=k+1;
          SPORDER[k]:=j;
        end;
      end;
    end;
  end;

  Refresh;
  UpdateColor(mPL,1);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnBook.BtnLeft(Sender:TObject);
begin
  Page:=max(Page-1,0);
  Refresh;
end;
{----------------------------------------------------------------------------}
procedure TSnBook.BtnRight(Sender:TObject);
begin
  Page:=min(Page+1,4);
  Refresh;
end;
{----------------------------------------------------------------------------}
procedure TSnBook.BtnSpellsR(Sender:TObject);
var
  SP:integer;
begin
  SP:=TDXWPanel(sender).Tag;
  TSnDialog.Create('',dsSpell,SP,HE)
end;
{----------------------------------------------------------------------------}
procedure TSnBook.BtnSpells(Sender:TObject);
var
  SP:integer;
  CanSpell:boolean;
begin
  SP:=TDXWPanel(sender).Tag;
  if SP=-1 then exit;
  if  (parent is TSnBattleField) then
  begin
    CanSpell:=true;
    //BT sepl imune to berserk
    if SP=SP59_Berserk then
    if cmd_HE_FindART(bHeroDef,AR100_PendantofDispassion)>0 then CanSpell:=false;
    //BT spel imune to blind
    if SP=SP62_Blind then
    if cmd_HE_FindART(bHeroDef,AR101_PendantofSecondSight)>0 then CanSpell:=false;
    //BT spel imune to curse
    if SP=SP42_Curse then
    if cmd_HE_FindART(bHeroDef,AR102_PendantofHoliness)>0 then CanSpell:=false;
    //BT spel imune to death ripple
    if SP=SP24_DeathRipple then
    if cmd_HE_FindART(bHeroDef,AR103_PendantofLife)>0 then CanSpell:=false;
    //BT spel imune to destroy undead
    if SP=SP25_DestroyUndead then
    if cmd_HE_FindART(bHeroDef,AR104_PendantofDeath)>0 then CanSpell:=false;
    //BT spel imune to hypnotise
    if SP=SP60_Hypnotize then
    if cmd_HE_FindART(bHeroDef,AR105_PendantofFreeWill)>0 then CanSpell:=false;
    //BT spel imune to lightning bolt/chain lightning
    if SP=SP19_ChainLightning then
    if cmd_HE_FindART(bHeroDef,AR106_PendantofNegativity)>0 then CanSpell:=false;
    //BT spel imune to forgetfullne
    if SP=SP61_Forgetfulness then
    if cmd_HE_FindART(bHeroDef,AR107_PendantofTotalRecall)>0 then CanSpell:=false;
    cmd_BA_allowSpellAction(SP,CanSpell);
    AutoDestroy:=true;
  end
  else
    TSnDialog.Create('',dsSpell,SP,HE);
end;
{----------------------------------------------------------------------------}
procedure TSnBook.BtnTab(Sender:TObject);
var
  y:integer;
begin
  y:=DxMouse.y;
  Case Y of
     24..140: TDxWPanel(Sender).tag:=0; //SCHOOL1_Air
    141..200: TDxWPanel(Sender).tag:=3; //SCHOOL3_Earth
    201..260: TDxWPanel(Sender).tag:=1; //SCHOOL0_Fire
    261..340: TDxWPanel(Sender).tag:=2; //SCHOOL2_Water
    341..420: TDxWPanel(Sender).tag:=4; //SCHOOL4_ALL
  end;
  page:=0;
  Refresh;
end;
{----------------------------------------------------------------------------}
procedure TSnBook.BtnCbt(Sender:TObject);
begin
  ShowCbt:=true;
  Refresh;
end;
{----------------------------------------------------------------------------}
procedure TSnBook.BtnAdv(Sender:TObject);
begin
  ShowCbt:=false;
  Refresh;
end;
{----------------------------------------------------------------------------}
procedure TSnBook.Refresh;
var
  school: integer;
  costspel: integer ;
  i,j,k,SP,SK: integer;
begin
  case TDXWPanel(Objectlist[DxO_Tab]).Tag of
    0: school:=SCHOOL1_Air;
    1: school:=SCHOOL0_Fire;
    2: school:=SCHOOL2_Water;
    3: school:=SCHOOL3_Earth;
    4: school:=SCHOOL4_All;
  end;
  i:=-1;
  j:=0;
  for k:=0 to MAX_SPEL do
  begin
    SP:=SPORDER[k];
    if ((iSpel[SP].school=school) or (school=SCHOOL4_All)) then
    if iSpel[SP].cbt=ShowCbt then
    begin
      if Cmd_HE_SPEL(HE,SP)   // check if i have the spel in book or via a tome
      then
      begin
        if j < 12*page  then
        begin
          inc(j);
          continue;
        end;
        i:= j mod 12;

        Case iSpel[SP].school of
          SCHOOL0_Fire:   SK:=SK14_Fire_Magic;
          SCHOOL1_Air:    SK:=SK15_Air_Magic;
          SCHOOL2_Water:  SK:=SK16_Water_Magic;
          SCHOOL3_Earth : SK:=SK17_Earth_Magic;
        end;

        case mHeros[HE].SSK[SK] of
          0: costSpel:=iSpel[SP].BAS.cost;
          1: costSpel:=iSpel[SP].NOV.cost;
          2: costSpel:=iSpel[SP].EXP.cost;
          3: costSpel:=iSpel[SP].MAS.cost;
        end;

        TDXWPanel(ObjectList[DxO_Level+i]).visible:=false;
        TDXWPanel(ObjectList[DxO_Level+12+i]).visible:=false;
        TDXWPanel(ObjectList[DxO_Level+24+i]).visible:=false;
        TDXWPanel(ObjectList[DxO_Level+36+i]).visible:=false;
        TDXWPanel(ObjectList[DxO_Spell+i]).Tag:=SP;
        TDXWPanel(ObjectList[DxO_Spell+i]).name:=iSpel[SP].name +  ' (' + inttostr(iSpel[SP].level) + ' lvl)' ;

        //it is not spel level but magie level of heroes .. so dont use iSpel[SP].level-2;
        TDXWPanel(ObjectList[DxO_Level+12*(iSpel[SP].school)+i]).visible:=true;
        TDXWPanel(ObjectList[DxO_Level+12*(iSpel[SP].school)+i]).Tag:=mHeros[HE].SSK[SK];

        TDXWLabel(ObjectList[DxO_Text+i]).Caption:=iSpel[SP].name;
        TDXWLabel(ObjectList[DxO_Text+i+12]).Caption:='level '+ inttostr(iSpel[SP].level) + '/' + SCHOOLLEVEL[mHeros[HE].SSK[SK]]
        + NL +
        'Spell Points: '+ inttostr(costSPel);
        TDXWLabel(ObjectList[DxO_Text+i]).name:=iSpel[SP].name +  ' (' + inttostr(iSpel[SP].level) + ' lvl)';
        TDXWPanel(ObjectList[DxO_Spell+i]).visible:=true;
        inc(j);
        if j=12*page+12 then break;
      end;

    end;
  end;
  for SP:=i+1 to 11 do
  begin
     TDXWPanel(ObjectList[DxO_Spell+SP]).visible:=false;
     TDXWLabel(ObjectList[DxO_Text+SP]).Caption:='';
     TDXWLabel(ObjectList[DxO_Text+12+SP]).Caption:='';
     TDXWPanel(ObjectList[DxO_Level+SP]).visible:=false;
     TDXWPanel(ObjectList[DxO_Level+12+SP]).visible:=false;
     TDXWPanel(ObjectList[DxO_Level+24+SP]).visible:=false;
     TDXWPanel(ObjectList[DxO_Level+36+SP]).visible:=false;
  end;

  TDXWLabel(Objectlist[DxO_Tab+1]).caption:=inttostr(mHeros[HE].PSKB.ptm);
  TDXWLabel(Objectlist[DxO_Page+2]).caption:='P'+ inttostr(2*page);
  TDXWLabel(Objectlist[DxO_Page+3]).caption:='P'+ inttostr(2*page+1);
end;
{----------------------------------------------------------------------------}
end.
