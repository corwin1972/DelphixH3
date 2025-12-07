unit UCT;

interface

uses  Forms, SysUtils, UType;

  function  Cmd_CT_ShowBuild(CT,BU: integer): boolean;
  function  Cmd_CT_ShowWhatToBuild(CT,Slot: integer): integer;
  function  Cmd_CT_CanBuild(CT,BU: integer): integer;
  function  Cmd_CT_HasDefense(CT: integer): boolean;
  procedure Cmd_CT_BuyBuild(CT,BU:integer);
  procedure Cmd_CT_BuyCons(CT,CO: integer);
  procedure Cmd_CT_BuyHero(CT,Slot:integer);
  procedure Cmd_CT_AddProd(CT,prod: integer);
  procedure Cmd_CT_ExtProd(CT,slot: integer);
  procedure Cmd_CT_AddCrea(CT,CR,n: integer);
  procedure Cmd_CT_AddSpel(CT,level: integer);
  procedure Cmd_CT_AddLibSpel(CT: integer);
  procedure Cmd_CT_NewWeek;
  procedure Cmd_CT_NewDay;
  function  Cmd_CT_Income(CT: integer): integer;
  function  Cmd_CT_find(pos: TPOS): integer;
  procedure Cmd_CT_SwitchHero(CT:integer);
  function  Cmd_CT_CityLevel(CT: integer): integer;
  function  Cmd_CT_FortLevel(CT: integer): integer;
  function  Cmd_CT_SpelLevel(CT: integer): integer;
  function  Cmd_CT_ProdArmy(CT,slot:integer; var text:string): integer;
  procedure Cmd_HE_VisitCity(HE,CT: integer);
  procedure Cmd_HE_VisitCityMage(HE,CT:integer);
  procedure Cmd_HE_VisitCitySkill(HE,CT:integer);
  procedure Cmd_CT_Annexion(PL,OB: integer);
implementation

Uses Math, UAI, UEnter, UMap, USnGame,USnDialog, USnInfoCrea, USnInfoRes,
     UBattle,USnLevelUp, UPathRect, USnBuyCrea, USnInfoPlayer, USnSepCrea, UHE, UArmy, UFile;

{----------------------------------------------------------------------------}
procedure Cmd_CT_Annexion(PL,OB: integer);
VAR
  CT,i:integer;
begin
  CT:=mObjs[OB].v;
  mPlayers[PL].LstCity[mPlayers[PL].nCity]:=CT;
  inc(mPlayers[PL].nCity);
  mObjs[OB].pid:=PL;
  mCitys[CT].pid:=PL;
  for i:=0 to MAX_ARMY do begin
   mCitys[CT].gararmys[i].n:=0;
   mCitys[CT].gararmys[i].t:=-1;
  end;
end;
{----------------------------------------------------------------------------}
function  Cmd_CT_hasDefense(CT: integer): boolean;
var
  i : integer;
begin
  result:=false;
  for i:=0 to 6 do
  if (mCitys[CT].GarArmys[i].t > -1)   then  result:=true;
end;
{----------------------------------------------------------------------------}
function  Cmd_CT_find(pos: TPOS): integer;
var
  i : integer;
begin
  result:=-1;
  for i:=0 to nCitys-1 do
  if ((mCitys[i].pos.x-2=pos.x) and  (mCitys[i].pos.y=pos.y) and (mCitys[i].pos.l=pos.l))
  then result:=i;
end;
{----------------------------------------------------------------------------}
function Cmd_CT_CityLevel(CT: integer): integer;
var
  lvl: integer;
begin
  lvl:=0;
  if mcitys[CT].Cons[Cons0_Town]    then lvl:=1;
  if mcitys[CT].Cons[Cons1_City]    then lvl:=2;
  if mcitys[CT].Cons[Cons2_Capitol] then lvl:=3;
  result:=lvl;
end;
{----------------------------------------------------------------------------}
function Cmd_CT_FortLevel(CT: integer): integer;
var
  lvl: integer;
begin
  lvl:=0;
  if mcitys[CT].Cons[Cons3_Fort]    then lvl:=1;
  if mcitys[CT].Cons[Cons4_Citadel] then lvl:=2;
  if mcitys[CT].Cons[Cons5_Castle]  then lvl:=3;
  result:=lvl;
end;
{----------------------------------------------------------------------------}
function Cmd_CT_SpelLevel(CT: integer): integer;
var
  lvl: integer;
begin
  lvl:=0;
  if mcitys[CT].Cons[Cons11_Mage1] then lvl:=1;
  if mcitys[CT].Cons[Cons12_Mage2] then lvl:=2;
  if mcitys[CT].Cons[Cons13_Mage3] then lvl:=3;
  if mcitys[CT].Cons[Cons14_Mage4] then lvl:=4;
  if mcitys[CT].Cons[Cons15_Mage5] then lvl:=5;
  result:=lvl;
end;
{----------------------------------------------------------------------------}
function Cmd_CT_Income(CT: integer): integer;
var
  gold: integer;
begin
  gold:=500;
  if mCitys[CT].Cons[Cons0_Town]    then gold:=1000;
  if mCitys[CT].Cons[Cons1_City]    then gold:=2000;
  if mCitys[CT].Cons[Cons2_Capitol] then gold:=4000;
  if mCitys[CT].Cons[Cons17_Grail]  then gold:=6000;
  result:=gold;
end;
{----------------------------------------------------------------------------}
procedure Cmd_CT_NewDay;
var
  CT: integer;
begin
  for CT:=0 to nCitys-1 do
    mCitys[CT].hasBuild:=0;
end;
{----------------------------------------------------------------------------}
procedure Cmd_CT_NewWeek;
type
  weekType=(NORMAL, DOUBLE_GROWTH, BONUS_GROWTH, DEITYOFFIRE, PLAGUE, NO_ACTION);
var
  CT, slot:integer;
  specialWeek: weektype;
  specialMonster: integer;
  monthType : integer;
  newmonth: boolean;
  s:string;
begin
  //TODO week of XXX bonus
  mData.rumor:=random(TxtRandTVRN.Count);

  specialWeek:=NORMAL;
  mData.weekmsg:=format(TxtARRAYTXT[128],['testweek']);
  newmonth:=(mData.Week=4);

  monthType:=random(100);
  if (newmonth) then
  begin
      specialWeek:=NORMAL;
      mData.weekmsg:=format(TxtARRAYTXT[125],['testmonth']);
    if (monthType < 40) then
    begin
      specialWeek:=DOUBLE_GROWTH; // ALL
      mData.weekmsg:=TxtARRAYTXT[126];
    end
    else if (monthType < 50) then
    begin
      specialWeek:=PLAGUE;
      mData.weekmsg:=TxtARRAYTXT[127];
    end;
  end;
  if not(newmonth) then
    if (monthType < 25)  then  begin
       specialWeek:=BONUS_GROWTH;
       specialMonster:=random(128);
       mData.weekmsg:=format(TxtARRAYTXT[129],[iCrea[specialMonster].name,iCrea[specialMonster].name]);
  end;

  for CT:=0 to nCitys-1 do
  begin
    mCitys[CT].hasbuild:=0;
    for slot:=0 to MAX_ARMY do
    begin
      case specialWeek of
        NORMAL: mCitys[CT].DispArmys[slot].n:=mcitys[CT].DispArmys[slot].n+Cmd_CT_ProdArmy(CT,slot,s);
        PLAGUE: mCitys[CT].DispArmys[slot].n:=mCitys[CT].DispArmys[slot].n div 2;
        BONUS_GROWTH: begin
          mCitys[CT].DispArmys[slot].n:=mcitys[CT].DispArmys[slot].n+Cmd_CT_ProdArmy(CT,slot,s);
          if  mCitys[CT].DispArmys[slot].t=specialMonster then mCitys[CT].DispArmys[slot].n:=mcitys[CT].DispArmys[slot].n+5;
      end;
    end;
  end;
  end;

end;

{-----------------------------------------------------------------------------
  Procedure:   Cmd_CT_AddSpel
  Date:        24-mai-2008
  Description: Add new level to CT magic tower
-----------------------------------------------------------------------------}
procedure Cmd_CT_AddSpel(CT,level: integer);
var
  i,j,r,n : integer;
  ok: boolean;
  max : integer;
const
  first : array [1..5] of byte = (1,7,12,16,19);
begin
  with mCitys[CT] do
  begin
    if (mCitys[CT].t=2) and mCitys[CT].cons[Cons18_SP1]
    then max:=6 else max:=5;
    for i:=0 to max-level do
    begin
      ok:=false;
      repeat
        n:=0;
        r:=random(60);
        for j:=0 to MAX_SPEL-1 do
        begin
        if  iSPEL[j].level=level then n:=n+iSPEL[j].rnd[mCitys[CT].t];
        if n>r then break
        end;
        if Spels[j]=0 then ok:=true;
      until ok;
      //repeat
      //  j:=random(MAX_SPEL)
      //until ((iSPEL[j].level=level) and (Spels[j]=0));
      Spels[j]:=first[level]+i;
    end;
    if VisHero <>-1 then Cmd_HE_VisitCityMage(VisHero,CT);
    if GarHero <>-1 then Cmd_HE_VisitCityMage(GarHero,CT);
  end;
