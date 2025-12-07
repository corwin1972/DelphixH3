unit UHE;
// List of Hero operation

interface

Uses
  SysUtils, Forms, Classes, Math,
  UFile, UType, UOB,
  UAI, UCT, UEnter, UMap,  Uarmy,
  USnDialog,
  USnInfoCrea, USnInfoRes, USnInfoPlayer,
  UBattle, USnLevelUp, UPathRect, USnBuyCrea, USnSepCrea;

  function Cmd_HE_isMagician(HE: integer): boolean;
  procedure Cmd_HE_BuyForge(HE, AR: integer);
  function  Cmd_HE_NewHero(t: integer;day1:boolean):integer;
  procedure Cmd_HE_NewDay(HE:integer);
  procedure Cmd_HE_Add(HE: integer);
  procedure Cmd_HE_AddExp(HE,exp: integer);
  procedure Cmd_HE_AddSkill(HE,a,d,k,p: integer);
  procedure Cmd_HE_SetSkill(HE,a,d,k,p: integer);
  procedure Cmd_HE_AddSSK(HE,SS: integer);
  procedure Cmd_HE_AddPSK(HE,PK: integer);
  procedure Cmd_HE_AddSpell(HE,SP: integer);
  procedure Cmd_HE_AddAllSpell(HE:integer);
  function  Cmd_HE_AddCrea(HE,CR,n: integer): boolean;
  function  Cmd_HE_BuyCrea(HE,CR,n: integer): boolean;
  procedure Cmd_HE_AddMoral(HE: integer);
  procedure Cmd_HE_AddLuck(HE: integer);
  procedure Cmd_HE_CompactArmy(HE:integer);
  procedure Cmd_HE_Del(HE: integer);

  function  Cmd_HE_GetSpeed(HE: integer): integer;
  function  Cmd_HE_GetVision(HE: integer): integer;
  function  Cmd_HE_PathCost(HE: integer;Pos: TPos): integer;
  function  Cmd_HE_SPEL(HE,SP: integer): boolean;

  procedure Cmd_HE_SetART(HE,AR: integer; P1: integer=-1);
  procedure Cmd_HE_EffectART(HE,AR: integer);
  function  Cmd_HE_FindART(HE,AR: integer): integer;
  function  Cmd_HE_CountART(HE: integer): integer;
  procedure Cmd_HE_FreeARTPos(HE,AR,P1: integer);
  function  Cmd_HE_PossbileARTPos(HE,AR,P1: integer): boolean;
  function  Cmd_HE_CheckMove(HE,x,y,l: integer): integer;
  function Cmd_HE_CancelMove(HE,x,y,l: integer): boolean;
  procedure Cmd_HE_Move(HE,x,y,l: integer);
  procedure Cmd_HE_MoveBy(HE,dx,dy,dl: integer);

implementation

{----------------------------------------------------------------------------}
procedure Cmd_HE_Add(HE: integer);
begin
  with mHeros[HE] do
  begin
    if ((oid=0) or (mObjs[oid].Deading = 290)) then
    begin
      mOBJs[nObjs].T:=OB34_Hero;
      mOBJs[nObjs].U:=HE div 8;
      mOBJs[nObjs].id:=nObjs ;
      mOBJs[nObjs].pos:=pos ;
      mOBJs[nObjs].v:=HE ;
      mOBJs[nObjs].pid:=mPL;
      mObjs[nObjs].Deading:=-1;
      oid:=nObjs;
      inc(nObjs);
    end;

    used:=true;
    mTiles[pos.x,pos.y,pos.l].obX.T:=OB34_Hero;
    mTiles[pos.x,pos.y,pos.l].obX.U:=HE div 8 ;
    mTiles[pos.x,pos.y,pos.l].p1:=2;
    mTiles[pos.x,pos.y,pos.l].obX.oid:=nObjs-1;
    pid:=mPL;
    mPlayers[pid].LstHero[mPlayers[pid].nHero]:=HE;
    mplayers[pid].nHero:=mplayers[pid].nHero+1;
    mPlayers[pid].ActiveHero:=HE;
    mPlayers[pid].Activecity:=-1;
    School[0]:=0;
    School[1]:=0;
    School[2]:=0;
    School[3]:=0;


  end;
end;

{----------------------------------------------------------------------------}
function Cmd_HE_isMagician(HE: integer): boolean;
begin
   result:= ((mHeros[HE].ClasseId mod 2) = 1);
end;
{----------------------------------------------------------------------------}
function Cmd_HE_NewHero(t: integer;day1:boolean): integer;
var
  HE:integer;
  test,i: integer;
begin
  test:=0;

  if t<>-1
  then
  begin
    test:=64;
    repeat
      HE:=16*t+random(16);
      dec(test)
    until (mHeros[HE].used=false) or (test=0);
  end;

  if test=0  //no hero of proper class found
  then
    repeat
      HE:=random(MAX_HERO);
    until mHeros[HE].used=false;

  result:=HE;
  mHeros[HE].used:=true;
  if day1= false then
  begin
    for i:=0 to MAX_ARMY do
    begin
        mHeros[HE].armys[i].t:=-1;
        mHeros[HE].armys[i].n:=0;
    end;
    mHeros[HE].armys[0].t:=14*(HE div 16);
    mHeros[HE].armys[0].n:=1;
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_CompactArmy(HE:integer);
var
  i: integer;
  tmpArmys:TArmys;
begin
 with mHeros[HE] do
 begin
   nArmy:=0;
   for i:=0 to MAX_ARMY do
   begin
     if Armys[i].t<>-1
     then
     begin
       tmpArmys[nArmy].t:=Armys[i].t;
       tmpArmys[nArmy].n:=Armys[i].n;
       inc(nArmy);
     end;
   end;

   for i:=0 to nARMY-1 do
   begin
       Armys[i].t:=tmpArmys[i].t;
       Armys[i].n:=tmpArmys[i].n;
   end;
   for i:=nARMY to MAX_ARMY do
   begin
       Armys[i].t:=-1;
       Armys[i].n:=0;
   end;
 end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_Move(HE,x,y,l: integer);

  procedure LeaveTile;
  begin
    with mHeros[HE] do
    begin
      // recover old obj at this pos
      mTiles[pos.x,pos.y,pos.l].obX:=obX;
      // clear P1 of old pos if Hero on no obj
      if obX.t=0
        then mTiles[pos.x,pos.y,pos.l].P1:=0;
      // clear Vis hero      if Hero leave cityXXX
      if obX.t=OB98_City
        then
        begin
           mCitys[mObjs[obX.oid].v].VisHero:=-1;
           mHeros[HE].vistown:=-1;
        end;
      // clear Vis hero      if Hero leave cityXXX
 

      // Hero on Boat
      if (boatId > 0) then
      begin
        if (mTiles[x,y,l].TR.t = TR08_Water)
        then  // stay on the boat
        begin
          mTiles[pos.x,pos.y,pos.l].obX:=obX;
          if obX.t=0
          then mTiles[pos.x,pos.y,pos.l].P1:=0;
          // mTiles[x,y,l].obX.t:=0;
          // mTiles[pos.x,pos.y,pos.l].oid:=0;
        end
        else  // leave the boat
        begin
          mTiles[pos.x,pos.y,pos.l].P1:=2;
          mObjs[BoatId].pid:=-1;
          mTiles[pos.x,pos.y,pos.l].obX.t:=OB08_Boat;
          mTiles[pos.x,pos.y,pos.l].obX.u:=0;
          mTiles[pos.x,pos.y,pos.l].obX.oid:=BoatId;

          mObjs[BoatId].pos.x:=pos.x;
          mObjs[BoatId].pos.y:=pos.y;
          mObjs[BoatId].pos.l:=pos.l;
          BoatId:=0;
          mHeros[HE].PSKA.mov:=0;
        end;
      end;
    end;
  end;

  procedure EnterTile;
  begin
    with mHeros[HE] do
    begin
      obX:=mTiles[x,y,l].obX;
      mTiles[x,y,l].obX.T:=OB34_Hero;
      mTiles[x,y,l].obX.oid:=oid;
      mTiles[x,y,l].P1:=2;
    end;
  end;

  procedure UpdatePos;
  begin
    with mHeros[HE] do
    begin
      pos.x:=x;
      pos.y:=y;
      pos.l:=l;
      PSKA.mov:=PSKA.mov - Cmd_HE_PathCost(HE,pos);
    end;
  end;

