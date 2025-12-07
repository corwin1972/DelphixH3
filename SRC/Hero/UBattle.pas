unit UBattle;

interface

uses  Types, Forms, UFile, UType, SysUtils, Classes, StdCtrls, ExtCtrls, UPathHexa, Math, USnDialog;

type

TBaState =
    (bsStart, bsNext, bsPlay, bsReply, bsReplay, bsFreeze, bsEnd, bsSpell, bsWin);


TSPschool =
     (spEarth, spWater, spFire, spAir);

const // globales

  STARTX=56;
  STARTY=86;
  HEXww=44;
  HEXhh=42;
  MAX_UNIT=42;
  SD_LEFT=0;  //attacker
  SD_RIGHT=1;  //defender
  DirU=0;
  DirR=1;
  DirD=2;
  iSTATE  : array [0..8] of string = ( 'bsStart', 'bsNext', 'bsPlay', 'bsReply', 'bsReplay', 'bsFreeze', 'bsEnd', 'bsSpell', 'bsWin');

  iACTION: array [0..21] of string = (
  'bAnimNo','bAnimSpel','bAnimWalk','bAnimDef',
  'bAnimQuit','bAnimLeav','bAnimAtt','bAnimShot','bAnimWait', 'bAnimCatapult' ,
  'bAnimCast','Freze','Heal','bAnimFly','bAnimDmg','bAnimLuck','bAnimMoral',
  'bAnimCastEnd', 'bAnimdeath', 'bAnimReplyAtt', 'bAnimReplyDmg','bAnimReplyDeath');

   //*** action Battle ***//
  bActionNo=0;
  bActionSpel=1;
  bActionWalk=2;        // = Walk
  bActionDef=3;         // = Defend
  bActionQuit=4;        // = Retreat from the battle
  bActionLeav=5;        // = Surrender
  bActionAtt=6;         // = Walk and Attack
  bActionShot=7;        // = Shoot 
  bActionWait=8;        // = Wait
  bActionCatapult=9;    // = Catapult with parabole
  bActionCast=10;       // = Monster casts a spell (fairy dragons)
  bActionFreeze=11;
  bActionHeal=12;
  bActionFly=13;
  bActionDmg=14;
  bActionLuck=15;
  bActionMoral=16;
  bActionCastEnd=17;
  bActionDeath=18;
  bActionReplyAtt=19;
  bActionReplyDmg=20;
  bActionReplyDeath=21;
  cAnimMove=0;
  cAnimSelect=1;
  cAnimStand=2;
  cAnimDmg=3;
  cAnimDef=4;             // also for smaldmg
  cAnimDeath=5;           // startat 3
  cAnimDeath2=6;          // beholder only
  cAnimTurn_LeftFront=7;
  cAnimTurn_RightFront=8;
  cAnimTurn_LeftBack=9;
  cAnimTurn_RightBack=10;
  cAnimAttak_up=11;
  cAnimAttak_side=12;
  cAnimAttak_down=13;
  cAnimShoot_up=14;
  cAnimShoot_side=15;
  cAnimShoot_down=16;
  cAnimCast_up=17;
  cAnimCast_side=18;
  cAnimCast_down=19;
  cAnimStart=20;           //rise begin move special power
  cAnimEnd=21;             //land end move
  cAnimTurn=22;
  {	enum EAnimType // list of creature animations, numbers were taken from def files
		WHOLE_ANIM=-1, //just for convenience
		MOVING=0, //will automatically add MOVE_START and MOVE_END to queue
		MOUSEON=1, //rename to IDLE
		HOLDING=2, //rename to STANDING
		HITTED=3,
		DEFENCE=4,
		DEATH=5,
		//DEATH2=6, //unused?
		TURN_L=7, //will automatically play second part of anim and rotate creature
		TURN_R=8, //same
		//TURN_L2=9, //identical to previous?
		//TURN_R2=10,
		ATTACK_UP=11,
		ATTACK_FRONT=12,
		ATTACK_DOWN=13,
		SHOOT_UP=14,
		SHOOT_FRONT=15,
		SHOOT_DOWN=16,
		CAST_UP=17,
		CAST_FRONT=18,
		CAST_DOWN=19,
		DHEX_ATTACK_UP=17,
		DHEX_ATTACK_FRONT=18,
		DHEX_ATTACK_DOWN=19,
		MOVE_START=20, //no need to use this two directly - MOVING will be enought
		MOVE_END=21
		//MOUSEON=22 //special group for border-only images - IDLE will be used as base
		//READY=23 //same but STANDING is base
}
  {UN_DOUBLE=      $0001;   //  1 - DOUBLE_WIDE - Takes 2 square
  UN_FLY=         $0002;   //  2 - fly
  UN_SHOOT=       $0004;   //  4 - shooter linked to graphic showing it shooting.
  UN_BREATH=      $0008;   //  8 - extended attack radius (2 square)  breath weapon (depth not radius)
  UN_ALIVE=       $0010;   // 16 - alive
  UN_CATAPULT=    $0020;   // 32 - CATAPULT, Cyclopes have this ability.
  UN_SIEGE=       $0040;   // 64 - SIEGE WEAPON - cannot move
  UN_KING=        $0080;   // 128 - KING_1 all 7th level creatures and neutral dragons that aren't KING_2 or KING_3.
  UN_KING1=       $0100;   // 256 - KING_2 Angels, Archangels, Devils, Archdevils.
  UN_KING2=       $0200;   // 512 - KING_3 Giants, Titans
  UN_NOMIND=      $0400;   // 1024 - immune to mind spell
  UN_NOOBS=       $0800;   // 2048 - monster: 35,74,75 "no obstacle penalty," since Archmages have that ability and Mages don't.
  UN_NOCLOSE=     $1000;   // 4096 - no penalty in close combat
  UN_UNKNOWN=     $2000;   // 8192 - ----
  UN_NOFIRE=      $4000;   // 16384 - IMMUNE_TO_FIRE_SPELLS
  UN_TWICE=       $8000;   // 32768 - shoot twice a non-range unit attack twice - Crusader, Wolf-Raider
  UN_NORETALIATE=$10000;   // 65536 - no enemy retaliation Cerberus has this ability (in addition to Hydra etc.) However if you give a unit this ability, it will attack in all directions, not just forwards like the Cerberus.
  UN_NOMORAL=    $20000;   // 131072 - no moral penalty
  UN_UNDEAD=     $40000;   // 262144 - undead
  UN_MELEE=      $80000;   // 524288 - attack all enemies around
  UN_RADIUS=    $100000;   // 1048576 - extended radius of shooters This is the Magog/Lich/Power Lich ability. You don't appear to be able to give a creature this ability. I assume since Magogs and Liches work differently, the program must check creature number.

  UN_SUMMONED=  $400000;
  UN_CLONE2=    $800000;
  UN_MORAL2=   $1000000;
  UN_WAIT2=    $2000000;
  UN_FIN2=     $4000000;
  UN_DEF2=     $8000000;

  UN_DRAGON=  $80000000;   // 2147483648 - Dragon   }

  UN_DOUBLE=      $0001;   //0  1 - DOUBLE_WIDE - Takes 2 square
  UN_FLY=         $0002;   //1  2 - fly
  UN_SHOOT=       $0004;   //2  4 - shooter linked to graphic showing it shooting.
  UN_CATAPULT=    $0008;   //3  8 - CATAPULT, Cyclopes have this ability.
  UN_NORETALIATE= $0010;   //4  16 - no enemy retaliation Cerberus has this ability (in addition to Hydra etc.)
  UN_CHARGE=      $0100;   //08  256 - jousting
  UN_TWICE=       $0200;   //09 512 - shoot twice a non-range unit attack twice - Crusader, Wolf-Raider
  UN_MORALBON=    $0400;   //10 1024 - bonus moral
  UN_UNDEAD=      $0800;   //11 2048 - undead
  UN_NOCLOSE=     $1000;   //12 4096 - no penalty in close combat
  UN_NOOBS=       $2000;   //13 8192 - monster: 35,74,75 "no obstacle penalty," since Archmages have that ability and Mages don't.
  UN_MORALPEN=    $4000;   //14 16384 - penalty moral

  UN_READY=$0000;
  UN_WAIT= $0001;
  UN_DONE= $0002;
  UN_DEF=  $0004;
  UN_CLONE=$0008;
  UN_MORAL=$0010;

var
  bTiles: array [-1..MAX_BAX+1,-1..MAX_BAY+1] of integer;
  bTR: byte;
  bCT: integer;
  bState,oState: TBaState;
  bId,bTgt: integer;
  bProj: record
  x,y,x0,y0,x1,y1,time : integer;
  end;
  bUnits: array [-2..41] of TBaUnit;
  bObstacle: array [0..41] of byte;
  bWall: array [0..10] of byte;
  bUnitID_P0_Machine:   array [0..42] of integer;
  bUnitID_P1_ToMove:    array [0..42] of integer;
  bUnitID_P2_WaitMoral: array [0..42] of integer;
  bUnitID_P3_Other:     array [0..42] of integer;
  bUnitID_Chain :       Array [0..42] of integer;
  bUnitNb_Chain : integer;
  phase: integer;
  phaseCR: integer;
  bAction: integer;
  bActionTime: integer;

  bSide: byte;
  bObjLeft: integer;
  bObjRight: integer;
  bShotDir: integer;
  BridgeOpen:boolean;
  BridgeDestroyed:boolean;
  bHeros: array [0..1] of integer;
  bHeroLEFT: integer;
  bHeroRight: integer;
  bHeroAtk, bHeroDef: integer;
  bAttak: integer;
  bSpel: integer;
  bSpelLevel: integer;
  bWinLeft: boolean; //true=win by Att
  bFinished: boolean;
  bExp: integer;
  bMsg: string;
  bText: TSTringlist;
  bPath: TBaPath;

  procedure cmd_BA_ChangeState;
  procedure cmd_BA_NextTurn;
  procedure cmd_BA_AutoBattle;
  procedure cmd_BA_Def;
  procedure cmd_BA_Wait;
  procedure cmd_BA_Attack(bAttakType:integer);
  procedure cmd_BA_AttackHAND;
  procedure cmd_BA_AttackSHOT;
  procedure cmd_BA_AttackCast(btgt, ratio: integer);
  procedure cmd_BA_AttackWALL;
  procedure cmd_BA_AllowSpellAction(SP:integer;CanSpell: boolean);
  procedure cmd_BA_CancelSpellAction;
  procedure cmd_BA_Spell(SP,bTgt: integer);
  function  cmd_BA_Spell_Failure(HE: integer):boolean;
  function  cmd_BA_DMG(bAtk,bDef: integer): integer;
  procedure cmd_BA_DMG_HandAttak(HE,bAtk: integer; var dmg:integer);
  procedure cmd_BA_DMG_ShotAttak(HE,bAtk,bDef: integer; var dmg:integer);
  procedure cmd_BA_DMG_CastAttak(HE,bDef: integer; var dmg:integer);
  function  cmd_BA_HitCr(id,Dmg: integer): integer;
  procedure cmd_BA_CPU(id: integer);
  procedure cmd_BA_Exp;
  procedure cmd_BA_End;
  procedure cmd_BA_NoArmy(side:integer);
  procedure cmd_BA_InitBattle(atk,def:integer);
  procedure cmd_BA_HeroSpecialCR(HE,CR,ID:integer);
  procedure cmd_BA_FleeBattle(side:integer);
  procedure cmd_BA_Info(x,y: integer; var s: string);
  procedure cmd_BA_WalkTo(x,y: integer);
  procedure cmd_BA_FlyTo(x,y: integer);
  procedure cmd_BA_MoveTo(x,y,msid: integer);
  procedure cmd_BA_HealAtk;
  procedure cmd_BA_HealDef;
  procedure cmd_BA_NextTurnAtk;
  procedure cmd_BA_NextTurnDef;
  procedure cmd_BA_NextUnit;
  procedure cmd_BA_Ranged;
  procedure cmd_BA_Reply;
  function  cmd_BA_VirtualBattle(HE,DF:integer): integer;
  procedure cmd_SP_CreateOBJ(SP:integer);
  procedure cmd_SP_DestroyOBJ(SP:integer);
  procedure cmd_SP_ShootDMG(SP:integer);
  procedure cmd_SP_AreaDMG(SP:integer;r: integer);
  procedure cmd_SP_ChainDMG_Prepare(SP:integer);
  procedure cmd_SP_ChainDMG(SP:integer);
  procedure cmd_SP_GlobalDMG(SP:integer);
  procedure cmd_SP_Bonus(SP:integer);
  procedure cmd_SP_Life(SP:integer);
  procedure cmd_SP_Move(SP:integer);
  function  cmd_SP_Summon(SP:integer):integer;
  procedure cmd_SP_BonusRemove(SP:integer;BU:integer);
  procedure cmd_SP_BonusApply(SP,BU: integer);
  function  Hex2PosXY(i,j:integer): TPoint;
  function  PosXY2Hex(x,y:integer): TPoint;
  function  Is2HexCR(id:integer): boolean;
  function  IsFlyCR(id:integer): boolean;
  function  IsALiveCR(id:integer): boolean;
  function  IsUnDeadCR(id:integer): boolean;
  function  IsWarMachine(id:integer): boolean;
  function  IsNoRetaliateCR(id:integer) : boolean;
  function  IsBridgePassable : boolean;
  function  cmd_BA_OpenBridge : boolean;
  function  cmd_BA_CloseBridge : boolean;
  //function  IsAliveCR(id:integer) : boolean;
  procedure cmd_BA_Log(s:string);

implementation

uses UHE, UOB, UMain, UEnter, UCT;

{----------------------------------------------------------------------------}
function  cmd_BA_CloseBridge : boolean;
begin
  result:=false;
  if (bCT> -1) then
  begin
    if (bTiles[9,5]=-1) and (bTiles[10,5]=-1)
    then
    begin
        result:=true;
        BridgeOpen:=False;
    end;
    if bridgeDestroyed  then result:=false;
  end;
end;
{----------------------------------------------------------------------------}
function  cmd_BA_OpenBridge : boolean;
begin
  result:=false;
  if (bCT> -1) then
  begin
    if ((BPath.WayHex[BPath.step+1].x=8) or (BPath.WayHex[BPath.step+1].x=9) or (BPath.WayHex[BPath.step+1].x=10)) and  (BPath.WayHex[BPath.step+1].y=5)  then
      begin
        result:=true;
        BridgeOpen:=true;
      end;
    if bridgeDestroyed  then result:=false;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_Log(s:string);
begin
  bText.add(s);
  logF.insert(s);
end;
{----------------------------------------------------------------------------}
function Hex2PosXY(i,j:integer): TPoint;
begin
  result.x:=startX+(HEXww div 2)*(1 - j mod 2)+HEXww * i;
  result.y:=startY+HEXhh*j;
end;
{----------------------------------------------------------------------------}
function PosXY2Hex(x,y:integer): TPoint;
begin
  result.y:=(y-startY+HEXhh) div HEXhh -1;
  result.x:=(x-startX-(HEXww div 2)*(1- result.y mod 2)+HEXww) div HEXww  - 1 ;
end;
{----------------------------------------------------------------------------}
function Is2HexCR(id:integer): boolean;
begin
  result:=((iCrea[bUnits[id].t].flag and UN_DOUBLE) = UN_DOUBLE)
end;
{----------------------------------------------------------------------------}
function IsFlyCR(id:integer): boolean;
begin
  result:=((iCrea[bUnits[id].t].flag and UN_FLY) = UN_FLY)
end;
{----------------------------------------------------------------------------}
function IsAliveCR(id:integer): boolean;
begin
  result:=not((iCrea[bUnits[id].t].flag and UN_UNDEAD) = UN_UNDEAD)
end;
{----------------------------------------------------------------------------}
function IsUndeadCR(id:integer): boolean;
begin
  result:=((iCrea[bUnits[id].t].flag and UN_UNDEAD) = UN_UNDEAD)
end;
{----------------------------------------------------------------------------}
function IsNoRetaliateCR(id:integer): boolean;
begin
  result:=((iCrea[bUnits[id].t].flag and UN_NORETALIATE) = UN_NORETALIATE);
end;
{----------------------------------------------------------------------------}
function IsWarMachine(id:integer): boolean;
begin
  if bUnits[id].t > 117 then result:=true;
end;
{----------------------------------------------------------------------------}
function  IsBridgePassable: boolean;
begin
  if bside=SD_Right then
  if bTiles[8,5]=-1 then result:=true;

  //if bside=SD_Left then
  if (bridgeOpen) or (bridgeDestroyed) then result:=true;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_NoArmy(side:integer);
var
  i:integer;
  NoArmy:boolean;
begin
  NoArmy:=true;
  for i:=0 to 20 do
  begin
    // exclude MO119_Ballista / MO121_AmmoCart / MO120_FirstAidTent
    if bUnits[21*side+i].t < 119
    then     
       NoArmy:=NoArmy and (bUnits[21*side+i].n <= 0);
  end;
  if NoArmy then
  begin
    bFinished:=true;
    bWinLEFT:=(side=SD_RIGHT);
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_CancelSpellAction;
begin
  bState:=bsPlay;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_AllowSpellAction(SP:integer;CanSpell: boolean);
begin
  if CanSpell
  then begin
    cmd_BA_Log(format('[%d] %s is alowed',[SP,ispel[SP].name]));
    bState:=bsSpell;
    bSpel:=SP;
  end
  else begin
    cmd_BA_Log(format('[%d] %s is not allowed due to ARTEFACT',[SP,ispel[SP].name]));
    bState:=bsPlay;
    bSPel:=SP;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_Def;
begin
  if (bUnits[bid].state=UN_DEF) then exit;
  bState:=bsNext;
  bAction:=bActionDef;
  bUnits[bId].state:=UN_DEF;
  cmd_BA_Log(format('   %s take a defensive attitude and gain +1 DEF ',[iCrea[bUnits[bid].t].name]));
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_Wait;
begin
  if (bUnits[bid].state=UN_WAIT) then exit;
  bState:=bsNext;
  bAction:=bActionNo; //bActionWait;
  bUnits[bid].state:=UN_WAIT;
  cmd_BA_Log(format('   %s prefer to wait',[iCrea[bUnits[bid].t].name]));
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_FleeBattle(side:integer);
var
  i: integer;
begin
  cmd_BA_Log('   You decide to quit battle and flee');
  bWinLEFT:=true;   // todo the opposite and check side
  if bWinLEFT=false
  then
    for i:=0 to MAX_ARMY do bUnits[i].n:=0
  else
    for i:=0 to MAX_ARMY do bUnits[21+i].n:=0;
  { compute surrender cost and apply reduction cost (sk + art)
    SK04_Diplomacy -20% -40% - 60%
    AR066_StatesmansMedal
    AR067_DiplomatsRing
    AR068_AmbassadorsSash
    AR125_ShacklesofWar //no one fleee}
end;
{----------------------------------------------------------------------------}
function cmd_BA_VirtualBattle(HE,DF:integer): integer;
var
  i,t,n,
  forceA, forceD: integer;
  attA: integer;
begin
  forceA:=0;
  attA:=mHeros[HE].PSKB.att;
  for i:=0 to MAX_ARMY do
  begin
    t:=mHeros[HE].Armys[i].t;
    n:=mHeros[HE].Armys[i].n;
    if t> -1 then
      forceA:=forceA+iCrea[t].dmgMax*(iCrea[t].atk+ attA)*n;
  end;
  t:=mObjs[DF].u;
  n:=mMonsters[mObjs[DF].v].qty;
  forceD:=iCrea[t].dmgMax*(iCrea[t].atk)*n;
  result:= forceA-forceD;
  LogP.InsertInt('AI Battle',result);
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_HeroSpecialCR(HE,CR,ID:integer);
var
  bonus : integer;
begin
  if (mHeros[HE].specSK=SS01_Creature) and ((mHeros[HE].specSKP=CR) or (mHeros[HE].specSKP+1=CR))  then
  begin
    if mHeros[HE].level > ((CR mod 14) div 2) then
    begin
      //bonus:= mHeros[HE].level div ((CR mod 14) div 2);
      bUnits[ID].atk0:= bUnits[ID].atk0 +1;
      bUnits[ID].def0:= bUnits[ID].def0 +1;
      bUnits[ID].move0:=bUnits[ID].move0+1;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_InitBattle(atk,def:integer);
var
  DefArmys, AttArmys: TArmys;
const
  bPos1: array [0..6] of integer =(5,0,0,0,0,0,0);
  bPos2: array [0..6] of integer =(2,8,0,0,0,0,0);
  bPos3: array [0..6] of integer =(2,5,8,0,0,0,0);
  bPos4: array [0..6] of integer =(0,4,6,10,0,0,0);
  bPos5: array [0..6] of integer =(0,2,4,8,10,0,0);
  bPos6: array [0..6] of integer =(0,2,4,6,8,10,0);
  bPos7: array [0..6] of integer =(0,2,4,5,6,8,10);

procedure InitBattleVar;
var
  i,j: integer;
begin
  bText.Clear;
  bCT:=-1;
  bHeroLEFT:=-1;
  bHeroRIGHT:=-1;
  bAction:=bActionNo;
  oState:=bsStart;
  bState:=bsNext;
  bFinished:=false;
  bSide:=SD_LEFT;
  bId:=-1;
  bTgt:=-1;
  // reset bTiles
  for i:=-1 to MAX_BAX+1 do
    for j:=-1 to MAX_BAY+1 do
      bTiles[i,j]:=-2;
  for i:=0 to MAX_BAX do
    for j:=0 to MAX_BAY do
      bTiles[i,j]:=-1;
  // reset bUnits
  for i:=0 to 41 do
  begin
    bUnits[i].t:=-1;
    bUnits[i].n:=0;
  end;
end;
{----------------------------------------------------------------------------}
procedure InitAtkMachine;
var i :integer;
begin
  if ((cmd_HE_FindART(bHeroLEFT,AR003_Catapult) >0) and ( bCT > -1)) then
  begin
    bTiles[0,1]:=20;
    bUnits[20].x:=-1;
    bUnits[20].y:=7;
    bUnits[20].t:=MO118_Catapult;
    bUnits[20].n:=1;
  end;

  if cmd_HE_FindART(bHeroLEFT,AR004_Ballista) >0 then
  begin
    bTiles[0,3]:=19;
    bUnits[19].x:=-1;
    bUnits[19].y:=3;
    bUnits[19].t:=MO119_Ballista;
    bUnits[19].n:=1;
  end;

  if cmd_HE_FindART(bHeroLEFT,AR005_AmmoCart) >0 then
  begin
    bTiles[0,7]:=18;
    bUnits[18].x:=0;
    bUnits[18].y:=1;
    bUnits[18].t:=MO121_AmmoCart;
    bUnits[18].n:=1;
  end;

  if cmd_HE_FindART(bHeroLEFT,AR006_FirstAidTent) >0 then
  begin
    bTiles[0,9]:=17;
    bUnits[17].x:=-1;
    bUnits[17].y:=9;
    bUnits[17].t:=MO120_FirstAidTent;
    bUnits[17].n:=1;
  end;

  // create summoned units
  for i:=16 downto 10 do
  begin
    bUnits[i].x:=-1;
    bUnits[i].y:=-1;
    bUnits[i].t:=20;
    bUnits[i].n:=0;
  end;
end;
{----------------------------------------------------------------------------}
procedure InitAtkArmyPos;
const
BANKHEPOS: array [0..6,0..1] of integer =((5,3),(9,3),(4,5),(7,5),(10,5),(5,7),(9,7));
var
  i,j: integer;
  qty: integer;
begin
  AttArmys:=mHeros[bHeroLEFT].Armys;
  // count of Armys
  qty:=0;
  for i:=0 to MAX_ARMY do
    if  (AttArmys[i].n >0) and (AttArmys[i].t >-1)   then
    qty:=qty+1;
    j:=0;
  // bUnits setup with Armys info : t n + position
  for i:=0 to MAX_ARMY do
  begin
    if  (AttArmys[i].n >0) and (AttArmys[i].t >-1)   then
    begin
      mObj:=mObjs[bObjRight];
      if  (mObj.t=OB16_CreatureBank)  or (mObj.t=OB84_Crypt)  or (mObj.t=OB25_DragonUtopia) 
      then
      begin
        bUnits[i].x:=BANKHEPOS[i,0];
        bUnits[i].y:=BANKHEPOS[i,1];
      end
      else
      begin
        bUnits[i].x:=0;
        //bUnits[i].y:=2*i; if i=MAX_ARMY then bUnits[i].y:=5;
        case qty of
        1: bUnits[i].y:=bPos1[j];
        2: bUnits[i].y:=bPos2[j];
        3: bUnits[i].y:=bPos3[j];
        4: bUnits[i].y:=bPos4[j];
        5: bUnits[i].y:=bPos5[j];
        6: bUnits[i].y:=bPos6[j];
        7: bUnits[i].y:=bPos7[j];
        end;
        j:=j+1;
      end;
      bUnits[i].t:=attArmys[i].t;
      bUnits[i].n:=attArmys[i].n;
    end;
  end;
  InitAtkMachine;
end;
{----------------------------------------------------------------------------}
procedure InitAtkUnits;
var
  i,j,bonusSPEED, bonusLife: integer;
  castle : integer ;
  castlemix : boolean;

begin
  bonusSPEED:=cmd_HE_FindArt(bHeroLEFT,AR097_NecklaceofSwiftness)
     + 2*cmd_HE_FindArt(bHeroLEFT,AR098_BootsofSpeed)
     + 2*cmd_HE_FindArt(bHeroLEFT,AR099_CapeofVelocity);

  // bonus +1 speed if all army from same town
  castlemix:=false;
  for i:=0 to 6 do
  begin
    castle :=-1;
    if bUnits[i].t> -1 then
    begin
      if castle=-1
      then castle := bUnits[i].t mod 14
      else if castle <> bUnits[i].t mod 14
        then castlemix:=true;
     end;
  end;
  if not(castlemix) then  bonusSPEED:=bonusSpeed+1;

  bonusLIFE:=cmd_HE_FindArt(bHeroLEFT,AR094_RingofVitality)
     +   cmd_HE_FindArt(bHeroLEFT,AR095_RingofLife)
     + 2*cmd_HE_FindArt(bHeroLEFT,AR096_VialofLifeblood);

  // bUnits setup with Creas info : ....
  for i:=0 to 20 do
  begin
    if bUnits[i].t> -1
    then
    with bUnits[i] do
    begin
      side:=SD_LEFT;
      AnimType:=cAnimStand;
      AnimPos:=0;
      AnimCount:=iCrea[t].AnimList[1].Count;
      Animlist:=@iCrea[t].AnimList;
      n0:=n;
      atk0:=iCrea[t].atk + mHeros[bHeroLEFT].PSKB.att;
      def0:=iCrea[t].def + mHeros[bHeroLEFT].PSKB.def;
      move0:=iCrea[bUnits[i].t].speed + bonusSpeed;
      cmd_BA_HeroSpecialCR(bHeroLEFT,t,i);
      atk1:=atk0;
      def1:=def0;
      move1:=move0;
      luck0:=mHeros[bHeroLEFT].luck; //+mHeros[HE].SSK[SK09_Luck] // already applied in HE luck
      luck1:=luck0;
      moral0:=mHeros[bHeroLEFT].moral+mHeros[bHeroLEFT].SSK[SK06_LeaderShip];
      moral1:=moral0;
      HexTravelled:=0;
      state:=UN_READY;
      for j:=0 to MAX_SPEL -1 do
      begin
        spelD[j]:=0;
        spelE[j]:=0;
      end;
      reply:=true;
      shot:=iCrea[t].shots;
      hit0:=iCrea[t].hit+bonuslife;
      hit1:=hit0;
      dirLeft:=false;
      bTiles[x,y]:=i;
      if is2HexCR(i) then bTiles[x+1,y]:=i;
      cmd_BA_Log(format('* Add Attacker %d [%d,%d]: %d %s',[i,x,y, n,iCrea[t].name]));
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure InitDefMachine;
var
towertype: integer;
begin

  
  if ((cmd_HE_FindART(bHeroRIGHT,AR004_Ballista) >0) and ( bCT = -1)) then
  begin
    bTiles[14,3]:=29;
    bUnits[29].x:=15;
    bUnits[29].y:=4;
    bUnits[29].t:=MO119_Ballista;
    bUnits[29].n:=1;

  end;

  if cmd_HE_FindART(bHeroRIGHT,AR005_AmmoCart) >0 then
  begin
    bTiles[14,7]:=28;
    bUnits[28].x:=14;
    bUnits[28].y:=2;
    bUnits[28].t:=MO121_AmmoCart;
    bUnits[28].n:=1;
  end;

  if cmd_HE_FindART(bHeroRIGHT,AR006_FirstAidTent) >0 then
  begin
    bTiles[14,9]:=27;
    bUnits[27].x:=15;
    bUnits[27].y:=10;
    bUnits[27].t:=MO120_FirstAidTent;
    bUnits[27].n:=1;
  end;

  if ( bCT > -1) then
  begin
    towerType:=mCitys[bCT].t*14+2;
    while iCrea[towertype].shots =0 do
    begin
      inc(towerType);
    end;
    bUnits[30].t:=towerType; // arbaletrier
    bUnits[30].n:=1;
    bUnits[30].tower:=1;
    bUnits[30].x:=11;
    bUnits[30].y:=-1;

    bUnits[31].t:=towerType;  // arbaletrier
    bUnits[31].n:=1;
    bUnits[31].tower:=2;
    bUnits[31].x:=15;
    bUnits[31].y:=3;

    bUnits[32].t:=towerType;  // arbaletrier
    bUnits[32].n:=1;
    bUnits[32].tower:=3;
    bUnits[32].x:=12;
    bUnits[32].y:=11;
  end;
end;

function isBankBattle : boolean;
begin
  mObj:=mObjs[bObjRIGHT];
  if (mObj.t=OB06_Pandora) or (mObj.t=OB16_CreatureBank)  or (mObj.t=OB84_Crypt)  or (mObj.t=OB24_DerelictShip) or (mObj.t=OB25_DragonUtopia)
  then result :=true
end;
{----------------------------------------------------------------------------}
procedure InitDefArmyPos;
const
BANKPOS: array [0..6,0..1] of integer =((14,0), (14,10),(0,10), (0,0),(14,5),(1,1), (2,2));
var
  i,j,qty,x: integer;
begin
  if bHeroRIGHT > -1
  then
    defArmys:=mHeros[bHeroRIGHT].Armys
  else
  begin
    mObj:=mObjs[bObjRIGHT];
    case mobj.t of
      OB05_Artifact, OB06_Pandora:
      begin
        for i:=0 to MAX_ARMY do
        begin
          defArmys[i].t:=mObjs[mObj.id].Armys[i].t;
          defArmys[i].n:=mObjs[mObj.id].Armys[i].n;
        end;
      end;
      OB54_Monster:
      begin
        for i:=0 to MAX_ARMY do
        begin
          defArmys[i].t:=-1;
          defArmys[i].n:= 0;
        end;
        //place def monster on x slots  Wiki said not random but link to force ratio
        qty:=mMonsters[mObj.v].qty;
        case random(100) of
         0..9  : x:=7;
        10..19 : x:=6;
        20..39 : x:=5;
        40..59 : x:=4;
        60..79 : x:=3;
        80..90 : x:=2;
            else x:=1;
        end;
        //split qty on x slot
        if qty >= x then
        for i:=0 to x-1 do
        begin
          defArmys[i].t:=mObj.u;
          defArmys[i].n:=qty div x;
        end;
        //place remaining qty : 1 on first slots
        for i:=0 to (qty mod x)-1 do
        begin
          defArmys[i].t:=mObj.u;
          defArmys[i].n:=defArmys[i].n+1;
        end;
      end;
      OB16_CreatureBank,OB24_DerelictShip,OB25_DragonUtopia, OB84_Crypt, OB85_Shipwreck:
      begin
        for i:=0 to MAX_ARMY do
        begin
          defArmys[i].t:=mObj.Armys[i].t;
          defArmys[i].n:=mObj.Armys[i].n;
        end;
      end;
      OB98_City:
      begin
        defArmys:=mCitys[mObj.v].garArmys;
        {for i:=0 to MAX_ARMY do
        begin
          defArmys[i].t:=mCitys[mObj.v].garArmys[i].t;
          defArmys[i].n:=mCitys[mObj.v].garArmys[i].n;
        end; }
      end;
    end;
  end;

  qty:=0;
  for i:=0 to MAX_ARMY do
    if  (DEfArmys[i].n >0) and (DefArmys[i].t >-1)   then
    qty:=qty+1;
  j:=0;

  for i:=0 to MAX_ARMY do
  begin
    if  (DefArmys[i].n >0) and (DefArmys[i].t >-1)   then
    begin
      if isBankBattle then
      begin
          bUnits[21+i].x:=BANKPOS[i,0];
          bUnits[21+i].y:=BANKPOS[i,1];
      end
      else
      begin
        bUnits[21+i].x:=14;
        case qty of
        1: bUnits[21+i].y:=bPos1[j];
        2: bUnits[21+i].y:=bPos2[j];
        3: bUnits[21+i].y:=bPos3[j];
        4: bUnits[21+i].y:=bPos4[j];
        5: bUnits[21+i].y:=bPos5[j];
        6: bUnits[21+i].y:=bPos6[j];
        7: bUnits[21+i].y:=bPos7[j];
        end;
        j:=j+1;
      end;
      bUnits[21+i].t:=DEFArmys[i].t;
      bUnits[21+i].n:=DEFArmys[i].n;
    end;
  end;

  if bHeroRIGHT > -1
  then
  begin
    InitDefMachine;
  end
end;
{----------------------------------------------------------------------------}
procedure InitDefUnits;
var
  i,j,bonusSPEED, bonusLife: integer;
  castle : integer ;
  castlemix : boolean;
begin
   bonusSpeed:=cmd_HE_FindArt(bHeroRIGHT,AR097_NecklaceofSwiftness)
     + 2*cmd_HE_FindArt(bHeroRIGHT,AR098_BootsofSpeed)
     + 2*cmd_HE_FindArt(bHeroRIGHT,AR099_CapeofVelocity);

  // bonus +1 speed if all army from same town
  castlemix:=false;
  for i:=21 to 27 do
  begin
    castle :=-1;
    if bUnits[i].t> -1 then
    begin
      if castle=-1
      then castle := bUnits[i].t mod 14
      else if castle <> bUnits[i].t mod 14
        then castlemix:=true;
     end;
  end;
  if not(castlemix) then  bonusSPEED:=bonusSpeed+1;

   bonusLIFE:=cmd_HE_FindArt(bHeroRIGHT,AR094_RingofVitality)
     +   cmd_HE_FindArt(bHeroRIGHT,AR095_RingofLife)
     + 2*cmd_HE_FindArt(bHeroRIGHT,AR096_VialofLifeblood);
   // bUnits setup with Creas info : ....
  for i:=21 to 41 do
  begin
    if (bUnits[i].t> -1) and   (bUnits[i].t< 1000)
    then
    with bUnits[i] do
    begin
      side:= SD_RIGHT;
      AnimType:=cAnimStand;
      AnimPos:=0;
      AnimCount:=iCrea[t].AnimList[1].Count;
      Animlist:=@iCrea[t].AnimList;
      n0:=n;
      atk0:=iCrea[t].atk+ mHeros[bHeroRIGHT].PSKB.att;
      def0:=iCrea[t].def+ mHeros[bHeroRIGHT].PSKB.def;
      move0:=iCrea[t].speed+ bonusSpeed;
      if i>=30 then move0:=0; //tower
      cmd_BA_HeroSpecialCR(bHeroRight,t,i);
      atk1:=atk0;
      def1:=def0;
      move1:=move0;
      luck0:=mHeros[bHeroRIGHT].luck; //+mHeros[HE].SSK[SK09_Luck] // already applied in HE luck
      luck1:=luck0;
      moral1:=mHeros[bHeroRIGHT].moral+mHeros[bHeroRIGHT].SSK[SK06_LeaderShip];
      moral1:=moral0;
      HexTravelled:=0;
      state:=UN_READY;
      for j:=0 to MAX_SPEL -1 do
      begin
        spelD[j]:=0;
        spelE[j]:=0;
      end;
      reply:=true;

      shot:=iCrea[t].shots;
      hit0:=iCrea[t].hit+bonusLife;
      hit1:=hit0;
      dirLeft:=true;
      bTiles[x,y]:=i;
      if is2HexCR(i) then
        bTiles[x-1,y]:=i;
      cmd_BA_Log(format('* Add Defender %d [%d,%d]: %d %s',[i,x,y,n,iCrea[t].name]));
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure InitOrder;
var i,j,k,l: integer;
begin
  for i:=0 to 42 do
  begin
    bUnitID_P0_Machine[i]:=-1;
    bUnitID_P1_ToMove[i]:=-1;
    bUnitID_P2_WaitMoral[i]:=-1;
    bUnitID_P3_Other[i]:=-1;
  end;

  if  (bCT) > -1 then
  begin
    if bUnits[20].t=MO118_Catapult
    then bUnitID_P0_Machine[0]:=20;
    {if CT has defense
    then bUnitID_P0_Machine[1]:=TowerUp;
    then bUnitID_P0_Machine[2]:=TowerDn;
    then bUnitID_P0_Machine[3]:=TowerCenter}
  end;
  j:=0;
  bUnitID_P1_ToMove[j]:=0;
  for i:=1 to 40 do
  begin
    if  bUnits[i].t=-1
    then
    begin
      continue
    end
    else
    begin
      j:=j+1;
      for k:=0 to j-1 do
      begin
        if  bunits[i].move1 > bunits[bUnitID_P1_ToMove[k]].move1
        then
        begin
          for l:=j downto k+1 do
            bUnitID_P1_ToMove[l]:=bUnitID_P1_ToMove[l-1];
          break;
        end;
      end;
      bUnitID_P1_ToMove[k]:=i;
    end;
  end;
  phaseCr:=-1;
  phase:=0;
end;
{----------------------------------------------------------------------------}
procedure InitObstacle;
var
  i:integer;
begin
  if  (bCT = -1) then exit;
  //battle inside city : setup obstacle
  bTiles[11,0]:=-2;
  bTiles[11,1]:=-2;
  bTiles[10,2]:=-2;
  bTiles[10,3]:=-2;
  bTiles[ 9,4]:=-2;
  //bTiles[ 10,5]:=-2;  //bTiles[ 10,5]:=-2 opening the gate  special bridge
  bTiles[ 9,6]:=-2;
  bTiles[10,7]:=-2;
  bTiles[10,8]:=-2;
  bTiles[11,9]:=-2;
  bTiles[11,10]:=-2;
  for i:=0 to 10 do bWall[i]:=0; //wall=2, dmgwall=1, nowall=0
  bWall[1]:=2;
  bWall[4]:=2;
  bWall[5]:=2;
  bWall[7]:=2;
  bWall[10]:=2;
{std::make_pair(50,  EWallParts::KEEP),
std::make_pair(183, EWallParts::BOTTOM_TOWER),
std::make_pair(182, EWallParts::BOTTOM_WALL),
std::make_pair(130, EWallParts::BELOW_GATE),
std::make_pair(62,  EWallParts::OVER_GATE),
std::make_pair(29,  EWallParts::UPPER_WAL),
std::make_pair(12,  EWallParts::UPPER_TOWER),
std::make_pair(95,  EWallParts::GATE),
std::make_pair(96,  EWallParts::GATE),
std::make_pair(45,  EWallParts::INDESTRUCTIBLE_PART),
std::make_pair(78,  EWallParts::INDESTRUCTIBLE_PART),
std::make_pair(112, EWallParts::INDESTRUCTIBLE_PART),
std::make_pair(147, EWallParts::INDESTRUCTIBLE_PART) }
end;
{----------------------------------------------------------------------------}

begin
  InitBattleVar;
  bObjLEFT:=  atk;
  bObjRIGHT:= def;
  bExp:=0;
  if mObjs[atk].t=OB34_Hero
  then bHeroLEFT:=mObjs[atk].v
  else bHeroLEFT:=-1;

  if mObjs[Def].t=OB34_Hero
  then
  begin
    bHeroRIGHT:=mObjs[def].v;
    bCT:=mHeros[bHeroRIGHT].VisTown;
  end
  else
    bHeroRIGHT:=-1;

  if mObjs[Def].t=OB98_City
  then bCT:=mObj.v;

  bHeros[0]:=bHeroLEFT;
  bHeros[1]:=bHEroRIGHT;

  with mObjs[def].pos do
  bTR:=mTiles[x,y,l].TR.t;
  cmd_BA_Log('****************************************************');
  cmd_BA_Log('*                   Start Battle                   *');
  cmd_BA_Log('****************************************************');
  InitAtkArmyPos;
  InitAtkUnits;
  InitDefArmyPos;
  InitDefUnits;
  InitObstacle;
  InitOrder;
  cmd_BA_Log('****************************************************');
end;

{----------------------------------------------------------------------------}
procedure cmd_BA_NextUnit;
var
  i:integer;
begin
// instead phase Atk(ordered by Y and tomove state), then phase Def
// use     phase1 ordered by speed ,                 then phase 2 waited ...

  for i:=0 to 42 do
  begin
    bid:=bUnitID_P1_ToMove[i];
    // ignore machine
    if (bUnits[bid].t=MO121_AmmoCart) or (bUnits[bid].t=MO120_FirstAidTent)  then
       continue;
    // in the first loop : Take not played CREA / not waiting
    if (bUnits[bid].t > -1)  and  (bUnits[bid].n > 0)  and  (bUnits[bid].state =UN_READY)
    then exit;
  end;

  if bID=-1  then
  begin
  cmd_BA_Log('   All crea played, trying waiting ones');
  for i:=0 to 42 do
  begin
    bid:=bUnitID_P1_ToMove[i];
    // ignore machine
    if (bUnits[bid].t=MO121_AmmoCart) or (bUnits[bid].t=MO120_FirstAidTent)  then
       continue;
    // in the second loop: Take waiting CREA
    if (bUnits[bid].t > -1)  and  (bUnits[bid].n > 0)  and  (bUnits[bid].state =UN_WAIT)
    then exit;
  end;
  end;
  if bID=-1 then  cmd_BA_NextTurn;

  for i:=0 to 42 do
  begin
    bid:=bUnitID_P1_ToMove[i];
    // ignore machine
    if (bUnits[bid].t=MO121_AmmoCart) or (bUnits[bid].t=MO120_FirstAidTent)  then
       continue;
    // in the first loop take not played CREA / not waiting
    if (bUnits[bid].t > -1)  and  (bUnits[bid].n > 0)  and  (bUnits[bid].state =UN_READY)
    then exit;
  end;

end;
{----------------------------------------------------------------------------}
procedure cmd_BA_NextTurn;
begin
  bSpel:=-1;
  cmd_BA_Log('===================================================');
  cmd_BA_NextTurnAtk;
  cmd_BA_NextTurnDef;
  cmd_BA_Log('New Round');
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_ChangeState;
begin
  if bAction <> bActionNo then exit;
  if oState=bState then exit;
  oState:=bState;

  Case bState of
    bsNext : begin
      cmd_BA_Log('- bsNext');
      cmd_BA_NextUnit;
      if bid=-1 then
        bState:=bsWin
      else begin
        bState:=bsPlay;
        if bUnits[bid].Moral1 <  0  then
          if Random(240) <  (-10 * bUnits[bid].Moral1) then
            bState:=bsFreeze;
      end;
    end;
    bsPlay : begin
      cmd_BA_Log('- bsPlay [' + inttostr(bid) + '] '+ iCrea[bUnits[bid].t].name);
      bSide:=bUnits[bid].side;
      bHeroAtk:=bHeros[bSide];
      bHeroDef:=bHeros[1-bSide];
      cmd_BA_Ranged;
      if mHeros[bHeroAtk].cpu then cmd_BA_CPU(bid);
    end;
    bsFreeze : begin
      cmd_BA_Log('- bsFreeze');
      cmd_BA_Log('   Bad Morale prevents ' + iCrea[bUnits[bid].t].Name + ' to attack');
      bUnits[bid].State:=UN_DONE;
      bAction:=bActionLuck;
      bState:= bsNext;
    end;
    bsSpell : begin
       case bSpel of
       SP66_FireElemental,
       SP67_EarthElemental,
       SP68_WaterElemental,
       SP69_AirElemental :
         begin
           //bAction:=bActionCast; //       direct cast
           bAction:=bActionSpel;  //      heroes amimation before cast
         end;
       end;
    end;
    bsReplay : begin
      cmd_BA_Log('- bsReplay');
      cmd_BA_Log('   High Morale enable ' + iCrea[bUnits[bid].t].name +  ' to attack again');
      bAction:=bActionMoral;
      bUnits[bid].State:=UN_DONE;
      bState:= bsPlay;
    end;
    bsReply : begin
      cmd_BA_Log('- bsReply');
      cmd_BA_Reply;
    end;
    bsEnd : begin
      cmd_BA_Log('- bsEnd');
      bState:=bsNext;
      if (bUnits[bid].Moral1 > 0 ) and (bUnits[bid].State= UN_READY) then
      begin
        if Random(240) < (10*bUnits[bid].Moral1)  then
        bState:=bsReplay;
      end;
      bUnits[bid].State:=UN_DONE;
    end;
    bsWin: begin
      cmd_BA_Log('- bsWin');
      bFinished:=true;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_CPU(id: integer);
type
  TTgt = record
    cr: integer;
    tgx: integer;
    tgy: integer;
    mouseid: integer;
  end;

const
Around: array [0..1,1..6,0..1] of integer= (
  ( ( 0,1),(-1,0),( 0,-1), (1,-1),(1,0),(1,1) ) ,
  ( (-1,1),(-1,0),(-1,-1), (0,-1),(1,0),(0,1) ));
  //  SO ,   Ot ,   NO ,     NE  , Et  , SE

var
  tgtx,tgty,msid1:integer;
  ligne:integer;
{----------------------------------------------------------------------------}
procedure SearchShot;
var
  i,n:integer;
begin
  n:=-1;
  bTgt:=-1;
  for i:= (1-bSide)*21 to (1-bSide)*21+20 do
  begin
    if (bUnits[i].n > 0) and (bUnits[i].n > n)  then
    begin
      bTgt:=i;
      n:=bUnits[bTgt].n;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure SearchCombat;
var
  i,j,n:integer;
begin
  n:=-1;
  bTgt:=-1;
  // find close attack
  for i:= (1-bSide)*21 to (1-bSide)*21+20 do
  begin
    if bUnits[i].n > 0 then
    begin
      if (bUnits[i].y mod 2 = 0) then ligne:=0 else ligne:=1;
      for j:= 1 to 6 do
      begin
        tgtx:= bUnits[i].x+Around[ligne,j,0];
        tgty:= bUnits[i].y+Around[ligne,j,1];
        //check inside -1 ....
        if  bPath.Inside(tgtx,tgty) then
        if  bPath.HexMove[tgtx,tgty] then
        if bUnits[i].n > n
        then
        begin
          msid1:=j +CrFightSO -1;
          bTgt:= i;
          break;
        end;
      end; // end for j
    end;
  end; // end for i
end;
{----------------------------------------------------------------------------}
procedure SearchClosest;
var
  i,j,n,p:integer;
begin
  n:= 0;
  bTgt:=-1;
  for i:= (1-bSide)*21 to (1-bSide)*21+20 do
  begin
    if bUnits[i].n > 0 then
    begin
      if bUnits[i].n  > n then
      begin
        bTgt:= i;
        n:= bUnits[bTgt].n ;
      end;
    end;
  end;

  n:=abs(bUnits[bTgt].x-bUnits[bId].x)+abs(bUnits[bTgt].y-bUnits[bId].y);
  for i:= 0 to Max_BaX do
  begin
    for j:= 0 to Max_BaY do
    begin
      if bPath.HexMove[i,j]=true then
      begin
        p:=abs(bUnits[bTgt].x-i)+abs(bUnits[bTgt].y-j);
        if (p < n)  then
        begin
          n:= p;
          tgtx:= i;
          tgty:= j;
        end;
      end
    end;
  end;
end;
{----------------------------------------------------------------------------}
begin
  cmd_BA_Log('   '+iCrea[bUnits[Id].t].name +' cpu turn');
  bTgt:=-1;

  // try to shot remote crea if shot>0 and no contact
  if (bUnits[bId].shot > 0)  and not(bPath.contact(bId))
  then
  begin
    SearchShot;
    if bTgt > -1
    then bAction:=bActionShot;
  end
  // cannot shoot
  else
  begin
    SearchCombat;
    if bTgt> -1
    then cmd_BA_MoveTo(bUnits[bTgt].x,bUnits[bTgt].y,msId1)
    else
    SearchClosest;
    //search the best creature to move closer to it

    if bTgt=-1
      then
      begin
      bUnits[bId].state:=UN_DONE;   //clicdef    ???
      bState:=bsNext;
      end
      else
        if isFlyCR(bId)
        then cmd_BA_MoveTo(tgtx,tgty,CrFly)
        else cmd_BA_MoveTo(tgtx,tgty,CrWalk)
  end;
end; // end of if can shoot

{----------------------------------------------------------------------------}
procedure cmd_BA_AutoBattle;
var
  atkForce, defForce: integer;
  cid,cqty: integer;
  i: integer;
begin
  atkForce:=0;
  for i:=0 to MAX_ARMY do
  begin
     cid:=bUnits[i].t;
     cqty:=bUnits[i].n ;
     if cid > -1
     then atkForce:=atkForce + iCrea[cid].atk * cqty;
  end;
  defForce:=0;
  for i:=21 to 21+MAX_ARMY do
  begin
    cid:=bUnits[i].t;
    cqty:=bUnits[i].n;
    if cid > -1
    then defForce:=defForce+  + iCrea[cid].def* cqty;
  end;
  bWinLEFT:= (atkForce > defForce);
  bWinLEFT:=true; //TODO remove when nodebugging easy win by att
  if bWinLEFT
  then
  begin
    for i:=0 to MAX_ARMY do bUnits[21+i].n:=0;
    cmd_BA_Log('Attacker '+ mHeros[bHeroLEFT].name + ' WIN');
    cmd_BA_Log('****************************************************');
  end
  else
  begin
    for i:=0 to MAX_ARMY do bUnits[i].n:=0;
    cmd_BA_Log('Defender WIN, losing ' +mHeros[bHeroLEFT].name);
    cmd_BA_Log('****************************************************');
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_Exp;
var
  i: integer;
begin
  if bWinLEFT
  then bSide:=SD_LEFT else bSide:=SD_RIGHT;
  bExp:=0;
  for i:=21*(1-bSide) to 21*(1-bSide)+ MAX_ARMY do
  begin
    if bUnits[i].t > -1 then
      bExp:=bExp+(bUnits[i].n0-bUnits[i].n)* iCrea[bUnits[i].t].hit;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_End;
var
  HE,i, necro,n: integer;
begin
  // lose crea in battle
  for i:=0 to 6 do
  begin
    n:=mHeros[bHeros[SD_LEFT]].Armys[i].n;
    if n > 0 then
    begin
      mHeros[bHeros[SD_LEFT]].Armys[i].n:=bUnits[i].n;
      if bUnits[i].n=0 then
      mHeros[bHeros[SD_LEFT]].Armys[i].t:=-1;
    end;
  end;
  //TODO exp attribution for defender also should be added...
  if bWinLEFT
  then bSide:=SD_LEFT else bSide:=SD_RIGHT;
  HE:=bHeros[bSide];
  if HE > -1 then
  begin
    //reset bonus moral up to next battle....
    mHeros[HE].VisBuoy:=false;
    mHeros[HE].VisRallyFlag:=false;
    Necro:=mHeros[HE].SSK[SK12_Necromancy];
    if Necro > 0 then
    begin
         Necro:=10*(Necro)+
       5*cmd_HE_FindArt(HE,AR054_AmuletoftheUndertaker)+
      10*cmd_HE_FindArt(HE,AR055_VampiresCowl)        +
      15*cmd_HE_FindArt(HE,AR056_DeadMansBoots);
     n:=0;
     for i:=0 to 40 do
       if bUnits[i].t > -1 then
          n:=n+bUnits[i].n0-bUnits[i].n;
     n:=(Necro*n) div 100;
     if n>0 then
       cmd_HE_Addcrea(HE,MO056_Skeleton,n);
    end;


    cmd_HE_AddExp(HE,bExp);
    cmd_BA_Log(mHeros[HE].name + ' get '+ inttostr(bexp) + ' points of exprience');
    // skill to learn spel during battle ?? need to store all cast spells
  end;

  if bSide= SD_LEFT then
  begin
    case mObjs[bObjRIGHT].t of
    OB06_Pandora : begin cmd_BonusPandora(bObjRIGHT);   cmd_OB_DEL(bObjRIGHT); end;
    OB16_CreatureBank :  cmd_BonusBank(bObjRIGHT);
    OB25_DragonUtopia :  cmd_BonusBank(bObjRIGHT);
    OB84_Crypt :         cmd_BonusBank(bObjRIGHT);
    OB98_City :          cmd_CT_annexion(mHeros[HE].pid,bObjRIGHT);
    //OB_Generator....
    else cmd_OB_DEL(bObjRIGHT);
    end;
  end
  else
    cmd_OB_DEL(bObjLEFT);
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_Info(x,y: integer; var s: string);
var
  dsx,dsy: integer;
  mx,my: integer;
  tgt: integer;
  dirCurseur: integer;
begin
  mx:=PosXY2Hex(x,y).x;
  my:=PosXY2Hex(x,y).y;
  DxMouse.mx:=mx;
  DxMouse.my:=my;
  DxMouse.id:=crDef;
  s:='';
  //if bid=-1 then exit; ???

  if ((x<60) and (y < 80))
  then
  begin
    DxMouse.id:=CrBaHero;
    s:= 'ATT Hero ' + mHeros[bHeroLEFT].name ;
  end;

  if ((x>700) and (y < 80))
  then
  if (bHeroRight >-1) then
  begin
    DxMouse.id:=CrBaHero;
    s:= 'DEF Hero ' + mHeros[bHeroRight].name ;
  end;

  if (y > 560)
    then DxMouse.id:=CrList;

  if bPath.Inside(mx,my) then
  begin
    DxMouse.id:=CrDef;
    s:=format('[%d %d] ', [mx,my]);
    Tgt:=bTiles[mx,my];
    if (mx=10) and (my=5) and (bSide=SD_LEFT) then
    begin
       if (bUnits[bid].t=MO118_Catapult)
         then Tgt:=-2
         else if ((tgt=-1) and not(isBridgePassable)) then tgt:=-2;
    end;
    case Tgt of
        -2 : if bSide=SD_LEFT then
        begin
          if (bUnits[bid].t=MO118_Catapult) and (bWall[my]>0)
          then
          begin
            DxMouse.id:=CrCatapult; // CrBaDesroyWall ?
            s:=format('%s Attack Wall '+ s,[iCrea[bUnits[bid].t].name]);
            bTgt:=my;
          end;
        end;
  {bTiles[11,0]:=-2;
  bTiles[11,1]:=-2;  //7
  bTiles[10,2]:=-2;  //7
  bTiles[10,3]:=-2;  //6
  bTiles[ 9,4]:=-2;  //9
  bTiles[ 9,5]:=-2;  //9 bTiles[ 10,5]:=-2 opening the gate
  bTiles[ 9,6]:=-2;  //9
  bTiles[10,7]:=-2;  //5
  bTiles[10,8]:=-2;  //4
  bTiles[11,9]:=-2;  //4
  bTiles[11,10]:=-2;
1. background wall,     TPWL
2. keep,                MAN1
3. bottom tower,        TW11
4. bottom wall,         WA11
5. wall below gate,     WA31
6. wall over gate,      WA41
7. upper wall,          WA61
8. upper tower,         TW21
9. gate,                DRW2 W1 descending / W2 open / W3 damaged
10. gate arch,          ARCH
11. bottom static wall, WA2
12. upper static wall,  WA5
13. moat,               MOAT
14. mlip,               MLIP
15. keep turret cover,  MANC
16. lower turret cover, TW1C
17. upper turret cover  TW2C}


        -1    :
          if not(bState=bsSpell) then
          begin
          s:=s+ ' noUnit';
          if bPath.HexMove[mx,my] then
          begin
            if isFlyCR(bId)
            then
            begin
               DxMouse.id:=CrFly;
               s:=format('Fly %s here ' + s, [iCrea[bUnits[bId].t].name]);
            end
            else
            begin
               DxMouse.id:=CrWalk;
               s:=format('Move %s here ' + s, [iCrea[bUnits[bId].t].name]);
            end;
          end;
        end;
        0..20 :
        begin
          if bSide=SD_RIGHT then
          begin
            DxMouse.id:=CrBafight;
            s:=format('%s Attack %s'+ s,[iCrea[bUnits[bid].t].name, iCrea[bUnits[Tgt].t].name]);
          end;
          if bSide=SD_LEFT then
          begin
            DxMouse.id:=CrInfo;
            s:=format('View %s Info '+ s,[iCrea[bUnits[tgt].t].name]);
          end;
        end;
        21..41:
        begin
          if (bSide=SD_LEFT) and (bUnits[bid].t<>MO118_Catapult) then
          begin
            DxMouse.id:=CrBafight;
            s:=format('%s Attack %s'+ s,[iCrea[bUnits[bid].t].name, iCrea[bUnits[Tgt].t].name]);
          end;
          if (bSide=SD_RIGHT) or (bUnits[bid].t=MO118_Catapult) then
          begin
            DxMouse.id:=CrInfo;
            s:=format('View %s Info '+ s,[iCrea[bUnits[tgt].t].name]);
          end;
        end;
    end;

    if bState=bsSpell
    {Combat is the concatenation of these value
    ADV_SPELL=1;
    COMBAT_SPELL=2;
    CREATURE_SPELL=4;
    CREATURE_TARGET=8;
    CREATURE_TARGET_1=16; //(rem spel effect)
    CREATURE_TARGET_2=32;
    LOCATION_TARGET=64;
    OBSTACLE_TARGET=64;
    MIND_SPELL=256; }
    then
    begin
      s:='Select spell target';
      if Tgt > -1 then s:=iCrea[bUnits[Tgt].t].name + ' ' + format('[%d %d] ', [mx,my]);
      //TODO refine DxMouse ?
      if (DxMouse.id=CrBafight) and (iSpel[bSpel].effect=-1) then
      begin
        DxMouse.id:=CrSpel;
        s:='Cast ATT spell ' + ispel[bSpel].name + ' on ' + s;
      end;
      if (DxMouse.id=Crinfo) and (iSpel[bSpel].effect=1) then
      begin
        DxMouse.id:=CrSpel;
       s:='Cast Bonus spell ' + iSpel[bSpel].name + ' on ' + s;
      end;
      if (DxMouse.id=CrDef) and (iSpel[bSpel].loc)then
      begin
        DxMouse.id:=CrSpel;
       s:='Cast Locaton spell ' + iSpel[bSpel].name + ' on ' + s;
      end;
    end;

    if DxMouse.id=CrBafight then
      if ((bUnits[bId].shot > 0) and (bPath.contact(bid)=false))   OR (bUnits[bId].tower > 0)
      then
      begin
      if abs(mx-bUnits[bId].x)+abs(my-bUnits[bId].y) < 6
        then DxMouse.id:=CrFire
        else DxMouse.id:=CrFireMalus;
      end;

    if DxMouse.id=CrBafight
    then
    begin
      DSx:= x-(Hex2PosXY(mx,my).X+21);
      DSy:= y-(Hex2PosXY(mx,my).Y+25);
      if Abs(DSy) < Abs(DSx) then
      begin
        if (DSx > 0) then               //Tx:=mx+1; Ty:=my;
          DirCurseur:= CrFightEE
        else                            //Tx:=mx-1; Ty:=my;
          DirCurseur:= CrFightOO;
      end
      else
      begin
        if (DSy > 0) then
        begin
          if DSx > 0
          then                          //Tx:=mx + (my mod 2); Ty:=my+1;
            DirCurseur:= CrFightSE
          else                          //Tx:=mx-1+(my mod 2); Ty:=my+1;
            DirCurseur:= CrFightSO;
        end
        else
        begin
          if DSx > 0
          then                          //tgtx:= mx  + (my mod 2); tgty:= my-1;
            DirCurseur:= CrFightNE
          else                          //tgtx:= mx-1+ (my mod 2); tgty:= my-1;
            DirCurseur:= CrFightNO;
        end;
      end;  // fin du if Abs (Dsy) < ABs DSX }
      DxMouse.id:=DirCurseur;
    end;
  end;
end;
{----------------------------------------------------------------------------}
function cmd_BA_HitCr(id,dmg:integer): integer;
var
  perte, delta:integer;
begin
  perte:=0;
  with bUnits[id] do
  begin
    if SpelD[SP62_Blind] > 0 then cmd_SP_BonusRemove(SP62_Blind,id);
    hit1:=hit1-dmg;
    if hit1 <=0 then
    begin
      perte:=1 - hit1 div hit0;
      hit1:=hit1 + perte * hit0;
      if n <= perte then
      begin
        perte:=n;
        n:=0;
        state:=UN_Done;
        bTiles[x,y]:=-1;
        if is2HexCR(id) then
        begin
          if side=SD_LEFT then delta:=+1 else delta:=-1;
          bTiles[x+delta,y]:=-1 ;
        end;
        if ((x=9) or (x=10)) and (y=5) then bridgeDestroyed:=true;  //dead on the bridge
      end
      else n:= n - perte;
    end;
  end;
  result:=perte;
end;
{----------------------------------------------------------------------------}
function cmd_BA_DMG_CRtoCR(atId,dfId: integer): integer;
var
  dmg,delta,r: integer;
begin
  // Basic dmg CR to CR
  dmg:=  iCrea[bUnits[atId].t].dmgMin
         + random(1+iCrea[bUnits[atId].t].dmgMax - iCrea[bUnits[atId].t].dmgMin);

  // curse or bless
    //SP41_Bless:         cmd_SP_bonus;  // DGT=MAX +xx          N+0/  B+0 / A+1 / E+1
    //SP42_Curse:         cmd_SP_bonus;  // DGT=MIN -xx          N-0/  B-0 / A-1 / E-1

  if bUnits[AtId].SpelD[SP41_Bless] > 0 then
  begin
    cmd_BA_Log(format('   Bless give MAX Dmg + %d',[bUnits[AtID].SpelE[SP41_Bless]]));
    Dmg:=iCrea[bUnits[atId].t].dmgMax * bUnits[atId].n + bUnits[AtID].SpelE[SP41_Bless];
  end;

  if bUnits[AtId].SpelD[SP42_Curse] > 0 then
  begin
    cmd_BA_Log(format('   Curse give 80% MIN Dmg - %d',[bUnits[AtID].SpelE[SP42_Curse]]));
    Dmg:=trunc (80 * (iCrea[bUnits[atId].t].dmgMin * bUnits[atId].n) / 100)  - bUnits[AtID].SpelE[SP42_Curse];
  end;

  // bonus or malus on ATK / DEF difference
  { on fait bonus = A.Att-D.Def
          >0 => dmg = rnd(A.dmg) * (100+5*bonus)/100 (BonusMax=+400%)
          <0 => dmg = rnd(A.dmg) * (100+2*malus)/100 (MalusMax= -30%)  }

  Delta:= bUnits[atId].atk1 - bUnits[dfId].Def1;

  if (Delta > 0) then
  begin
    if (Delta > 80) then Delta:=80;     // delta = +80 maxi => +40%
    dmg:=round(dmg * bUnits[atId].n * (1+0.05*Delta));
  end
  else
  begin
    if (Delta < -15)  then Delta:=-15;  // delta = -15 maxi   => -30%
    dmg:=round(dmg * bUnits[atId].n * (1+0.02*Delta) );
  end;

  cmd_BA_Log(format('   Initial DMG %d',[dmg]));

  // luck effect
  // doublebonus  luck = rnd(100) < 4.2 H.luck (1 2 3) => 2*dmg

  r:=Random(240);
  if r < 10 * bUnits[atId].luck1 then
  begin
    Dmg:= Dmg+Dmg;
    cmd_BA_Log('   Luck effect: '+ iCrea[bUnits[atId].t].name +' do Double Dmg');
  end;

  result:=dmg;

end;
{----------------------------------------------------------------------------}
procedure cmd_BA_DMG_HandAttak(HE,bAtk: integer; var dmg:integer);
var
  bonus: integer;
begin
  //offence
  //        => +10% Offence Skill   et +5% Offence speciality  * level
  //si cavalier/champion : jouting bonus
  //        => 5% Hex travelle

  // SKILL PART: offense effect
  bonus:=10* mHeros[HE].SSK[SK22_Offence];
  if (mHeros[HE].specSK=SS00_Sklll) and (mHeros[HE].specSKP=SK22_Offence) then
  bonus:= round(bonus * (1+ 5/100 * mHeros[HE].level));
  if bonus > 0 then
  begin
    dmg:=round( dmg*(1+ bonus / 100 ));
    cmd_BA_Log('   Offence skill effect: ' + inttostr(bonus) +'% on dmg per level on hand attack');
  end;

  // UNIT PART: jouting bonus
  if ((bUnits[bAtk].t=MO011_Cavalier) or (bUnits[bAtk].t=MO012_Champion)) then
  if bUnits[bAtk].HexTravelled > 0 then
  begin
    dmg:= Round(( 1+ 0.05*bUnits[bid].HexTravelled) * dmg);
    cmd_BA_Log('   Cavalier/Champion Jouting effect: ' + ' do 5% Dmg per HEX');
    bUnits[bAtk].HexTravelled:=0;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_DMG_ShotAttak(HE,bAtk,bDef: integer; var dmg:integer);
var
  bonus,r: integer;
begin
  // MACHINE PART:
  if (bUnits[bAtk].t=MO118_Catapult) then
  begin
    r:=random(100);
    if r >  (100 - 25* mHeros[HE].SSK[SK20_Artillery]) then
    begin
      Dmg:= 2* Dmg;
      cmd_BA_Log('   Artillery Skill effect: ' + ' do Double Dmg');
    end;
    exit;
  end;

  if (bUnits[bAtk].t=MO119_Ballista)  then
  begin
    if (mHeros[HE].SSK[SK10_Ballistics] > 1) then
    begin
      Dmg:= 2* Dmg;
      cmd_BA_Log('   Ballistic Skill effect: ' + ' do Double Dmg');
    end;
    exit;
  end;

  // CREATURE PART

  // Penalty of ditance : dmg div 2
  // no penalty of ditance : AR091_GoldenBow
  if abs(bUnits[bAtk].x-bUnits[bDef].x)+abs(bUnits[bAtk].y-bUnits[bDef].y) > 6 then
  begin
    if cmd_HE_FindArt(HE,AR060_BowofElvenCherrywood) < 0 then
    cmd_BA_Log('   Shoot with distnace peanity : do Half Dmg');
    dmg:= dmg div 2;
  end;

  // SKILL PART: archery effect
  // 5%  Hero level * Archery bonus
  case  mHeros[HE].SSK[SK01_Archery] of
    1: bonus:= 10;
    2: bonus:= 15;
    3: bonus:= 25;
    else bonus:=0;
  end;

  if (mHeros[HE].specSK=SS00_Sklll) and (mHeros[HE].specSKP=SK01_Archery) then
  bonus:= round(bonus * (1+ 5/100 * mHeros[HE].level));

  if bonus > 0 then
  begin
     //ART bonus
     bonus:=bonus
      + 5*cmd_HE_FindArt(HE,AR060_BowofElvenCherrywood)
      + 10*cmd_HE_FindArt(HE,AR061_BowstringoftheUnicornsMane)
      + 15*cmd_HE_FindArt(HE,AR062_AngelFeatherArrows);
    dmg:=trunc((100+bonus) * dmg / 100);
    cmd_BA_Log('   Archery Skill effect + Artefact add ' + inttostr(bonus)+ ' % of dmg');
  end;

  // SPELL PART:
  //onShotATT   DGT on DEF N75%/ B75%/ A50%/ E50%
  if bUnits[bDef].SpelD[SP28_AirShield] > 0 then
  begin
    cmd_BA_Log(format('   Air Shield Reduces Shot Dmg by %d %%',[bUnits[bDef].SpelE[SP28_AirShield]]));
    dmg:=trunc((dmg * bUnits[bDef].SpelE[SP28_AirShield]) / 100);
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_DMG_CastAttak(HE,bDef: integer; var dmg:integer);
var
  bonus : integer;
begin
  // Apply dmg according to speLl level
  case bSpelLevel  of
    0 : dmg:=iSpel[bspel].BAS.effect;
    1:  dmg:=iSpel[bspel].NOV.effect;
    2:  dmg:=iSpel[bspel].EXP.effect;
    3:  dmg:=iSpel[bspel].MAS.effect;
  end;
  // add power of Hero
  dmg:=dmg+ iSpel[bspel].pow*mHeros[HE].PSKB.pow ;

  cmd_BA_Log(format('   Initial Spell DMG %d',[Dmg]));

  //SKILL BONUS
  bonus:=mHeros[HE].SSK[SK25_Sorcery];
  if (mHeros[HE].specSK=SS00_Sklll) and (mHeros[HE].specSKP=SK25_Sorcery) then
  bonus:= round (bonus * (1+ 5/100* mHeros[HE].level));
  if bonus > 0 then
  begin
    dmg:=round( dmg*(1+ bonus / 100 ));
    cmd_BA_Log('   Sorcery Skill effect: do ' + inttostr(bonus) +' %  on DMG');
  end;

  //ART BONUS
  case iSpel[bspel].school of
    0: if cmd_HE_FindArt(HE,AR079_OrboftheFirmament) > 0     then  dmg:=trunc(1.50* dmg);
    1: if cmd_HE_FindArt(HE,AR080_OrbofSilt)> 0              then  dmg:=trunc(1.50* dmg);
    2: if cmd_HE_FindArt(HE,AR081_OrbofTempestuousFire) > 0  then  dmg:=trunc(1.50* dmg);
    3: if cmd_HE_FindArt(HE,AR082_OrbofDrivingRain) > 0      then  dmg:=trunc(1.50* dmg);
  end;

  // SPELL BONUS
  case iSpel[bSpel].school of
    0:if bUnits[bDef].SpelD[SP30_ProtFromAir] > 0 then
    begin
      cmd_BA_Log(format('   Reduce Air spel Dmg by %d %%',[bUnits[bDef].SpelE[SP30_ProtFromAir]]));
      dmg:=(dmg * bUnits[bDef].SpelE[SP30_ProtFromAir]) div 100;
    end;
    1:if bUnits[bDef].SpelD[SP31_ProtFromFire] > 0 then
    begin
      cmd_BA_Log(format('   Reduce Fire spel Dmg by %d %%',[bUnits[bDef].SpelE[SP31_ProtFromFire]]));
      dmg:=(dmg * bUnits[bDef].SpelE[SP31_ProtFromFire]) div 100;
    end;
    2:if bUnits[bDef].SpelD[SP32_ProtFromWater] > 0 then
    begin
      cmd_BA_Log(format('   Reduce Water spel Dmg by %d %%',[bUnits[bDef].SpelE[SP32_ProtFromWater]]));
      dmg:=(dmg * bUnits[bDef].SpelE[SP32_ProtFromWater]) div 100;
    end;
    3:if bUnits[bDef].SpelD[SP33_ProtFromEarth] > 0 then
    begin
      cmd_BA_Log(format('   Reduce Earth spel Dmg by %d %%',[bUnits[bDef].SpelE[SP33_ProtFromEarth]]));
      dmg:=(dmg * bUnits[bDef].SpelE[SP33_ProtFromEarth]) div 100;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_DMG_Reduction(HE,bDef: integer; var dmg:integer);
var
  bonus: integer;
begin
//SP27_Shield:        cmd_SP_bonus; //onHandATT   DGT on DEF N75%/ B75%/ A50%/ E50%
//SP28_AirShield:     cmd_SP_bonus; //onShotATT   DGT on DEF N75%/ B75%/ A50%/ E50%
//SP29_FireShield:    cmd_SP_bonus; //onHandATT   DGT to ATT N20%/ B20%/ A25%/ E30%
//-5% Armor   Skill et Armor speciality

  //SKILL bonus
  bonus:= 5*  mHeros[HE].SSK[SK23_Armorer];
  if ((mHeros[HE].specSK=SS00_Sklll) and  (mHeros[HE].specSKP=SK23_Armorer)) then
  bonus:= round( bonus * (1+ 5/100 * mHeros[HE].level));
  if bonus > 0 then
  begin
    dmg:= (dmg * (100 - bonus)) div 100 ;
    cmd_BA_Log('   Armor Skill effect reduce dmg by ' + inttostr(bonus)+ ' %');
  end;


  //SPELL bonus
  if bUnits[bDef].SpelD[SP27_Shield] > 0 then
  begin
    cmd_BA_Log(format('   Shield Spell SP27 Reduces Dmg by %d %%',[bUnits[bDef].SpelE[SP27_Shield]]));
    dmg:=(dmg * bUnits[bDef].SpelE[SP27_Shield]) div 100;
  end;
end;
{----------------------------------------------------------------------------}
function cmd_BA_DMG(bAtk,bDef: integer): integer;
var
  dmg: integer;
  HE: integer;
  s:string;
begin
  dmg:=0;

  HE:=bHeros[Bside]; // bHeroAtk;
  //HE:=bHeros[1-bUnits[bDef].side]; //bizarre de regarder side of crea...

  case bAttak of
    bActionAtt: begin
      s:='DMG Value: '+ iCrea[bUnits[bAtk].t].name + ' do ';
      dmg:=cmd_BA_DMG_CRtoCR(bAtk,bDef);
      cmd_BA_DMG_HandAttak(HE,bAtk,dmg);
      end;
    bActionShot: begin
      s:='DMG Value: '+ iCrea[bUnits[bAtk].t].name + ' do ';
      dmg:=cmd_BA_DMG_CRtoCR(bAtk,bDef);
      cmd_BA_DMG_ShotAttak(HE,bAtk,bDef,dmg);
      end;
    bActionCast: begin
      s:='DMG Value: '+ mHeros[HE].name + ' do ';
      cmd_BA_DMG_CastAttak(HE,bDef,dmg) ;
      end;
  end;

  HE:=bHeros[bUnits[bDef].side];
  cmd_BA_DMG_Reduction(HE,bDef,dmg) ;

  result:=dmg;

  cmd_BA_Log('   '+ s + inttostr(result)+   ' damages.');
end;
{----------------------------------------------------------------------------}
function cmd_BA_Spell_Failure(HE: integer):boolean;
var
  r: integer;
begin
  result:=false;
  r:=random(100);
  case mHeros[HE].SSK[SK26_Resistance] of
    1: if r <= 5  then result:=true;
    2: if r <= 10 then result:=true;
    3: if r <= 20 then result:=true;
  end;
  if result then cmd_BA_Log('   Spell resistance');
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_Spell(SP,bTgt: integer);
var
  atHE:integer;
  dfHE:integer;
  costSpel: integer;
begin
  atHE:=bHeros[bSide];
  dfHE:=bHeros[1-bSide];

  bSpelLevel:=mHeros[atHE].SSK[SK14_Fire_Magic+iSpel[bspel].school];

  case iSpel[SP].school of
    0: if cmd_HE_FindArt(atHE,AR086_TomeofFireMagic) > 0   then  bSpelLevel:=3;
    1: if cmd_HE_FindArt(atHE,AR087_TomeofAirMagic)  > 0   then  bSpelLevel:=3;
    2: if cmd_HE_FindArt(atHE,AR088_TomeofWaterMagic) > 0  then  bSpelLevel:=3;
    3: if cmd_HE_FindArt(atHE,AR089_TomeofEarthMagic) > 0  then  bSpelLevel:=3;
  end;

  //remove some spell point   according to spel level
  case bSpelLevel of
    0: costSpel:=iSpel[SP].BAS.cost;
    1: costSpel:=iSpel[SP].NOV.cost;
    2: costSpel:=iSpel[SP].EXP.cost;
    3: costSpel:=iSpel[SP].MAS.cost;
  end;

  mHeros[atHE].PSKA.ptm:=mHeros[atHE].PSKA.ptm - costSpel; // to change by cost spel

  cmd_BA_Log('   Spell ' + ispel[SP].name + ' Positiveness =' + inttostr(ispel[SP].effect) + ' , combat=' + inttostr(ispel[SP].combat));
  cmd_BA_Log('   Spell ' + ispel[SP].name + ' Cost =' + inttostr(costspel));
  bState:=bsPlay;       //remove sp state an get back to play mode

  if iSpel[SP].effect = -1 then
  if cmd_BA_Spell_Failure(dfHE) then exit;

  case SP of
    SP10_Quicksand:     cmd_SP_createOBJ(SP);
    SP11_LandMine:      cmd_SP_createOBJ(SP);
    SP12_ForceField:    cmd_SP_createOBJ(SP);
    SP13_FireWall:      cmd_SP_createOBJ(SP);

    SP14_Earthquake:    cmd_SP_destroyOBJ(SP);

    SP15_MagicArrow:    cmd_SP_shootDMG(SP);
    SP16_IceBolt:       cmd_SP_shootDMG(SP);
    SP17_LightningBolt: cmd_SP_shootDMG(SP);
    SP18_Implosion:     cmd_SP_shootDMG(SP);
    SP19_ChainLightning:cmd_SP_chainDMG(SP);

    SP20_FrostRing:     cmd_SP_areaDMG(SP,1);       //AREA=+1 except center
    SP21_Fireball:      cmd_SP_areaDMG(SP,1);       //AREA=+1
    SP22_Inferno:       cmd_SP_areaDMG(SP,2);       //AREA=+2
    SP23_MeteorShower:  cmd_SP_areaDMG(SP,1);       //AREA=+1

    SP24_DeathRipple:   cmd_SP_globalDMG(SP);       //CR live
    SP25_DestroyUndead: cmd_SP_globalDMG(SP);       //CR dead
    SP26_Armageddon:    cmd_SP_globalDMG(SP);       //CR all

    SP27_Shield:        cmd_SP_bonus(SP);
    SP28_AirShield:     cmd_SP_bonus(SP);
    SP29_FireShield:    cmd_SP_bonus(SP);
    SP30_ProtFromAir:   cmd_SP_bonus(SP);
    SP31_ProtFromFire:  cmd_SP_bonus(SP);
    SP32_ProtFromWater: cmd_SP_bonus(SP);
    SP33_ProtFromEarth: cmd_SP_bonus(SP);
    SP34_AntiMagic:     cmd_SP_bonus(SP);
    SP35_Dispel:        cmd_SP_bonus(SP);
    SP36_MagicMirror:   cmd_SP_bonus(SP);

    SP37_Cure:          cmd_SP_life(SP);
    SP38_Resurrection:  cmd_SP_life(SP);
    SP39_AnimateDead:   cmd_SP_life(SP);
    SP40_Sacrifice:     cmd_SP_life(SP);

    SP41_Bless:         cmd_SP_bonus(SP);
    SP42_Curse:         cmd_SP_bonus(SP);
    SP43_Bloodlust:     cmd_SP_bonus(SP);
    SP44_Precision:     cmd_SP_bonus(SP);
    SP45_Weakness:      cmd_SP_bonus(SP);
    SP46_StoneSkin:     cmd_SP_bonus(SP);
    SP47_DisruptingRay: cmd_SP_bonus(SP);
    SP48_Prayer:        cmd_SP_bonus(SP);
    SP49_Mirth:         cmd_SP_bonus(SP);
    SP50_Sorrow:        cmd_SP_bonus(SP);
    SP51_Fortune:       cmd_SP_bonus(SP);
    SP52_Misfortune:    cmd_SP_bonus(SP);
    SP53_Haste:         cmd_SP_bonus(SP);
    SP54_Slow:          cmd_SP_bonus(SP);
    SP55_Slayer:        cmd_SP_bonus(SP);
    SP56_Frenzy:        cmd_SP_bonus(SP);
    SP57_TitansLightningBolt:  cmd_SP_bonus(SP);
    SP58_Counterstrike: cmd_SP_bonus(SP);
    SP59_Berserk:       cmd_SP_bonus(SP);
    SP60_Hypnotize:     cmd_SP_bonus(SP);
    SP61_Forgetfulness: cmd_SP_bonus(SP);
    SP62_Blind:         cmd_SP_bonus(SP);

    SP63_Teleport:      cmd_SP_move(SP);

    SP64_RemoveObstacle:cmd_SP_destroyOBJ(SP);

    {SP65_Clone:         cmd_SP_summon(SP);
    SP66_FireElemental: cmd_SP_summon(SP);
    SP67_EarthElemental:cmd_SP_summon(SP);
    SP68_WaterElemental:cmd_SP_summon(SP);
    SP69_AirElemental:  cmd_SP_summon(SP); }

  end;
end;

{----------------------------------------------------------------------------}
procedure cmd_SP_CreateOBJ(SP:integer);
begin
  cmd_BA_Log('   Spell ' + ispel[SP].name + ' = create OBJ');
end;
{----------------------------------------------------------------------------}
procedure cmd_SP_DestroyOBJ(SP:integer);
begin
  cmd_BA_Log('   Spell ' + ispel[SP].name +  ' = destroy OBJ');
end;
{----------------------------------------------------------------------------}
procedure cmd_SP_ShootDMG(SP:integer);
begin
  cmd_BA_Log('   Spell ' + ispel[SP].name + ' = shoot DMG');
  cmd_BA_AttackCAST(bTgt,100);
end;
{----------------------------------------------------------------------------}
procedure cmd_SP_AreaDMG(SP:integer;r: integer);
var
  nbunits,u, dist : integer;
  start_hex, hex  : TPoint;
begin
  cmd_BA_Log('   Spell ' + ispel[SP].name + ' = AREA DMG');
  //find the tgt crea within the range and apply same damage for all

  // find all units in the trange od mx/my
  start_hex := Point(DxMouse.sX,DxMouse.sY);
  nbunits:=0;
  for u:=0 to 41 do
  begin
    if (bUnits[u].t=-1) or (bUnits[u].n=0)
    then continue;
    hex:=  Point(bUnits[u].x,bUnits[u].y)  ;
    dist:= bPath.distance(start_hex, hex) ;
    if (dist = 0) and (SP=SP20_FrostRing)
    then continue;
    if dist <= r
    then
    begin
      bUnitID_Chain[nbUnits]:=u;
      inc(nbUnits);
      continue
    end;
    if  is2HexCR(u) then   begin
    if Bunits[u].dirleft
    then hex:=  Point(bUnits[u].x-1,bUnits[u].y)
    else hex:=  Point(bUnits[u].x+1,bUnits[u].y)  ;
    dist:= bPath.distance(start_hex, hex) ;
    if (dist = 0) and (SP=SP20_FrostRing)
    then continue;
    if dist <= r
    then
    begin
      bUnitID_Chain[nbUnits]:=u;
      inc(nbUnits);
      continue
    end;
    end;
  end;

  cmd_BA_Log('   Spell ' + ispel[SP].name + ' = RANGEDMG');
  for u:=0 to nbUnits-1 do
  begin
    begin
      bTgt:=bUnitID_Chain[u];
      cmd_BA_Log( format('chain %d %d %d, %s'  , [u, bTgt, bunits[btgt].t, iCRea[bunits[btgt].t].name]) );
      cmd_BA_AttackCAST(bTgt,100);
    end;
  end;

end;
{----------------------------------------------------------------------------}
procedure cmd_SP_ChainDMG_Prepare(SP:integer);
var
  nbunits, u,v : integer;
  start_id ,
  old_next, old_next_id,
  next,     next_id,     next_distance,
                 id,     distance :integer;
  start_hex, next_hex, hex: TPoint;


begin
  cmd_BA_Log('   Spell Prepare ' + ispel[SP].name + ' = Chain DMG');

  // starting unit in chain
  bUnitID_Chain[0]:=btgt;

  // find all units and place them in chain
  nbunits:=1;
  for u:=0 to 41 do
  begin
      if (bUnits[u].t=-1) or (bUnits[u].n=0)
      then continue;
      if u = btgt
      then continue;
      bUnitID_Chain[nbUnits]:=u;
      inc(nbUnits);
  end;

  bUnitNb_Chain:= min(4,nbUnits-1);

  for u:=1 to bUnitNb_Chain do
  begin
    start_id:=bUnitID_Chain[u-1];
    start_hex := Point(bUnits[start_id].x,bUnits[start_id].y);
    old_next:=u;
    old_next_id:=bUnitID_Chain[old_next];

    next:=u;
    next_id:=bUnitID_Chain[next];
    next_hex:= Point(bUnits[next_id].x,bUnits[next_id].y) ;
    next_distance:= bPath.distance(start_hex, next_hex);

    for v:=u+1 to nbUnits-1 do
    begin
      id:=bUnitID_Chain[v];
      hex:= Point(bUnits[id].x,bUnits[id].y)  ;
      distance:= bPath.distance(start_hex, hex) ;
      if distance < next_distance
      then begin
        next:=v;
        next_id:= id;
        next_distance:=distance;
      end;
    end;
    bUnitID_Chain[old_next]:=next_id;
    bUnitID_Chain[next]:=old_next_id;
  end;
end;

{----------------------------------------------------------------------------}
procedure cmd_SP_ChainDMG(SP:integer);
var
  u,ratio : integer;
begin
  cmd_BA_Log('   Spell ' + ispel[SP].name + ' = CHAINDMG');
  ratio:=100;
  for u:=0 to bUnitNb_Chain do
  begin
    begin
      bTgt:=bUnitID_Chain[u];
      cmd_BA_Log( format('chain %d %d %d, %s'  , [u, bTgt, bunits[btgt].t, iCRea[bunits[btgt].t].name]) );
      cmd_BA_AttackCAST(btgt,ratio);
      ratio:= ratio div 2;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_SP_GlobalDMG(SP:integer);
var
  i :integer;
begin
  cmd_BA_Log('   Spell ' + ispel[SP].name +  ' = GLOBAL DMG');
  for i:=0 to 41 do
  begin
    if bunits[i].n > 0 then
    begin
      bTgt:=i;
      case SP of
      SP24_DeathRipple:  //CR live
        if isAliveCR(i)  then cmd_BA_AttackCAST(bTgt,100);
      SP25_DestroyUndead: //CR dead
        if isUnDeadCR(i) then cmd_BA_AttackCAST(bTgt,100);
      SP26_Armageddon:   //CR all
        cmd_BA_AttackCAST(bTgt,100);
      end;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_SP_BonusRemove(SP:integer;BU:integer);
begin
  case SP of
    SP46_StoneSkin: begin
      bUnits[BU].def1:=bUnits[BU].def0;
    end;
    SP47_DisruptingRay: begin
      bUnits[BU].def1:=bUnits[BU].def0;
    end;
    SP48_Prayer: begin
      bUnits[BU].def1:=bUnits[BU].def0;
      bUnits[BU].atk1:=bUnits[BU].atk0;
       bUnits[BU].move1:=bUnits[BU].move0;
    end;
    SP49_Mirth: begin
      bUnits[BU].moral1:=bUnits[BU].moral0;
    end;
    SP50_Sorrow: begin
      bUnits[BU].moral1:=bUnits[BU].moral0;
    end;
    SP51_Fortune: begin
      bUnits[BU].luck1:=bUnits[BU].luck0;
    end;
    SP52_Misfortune: begin
      bUnits[BU].luck1:=bUnits[BU].luck0;
    end;
    SP53_Haste:    begin
      bUnits[BU].move1:= bUnits[BU].move0;
      bUnits[BU].moveSP:=-1;
    end;
    SP54_Slow:     begin
      bUnits[BU].move1:=bUnits[BU].move0;
      bUnits[BU].moveSP:=-1;
    end;
    SP56_Frenzy:   begin
      bUnits[BU].atk1:=bUnits[BU].atk0;
      bUnits[BU].def1:=bUnits[BU].def0;
      bUnits[BU].atkSP:=-1;
      bUnits[BU].defSP:=-1;
    end;
    SP62_Blind:    begin
      bUnits[BU].move1:=bUnits[BU].move0;
      bUnits[BU].State:=UN_READY;
    end;

  end;
  bUnits[BU].SpelD[SP]:=0;
end;
{----------------------------------------------------------------------------}
procedure cmd_SP_Bonus(SP:integer);
var
  effect: integer;
begin
  cmd_BA_Log('   Spell ' + ispel[SP].name +  ' = BONUS/MALUS added to CREA');
  // check mHeros[bAttHero].school Expert to apply MAS effect
  bUnits[bTgt].SpelD[bSpel]:=3;
  case bSpelLevel  of
    0 : effect:=iSpel[bspel].BAS.effect;
    1:  effect:=iSpel[bspel].NOV.effect;
    2:  effect:=iSpel[bspel].EXP.effect;
    3:  effect:=iSpel[bspel].MAS.effect;
  end;
  case SP of
    SP27_Shield,
    SP28_AirShield,
    SP29_FireShield,
    SP30_ProtFromAir,
    SP31_ProtFromFire,
    SP32_ProtFromWater,
    SP33_ProtFromEarth: begin
      bUnits[bTgt].SpelE[SP]:= effect;
    end;
    SP46_StoneSkin: begin
      bUnits[bTgt].def1:=bUnits[bTgt].def0+effect;
    end;
    SP47_DisruptingRay: begin
      bUnits[bTgt].def1:=MAX(bUnits[bTgt].def1-effect,0);
    end;
    SP48_Prayer: begin
      bUnits[bTgt].def1:=bUnits[bTgt].def0+effect;
      bUnits[bTgt].atk1:=bUnits[bTgt].atk0+effect;
      bUnits[bTgt].move1:=bUnits[bTgt].move0+effect;
    end;
    SP49_Mirth: begin
       bUnits[bTgt].moral1:=bUnits[bTgt].moral0+effect;
    end;
    SP50_Sorrow: begin
       bUnits[bTgt].moral1:=MAX(bUnits[bTgt].moral0-effect,0)
    end;
    SP51_Fortune: begin
       bUnits[bTgt].luck1:=bUnits[bTgt].luck0+effect;
    end;
    SP52_Misfortune: begin
       bUnits[bTgt].luck1:=MAX(bUnits[bTgt].luck0-effect,0);
    end;
    SP53_Haste:    begin
       bUnits[bTgt].move1:=bUnits[bTgt].move0+effect;
    end;
    SP54_Slow:     begin
       bUnits[bTgt].move1:=(effect *bUnits[bTgt].move0) div 100;
    end;
    SP56_Frenzy:   begin
       bUnits[bTgt].atk1:=bUnits[bTgt].atk0+(effect*bUnits[bTgt].def0) div 100;
       bUnits[bTgt].def1:=0;
    end;
    SP62_Blind:    begin
       bUnits[bTgt].move1:=0;
       bUnits[bTgt].State:=UN_DONE;
    end;
  end;
  {
SP27_Shield:        cmd_SP_bonus; //onHandATT   DGT on DEF N75%/ B75%/ A50%/ E50%
SP28_AirShield:     cmd_SP_bonus; //onShotATT   DGT on DEF N75%/ B75%/ A50%/ E50%
SP29_FireShield:    cmd_SP_bonus; //onHandATT   DGT to ATT N20%/ B20%/ A25%/ E30%
SP30_ProtectionfromAir:   cmd_SP_bonus;//onMagAirATT  DGT on DEF N70%/ B70%/ A50%/ E50%
SP31_ProtectionfromFire:  cmd_SP_bonus;//onMagFirATT  DGT on DEF N70%/ B70%/ A50%/ E50%
SP32_ProtectionfromWater: cmd_SP_bonus;//onMagWtrATT  DGT on DEF N70%/ B70%/ A50%/ E50%
SP33_ProtectionfromEarth: cmd_SP_bonus;//onMagEarATT  DGT on DEF N70%/ B70%/ A50%/ E50%
SP34_AntiMagic:     cmd_SP_bonus;  //Min SPELL level       N4  / B4  / A5  / E6 (no speel)
SP35_Dispel:        cmd_SP_bonus;  //Cancel SPELL         N1CRa/B1CRa/A1CRx/ EallCR
SP36_MagicMirror:   cmd_SP_bonus;  //onMagATT  DGT to Enmy N20%/ B20%/ A30%/ E40%

SP41_Bless:         cmd_SP_bonus;  // DGT=MAX +xx          N+0/  B+0 / A+1 / E+1
SP42_Curse:         cmd_SP_bonus;  // DGT=MIN -xx          N-0/  B-0 / A-1 / E-1
SP43_Bloodlust:     cmd_SP_bonus;  // HandATT  ATT+xxx     N+3/  B+3 / A+6 / E all +3 ?
SP44_Precision:     cmd_SP_bonus;  // ShotATT  ATT+xxx     N+3/  B+3 / A+6 / E all +6 ?
SP45_Weakness:      cmd_SP_bonus;  // HandATT  ATT-xxx     N-3/  B-3 / A-6 / E all -6 ?
SP46_StoneSkin:     cmd_SP_bonus;  // DEF +xxx             N+3/  B+3 / A+6 / E all +6 ?
SP47_DisruptingRay: cmd_SP_bonus;  // DEF -xxx  (cumul..)  N-3/  B-3 / A-4 / E-5
SP48_Prayer:        cmd_SP_bonus;  // ATT/DEF/SPEED +xx    N+2/  B+2 / A+4 / E all +4 ?
SP49_Mirth:         cmd_SP_bonus;  // MORAL                N+1/  B+1 / A+2 / E all +2 ?
SP50_Sorrow:        cmd_SP_bonus;  // MORAL                N-1/  B-1 / A-2 / E all -2 ?
SP51_Fortune:       cmd_SP_bonus;  // CHANCE               N+1/  B+1 / A+2 / E +3 ou all +2 ?
SP52_Misfortune:    cmd_SP_bonus;  // CHANCE               N-1/  B-1 / A-2 / E all -2 ?
SP53_Haste:         cmd_SP_bonus;  // SPEED +xx            N+3/  B+3 / A+5 / E all +5 ?
SP54_Slow:          cmd_SP_bonus;  // SPEED %              N75%/ B75%/ A50%/ E50%
SP55_Slayer:        cmd_SP_bonus;  // AATT+8 on kingX      NK1 / BK1 / AK12/ EK123
SP56_Frenzy:        cmd_SP_bonus;  // ATT= ATT+ x% of DEF  N100/ B100/ A150/ E200   DEF=0
SP57_TitansLightningBolt:  cmd_SP_bonus; //unused

SP58_Counterstrike: cmd_SP_bonus;  //REPLy +xx             N+1 / B+1 /A+2  /E+2
SP59_Berserk:       cmd_SP_bonus;  //Frenesei a HEX+x      N 1 / B 1 / A 7 / E 19
SP60_Hypnotize:     cmd_SP_bonus;  //if Life <25+Pwr +x    N 10/ B 10/ A 20/ E 50
SP61_Forgetfulness: cmd_SP_bonus;  //nb CREA forget shoot  N50%/ B50%/ A100%/ E all
SP62_Blind:         cmd_SP_bonus;  //blind et %ATT 1reply  N50%/ B50%/ A25%/ E0%
}
end;
{----------------------------------------------------------------------------}
procedure cmd_SP_Life(SP:integer);
//SP37_Cure:          cmd_SP_life;   //Cancel -SPELL + life  N10 / B10 / A20 / E30
//SP38_Resurrection:  cmd_SP_life;   // +life pts            N40 / B40 / A80 / E160
//SP39_AnimateDead:   cmd_SP_life;   // +life pts on dead    N30 / B30 / A60 / E160
//SP40_Sacrifice:     cmd_SP_life;   // +life pts per unit   N+3/  B+3 / A+6 / E+10
var
  effect: integer;
begin
  cmd_BA_Log('   Spell ' + ispel[SP].name + ' = LIFE gift to CREA');
  case bSpelLevel  of
    0 : effect:=iSpel[bspel].BAS.effect;
    1:  effect:=iSpel[bspel].NOV.effect;
    2:  effect:=iSpel[bspel].EXP.effect;
    3:  effect:=iSpel[bspel].MAS.effect;
  end;
  case SP of
    SP37_Cure: begin
      bUnits[bTgt].hit1:=max(bUnits[bTgt].hit1+effect,bUnits[bTgt].hit0);
    end;
    SP38_Resurrection: begin
      bUnits[bTgt].hit1:=max(bUnits[bTgt].hit1+effect,bUnits[bTgt].hit0);
    end;
    SP39_AnimateDead: begin
      bUnits[bTgt].hit1:=max(bUnits[bTgt].hit1+effect,bUnits[bTgt].hit0);
    end;
    SP40_Sacrifice: begin
      bUnits[bTgt].hit1:=max(bUnits[bTgt].hit1+effect,bUnits[bTgt].hit0);
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_SP_Move(SP:integer);
begin
  cmd_BA_Log('   Spell ' + iSpel[SP].name + ' = MOVE CREA');
end;
{----------------------------------------------------------------------------}
function cmd_SP_Summon(SP:integer): integer;
var
  i,j, x, y:integer;
begin
  cmd_BA_Log('   Spell ' + iSpel[SP].name + ' = CREATE CREA');
  x:=0;

  for y:=0 to 11 do
    if bTiles[x,y] = -1 then break;
  for i:=16 downto 7 do
    if bunits[i].t=20 then break;   //TODO better empty summon crea slot

  bUnits[i].x:=x;
  bUnits[i].y:=y;
  with bUnits[i] do
  begin
    case SP of
      SP69_AirElemental:
      begin
        t:=MO112_AELEM;
        n:=mHeros[bHeroLEFT].PSKB.pow*(1+ mHeros[bHeroLEFT].ssk[SK15_Air_Magic]);
      end;
      SP67_EarthElemental:
      begin
        t:=MO113_EELEM;
        n:=mHeros[bHeroLEFT].PSKB.pow*(1+ mHeros[bHeroLEFT].ssk[SK17_Earth_Magic]);
      end;
      SP66_FireElemental:
      begin
        t:=MO114_FELEM;
        n:=mHeros[bHeroLEFT].PSKB.pow*(1+ mHeros[bHeroLEFT].ssk[SK14_Fire_Magic]);
      end;
        SP68_WaterElemental:
      begin
        t:=MO115_WELEM;
        n:=mHeros[bHeroLEFT].PSKB.pow*(1+ mHeros[bHeroLEFT].ssk[SK16_Water_Magic]);
      end;
    end;

    side:=SD_LEFT;
    AnimType:=cAnimStand;
    AnimPos:=0;
    AnimCount:=iCrea[t].AnimList[1].Count;
    Animlist:=@iCrea[t].AnimList;
    n0:=n;
    atk0:=iCrea[t].atk + mHeros[bHeroLEFT].PSKB.att;
    def0:=iCrea[t].def + mHeros[bHeroLEFT].PSKB.def;
    move0:=iCrea[bUnits[i].t].speed ; //+ bonusSpeed;
    cmd_BA_HeroSpecialCR(bHeroLEFT,t,i);
    atk1:=atk0;
    def1:=def0;
    move1:=move0;
    luck0:=mHeros[bHeroLEFT].luck; //+mHeros[HE].SSK[SK09_Luck] // already applied in HE luck
    luck1:=luck0;
    moral1:=mHeros[bHeroLEFT].moral+mHeros[bHeroLEFT].SSK[SK06_LeaderShip];
    moral1:=moral0;
    HexTravelled:=0;
    state:=UN_READY;
    for j:=0 to MAX_SPEL -1 do
    begin
      spelD[j]:=0;
      spelE[j]:=0;
    end;
    reply:=true;
    shot:=iCrea[t].shots;
    hit0:=iCrea[t].hit; //+bonuslife;
    hit1:=hit0;
    dirLeft:=false;
    bTiles[x,y]:=i;
    if is2HexCR(i) then bTiles[x+1,y]:=i;
    cmd_BA_Log(format('* Add Summoned Attacker %d [%d,%d]: %d %s',[i,x,y, n,iCrea[t].name]));
  end;
  result:=i;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_Attack(bAttakType:integer);
begin
  bAttak:=bAttakType;
  case  bAttak of
    bActionAtt:  cmd_BA_AttackHAND;
    bActionShot: cmd_BA_AttackSHOT;
    bActionCast: cmd_BA_AttackCast(btgt, 100);
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_AttackHAND;
var
  dmg:integer;
  perte:integer;
begin
  bAttak:=bActionAtt;
  dmg:=cmd_BA_DMG(bId,bTgt);
  perte:=cmd_BA_HitCr(bTgt,Dmg);
  //bAction:=bActionNo;
  bAction:=bActionDmg;
  bState:=bsEnd;

  // some crea perished
  if perte > 0  then
  begin
    cmd_BA_Log('   '+ iCrea[bUnits[bid].t].name +' attak and do '
      + Inttostr(Dmg)+ ' damage, '
      + InttoStr(Perte) + ' ' + iCrea[bUnits[bTgt].t].name + ' perished' );
      bUnits[bTgt].AnimType:=cAnimDmg; //Def;
  end;

  if bUnits[bTgt].n > 0 then
  begin
    if bUnits[bTgt].Reply  then
    begin
       bState:= bsReply;
       if bUnits[bTgt].t <> 4 then bUnits[bTgt].Reply:= false;
       if IsNoRetaliateCR(bId) then bState:=bsEnd;
       if IsWarMachine(bTgt) then bState:=bsEnd;
       //if bAction=bActionNo then bAction:=bActionReplyAtt;
    end;
  end
  else
  begin
    cmd_BA_Log('   Lose monster:  '+ iCrea[bUnits[bTgt].t].name);
    bAction:=bActionDeath  ;
    bUnits[bTgt].AnimType:=cAnimDeath;
    cmd_BA_NoArmy(bUnits[bTgt].side);
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_AttackWALL;
var
  WallID:integer;
begin
  WallID:=bUnits[-2].y;

  case WallID of
    0,1: begin
    bWall[0]:=Max(bWall[0]-1,0);
    bWall[1]:=Max(bWall[1]-1,0);
    if bWall[1]=0 then bTiles[11,1]:=-1;
    end;

    4: begin
    bWall[4]:=Max(bWall[4]-1,0);
    //bWall[1]:=Max(bWall[1]-1,0);
    if bWall[4]=0 then bTiles[9,4]:=-1;
    end;

    5: begin
    bWall[5]:=Max(bWall[5]-1,0);
    //bWall[1]:=Max(bWall[1]-1,0);
    if bWall[5]=0 then bridgeDestroyed:=true; //bTiles[10,5]:=-1;
    end;

    7: begin
    bWall[7]:=Max(bWall[7]-1,0);
    //bWall[8]:=Max(bWall[1]-1,0);
    if bWall[7]=0 then bTiles[10,7]:=-1;
    end;

    9,10: begin
    bWall[9]:=Max(bWall[9]-1,0);
    bWall[10]:=Max(bWall[10]-1,0);
    if bWall[10]=0 then bTiles[11,10]:=-1;
    end;
  end;

  //if WallID in [1,4,5, 7,10]

  {  bTiles[11,0]:=-2;
  bTiles[11,1]:=-2;
  bTiles[10,2]:=-2;
  bTiles[10,3]:=-2;
  bTiles[ 9,4]:=-2;
  bTiles[ 9,5]:=-2;  //bTiles[ 10,5]:=-2 opening the gate
  bTiles[ 9,6]:=-2;
  bTiles[10,7]:=-2;
  bTiles[10,8]:=-2;
  bTiles[11,9]:=-2;
  bTiles[11,10]:=-2;}
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_AttackSHOT;
var
  dmg:integer;
  perte:integer;
  //SP28_AirShield:     cmd_SP_bonus; //onShotATT   DGT on DEF N75%/ B75%/ A50%/ E50%
begin
  bAttak:=bActionShot;
  dmg:=cmd_BA_DMG(bId,bTgt);
  perte:=cmd_BA_HitCr(bTgt,Dmg);
  //bAction:=bActionNo;
  bAction:=bActionDmg;
  bState:=bsEnd;

  if perte > 0  then
  begin
    cmd_BA_Log('   '+ iCrea[bUnits[bid].t].name +' shoot and do '
      + Inttostr(Dmg)+ ' damage, '
      + InttoStr(Perte) + ' ' + iCrea[bUnits[bTgt].t].name + ' perished' );
      bUnits[bTgt].AnimType:=cAnimDmg; //Def;
    //bAction:=bActionDmg;
  end;

  if bUnits[bTgt].n = 0 then
  begin
    cmd_BA_Log('   Lose monster:  '+ iCrea[bUnits[bTgt].t].name);
    bAction:=bActionDeath  ;
    bUnits[bTgt].AnimType:=cAnimDeath;
    cmd_BA_NoArmy(bUnits[bTgt].side);
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_AttackCast(btgt, ratio: integer);
var
  dmg:integer;
  perte:integer;
//SP30_ProtectionfromAir:   cmd_SP_bonus;//onMagAirATT  DGT on DEF N70%/ B70%/ A50%/ E50%
//SP31_ProtectionfromFire:  cmd_SP_bonus;//onMagFirATT  DGT on DEF N70%/ B70%/ A50%/ E50%
//SP32_ProtectionfromWater: cmd_SP_bonus;//onMagWtrATT  DGT on DEF N70%/ B70%/ A50%/ E50%
//SP33_ProtectionfromEarth: cmd_SP_bonus;//onMagEarATT  DGT on DEF N70%/ B70%/ A50%/ E50%
begin
  bAttak:=bActionCast;
  dmg:= (cmd_BA_DMG(-1,bTgt) * ratio) div 100;
  perte:=cmd_BA_HitCr(bTgt,Dmg);

  bState:=bsEnd;

  if perte > 0  then
  begin
    cmd_BA_Log('   ' +mHeros[bHeroLEFT].name +' cast spel '+iSpel[bspel].name +' and do '
      + Inttostr(Dmg)+ ' damage, '
      + InttoStr(Perte) + ' ' + iCrea[bUnits[bTgt].t].name + ' perished');
    bAction:=bActionDmg;
    bUnits[bTgt].AnimType:=cAnimDmg;
    //bUnits[bTgt].AnimCount:=5;
    //bUnits[bTgt].AnimPos:=0;

  end;

  if bUnits[bTgt].n = 0 then
  begin
    cmd_BA_Log('   Lose monster:  '+ iCrea[bUnits[bTgt].t].name);
    bAction:=bActionDeath  ;
    bUnits[bTgt].AnimType:=cAnimDeath;
    //bUnits[bTgt].AnimCount:=5;
    //bUnits[bTgt].AnimPos:=0;
    cmd_BA_NoArmy(bUnits[bTgt].side);
  end;

  if not( (bAction=bActionDmg) or (bAction=bActionDeath )) then
    bAction:=bActionNo;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_Reply;
var
  dmg,perte :integer;
begin
  dmg:=cmd_BA_DMG(bTgt,bId);
  perte:=cmd_BA_HitCr(bId,Dmg);

  if Perte > 0  then
  begin
    cmd_BA_Log('   '+ iCrea[bUnits[bTgt].t].name +' reply and do ' + Inttostr(Dmg)+ ' damage, '
           + InttoStr(Perte) + ' ' + iCrea[bUnits[bId].t].name + ' perished.');
    if bUnits[bid].n=0 then
    begin
      cmd_BA_Log('   Lose monster:  '+ iCrea[bUnits[bId].t].name);
      cmd_BA_NoArmy(bUnits[bId].side);
      bAction:=bActionReplyDeath ;
      bUnits[bid].animType:= cAnimDeath;
    end
    else
    begin
      bAction:=bActionReplyDmg  ;
      bUnits[bid].animType:= cAnimDmg;
    end;
  end
  else
  begin
    cmd_BA_Log(format('   %s  reply and do %d  damage.',[iCrea[bUnits[bId].t].name,Dmg]));
    bAction:=bActionNo;
  end;
  bState:=bsEnd;
end;

{----------------------------------------------------------------------------}
procedure cmd_BA_FlyTo(x,y:integer);
var
  i,j,x0,y0,x1,Y1: integer;
  tx, delta: integer;
begin
  //if ((bTiles[x,y]<>-1) and (bTiles[x,y]<>bid)) then exit;
  cmd_BA_Log(format('   Flying %s  to [%d,%d]',[iCrea[bUnits[bId].t].name,x,y]));
  if is2HexCR(bId)
  then
  begin
  if bunits[bid].side = SD_Right  then   //dir to left .X   X at the patte
  begin
    if  x >= bUnits[bId].x then if ((btiles[x-1,y]=-1) or  (btiles[x-1,y]=bId)) then tx:=x else tx:=x+1;
    if  x < bUnits[bId].x  then if ((btiles[x+1,y]=-1) or  (btiles[x+1,y]=bId)) then tx:=x+1 else tx:=x;
    x:=tx;
  end
  else     //dir to Right X.   X at the patte
  begin
    if  x >= bUnits[bId].x then if ((btiles[x-1,y]=-1) or  (btiles[x-1,y]=bId)) then tx:=x-1 else tx:=x;
    if  x < bUnits[bId].x  then if ((btiles[x+1,y]=-1) or  (btiles[x+1,y]=bId)) then tx:=x else tx:=x-1;
    x:=tx;
  end;

  end
  else
    tx:=x;

  if bPath.findfly(tx,y)
  then
  begin
  //if  bUnits[bId].x < tx then  bUnits[bId].dirLeft:=false;
  //if  bUnits[bId].x > tx then  bUnits[bId].dirLeft:=true;

  i:=bUnits[bid].x;
  j:=bUnits[bid].y;
  bTiles[i,j]:=-1 ;
  x0:=Hex2PosXY(i,j).x+3;
  y0:=Hex2PosXY(i,j).y;
  x1:=Hex2PosXY(x,y).x+3;
  y1:=Hex2PosXY(x,y).y;
  bproj.x:=x1;
  bproj.y:=y1;
  if x1-x0=0 then
  begin
    bproj.x:=0;
    if y1>y0 then bproj.y:=10 else bproj.y:=-10;
    bActionTime:=abs(y1-y0) div 10;
  end
  else
  begin
    bproj.X:=sign(x1-X0)*abs(round( 10*cos( arctan((y1-y0)/(x1-x0)))));
    bproj.Y:=sign(y1-y0)*abs(round(10*sin(arctan((y1-y0)/(x1-x0)))));
    bActionTime:= abs(round( (x1-x0) / cos( arctan( (y1-y0)/(x1-x0) ) ) /10 ));
  end;
  bTiles[tx,y]:=bId ;
  if is2HexCR(bid) then
    begin
      if bUnits[bid].side=1 then delta:=-1 else delta:=+1;
      bTiles[bUnits[bId].x+delta,bUnits[bId].y]:=-1 ;
      bTiles[x+delta,y]:=bid;
    end;

  bAction:=bActionFly;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_WalkTo(x,y: integer);
var
  tx, delta: integer;
begin
  cmd_BA_Log(format('   Walking %s  to [%d,%d]',[iCrea[bUnits[bId].t].name,x,y]));
  if is2HexCR(bid)
   then
 begin
  if  bunits[bid].side = SD_Right then   //dir to left .X   X at the patte
  begin
    if  x >= bUnits[bId].x then if ((btiles[x-1,y]=-1) or  (btiles[x-1,y]=bId)) then tx:=x else tx:=x+1;
    if  x < bUnits[bId].x  then if ((btiles[x+1,y]=-1) or  (btiles[x+1,y]=bId)) then tx:=x+1 else tx:=x;
    x:=tx;
  end
  else     //dir to Right X.   X at the patte
  begin
    if  x >= bUnits[bId].x then if ((btiles[x-1,y]=-1) or  (btiles[x-1,y]=bId)) then tx:=x-1 else tx:=x;
    if  x < bUnits[bId].x  then if ((btiles[x+1,y]=-1) or  (btiles[x+1,y]=bId)) then tx:=x else tx:=x-1;
    x:=tx;
  end;
  //  if  (x >= bUnits[bId].x) and (bUnits[bid].side=SD_LEFT) then if btiles[x-1,y]=-1 then tx:=x-1 else tx:=x;
  //  if  (x < bUnits[bId].x) and (bUnits[bid].side=SD_RIGHT)  then if btiles[x+1,y]=-1 then tx:=x+1 else tx:=x;
  end
  else
    tx:=x;

  if bPath.findwalk(tx,y)
  then
  begin
    //if  bUnits[bId].x < x then  bUnits[bId].dirLeft:=false ;
    //if  bUnits[bId].x > x then  bUnits[bId].dirLeft:=true;
    bTiles[bUnits[bId].x,bUnits[bId].y]:=-1 ;
    bTiles[tx,y]:=bId ;
    if is2HexCR(bid) then
    begin
      if bUnits[bid].side=SD_RIGHT then delta:=-1 else delta:=+1;
      bTiles[bUnits[bId].x+delta,bUnits[bId].y]:=-1 ;
      bTiles[tx+delta,y]:=bid;
    end;
  bUnits[bId].HexTravelled:=bPath.DstPath;
  bAction:=bActionWalk;
  bActionTime:=7;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_MoveTo(x,y, msId: integer);
begin
  if ((msId=CrList)
   or (msId=crDef))
   or (bAction <> bActionNo)
   or  not(bPath.Inside(x,y)) then exit;

  cmd_BA_Log(format('   Click on [%d,%d] with MouseId=%d',[x,y,msId] ));

  bTgt:=bTiles[x,y];

  if msId=CrSpel then  //HE Spel
  begin
     //bAction:=bActionCast; //      direct cast
     bAction:=bActionSpel;   //      heroes amimation before cast
     bText.add('bActioncast');
     exit
  end;

  if ((msId=CrFire) or (msId=CrFireMalus)) then
  begin
     bAction:=bActionShot;
     bText.add('bActionShot');
     exit;
  end;

  if (msId=CrCatapult) then
  begin
     bAction:=bActionCatapult;
     bText.add('bActionCatapult');
     bunits[-2].x:=x;
     bunits[-2].y:=y;
     exit;
  end;

  case msId of
    CrFightSO: begin if (y mod 2) = 1 then x:=x-1; y:=y+1; end;
    CrFightOO: begin x:=x-1; end;
    CrFightNO: begin if (y mod 2) = 1 then x:=x-1; y:=y-1; end;
    CrFightNE: begin if (y mod 2) = 0 then x:=x+1; y:=y-1; end;
    CrFightEE: begin x:=x+1;  end;
    CrFightSE: begin if (y mod 2) = 0 then x:=x+1; y:=y+1; end;
  end;

  if IsFlyCR(bid)
  then cmd_BA_FlyTo(x,y)
  else cmd_BA_WalkTo(x,y);
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_Ranged;
begin
  cmd_BA_Log('   Reset path ranged of ['+inttostr(bId) + '] ' + iCrea[bUnits[bid].t].name );
  with bPath do
  begin
    Pos.X:=bUnits[bId].x;
    Pos.Y:=bUnits[bId].y;
    Speed:=bUnits[bId].move1;
    ResetMoveHex;
    if IsFlyCR(bId)
    then setFlyHex else setWalkHex;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_HealAtk;
 var
  i:integer;
begin
  //TODO regen crea, use tent,  -1 for speel effect,  propose flee, usedmagic=0
  //TODO take machine de guerre
   {AR003_Catapult
    AR004_Ballista
    AR005_AmmoCart
    todo add skill tent
       mHeros[HE].SSK[SK27_First_Aid]     50PV 75 100
       mHeros[HE].SSK[SK26_Resitance]     5% 10 / 20
    }
  cmd_BA_Log('Next Turn Att, try to restore hit points using First Aid Tent');
  if cmd_HE_findART(bHeroLEFT,AR006_FirstAidTent)> 0 then
  for i:=0 to 20 do
  begin
    if  ((bUnits[i].t< 118) and (bUnits[i].t> -1) and (bUnits[i].n> 0) and (bUnits[i].hit1 < bUnits[i].hit0))
    then
    begin
      bUnits[i].hit1:=bUnits[i].hit0;
      cmd_BA_Log(format('Restore ALL (%d) hit points of [%d] %s ',[bUnits[i].hit0, i,iCrea[bUnits[i].t].name]));
      bTgt:=i;
      bAction:=bActionHeal;
      break;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_NextTurnAtk;
var
  BU,SP:integer;
begin
  cmd_BA_HealAtk;

  for BU:=0 to 20 do
  begin
    if  (bUnits[BU].t>-1)
    then
    with bUnits[BU] do
    begin
      HexTravelled:=0;
      state:=UN_READY;
      Reply:=true;
      for SP:=0 to MAX_SPEL -1 do
      begin
        if spelD[SP]>0 then cmd_SP_BonusApply(SP,BU);
        if spelD[SP]=1 then cmd_SP_BonusRemove(SP,BU);
        spelD[SP]:=MAX(0,spelD[SP] -1);
      end;
      //if bUnits[i].state:=Un02_Def then bUnits[i].Def:=bUnits[i].Def+1 else  bUnits[i].Def
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_HealDef;
var
  i:integer;
begin
  //TODO regen crea, use tent,  -1 for speel effect,  propose flee, usedmagic=0
  //TODO take machine de guerre
   {AR003_Catapult
    AR004_Ballista
    AR005_AmmoCart
    }
  cmd_BA_Log('Next Turn Def, try to restore hit points using First Aid Tent');
  if cmd_HE_findART(bHeroDef,AR006_FirstAidTent)> 0 then
  for i:=21 to 41 do
  begin
    if  ((bUnits[i].t< 118) and (bUnits[i].t> -1) and (bUnits[i].n> 0) and (bUnits[i].hit1 < bUnits[i].hit0))
    then
    begin
      bUnits[i].hit1:=bUnits[i].hit0;
      cmd_BA_Log(format('Restore ALL (%d) hit points of [%d] %s ',[bUnits[i].hit0, i,iCrea[bUnits[i].t].name]));
      bTgt:=i;
      bAction:=bActionHeal;
      break;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_BA_NextTurnDef;
var
  BU,SP:integer;
begin
  if bHeroDef > -1 then cmd_BA_HealDef;

  for BU:=21 to 41 do
  begin
    if  (bUnits[BU].t>-1)
    then
    with bUnits[BU] do
    begin
      HexTravelled:=0;
      state:=UN_READY;
      Reply:=true;
      for SP:=0 to MAX_SPEL -1 do
      begin
        if spelD[SP]>0 then cmd_SP_BonusApply(SP,BU);
        if spelD[SP]=1 then cmd_SP_BonusRemove(SP,BU);
        spelD[SP]:=MAX(0,spelD[SP] -1);
      end;
      //if bUnits[i].state:=UN02_DEF then bUnits[i].Def:=bUnits[i].Def+1 else  bUnits[i].Def
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure cmd_SP_BonusApply(SP,BU: integer);
begin
  case SP of
    SP62_Blind: if bUnits[BU].SpelD[SP62_Blind]> 0 then bUnits[BU].state:=UN_DONE;
  end;
end;
{----------------------------------------------------------------------------}
initialization
begin
  bText:=TSTringlist.Create;
  bPath:=TBaPath.create;
end;
{----------------------------------------------------------------------------}
end.

////////////////////////////////////////////////////////////////////////////////
Évaluation	Chance	%						
-3	1/4	25,0%						
-2	1/8	16,7%						
-1	1/12	8,3%						
0	0	0%						
+1	1/24	4,2%						
+2	1/12	8,3%						
+3	1/8	12,5%


// AR for spell graal machine
AR000_Spellbook=0;
AR001_SpellScroll=1;
AR002_Grail=2;
AR003_Catapult=3;
AR004_Ballista=4;
AR005_AmmoCart=5;
AR006_FirstAidTent=6;
// AR for Pskill
AR007_CentaurAxe=7;                    //PSK +++
AR008_BlackshardoftheDeadKnight=8;
AR009_GreaterGnollsFlail=9;
AR010_OgresClubofHavoc=10;
AR011_SwordofHellfire=11;
AR012_TitansGladius=12;
AR013_ShieldoftheDwarvenLords=13;
AR014_ShieldoftheYawningDead=14;
AR015_BuckleroftheGnollKing=15;
AR016_TargoftheRampagingOgre=16;
AR017_ShieldoftheDamned=17;
AR018_SentinelsShield=18;
AR019_HelmoftheAlabasterUnicorn=19;
AR020_SkullHelmet=20;
AR021_HelmofChaos=21;
AR022_CrownoftheSupremeMagi=22;
AR023_HellstormHelmet=23;
AR024_ThunderHelmet=24;
AR025_BreastplateofPetrifiedWood=25;
AR026_RibCage=26;
AR027_ScalesoftheGreaterBasilisk=27;
AR028_TunicoftheCyclopsKing=28;
AR029_BreastplateofBrimstone=29;
AR030_TitansCuirass=30;
AR031_ArmorofWonder=31;
AR032_SandalsoftheSaint=32;
AR033_CelestialNecklaceofBliss=33;
AR034_LionsShieldofCourage=34;
AR035_SwordofJudgement=35;
AR036_HelmofHeavenlyEnlightenment=36;
AR037_QuietEyeoftheDragon=37;
AR038_RedDragonFlameTongue=38;
AR039_DragonScaleShield=39;
AR040_DragonScaleArmor=40;
AR041_DragonboneGreaves=41;
AR042_DragonWingTabard=42;
AR043_NecklaceofDragonteeth=43;
AR044_CrownofDragontooth=44;
//ART LUCK / MORAL
AR045_StillEyeoftheDragon=45;         //MP HE LUCK / MORAL
AR046_CloverofFortune=46;             //MP HE LUCK / MORAL
AR047_CardsofProphecy=47;             //MP HE LUCK / MORAL
AR048_LadybirdofLuck=48;              //MP HE LUCK / MORAL
AR049_BadgeofCourage=49;              //MP HE LUCK / MORAL
AR050_CrestofValor=50;                //MP HE LUCK / MORAL
AR051_GlyphofGallantry=51;            //MP HE LUCK / MORAL
AR052_Speculum=52;                    //MP HE VIS
AR053_Spyglass=53;                    //MP HE VIS
//BATTLE and other
AR054_AmuletoftheUndertaker=54;       //BT NECRO +5%
AR055_VampiresCowl=55;                //BT NECRO +10%
AR056_DeadMansBoots=56;               //BT NECRO +15%
AR057_GarnitureofInterference=57;     //BR MAG RES +5%
AR058_SurcoatofCounterpoise=58;       //BT NECRO +10%
AR059_BootsofPolarity=59;             //BT MAG RES +15%
AR060_BowofElvenCherrywood=60;        //BT ARCHERY +5%
AR061_BowstringoftheUnicornsMane=61;  //BT ARCHERY +10%
AR062_AngelFeatherArrows=62;          //BT ARCHERY +15%
AR063_BirdofPerception=63;            //BT learn SPEL + 5%
AR064_StoicWatchman=64;               //BT learn SPEL + 10%
AR065_EmblemofCognizance=65;          //BT learn SPEL + 15%
AR066_StatesmansMedal=66;             //BT surrender cost
AR067_DiplomatsRing=67;               //BT surrender cost
AR068_AmbassadorsSash=68;             //BT surrender cost
AR069_RingoftheWayfarer=69;           //BT CR speed+1 HE speed +6
AR070_EquestriansGloves=70;           //MP HE speed EARTH
AR071_NecklaceofOceanGuidance=71;     //MP HE speed SAIL
AR072_AngelWings=72;                  //MP HE speed FLY
AR073_CharmofMana=73;                 //MP HE ptm +1/D
AR074_TalismanofMana=74;              //MP HE ptm +2/D
AR075_MysticOrbofMana=75;             //MP HE ptm +3/D
AR076_CollarofConjuring=76;           //BT spel dur + 1
AR077_RingofConjuring=77;             //BT spel dur + 2
AR078_CapeofConjuring=78;             //BT spel dur + 3
AR079_OrboftheFirmament=79;           //BT spel air +50% dmg
AR080_OrbofSilt=80;                   //BT spel earth +50% dmg
AR081_OrbofTempestuousFire=81;        //BT spel fire +50% dmg
AR082_OrbofDrivingRain=82;            //BT spel water +50% dmg
AR083_RecantersCloak=83;              //BT no L2+ spel
AR084_SpiritofOppression=84;          //BT no pos moral / but neg possible
AR085_HourglassoftheEvilHour=85;      //BT no luck
AR086_TomeofFireMagic=86;             //BT Exp fire + all Fire spel
AR087_TomeofAirMagic=87;              //BT Exp air  + all air spel
AR088_TomeofWaterMagic=88;            //BT Exp watr + all watr spel
AR089_TomeofEarthMagic=89;            //BT Exp erth + all erth spel
AR090_BootsofLevitation=90;           //MP HE speed FLY on water
AR091_GoldenBow=91;                   //BT archery no penality range/obs
AR092_SphereofPermanence=92;          //BT spel imune to dispel
AR093_OrbofVulnerability=93;          //BT spel all usable no immunities
AR094_RingofVitality=94;              //BT CR life +1
AR095_RingofLife=95;                  //BT CR life +1
AR096_VialofLifeblood=96;             //BT CR life +2
AR097_NecklaceofSwiftness=97;         //BT CR speed +1
AR098_BootsofSpeed=98;                //MP HE speed +6
AR099_CapeofVelocity=99;              //BT CR speed +2
AR100_PendantofDispassion=100;        //BT sepl imune to berserk
AR101_PendantofSecondSight=101;       //BT spel imune to blind
AR102_PendantofHoliness=102;          //BT spel imune to curse
AR103_PendantofLife=103;              //BT spel imune to death ripple
AR104_PendantofDeath=104;             //BT spel imune to destroy undead
AR105_PendantofFreeWill=105;          //BT spel imune to hypnotise
AR106_PendantofNegativity=106;        //BT spel imune to lightning bolt/chain lightning
AR107_PendantofTotalRecall=107;       //BT spel imune to forgetfullness
AR108_PendantofCourage=108;           //MP HE luck +3 /moral +3
AR109_EverflowingCrystalCloak=109;    //MP RES CRYS + 1
AR110_RingofInfiniteGems=110;         //MP RES GEMS + 1
AR111_EverpouringVialofMercury=111;   //MP RES MERC + 1
AR112_InexhaustibleCartofOre=112;     //MP RES ORE  + 1
AR113_EversmokingRingofSulfur=113;    //MP RES SULF + 1
AR114_InexhaustibleCartofLumber=114;  //MP RES BOIS + 1
AR115_EndlessSackofGold=115;          //MP RES OR + 500
AR116_EndlessBagofGold=116;           //MP RES OR + 750
AR117_EndlessPurseofGold=117;         //MP RES OR + 1000
AR118_LegsofLegion=118;               //TN CR2 +5
AR119_LoinsofLegion=119;              //TN CR3 +4
AR120_TorsoofLegion=120;              //TN CR4 +3
AR121_ArmsofLegion=121;               //TN CR5 +2
AR122_HeadofLegion=122;               //TN CR6 +1
AR123_SeaCaptainsHat=123;
AR124_SpellbindersHat=124;
AR125_ShacklesofWar=125;
AR126_OrbofInhibition=126;
AR127_VialofDragonBlood=127;
AR128_ArmageddonsBlade=128;
AR129_AngelicAlliance=129;
AR130_CloakoftheUndeadKing=130;
AR131_ElixirofLife=131;
AR132_ArmoroftheDamned=132;
AR133_StatueofLegion=133;             //TN CRALL +50%
AR134_PoweroftheDragonFather=134;
AR135_TitansThunder=135;
AR136_AdmiralsHat=136;
AR137_BowoftheSharpshooter=137;
AR138_WizardsWell=138;
AR139_RingoftheMagi=139;
AR140_Cornucopia=140;

PS0_ATT=0;
PS1_DEF=1;
PS2_KNO=2;
PS3_POW=3;

SK00_Pathfinding=0;  //MP PLturn penality of mov   B -25% --- A -50% --- E -75%
SK01_Archery=1;      //BT battle shot dmg :        B +10% --- A +25% --- E +50%
SK02_Logistics=2;    //MP PLturn augmente HE MOV   B +10% --- A +20% --- E +30%
SK03_Scouting=3;     //MP PLturn augmente HE VIS   B +1case - A +2case - E +3case -
SK04_Diplomacy=4;    //BE NEGO if less force Red cost B -20% --- A -40% --- E -60%
SK05_Navigation=5;   //MP NAV augmente HE MOV      B +50% --- A +100% -- E +150%
SK06_Leadership=6;   //BT batle  augmente CR MORAL B +1 ----- A +2 ----- E +3
SK07_Wisdom=7;       //MP ucmd  learn spel of LEV  B  3 ----- A  4 ----- E  5
SK08_Mysticism=8;    //MP        recover pt magie    B  2 ----- A  3 ----- E  4
SK09_Luck=9;         //MP      augmente HE LUCK    B +1 ----- A +2 ----- E +3
SK10_Ballistics=10;  //BT balist control           B dirig    A dmg+     E double shoot
SK11_Eagle_Eye=11;   //BE learn skil dur cBT       B 40% 1/2  A 50% 1/2/3 E 60% 1/2/3/4
SK12_Necromancy=12;  //BE % of dead becoming skeletB 10% ---  A 20% ---  E 30%
SK13_Estates=13;     //ok ucmd  or par tour        B 125 ---  A 250 ---  E 500
SK14_Fire_Magic=14;  //BT battle bonus fire  spell at B / A / E
SK15_Air_Magic=15;   //BT battle bonus air   spell at B / A / E
SK16_Water_Magic=16; //BT battle bonus water spell at B / A / E
SK17_Earth_Magic=17; //BT battle bonus earth spell at B / A / E
SK18_Scholar=18;     //MP
SK19_Tactics=19;     //BT place army
SK20_Artillery=20;   //BT chance *2dmg par ballist B 50% ---  A 75% ---  E 100%
SK21_Learning=21;    //MP
SK22_Offence=22;     //DMG en corp a corps         B +10% --- A +20% --- E +30%
SK23_Armorer=23;     //BT battle dmg reduce:       B  -5% --- A -10% --- E -15%
SK24_Intelligence=24;//MP augmente HE ptM          B +25% --- A +50% --- E +100%
SK25_Sorcery=25;     //BT spel dmg augmente        B  +5% --- A +10% --- E +15%
SK26_Resistance=26;  //BT spell failure :          B + 5% --- A +10% --- E + 20%
SK27_First_Aid=27;   //BT aidtent control creat    B 50ptV -- A 75ptV  -- E 100ptV

//SP_AdventureSpells
SP0_SummonBoat=0;
SP1_ScuttleBoat=1;
SP2_Visions=2;
SP3_ViewEarth=3;
SP4_Disguise=4;
SP5_ViewAir=5;
SP6_Fly=6;
SP7_WaterWalk=7;
SP8_DimensionDoor=8;
SP9_TownPortal=9;
//SP_CombatSpells=0;
SP10_Quicksand:     cmd_SP_createOBJ;    //CR bloqué NbHex N 4 / B 4 / A 6 / E 8
SP11_LandMine:      cmd_SP_createOBJ;    //CR DGT    NbDGT N25 / B25 / A50 / E100
SP12_ForceField:    cmd_SP_createOBJ;    //OBS       NbHex N 2 / B 2 / A 3 / E 3
SP13_FireWall:      cmd_SP_createOBJ;    //OBS DGT   NbDGT N10 / B10 / A20 / E50

SP14_Earthquake:    cmd_SP_destroyOBJ;   //MUR DGT   NbMur N 2 / B 2 / A 3 / E 4 (+Pwr?)

SP15_MagicArrow:    cmd_SP_shootDMG;     //DGT 10PWR+      N10 / B10 / A20 / E30
SP16_IceBolt:       cmd_SP_shootDMG;     //DGT 20PWR+      N10 / B10 / A20 / E30
SP17_LightningBolt: cmd_SP_shootDMG;     //DGT 25PWR+      N10 / B10 / A20 / E30
SP18_Implosion:     cmd_SP_shootDMG;     //DGT 75PWR+      N100/ B100/ A200/ E300
SP19_ChainLightning:cmd_SP_shootDMG;     //DGT 40PWR+      N25 / B25 / A50 / E100

SP20_FrostRing:     cmd_SP_areaDMG;//AREA=+1 NOCTR 10PWR+  N15 / B15 / A30 / E40
SP21_Fireball:      cmd_SP_areaDMG;      //AREA=+1 10PWR+  N15 / B15 / A30 / E60
SP22_Inferno:       cmd_SP_areaDMG;      //AREA=+2 10PWR+  N20 / B20 / A60 / E100
SP23_MeteorShower:  cmd_SP_areaDMG;      //AREA=+1 25PWR+  N25 / B25 / A50 / E100

SP24_DeathRipple:   cmd_SP_globalDMG;//CR live  DGT 5PWR+  N10 / B10 / A20 / E30
SP25_DestroyUndead: cmd_SP_globalDMG;//CR dead  DGT 10PWR+ N10 / B10 / A20 / E50
SP26_Armageddon:    cmd_SP_globalDMG;//CR all   DGT 50PWR+ N30 / B30 / A60 / E120

SP27_Shield:        cmd_SP_bonus; //onHandATT   DGT on DEF N75%/ B75%/ A50%/ E50%
SP28_AirShield:     cmd_SP_bonus; //onShotATT   DGT on DEF N75%/ B75%/ A50%/ E50%
SP29_FireShield:    cmd_SP_bonus; //onHandATT   DGT to ATT N20%/ B20%/ A25%/ E30%
SP30_ProtectionfromAir:   cmd_SP_bonus;//onMagAirATT  DGT on DEF N70%/ B70%/ A50%/ E50%
SP31_ProtectionfromFire:  cmd_SP_bonus;//onMagFirATT  DGT on DEF N70%/ B70%/ A50%/ E50%
SP32_ProtectionfromWater: cmd_SP_bonus;//onMagWtrATT  DGT on DEF N70%/ B70%/ A50%/ E50%
SP33_ProtectionfromEarth: cmd_SP_bonus;//onMagEarATT  DGT on DEF N70%/ B70%/ A50%/ E50%
SP34_AntiMagic:     cmd_SP_bonus;  //Min SPELL level       N4  / B4  / A5  / E6 (no speel)
SP35_Dispel:        cmd_SP_bonus;  //Cancel SPELL         N1CRa/B1CRa/A1CRx/ EallCR
SP36_MagicMirror:   cmd_SP_bonus;  //onMagATT  DGT to Enmy N20%/ B20%/ A30%/ E40%

SP37_Cure:          cmd_SP_life;   //Cancel -SPELL + life  N10 / B10 / A20 / E30
SP38_Resurrection:  cmd_SP_life;   // +life pts            N40 / B40 / A80 / E160
SP39_AnimateDead:   cmd_SP_life;   // +life pts on dead    N30 / B30 / A60 / E160
SP40_Sacrifice:     cmd_SP_life;   // +life pts per unit   N+3/  B+3 / A+6 / E+10


SP41_Bless:         cmd_SP_bonus;  // DGT=MAX +xx          N+0/  B+0 / A+1 / E+1
SP42_Curse:         cmd_SP_bonus;  // DGT=MIN -xx          N-0/  B-0 / A-1 / E-1
SP43_Bloodlust:     cmd_SP_bonus;  // HandATT  ATT+xxx     N+3/  B+3 / A+6 / E all +3 ?
SP44_Precision:     cmd_SP_bonus;  // ShotATT  ATT+xxx     N+3/  B+3 / A+6 / E all +6 ?
SP45_Weakness:      cmd_SP_bonus;  // HandATT  ATT-xxx     N-3/  B-3 / A-6 / E all -6 ?
SP46_StoneSkin:     cmd_SP_bonus;  // DEF +xxx             N+3/  B+3 / A+6 / E all +6 ?
SP47_DisruptingRay: cmd_SP_bonus;  // DEF -xxx  (cumul..)  N-3/  B-3 / A-4 / E-5
SP48_Prayer:        cmd_SP_bonus;  // ATT/DEF/SPEED +xx    N+2/  B+2 / A+4 / E all +4 ?
SP49_Mirth:         cmd_SP_bonus;  // MORAL                N+1/  B+1 / A+2 / E all +2 ?
SP50_Sorrow:        cmd_SP_bonus; // MORAL                N-1/  B-1 / A-2 / E all -2 ?
SP51_Fortune:       cmd_SP_bonus;  // CHANCE               N+1/  B+1 / A+2 / E +3 ou all +2 ?
SP52_Misfortune:    cmd_SP_bonus;  // CHANCE               N-1/  B-1 / A-2 / E all -2 ?
SP53_Haste:         cmd_SP_bonus;  // SPEED +xx            N+3/  B+3 / A+5 / E all +5 ?
SP54_Slow:          cmd_SP_bonus;  // SPEED %              N75%/ B75%/ A50%/ E50%
SP55_Slayer:        cmd_SP_bonus;  // AATT+8 on kingX      NK1 / BK1 / AK12/ EK123
SP56_Frenzy:        cmd_SP_bonus;  // ATT= ATT+ x% of DEF  N100/ B100/ A150/ E200   DEF=0
SP57_TitansLightningBolt:  cmd_SP_bonus; //unused
SP58_Counterstrike: cmd_SP_bonus;  //REPLy +xx             N+1 / B+1 /A+2  /E+2
SP59_Berserk:       cmd_SP_bonus;  //Frenesei a HEX+x      N 1 / B 1 / A 7 / E 19
SP60_Hypnotize:     cmd_SP_bonus;  //if Life <25+Pwr +x    N 10/ B 10/ A 20/ E 50
SP61_Forgetfulness: cmd_SP_bonus;  //nb CREA forget shoot  N50%/ B50%/ A100%/ E all
SP62_Blind:         cmd_SP_bonus;  //blind et %ATT 1reply  N50%/ B50%/ A25%/ E0%

SP63_Teleport:      cmd_SP_move;   //téléporte N/B limité a mme zone (mur/douve exclu)

SP64_RemoveObstacle:cmd_SP_destroyOBJ;
SP65_Clone:         cmd_SP_create;
SP66_FireElemental: cmd_SP_create;
SP67_EarthElemental:cmd_SP_create;
SP68_WaterElemental:cmd_SP_create;
SP69_AirElemental:  cmd_SP_create;


void Battle::Unit::SpellModesAction(const Spell & spell, u8 duration, const HeroBase* hero)
{
    if(hero)
    {
	u8 acount = hero->HasArtifact(Artifact::WIZARD_HAT);
	if(acount) duration += acount * Artifact(Artifact::WIZARD_HAT).ExtraValue();
	   acount = hero->HasArtifact(Artifact::ENCHANTED_HOURGLASS);
	if(acount) duration += acount * Artifact(Artifact::ENCHANTED_HOURGLASS).ExtraValue();
    }

    switch(spell())
    {
	case Spell::BLESS:
	case Spell::MASSBLESS:
	    if(Modes(SP_CURSE))
	    {
		ResetModes(SP_CURSE);
		affected.RemoveMode(SP_CURSE);
	    }
	    SetModes(SP_BLESS);
	    affected.AddMode(SP_BLESS, duration);
	    ResetModes(LUCK_GOOD);
	    break;

	case Spell::BLOODLUST:
	    SetModes(SP_BLOODLUST);
	    affected.AddMode(SP_BLOODLUST, 3);
	    break;

	case Spell::CURSE:
	case Spell::MASSCURSE:
	    if(Modes(SP_BLESS))
	    {
		ResetModes(SP_BLESS);
		affected.RemoveMode(SP_BLESS);
	    }
	    SetModes(SP_CURSE);
	    affected.AddMode(SP_CURSE, duration);
	    ResetModes(LUCK_BAD);
	    break;

	case Spell::HASTE:
	case Spell::MASSHASTE:
	    if(Modes(SP_SLOW))
	    {
		ResetModes(SP_SLOW);
		affected.RemoveMode(SP_SLOW);
	    }
	    SetModes(SP_HASTE);
	    affected.AddMode(SP_HASTE, duration);
	    break;

	case Spell::DISPEL:
	case Spell::MASSDISPEL:
	    if(Modes(IS_MAGIC))
	    {
		ResetModes(IS_MAGIC);
		affected.RemoveMode(IS_MAGIC);
	    }
	    break;

	case Spell::SHIELD:
	case Spell::MASSSHIELD:
	    SetModes(SP_SHIELD);
	    affected.AddMode(SP_SHIELD, duration);
	    break;

	case Spell::SLOW:
	case Spell::MASSSLOW:
	    if(Modes(SP_HASTE))
	    {
		ResetModes(SP_HASTE);
		affected.RemoveMode(SP_HASTE);
	    }
	    SetModes(SP_SLOW);
	    affected.AddMode(SP_SLOW, duration);
	    break;

	case Spell::STONESKIN:
	    if(Modes(SP_STEELSKIN))
	    {
		ResetModes(SP_STEELSKIN);
		affected.RemoveMode(SP_STEELSKIN);
	    }
	    SetModes(SP_STONESKIN);
	    affected.AddMode(SP_STONESKIN, duration);
	    break;

	case Spell::BLIND:
	    SetModes(SP_BLIND);
	    blindanswer = false;
	    affected.AddMode(SP_BLIND, duration);
	    break;

	case Spell::DRAGONSLAYER:
	    SetModes(SP_DRAGONSLAYER);
	    affected.AddMode(SP_DRAGONSLAYER, duration);
	    break;

	case Spell::STEELSKIN:
	    if(Modes(SP_STONESKIN))
	    {
		ResetModes(SP_STONESKIN);
		affected.RemoveMode(SP_STONESKIN);
	    }
	    SetModes(SP_STEELSKIN);
	    affected.AddMode(SP_STEELSKIN, duration);
	    break;

	case Spell::ANTIMAGIC:
	    ResetModes(IS_MAGIC);
	    SetModes(SP_ANTIMAGIC);
	    affected.AddMode(SP_ANTIMAGIC, duration);
	    break;

	case Spell::PARALYZE:
	    SetModes(SP_PARALYZE);
	    affected.AddMode(SP_PARALYZE, duration);
	    break;

	case Spell::BERSERKER:
	    SetModes(SP_BERSERKER);
	    affected.AddMode(SP_BERSERKER, duration);
	    break;

	case Spell::HYPNOTIZE:
	{
	    SetModes(SP_HYPNOTIZE);
	    u8 acount = hero ? hero->HasArtifact(Artifact::GOLD_WATCH) : 0;
	    affected.AddMode(SP_HYPNOTIZE, (acount ? duration * acount * 2 : duration));
	}
	    break;

        case Spell::STONE:
	    SetModes(SP_STONE);
	    affected.AddMode(SP_STONE, duration);
	    break;

	case Spell::MIRRORIMAGE:
	    affected.AddMode(CAP_MIRRORIMAGE, duration);
	    break;

	case Spell::DISRUPTINGRAY:
	    ++disruptingray;
	    break;

	default: break;
    }
}

void Battle::Unit::SpellApplyDamage(const Spell & spell, u8 spoint, const HeroBase* hero, TargetInfo & target)
{
    u32 dmg = spell.Damage() * spoint;

    switch(GetID())
    {
	case Monster::IRON_GOLEM:
	case Monster::STEEL_GOLEM:
	    switch(spell())
	    {
		// 50% damage
                case Spell::COLDRAY:
                case Spell::COLDRING:
                case Spell::FIREBALL:
                case Spell::FIREBLAST:
                case Spell::LIGHTNINGBOLT:
                case Spell::CHAINLIGHTNING:
                case Spell::ELEMENTALSTORM:
                case Spell::ARMAGEDDON:
            	    dmg /= 2; break;
                default: break;
            }
	    break;

        case Monster::WATER_ELEMENT:
	    switch(spell())
	    {
		// 200% damage
                case Spell::FIREBALL:
                case Spell::FIREBLAST:
            	    dmg *= 2; break;
                default: break;
            }
	    break;

	case Monster::AIR_ELEMENT:
	    switch(spell())
	    {
		// 200% damage
                case Spell::ELEMENTALSTORM:
                case Spell::LIGHTNINGBOLT:
                case Spell::CHAINLIGHTNING:
            	    dmg *= 2; break;
                default: break;
            }
	    break;

	case Monster::FIRE_ELEMENT:
	    switch(spell())
	    {
		// 200% damage
                case Spell::COLDRAY:
                case Spell::COLDRING:
            	    dmg *= 2; break;
                default: break;
            }
	    break;

	default: break;
    }

    // check artifact
    if(hero)
    {
	const HeroBase* myhero = GetCommander();
	u8 acount = 0;

	switch(spell())
	{
            case Spell::COLDRAY:
            case Spell::COLDRING:
		// +50%
    		acount = hero->HasArtifact(Artifact::EVERCOLD_ICICLE);
		if(acount) dmg += dmg * acount * Artifact(Artifact::EVERCOLD_ICICLE).ExtraValue() / 100;
    		acount = hero->HasArtifact(Artifact::EVERCOLD_ICICLE);
		if(acount) dmg += dmg * acount * Artifact(Artifact::EVERCOLD_ICICLE).ExtraValue() / 100;
		// -50%
    		acount = myhero ? myhero->HasArtifact(Artifact::ICE_CLOAK) : 0;
		if(acount) dmg /= acount * 2;
    		acount = myhero ? myhero->HasArtifact(Artifact::HEART_ICE) : 0;
		if(acount) dmg -= dmg * acount * Artifact(Artifact::HEART_ICE).ExtraValue() / 100;
    		// 100%
    		acount = myhero ? myhero->HasArtifact(Artifact::HEART_FIRE) : 0;
		if(acount) dmg *= acount * 2;
    		break;

            case Spell::FIREBALL:
            case Spell::FIREBLAST:
		// +50%
    		acount = hero->HasArtifact(Artifact::EVERHOT_LAVA_ROCK);
		if(acount) dmg += dmg * acount * Artifact(Artifact::EVERHOT_LAVA_ROCK).ExtraValue() / 100;
		// -50%
    		acount = myhero ? myhero->HasArtifact(Artifact::FIRE_CLOAK) : 0;
		if(acount) dmg /= acount * 2;
    		acount = myhero ? myhero->HasArtifact(Artifact::HEART_FIRE) : 0;
		if(acount) dmg -= dmg * acount * Artifact(Artifact::HEART_FIRE).ExtraValue() / 100;
    		// 100%
    		acount = myhero ? myhero->HasArtifact(Artifact::HEART_ICE) : 0;
		if(acount) dmg *= acount * 2;
    		break;

            case Spell::LIGHTNINGBOLT:
		// +50%
    		acount = hero->HasArtifact(Artifact::LIGHTNING_ROD);
		if(acount) dmg += dmg * acount * Artifact(Artifact::LIGHTNING_ROD).ExtraValue() / 100;
		// -50%
    		acount = myhero ? myhero->HasArtifact(Artifact::LIGHTNING_HELM) : 0;
		if(acount) dmg /= acount * 2;
		break;

            case Spell::CHAINLIGHTNING:
		// +50%
    		acount = hero->HasArtifact(Artifact::LIGHTNING_ROD);
		if(acount) dmg += acount * dmg / 2;
		// -50%
    		acount = myhero ? myhero->HasArtifact(Artifact::LIGHTNING_HELM) : 0;
		if(acount) dmg /= acount * 2;
		// update orders damage
		switch(target.damage)
		{
		    case 0: 	break;
		    case 1:	dmg /= 2; break;
		    case 2:	dmg /= 4; break;
		    case 3:	dmg /= 8; break;
		    default: break;
		}
    		break;

        case Spell::ELEMENTALSTORM:
        case Spell::ARMAGEDDON:
		// -50%
    		acount = myhero ? myhero->HasArtifact(Artifact::BROACH_SHIELDING) : 0;
		if(acount) dmg /= acount * 2;
    		break;

	    default: break;
	}
    }

    // apply damage
    if(dmg)
    {
	target.damage = dmg;
	target.killed = ApplyDamage(dmg);
	if(target.defender && target.defender->Modes(SP_BLIND)) target.defender->ResetBlind();
    }
}

void Battle::Unit::SpellRestoreAction(const Spell & spell, u8 spoint, const HeroBase* hero)
{
    switch(spell())
    {
	case Spell::CURE:
	case Spell::MASSCURE:
	    // clear bad magic
	    if(Modes(IS_BAD_MAGIC))
	    {
		ResetModes(IS_BAD_MAGIC);
		affected.RemoveMode(IS_BAD_MAGIC);
	    }
	    // restore
	    hp += (spell.Restore() * spoint);
	    if(hp > ArmyTroop::GetHitPoints()) hp = ArmyTroop::GetHitPoints();
	    break;

        case Spell::RESURRECT:
	case Spell::ANIMATEDEAD:
        case Spell::RESURRECTTRUE:
	{
	    u32 restore = spell.Resurrect() * spoint;
	    // remove from graveyard
	    if(!isValid())
	    {
		Arena::GetGraveyard()->RemoveTroop(*this);
		ResetAnimFrame(AS_IDLE);
	    }
	    // restore hp
	    u8 acount = hero ? hero->HasArtifact(Artifact::ANKH) : 0;
	    if(acount) restore *= acount * 2;

	    const u32 resurrect = Resurrect(restore, false, (spell == Spell::RESURRECT));

	    if(Arena::GetInterface())
	    {
		std::string str(_("%{count} %{name} rise(s) from the dead!"));
		StringReplace(str, "%{count}", resurrect);
		StringReplace(str, "%{name}", GetName());
		Arena::GetInterface()->SetStatus(str, true);
	    }
	}
        break;

	default: break;
    }
}






bonus attack
Attacker's Attack Skill > Defender's Defense Skill
        0,05 * (A - D), (capped at 3)
Attacker is a shooter
  Archery Skill bonus, additive with artifact bonuses if Archery skill present
  Attacker is a Ballista, does double damage
        1
  Attacking hero has Archery specialty
        0,05 * Hero level * Archery bonus
Attacking hero has Offense Skill
        Offense skill bonus
Attacking hero has Offense specialty
        0,05 * Hero level * Offense bonus
Attacker gets Luck
        1
Attacker is a Cavalier/Champion
        0,05 * hexes traveled
Attacker is an opposite Elemental type
        1
Attacker 'hates' the Defender
        0,5
Dread knight's double damage
        1
Bless specialty Hero, Bless is cast
        0,03 * Hero level / Unit leve


bonus defend = dmg* (1-bonus)

Defender's Defense > Attacker's Attack
        0,025 * (D – A), up to a maximum of 0,7
Defending hero has Armorer
        Armorer skill bonus
Defending hero has specialty Armorer
        0,05 * Hero level *Armorer bonus, additive with base Armorer bonus
Defender has Shield spell applied
        Shield spell bonus
Attacker is a shooter, Basic Air Shield is cast
        0,25
Attacker is a shooter with range, wall or melee penalty, or Advanced Air Shield is cast
        0,5
Attacking a petrified unit
        0,5
Attacker is Psychic Elemental, defender is immune to Mind spells
        0,5
Attacker is Magic Elemental, defender is Magic Elemental or the Black Dragon
        0,5
Unit retaliates from Basic Blind state
        0,5
Unit retaliates from Advanced Blind state
        0,25