end;
{-----------------------------------------------------------------------------
  Procedure:   Cmd_CT_AddLibSpel
  Date:        24-mai-2008
  Description: Add 1 spel to each level of CT magic tower
-----------------------------------------------------------------------------}
procedure Cmd_CT_AddLibSpel(CT: integer);
var
  i,j : integer;
const
  last : array [1..5] of byte = (6,11,15,18,20);
begin
  with mCitys[CT] do
  begin
    for i:=1 to Cmd_CT_SpelLevel(CT) do
    begin
      repeat
        j:=random(MAX_SPEL)
      until ((iSPEL[j].level=i) and (Spels[j]=0));
      Spels[j]:=last[i];
    end;
    if VisHero <>-1 then Cmd_HE_VisitCityMage(VisHero,CT);
    if GarHero <>-1 then Cmd_HE_VisitCityMage(GarHero,CT);
  end;
end;
{----------------------------------------------------------------------------}
function Cmd_CT_ProdArmy(CT,slot:integer;var text:string): integer; //get prodArmy + mes
var
  bonus: integer;
  add,i,CR:integer;
  He:integer;
begin
  result:=0;
  with mCitys[CT] do
  begin
    CR:=ProdArmys[slot].t;
    mDialog.mes:='no info';
    // bonus Castle
    bonus:=0;
    if Cons[Cons4_Citadel] then bonus:=50 ;
    if Cons[Cons5_Castle]  then bonus:=100;
    if Cons[Cons17_Grail]  then bonus:=200;

    text:='';
    if CR=-1 then exit;
    add:=iCrea[CR].growth; //ProdArmys[slot].n;

    text:=text+ NL +'Basic Growth = '+ inttostr(iCrea[CR].growth);
    if bonus > 0 then
    begin
      text:=text+ NL +'Castle Bonus = '+ inttostr(bonus)+'%   ';
      add:=((100  + bonus)*add) div 100;
    end;

    bonus:=0;

    // bonus Legion ART of visited heroes
    HE:=VisHero;
    if HE > -1 then
    case slot of
      1: bonus:=5*Cmd_HE_findArt(HE,AR118_LegsofLegion);
      2: bonus:=4*Cmd_HE_findArt(HE,AR119_LoinsofLegion);
      3: bonus:=3*Cmd_HE_findArt(HE,AR120_TorsoofLegion);
      4: bonus:=2*Cmd_HE_findArt(HE,AR121_ArmsofLegion);
      5: bonus:=Cmd_HE_findArt(HE,AR122_HeadofLegion);
    end;

    if bonus > 0 then text:=text+ NL + 'Art ' +iART[118+slot].name + ' + ' + inttostr(bonus);
    add:=add+bonus;

    // bonus Legion ART of garnison heroes
    bonus:=0;
    HE:=GarHero;
    if HE > -1 then
    case slot of
      1: bonus:=5*Cmd_HE_findArt(HE,AR118_LegsofLegion);
      2: bonus:=4*Cmd_HE_findArt(HE,AR119_LoinsofLegion);
      3: bonus:=3*Cmd_HE_findArt(HE,AR120_TorsoofLegion);
      4: bonus:=2*Cmd_HE_findArt(HE,AR121_ArmsofLegion);
      5: bonus:=Cmd_HE_findArt(HE,AR122_HeadofLegion);
    end;

    if bonus > 0 then text:=text+ NL+ 'Art ' +iART[118+slot].name + ' + ' + inttostr(bonus);
    add:=add+bonus;

    // bonus of owned crea generator
    bonus:=0;
      for i:=0 to nObjs-1 do
      if  ((mObjs[i].t=OB17_Generator)
       and  (2*(mObjs[i].def-835)=CR)
       and  (mObjs[i].pid=mCitys[CT].pid) )
      then inc(bonus);
     if bonus > 0 then text:=text+ NL + 'Generator Bonus =' + inttostr(bonus);
    add:=add+bonus;
  end;

  result:=add;
  text:='{Weekly ' + iCrea[CR].name + ' growth is ' +  inttostr(add) + '}'+ NL + text;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_VisitCity(HE,CT:integer);
begin
  mCitys[CT].VisHero:=HE;
  mHeros[HE].VisTown:=CT;
  Cmd_HE_VisitCityMage(HE,CT);
  Cmd_HE_VisitCitySkill(HE,CT);
  if mPlayers[mPL].isCPU then cmd_AI_Recruit(HE,CT);
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_VisitCityMage(HE,CT:integer);
var
  SP:integer;
begin
  if mHeros[HE].hasbook=false then exit;
  for SP:=0 to MAX_SPEL do
  begin
    if iSpel[SP].level <= 3 + mHeros[HE].SSK[SK07_Wisdom]+1
    then mHeros[HE].spels[SP]:=((mHeros[HE].spels[SP]) or (mCitys[ct].spels[SP] <>0));
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_VisitCitySkill(HE,CT:integer);
var
  txtid:integer;
begin
  if mHeros[HE].VisCTskill[CT] then exit;
  txtid:=580;
  case mCitys[CT].t of
    0: exit;  //0: mHeros[HE].mov extented  //581
    1: exit;  //1: mHeros[HE].Luck +2 extented for a hero during a siege.
    2: if mCitys[CT].Cons[Cons19_SP2] then
    begin
      txtid:=582;
      ProcessInfo(TxtGenrlTxt[txtId]);
      mHeros[HE].PSKB.kno:=mHeros[HE].PSKB.kno+1;
      mHeros[HE].VisCTskill[CT]:=true;
    end;

    3: if mCitys[CT].Cons[Cons20_SP3] then
    begin
      txtid:=583;
      ProcessInfo(TxtGenrlTxt[txtId]);
      mHeros[HE].PSKB.pow:=mHeros[HE].PSKB.pow+1;
      mHeros[HE].VisCTskill[CT]:=true;
    end;

    4: exit; //4 : 10% to the Necromancy skill to all necro
    5: if mCitys[CT].Cons[Cons20_SP3] then
    begin
      txtid:=584;
      ProcessInfo(TxtGenrlTxt[txtId]);
      cmd_HE_addexp(HE, 1000);
      mHeros[HE].VisCTskill[CT]:=true;
    end;
    6: if mCitys[CT].Cons[Cons21_SP4] then
    begin
      txtid:=585;
      ProcessInfo(TxtGenrlTxt[txtId]);
      mHeros[HE].PSKB.att:=mHeros[HE].PSKB.att+1;
      mHeros[HE].VisCTskill[CT]:=true;
    end;
    7: if mCitys[CT].Cons[Cons18_SP1] then
    begin
      txtid:=586;
      ProcessInfo(TxtGenrlTxt[txtId]);
      mHeros[HE].PSKB.def:=mHeros[HE].PSKB.def+1;
      mHeros[HE].VisCTskill[CT]:=true;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_CT_AddCrea(CT,CR,n: integer);
var
  i: integer;
  slot: integer;
  pArmys: ^TArmys;
begin
  slot:=(CR mod 14) div 2;
  with mCitys[CT] do
  begin
    dispArmys[slot].n:=dispArmys[slot].n-n;
    if GarHero=-1
    then pArmys:=@GarArmys
    else pArmys:=@mHeros[GarHero].Armys;

    //search first of slot with same crea
    for i:=0 to MAX_ARMY do
    begin
      if pArmys[i].t=CR then
      begin
        pArmys[i].n:=pArmys[i].n+n;
        mPlayers[mPL].res[6]:=mPlayers[mPL].res[6]-n*iCrea[CR].cost;
        exit
      end;
    end;
    for i:=0 to MAX_ARMY do
    begin
      if pArmys[i].n=0 then
      begin
        pArmys[i].t:=CR;
        pArmys[i].n:=n;
        mPlayers[mPL].res[6]:=mPlayers[mPL].res[6]-n*iCrea[CR].cost;
        exit
      end;
    end;

  dispArmys[slot].n:=dispArmys[slot].n+n;
  end;
  ProcessInfo('No Free slot to add this crea , Sorry');
end;
{----------------------------------------------------------------------------}
procedure Cmd_CT_BuyHero(CT, slot: integer);
var
  HE,PL: integer;
begin
  PL:=mCitys[CT].pid;
  HE:=mPlayers[PL].TavHero[slot];
  with mHeros[HE] do
  begin
    pos:=mCitys[CT].pos;
    pos.x:=mCitys[CT].pos.x-2;
    pid:=PL;
    obX:=mTiles[pos.x,pos.y,pos.l].obX;    // hero over a city
    //mTiles[pos.x,pos.y,pos.l].obX.t:=OB34_Hero;
    //mTiles[pos.x,pos.y,pos.l].obX.u:=HE div 8;
    //mTiles[pos.x,pos.y,pos.l].obX.oid:=nObjs;
    //mTiles[pos.x,pos.y,pos.l].p1:=2;

  end;
  mPlayers[PL].res[6]:=mPlayers[PL].res[6]-2500;
  Cmd_He_Add(HE);
  Cmd_HE_VisitCity(HE,CT);
end;
{----------------------------------------------------------------------------}
procedure Cmd_CT_SwitchHero(CT:integer);
var
  tmpHero,i,j  : integer;  //temp value