begin
  leaveTile;
  updatePos;
  enterTile;
  Cmd_Map_Unfog(mPL,x,y,l,Cmd_HE_GetVision(HE));
end;


{----------------------------------------------------------------------------}
procedure Cmd_HE_MoveBy(HE,dx,dy,dl: integer);
begin
  with mHeros[HE] do
    begin
    if (mTiles[pos.x+dx,pos.y+dy,pos.l+dl].P1=TL_FREE) then
    begin
      Cmd_HE_Move(HE,pos.x+dx,pos.y+dy,pos.l+dl);
    end;
  end;
end;

{----------------------------------------------------------------------------}
function Cmd_HE_GetVision(HE:integer): integer;
var
  vision: integer;
begin
  vision:=5;
  vision:= vision + (1+mHeros[HE].SSK[SK03_Scouting]);
  vision:=vision + Cmd_He_findART(HE,AR052_Speculum)
                 + Cmd_He_findART(HE,AR053_Spyglass);
  result:=vision
end;
{----------------------------------------------------------------------------}
function Cmd_HE_BuyCrea(HE,CR,n: integer): boolean;
begin
  result:=Cmd_HE_AddCrea(HE,CR,n);
  if result then mPlayers[mPL].res[6]:=mPlayers[mPL].res[6]-n*iCrea[CR].cost;
end;
{----------------------------------------------------------------------------}
function Cmd_HE_AddCrea(HE,CR,n: integer): boolean;
var
  i: integer;
begin
  result:=false;
  with mHeros[HE] do
  begin
    for i:=0 to MAX_ARMY do
    begin
      if  Armys[i].t=CR then
      begin
        Armys[i].n:=Armys[i].n+n;
        result:=true;
        break;
      end;
    end;
    if not(result) then
    for i:=0 to MAX_ARMY do
    begin
      if  Armys[i].n=0 then
      begin
        Armys[i].t:=CR;
        Armys[i].n:=n;
        result:=true;
        break;
      end;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_HE_AddExp(HE,exp: integer);
var
  psk, sk1, sk2, sk1level, sk2level: integer;
  i,r: integer;
  ok: boolean;
  totalskill,maxskill: integer;
begin
  mHeros[HE].exp:=mHeros[HE].exp+ exp;
  while ExpLevel[mHeros[HE].level+1] <= mHeros[HE].exp do
  begin
    if mHeros[HE].level=14 then exit;  // car 14 level / level exp précodé

    mHeros[HE].level:=mHeros[HE].level+1;

    with iHero[mHeros[HE].classeId] do
    begin
      // find PSkil (att/def/pow/kno by randon in range [%att / %def , %pow %kno]  (ex 30,60,80,100)
      r:=random(100);
      if mHeros[HE].level < 10
      then
      begin
        for i:=0 to 3 do
          if r < PSK_GAIN_LL[i]
          then begin psk:=i; break; end;
      end
      else
      begin
        for i:=0 to 3 do
          if r < PSK_GAIN_HL[i]
          then begin psk:=i; break; end;
      end;

      // todo improve get new skill on hero with 8 skills
      maxskill:=0;    //nb skill différent : up to 8)
      totalskill:=0;  //total skills 1..3
      sk1:=0;
      sk2:=1;

      for i:=0 to MAX_SSK do
      begin
        if mHeros[HE].SSK[i] > 0  then
        begin
           maxskill:=maxskill+1;
           totalskill:=totalskill+mHeros[HE].SSK[i];
        end;
      end;

      ok:=false;

      if totalskill < (3*8-2) then       // un des 8 skill < 3)
      begin
        while not (ok) do
        begin
          r:=random(113);
          for i:=0 to MAX_SSK do   // trouve le skil1 by randon in range [%sk1, %sk2...]
            if r < SSK_GAIN[i]
            then begin sk1:=i; break; end;
          if (mHeros[HE].SSK[sk1] <= 2) then ok:=true;                         // skill new ou amériolable
          if ((mHeros[HE].SSK[sk1] = 0) and ( maxskill>=8) ) then ok:=false;   // skill new et deja 8 skill
        end;

        ok:=false;
        while not (ok) do
        begin
          r:=random(113);
          for i:=0 to MAX_SSK do   // trouve le skil1 by randon in range [%sk1, %sk2...]
            if r < ssk_GAIN[i]
            then begin sk2:=i; break; end;
          if ( (sk2 <> sk1) and (mHeros[HE].SSK[sk2] <= 2)) then ok:=true;     // skill new ou amériolable
          if ((mHeros[HE].SSK[sk2] = 0) and ( maxskill>=8) ) then ok:=false;   // skill new et deja 8 skill
        end;
      end;

      sk1level:=min(3,mHeros[HE].SSK[sk1] +1);
      sk2level:=min(3,mHeros[HE].SSK[sk2] +1);

      mDialog.res :=-1;
      TSnLevelUp.Create(HE,psk, sk1, sk1level, sk2,sk2level);
      repeat
        Application.HandleMessage
      until mDialog.res <> -1;
      if mDialog.res=1
      then
        mHeros[HE].SSK[sk1]:=sk1level
      else
        mHeros[HE].SSK[sk2]:=sk2level;

    end;

    Cmd_He_AddPSK(HE,psk);
  end;
end;

function Cmd_HE_CancelMove(HE,x,y,l: integer): boolean;
begin
  with mHeros[HE] do
  begin
    result:=true;
    // if PSKA.mov < 100 then exit;
    if Cmd_Map_Inside(x,y) then
    case mTiles[x,y,l].P1  of
      TL_EVENT: result:=false;    //event
      TL_FREE:  result:=false;    //free
      TL_OBJ:   result:=true;   //obs
      TL_ENTRY: result:=not(Cmd_HE_CanEnterObj(HE,x,y,l));    //entry
    end;
    if ((mHeros[HE].pos.x=x) and (mHeros[HE].pos.y=y))  then result:=true;
   end;
end;
{----------------------------------------------------------------------------}
function Cmd_HE_CheckMove(HE,x,y,l: integer): integer;
begin
  with mHeros[HE] do
  begin
    result:=-1;
    // if PSKA.mov < 100 then exit;
    if Cmd_Map_Inside(x,y) then
    case mTiles[x,y,l].P1  of
      TL_EVENT: result:=mTiles[x,y,l].obX.t;    //event
      TL_FREE:  result:=0;                      //free
      TL_OBJ:   result:=-1;                     //obs
      TL_ENTRY: result:=mTiles[x,y,l].obX.t;    //entry
    end;
    if ((mHeros[HE].pos.x=x) and (mHeros[HE].pos.y=y))  then result:=-1;
   end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_Del(HE: integer);
var
  i,j:integer;
