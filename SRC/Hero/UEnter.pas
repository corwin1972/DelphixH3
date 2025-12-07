unit UEnter;

interface

uses  SysUtils, UFile, Forms, Math,
  UType, UMap,
  USnGame, USnDialog, UPathRect,UBattle,
  USnBattlefield,
  USnBuyCrea, USnBuyHero, USnBuyRes, USnBuyAmmo,
  USnHillFort, USnInfoCrea, USnInfoRes,
  USnLevelUp, USnOverview, USnPlayers, USnPuzzle, UCT, USnBuyShip;

procedure cmd_BonusBank(id: integer);
procedure cmd_BonusPandora(id: integer);
function  Cmd_HE_EnterObj(value,ax,ay,al: integer):integer;
function Cmd_HE_CanEnterObj(value,ax,ay,al: integer): boolean;
{----------------------------------------------------------------------------}
{Types of objects (#1):
(Number in parenthesis is object type number)
0 - Learning Stone (100)
1 - Marletto Tower (23)
2 - Garden of Revelation (32)
3 - Mercenary Camp (51)
4 - Star Axis (61)
5 - Tree of Knowledge (102)
6 - Library of Enlightenment (41)
7 - Arena (4)
8 - School of Magic (47)
9 - School of War (107) }
{----------------------------------------------------------------------------}


implementation

Uses UOB, UHE, UPL, UMain;

var
  obX: TObjIndex;
  PL: integer;
  HE: integer;
  NewAction: integer;
  x,y,l: integer;

const //text message
  AD000_Arena_Bonus=0;
  AD001_Arena_Visited=1;
  AD002_ART_NoSLOT=2;
  AD003_ART_NoWisdom=3;
  AD004_ART_QMoney1=4;
  AD005_ART_QMoney2=5;
  AD006_ART_QMoney3=6;
  AD007_ART_Reward=7;
  AD008_ART_Fight1=8;
  AD009_ART_Fight2=9;
  AD010_ART_NoMoney=10;
  AD011_ART_NoFight=11;
  //AD012_ART_NoPay=12;
  AD013_ART_NoPay=13;
  AD014_PANDORA_QOpen=14;
  AD015_PANDORA_Empty=15;
  AD016_PANDORA_Fight=16;
  AD017_Border_Enter=17;
  AD018_Border_NOEnter=18;
  AD019_TENT_EnterLeader=19;
  AD020_TENT_Enter2=20;
  AD021_Bouee_Moral=21;
  AD022_Bouee_Nothing=22;
  AD023_Camp=23;
  AD024_Carto_Visited=24;
  AD025_Carto_Water=25;
  AD026_Carto_Earth=26;
  AD027_Carto_Under=27;
  AD028_Carto_NoMoney=28;
  AD029_Cygne_Moral=29;
  AD030_Cygne_visited=30;
  AD031_Fog=31;
  AD032_Bank_QBattle=32;
  AD033_Bank_Visited=33;
  AD034_Bank_Bonus =34;
  AD035_Recruit_QBuy=35;
  AD036_Recruit_QBuy4=36;
  AD037_Skeleton_QSearch=37;
  AD038_Skeleton_Visited=38;
  AD039_Marletto_Bonus=39;
  AD040_Marletto_Visited=40;
  AD041_Derelict_QBattle=41;
  AD042_Derelict_NoBonus=42;
  AD043_Derelict_Bonus=43;
  AD045_Fire_NOBonus=45;
  //AD046_BUG
  AD047_Utopia_QBattle=47;
  AD048_EyeLooking=48;
  AD049_Faery_Bonus=49;
  AD050_Faery_Visited=50;
  AD051_FlotSam_No =51;
  AD052_FlotSam_Wood=52;
  AD053_FlotSam_WoodGold=53;
  AD054_FlotSam_WoodGold=54;
  AD055_Fortune_Bonus=55;
  AD056_Fortune_Visited=56;
  AD057_Yough_Bonus=57;
  AD058_Yough_Visited=58;
  AD059_Garden_Bonus=59;
  AD060_Garden_Visited=60;
  AD061_EyeSee=61;
  AD062_Idol_Bonus=62;
  AD063_Idol_visited=63;
  AD064_Lean_Bonus=64;
  AD065_Lean_visited=65;
  AD066_Library_Bonus=66;
  AD067_Library_Visited=67;
  AD068_Library_No=68;
  AD069_Lighthouse=69;
  AD070_Portal_No=70;
  AD071_SchoolMagic_Qbuy=71;
  AD072_SchoolMagic_visited=72;
  AD073_SchoolMagic_NoMoney=73;
  AD074_MagicSpring_Bonus=74;
  AD075_MagicSpring_Visited=75;
  AD076_MagicSpring_Maxi=76;
  AD077_MagicWell_Recover=77;
  AD078_MagicWell_Visited=78;
  AD079_MagicWell_Maxi=79;
  AD080_Mercenary_Bonus=80;
  AD081_Mercenary_Visited=81;
  AD082_Mermaid_Bonus=82;
  AD083_Mermaid_Visited=83;
  AD086_Recruit_QJoin=86;
  AD087_Recruit_NoJoin=87;
  AD088_Recruit_QBuy=88;
  AD089_Mine7_QBattle=89;
  AD089_Mine7_Bonus=90;
  AD091_Recruit_QBattle=91;
  AD092_Mystical_Bonus=92;
  AD093_Mystical_Visited=93;
  AD094_Oasis_Visited=94;
  AD095_Oasis_Bonus=95;
  AD096_Obelisk_Bonus=96;
  AD097_Obelisk_Visited=97;
  AD098_Tree_UnFog=98;
  AD099_Pillar_UnFog=99;
  AD100_Axis_Bonus=100;
  AD101_Axis_Visited=101;
  AD102_Prison_newhero=102;
  AD103_Prison_maxhero=103;
  AD104_Prison_libhero=104;
  AD105_Pyramid_QEnter=105;
  AD106_Pyramid_Bonus=106;
  AD107_Pyramid_Visited=107;
  AD108_Pyramid_NoWisdom=108;
  AD109_Pyramid_NoBook=109;
  AD110_RallyFlag_Visited=110;
  AD111_RallyFlag_Bonus=111;
  AD112_Refugee=112;
  AD113_Res_Bonus=113;
  AD114_Sanctuary=114;
  AD115_Scholar=115;
  AD116_Seechest_No=116;
  AD117_Seechest_GoldArt=117;
  AD118_Seechest_Gold=118;
  AD119_Crypte=119;
  AD120_Crypte_Visited=120;
  AD121_Crypte_Bonus=121;
  AD122_Shipwreck_QBattle=122;
  AD123_Shipwreck_NoBonus=123;
  AD124_Shipwreck_Bonus=124;
  AD125_Survivor_Art=125;
  AD126_Survivor_NoSlot=126;
  AD127_ShrineofMagicIncantation=127;
  AD128_ShrineofMagicGesture=128;
  AD129_ShrineofMagicThought=129;
  AD130_Spell_Nolevel=130;
  AD131_Spell_NoBook=131;
  AD132_Sirens_Bonus=132;
  AD133_Sirens_NoBonus=133;
  AD134_Sirens_Noeffect=134;
  AD135_Scroll=135;
  AD136_Stable_Visited=136;
  AD137_Stable_Bonus=137;
  AD138_Stable_Bonus1=138;
  AD139_Stable_Bonus2=139;
  AD140_Temple_Bonus=140;
  AD141_Temple_Visited=141;
  AD142_Tavern_Info=142;
  AD143_KnowStone_Bonus=143;
  AD144_KnowStone_Visited=144;
  AD145_Chest_Art=145;
  AD146_Chest_QExp=146;
  AD147_KnowTree_Visited=147;
  AD148_KnowTree_Bonus=148;
  AD149_KnowTree_NeedMoney=149;
  AD150_KnowTree_NoMoney=150;
  AD151_KnowTree_NeedGem=151;
  AD152_KnowTree_NoGem=152;
  AD154_Wagon_Bonus1=154;
  AD155_Wagon_Bonus2=155;
  AD156_Wagon_Visited=156;
  AD157_WarMachine_QBuy=157;
  AD158_SchollWar_Bonus=158;
  AD159_Schoolwar_Visited=159;
  AD160_SchoolWar_NoMoney=160;
  AD161_Tomb_Q=161;
  AD162_Tomb_Bonus=162;
  AD163_Tomb_Moral=163;
  AD164_WaterMill_Bonus=164;
  AD165_WaterMill_Visited=165;

  AD169_WindMill_Visited=169;
  AD170_WindMill_Bonus=170;
  AD171_WitchHut_Bonus=171;
  AD172_WitchHut_HasSkill=172;
  AD173_WitchHut_MaxSkill=173;
  AD174_Shrine_SpellAlreadyknown=174;
{----------------------------------------------------------------------------}
function Cmd_OB_FindbyQuestID(ID:string):integer ;
var
  MO:integer;
begin
  for MO:=0 to NMOnsters-1 do
  begin
    if (mMonsters[MO].questID=ID) then break;
  end;
  result:=MO;
end;
{----------------------------------------------------------------------------}
procedure cmd_BonusBank(id: integer);
var
  i: integer;
  CR :integer;
  nCR:integer;
  qty: integer;
begin
  //AD034_Bank_Bonus
  {CR:=mBanks[mObjs[id].v].bArmy.t;
  nCR:=mBanks[mObjs[id].v].bArmy.n;
  processEnterInfo(format(txtADVEVENT[34],[iCrea[CR].name,iCrea[CR].name]));
  cmd_HE_AddCrea(HE,CR,nCR);     }
  CR:= mObjs[id].Armys[0].t;
  with mBanks[mObjs[id].v] do
  begin
    qty:=bRes[6];
    if qty > 0 then
    begin
      processEnterInfo(format(txtADVEVENT[34],[iCrea[CR].name,'Gold']));
      mPlayers[mPL].Res[6]:=mPlayers[mPL].Res[6]+ qty
    end;

    if bTotalArts > 0 then
    for i:=0 to bTotalArts - 1 do
    begin
       processEnterInfo('You Get a ART bonus : ' + iART[bARTS[i]].name);
       cmd_HE_SetART(HE,bARTS[i]);
    end;
  end;
  mBanks[mObjs[id].v].Take:=true;
end;
{  case pObj.v of
      1: s:='1000';
      2: s:='2000';
      3: s:='2500';
      4: s:='5000';
      end;
      mDialog.mes:=txtADVEVENT[AD121_Crypte_Bonus] + s + ' or';
}
{----------------------------------------------------------------------------}
procedure cmd_BonusPandora(id: integer);
var
  HasBonus: boolean;
begin
  HasBonus:=false;
  with mBonus[mObjs[ID].u] do
  begin
    if nCR > 0 then
    begin
      HasBonus:=true;
      processEnterInfo('You Get a Crea bonus : ' + iCrea[CREAS[0].t].name);
      cmd_HE_AddCrea(HE,CREAS[0].t,CREAS[0].n);
    end;
    if nART > 0 then
    begin
      HasBonus:=true;
      processEnterInfo('You Get a ART bonus : ' + iART[ARTS[0]].name);
      cmd_HE_SetART(HE,ARTS[0]);
    end;
  end;
  if HasBonus=false then
     processEnterInfo(txtADVEVENT[AD015_PANDORA_Empty]);
  NewAction:=ACT02_Delete;
end;
{----------------------------------------------------------------------------}
procedure EnterOB04_Arena;                             //VisID=7
begin
  if mHeros[HE].VisObj[7,pObj.v] then
  begin
    processEnterInfo(txtADVEVENT[AD001_Arena_Visited]);
  end
  else
  begin
    processDialog(txtADVEVENT[AD000_Arena_Bonus],dsPriSkill,1);
    mHeros[HE].VisObj[7,pObj.v]:=true;
    if mDialog.res =0
    then
      Cmd_HE_AddSkill(HE,2,0,0,0)  //Atk bonus
    else
      Cmd_HE_AddSkill(HE,0,2,0,0); //Def bonus
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB05_Artifact;
var
  AR :integer;
begin
  if pObj.Guarded then
  begin
    processEnterInfo(txtADVEVENT[AD009_ART_Fight2]);
    cmd_BA_InitBattle(mHeros[HE].oid,pObj.id);
    if mPLayers[mPL].isCPU
    then begin
      cmd_BA_AutoBattle;
      if bWinLeft then
      begin
        processEnterInfo(txtADVEVENT[AD007_ART_Reward]);
        AR:=pObj.u;
        NewAction:=ACT02_Delete;
        Cmd_HE_SetART(HE,AR);
      end;
    end
    else NewAction:=ACT04_Battle; //TSnBattleField.Create;
  end
  else
  begin
    AR:=pObj.u;
    processDialog(iArt[AR].event,dsArt,AR);
    NewAction:=ACT02_Delete;
    Cmd_HE_SetART(HE,AR);    //equip art and set bonus
  end;
  {AD002_ART_NoSLOT=2;
  AD003_ART_NoWisdom=3;
  AD004_ART_QMoney1=4;
  AD005_ART_QMoney2=5;
  AD006_ART_QMoney3=6;
  AD007_ART_Reward=7;
  AD008_ART_Fight1=8;
  AD009_ART_Fight2=9;
  AD010_ART_NoMoney=10;
  AD011_ART_NoFight=11;
  AD012_ART_NoPay=12;
  AD013_ART_NoPay=13;}
end;
{----------------------------------------------------------------------------}
procedure EnterOB06_Pandora;
begin
  if pObj.msg <> '' then processEnterInfo(pObj.msg);

  if processQuestion(txtADVEVENT[AD014_PANDORA_QOpen])
  then
  begin
    if pobj.Guarded then
    begin
      processEnterInfo(txtADVEVENT[AD016_PANDORA_Fight]);
      cmd_BA_InitBattle(mHeros[HE].oid,pObj.id);
      if mPLayers[mPL].isCPU then
      begin
        cmd_BA_AutoBattle;
        if bWinLeft then  cmd_BonusPandora(pObj.id);
      end
      else NewAction:=ACT04_Battle; //TSnBattleField.Create;
    end
    else
    begin
      cmd_BonusPandora(pObj.id);
    end;
  end
  else
  NewAction:=ACT12_CancelMove;
end;
{----------------------------------------------------------------------------}
procedure EnterOB08_Boat;
begin
  mHeros[HE].BoatId:=pObj.id;
  mHeros[HE].PSKA.mov:=0;
  pObj.pid:=PL;
end;
{----------------------------------------------------------------------------}
procedure EnterOB09_BorderGuard;
begin
  if mPlayers[mPL].TentVisited[pObj.u] then
  begin
    processEnterInfo(txtADVEVENT[AD017_Border_Enter]);
    NewAction:=ACT02_Delete;
  end
  else
  begin
    processEnterInfo(txtADVEVENT[AD018_Border_NOEnter]);
    NewAction:=ACT00_Nothing;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB10_KeyMaster;
begin
  if mPlayers[mPL].TentVisited[pObj.u]
  then
    processEnterInfo(txtADVEVENT[AD020_TENT_Enter2])
  else
    processEnterInfo(txtADVEVENT[AD019_TENT_EnterLeader]);
  mPlayers[mPL].TentVisited[pObj.u]:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB11_Buoy;
begin
  if mHeros[HE].VisBuoy=false
  then
  begin
    processDialog(txtADVEVENT[AD021_Bouee_Moral],dsMorale_p,1);
    mHeros[HE].moral:=MIN(3,mHeros[HE].moral+1);
    //this bonus will be lost after next battle
  end
  else
    processEnterInfo(txtADVEVENT[AD022_Bouee_Nothing]);
  mHeros[HE].VisBuoy:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB12_Fire;
begin
  processDialog(txtADVEVENT[AD023_Camp],dsMapBonus,pOBJ.u,pOBJ.v);
  //processEnterInfo(txtADVEVENT[AD023_Camp]);
  Cmd_PL_AddRes(PL,6,100* pOBJ.v);
  Cmd_PL_AddRes(PL,pOBJ.u,pOBJ.v);
  NewAction:=ACT02_Delete;
end;
{----------------------------------------------------------------------------}
procedure EnterOB13_Cartographer;
begin
  case pObj.U of
    0: begin
      if mPlayers[PL].allWtrMap
      then
        processEnterInfo(txtADVEVENT[AD024_Carto_Visited])
      else
      begin
        if mPLayers[PL].res[6] < 1000
        then
           processEnterInfo(txtADVEVENT[AD028_Carto_NoMoney])
        else
        if processQuestion(txtADVEVENT[AD025_Carto_Water]) then
        begin
           Cmd_Map_UnfogWaterLevel(PL,pOBJ.pos.l);
           Cmd_PL_AddRes(PL,6,-1000);
        end;
      end;
    end;

    1: begin
      if mPlayers[PL].allTopMap
      then
        processEnterInfo(txtADVEVENT[AD024_Carto_Visited])
      else
      begin
        if mPLayers[PL].res[6] < 1000
        then
           processEnterInfo(txtADVEVENT[AD028_Carto_NoMoney])
        else
        if processQuestion(txtADVEVENT[AD026_Carto_Earth]) then
        begin
           Cmd_Map_UnfogEarthLevel(PL,pOBJ.pos.l);
           Cmd_PL_AddRes(PL,6,-1000);
        end;
      end;
    end;

    2: begin
      if mPlayers[PL].allSubMap
      then
        processEnterInfo(txtADVEVENT[AD024_Carto_Visited])
      else
      begin
        if mPLayers[PL].res[6] < 1000
        then
           processEnterInfo(txtADVEVENT[AD028_Carto_NoMoney])
        else
        if processQuestion(txtADVEVENT[AD027_Carto_Under]) then
        begin
           Cmd_Map_UnfogEarthLevel(PL,pOBJ.pos.l);
           Cmd_PL_AddRes(PL,6,-1000);
        end;
      end;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB14_SwanPond;
begin
  if mHeros[HE].VisSwan=false
  then
  begin
    processDialog(txtADVEVENT[AD029_Cygne_Moral],dsLuck_p,1);
    mHeros[HE].luck:=MIN(3,mHeros[HE].luck+2);
    mHeros[HE].PSKA.mov:=0;
    //this bonus will be lost after next battle
  end
  else
    processEnterInfo(txtADVEVENT[AD030_Cygne_visited]);
  mHeros[HE].VisSwan:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB15_CoverofDarkness;
begin
  processEnterInfo(txtADVEVENT[AD031_Fog]);
  Cmd_Map_DoFog(mPL,x,y,l,20);  //TODO before was Radius 8
end;
{----------------------------------------------------------------------------}
procedure EnterOB16_CreatureBank;
begin
  if mBanks[pObj.v].take=false
  then
  begin
    if processQuestion(format(txtADVEVENT[AD032_Bank_QBattle],[iBank[pObj.u,0].name])) then
    begin
     cmd_BA_InitBattle(mHeros[HE].oid,pObj.id);
     NewAction:=ACT04_Battle; //TSnBattleField.Create;    //TODO CPU case
    end;
  end
  else
  begin
    mBanks[pObj.v].visited[PL]:=true;
    processEnterInfo(format(txtADVEVENT[AD033_Bank_Visited],[iBank[pObj.u,0].name]));
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB17_Generator;
var
  CR,n: integer;
begin
  CR:=2*(pObj.def-157);
  if CR >115 then CR:=1;
  n:=pObj.v;
  pObj.pid:=PL;
  if mPLayers[PL].isCPU then exit; //TODO: CPU can recruit
  if processQuestion(format(txtADVEVENT[AD035_Recruit_QBuy],[TxtCrGen1[pobj.u],iCrea[CR].name]))
  then begin
    mDialog.res:=-1;
    TSnBuyCrea.Create(CR,n);
    repeat
      Application.HandleMessage
    until mDialog.res <> -1;
    if mDialog.res >0 then
    begin
      if cmd_HE_BuyCrea(HE,CR,mDialog.res)
      then pObj.v:=pObj.v-mDialog.res;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB22_Corpse;
var
  AR: integer;
begin
  AR:=pObj.v;
  if AR=0 then
  begin
    processEnterInfo(txtADVEVENT[AD038_Skeleton_Visited]);
  end
  else
  begin
    processEnterInfo(txtADVEVENT[AD037_Skeleton_QSearch]+ iArt[AR].name);
    cmd_HE_setArt(HE,AR);
  end;
  pObj.v:=0;
end;
{----------------------------------------------------------------------------}
procedure EnterOB23_MarlettoTower;               //VisId=1
begin
  if mHeros[HE].VisObj[1,pObj.v] then
  begin
    processEnterInfo(txtADVEVENT[AD040_Marletto_visited]);
  end
  else
  begin
    processDialog(txtADVEVENT[AD039_Marletto_Bonus],dsPriSkill+1,1);
    mHeros[HE].VisObj[1,pObj.v]:=true;
    inc(mHeros[HE].PSKB.def);
    inc(mHeros[HE].PSKA.def);
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB24_DerelictShip;
begin
  if mBanks[pObj.v].Take then
    processEnterInfo('Ship Visited')
  else
  if processQuestion(txtADVEVENT[AD041_Derelict_QBattle])  then
  begin
    cmd_BA_InitBattle(mHeros[HE].oid,pObj.id);
    NewAction:=ACT04_Battle; //TSnBattleField.Create;
  end;
  //  AD042_Derelict_NoBonus=42;
  //  AD043_Derelict_Bonus=43;
end;
{----------------------------------------------------------------------------}
procedure EnterOB25_DragonUtopia;
begin
  if mBanks[pObj.v].Take then
    processEnterInfo('Utopia Visited')
  else
  if processQuestion(txtADVEVENT[AD047_Utopia_QBattle])  then
  begin
    cmd_BA_InitBattle(mHeros[HE].oid,pObj.id);
    NewAction:=ACT04_Battle; //TSnBattleField.Create;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB26_Event;
begin
  processEnterInfo(mSigns[pObj.v]);
  NewAction:=ACT02_Delete;
end;
{----------------------------------------------------------------------------}
procedure EnterOB27_EyeoftheMagi;
begin
  processEnterInfo(txtADVEVENT[AD048_EyeLooking]);
  //TODO Hutofthe Eye nfog locally and center on object to see few s of revealed
end;
{----------------------------------------------------------------------------}
procedure EnterOB28_Faery;
begin
  if mHeros[HE].VisFaery=false
  then
  begin
    processDialog(txtADVEVENT[AD049_Faery_Bonus],dsLuck_p,1);
    mHeros[HE].luck:=mHeros[HE].luck+1;
    //this bonus will be lost after next battle
  end
  else
    processEnterInfo(txtADVEVENT[AD050_Faery_Visited]);
  mHeros[HE].VisFaery:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB29_FlotSam;
begin
  // 25% rien, 25% 5 bois ,25% 5bois+200or, 25% 5bois+500 or
  NewAction:=ACT02_Delete;
  case pObj.v of
    0: processEnterInfo(txtADVEVENT[AD051_FlotSam_No]);
    1: begin
      processDialog(txtADVEVENT[AD052_FlotSam_Wood],dsRes0,5);
      mPlayers[PL].Res[0]:=mPlayers[PL].Res[0]+5;
    end;
    2: begin
      processDialog(txtADVEVENT[AD054_FlotSam_WoodGold],dsMapBonus,dsRes0,10);  //54 EPAVES
      mPlayers[PL].Res[0]:=mPlayers[PL].Res[0]+10;
      mPlayers[PL].Res[6]:=mPlayers[PL].Res[6]+1000;
    end;
    3: begin
      processDialog(txtADVEVENT[AD053_FlotSam_WoodGold],dsMapBonus,dsRes0,5); //55 DEBRIS
      mPlayers[PL].Res[0]:=mPlayers[PL].Res[0]+5;
      mPlayers[PL].Res[6]:=mPlayers[PL].Res[6]+500;
    end;
  end;
end;

{----------------------------------------------------------------------------}
procedure EnterOB30_FountainofFortune;
begin
  if mHeros[HE].VisFortune=false
  then
  begin
    processDialog(txtADVEVENT[AD055_Fortune_Bonus],dsLuck_p,1);
    mHeros[HE].luck:=mHeros[HE].luck+1;
    //this bonus will be lost after next battle
  end
  else
    processEnterInfo(txtADVEVENT[AD056_Fortune_Visited]);
  mHeros[HE].VisFortune:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB31_FountainofYouth;
begin
  if mHeros[HE].VisYough=false
  then
  begin
    processDialog(txtADVEVENT[AD057_Yough_Bonus],dsMorale_p,1);
    mHeros[HE].luck:=MIN(3,mHeros[HE].luck+1);
    mHeros[HE].PSKA.mov:= mHeros[HE].PSKA.mov+400;
    //this bonus will be lost after next battle
  end
  else
    processEnterInfo(txtADVEVENT[AD058_Yough_Visited]);
  mHeros[HE].VisYough:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB32_Garden;                      //VisId=2
begin
  if mHeros[HE].VisObj[2,pObj.v] then
    processEnterInfo(txtADVEVENT[AD060_Garden_Visited])
  else
  begin
    processDialog(txtADVEVENT[AD059_Garden_Bonus],dsPriSkill+2,1);
    mHeros[HE].VisObj[2,pObj.v]:=true;
    inc(mHeros[HE].PSKB.pow);
    inc(mHeros[HE].PSKA.pow);
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB33_Garnison;
begin
  if  not(cmd_PL_SameTeam(pObj.pid,PL))
  then
  begin
    //TODO if armys need to fight them or not ?
    pObj.pid:=PL;
  end;
  NewAction:=ACT11_Gar;
end;
{----------------------------------------------------------------------------}
procedure EnterOB34_Hero;
begin
  if cmd_PL_SameTeam(mHeros[pObj.v].pid,PL)
  then
  begin
    processEnterInfo('Meet Friendly Hero ' + mHeros[pObj.v].name);
    NewAction:=ACT05_Meet;
  end
  else
  begin
    processEnterInfo('Prepare for Fighting against ' + mHeros[pObj.v].name);
    cmd_BA_InitBattle(mHeros[HE].oid,mHeros[pObj.v].oid);
    NewAction:=ACT04_Battle;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB35_HillFort;
begin
  TSnHillFort.Create(HE);
end;
{----------------------------------------------------------------------------}
procedure EnterOB37_HutoftheMagi;
var
  i:integer;
begin
  processEnterInfo(txtADVEVENT[AD061_EyeSee]);
  i:=-1;
  repeat
    i:=Cmd_OB_Find(OB27_EyeoftheMagi,i+1);
    if i > -1 then Cmd_Map_Unfog(PL,mobjs[i].pos.x,mobjs[i].pos.y,mobjs[i].pos.l,10);
  until  i=-1;
end;
{----------------------------------------------------------------------------}
procedure EnterOB38_IdolofFortune;
begin
  if mHeros[HE].VisIdol=false
  then
  begin
    processDialog(txtADVEVENT[AD062_Idol_Bonus],dsLuck_p,1);
    mHeros[HE].luck:=mHeros[HE].luck+1;
  end
  else
    processEnterInfo(txtADVEVENT[AD063_Idol_Visited]);

  mHeros[HE].VisIdol:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB39_LeanTo;
var
  rid: byte;
begin
  if pObj.v > 0 then
  begin
    rid:=random(6);
    processDialog(txtADVEVENT[AD064_Lean_Bonus],dsRes0+rId, pObj.v);
    //processEnterInfo(txtADVEVENT[AD064_Lean_Bonus]);
    cmd_PL_AddRes(PL,rid,pObj.v);
    pObj.v:=0
  end
  else
  begin
    processEnterInfo(txtADVEVENT[AD065_Lean_visited]);
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB41_Library;
begin
  if mHeros[HE].VisObj[6,pObj.v] then
  begin
    processEnterInfo(txtADVEVENT[AD067_Library_Visited]);
  end
  else
  begin
    //to do: check renommee AD068_Library_No  (not enough famous...
    processDialog(txtADVEVENT[AD066_Library_Bonus],dsPriSkill,2);
    mHeros[HE].VisObj[6,pObj.v]:=true;
    Cmd_He_AddSkill(HE,2,2,2,2);
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB42_LightHouse;
begin
  processEnterInfo(txtADVEVENT[AD069_Lighthouse]);
end;
{----------------------------------------------------------------------------}
procedure EnterOB43_Monolith_Entrance;
var
  oid: integer;
begin
  NewAction:=ACT07_TelePort;
  oid:=Cmd_OB_Find(OB44_Monolith_exit,0);
  if oid = pObj.id then oid:=Cmd_OB_Find(OB44_Monolith_exit,oid+1);
  with mObjs[oid].pos do
  begin
    mHeros[HE].tgt.x:=x;
    mHeros[HE].tgt.y:=y;
    mHeros[HE].tgt.l:=l;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB44_Monolith_exit;
begin
  processEnterInfo(txtADVEVENT[AD070_Portal_No]);
end;
{----------------------------------------------------------------------------}
procedure EnterOB45_Monolith_2way;
var
  oid: integer;
begin
  NewAction:=ACT07_TelePort;
  oid:=Cmd_OB_Find(OB45_Monolith_2way,0);
  if oid = pObj.id then oid:=Cmd_OB_Find(OB45_Monolith_2way,oid+1);
  with mObjs[oid].pos do
  begin
    mHeros[HE].tgt.x:=x;
    mHeros[HE].tgt.y:=y;
    mHeros[HE].tgt.l:=l;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB47_SchoolofMagic;
begin
  if mHeros[HE].VisObj[8,pObj.v] then
  begin
    processEnterInfo(txtADVEVENT[AD072_SchoolMagic_visited]);
  end
  else
  begin
    //has money
    if mPlayers[mPL].res[6] > 1000 then
    begin
      processDialog(txtADVEVENT[AD071_SchoolMagic_Qbuy],dsPriSkill+3,1);
      if mDialog.res=0 then exit;
      mHeros[HE].VisObj[8,pObj.v]:=true;
      if mDialog.res=2 then
      begin
        inc(mHeros[HE].PSKB.pow);
        inc(mHeros[HE].PSKA.pow);
      end;
      if mDialog.res=1 then
      begin
        inc(mHeros[HE].PSKB.kno);
        inc(mHeros[HE].PSKA.kno);
      end;
      mPlayers[mPL].res[6]:=mPlayers[mPL].res[6] - 1000;
    end
    else
    begin
      // no money
      processEnterInfo(txtADVEVENT[AD073_SchoolMagic_NoMoney]);
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB48_MagicSpring;
begin
  if pObj.v=-1 then
  begin
    processEnterInfo(txtADVEVENT[AD075_MagicSpring_Visited]);
  end
  else
  begin
    if mHeros[HE].PSKA.ptm<2*mHeros[HE].PSKB.ptm then
    begin
      processDialog(txtADVEVENT[AD074_MagicSpring_Bonus],dsSpellPoints,10);
      mHeros[HE].PSKA.ptm:=2*mHeros[HE].PSKB.ptm;
      pObj.v:=-1;
    end
    else
    begin
      processEnterInfo(txtADVEVENT[AD076_MagicSpring_Maxi]);
      pObj.v:=-1;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB49_MagicWell;
begin
  if mHeros[HE].VisMagicWell=false then
  begin
    if mHeros[HE].PSKA.ptm=mHeros[HE].PSKB.ptm then
    begin
      processEnterInfo(txtADVEVENT[AD079_MagicWell_Maxi]);
    end
    else
    begin
      processEnterInfo(txtADVEVENT[AD077_MagicWell_Recover]);
      mHeros[HE].PSKA.ptm:=mHeros[HE].PSKB.ptm;
    end;
  end
  else
    processEnterInfo(txtADVEVENT[AD078_MagicWell_Visited]);

  mHeros[HE].VisMagicWell:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB51_MercenaryCamp;
begin
  if mHeros[HE].VisObj[3,pObj.v] then
  begin
    processEnterInfo(txtADVEVENT[AD081_Mercenary_Visited]);
  end
  else
  begin
    processDialog(txtADVEVENT[AD080_Mercenary_Bonus],dsPriSkill,1);
    mHeros[HE].VisObj[3,pObj.v]:=true;
    inc(mHeros[HE].PSKB.att);
    inc(mHeros[HE].PSKA.att);
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB52_Mermaid;
begin
  if mHeros[HE].VisMermaid
  then
    processEnterInfo(txtADVEVENT[AD083_Mermaid_Visited])
  else
    processEnterInfo(txtADVEVENT[AD082_Mermaid_Bonus]);
  mHeros[HE].VisMermaid:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB53_Mine; // mine on tgt + move
begin
  if  not(cmd_PL_SameTeam(mMines[pObj.v].pid,PL))
  then
  begin
    if ((pObj.u=0) or (pObj.u=2))
    then processDialog(iRes[pObj.u].event,dsRes0 + pObj.u,-2)
    else processDialog(iRes[pObj.u].event,dsRes0 + pObj.u,-1);
    Cmd_PL_AddMine(PL,pObj.v);
    mObjs[pObj.id].pid:=PL;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB54_Monster;
var
  id,r : integer;
  s: string;
  flee: boolean;
  qtyjoin: integer;
begin
  id:=pObj.u;
  if id>118 then exit;
  with mMonsters[pobj.v] do
  begin
    r:=random(100);
    case agressiv of
      0: flee:=true;
      1: flee:=(r < 20);
      2: flee:=(r < 10);
      3: flee:=(r < 5);
      else flee:=false;
    end;
    //TODO add never flee option see map loaad
    //SK04_Diplomacy=4;  if flee : diplomacy 25% 50% 100% to flee
    if flee then
    begin
      case mHeros[HE].SSK[SK04_Diplomacy] of
        0: qtyjoin:= qty div 4 +1;
        1: qtyjoin:= qty div 2 +1;
        2: qtyjoin:= qty;
        else qtyjoin:=0;
      end;
      if agressiv=0 then qtyjoin:= qty;
      if qtyjoin > 0
      then
      begin
        s:= format('%d %ss (%d) , with a desire of GLORY, wish to join you. Do you accept?',[qtyjoin,iCrea[id].name,qty]);
        cmd_HE_AddCrea(HE,id,qtyjoin);
      end
      else s:=iCrea[id].name + ' flees.';
      processQuestion(s);
    end
    else
    begin
      processEnterInfo(Msg + format(' Attacking %d %s',[qty,iCrea[id].name]));
      cmd_BA_InitBattle(mHeros[HE].oid,pObj.id);
    end;
  end;
  if flee
    then NewAction:=ACT02_Delete
    else NewAction:=ACT04_Battle;
end;
{----------------------------------------------------------------------------}
procedure EnterOB55_MysticalGarden;
var
  r,n : integer;
begin
  if pObj.v=-1 then
  begin
    processEnterInfo(txtADVEVENT[AD093_Mystical_Visited]);
  end
  else
  begin
    if pObj.v=0
    then
      begin r:=5; n:=5; end
    else
      begin r:=6; n:=500; end;
    processDialog(txtADVEVENT[AD092_Mystical_Bonus],dsRes0 + r,n);
    cmd_PL_AddRes(PL,r,n);
    pObj.v:=-1;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB56_Oasis;
begin
  if mHeros[HE].VisOasis=false
  then
  begin
    processDialog(txtADVEVENT[AD095_Oasis_Bonus],dsMorale_p,1);
    mHeros[HE].moral:=min(3,mHeros[HE].moral+2);
    mHeros[HE].PSKA.mov:=mHeros[HE].PSKA.mov+800;
    //this bonus will be lost after next battle
  end
  else
    processEnterInfo(txtADVEVENT[AD094_Oasis_Visited]);

  mHeros[HE].VisOasis:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB57_Obelisk;
begin
  if (pObj.v and (1 shl PL) =1 shl PL)
  then
  begin
   processEnterInfo(txtADVEVENT[AD097_Obelisk_Visited]);;
  end
  else
  begin
    processEnterInfo(txtADVEVENT[AD096_Obelisk_Bonus]);
    TSnPuzzle.create;
  end;
  pObj.v := pObj.v or (1 shl PL);
end;
{----------------------------------------------------------------------------}
procedure EnterOB58_Tree;
begin
  processEnterInfo(txtADVEVENT[AD098_Tree_UnFog]);
  Cmd_Map_Unfog(PL,x,y,l,21);  //TODO range20?
end;
{----------------------------------------------------------------------------}
procedure EnterOB59_Bottle;
begin
  processEnterInfo(mSigns[pObj.v]);
  NewAction:=ACT02_Delete;;
end;
{----------------------------------------------------------------------------}
procedure EnterOB60_PillarofFire;
begin
  processEnterInfo(txtADVEVENT[AD099_Pillar_UnFog]);
  Cmd_Map_Unfog(PL,x,y,l,21);  //TODO range20?  
end;
{----------------------------------------------------------------------------}
procedure EnterOB61_StarAxis;           //VisId=4;
begin
  if mHeros[HE].VisObj[4,pObj.v] then
  begin
    processEnterInfo(txtADVEVENT[AD101_Axis_Visited]);
  end
  else
  begin
    processDialog(txtADVEVENT[AD100_Axis_Bonus],dsPriSkill+2,1);
    mHeros[HE].VisObj[4,pObj.v]:=true;
    inc(mHeros[HE].PSKB.pow);
    inc(mHeros[HE].PSKA.pow);
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB62_Prison;
var
  newHE: integer;
begin
  if mPlayers[PL].nHero >=8 then
  begin
    processEnterInfo(txtADVEVENT[AD103_Prison_maxhero]);
  end
  else
  begin
    processEnterInfo(txtADVEVENT[AD102_Prison_newhero]);
    newHE:=pobj.v;
    mHeros[newHE].pos:=pObj.pos;
    cmd_OB_DEL(pObj.id);
    mHeros[newHE].pid:=PL;
    mHeros[newHE].oid:=0;
    Cmd_He_Add(newHE);
    SnGame.AddHero(newHE);
  end;
  //NewAction:=ACT02_Delete;;
  //AD0104_Prison_libhero=104;
end;
{----------------------------------------------------------------------------}
procedure EnterOB63_Pyramid;
begin
  if processQuestion(txtADVEVENT[AD105_Pyramid_QEnter]) then
  processEnterInfo(txtADVEVENT[AD106_Pyramid_Bonus]);
  {AD105_Pyramid_QEnter=105;
  AD106_Pyramid_Bonus=106;
  AD107_Pyramid_Visited=107;
  AD108_Pyramid_NoWisdom=108;
  AD109_Pyramid_NoBook=109;}
end;
{----------------------------------------------------------------------------}
procedure EnterOB64_RallyFlag;
begin
  if mHeros[HE].VisRallyFlag=false
  then
  begin
    processDialog(txtADVEVENT[AD111_RallyFlag_Bonus],dsLuck_p,1);
    mHeros[HE].luck:=min(3,mHeros[HE].luck+1);
    mHeros[HE].moral:=min(3,mHeros[HE].moral+1);
    mHeros[HE].PSKA.mov:=mHeros[HE].PSKA.mov+400;
    //this bonus will be lost after next battle
  end
  else
    processEnterInfo(txtADVEVENT[AD110_RallyFlag_Visited]);

  mHeros[HE].VisRallyFlag:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB78_RefugeeCamp;
begin
  processEnterInfo(txtADVEVENT[AD112_Refugee]);
end;
{----------------------------------------------------------------------------}
procedure EnterOB79_Res;
begin
  Cmd_PL_AddRes(PL,pObj.u,pObj.v);
  NewAction:=ACT02_Delete;;
  if mPLayers[mPL].isCPU then exit;

  //processDialog(txtADVEVENT[AD113_Res_Bonus],dsRes0+ pObj.u,pObj.v);
  SnGame.SubInfoRes.update(txtADVEVENT[AD113_Res_Bonus], pObj.u,pObj.v);
  SnGame.SHOWID:=SHOW3_RES;
end;
{----------------------------------------------------------------------------}
procedure EnterOB80_Sanctuary;
begin
  processEnterInfo(txtADVEVENT[AD114_Sanctuary]);
end;
{----------------------------------------------------------------------------}
procedure EnterOB81_Schoolar;
begin
  //learn a primary skill, sec skill, spell ????
  with mScholar[pObj.v] do
  begin
    case t of
      0:
      begin
        processDialog(txtADVEVENT[AD115_Scholar],dsPriSkill+ pk,1);
        Cmd_HE_AddPSK(HE,pk);
      end;
      1:
      begin
        //todo  check if sec skill already at max ?
        if (mHeros[HE].SSK[ss]<3) then
        begin
          processDialog(txtADVEVENT[AD115_Scholar],dsSecSkill,ss*3+3);
          Cmd_HE_AddSSK(HE,ss);
        end
        else
        begin
          pk:=random(4);
          processDialog(txtADVEVENT[AD115_Scholar],dsPriSkill+ pk,1);
          Cmd_HE_AddPSK(HE,pk);
        end;
      end;
      2:
      begin
        processDialog(txtADVEVENT[AD115_Scholar],dsSpell,sp);
        Cmd_HE_AddSpell(HE,sp);
      end;
    end;
  end;
  NewAction:=ACT02_Delete;;
end;
{----------------------------------------------------------------------------}
procedure EnterOB82_SeeChest;
var
  AR,v: integer;
begin
  NewAction:=ACT02_Delete;
  case pObj.v of
    0: begin
       processEnterInfo(txtADVEVENT[AD116_SeeChest_No]);
    end;
    1: begin
       AR:=random(100);
       v:=1500;
       processDialog(format(txtADVEVENT[AD117_SeeChest_GoldArt],[iArt[AR].name]),dsRes0 + 6,v);
       cmd_PL_AddRes(PL,6,v);
       cmd_HE_SetART(HE,AR);
    end;
    2: begin
       v:=1500;
       processDialog(txtADVEVENT[AD118_SeeChest_Gold],dsRes0 + 6,v);
       cmd_PL_AddRes(PL,6,v);
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB83_Seer;
var
  MO:integer;
  s1,s2,s3: string;
begin
  s1:='%s are menacing the %s region of this land.  If you could be so bold as to defeat them, I would reward you richly.';
  s2:='Don''t lose heart.  Defeating the %s is a difficult task, but you will surely succeed';
  s3:='At last, you defeated the %s, and the countryside is safe again!  Are you ready to accept the reward';
  with mSeers[pObj.v] do
  begin
    if Completed then
    begin
       processEnterInfo(format(txtseer[2],[name]));
    end
    else
    begin
      case quest of
        4: begin
          MO:=Cmd_OB_FindbyQuestID(QuestID);
          if not(visited[PL])
          then processEnterInfo(format(s1, [ICrea[mObjs[MMonsters[MO].oid].u].name,'Central Region']))
          else processEnterInfo(format(s2, [ICrea[mObjs[MMonsters[MO].oid].u].name]));
        end;
        5: begin
          mDialog.t:=dsArt;
          mDialog.v:=Q1;
          if Visited[PL]
          then
            processEnterInfo(format(txtseer[12],[iART[Q1].name]))
          else
            processEnterInfo(format(txtseer[22],[iART[Q1].name]));
        end;
      else
        processEnterInfo('only handled achievment  like ART - Defeat Monster Seer');
    end;

    visited[PL]:=true;
  end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB84_Crypt;
begin
  if processQuestion(txtADVEVENT[AD119_Crypte]) then
  begin
    if mBanks[pObj.v].take then                //pas de chance vide
    begin
       processEnterInfo(txtADVEVENT[AD120_Crypte_Visited]);
       mBanks[pObj.v].Visited[PL]:=true;
    end
    else
    begin                                      // combat
      cmd_BA_InitBattle(mHeros[HE].oid,pObj.id);
      NewAction:=ACT04_Battle; //TSnBattleField.Create;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB85_Shipwreck;
begin
  if processQuestion(txtADVEVENT[AD122_Shipwreck_QBattle]) then
  begin
    if mBanks[pObj.v].take then                //pas de chance vide
    begin
       processEnterInfo(txtADVEVENT[AD120_Crypte_Visited]);
       mBanks[pObj.v].Visited[PL]:=true;
    end
    else
    begin                                      // combat
      cmd_BA_InitBattle(mHeros[HE].oid,pObj.id);
      NewAction:=ACT04_Battle; //TSnBattleField.Create;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB86_Survivor;
begin
  processDialog(format(txtADVEVENT[AD125_Survivor_Art],[iArt[pObj.v].name]),dsArt,pObj.v);
  Cmd_He_SetART(HE,pObj.v);    // equip art
  NewAction:=ACT02_Delete;;
  //AD126_Survivor_NoSlot=126;
end;
{----------------------------------------------------------------------------}
procedure EnterOB87_ShipYeard;
var
  i,j: integer;
  p : TPos;
  OB: integer;
  found: boolean;
const   vv: array  [-1..1] of integer = (0,-1,1) ;
begin
  found:=false;
  mDialog.mes:='{Question} Need a boat';
  begin
    mDialog.res:=-1;
    TSnBuyShip.Create;
    repeat
      Application.HandleMessage
    until mDialog.res <> -1;
    if mDialog.res >0 then
    begin
    for i:=-1 to 1 do
    begin
      j:=vv[i];
      p.x:=x+2;
      p.y:=y+j;
      p.l:=l;
      if mTiles[p.x,p.y,p.l].TR.t=TR08_Water then
      begin
        found:=true;
        break;
      end;

      p.x:=x-2;
      p.y:=y+j;
      p.l:=l;
      if mTiles[p.x,p.y,p.l].TR.t=TR08_Water then
      begin
        found:=true;
        break;
      end;

      p.x:=x+j;
      p.y:=y-1;
      p.l:=l;
      if mTiles[p.x,p.y,p.l].TR.t=TR08_Water then
      begin
        found:=true;
        break;
      end;
      p.x:=x+j;
      p.y:=y+1;
      p.l:=l;
      if mTiles[p.x,p.y,p.l].TR.t=TR08_Water then
      begin
        found:=true;
        break;
      end;
    end;
    if found=false then exit;

    OB:=nObjs;
    mObj.id:=OB;
    mObj.t:=OB08_Boat;
    mObj.u:=0;
    mObj.v:=0;
    mTiles[p.x,p.y,p.l].P1:=2;
    mTiles[p.x,p.y,p.l].obX.t:=mObj.t;
    mTiles[p.x,p.y,p.l].obX.u:=mObj.u;
    mTiles[p.x,p.y,p.l].obX.oid:=mObj.id;
    mObjs[OB]:=mObj;
    inc(nObjs);
    Cmd_PL_AddRes(PL,6,-1000);
    Cmd_PL_AddRes(PL,0,-10);
    p.x:=p.x+1;
    SnGame.AddSprite('AVXMyboat',p);
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB88_ShrineofMagicIncantation;
begin
  if mHeros[HE].hasBook then
  begin
    if mHeros[HE].Spels[pObj.v] then
    begin
      processEnterInfo(txtADVEVENT[AD174_Shrine_SpellAlreadyknown]);
    end
    else
    begin
      processEnterInfo(txtADVEVENT[AD127_ShrineofMagicIncantation]);
      mHeros[HE].Spels[pObj.v]:=true;
    end;
  end
  else
    processEnterInfo(txtADVEVENT[AD131_Spell_NoBook]);

end;
{----------------------------------------------------------------------------}
procedure EnterOB89_ShrineofMagicGesture;
begin
  if mHeros[HE].hasBook then
  begin
    if mHeros[HE].Spels[pObj.v] then
    begin
      processEnterInfo(txtADVEVENT[AD174_Shrine_SpellAlreadyknown]);
    end
    else
    begin
      processEnterInfo(txtADVEVENT[AD128_ShrineofMagicGesture]);
      mHeros[HE].Spels[pObj.v]:=true;
    end;
  end
  else
  begin
    processEnterInfo(txtADVEVENT[AD131_Spell_NoBook]);
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB90_ShrineofMagicThought;
begin
  if mHeros[HE].hasBook then
  begin
    if mHeros[HE].Spels[pObj.v] then
    begin
      processEnterInfo(txtADVEVENT[AD174_Shrine_SpellAlreadyknown]);
    end
    else
    begin
      // TODO control skill level wisdom  AD130_Spell_Nolevel=130;
      processEnterInfo(txtADVEVENT[AD129_ShrineofMagicThought]);
      mHeros[HE].Spels[pObj.v]:=true;
    end;
  end
  else
  begin
    processEnterInfo(txtADVEVENT[AD131_Spell_NoBook]);
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB91_Sign;
begin
  processEnterInfo(mSigns[pObj.v]);

end;
{----------------------------------------------------------------------------}
procedure EnterOB92_Sirens;
begin
  processEnterInfo(txtADVEVENT[AD132_Sirens_Bonus]);
  //AD133_Sirens_NoBonus=133;
  //AD134_Sirens_Noeffect=134;];
end;
{----------------------------------------------------------------------------}
procedure EnterOB93_Scroll;
begin
  processDialog(format(txtADVEVENT[AD135_Scroll],[iSPEL[pObj.v].name]),dsArt,7);
  Cmd_He_SetART(HE,7);    //equip art
  NewAction:=ACT02_Delete;;
end;
{----------------------------------------------------------------------------}
procedure EnterOB94_Stables;
begin;
  if mHeros[HE].VisStable=true then
  begin
    processEnterInfo(txtADVEVENT[AD136_Stable_Visited]);
  end
  else
  begin
    processEnterInfo(txtADVEVENT[AD137_Stable_Bonus]);
    mHeros[HE].PSKA.mov:= mHeros[HE].PSKA.mov+400;
  end;
  mHeros[HE].VisStable:=true;
  {AD138_Stable_Bonus1
   AD139_Stable_Bonus2}
end;
{----------------------------------------------------------------------------}
procedure EnterOB95_Tavern;
begin
  TSnBuyHero.Create(-pObj.id);
end;
{----------------------------------------------------------------------------}
procedure EnterOB96_Temple;
begin
  if mHeros[HE].VisTemple=true then
  begin
    processEnterInfo(txtADVEVENT[AD141_Temple_Visited]);
  end
  else
  begin
    processEnterInfo(txtADVEVENT[AD140_Temple_Bonus]);
  end;
  mHeros[HE].VisTemple:=true;
end;
{----------------------------------------------------------------------------}
procedure EnterOB97_DenofThieves;
begin
  TSnPlayers.create;
end;
{----------------------------------------------------------------------------}
procedure EnterOB98_City;
var
  i,j,
  CT: integer;
begin
  CT:=pObj.v;
  with mHeros[HE] do
  begin
    if pObj.pid <> pid   //TODO friendly City
    then
    begin
      // check defense ?
      if cmd_CT_hasdefense(CT) then
      begin
      cmd_BA_InitBattle(mHeros[HE].oid,pObj.id);
      NewAction:=ACT04_Battle;
      exit;
      end;
      if pObj.pid > -1 then
      begin
        for i:=0 to mPlayers[pobj.pid].nCity-1 do
          if  mPlayers[pObj.pid].LstCity[i]=CT then break;
        for j:=i to mPlayers[pObj.pid].nCity-1 do
          mPlayers[pObj.pid].LstCity[j]:=mPlayers[pObj.pid].LstCity[j+1];
        dec(mPlayers[pObj.pid].nCity);
        if mPlayers[pObj.pid].nCity=0 then
        begin
          mPlayers[pObj.pid].isAlive:=false;
          dec(mData.nPlr);
        end;
      end;
      mPlayers[pid].LstCity[mPlayers[pid].nCity]:=CT;
      inc(mPlayers[pid].nCity);
      pObj.pid:=pid;
      mCitys[CT].pid:=pid;
    end;
    Cmd_HE_VisitCity(HE,CT);
    if mPlayers[pid].isCPU = false
    then NewAction:=ACT06_Town;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB99_TradingPost;
begin
  TSnBuyRes.Create;
end;
{----------------------------------------------------------------------------}
procedure EnterOB100_LearningStone;
begin
  if mHeros[HE].VisObj[0,pObj.v] then
  begin
    processEnterInfo(txtADVEVENT[AD144_KnowStone_Visited]);
  end
  else
  begin
    processdialog(txtADVEVENT[AD143_KnowStone_Bonus],dsExperience,1000);
    mHeros[HE].VisObj[0,pObj.v]:=true;
    cmd_HE_AddExp(HE,1000);
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB101_TreasureChest;
begin
  if mChests[pObj.v].t=1
  then
  begin
    processDialog(format(txtADVEVENT[AD145_Chest_Art],[iART[mChests[pObj.v].a].name]),dsArt,mChests[pObj.v].a);
    Cmd_He_SetART(HE,mChests[pObj.v].a);
  end
  else
  begin
    processDialog(txtADVEVENT[AD146_Chest_QExp],dsMoneyExp,mChests[pObj.v].b);
    if mDialog.res=1
    then
      cmd_PL_AddRes(PL,6,500* mChests[pObj.v].b)
    else
      cmd_HE_AddExp(HE,500 * mChests[pObj.v].b -500);
  end;
  NewAction:=ACT02_Delete;;
end;
{----------------------------------------------------------------------------}
procedure EnterOB102_TreeofKnowledge;
begin
  if mHeros[HE].VisObj[5,pObj.v] then
  begin
    processEnterInfo(txtADVEVENT[AD147_KnowTree_Visited] );
  end
  else
  begin
    case pObj.u of
      0 : //free
      begin
        processDialog(txtADVEVENT[AD148_KnowTree_Bonus] ,dsExperience,1000);
        mHeros[HE].VisObj[5,pObj.v]:=true;
        cmd_HE_AddExp(HE,1000);
      end;
      1 : //2000 or
      if mPlayers[PL].Res[6] >= 2000 then
      begin
        processDialog(txtADVEVENT[AD149_KnowTree_NeedMoney] ,dsExperience,1000);
        mHeros[HE].VisObj[5,pObj.v]:=true;
        mPlayers[PL].Res[6]:=mPlayers[PL].Res[6]-2000;
        cmd_HE_AddExp(HE,1000);
      end
      else
        processEnterInfo(txtADVEVENT[AD150_KnowTree_NoMoney] );
      2 : //10 gems
      if mPlayers[PL].Res[5] >= 10 then
      begin
        processDialog(txtADVEVENT[AD151_KnowTree_NeedGem] ,dsExperience,1000);
        mHeros[HE].VisObj[5,pObj.v]:=true;
        mPlayers[PL].Res[5]:=mPlayers[PL].Res[5]-10;
        cmd_HE_AddExp(HE,1000);
      end
      else
       processEnterInfo(txtADVEVENT[AD152_KnowTree_NoGem] );
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB103_Gate;
var
  oid: integer;
begin
  NewAction:=ACT07_TelePort;
  oid:=Cmd_OB_FindGate(mHeros[HE].pos);
  with mObjs[oid].pos do
  begin
    mHeros[HE].tgt.x:=x-1;
    mHeros[HE].tgt.y:=y;
    mHeros[HE].tgt.l:=l;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB105_Wagon;
begin
  case pOBJ.v of
    -1:
      begin
        processEnterInfo(txtADVEVENT[AD156_Wagon_Visited]);
      end;
    0..199:
      begin
        processEnterInfo(txtADVEVENT[AD154_Wagon_Bonus1]);
        pObj.v:=-1;
      end;
    200..210:
      begin
        processEnterInfo(txtADVEVENT[AD155_Wagon_Bonus2]);
        //mPlayers[PL].Res[6]:=mPlayers[PL].Res[6]+1000; res
        pObj.v:=-1;
      end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB106_WarMachineFactory;
begin
  if processQuestion(txtADVEVENT[AD157_WarMachine_QBuy]) then
  begin
    //TODO not a msg dlg but specific buy of each war machine
    mDialog.res :=-1;
    TSnBuyAmmo.Create;
    repeat
      Application.HandleMessage
    until mDialog.res <> -1;
    if mDialog.res > 0 then
    begin
      Cmd_HE_SetART(HE,AR004_Ballista,13);
      Cmd_HE_SetART(HE,AR005_AmmoCart,14);
      Cmd_HE_SetART(HE,AR006_FirstAidTent,15);
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB107_SchoolofWar;
begin
  if mHeros[HE].VisObj[9,pObj.v]
  then
  begin
    processEnterInfo(txtADVEVENT[AD159_Schoolwar_Visited]);
  end
  else
  begin
    if  mPlayers[PL].res[6] < 1000 then
    begin
      processEnterInfo(txtADVEVENT[AD160_SchoolWar_NoMoney]);
    end
    else
    begin
      processEnterInfo(txtADVEVENT[AD158_SchollWar_Bonus]);
      mHeros[HE].VisObj[9,pObj.v]:=true;
      cmd_HE_AddPSK(HE,1);
      cmd_PL_AddRes(PL,6,-1000);
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB108_WarriorsTomb;
var
  AR: integer;
begin
  if processQuestion(txtADVEVENT[AD161_Tomb_Q]) then
  begin
    AR:=pobj.v;
    if AR=-1
    then
    begin
      processEnterInfo(txtADVEVENT[AD163_Tomb_Moral]);
    end
    else
    begin
      processDialog(format(txtADVEVENT[AD162_Tomb_Bonus],[iART[AR].name]),dsArt,AR);
      //processEnterInfo(format(txtADVEVENT[AD162_Tomb_Bonus],[iART[pObj.v].name]));
      cmd_HE_setART(HE,pObj.v);
      pobj.v:=-1 ;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB109_WaterWheel;
begin
  if pObj.v=-1 then
  begin
    processEnterInfo(txtADVEVENT[AD165_WaterMill_Visited]);
  end
  else
  begin
    processEnterInfo(txtADVEVENT[AD164_WaterMill_Bonus]);
    mPlayers[PL].Res[6]:=mPlayers[PL].Res[6]+1000;
    pObj.v:=-1;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB111_WaterWhirl;
var
  oid: integer;
begin
  NewAction:=ACT07_TelePort;
  oid:=Cmd_OB_Find(OB111_WaterWhirl,0);
  if oid = pObj.id then oid:=Cmd_OB_Find(OB111_WaterWhirl,oid+1);
  with mObjs[oid].pos do
  begin
    mHeros[HE].tgt.x:=x;
    mHeros[HE].tgt.y:=y;
    mHeros[HE].tgt.l:=l;
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB112_WindMill;
var
  rId: integer;
begin
  rId:=pObj.v;
  if rid=-1 then
  begin
    processEnterInfo(txtADVEVENT[AD169_WindMill_Visited]);
  end
  else
  begin
    processDialog(txtADVEVENT[AD170_WindMill_Bonus],dsRes0+rId, 5);
    mPlayers[mPL].Res[rid]:=mPlayers[PL].res[rid] + 5;
    pObj.v:=-1
  end;
end;
{----------------------------------------------------------------------------}
procedure EnterOB113_WitchHut;
var
  ssk: integer;
begin
  ssk:=pObj.v;
  if mHeros[HE].SSK[ssk] > 0  then
  begin
    processEnterInfo(txtADVEVENT[AD172_WitchHut_HasSkill]);
  end
  else
    //processEnterInfo(txtADVEVENT[AD173_WitchHut_MaxSkil]);
  begin
    processEnterInfo(format(txtADVEVENT[AD171_WitchHut_Bonus],[iSSK[ssk].name]));
    Cmd_HE_AddSSK(HE,ssk);
  end;
end;

{----------------------------------------------------------------------------}
function Cmd_HE_EnterObj(value,ax,ay,al: integer):integer;
begin
  HE:=value;
  PL:=mHeros[HE].pid;
  x:=ax;
  y:=ay;
  l:=al;
  mDialog.mes:='Enter OBJECT';
  mDialog.t:=DsNone;
  NewAction:=ACT03_Enter;
  obX:=mTiles[x,y,l].obX;
  pObj:=@mObjs[obX.oid];
  LogP.InsertStr('EnterObjet', TxtObject[pObj.t]);
  case pObj.t of
    OB04_Arena:            EnterOB04_Arena;
    OB05_Artifact:         EnterOB05_Artifact;
    OB06_Pandora:          EnterOB06_Pandora;
    OB08_Boat :            EnterOB08_Boat;
    OB09_BorderGuard:      EnterOB09_BorderGuard;
    OB10_KeyMaster:        EnterOB10_KeyMaster;
    OB11_Buoy:             EnterOB11_Buoy;
    OB12_Fire:             EnterOB12_Fire;
    OB13_Cartographer:     EnterOB13_Cartographer;
    OB14_SwanPond:         EnterOB14_SwanPond;
    OB15_CoverofDarkness:  EnterOB15_CoverofDarkness;
    OB16_CreatureBank:     EnterOB16_CreatureBank ;
    OB17_Generator:        EnterOB17_Generator;
    OB22_Corpse:           EnterOB22_Corpse;
    OB23_MarlettoTower:    EnterOB23_MarlettoTower;
    OB24_DerelictShip:     EnterOB24_DerelictShip;
    OB25_DragonUtopia:     EnterOB25_DragonUtopia;
    OB26_Event:            EnterOB26_Event;
    OB27_EyeoftheMagi:     EnterOB27_EyeoftheMagi;
    OB28_Faery:            EnterOB28_Faery;
    OB29_FlotSam:          EnterOB29_FlotSam;
    OB30_FountainofFortune:EnterOB30_FountainofFortune;
    OB31_FountainofYouth : EnterOB31_FountainofYouth;
    OB32_Garden:           EnterOB32_Garden;
    OB33_Garnison:         EnterOB33_Garnison;
    OB34_Hero:             EnterOB34_Hero;
    OB35_HillFort:         EnterOB35_HillFort;
    //36 Grail
    OB37_HutoftheMagi:     EnterOB37_HutoftheMagi;
    OB38_IdolofFortune:    EnterOB38_IdolofFortune;
    OB39_LeanTo:           EnterOB39_LeanTo;
    //40 <blank>
    OB41_Library:          EnterOB41_Library;
    OB42_LightHouse:       EnterOB42_LightHouse;
    OB43_Monolith_entrance:EnterOB43_Monolith_entrance;
    OB44_Monolith_exit:    EnterOB44_Monolith_exit;
    OB45_Monolith_2way:    EnterOB45_Monolith_2way;
    //46 Magic Plains
    OB47_SchoolofMagic:    EnterOB47_SchoolofMagic;
    OB48_MagicSpring:      EnterOB48_MagicSpring;
    OB49_MagicWell:        EnterOB49_MagicWell;
    //50 <blank>
    OB51_MercenaryCamp :   EnterOB51_MercenaryCamp;
    OB52_Mermaid:          EnterOB52_Mermaid;
    OB53_Mine:             EnterOB53_mine;
    OB54_Monster:          EnterOB54_Monster;
    OB55_MysticalGarden:   EnterOB55_MysticalGarden;
    OB56_Oasis:            EnterOB56_Oasis;
    OB57_Obelisk:          EnterOB57_Obelisk;
    OB58_Tree :            EnterOB58_Tree;
    OB59_Bottle :          EnterOB59_Bottle;
    OB60_PillarofFire:     EnterOB60_PillarofFire;
    OB61_StarAxis:         EnterOB61_StarAxis;
    OB62_Prison:           EnterOB62_Prison;
    OB63_Pyramid:          EnterOB63_Pyramid;
    OB64_RallyFlag:        EnterOB64_RallyFlag;
    //65 Random Artifact 70 Random Hero 71 Random Monster 76 Random Resource
    OB78_RefugeeCamp:      EnterOB78_RefugeeCamp;
    OB79_Res:              EnterOB79_Res;
    OB80_Sanctuary:        EnterOB80_Sanctuary;
    OB81_Schoolar:         EnterOB81_Schoolar;
    OB82_Seechest:         EnterOB82_Seechest;
    OB83_Seer:             EnterOB83_Seer;
    OB84_Crypt:            EnterOB84_Crypt;
    OB85_Shipwreck:        EnterOB85_Shipwreck;
    OB86_Survivor:         EnterOB86_Survivor;
    OB87_ShipYeard:        EnterOB87_ShipYeard;
    OB88_ShrineofMagicIncantation: EnterOB88_ShrineofMagicIncantation;
    OB89_ShrineofMagicGesture: EnterOB89_ShrineofMagicGesture;
    OB90_ShrineofMagicThought: EnterOB90_ShrineofMagicThought;
    OB91_Sign:             EnterOB91_Sign;
    OB92_Sirens:           EnterOB92_Sirens;
    OB93_Scroll:           EnterOB93_Scroll;
    OB94_Stables:          EnterOB94_Stables;
    OB95_Tavern:           EnterOB95_Tavern;
    OB96_Temple:           EnterOB96_Temple;
    OB97_DenofThieves:     EnterOB97_DenofThieves;
    OB98_City:             EnterOB98_City;
    OB99_TradingPost:      EnterOB99_TradingPost;
    OB100_LearningStone:   EnterOB100_LearningStone;
    OB101_TreasureChest:   EnterOB101_TreasureChest;
    OB102_TreeofKnowledge: EnterOB102_TreeofKnowledge;
    OB103_Gate:            EnterOB103_Gate;
    OB105_Wagon:           EnterOB105_Wagon;
    OB106_WarMachineFactory:EnterOB106_WarMachineFactory;
    OB107_SchoolofWar:     EnterOB107_SchoolofWar;
    OB108_WarriorsTomb:    EnterOB108_WarriorsTomb ;
    OB109_WaterWheel:      EnterOB109_WaterWheel;
    OB111_WaterWhirl:      EnterOB111_WaterWhirl;
    OB112_WindMill:        EnterOB112_WindMill;
    OB113_WitchHut:        EnterOB113_WitchHut;
    OB215_BorderGate1:     EnterOB09_BorderGuard;
  end;
  result:=NewAction;
end;


{----------------------------------------------------------------------------}
function Cmd_HE_CanEnterObj(value,ax,ay,al: integer): boolean;
var
  CT: integer;
begin
  result:=true;
  HE:=value;
  PL:=mHeros[HE].pid;
  x:=ax;
  y:=ay;
  l:=al;
  obX:=mTiles[x,y,l].obX;
  pObj:=@mObjs[obX.oid];
  LogP.InsertStr('PreEnterObjet', TxtObject[pObj.t]);
  case pObj.t of
    //OB04_Arena:            EnterOB04_Arena;
    OB05_Artifact:         result:=false;
    OB06_Pandora:          result:=false;
    //OB08_Boat :            EnterOB08_Boat;
    //OB09_BorderGuard:      EnterOB09_BorderGuard;
    //OB10_KeyMaster:        EnterOB10_KeyMaster;
    //OB11_Buoy:             EnterOB11_Buoy;
    //OB12_Fire:             EnterOB12_Fire;
    //OB13_Cartographer:     EnterOB13_Cartographer;
    //OB14_SwanPond:         EnterOB14_SwanPond;
    //OB15_CoverofDarkness:  EnterOB15_CoverofDarkness;
    //OB16_CreatureBank:     result:=false;
    //OB17_Generator:        EnterOB17_Generator;
    //OB22_Corpse:           EnterOB22_Corpse;
    //OB23_MarlettoTower:    EnterOB23_MarlettoTower;
    //OB24_DerelictShip:     EnterOB24_DerelictShip;
    //OB25_DragonUtopia:     EnterOB25_DragonUtopia;
    //OB26_Event:            EnterOB26_Event;
    //OB27_EyeoftheMagi:     EnterOB27_EyeoftheMagi;
    //OB28_Faery:            EnterOB28_Faery;
    //OB29_FlotSam:          EnterOB29_FlotSam;
    //OB30_FountainofFortune:EnterOB30_FountainofFortune;
    //OB31_FountainofYouth : EnterOB31_FountainofYouth;
    //OB32_Garden:           EnterOB32_Garden;
    //OB33_Garnison:         EnterOB33_Garnison;
    OB34_Hero:             result:=false;
    //OB35_HillFort:         EnterOB35_HillFort;
    //36 Grail
    //OB37_HutoftheMagi:     EnterOB37_HutoftheMagi;
    //OB38_IdolofFortune:    EnterOB38_IdolofFortune;
    //OB39_LeanTo:           EnterOB39_LeanTo;
    //40 <blank>
    //OB41_Library:          EnterOB41_Library;
    //OB42_LightHouse:       EnterOB42_LightHouse;
    //OB43_Monolith_entrance:EnterOB43_Monolith_entrance;
    //OB44_Monolith_exit:    EnterOB44_Monolith_exit;
    //OB45_Monolith_2way:    EnterOB45_Monolith_2way;
    //46 Magic Plains
    //OB47_SchoolofMagic:    EnterOB47_SchoolofMagic;
    //OB48_MagicSpring:      EnterOB48_MagicSpring;
    //OB49_MagicWell:        EnterOB49_MagicWell;
    //50 <blank>
    //OB51_MercenaryCamp :   EnterOB51_MercenaryCamp;
    //OB52_Mermaid:          EnterOB52_Mermaid;
    //OB53_Mine:             result:=false;
    OB54_Monster:          result:=false;
    //OB55_MysticalGarden:   EnterOB55_MysticalGarden;
    //OB56_Oasis:            EnterOB56_Oasis;
    //OB57_Obelisk:          EnterOB57_Obelisk;
    //OB58_Tree :            EnterOB58_Tree;
    OB59_Bottle :          result:=false;
    //OB60_PillarofFire:     EnterOB60_PillarofFire;
    //OB61_StarAxis:         EnterOB61_StarAxis;
    OB62_Prison:           result:=false;
    //OB63_Pyramid:          EnterOB63_Pyramid;
    //OB64_RallyFlag:        EnterOB64_RallyFlag;
    //65 Random Artifact 70 Random Hero 71 Random Monster 76 Random Resource
    //OB78_RefugeeCamp:      EnterOB78_RefugeeCamp;
    OB79_Res:              result:=false;
    //OB80_Sanctuary:        EnterOB80_Sanctuary;
    //OB81_Schoolar:         EnterOB81_Schoolar;
    OB82_Seechest:         result:=false;
    //OB83_Seer:             EnterOB83_Seer;
    //OB84_Crypt:            EnterOB84_Crypt;
    //OB85_Shipwreck:        EnterOB85_Shipwreck;
    OB86_Survivor:         result:=false;
    //OB87_ShipYeard:        EnterOB87_ShipYeard;
    //OB88_ShrineofMagicIncantation: EnterOB88_ShrineofMagicIncantation;
    //OB89_ShrineofMagicGesture: EnterOB89_ShrineofMagicGesture;
    //OB90_ShrineofMagicThought: EnterOB90_ShrineofMagicThought;
    //OB91_Sign:             EnterOB91_Sign;
    //OB92_Sirens:           EnterOB92_Sirens;
    OB93_Scroll:           result:=false;
    //OB94_Stables:          EnterOB94_Stables;
    //OB95_Tavern:           EnterOB95_Tavern;
    //OB96_Temple:           EnterOB96_Temple;
    //OB97_DenofThieves:     EnterOB97_DenofThieves;
    OB98_City:             begin
      CT:=pObj.v;
      if mHeros[HE].pid <> pObj.pid   //TODO not the same team
      then
        if cmd_CT_hasdefense(CT)
        then  result:=false;
    end;
    //OB99_TradingPost:      EnterOB99_TradingPost;
    //OB100_LearningStone:   EnterOB100_LearningStone;
    OB101_TreasureChest:   result:=false;
    //OB102_TreeofKnowledge: EnterOB102_TreeofKnowledge;
    //OB103_Gate:            EnterOB103_Gate;
    //OB105_Wagon:           EnterOB105_Wagon;
    //OB106_WarMachineFactory:EnterOB106_WarMachineFactory;
    //OB107_SchoolofWar:     EnterOB107_SchoolofWar;
    //OB108_WarriorsTomb:    EnterOB108_WarriorsTomb ;
    //OB109_WaterWheel:      EnterOB109_WaterWheel;
    //OB111_WaterWhirl:      EnterOB111_WaterWhirl;
    //OB112_WindMill:        EnterOB112_WindMill;
    //OB113_WitchHut:        EnterOB113_WitchHut;
    //OB215_BorderGate1:     EnterOB09_BorderGuard;
  end;
end;
end.