begin
  with mCitys[CT] do
  begin
    if (GarHero<>-1) and  (VisHero<>-1)
    then begin
      tmpHero:= GarHero;
      GarHero:= VisHero;
      VisHero:= tmpHero;
      gArmy.initCT(CT);
      //Cmd_HE_Del(GarHero);

      with mHeros[GarHero] do begin
        mObjs[oid].Deading:=500;
        for i:=0 to mPlayers[pid].nHero-1 do
          if  mPlayers[pid].LstHero[i]=id then break;
        for j:=i to mPlayers[pid].nHero-1 do
          mPlayers[pid].LstHero[j]:=mPlayers[pid].LstHero[j+1];
        mPlayers[pid].nHero:=mPlayers[pid].nHero-1;
        mTiles[pos.x,pos.y,pos.l].obX:=obX;
        if obX.t=0
         then  mTiles[pos.x,pos.y,pos.l].P1:=0;

        mPlayers[pid].ActiveHero:=mPlayers[pid].LstHero[0];
        if  mPlayers[pid].nHero=0
        then begin
         mPlayers[pid].ActiveHero:=-1;
         mPlayers[pid].ActiveCity:=mPlayers[pid].LstCity[0];
        end;
      end;

      Cmd_HE_Add(VisHero);
      if mObjs[mHeros[VisHero].oid].Deading=500
      then mObjs[mHeros[VisHero].oid].Deading:=-1
      else SnGame.AddHero(VisHero);
      exit;
    end;

    if (GarHero=-1) and (VisHero=-1)
    then exit;    // should not have occur

    if (GarHero<>-1) and (VisHero=-1)
    then begin
      VisHero:= GarHero;
      GarHero:= -1;
      gArmy.initCT(CT);
      Cmd_HE_Add(VisHero);
      if mObjs[mHeros[VisHero].oid].Deading=500
      then mObjs[mHeros[VisHero].oid].Deading:=-1
      else SnGame.AddHero(VisHero);
      exit;
    end;

    if (GarHero=-1) and (VisHero<>-1)
    then
    // try to merge the creature
    if gArmy.merge(CT) then begin
      GarHero:= VisHero;
      VisHero:=-1;
      gArmy.initCT(CT);
      //Cmd_HE_Del(GarHero);

      with mheros[GarHero] do
      begin
        mObjs[oid].Deading:=500;
        for i:=0 to mPlayers[pid].nHero-1 do
          if  mPlayers[pid].LstHero[i]=id then break;
        for j:=i to mPlayers[pid].nHero-1 do
          mPlayers[pid].LstHero[j]:=mPlayers[pid].LstHero[j+1];
        mPlayers[pid].nHero:=mPlayers[pid].nHero-1;
        mTiles[pos.x,pos.y,pos.l].obX:=obX;
        if obX.t=0 then
          mTiles[pos.x,pos.y,pos.l].P1:=0;

        mPlayers[pid].ActiveHero:=mPlayers[pid].LstHero[0];
        if  mPlayers[pid].nHero=0 then
        begin
          mPlayers[pid].ActiveHero:=-1;
          mPlayers[pid].ActiveCity:=mPlayers[pid].LstCity[0];
        end;
      end;
      exit;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_CT_AddProd(CT,prod: integer);  // prod 0..13
var
  CR :integer;
  slot: integer;
begin
  with mCitys[CT] do
  begin
    CR:=prod+14*t;
    slot:=prod div 2;
    ProdArmys[slot].t:=CR;
    ProdArmys[slot].n:=iCrea[CR].growth;
    //TODO why such calculation
    //DispArmys[slot].n:=DispArmys[slot].n + max(ProdArmys[slot].n,1) ;
    DispArmys[slot].n:=ProdArmys[slot].n;
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_CT_ExtProd(CT,slot: integer);  // slot 0..6
var
  CR :integer;
begin
  with mCitys[CT] do
  begin
    CR:=ProdArmys[slot].t;
    ProdArmys[slot].n:=iCrea[CR].growth+iCrea[CR].growH;
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_CT_BuyBuild(CT,BU:integer);
var
  CO: integer;
  T:  byte;
  i : integer;
  procedure cmd_CT_BuildNeutral;
  begin
    case BU of
      0: CO:=Cons11_Mage1;
      1: CO:=Cons12_Mage2;
      2: CO:=Cons13_Mage3;
      3: CO:=Cons14_Mage4;
      4: CO:=Cons15_Mage5;
      5: CO:=Cons6_Tavern;
      6: CO:=Cons16_Shipyard;
      7: CO:=Cons3_Fort;
      8: CO:=Cons4_Citadel;
      9: CO:=Cons5_Castle;
     10: CO:=-1;
     11: CO:=Cons0_Town;
     12: CO:=Cons1_City;
     13: CO:=Cons2_Capitol;
     14: CO:=Cons8_Market;
     15: CO:=Cons9_Silo;
     16: CO:=Cons7_Blacksmith;
    end;
  end;

   procedure cmd_CT_BuildDwelling;
  begin
    case BU of
      26: CO:=Cons17_Grail;
      27: CO:=-1;
      28: CO:=-1;
      29: CO:=-1;
      30: CO:=Cons22_StdCr0;
      31: CO:=Cons25_StdCr1;
      32: CO:=Cons28_StdCr2;
      33: CO:=Cons31_StdCr3;
      34: CO:=Cons34_StdCr4;
      35: CO:=Cons37_StdCr5;
      36: CO:=Cons39_StdCr6;
      37: CO:=Cons23_UpgCr0;
      38: CO:=Cons26_UpgCr1;
      39: CO:=Cons29_UpgCr2;
      40: CO:=Cons32_UpgCr3;
      41: CO:=Cons35_UpgCr4;
      42: CO:=Cons38_UpgCr5;
      43: CO:=Cons40_UpgCr6;
    end;
  end;

  procedure BuildSpecial_CS;
  begin
    case BU of
      17: CO:=Cons18_SP1;       //lighthouse
      18: CO:=Cons30_MorCr2;    //griffin
      19: CO:=Cons30_MorCr2;    //griffin
      20: CO:=-1;
      21: CO:=Cons20_SP3;       //stable                +Mov for departure heroes
      22: CO:=Cons19_SP2;       //brotherhood           +2 morale bonus to all garrisoned creatures during a siege.
      23: CO:=-1;
      24: CO:=-1;               // only Upg
      25: CO:=-1;               // only Upg
      26: CO:=Cons17_Grail;
      27: CO:=-1;
      28: CO:=-1;
      29: CO:=-1;
    end;
  end;

  procedure BuildSpecial_RM;
  begin
    case BU of
       17: CO:=Cons18_SP1;      // mystic pond           provides 1-4 random resources on Day 1 of each week
       18: CO:=Cons27_MorCr1;   // dwarves
       19: CO:=Cons27_MorCr1;   // dwarves
       20: CO:=-1;
       21: CO:=Cons19_SP2;      // fountain of fortune   +2 Luck for a hero during a siege.
       22: CO:=Cons20_SP3;      // dwarven treasury(1)   +10% interest for Day 1 player gold total.
       23: CO:=-1;
       24: CO:=Cons36_MorCr4;   // Dendroid soldiers
       25: CO:=Cons36_MorCr4;   // Dendroid soldiers
       26: CO:=Cons17_Grail;
       27: CO:=-1;
       28: CO:=-1;
       29: CO:=-1;
    end;
  end;

  procedure BuildSpecial_TW;
  begin
    case BU of
      17: CO:=Cons10_Artifact;  // Artifact Merchants
      18: CO:=Cons27_MorCr1;    // stone gargoyles
      19: CO:=Cons27_MorCr1;    // stone gargoyles
      20: CO:=-1;
      21: begin
      CO:=Cons20_SP3;           // lookout tower (2)       shroud is removed over all locations within twenty terrain tiles.
      Cmd_Map_Unfog(mCitys[CT].pid,mCitys[CT].pos.x,mCitys[CT].pos.y,mCitys[CT].pos.l,10);
      end;
      22: begin
      CO:=Cons18_SP1;           // library(2)               each level of the mage guild makes one extra spell
      Cmd_CT_AddLibSpel(CT);
      end;
      23: CO:=Cons19_SP2;       // wall of Knowledge.(2)    +1 to their Knowledge skill.
      24: CO:=-1; // only Upg
      25: CO:=-1; // only Upg
      26: CO:=Cons17_Grail;
      27: CO:=-1;
      28: CO:=-1;
      29: CO:=-1;
    end;
  end;

  procedure BuildSpecial_IN;
  begin
    case BU of
      17: CO:=-1;               // Artifact Merchants
      18: CO:=Cons24_MorCr0;    // imps
      19: CO:=Cons24_MorCr0;    // imps
      20: CO:=-1;
      21: CO:=Cons18_SP1;       // brimstone clouds(3)      siege, the Brimstone Stormclouds increase the Power skill of a hero by two.
      22: CO:=Cons19_SP2;       // castle gates(3)          can pass through the Castle Gate building to any other allied Inferno tow
      23: CO:=Cons20_SP3;       // order of fire(3)         adds one to a visiting hero’s Power skill
      24: CO:=Cons30_MorCr2;    // Cerberi
      25: CO:=Cons30_MorCr2;    // Cerberi
      26: CO:=Cons17_Grail;
      27: CO:=-1;
      28: CO:=-1;
      29: CO:=-1;
    end;
  end;

  procedure BuildSpecial_NC;
  begin
    case BU of
      17: CO:=Cons18_SP1;       // veil of darkness(4)       permanent shroud over the town for enemy heroes
      18: CO:=Cons24_MorCr0;    // skeletons
      19: CO:=Cons24_MorCr0;    // skeletons
      20: CO:=-1;
      21: CO:=Cons19_SP2;       // necromancy amplifier(4)   adds 10% to the Necromancy skill of all Necromancers
      22: CO:=Cons20_SP3;       // skeleton transformer(4)   Creatures brought to a town with a Skeleton Transformer may be turned into skeletons
      23: CO:=-1;
      24: CO:=-1; // only Upg
      25: CO:=-1; // only Upg
      26: CO:=Cons17_Grail;
      27: CO:=-1;
      28: CO:=-1;
      29: CO:=-1;
    end;
  end;

  procedure BuildSpecial_DG;
  begin
    case BU of
      17: CO:=Cons10_Artifact;  // Artifact Merchants
      18: CO:=Cons24_MorCr0;    // troglodytes
      19: CO:=Cons24_MorCr0;    // troglodytes
      20: CO:=-1;
      21: CO:=Cons18_SP1;       // mana vortex(5)
      22: CO:=Cons19_SP2;       // portal of summoning(5)
      23: CO:=Cons20_SP3;       // academy of battle scholars(5)    heroes gain 1000 experience points from the academy

      24: CO:=-1; // only Upg
      25: CO:=-1; // only Upg
      26: CO:=Cons17_Grail;
      27: CO:=-1;
      28: CO:=-1;
      29: CO:=-1;
    end;
  end;

  procedure BuildSpecial_ST;
  begin
    case BU of
      17: CO:=Cons18_SP1;       // escape tunnel(6)       flee during siege battle
      18: CO:=Cons24_MorCr0;    // goblins,
      19: CO:=Cons24_MorCr0;    // goblins,
      20: CO:=-1;
      21: CO:=Cons19_SP2;       // freelancer's guild(6)   You may trade creatures for resources at the Freelancer’s Guild.
      22: CO:=Cons20_SP3;       // ballista yard(6)        Upgrade to the blacksmith allows for the purchase of the Ballista war machine
      23: CO:=Cons21_SP4;       // hall of valhalla(6)     +1 to their Attack skill from the Hall of Valhalla.
      24: CO:=-1;               // only Upg
      25: CO:=-1;               // only Upg
      26: CO:=Cons17_Grail;
      27: CO:=-1;
      28: CO:=-1;
      29: CO:=-1;
    end;
  end;

  procedure BuildSpecial_FR;
  begin
    case BU of
      17: CO:=Cons18_SP1;       // cage of warlords(7)  +1 to their Defense skill
      18: CO:=Cons24_MorCr0;    // gnolls
      19: CO:=Cons24_MorCr0;    // gnolls
      20: CO:=-1;
      21: CO:=Cons18_SP1;       // glyphs of fear(7)    +2 to their Defense skill during sieges.
      22: CO:=Cons19_SP2;       // blood obelisk(7)     +2 to their Attack skill during siege battles.
      23: CO:=-1;
      24: CO:=-1;               // only Upg
      25: CO:=-1;               // only Upg
      26: CO:=Cons17_Grail;
      27: CO:=-1;
      28: CO:=-1;
      29: CO:=-1;
    end;
  end;

  procedure cmd_CT_BuildSpecial;
  begin
    case t of
      0: BuildSpecial_CS;
      1: BuildSpecial_RM;
      2: BuildSpecial_TW;
      3: BuildSpecial_IN;
      4: BuildSpecial_NC;
      5: BuildSpecial_DG;
      6: BuildSpecial_ST;
      7: BuildSpecial_FR;
    end;
  end;