begin
  with mHeros[HE] do
  begin
    if obX.t=OB98_City
    then
    begin
      if mCitys[mObjs[obX.oid].v].VisHero=HE then mCitys[mObjs[obX.oid].v].VisHero:=-1;
      if mCitys[mObjs[obX.oid].v].GarHero=HE then mCitys[mObjs[obX.oid].v].GarHero:=-1;
      gArmy.initCT(obX.u);
      mHeros[HE].vistown:=-1;
    end;
    used:=false;
    mObjs[oid].Deading:=500;
    for i:=0 to mPlayers[pid].nHero-1 do
      if  mPlayers[pid].LstHero[i]=id then break;
    for j:=i to mPlayers[pid].nHero-1 do
      mPlayers[pid].LstHero[j]:=mPlayers[pid].LstHero[j+1];
   mPlayers[pid].nHero:=mPlayers[pid].nHero-1;
   mTiles[pos.x,pos.y,pos.l].obX:=obX;
   if obX.t=0
     then  mTiles[pos.x,pos.y,pos.l].P1:=0;
   if boatId >0 then
   begin
     Cmd_OB_Del(boatId);
   end;
   mPlayers[pid].ActiveHero:=mPlayers[pid].LstHero[0];
   if  mPlayers[pid].nHero=0 then
   begin
     mPlayers[pid].ActiveHero:=-1;
     mPlayers[pid].ActiveCity:=mPlayers[pid].LstCity[0];
   end;
   if pid=mPL then mPath.length:=-1;
   end;
end;

{----------------------------------------------------------------------------}
function Cmd_HE_Spel(HE,SP: integer): boolean;
var
  ok: boolean;
  AR: integer;
begin
  case iSpel[SP].school of
    0: AR:=AR086_TomeofFireMagic;
    1: AR:=AR087_TomeofAirMagic;
    2: AR:=AR088_TomeofWaterMagic;
    3: AR:=AR089_TomeofEarthMagic;
  end;
  ok:=(Cmd_HE_FindArt(HE,AR) > 0);
  ok:=ok or mHeros[HE].Spels[SP];
  result:=OK;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_AddPSK(HE,PK: integer);
begin
  case PK of
    PS0_ATT: Cmd_He_AddSkill(HE,1,0,0,0);
    PS1_DEF: Cmd_He_AddSkill(HE,0,1,0,0);
    PS2_KNO: Cmd_He_AddSkill(HE,0,0,1,0);
    PS3_POW: Cmd_He_AddSkill(HE,0,0,0,1);
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_AddSpell(HE,SP: integer);
begin
  mHeros[HE].spels[SP]:=true;
end;

{----------------------------------------------------------------------------}
procedure Cmd_HE_AddAllSpell(HE: integer);
var SP:integer;
begin
  for SP:=0 to 64 do mHeros[HE].spels[SP]:=true;
end;

{----------------------------------------------------------------------------}
procedure Cmd_HE_AddSkill(HE,a,d,k,p: integer);
begin
  with mHeros[HE].PSKB do
  begin
    att:=att+a;
    def:=def+d;
    kno:=kno+k;
    pow:=pow+p;
    ptm:=max(10*kno,0);
  end;
  //to do handle < 0 value
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_SetSkill(HE,a,d,k,p: integer);
begin
  with mHeros[HE].PSKB do
  begin
    att:=a;
    def:=d;
    kno:=k;
    pow:=p;
    ptm:=max(10*kno,0);
  end;
end;
{----------------------------------------------------------------------------}
function Cmd_HE_PathCost(HE: integer;pos : TPos): integer;
var
  cost : integer;
begin
  case mTiles[pos.x,pos.y,pos.l].TR.t of
    0..3: cost:=100;
    4: cost:=125;
    5: cost:=150;
    6: cost:=150;
    7: cost:=175;
    8: cost:=100;
  end;
  case mTiles[pos.x,pos.y,pos.l].RD.t of
    1: cost:=50;
    2: cost:=65;
    3: cost:=75;
  end;
  if cost > 100 then
  case  mHeros[HE].SSK[SK00_Pathfinding] of
    0: cost:=max(100, cost -25);
    1: cost:=max(100, cost -50);
    2: cost:=max(100, cost -75);
  end;
  result:=cost;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_AddSSK(HE,SS: integer);
