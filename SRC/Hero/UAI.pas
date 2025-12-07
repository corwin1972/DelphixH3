unit UAI;

interface

Uses
  SysUtils, Forms, Math, UType;

  function  Cmd_Map_CheckFog(PL, x,y,l: integer): boolean;
  function  Cmd_HE_CheckVisited(HE, t, id: integer) : boolean;
  function  Cmd_Map_CheckOwnerTown(PL: integer;p: pTMapOBJ): boolean;
  function  Cmd_Map_CheckFight(HE: integer;p: pTMapOBJ): boolean;
  function  Cmd_Map_CheckSuicide(HE: integer;p: pTMapOBJ): boolean;
  function  Cmd_Map_CheckBonus(HE: integer;p: pTMapOBJ): boolean;
  procedure Cmd_AI_PlayTurn(PL: integer);
  procedure Cmd_AI_ImproveCity(PL: integer);
  procedure Cmd_AI_Recruit(HE,CT: integer);
  function  Cmd_AI_SelectHero(PL: integer): integer;
  procedure Cmd_AI_MoveHero(HE: integer);
  function  Cmd_AI_FindOBTarget(HE, OBStyle, Range: integer)  : boolean;
  function  Cmd_AI_FindTarget(HE: integer): boolean;

  const
    dx :array [0..3] of integer = (1,0,-1,0);
    dy :array [0..3] of integer = (0,1,0,-1);
    OB_None=-1;
    OB_Bonus=1;
    OB_Attak=2;
    OB_Town=3;
    OB_Suicide=4;
  var
    tx,ty: integer;

implementation

Uses
  UCT, UEnter, UFile, UMap, UPathRect, UBattle, UHE, UPL,
  USnDialog, USnGame, USnBuyCrea, USnInfoCrea, USnInfoPlayer, USnInfoRes, USnLevelUp;

{----------------------------------------------------------------------------}
function Cmd_Map_CheckFog(PL, x,y,l: integer): boolean;
var
  i,j: integer;
begin
  result:=false;
  for i:=x-7 to x+7  do
  for j:=y-7 to y+7  do
    if  Cmd_Map_Inside(i,j) then
    if not(mTiles[i,j,l].vis[PL]) then
    begin
      result:=true;
      exit;
    end;
end;
{----------------------------------------------------------------------------}
function Cmd_HE_checkVisited(HE, t, id: integer) : boolean;
begin
  result:=mHeros[HE].VisObj[t,id];
end;
{----------------------------------------------------------------------------}
function Cmd_Map_CheckOwnerTown(PL: integer;p: pTMapOBJ): boolean;
begin
  result:=(p.t=OB98_City) and (p.pid=PL);
end;
{----------------------------------------------------------------------------}
function Cmd_Map_CheckFight(HE: integer;p: pTMapOBJ): boolean;
var
  PL: integer;
begin
  result:=false;
  PL:=mHeros[HE].pid;
  case p.t of
    OB34_Hero:      result:=not(Cmd_PL_SameTeam(p.pid,PL));
    OB54_Monster:   result:=(cmd_BA_VirtualBattle(HE,p.id) > 0);
    OB98_City:      result:=not(Cmd_PL_SameTeam(p.pid,PL));
  end;
end;
{----------------------------------------------------------------------------}
function Cmd_Map_CheckSuicide(HE: integer;p: pTMapOBJ): boolean;
var
  PL: integer;
begin
  result:=false;
  PL:=mHeros[HE].pid;
  case p.t of
    OB34_Hero:      result:=not(Cmd_PL_SameTeam(p.pid,PL));
    OB54_Monster:   result:=true;
    OB98_City:      result:=not(Cmd_PL_SameTeam(p.pid,PL));
  end;
end;
{----------------------------------------------------------------------------}
function Cmd_Map_CheckBonus(HE: integer;p: pTMapOBJ): boolean;
var
  x,y,l : integer;
  PL: integer;