begin
  T:=mCitys[CT].t;
  mCitys[CT].hasBuild:=1;
  LogP.InsertStr('Build in',format('%s BU=%d  %s', [mCitys[CT].name,BU,iBuild[mCitys[CT].t,BU].name]));
  for i:=0 to MAX_RES-1 do
  begin
    mPLayers[mPL].Res[i]:=mPLayers[mPL].Res[i]-iBUILD[t][BU].resnec[i];
    //LogP.InsertStr('BuCost',format('res=%d value=%d',[i,iBUILD[t][BU].resnec[i]]));
  end;
  case BU of
    0..16:  cmd_CT_BuildNeutral;
    17..25: cmd_CT_BuildSpecial;
    26..43: cmd_CT_BuildDwelling;
    else CO:=-1;
  end;
  if CO <> -1 then Cmd_CT_BuyCons(CT,CO);
  if mCitys[CT].VisHero <>-1 then Cmd_HE_VisitCitySkill(mCitys[CT].VisHero,CT);
end;
{----------------------------------------------------------------------------}
function Cmd_CT_ShowWhatToBuild(CT,Slot: integer): integer;
var
  BU,SL: integer;
const
  SL00_City=0;
  SL01_Fort=1;
  SL02_Tvrn=2;
  SL03_Blak=3;
  SL04_Mrkt=4;
  SL05_Magi=5;
  SL06_Ship=7;
  //SL08_Artf=8;
  //SL08_SPE1=8;
  //SL09_SPE2=8;
  //SL10_HRD1=10;
  SL11_CRE0=11;
  SL12_CRE1=12;
  SL13_CRE2=13;
  SL14_CRE3=14;
  SL15_CRE4=15;
  SL16_CRE5=16;
  SL17_CRE6=17;

  procedure ShowNeutral;
  begin
    with mCitys[CT] do
    begin
      case SL of
        SL00_City:
          if CONS[Cons1_City]        then BU:=13
          else if CONS[Cons0_Town]   then BU:=12
                                     else BU:=11;
        SL01_Fort:
          if CONS[Cons4_Citadel]     then BU:=9
          else if CONS[Cons3_Fort]   then BU:=8
                                     else BU:=7;
        SL02_Tvrn:
          if t=0 then
          begin
          if CONS[Cons6_Tavern]      then BU:=22
                                     else BU:=5;
          end                        else BU:=5;

        SL03_Blak:                        BU:=16;

        SL04_Mrkt:
          if CONS[Cons8_Market]      then BU:=15
                                     else BU:=14;
        SL05_Magi:
        begin
          if  ((t in [1,2,4,5]) and (CONS[Cons14_Mage4])) then BU:=4
          else if ((t in [1,2,3,4,5]) and (CONS[Cons13_Mage3]))      then BU:=3
          else if CONS[Cons12_Mage2] then BU:=2
          else if CONS[Cons11_Mage1] then BU:=1
                                     else BU:=0;
        end;
      end;
    end;
  end;

  procedure ShowDwelling;
  begin
    with mCitys[CT] do
    begin
      case SL of
        SL11_CRE0: if CONS[Cons22_StdCr0]
           then BU:=37
           else BU:=30;
        SL12_CRE1: if CONS[Cons25_StdCr1]
           then BU:=38
           else BU:=31;
        SL13_CRE2: if CONS[Cons28_StdCr2]
           then BU:=39
           else BU:=32;
        SL14_CRE3:  if CONS[Cons31_StdCr3]
           then BU:=40
           else BU:=33;
        SL15_CRE4: if CONS[Cons34_StdCr4]
           then BU:=41
           else BU:=34;
        SL16_CRE5: if CONS[Cons37_StdCr5]
           then BU:=42
           else BU:=35;
        SL17_CRE6: if CONS[Cons39_StdCr6]
           then BU:=43
           else BU:=36;
      end;
    end;
  end;

  procedure ShowSpecial_CS;     //SLOT  7 10 ignored
  begin
    with mCitys[CT] do
    begin
      case SL of
        6: if CONS[Cons16_Shipyard]
           then BU:=17
           else BU:=6;         //Shipyard
        8:      BU:=21;        //Stable
        9:      BU:=18;        //Griffing Bastion
      end;
    end;
  end;

  procedure ShowSpecial_RM;    //SLOT 7 ignored
  begin
    with mCitys[CT] do
    begin
    case SL of
        6:  if CONS[18]
         then BU:=21
         else BU:=17;        //Bassin
        8:    BU:=22;        //Abondance
        9:    BU:=24;        //Pepiniere
        10:   BU:=18;        //mineur
      end;
    end;
  end;

 procedure ShowSpecial_TW;
   begin
    with mCitys[CT] do
    begin
    case SL of
        6:    BU:=22;        //Library
        7:    BU:=23;        //wall
        8:    BU:=17;        //Artf
        9:    BU:=21;        //Lookout
        10:   BU:=18;        //Sculptor
      end;
    end;
  end;

 procedure ShowSpecial_IN;
   begin
    with mCitys[CT] do
    begin
    case SL of
        6:    BU:=23;        //oder of fire
        7:    BU:=21;        //cloud
        8:    BU:=22;        //castle
        9:    BU:=18;        //birthing pool
        10:   BU:=24;        //hell hound
      end;
    end;
  end;

 procedure ShowSpecial_NC;
   begin
    with mCitys[CT] do
    begin
    case SL of
        6:    BU:=21;        //necro
        7:    BU:=6;         //ship
        8:    BU:=17;        //cover
        9:    BU:=22;        //tansfo
        10:   BU:=18;        //grave
      end;
    end;
  end;

 procedure ShowSpecial_DG;
   begin
    with mCitys[CT] do
    begin
    case SL of
        6:    BU:=21;        //vortex
        7:    BU:=22;        //summon
        8:    BU:=17;        //art
        9:    BU:=23;        //scholar
        10:   BU:=18;        //musshroom
      end;
    end;
  end;

 procedure ShowSpecial_ST;
   begin
    with mCitys[CT] do
    begin
    case SL of
        6:    BU:=23;        //valhala
        7:    BU:=17;        //escape
        8:    BU:=21;        //freelancer
        9:    BU:=22;        //balista
        10:   BU:=18;        //mess
      end;
    end;
  end;

 procedure ShowSpecial_FR;   //SLOT 7 ignored
   begin
    with mCitys[CT] do
    begin
    case SL of
        //6:  BU:=21;        //gliph
        6:    BU:=22;        //obelisk
        8:    BU:=6;         //Shipyard
        9:    BU:=17;        //cage
        10:   BU:=18;        //gnol
      end;
    end;
  end;

  procedure ShowSpecial;
  begin
    case mcitys[CT].t of
    0: ShowSpecial_CS;
    1: ShowSpecial_RM;
    2: ShowSpecial_TW;
    3: ShowSpecial_IN;
    4: ShowSpecial_NC;
    5: ShowSpecial_DG;
    6: ShowSpecial_ST;
    7: ShowSpecial_FR;
    end;
  end;