begin
  if (mHeros[HE].SSK[SS]+1=4) then exit;
  mHeros[HE].SSK[SS]:=mHeros[HE].SSK[SS]+1;
  if SS=SK06_Leadership then Cmd_HE_AddMoral(HE);
  if SS=SK09_Luck then Cmd_HE_AddLuck(HE);
  if SS=SK24_Intelligence then
  begin
     case mHeros[HE].SSK[SS] of
     1:mHeros[HE].PSKB.ptm:=round(10*mHeros[HE].PSKB.kno * 1.25);
     2:mHeros[HE].PSKB.ptm:=round(10*mHeros[HE].PSKB.kno * 1.50);
     3:mHeros[HE].PSKB.ptm:=round(10*mHeros[HE].PSKB.kno * 2);
     end;
     if mData.day+mData.month+mData.week=0 then
     mHeros[HE].PSKA.ptm:=mHeros[HE].PSKB.ptm;
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_AddMoral(HE: integer);
begin
  mHeros[HE].moral:=MIN(3,mHeros[HE].moral+1);
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_AddLuck(HE: integer);
begin
  mHeros[HE].luck:=MIN(3,mHeros[HE].luck+1)
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_EffectART(HE,AR: integer);
begin
  // note PSKLB skill basic, PSKLA skill with art
  with mHeros[HE] do
  Case AR of
    AR000_Spellbook: HasBook:=true;
    {AR001_SpellScroll
    AR002_Grail
    }
    //Attack bonus artifacts (Weapons)
    AR007_CentaurAxe :                cmd_HE_AddSkill(HE,2,0,0,0);
    AR008_BlackshardoftheDeadKnight:  cmd_HE_AddSkill(HE,3,0,0,0);
    AR009_GreaterGnollsFlail:         cmd_HE_AddSkill(HE,4,0,0,0);
    AR010_OgresClubofHavoc:           cmd_HE_AddSkill(HE,5,0,0,0);
    AR011_SwordofHellfire:            cmd_HE_AddSkill(HE,6,0,0,0);
    AR012_TitansGladius:              cmd_HE_AddSkill(HE,12,-3,0,0);
    //Defense bonus artifacts (Shields)
    AR013_ShieldoftheDwarvenLords:    cmd_HE_AddSkill(HE,0,2,0,0);
    AR014_ShieldoftheYawningDead:     cmd_HE_AddSkill(HE,0,3,0,0);
    AR015_BuckleroftheGnollKing:      cmd_HE_AddSkill(HE,0,4,0,0);
    AR016_TargoftheRampagingOgre:     cmd_HE_AddSkill(HE,0,5,0,0);
    AR017_ShieldoftheDamned:          cmd_HE_AddSkill(HE,0,6,0,0);
    AR018_SentinelsShield:            cmd_HE_AddSkill(HE,-3,12,0,0);
    //Knowledge bonus artifacts (Helmets)
    AR019_HelmoftheAlabasterUnicorn:  cmd_HE_AddSkill(HE,0,0,2,0);
    AR020_SkullHelmet:                cmd_HE_AddSkill(HE,0,0,3,0);
    AR021_HelmofChaos:                cmd_HE_AddSkill(HE,0,0,4,0);
    AR022_CrownoftheSupremeMagi:      cmd_HE_AddSkill(HE,0,0,5,0);
    AR023_HellstormHelmet:            cmd_HE_AddSkill(HE,0,0,6,0);
    AR024_ThunderHelmet:              cmd_HE_AddSkill(HE,0,0,12,-3);
    //Spell power bonus artifacts (Armours)
    AR025_BreastplateofPetrifiedWood: cmd_HE_AddSkill(HE,0,0,0,2);
    AR026_RibCage:                    cmd_HE_AddSkill(HE,0,0,0,3);
    AR027_ScalesoftheGreaterBasilisk: cmd_HE_AddSkill(HE,0,0,0,4);
    AR028_TunicoftheCyclopsKing:      cmd_HE_AddSkill(HE,0,0,0,5);
    AR029_BreastplateofBrimstone:     cmd_HE_AddSkill(HE,0,0,0,6);
    AR030_TitansCuirass:              cmd_HE_AddSkill(HE,0,0,-2,10);
    //All primary skills (various)
    AR031_ArmorofWonder:              cmd_HE_AddSkill(HE,1,1,1,1);
    AR032_SandalsoftheSaint:          cmd_HE_AddSkill(HE,2,2,2,2);
    AR033_CelestialNecklaceofBliss:   cmd_HE_AddSkill(HE,3,3,3,3);
    AR034_LionsShieldofCourage:       cmd_HE_AddSkill(HE,4,4,4,4);
    AR035_SwordofJudgement:           cmd_HE_AddSkill(HE,5,5,5,5);
    AR036_HelmofHeavenlyEnlightenment:cmd_HE_AddSkill(HE,6,6,6,6);
    //Attack and Defense (various)
    AR037_QuietEyeoftheDragon:        cmd_HE_AddSkill(HE,1,1,0,0);
    AR038_RedDragonFlameTongue:       cmd_HE_AddSkill(HE,2,2,0,0);
    AR039_DragonScaleShield:          cmd_HE_AddSkill(HE,3,3,0,0);
    AR040_DragonScaleArmor:           cmd_HE_AddSkill(HE,4,4,0,0);
    //Spell power and Knowledge (various)
    AR041_DragonboneGreaves:          cmd_HE_AddSkill(HE,0,0,1,1);
    AR042_DragonWingTabard:           cmd_HE_AddSkill(HE,0,0,2,2);
    AR043_NecklaceofDragonteeth:      cmd_HE_AddSkill(HE,0,0,3,3);
    AR044_CrownofDragontooth:         cmd_HE_AddSkill(HE,0,0,4,4);
    //moral art see SnHero   ???
    //Luck and morale
    //ART_MORALE(45,+1); //Still Eye of the Dragon
    //ART_LUCK(45,+1);   //Still Eye of the Dragon
    AR045_StillEyeoftheDragon:
    begin
        Cmd_HE_AddMoral(HE);
        Cmd_HE_AddLuck(HE);
    end;
    AR046_CloverofFortune:            cmd_HE_AddLuck(HE);
    AR047_CardsofProphecy:            cmd_HE_AddLuck(HE);
    AR048_LadybirdofLuck:             cmd_HE_AddLuck(HE);
    AR049_BadgeofCourage:             cmd_HE_AddMoral(HE);    //-> +1 morale and immunity to hostile mind spells:
    AR050_CrestofValor:               cmd_HE_AddMoral(HE);
    AR051_GlyphofGallantry:           cmd_HE_AddMoral(HE);
    //vision art

    {

    // 54 necro bonus
    AR057_GarnitureofInterference
    AR058_SurcoatofCounterpoise
    AR059_BootsofPolarity
    //***
    AR063_BirdofPerception
    AR064_StoicWatchman
    AR065_EmblemofCognizance
    // diplo art
    AR069_RingoftheWayfarer
    AR070_EquestriansGloves
    AR071_NecklaceofOceanGuidance
    AR072_AngelWings
    //***
    AR076_CollarofConjuring
    AR077_RingofConjuring
    AR078_CapeofConjuring
    AR079_OrboftheFirmament
    AR080_OrbofSilt
    AR081_OrbofTempestuousFire
    AR082_OrbofDrivingRain
    AR083_RecantersCloak
    AR084_SpiritofOppression
    AR085_HourglassoftheEvilHour

    AR090_BootsofLevitation
    AR091_GoldenBow
    AR092_SphereofPermanence
    AR093_OrbofVulnerability
    AR094_RingofVitality
    AR095_RingofLife
    AR096_VialofLifeblood
    //***
    AR100_PendantofDispassion
    AR101_PendantofSecondSight
    AR102_PendantofHoliness
    AR103_PendantofLife
    AR104_PendantofDeath
    AR105_PendantofFreeWill
    AR106_PendantofNegativity
    AR107_PendantofTotalRecall
    AR108_PendantofCourage


    // ressource bonus    put in the income computation with city handling

//giveArtBonus(109,Bonus::GENERATE_RESOURCE,+1,4); //Everflowing Crystal Cloak
//giveArtBonus(110,Bonus::GENERATE_RESOURCE,+1,5); //Ring of Infinite Gems
//giveArtBonus(111,Bonus::GENERATE_RESOURCE,+1,1); //Everpouring Vial of Mercury
//giveArtBonus(112,Bonus::GENERATE_RESOURCE,+1,2); //Inexhaustible Cart of Ore
//giveArtBonus(113,Bonus::GENERATE_RESOURCE,+1,3); //Eversmoking Ring of Sulfur
//giveArtBonus(114,Bonus::GENERATE_RESOURCE,+1,0); //Inexhaustible Cart of Lumber
//giveArtBonus(115,Bonus::GENERATE_RESOURCE,+1000,6); //Endless Sack of Gold
//giveArtBonus(116,Bonus::GENERATE_RESOURCE,+750,6); //Endless Bag of Gold
//giveArtBonus(117,Bonus::GENERATE_RESOURCE,+500,6); //Endless Purse of Gold



    AR123_SeaCaptainsHat
    AR124_SpellbindersHat
    // diplo no reddition
    AR126_OrbofInhibition
    AR127_VialofDragonBlood
    AR128_ArmageddonsBlade
    AR129_AngelicAlliance
    AR130_CloakoftheUndeadKing
    AR131_ElixirofLife
    AR132_ArmoroftheDamned
    AR133_StatueofLegion
    AR134_PoweroftheDragonFather
    AR135_TitansThunder
    AR136_AdmiralsHat
    AR137_BowoftheSharpshooter
    AR138_WizardsWell
    AR139_RingoftheMagi
    AR140_Cornucopia}
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_BuyForge(HE, AR: integer);
begin
  Cmd_HE_SetART(HE,AR);
  mPlayers[mPL].res[6] := mPlayers[mPL].res[6] - 1000;
end;
{----------------------------------------------------------------------------}
function Cmd_HE_FindART(HE,AR: integer): integer;
var
  i,nb: integer;
begin
  result:=0;
  if HE=-1 then exit;
  nb:=0;
  for i:=0 to MAX_SLOT-1 do
    if mHeros[HE].Arts[i]=AR then inc(nb);
  result:=nb;
end;
{----------------------------------------------------------------------------}
function Cmd_HE_GetSpeed(He: integer): integer;
var
  i,t:integer;
  speed: integer;
begin
  speed := 20;
  for i:=0 to MAX_ARMY-1 do
  begin
    t:=mHeros[HE].Armys[i].t;
    if t > -1 then
    case iCrea[t].speed of
    0..4:  speed := min(speed,15);
    5   :  speed := min(speed,16);
    6,7 :  speed := min(speed,17);
    8   :  speed := min(speed,18);
    9,10:  speed := min(speed,19);
    else   speed := min(speed,20)
    end;
  end;
  result:=speed;
end;
{----------------------------------------------------------------------------}
function  Cmd_HE_CountART(HE: integer): integer;
var
  slot : integer;
begin
  result:=0;
  with mHeros[HE] do
  begin
    for slot:=4 to 17 do
    if Arts[slot]>-1 then inc(result);
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_SetART(HE,AR: integer; P1: integer=-1);
var
  P2: integer;