begin
  x:=p.pos.x;
  y:=p.pos.y;
  l:=p.pos.l;
  PL:=mHeros[HE].pid;
  result:=false;

  case p.t of
    OB04_Arena:
      result:=not(Cmd_HE_checkVisited(HE, 7, p.v));
    OB05_Artifact:
      result:=true;
    OB06_Pandora:
      result:=true;
    //OB08_Boat:
    //OB09_BorderGuard:
    //OB10_KeyMaster:
    OB11_Buoy:
      result:=true;
    OB12_Fire:
      result:=true;
    //OB13_Cartographer:
    //OB14_SwanPond:
    //OB15_CoverofDarkness:
    //OB16_CreatureBank:
    OB17_Generator:
      result:=(p.v<>0) or (p.pid<>PL);
    //OB22_Corpse:
    OB23_MarlettoTower:
      result:=not(Cmd_HE_checkVisited(HE, 1, p.v));
    //OB24_DerelictShip:
    //OB25_DragonUtopia:
    //OB26_Event:
    //OB27_EyeoftheMagi:
    //OB28_Faery:
    OB29_FlotSam:
      result:=true;
    //OB30_FountainofFortune:
    //OB31_FountainofYouth :
    OB32_Garden:
      result:=not(Cmd_HE_checkVisited(HE, 2, p.v));
    OB33_Garnison:
      result:=true;
    //OB34_Hero:
    //OB35_HillFort:
    //OB36 Grail
    //OB37_HutoftheMagi:
    //OB38_IdolofFortune:
    OB39_LeanTo:
      result:=(p.v>-1);
    //40 <blank>
    OB41_Library:
      result:=not(Cmd_HE_checkVisited(HE, 6, p.v));
    //OB42_LightHouse:
    //OB43_Monolith_entrance:
    //OB44_Monolith_exit:
    OB45_Monolith_2way:
      //prevent to enter monolith 2 times in same turn
      if not(mHeros[HE].VisMono) then result:=true;
    //46 Magic Plains
    OB47_SchoolofMagic:
      result:=not(Cmd_HE_checkVisited(HE, 8, p.v));
    //OB48_MagicSpring:
    OB49_MagicWell:
       result:=not(mHeros[HE].PSKA.ptm=mHeros[HE].PSKB.ptm);
     //50 <blank>
    OB51_MercenaryCamp :
      result:=not(Cmd_HE_checkVisited(HE, 3, p.v));
    //OB52_Mermaid:
    OB53_Mine:
      result:=not(p.pid=PL);
    //OB54_Monster
    OB55_MysticalGarden:
      result:=(p.v>-1);
    //OB56_Oasis:
    //OB57_Obelisk:
    OB58_Tree:
      result:=Cmd_Map_CheckFog(PL, x,y,l);
    OB59_Bottle:
      result:=true;
    OB60_PillarofFire:
      result:=Cmd_Map_CheckFog(PL, x,y,l);
    OB61_StarAxis:
      result:=not(Cmd_HE_checkVisited(HE, 4, p.v));
    OB62_Prison:
      result:=true;
    //OB63_Pyramid:
    //OB64_RallyFlag:
    //65 Random Artifact 70 Random Hero 71 Random Monster 76 Random Resource
    //OB78_RefugeeCamp:
    OB79_Res:
      result:=true;
    //OB80_Sanctuary:
    OB81_Schoolar:
      result:=true;
    //OB82_Seechest:
    //OB83_Seer:
    //OB84_Crypt:
    //OB85_Shipwreck:
    OB86_Survivor:
      result:=true;
    //OB87_ShipYeard:
    //OB88_ShrineofMagicIncantation:
    //OB89_ShrineofMagicGesture:
    //OB90_ShrineofMagicThought:
    //OB91_Sign:
    //OB92_Sirens:
    OB93_Scroll:
      result:=true;
    //OB94_Stables:
    //OB95_Tavern:
    //OB96_Temple:
    //OB97_DenofThieves:
    //OB98_City:
    //OB99_TradingPost:
    OB100_LearningStone:
      result:=not(Cmd_HE_checkVisited(HE, 0, p.v));
   OB101_TreasureChest:
      result:=true;
    OB102_TreeofKnowledge:
      result:=not(Cmd_HE_checkVisited(HE, 5, p.v));
    //OB103_Gate
    OB105_Wagon:
      result:=(p.v>-1);
    //OB106_WarMachineFactory
    OB107_SchoolofWar:
      result:=not(Cmd_HE_checkVisited(HE, 9, p.v));
    //OB108_WarriorsTomb:
    OB109_WaterWheel:
      result:=(p.v>-1);
    OB112_WindMill:
      result:=(p.v>-1);
    //OB113_WitchHut:
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_AI_Recruit(HE,CT: integer);
var
  i,j,t,n : integer;