begin
  BU:=1;
  SL:=SLOT;
  //if ((mCitys[CT].t=0) and (SL>5)) then  SL:=SL+2;
  //if ((mCitys[CT].t in [1,6,7])and (SL>5)) then SL:=SL+1;
  case SL  of
     0..5 : ShowNeutral;
    6..10 : ShowSpecial;
    11..17: ShowDwelling;
  end;
  result:=BU;
end;
{----------------------------------------------------------------------------}
function Cmd_CT_ShowBuild(CT,BU: integer): boolean;
var
  OK: boolean;

  procedure ShowNeutral;
  begin
    with mCitys[CT] do
    begin
      case BU of
        0: OK:=(CONS[Cons11_Mage1]  and  not(CONS[Cons12_Mage2]));
        1: OK:=(CONS[Cons12_Mage2]  and  not(CONS[Cons13_Mage3]));
        2: OK:=(CONS[Cons13_Mage3]  and  not(CONS[Cons14_Mage4]));
        3: OK:=(CONS[Cons14_Mage4]  and  not(CONS[Cons15_Mage5]));
        4: OK:=(CONS[Cons15_Mage5]);
        5: if t=0
      then OK:=(CONS[Cons6_Tavern]  and  not(CONS[Cons19_SP2]))
      else OK:=(CONS[Cons6_Tavern]);
        6: OK:=(CONS[Cons16_Shipyard]);
        7: OK:=(CONS[Cons3_Fort]    and  not(CONS[Cons4_Citadel]));
        8: OK:=(CONS[Cons4_Citadel] and  not(CONS[Cons5_Castle]));
        9: OK:=(CONS[Cons5_Castle]);
       10: OK:=not(CONS[Cons0_Town]);
       11: OK:=(CONS[Cons0_Town] and   not(CONS[Cons1_City]));
       12: OK:=(CONS[Cons1_City] and   not(CONS[Cons2_Capitol]));
       13: OK:=(CONS[Cons2_Capitol]);
       14: OK:=(CONS[Cons8_Market]);
       15: OK:=(CONS[Cons9_Silo]);
       16: OK:=(CONS[Cons7_Blacksmith]);
      end;
    end;
  end;


  procedure ShowSpecial_CS;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: OK:=(CONS[Cons18_SP1]);                                //lighthouse
       18: OK:=(CONS[Cons28_StdCr2]  and (CONS[Cons30_MorCr2]));  //griffin
       19: OK:=(CONS[Cons29_UpgCr2]  and (CONS[Cons30_MorCr2]));  //griffin
       20: OK:=false;
       21: OK:=(CONS[Cons20_SP3]);                                //stable
       22: OK:=(CONS[Cons19_SP2]);                                //brothehood
       23: OK:=false;
       24: OK:=false; // only Upg
       25: OK:=false; // only Upg
       26: OK:=(CONS[Cons17_Grail]);
      end;
    end;
  end;

  procedure ShowSpecial_RM;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: OK:=((CONS[Cons18_SP1]) and not (CONS[Cons19_SP2]));   // mystic pond
       18: OK:=(CONS[Cons25_StdCr1]  and (CONS[Cons27_MorCr1]));  // dwarves
       19: OK:=(CONS[Cons26_UpgCr1]  and (CONS[Cons27_MorCr1]));  // dwarves
       20: OK:=false;
       21: OK:=(CONS[Cons19_SP2]);                                // fountain of fortune(1)
       22: OK:=(CONS[Cons20_SP3]);   //stable                     // dwarven treasury(1)OK:=false;
       23: OK:=false;
       24: OK:=(CONS[Cons34_StdCr4]  and (CONS[Cons36_MorCr4]));  //Dendroid soldiers
       25: OK:=(CONS[Cons35_UpgCr4]  and (CONS[Cons36_MorCr4]));  // Dendroid soldiers
       26: OK:=(CONS[Cons17_Grail]);
       27: OK:=(CONS[Cons0_Town]);
       28: OK:=(CONS[Cons1_City]);
       29: OK:=(CONS[Cons2_Capitol]);
      end;
    end;
  end;

  procedure ShowSpecial_TW;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: OK:=(CONS[Cons10_Artifact]);                           // Artifact Merchants
       18: OK:=(CONS[Cons25_StdCr1]  and (CONS[Cons27_MorCr1]));  // stone gargoyles
       19: OK:=(CONS[Cons26_UpgCr1]  and (CONS[Cons27_MorCr1]));  // stone gargoyles
       20: OK:=false;
       21: OK:=(CONS[Cons20_SP3]);                                // lookout tower (2)
       22: OK:=(CONS[Cons18_SP1]);                                // library(2)
       23: OK:=(CONS[Cons19_SP2]);                                // wall of Knowledge.(2)
       24: OK:=false; // only Upg
       25: OK:=false; // only Upg
       26: OK:=(CONS[Cons17_Grail]);
       //27: OK:=(CONS[Cons0_Town]);
       //28: OK:=(CONS[Cons1_City]);
       //29: OK:=(CONS[Cons2_Capitol]);
      end;
    end;
  end;

  procedure ShowSpecial_IN;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: OK:=false;                                             // Artifact Merchants
       18: OK:=(CONS[Cons22_StdCr0]  and (CONS[Cons24_MorCr0]));  // imps
       19: OK:=(CONS[Cons23_UpgCr0]  and (CONS[Cons24_MorCr0]));  // imps
       20: OK:=false;
       21: OK:=(CONS[Cons18_SP1]);                                // brimstone clouds(3)
       22: OK:=(CONS[Cons19_SP2]);                                // castle gates(3)
       23: OK:=(CONS[Cons20_SP3]);                                // order of fire(3)
       24: OK:=(CONS[Cons28_StdCr2]  and (CONS[Cons30_MorCr2]));  // Cerberi
       25: OK:=(CONS[Cons29_UpgCr2]  and (CONS[Cons30_MorCr2]));  // Cerberi
       26: OK:=(CONS[Cons17_Grail]);
      end;
    end;
  end;

  procedure ShowSpecial_NC;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: OK:=(CONS[Cons18_SP1]);                                // veil of darkness(4)
       18: OK:=(CONS[Cons22_StdCr0]  and (CONS[Cons24_MorCr0]));  // skeletons
       19: OK:=(CONS[Cons23_UpgCr0]  and (CONS[Cons24_MorCr0]));  // skeletons
       20: OK:=false;
       21: OK:=(CONS[Cons19_SP2]);                                // necromancy amplifier(4)
       22: OK:=(CONS[Cons20_SP3]);                                // skeleton transformer(4)
       23: OK:=false;
       24: OK:=false; // only Upg
       25: OK:=false; // only Upg
       26: OK:=(CONS[Cons17_Grail]);
       //27: OK:=(CONS[Cons0_Town]);  // juste des pic si large town
       //28: OK:=(CONS[Cons1_City]);
       //29: OK:=(CONS[Cons2_Capitol]);
      end;
    end;
  end;


  procedure ShowSpecial_DG;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: OK:=(CONS[Cons10_Artifact]);                           // Artifact Merchants
       18: OK:=(CONS[Cons22_StdCr0]  and (CONS[Cons24_MorCr0]));  // troglodytes
       19: OK:=(CONS[Cons23_UpgCr0]  and (CONS[Cons24_MorCr0]));  // troglodytes
       20: OK:=false;
       21: OK:=(CONS[Cons18_SP1]);                                // mana vortex(5)
       22: OK:=(CONS[Cons19_SP2]);                                // portal of summoning(5)
       23: OK:=(CONS[Cons20_SP3]);                                // academy of battle scholars(5)
       24: OK:=false; // only Upg
       25: OK:=false; // only Upg
       26: OK:=(CONS[Cons17_Grail]);
      end;
    end;
  end;

  procedure ShowSpecial_ST;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: OK:=(CONS[Cons18_SP1]);                                // escape tunnel(6)
       18: OK:=(CONS[Cons22_StdCr0]  and (CONS[Cons24_MorCr0]));  // goblins,
       19: OK:=(CONS[Cons23_UpgCr0]  and (CONS[Cons24_MorCr0]));  // goblins,
       20: OK:=false;
       21: OK:=(CONS[Cons19_SP2]);                                // freelancer's guild(6)
       22: OK:=(CONS[Cons20_SP3]);                                // ballista yard(6)
       23: OK:=(CONS[Cons21_SP4]);                                // hall of valhalla(6)
       24: OK:=false; // only Upg
       25: OK:=false; // only Upg
       26: OK:=(CONS[Cons17_Grail]);
      end;
    end;
  end;

  procedure ShowSpecial_FR;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: OK:=(CONS[Cons18_SP1]);                                // cage of warlords(7)
       18: OK:=(CONS[Cons22_StdCr0]  and (CONS[Cons24_MorCr0]));  // gnolls
       19: OK:=(CONS[Cons23_UpgCr0]  and (CONS[Cons24_MorCr0]));  // gnolls
       20: OK:=false;
       21: OK:=(CONS[Cons18_SP1]);                                // glyphs of fear(7)
       22: OK:=(CONS[Cons19_SP2]);                                // blood obelisk(7)
       23: OK:=false;
       24: OK:=false; // only Upg
       25: OK:=false; // only Upg
       26: OK:=(CONS[Cons17_Grail]);
      end;
    end;
  end;
  procedure ShowDwelling;
  begin
    with mCitys[CT] do
    begin
      case BU of
       30: OK:=(CONS[Cons22_StdCr0]) and not(CONS[Cons23_UpgCr0]);
       31: OK:=(CONS[Cons25_StdCr1]) and not(CONS[Cons26_UpgCr1]);
       32: OK:=(CONS[Cons28_StdCr2]) and not(CONS[Cons29_UpgCr2]);
       33: OK:=(CONS[Cons31_StdCr3]) and not(CONS[Cons32_UpgCr3]);
       34: OK:=(CONS[Cons34_StdCr4]) and not(CONS[Cons35_UpgCr4]);
       35: OK:=(CONS[Cons37_StdCr5]) and not(CONS[Cons38_UpgCr5]);
       36: OK:=(CONS[Cons39_StdCr6]) and not(CONS[Cons40_UpgCr6]);
       37: OK:=(CONS[Cons23_UpgCr0]);
       38: OK:=(CONS[Cons26_UpgCr1]);
       39: OK:=(CONS[Cons29_UpgCr2]);
       40: OK:=(CONS[Cons32_UpgCr3]);
       41: OK:=(CONS[Cons35_UpgCr4]);
       42: OK:=(CONS[Cons38_UpgCr5]);
       43: OK:=(CONS[Cons40_UpgCr6]);
      end;
    end;
  end;

  procedure ShowSpecial;
  begin
    case mcitys[CT].t of
    0: ShowSpecial_CS;
    1: ShowSpecial_RM;
    2: ShowSpecial_TW;
    3: ShowSpecial_IN;
    4: ShowSpecial_NC;
    5: ShowSpecial_DG;
    6: ShowSpecial_ST;
    7: ShowSpecial_FR;
    end;
  end;