begin
  if HE=-1 then exit; // HE:=pHero.id;
  with mHeros[HE], iArt[AR] do
  begin
    // no pos specified, try to find free pos
    if P1=-1 then
    begin
      for P2:=0 to MAX_SLOT do
        if (Arts[P2]=-1) and (SlotOK[P2]=true) then break;
      P1:=P2;
    end;
    // pos found => put art to equip pos
    if P1< MAX_SLOT then
    begin
      Arts[P1]:=AR;
      Cmd_HE_EffectART(HE,AR);
      exit;
    end;
    if AR=AR000_Spellbook then
    exit;
    if AR=AR003_Catapult then
    exit;
    // no pos found => put art to pack pos
    if P1>=MAX_SLOT then
      for P2:=MAX_SLOT to MAX_PACK do
        if Arts[P2]=-1 then break;
      P1:=P2;
      Arts[P1]:=AR;
  end;
end;
{----------------------------------------------------------------------------}
function Cmd_HE_PossbileARTPos(HE,AR,P1: integer): boolean;
begin
  result:=false;
  if HE=-1 then exit;
  if (iArt[AR].SlotOK[P1])
  then
    result:=true
  else
    result:=false;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_FreeARTPos(HE,AR,P1: integer);
begin
  if HE=-1 then exit;
  mHeros[HE].Arts[P1]:=-1;
  if P1 > 17 then Exit;
  //TODO remove effect of AR

  // note PSKLB skill basic, PSKLA skill with art
  with mHeros[HE] do
  Case AR of
    AR000_Spellbook: HasBook:=true;
    {AR001_SpellScroll
    AR002_Grail
    }
    //Attack bonus artifacts (Weapons)
    AR007_CentaurAxe :                cmd_HE_AddSkill(HE,-2,0,0,0);
    AR008_BlackshardoftheDeadKnight:  cmd_HE_AddSkill(HE,-3,0,0,0);
    AR009_GreaterGnollsFlail:         cmd_HE_AddSkill(HE,-4,0,0,0);
    AR010_OgresClubofHavoc:           cmd_HE_AddSkill(HE,-5,0,0,0);
    AR011_SwordofHellfire:            cmd_HE_AddSkill(HE,-6,0,0,0);
    AR012_TitansGladius:              cmd_HE_AddSkill(HE,-12,+3,0,0);
    //Defense bonus artifacts (Shields)
    AR013_ShieldoftheDwarvenLords:    cmd_HE_AddSkill(HE,0,-2,0,0);
    AR014_ShieldoftheYawningDead:     cmd_HE_AddSkill(HE,0,-3,0,0);
    AR015_BuckleroftheGnollKing:      cmd_HE_AddSkill(HE,0,-4,0,0);
    AR016_TargoftheRampagingOgre:     cmd_HE_AddSkill(HE,0,-5,0,0);
    AR017_ShieldoftheDamned:          cmd_HE_AddSkill(HE,0,-6,0,0);
    AR018_SentinelsShield:            cmd_HE_AddSkill(HE,+3,-12,0,0);
    //Knowledge bonus artifacts (Helmets)
    AR019_HelmoftheAlabasterUnicorn:  cmd_HE_AddSkill(HE,0,0,-2,0);
    AR020_SkullHelmet:                cmd_HE_AddSkill(HE,0,0,-3,0);
    AR021_HelmofChaos:                cmd_HE_AddSkill(HE,0,0,-4,0);
    AR022_CrownoftheSupremeMagi:      cmd_HE_AddSkill(HE,0,0,-5,0);
    AR023_HellstormHelmet:            cmd_HE_AddSkill(HE,0,0,-6,0);
    AR024_ThunderHelmet:              cmd_HE_AddSkill(HE,0,0,-12,+3);
    //Spell power bonus artifacts (Armours)
    AR025_BreastplateofPetrifiedWood: cmd_HE_AddSkill(HE,0,0,0,-2);
    AR026_RibCage:                    cmd_HE_AddSkill(HE,0,0,0,-3);
    AR027_ScalesoftheGreaterBasilisk: cmd_HE_AddSkill(HE,0,0,0,-4);
    AR028_TunicoftheCyclopsKing:      cmd_HE_AddSkill(HE,0,0,0,-5);
    AR029_BreastplateofBrimstone:     cmd_HE_AddSkill(HE,0,0,0,-6);
    AR030_TitansCuirass:              cmd_HE_AddSkill(HE,0,0,+3,-10);
    //All primary skills (various)
    AR031_ArmorofWonder:              cmd_HE_AddSkill(HE,-1,-1,-1,-1);
    AR032_SandalsoftheSaint:          cmd_HE_AddSkill(HE,-2,-2,-2,-2);
    AR033_CelestialNecklaceofBliss:   cmd_HE_AddSkill(HE,-3,-3,-3,-3);
    AR034_LionsShieldofCourage:       cmd_HE_AddSkill(HE,-4,-4,-4,-4);
    AR035_SwordofJudgement:           cmd_HE_AddSkill(HE,-5,-5,-5,-5);
    AR036_HelmofHeavenlyEnlightenment:cmd_HE_AddSkill(HE,-6,-6,-6,-6);
    //Attack and Defense (various)
    AR037_QuietEyeoftheDragon:        cmd_HE_AddSkill(HE,-1,-1,-0,-0);
    AR038_RedDragonFlameTongue:       cmd_HE_AddSkill(HE,-2,-2,-0,-0);
    AR039_DragonScaleShield:          cmd_HE_AddSkill(HE,-3,-3,-0,-0);
    AR040_DragonScaleArmor:           cmd_HE_AddSkill(HE,-4,-4,-0,-0);
    //Spell power and Knowledge (various)
    AR041_DragonboneGreaves:          cmd_HE_AddSkill(HE,-0,-0,-1,-1);
    AR042_DragonWingTabard:           cmd_HE_AddSkill(HE,-0,-0,-2,-2);
    AR043_NecklaceofDragonteeth:      cmd_HE_AddSkill(HE,-0,-0,-3,-3);
    AR044_CrownofDragontooth:         cmd_HE_AddSkill(HE,-0,-0,-4,-4);

    //moral art see SnHero   ???
    //Luck and morale
    //ART_MORALE(45,+1); //Still Eye of the Dragon
    //ART_LUCK(45,+1); //Still Eye of the Dragon
    {45:
    begin
        Cmd_HE_AddMoral(HE);
        Cmd_HE_AddLuck(HE);
    end;
    //ART_LUCK(46,+1); //Clover of Fortune
    46: Cmd_HE_AddLuck(HE);
    //ART_LUCK(47,+1); //Cards of Prophecy
    47: Cmd_HE_AddLuck(HE);
    //ART_LUCK(48,+1); //Ladybird of Luck
    48: Cmd_HE_AddLuck(HE);
    //ART_MORALE(49,+1); //Badge of Courage -> +1 morale and immunity to hostile mind spells:
    49: Cmd_HE_AddMoral(HE);
    //ART_MORALE(50,+1); //Crest of Valor
    50: Cmd_HE_AddMoral(HE);
    //ART_MORALE(51,+1); //Glyph of Gallantry
    51: Cmd_HE_AddMoral(HE);
    //vision art


    // 54 necro bonus
    AR057_GarnitureofInterference
    AR058_SurcoatofCounterpoise
    AR059_BootsofPolarity
    //***
    AR063_BirdofPerception
    AR064_StoicWatchman
    AR065_EmblemofCognizance
    // diplo art

    AR069_RingoftheWayfarer
    AR070_EquestriansGloves
    AR071_NecklaceofOceanGuidance
    AR072_AngelWings
    //***
    AR076_CollarofConjuring
    AR077_RingofConjuring
    AR078_CapeofConjuring
    AR079_OrboftheFirmament
    AR080_OrbofSilt
    AR081_OrbofTempestuousFire
    AR082_OrbofDrivingRain
    AR083_RecantersCloak
    AR084_SpiritofOppression
    AR085_HourglassoftheEvilHour

    AR090_BootsofLevitation
    AR091_GoldenBow
    AR092_SphereofPermanence
    AR093_OrbofVulnerability
    AR094_RingofVitality
    AR095_RingofLife
    AR096_VialofLifeblood
    //***
    AR100_PendantofDispassion
    AR101_PendantofSecondSight
    AR102_PendantofHoliness
    AR103_PendantofLife
    AR104_PendantofDeath
    AR105_PendantofFreeWill
    AR106_PendantofNegativity
    AR107_PendantofTotalRecall
    AR108_PendantofCourage


    // ressource bonus    put in the income computation with city handling

//giveArtBonus(109,Bonus::GENERATE_RESOURCE,+1,4); //Everflowing Crystal Cloak
//giveArtBonus(110,Bonus::GENERATE_RESOURCE,+1,5); //Ring of Infinite Gems
//giveArtBonus(111,Bonus::GENERATE_RESOURCE,+1,1); //Everpouring Vial of Mercury
//giveArtBonus(112,Bonus::GENERATE_RESOURCE,+1,2); //Inexhaustible Cart of Ore
//giveArtBonus(113,Bonus::GENERATE_RESOURCE,+1,3); //Eversmoking Ring of Sulfur
//giveArtBonus(114,Bonus::GENERATE_RESOURCE,+1,0); //Inexhaustible Cart of Lumber
//giveArtBonus(115,Bonus::GENERATE_RESOURCE,+1000,6); //Endless Sack of Gold
//giveArtBonus(116,Bonus::GENERATE_RESOURCE,+750,6); //Endless Bag of Gold
//giveArtBonus(117,Bonus::GENERATE_RESOURCE,+500,6); //Endless Purse of Gold


    AR123_SeaCaptainsHat
    AR124_SpellbindersHat

    // diplo no reddition
    AR126_OrbofInhibition
    AR127_VialofDragonBlood
    AR128_ArmageddonsBlade
    AR129_AngelicAlliance
    AR130_CloakoftheUndeadKing
    AR131_ElixirofLife
    AR132_ArmoroftheDamned
    AR133_StatueofLegion
    AR134_PoweroftheDragonFather
    AR135_TitansThunder
    AR136_AdmiralsHat
    AR137_BowoftheSharpshooter
    AR138_WizardsWell
    AR139_RingoftheMagi
    AR140_Cornucopia}
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_HE_NewDay(HE: integer);
var CT: integer;
begin
  with mHeros[HE] do
  begin
    //todo : change to 5/10/20 instead of 5/10/15 bonus multiplier
    // add boot and glove bonus
    //Boots of SpeedBoots of Speed give +600 (+400 in HotA) points on land
    //Equestrian's GlovesEquestrian's Gloves give +300 (+200 in HotA) points on land
    //Necklace of Ocean GuidanceNecklace of Ocean Guidance gives +1000 points on water
    //Sea Captain's HatSea Captain's Hat gives +500 points on water.
    // It gives a hero who's visiting Castle town with built Stables the bonus of +400 movement points
    //  increasing movement points by +500 when heroes move on water with a boat.
    PSKA.mov:=(100+5* SSK[SK02_Logistics])* Cmd_HE_GetSpeed(HE);


    if mData.Day=0 then VisStable:=false;

    if (mTiles[pos.x,pos.y,pos.l].TR.t = TR08_Water)
    then
    begin
      // need to count the owne lighthouse per catle and on map
    end
    else
    begin
      if VisStable then PSKA.mov:=PSKA.mov + 400;
      PSKA.mov:=PSKA.mov + 400  * cmd_HE_FindART(HE, AR098_BootsofSpeed);
      PSKA.mov:=PSKA.mov + 300 * cmd_HE_FindART(HE, AR070_EquestriansGloves);
    end;

    PSKB.mov:=PSKA.mov;

    PSKA.ptm:=min( PSKB.ptm,
            PSKA.ptm +1
            +  Cmd_He_FindARt(HE,AR073_CharmOfMana)
            +2*Cmd_He_FindARt(HE,AR074_TalismanOfMana)
            +3*Cmd_He_FindARt(HE,AR075_MysticOrbOfMana) );
    // if Hero in City , then recover all mana (like when going to the puit

    CT :=mHeros[HE].VisTown;
    if CT > -1 then
    begin
      if Cmd_CT_SpelLevel(CT) > 0 then
        mHeros[HE].PSKA.ptm:=mHeros[HE].PSKB.ptm;
    end;

    VisMagicWell:=false;
    VisTemple:=false;
    VisMono:=false;
    Cmd_Map_Unfog(pid,pos.x,pos.y,pos.l)
  end;