begin
  // first recruit all crea
  for i:=0 to MAX_ARMY do
  begin
    t:=mCitys[CT].prodArmys[i].t;
    if t > -1 then
    begin
      n:=Min(mCitys[CT].dispArmys[i].n, mPlayers[mPL].res[6] div iCrea[t].cost);
      if n=0 then continue;
      LogP.InsertStr('AI_Recruit', format('%s, %d , %s', [mHeros[HE].name,n,iCrea[t].name]));
      Cmd_CT_AddCrea(CT,t,n);
    end;
  end;

  // add Crea to hero
  for i:=0 to MAX_ARMY do
  begin
    t:=mCitys[CT].GarArmys[i].t;
    if t > -1 then
    begin
      n:=mCitys[CT].GarArmys[i].n;
      for j:=0 to MAX_ARMY   do
      begin
        if t=mHeros[HE].Armys[j].t then
        begin
          mHeros[HE].Armys[j].n:=mHeros[HE].Armys[j].n+n;
          mCitys[CT].GarArmys[i].n:=0;
          mCitys[CT].GarArmys[i].t:=-1;
          break
        end;
      end;
      if j >  MAX_ARMY then
      for j:=0 to MAX_ARMY   do
      begin
        if mHeros[HE].Armys[j].t=-1 then
        begin
          mHeros[HE].Armys[j].t:=t;
          mHeros[HE].Armys[j].n:=n;
          mCitys[CT].GarArmys[i].n:=0;
          mCitys[CT].GarArmys[i].t:=-1;
          break
        end;
      end;
    end;
  end;
  Cmd_HE_CompactArmy(HE);
end;
{----------------------------------------------------------------------------}
procedure Cmd_AI_ImproveCity(PL: integer);
var
    i, Slot, CT, BU: integer;
begin
  BU:=-1;
  i:=random(mPlayers[PL].nCity);
  CT:=mPlayers[PL].LstCity[i];
  // try to build a creature
  for i:=30 to 36 do
  begin
    //BU:=Cmd_CT_ShowWhatToBuild(CT,slot);
    if not(Cmd_CT_ShowBuild(CT,i))
    then
    begin
      BU:=i;
      break;
    end;
  end;
  // if not try to improve city
  if BU = -1
  then
  for slot:=0 to 5 do
  begin
    BU:=Cmd_CT_ShowWhatToBuild(CT,slot);
    if not(Cmd_CT_ShowBuild(CT,BU))
    then  break;
  end;
  // try to Build a improved creature
  if BU = -1
  then
  for i:=37 to 43 do
  begin
    //BU:=Cmd_CT_ShowWhatToBuild(CT,slot);
    if not(Cmd_CT_ShowBuild(CT,BU))
    then
    begin
      BU:=i;
      break;
    end;
  end;

  if BU <> -1 then
  begin
    LogP.InsertStr('AI_Build', 'xxxx');
    cmd_CT_BuyBuild(CT,BU);
  end;
end;
{----------------------------------------------------------------------------}
function Cmd_AI_SelectHero(PL : integer): integer;
var
  i, slot: integer;
  HE, CT: integer;
begin
  HE:=-1;
  //check presence of hero if not try to buy it
  LogP.InsertStr('AI_Search', 'Hero');
  if mPlayers[PL].nHero=0 then
  begin
    i:=random(mPlayers[PL].nCity);
    CT:=mPlayers[PL].Lstcity[i];
    with mCitys[CT] do
    begin
      if Cons[Cons6_Tavern]=false then
        Cmd_CT_BuyCons(CT,Cons6_Tavern);
      slot:=random(2);
      Cmd_CT_BuyHero(CT,slot);
      SnGame.AddHero(mPlayers[mPL].TavHero[slot]);
      mPlayers[mPL].TavHero[slot]:=Cmd_HE_NewHero(t,false);
    end;
  end;

  for i:=0 to mPlayers[PL].nHero -1 do
  begin
    HE:=mPlayers[PL].LstHero[i];
    if mHeros[HE].PSKA.mov > 99 then break else HE:=-1;
  end;

  if HE <> -1 then
  begin
    mPlayers[PL].ActiveHero:=HE;
    for i:=0 to mPlayers[PL].nCity -1 do
    begin
      CT:=mPlayers[PL].LstCity[i];
      if mCitys[CT].VisHero=HE then
        Cmd_AI_Recruit(HE,CT);
    end;
    LogP.InsertStr('AI_SelectHero',format('%s at [%d,%d]', [mHeros[HE].name,mHeros[HE].pos.x,mHeros[HE].pos.y]));
  end;
  result:=HE;
end;
{----------------------------------------------------------------------------}
function Cmd_AI_FindOBTarget(HE, OBStyle, Range: integer)  : boolean;
var
  d,p,dir:integer;
  PL,x0,y0,l: integer;
  x,y:integer;
  a,b,c: integer;
  test1,test2: boolean;