begin
  OK:=false;
  case BU of
     0..16: ShowNeutral;
    17..29: ShowSpecial;
    30..43: ShowDwelling;
  end;
  result:=OK;
end;

function Cmd_CT_CanBuild(CT,BU: integer): integer;
const
  IsOK=1;
  NoMoney=3;
  MissBuild=2;
  Disabled=0;
var
  i: integer;
  s: string;
  ok :integer;

  procedure CanDwelling_CS;
  begin
    with mCitys[CT] do
    begin
      case BU of
       30: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';
       31: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Gardhouse';
       32: begin
           if not(CONS[Cons7_Blacksmith]) then s:=s+ ' Blacksmith ';
           if not(CONS[Cons31_StdCr3]) then s:=s+ ' Barrack';
       end;
       33: begin
           if not(CONS[Cons22_StdCr0])    then s:=s+ ' Gardhouse';
           if not(CONS[Cons7_Blacksmith]) then s:=s+ ' Blacksmith ';
       end;
       34: begin
           if not(CONS[Cons31_StdCr3])    then s:=s+ ' Barrack';
           if not(CONS[Cons7_Blacksmith]) then s:=s+ ' Blacksmith ';
           if not(CONS[Cons11_Mage1])     then s:=s+ ' Magie ';
       end;
       35: begin
       if not(CONS[Cons7_Blacksmith]) then s:=s+ ' Blacksmith ';
       if not(CONS[Cons20_SP3])    then s:=s+ ' Stable';
       if not(CONS[Cons31_StdCr3]) then s:=s+ ' Barrack';
       end;
       36: begin
       if not(CONS[Cons11_Mage1])     then s:=s+ ' Magie L1';
       if not(CONS[Cons7_Blacksmith]) then s:=s+ ' Blacksmith ';
       if not(CONS[Cons31_StdCr3]) then s:=s+ ' Barrack';
       if not(CONS[Cons34_StdCr4]) then s:=s+ ' Monastery';
       end;
       37: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Guardhouse';
       38: if not(CONS[Cons25_StdCr1]) then s:=s+ ' Archery';
       39: if not(CONS[Cons28_StdCr2]) then s:=s+ ' GriffonTower';
       40: if not(CONS[Cons31_StdCr3]) then s:=s+ ' Guardhouse';
       41: if not(CONS[Cons34_StdCr4]) then s:=s+ ' Stable';
       42: if not(CONS[Cons37_StdCr5]) then s:=s+ ' Monastery';
       43: if not(CONS[Cons39_StdCr6]) then s:=s+ ' Angeleries';
      end;
     end;
  end;

  procedure CanDwelling_RM;
  begin
    with mCitys[CT] do
    begin
      case BU of
       30: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';
       31: if not(CONS[Cons22_StdCr0]) then s:=s+ ' CentaurStables';
       32: if not(CONS[Cons22_StdCr0]) then s:=s+ ' CentaurStables';
       33: if not(CONS[Cons28_StdCr2]) then s:=s+ ' HomeStead';
       34: if not(CONS[Cons28_StdCr2]) then s:=s+ ' HomeStead';
       35: begin
           if not(CONS[Cons31_StdCr3]) then s:=s+ ' EnchantedSpring';
           if not(CONS[Cons34_StdCr4]) then s:=s+ ' DendroidArches';
       end;
       36: begin
       if not(CONS[Cons12_Mage2])     then s:=s+ ' Magie L2 ';
       if not(CONS[Cons37_StdCr5]) then s:=s+ ' UnicornGlades';
       end;
       37: if not(CONS[Cons22_StdCr0]) then s:=s+ ' CentaurStables';
       38: if not(CONS[Cons25_StdCr1]) then s:=s+ ' DwarfCottage';
       39: if not(CONS[Cons28_StdCr2]) then s:=s+ ' HomeStead';
       40: if not(CONS[Cons31_StdCr3]) then s:=s+ ' EnchantedSpring';
       41: if not(CONS[Cons34_StdCr4]) then s:=s+ ' DendroidArches';
       42: if not(CONS[Cons37_StdCr5]) then s:=s+ ' UnicornGlades';
       43: if not(CONS[Cons39_StdCr6]) then s:=s+ ' Angeleries';
      end;
     end;
  end;

  procedure CanDwelling_TW;
  begin
    with mCitys[CT] do
    begin
      case BU of
       30: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';
       31: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Workshop';
       32: if not(CONS[Cons22_StdCr0]) then s:=s+ ' WorkShop';
       33: begin
       if not(CONS[Cons11_Mage1])     then s:=s+ ' Magie L1 ';
       if not(CONS[Cons25_StdCr1]) then s:=s+ ' Parapet';
       if not(CONS[Cons28_StdCr2]) then s:=s+ ' Golem Factory';
       end;
       34: if not(CONS[Cons31_StdCr3]) then s:=s+ ' Mage Tower';
       35: if not(CONS[Cons31_StdCr3]) then s:=s+ ' Mage Tower';
       36: begin
           if not(CONS[Cons34_StdCr4]) then s:=s+ ' Altar of Whishes';
           if not(CONS[Cons37_StdCr5]) then s:=s+ ' Golden Pavillon';
       end;
       37: if not(CONS[Cons22_StdCr0]) then s:=s+ ' WorkShop';
       38: if not(CONS[Cons25_StdCr1]) then s:=s+ ' Parapet';
       39: if not(CONS[Cons28_StdCr2]) then s:=s+ ' Golem Factory';
       40: if not(CONS[Cons31_StdCr3]) then s:=s+ ' Mage Tower';
       41: if not(CONS[Cons34_StdCr4]) then s:=s+ ' Altar of Whishes';
       42: if not(CONS[Cons37_StdCr5]) then s:=s+ ' Golden Pavillon';
       43: if not(CONS[Cons39_StdCr6]) then s:=s+ ' Cloud Temple';
      end;
    end;
  end;

  procedure CanDwelling_IN;
  begin
    with mCitys[CT] do
    begin
      case BU of
       30: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';
       31: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Imp Crucible';
       32: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Imp Crucible';
       33: if not(CONS[Cons25_StdCr1]) then s:=s+ ' Hall of Sins';
       34: if not(CONS[Cons31_StdCr3]) then s:=s+ ' Demon Gate';
       35: begin
       if not(CONS[Cons11_Mage1])     then s:=s+ ' Magie L1 ';
       if not(CONS[Cons31_StdCr3]) then s:=s+ ' Demon Gate';
       end;
       36: begin
           if not(CONS[Cons34_StdCr4]) then s:=s+ ' Hell Hole';
           if not(CONS[Cons37_StdCr5]) then s:=s+ ' Fire Lake';
       end;
       37: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Imp Crucible';
       38: if not(CONS[Cons25_StdCr1]) then s:=s+ ' Hall of Sins';
       39: if not(CONS[Cons28_StdCr2]) then s:=s+ ' Kennels';
       40: if not(CONS[Cons31_StdCr3]) then s:=s+ ' Demon Gate';
       41: begin
       if not(CONS[Cons12_Mage2])     then s:=s+ ' Magie L2 ';
       if not(CONS[Cons34_StdCr4]) then s:=s+ ' Hell Hole';
       end;
       42: if not(CONS[Cons37_StdCr5]) then s:=s+ ' Fire Lake';
       43: if not(CONS[Cons39_StdCr6]) then s:=s+ ' Forsaken Palace';
      end;
    end;
  end;

  procedure CanDwelling_NC;
  begin
    with mCitys[CT] do
    begin
      case BU of
       30: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';
       31: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Cursed Temple';
       32: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Cursed Temple';
       33: if not(CONS[Cons25_StdCr1]) then s:=s+ ' Graveyard';
       34: begin
       if not(CONS[Cons11_Mage1])     then s:=s+ ' Magie L1 ';
       if not(CONS[Cons25_StdCr1]) then s:=s+ ' Graveyard';
       end;
       35: begin
        if not(CONS[Cons34_StdCr4]) then s:=s+ ' Mausoleum';
       if not(CONS[Cons31_StdCr3]) then s:=s+ ' Estate';
       end;
       36: if not(CONS[Cons37_StdCr5]) then s:=s+ ' Hall of Darkness';
       37: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Cursed Temple';
       38: if not(CONS[Cons25_StdCr1]) then s:=s+ ' Graveyard';
       39: if not(CONS[Cons28_StdCr2]) then s:=s+ ' Tomb of Souls';
       40: begin
       if not(CONS[Cons31_StdCr3]) then s:=s+ ' Estate';
       if not(CONS[Cons19_SP2]) then s:=s+ ' Necro Amplifier';
       end;
       41: if not(CONS[Cons34_StdCr4]) then s:=s+ ' Mausoleum';
       42: if not(CONS[Cons37_StdCr5]) then s:=s+ ' Hall of Darkness';
       43: if not(CONS[Cons39_StdCr6]) then s:=s+ ' Dragon Vault';
      end;
    end;
  end;

  procedure CanDwelling_DG;
  begin
    with mCitys[CT] do
    begin
      case BU of
       30: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';
       31: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Warren';
       32: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Warren';
       33: begin
       if not(CONS[Cons25_StdCr1]) then s:=s+ ' Harpy Loft';
       if not(CONS[Cons28_StdCr2]) then s:=s+ 'Pillar of Eyes';
       end;
       34: if not(CONS[Cons31_StdCr3]) then s:=s+ ' Chapel of Stilled Voices';
       35: if not(CONS[Cons31_StdCr3]) then s:=s+ ' Chapel of Stilled Voices';
       36: begin
       if not(CONS[Cons12_Mage2])  then s:=s+ ' Mage Guild Level II';
       if not(CONS[Cons34_StdCr4]) then  s:=s+ ' Labyrinth';
       if not(CONS[Cons37_StdCr5]) then s:=s+ ' Manticore Lair';
       end;
       37: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Warren';
       38: if not(CONS[Cons25_StdCr1]) then s:=s+ ' Harpy Loft';
       39: if not(CONS[Cons28_StdCr2]) then s:=s+ ' Pillar of Eyes';
       40: if not(CONS[Cons31_StdCr3]) then s:=s+ ' Chapel of Stilled Voices';
       41: if not(CONS[Cons34_StdCr4]) then s:=s+ ' Labyrinth';
       42: if not(CONS[Cons37_StdCr5]) then s:=s+ ' Manticore Lair';
       43: begin
       if not(CONS[Cons13_Mage3])  then s:=s+ ' Mage Guild Level III';
       if not(CONS[Cons39_StdCr6]) then s:=s+ ' Dragon Cave';
      end;
    end;
  end;
  end;

  procedure CanDwelling_ST;
  begin
    with mCitys[CT] do
    begin
      case BU of
       30: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';
       31: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Goblin Barracks';
       32: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Goblin Barracks';
       33:  if not(CONS[Cons28_StdCr2]) then s:=s+ ' Orc Tower';
       34: if not(CONS[Cons25_StdCr1]) then s:=s+ ' Wolf Pen';
       35:  if not(CONS[Cons31_StdCr3]) then s:=s+ ' Ogre Fort';
       36: if not(CONS[Cons34_StdCr4]) then s:=s+ ' Cliff Nest';
       37: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Goblin Barracks';
       38: begin
       if not(CONS[Cons25_StdCr1]) then s:=s+ ' Wolf Pen';
       if not(CONS[Cons23_UpgCr0]) then s:=s+ ' Upg Goblin Barracks';
       end;
       39: begin
       if not(CONS[Cons28_StdCr2]) then s:=s+ ' Orc Tower';
       if not(CONS[Cons7_Blacksmith]) then s:=s+ ' Blacksmith ';
       end;
       40: begin
       if not(CONS[Cons31_StdCr3]) then s:=s+ ' Ogre Fort';
       if not(CONS[Cons11_Mage1])  then s:=s+ ' Mage Guild Level I';
       end;
       41: if not(CONS[Cons34_StdCr4]) then s:=s+ ' Cliff Nest';
       42: if not(CONS[Cons37_StdCr5]) then s:=s+ ' Cyclops Cave';
       43:
       if not(CONS[Cons39_StdCr6]) then s:=s+ ' Behemoth Lair';
      end;
    end;
  end;

  procedure CanDwelling_FR;
  begin
    with mCitys[CT] do
    begin
      case BU of
       30: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';
       31: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Gnoll Hut';
       32: if not(CONS[Cons22_StdCr0]) then s:=s+ ' Gnoll Hut';
       33: begin
       if not(CONS[Cons22_StdCr0]) then s:=s+ ' Gnoll Hut';
       if not(CONS[Cons28_StdCr2]) then s:=s+ ' Serpent Fly hive';
       end;
       34: begin
       if not(CONS[Cons22_StdCr0]) then s:=s+ ' Gnoll Hut';
       if not(CONS[Cons25_StdCr1]) then s:=s+ ' Lizard Den';
       if not(CONS[Cons28_StdCr2]) then s:=s+ ' Serpent Fly hive';
       end;
       35: begin
       if not(CONS[Cons22_StdCr0]) then s:=s+ ' Gnoll Hut';
       if not(CONS[Cons25_StdCr1]) then s:=s+ ' Lizard Den';
       end;
       36: begin
       if not(CONS[Cons22_StdCr0]) then s:=s+ ' Gnoll Hut';
       if not(CONS[Cons25_StdCr1]) then s:=s+ ' Lizard Den';
       if not(CONS[Cons28_StdCr2]) then s:=s+ ' Serpent Fly hive';
       if not(CONS[Cons31_StdCr3]) then s:=s+ ' Basilik Pit';
       if not(CONS[Cons37_StdCr5]) then s:=s+ ' Wyvern Nest';
       end;
       37: begin
       if not(CONS[Cons22_StdCr0]) then s:=s+ ' Gnoll Hut';
       if not(CONS[Cons6_Tavern]) then s:=s+ ' Tavern';
       end;
       38: if not(CONS[Cons25_StdCr1]) then s:=s+ ' Lizard Den';
       39: if not(CONS[Cons28_StdCr2]) then s:=s+ ' Serpent Fly hive';
       40: if not(CONS[Cons31_StdCr3]) then s:=s+ ' Basilik Pit';
       41: begin
       if not(CONS[Cons34_StdCr4]) then s:=s+ ' Gorgon';
       if not(CONS[Cons9_Silo]) then s:=s+ ' Ressource silo';
       end;
       42: if not(CONS[Cons37_StdCr5]) then s:=s+ ' Wyvern Nest';
       43:
       if not(CONS[Cons39_StdCr6]) then s:=s+ ' Hydre Pont';
      end;
  end;
  end;

  procedure CanDwelling;
  begin
    case mcitys[CT].t of
    0: CanDwelling_CS;
    1: CanDwelling_RM;
    2: CanDwelling_TW;
    3: CanDwelling_IN;
    4: CanDwelling_NC;
    5: CanDwelling_DG;
    6: CanDwelling_ST;
    7: CanDwelling_FR;
    end;
  end;

  procedure CanSpecial_CS;
  begin
    with mCitys[CT] do
    begin
      case BU of
        18,19: begin
          if not(CONS[Cons7_Blacksmith]) then s:=s+ ' Blacksmith ';
          if not(CONS[Cons31_StdCr3])    then s:=s+ ' Barrack';
          if not(CONS[Cons28_StdCr2])    then s:=s+ ' GriffonTower';
        end;
        21:  begin
          if not(CONS[Cons7_Blacksmith]) then s:=s+ ' Blacksmith ';
          if not(CONS[Cons31_StdCr3])    then s:=s+ ' Barrack';
        end;
      end;
    end;
  end;


  procedure CanSpecial_RM;
  begin
    with mCitys[CT] do
    begin
      case BU of
        18,19: begin
          if not(CONS[Cons25_StdCr1]) then s:=s+ ' Dwarfcottage';
        end;
        22:  begin
          if not(CONS[Cons27_MorCr1]) then s:=s+ ' MinerGuild';
        end;
         24:  begin
          if not(CONS[Cons34_StdCr4]) then s:=s+ ' Dendroid Arches';
        end;
      end;
    end;
  end;

  procedure CanSpecial_TW;
  begin
    with mCitys[CT] do
    begin
      case BU of
        17: begin
          if not(CONS[Cons8_Market])  then s:=s+ ' Market';
        end;
        18,19:  begin
          if not(CONS[Cons25_StdCr1]) then s:=s+ ' Parapet';
        end;
         21:
          if not(CONS[Cons5_Castle])  then s:=s+ ' Castle';
         22:
          if not(CONS[Cons11_Mage1])  then s:=s+ ' Magie L1 ';
         23:
           if not(CONS[Cons11_Mage1]) then s:=s+ ' Magie L1 ';
      end;
    end;
  end;

  procedure CanSpecial_IN;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: if not(CONS[Cons8_Market])      then s:=s+ ' Market';                                                         // Artifact Merchants
       18,19 : if not(CONS[Cons22_StdCr0]) then s:=s+ ' Faille des Diablotins'; // Fontaine des Hybride
       21: if not(CONS[Cons3_Fort])        then s:=s+ ' Fort';                  // brimstone clouds(3)
       22: if not(CONS[Cons4_Citadel])     then s:=s+' Citadel';                // castle gates(3)
       23: if not(CONS[Cons11_Mage1])      then s:=s+ ' MagieL1 ';              // order of fire(3)
       24,25: if not(CONS[Cons28_StdCr2])  then s:=s+ ' Kennels';               // Cerberi
      end;
    end;
  end;

  procedure CanSpecial_NC;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: if not(CONS[Cons3_Fort])     then s:=s+ ' Fort';             // cover of darkness                                    // Artifact Merchants
       18,19 : if not(CONS[Cons20_SP3]) then s:=s+ ' Ossuaire';         // catacombes
       21: if not(CONS[Cons11_Mage1])   then s:=s+ ' MagieL1 ';         // necro amplifier
       22:  if not(CONS[Cons22_StdCr0]) then s:=s+ ' Temple Maudit';    // skeleton transformer
      end;
    end;
  end;


  procedure CanSpecial_DG;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: if not(CONS[Cons8_Market])  then s:=s+ ' Market';            //Artifact Merchants                                      // Artifact Merchants
       18,19 : if not(CONS[Cons22_StdCr0]) then s:=s+ ' Warren';        // Mushroom Rings
       21: if not(CONS[Cons11_Mage1])  then s:=s+ ' MagieL1 ';          // Mana Vortex
      end;
    end;
  end;


  procedure CanSpecial_ST;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';                        //Escape Tunnel                                    // Artifact Merchants
       18,19 : if not(CONS[Cons22_StdCr0]) then s:=s+ ' Goblin Barracks';  // Mess Hall
       21: if not(CONS[Cons8_Market])  then s:=s+ ' Market';               //Freelancer Guild
       22: if not(CONS[Cons7_Blacksmith]) then s:=s+' Blacksmith';                    // Ballista Yard
       23: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';                  //Hall of Valhalla
      end;
    end;
  end;

  procedure CanSpecial_FR;
  begin
    with mCitys[CT] do
    begin
      case BU of
       17: if not(CONS[Cons8_Market])  then s:=s+ ' Market';                                                         // Artifact Merchants
       18,19 : if not(CONS[Cons22_StdCr0]) then s:=s+ ' Faille des Diablotins'; // Fontaine des Hybride
       21: if not(CONS[Cons3_Fort])  then s:=s+ ' Fort';                        // brimstone clouds(3)
       22: if not(CONS[Cons4_Citadel]) then s:=s+' Citadel';                    // castle gates(3)
       23: if not(CONS[Cons11_Mage1])  then s:=s+ ' MagieL1 ';                  // order of fire(3)
       24,25: if not(CONS[Cons28_StdCr2])  then s:=s+ ' Kennels';               // Cerberi
      end;
    end;
  end;
  procedure CanSpecial;
  begin
    case mcitys[CT].t of
    0: CanSpecial_CS;
    1: CanSpecial_RM;
    2: CanSpecial_TW;
    3: CanSpecial_IN;
    4: CanSpecial_NC;
    5: CanSpecial_DG;
    6: CanSpecial_ST;
    7: CanSpecial_FR;
    end;
  end;

  procedure CanNeutral;
  var
    i :integer;
  begin
    with mCitys[CT] do
    begin
      case BU of
        //0..5: ok:=1;
        6:   // shipyard
        begin
          for i:=-1 to 1 do
            if Cmd_MAP_inside(pos.x+1,pos.y+i)
            then
              if mTiles[pos.x+1,pos.y+i,pos.l].TR.t=TR08_Water then break;
          if i=2 then s:='Not Near water';
          OK:=Disabled;
        end;
        //7..10: ok:=1;

        11:   if not(Cons[6]) then s:='Taverne';      //Town Hall


        12:  begin       //City Hall
          if not(CONS[Cons11_Mage1]) then s:=s+ ' Mage';
          if not(CONS[Cons6_Tavern]) then s:=s+ ' Tavern';
          if not(CONS[Cons8_Market]) then s:=s+ ' Market';
          if not(CONS[Cons7_Blacksmith]) then s:=s+ ' Blacksmith';
        end;

        13:  begin //Capitol
          if not(CONS[Cons11_Mage1]) then s:=s+ ' Mage';
          if not(CONS[Cons6_Tavern]) then s:=s+' Tavern';
          if not(CONS[Cons5_Castle]) then s:=s+' Castle';
          if not(CONS[Cons8_Market]) then s:=s+' Market';
          if not(CONS[Cons7_Blacksmith]) then s:=s+' Blacksmith';
        end;

      end;
    end;
  end;