end;
{----------------------------------------------------------------------------}
end.






void CArtHandler::addBonuses()
{
	#define ART_PRIM_SKILL(ID, whichSkill, val) giveArtBonus(ID,Bonus::PRIMARY_SKILL,val,whichSkill)
	#define ART_MORALE(ID, val) giveArtBonus(ID,Bonus::MORALE,val)
	#define ART_LUCK(ID, val) giveArtBonus(ID,Bonus::LUCK,val)
	#define ART_MORALE_AND_LUCK(ID, val) giveArtBonus(ID,Bonus::MORALE_AND_LUCK,val)
	#define ART_ALL_PRIM_SKILLS(ID, val) ART_PRIM_SKILL(ID,0,val); ART_PRIM_SKILL(ID,1,val); ART_PRIM_SKILL(ID,2,val); ART_PRIM_SKILL(ID,3,val)
	#define ART_ATTACK_AND_DEFENSE(ID, val) ART_PRIM_SKILL(ID,0,val); ART_PRIM_SKILL(ID,1,val)
	#define ART_POWER_AND_KNOWLEDGE(ID, val) ART_PRIM_SKILL(ID,2,val); ART_PRIM_SKILL(ID,3,val)

	//Attack bonus artifacts (Weapons)
	ART_PRIM_SKILL(7,0,+2); //Centaur Axe
	ART_PRIM_SKILL(8,0,+3); //Blackshard of the Dead Knight
	ART_PRIM_SKILL(9,0,+4); //Greater Gnoll's Flail
	ART_PRIM_SKILL(10,0,+5); //Ogre's Club of Havoc
	ART_PRIM_SKILL(11,0,+6); //Sword of Hellfire
	ART_PRIM_SKILL(12,0,+12); //Titan's Gladius
	ART_PRIM_SKILL(12,1,-3);  //Titan's Gladius

	//Defense bonus artifacts (Shields)
	ART_PRIM_SKILL(13,1,+2); //Shield of the Dwarven Lords
	ART_PRIM_SKILL(14,1,+3); //Shield of the Yawning Dead
	ART_PRIM_SKILL(15,1,+4); //Buckler of the Gnoll King
	ART_PRIM_SKILL(16,1,+5); //Targ of the Rampaging Ogre
	ART_PRIM_SKILL(17,1,+6); //Shield of the Damned
	ART_PRIM_SKILL(18,1,+12); //Sentinel's Shield
	ART_PRIM_SKILL(18,0,-3);  //Sentinel's Shield

	//Knowledge bonus artifacts (Helmets)
	ART_PRIM_SKILL(19,3,+1); //Helm of the Alabaster Unicorn 
	ART_PRIM_SKILL(20,3,+2); //Skull Helmet
	ART_PRIM_SKILL(21,3,+3); //Helm of Chaos
	ART_PRIM_SKILL(22,3,+4); //Crown of the Supreme Magi
	ART_PRIM_SKILL(23,3,+5); //Hellstorm Helmet
	ART_PRIM_SKILL(24,3,+10); //Thunder Helmet
	ART_PRIM_SKILL(24,2,-2);  //Thunder Helmet

	//Spell power bonus artifacts (Armours)
	ART_PRIM_SKILL(25,2,+1); //Breastplate of Petrified Wood
	ART_PRIM_SKILL(26,2,+2); //Rib Cage
	ART_PRIM_SKILL(27,2,+3); //Scales of the Greater Basilisk
	ART_PRIM_SKILL(28,2,+4); //Tunic of the Cyclops King
	ART_PRIM_SKILL(29,2,+5); //Breastplate of Brimstone
	ART_PRIM_SKILL(30,2,+10); //Titan's Cuirass
	ART_PRIM_SKILL(30,3,-2);  //Titan's Cuirass

	//All primary skills (various)
	ART_ALL_PRIM_SKILLS(31,+1); //Armor of Wonder
	ART_ALL_PRIM_SKILLS(32,+2); //Sandals of the Saint
	ART_ALL_PRIM_SKILLS(33,+3); //Celestial Necklace of Bliss
	ART_ALL_PRIM_SKILLS(34,+4); //Lion's Shield of Courage
	ART_ALL_PRIM_SKILLS(35,+5); //Sword of Judgement
	ART_ALL_PRIM_SKILLS(36,+6); //Helm of Heavenly Enlightenment

	//Attack and Defense (various)
	ART_ATTACK_AND_DEFENSE(37,+1); //Quiet Eye of the Dragon
	ART_ATTACK_AND_DEFENSE(38,+2); //Red Dragon Flame Tongue
	ART_ATTACK_AND_DEFENSE(39,+3); //Dragon Scale Shield
	ART_ATTACK_AND_DEFENSE(40,+4); //Dragon Scale Armor

	//Spell power and Knowledge (various)
	ART_POWER_AND_KNOWLEDGE(41,+1); //Dragonbone Greaves
	ART_POWER_AND_KNOWLEDGE(42,+2); //Dragon Wing Tabard
	ART_POWER_AND_KNOWLEDGE(43,+3); //Necklace of Dragonteeth
	ART_POWER_AND_KNOWLEDGE(44,+4); //Crown of Dragontooth

	//Luck and morale 
	ART_MORALE(45,+1); //Still Eye of the Dragon
	ART_LUCK(45,+1); //Still Eye of the Dragon
	ART_LUCK(46,+1); //Clover of Fortune
	ART_LUCK(47,+1); //Cards of Prophecy
	ART_LUCK(48,+1); //Ladybird of Luck
	ART_MORALE(49,+1); //Badge of Courage -> +1 morale and immunity to hostile mind spells:
	giveArtBonus(49,Bonus::SPELL_IMMUNITY,0,50);//sorrow
	giveArtBonus(49,Bonus::SPELL_IMMUNITY,0,59);//berserk
	giveArtBonus(49,Bonus::SPELL_IMMUNITY,0,60);//hypnotize
	giveArtBonus(49,Bonus::SPELL_IMMUNITY,0,61);//forgetfulness
	giveArtBonus(49,Bonus::SPELL_IMMUNITY,0,62);//blind
	ART_MORALE(50,+1); //Crest of Valor
	ART_MORALE(51,+1); //Glyph of Gallantry

	giveArtBonus(52,Bonus::SIGHT_RADIOUS,+1);//Speculum
	giveArtBonus(53,Bonus::SIGHT_RADIOUS,+1);//Spyglass

	//necromancy bonus
	giveArtBonus(54,Bonus::SECONDARY_SKILL_PREMY,+5,12, Bonus::ADDITIVE_VALUE);//Amulet of the Undertaker
	giveArtBonus(55,Bonus::SECONDARY_SKILL_PREMY,+10,12, Bonus::ADDITIVE_VALUE);//Vampire's Cowl
	giveArtBonus(56,Bonus::SECONDARY_SKILL_PREMY,+15,12, Bonus::ADDITIVE_VALUE);//Dead Man's Boots

	giveArtBonus(57,Bonus::MAGIC_RESISTANCE,+5);//Garniture of Interference
	giveArtBonus(58,Bonus::MAGIC_RESISTANCE,+10);//Surcoat of Counterpoise
	giveArtBonus(59,Bonus::MAGIC_RESISTANCE,+15);//Boots of Polarity

	//archery bonus
	giveArtBonus(60,Bonus::SECONDARY_SKILL_PREMY,+5,1, Bonus::ADDITIVE_VALUE);//Bow of Elven Cherrywood
	giveArtBonus(61,Bonus::SECONDARY_SKILL_PREMY,+10,1, Bonus::ADDITIVE_VALUE);//Bowstring of the Unicorn's Mane
	giveArtBonus(62,Bonus::SECONDARY_SKILL_PREMY,+15,1, Bonus::ADDITIVE_VALUE);//Angel Feather Arrows

	//eagle eye bonus
	giveArtBonus(63,Bonus::SECONDARY_SKILL_PREMY,+5,11, Bonus::ADDITIVE_VALUE);//Bird of Perception
	giveArtBonus(64,Bonus::SECONDARY_SKILL_PREMY,+10,11, Bonus::ADDITIVE_VALUE);//Stoic Watchman
	giveArtBonus(65,Bonus::SECONDARY_SKILL_PREMY,+15,11, Bonus::ADDITIVE_VALUE);//Emblem of Cognizance

	//reducing cost of surrendering
	giveArtBonus(66,Bonus::SURRENDER_DISCOUNT,+10);//Statesman's Medal
	giveArtBonus(67,Bonus::SURRENDER_DISCOUNT,+10);//Diplomat's Ring
	giveArtBonus(68,Bonus::SURRENDER_DISCOUNT,+10);//Ambassador's Sash

	giveArtBonus(69,Bonus::STACKS_SPEED,+1);//Ring of the Wayfarer

	giveArtBonus(70,Bonus::LAND_MOVEMENT,+300);//Equestrian's Gloves
	giveArtBonus(71,Bonus::SEA_MOVEMENT,+1000);//Necklace of Ocean Guidance
	giveArtBonus(72,Bonus::FLYING_MOVEMENT, 0, 1);//Angel Wings

	giveArtBonus(73,Bonus::MANA_REGENERATION,+1);//Charm of Mana
	giveArtBonus(74,Bonus::MANA_REGENERATION,+2);//Talisman of Mana
	giveArtBonus(75,Bonus::MANA_REGENERATION,+3);//Mystic Orb of Mana

	giveArtBonus(76,Bonus::SPELL_DURATION,+1);//Collar of Conjuring
	giveArtBonus(77,Bonus::SPELL_DURATION,+2);//Ring of Conjuring
	giveArtBonus(78,Bonus::SPELL_DURATION,+3);//Cape of Conjuring

	giveArtBonus(79,Bonus::AIR_SPELL_DMG_PREMY,+50);//Orb of the Firmament
	giveArtBonus(80,Bonus::EARTH_SPELL_DMG_PREMY,+50);//Orb of Silt
	giveArtBonus(81,Bonus::FIRE_SPELL_DMG_PREMY,+50);//Orb of Tempestuous Fire
	giveArtBonus(82,Bonus::WATER_SPELL_DMG_PREMY,+50);//Orb of Driving Rain

	giveArtBonus(83,Bonus::BLOCK_SPELLS_ABOVE_LEVEL,3);//Recanter's Cloak
	giveArtBonus(84,Bonus::BLOCK_MORALE,0);//Spirit of Oppression
	giveArtBonus(85,Bonus::BLOCK_LUCK,0);//Hourglass of the Evil Hour

	giveArtBonus(86,Bonus::FIRE_SPELLS,0);//Tome of Fire Magic
	giveArtBonus(87,Bonus::AIR_SPELLS,0);//Tome of Air Magic
	giveArtBonus(88,Bonus::WATER_SPELLS,0);//Tome of Water Magic
	giveArtBonus(89,Bonus::EARTH_SPELLS,0);//Tome of Earth Magic

	giveArtBonus(90,Bonus::WATER_WALKING, 0, 1);//Boots of Levitation
	giveArtBonus(91,Bonus::NO_SHOTING_PENALTY,0);//Golden Bow
	giveArtBonus(92,Bonus::SPELL_IMMUNITY,0,35);//Sphere of Permanence
	giveArtBonus(93,Bonus::NEGATE_ALL_NATURAL_IMMUNITIES,0);//Orb of Vulnerability

	giveArtBonus(94,Bonus::STACK_HEALTH,+1);//Ring of Vitality
	giveArtBonus(95,Bonus::STACK_HEALTH,+1);//Ring of Life
	giveArtBonus(96,Bonus::STACK_HEALTH,+2);//Vial of Lifeblood

	giveArtBonus(97,Bonus::STACKS_SPEED,+1);//Necklace of Swiftness
	giveArtBonus(98,Bonus::LAND_MOVEMENT,+600);//Boots of Speed
	giveArtBonus(99,Bonus::STACKS_SPEED,+2);//Cape of Velocity

	giveArtBonus(100,Bonus::SPELL_IMMUNITY,0,59);//Pendant of Dispassion
	giveArtBonus(101,Bonus::SPELL_IMMUNITY,0,62);//Pendant of Second Sight
	giveArtBonus(102,Bonus::SPELL_IMMUNITY,0,42);//Pendant of Holiness
	giveArtBonus(103,Bonus::SPELL_IMMUNITY,0,24);//Pendant of Life
	giveArtBonus(104,Bonus::SPELL_IMMUNITY,0,25);//Pendant of Death
	giveArtBonus(105,Bonus::SPELL_IMMUNITY,0,60);//Pendant of Free Will
	giveArtBonus(106,Bonus::SPELL_IMMUNITY,0,17);//Pendant of Negativity
	giveArtBonus(107,Bonus::SPELL_IMMUNITY,0,61);//Pendant of Total Recall
	giveArtBonus(108,Bonus::MORALE,+3);//Pendant of Courage
	giveArtBonus(108,Bonus::LUCK,+3);//Pendant of Courage

	giveArtBonus(109,Bonus::GENERATE_RESOURCE,+1,4); //Everflowing Crystal Cloak
	giveArtBonus(110,Bonus::GENERATE_RESOURCE,+1,5); //Ring of Infinite Gems
	giveArtBonus(111,Bonus::GENERATE_RESOURCE,+1,1); //Everpouring Vial of Mercury
	giveArtBonus(112,Bonus::GENERATE_RESOURCE,+1,2); //Inexhaustible Cart of Ore
	giveArtBonus(113,Bonus::GENERATE_RESOURCE,+1,3); //Eversmoking Ring of Sulfur
	giveArtBonus(114,Bonus::GENERATE_RESOURCE,+1,0); //Inexhaustible Cart of Lumber
	giveArtBonus(115,Bonus::GENERATE_RESOURCE,+1000,6); //Endless Sack of Gold
	giveArtBonus(116,Bonus::GENERATE_RESOURCE,+750,6); //Endless Bag of Gold
	giveArtBonus(117,Bonus::GENERATE_RESOURCE,+500,6); //Endless Purse of Gold

	giveArtBonus(118,Bonus::CREATURE_GROWTH,+5,1); //Legs of Legion
	giveArtBonus(119,Bonus::CREATURE_GROWTH,+4,2); //Loins of Legion
	giveArtBonus(120,Bonus::CREATURE_GROWTH,+3,3); //Torso of Legion
	giveArtBonus(121,Bonus::CREATURE_GROWTH,+2,4); //Arms of Legion
	giveArtBonus(122,Bonus::CREATURE_GROWTH,+1,5); //Head of Legion

	//Sea Captain's Hat 
	giveArtBonus(123,Bonus::WHIRLPOOL_PROTECTION,0); 
	giveArtBonus(123,Bonus::SEA_MOVEMENT,+500); 
	giveArtBonus(123,Bonus::SPELL,3,0, Bonus::INDEPENDENT_MAX);
	giveArtBonus(123,Bonus::SPELL,3,1, Bonus::INDEPENDENT_MAX);

	giveArtBonus(124,Bonus::SPELLS_OF_LEVEL,3,1); //Spellbinder's Hat
	giveArtBonus(125,Bonus::ENEMY_CANT_ESCAPE,0); //Shackles of War
	giveArtBonus(126,Bonus::BLOCK_SPELLS_ABOVE_LEVEL,0);//Orb of Inhibition

	//vial of dragon blood
	giveArtBonus(127, Bonus::PRIMARY_SKILL, +5, PrimarySkill::ATTACK, Bonus::BASE_NUMBER, new HasAnotherBonusLimiter(Bonus::DRAGON_NATURE));
	giveArtBonus(127, Bonus::PRIMARY_SKILL, +5, PrimarySkill::DEFENSE, Bonus::BASE_NUMBER, new HasAnotherBonusLimiter(Bonus::DRAGON_NATURE));

	//Armageddon's Blade
	giveArtBonus(128, Bonus::SPELL, 3, 26, Bonus::INDEPENDENT_MAX);
	giveArtBonus(128, Bonus::SPELL_IMMUNITY,0, 26);
	ART_ATTACK_AND_DEFENSE(128, +3);
	ART_PRIM_SKILL(128, 2, +3);
	ART_PRIM_SKILL(128, 3, +6);

	//Angelic Alliance
	giveArtBonus(129, Bonus::NONEVIL_ALIGNMENT_MIX, 0);
	giveArtBonus(129, Bonus::OPENING_BATTLE_SPELL, 10, 29); // Prayer

	//Cloak of the Undead King
	giveArtBonus(130, Bonus::IMPROVED_NECROMANCY, 0);

	//Elixir of Life
	giveArtBonus(131, Bonus::STACK_HEALTH, +25, -1, Bonus::PERCENT_TO_BASE);
	giveArtBonus(131, Bonus::HP_REGENERATION, +50);

	//Armor of the Damned
	giveArtBonus(132, Bonus::OPENING_BATTLE_SPELL, 50, 54); // Slow
	giveArtBonus(132, Bonus::OPENING_BATTLE_SPELL, 50, 47); // Disrupting Ray
	giveArtBonus(132, Bonus::OPENING_BATTLE_SPELL, 50, 45); // Weakness
	giveArtBonus(132, Bonus::OPENING_BATTLE_SPELL, 50, 52); // Misfortune

	// Statue of Legion - gives only 50% growth
	giveArtBonus(133, Bonus::CREATURE_GROWTH_PERCENT, 50);

	//Power of the Dragon Father
	giveArtBonus(134, Bonus::LEVEL_SPELL_IMMUNITY, 4);

	//Titan's Thunder
	// FIXME: should also add a permanent spell book, somehow.
	giveArtBonus(135, Bonus::SPELL, 3, 57);

	//Admiral's Hat
	giveArtBonus(136, Bonus::FREE_SHIP_BOARDING, 0);

	//Bow of the Sharpshooter
	giveArtBonus(137, Bonus::NO_SHOTING_PENALTY, 0);
	giveArtBonus(137, Bonus::FREE_SHOOTING, 0);

	//Wizard's Well
	giveArtBonus(138, Bonus::FULL_MANA_REGENERATION, 0);

	//Ring of the Magi
	giveArtBonus(139, Bonus::SPELL_DURATION, +50);

	//Cornucopia
	giveArtBonus(140, Bonus::GENERATE_RESOURCE, +4, 1);
	giveArtBonus(140, Bonus::GENERATE_RESOURCE, +4, 3);
	giveArtBonus(140, Bonus::GENERATE_RESOURCE, +4, 4);
	giveArtBonus(140, Bonus::GENERATE_RESOURCE, +4, 5);