begin
  result:=true;

  case   OBStyle of
    OB_None:  LogP.InsertsTr('AI_Search','FreeTile' + NT + 'at '+ inttostr(range));
    OB_Bonus: LogP.InsertsTr('AI_Search','Bonus' + NT + 'at '+ inttostr(range) );
    OB_Attak: LogP.InsertsTr('AI_Search','Attak' + NT + 'at '+ inttostr(range) );
    OB_Town:  LogP.InsertsTr('AI_Search','Town'+ NT + 'at '+ inttostr(range));
    OB_Suicide: LogP.InsertsTr('AI_Search','Suicide'+ NT + 'at '+ inttostr(range));
    // OB_Meet ?
  end;

  x0:=mHeros[HE].pos.x;
  y0:=mHeros[HE].pos.y;
  l:=mHeros[HE].pos.l;
  PL:=mHeros[HE].pid;

  for d:=1 to range do
  begin
    x:=x0-d ;
    y:=y0-d;
    for p:=0 to 8*d-1 do
    begin
      if Cmd_Map_Inside(x,y) then
      begin
        if OBStyle=OB_None then
        begin
          if (mTiles[x,y,l].Vis[PL] = false)
          then
          begin
            for c:=0 to 3 do
            begin
              a:=x+dx[c];
              b:=y+dy[c];
              if mPath.IsPathTo(a,b) then
              begin
                LogP.InsertStr('Free Tile', format('[%d,%d]',[a,b]));
                tx:=a;
                ty:=b;
                exit;
              end;
            end;
          end;
        end

        else
        begin
          if mTiles[x,y,l].P1=TL_ENTRY then
          begin
            if mPath.IsPathTo(x,y) then
            begin
              tx:=x;
              ty:=y;

              pObj:=@mObjs[mTiles[x,y,l].obX.oid];
              case OBStyle of
                OB_Bonus: if Cmd_Map_CheckBonus(HE,pOBJ) then exit;
                OB_Attak: if Cmd_Map_CheckFight(HE,pOBJ) then exit;
                OB_Town:  if Cmd_Map_CheckOwnerTown(mPL,pOBJ) then exit;
                OB_Suicide: if Cmd_Map_CheckSuicide(HE,pOBJ) then exit;
              end;
            end;
          end;
        end;
      end;
      // next cell
      dir:=p div (2*d);
      x:=x+dx[dir];
      y:=y+dy[dir];
    end;
  end;
  result:=false;
end;
{----------------------------------------------------------------------------}
function Cmd_AI_FindTarget(HE: integer): boolean;
begin
  result:=true;
  LogP.insertstr('AI_FindTarget',mHeros[HE].name );
  mPath.BuildObs(HE);
  if Cmd_AI_FindOBTarget(HE,OB_Bonus, 4)  then exit;
  if Cmd_AI_FindOBTarget(HE,OB_Attak, 8)  then exit;
  if Cmd_AI_FindOBTarget(HE,OB_Bonus, 12) then exit;
  if Cmd_AI_FindOBTarget(HE,OB_None, 18)  then exit;
  if Cmd_AI_FindOBTarget(HE,OB_Town, 24)  then exit;
  if Cmd_AI_FindOBTarget(HE,OB_Suicide, 24)  then exit;
  result:=false;
end;
{----------------------------------------------------------------------------}
procedure Cmd_AI_MoveHero(HE: integer);
var
  Action: ^TAction;
begin
  with mHeros[HE] do
  begin
    //todo : do we need to check mov inf 200
    if PSKA.mov < 200 then
    begin
      PSKA.mov :=0;
      exit;
    end;
    if Cmd_AI_FindTarget(HE) then
    begin
      SnGame.FindHero(HE);
      if (Cmd_HE_CheckMove(HE,tX,ty,pos.l)<>1 )  then
      begin
        LogP.InsertStr('AI_MoveTo', format('[%d %d %d].t=%d' ,[tx,ty,pos.l,mTiles[tx,ty,pos.l].obX.t]));
        mHeros[HE].tgt.x:= tx;
        mHeros[HE].tgt.y:= ty;
        mHeros[HE].tgt.l:= pos.l;
        mPath.FindPath(HE);
        SnGame.AddMoveAction(HE);
        {New(Action);
        Action.ID:=Act01_Move;
        Action.Delay:=2+ActStartTime;
        Action.HE:=HE;
        Actions.add(Action); }

      end
      else PSKA.mov:=0;
    end
    else
    begin
      PSKA.mov:=0;
      mHeros[HE].tgt.x:= mHeros[HE].pos.x;
      mHeros[HE].tgt.y:= mHeros[HE].pos.y;
      mPath.FindPath(HE);
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_AI_PlayTurn(PL: integer);
var
  HE: integer;
begin
  HE:=Cmd_AI_SelectHero(PL);
  if HE <> -1
  then Cmd_AI_MoveHero(HE)
  else SnGame.DoEndTurn;
end;
{----------------------------------------------------------------------------}

end.