begin
  ok:=isok;
  s:='';

  case BU of
     0..16:  CanNeutral;
     17..29: CanSpecial;
     30..43: CanDwelling;
  end;

  if (ok = isok) then // not disabled
  begin
    with mCitys[CT] do
    begin
    for i:=0 to MAX_RES-1 do
      if iBuild[t][BU].resnec[i] > mPlayers[mPL].Res[i]
      then ok:=noMoney;
    end;

    if s=''          // miss build
    then
    begin
      mDialog.mes:='All prerequisite for this building has been met';
      result:=ok;
    end
    else
    begin
      mDialog.mes:='Requires ' +  NL + s;
      ok:=MissBuild;
    end;
  end;
  result:=Ok;

end;


{----------------------------------------------------------------------------}
procedure Cmd_CT_BuyCons(CT,CO: integer);
begin
  mCitys[CT].hasBuild:=1;
  mCitys[CT].Cons[CO]:=true;
  case CO of
    Cons11_Mage1:  cmd_CT_AddSpel(CT,1);
    Cons12_Mage2:  cmd_CT_AddSpel(CT,2);
    Cons13_Mage3:  cmd_CT_AddSpel(CT,3);
    Cons14_Mage4:  cmd_CT_AddSpel(CT,4);
    Cons15_Mage5:  cmd_CT_AddSpel(CT,5);

    Cons22_StdCr0: cmd_CT_AddProd(CT,0);
    Cons23_UpgCr0: cmd_CT_AddProd(CT,1);
    Cons24_MorCr0: cmd_CT_ExtProd(CT,0);

    Cons25_StdCr1: cmd_CT_AddProd(CT,2);
    Cons26_UpgCr1: cmd_CT_AddProd(CT,3);
    Cons27_MorCr1: cmd_CT_ExtProd(CT,1);

    Cons28_StdCr2: cmd_CT_AddProd(CT,4);
    Cons29_UpgCr2: cmd_CT_AddProd(CT,5);
    Cons30_MorCr2: cmd_CT_ExtProd(CT,2);

    Cons31_StdCr3: cmd_CT_AddProd(CT,6);
    Cons32_UpgCr3: cmd_CT_AddProd(CT,7);
    Cons33_MorCr3: cmd_CT_ExtProd(CT,3);

    Cons34_StdCr4: cmd_CT_AddProd(CT,8);
    Cons35_UpgCr4: cmd_CT_AddProd(CT,9);
    Cons36_MorCr4: cmd_CT_ExtProd(CT,4);

    Cons37_StdCr5: cmd_CT_AddProd(CT,10);
    Cons38_UpgCr5: cmd_CT_AddProd(CT,11);

    Cons39_StdCr6: cmd_CT_AddProd(CT,12);
    Cons40_UpgCr6: cmd_CT_AddProd(CT,13);

  end;
end;


end.
