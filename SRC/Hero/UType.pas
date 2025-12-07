unit UType;

interface

uses
  Windows, Messages, SysUtils, Contnrs, Variants, Classes, Graphics, Controls, Forms, Math;
  
const

// Text Handler NewLine / NewTab
  NL= chr(13);
  NT= #9;

// MAP Version
  VER_ROE=14;
  VER_ARB=21;
  VER_SOD=28;

// MAP Size and MAX of OBJECT in a MAP
  DIM_S = 36;
  DIM_M = 72;
  DIM_L =108;
  DIM_XL=144;

  MAX_OBJ= 20000;
  MAX_OB1=32;
  MAX_OB2=1024;
  MAX_CITY=48;
  MAX_PLAYER=8;

// MAP remarkable value
  TR08_Water=8;
  TL_OUT=-1;
  TL_EVENT=-1;
  TL_FREE =0;
  TL_OBJ  =1;
  TL_ENTRY=2;

// DEF
  MAX_DEF=1343;
  DEF_W=8;
  DEF_H=6;

// MAX Qty in Game
  MAX_RES=7;
  MAX_ART=127;
  MAX_SPEL=69;
  MAX_CREA=122;
  MAX_BANK=11;
  MAX_FLAG=14;
  MAX_SSK=27;

// TOWN
  MAX_TOWN=8;
  MAX_PUZZLE=48;
  MAX_BUILD=44;
  MAX_CONS=41;
  MAX_SPEC=11;
  MAX_NEUT=17;
  MAX_DWELL=14;

//==============================================================================

// PLAYER String ID
  PL_INITIAL:   Array [0..MAX_PLAYER-1] of String
    = ('L','G','R','D','B','P','W','K');
  PL_INITIAL2:  Array [0..MAX_PLAYER-1] of String
    = ('R','B','Y','G','O','P','T','S');
  PL_COLOR:     Array [0..MAX_PLAYER-1] of String
    = ('RED','BLUE','TAN','GREEN','ORANGE','PURPLE','TEAL','ROSE');

// TOWN String ID
  TN_INITIAL: Array [0..MAX_TOWN-1] of String
    = ('CS','RM','TW','IN','NC','DN','ST','FR');
  TNext: array [0..MAX_TOWN] of string
    = ('CSTL','RAMP','TOWR','INFR','NECR','DUNG','STRN','FORT','NEUT');
  TNext2 : array [0..MAX_TOWN] of string
    = ('CAS','RAM','TOW','INF','NEC','DUN','STR','FOR','NEU');
  TNext3 : array [0..MAX_TOWN] of string
    = ('CS','RM','TW','IN','NC','DG','ST','FR','NE');
  TNext4 : array [0..MAX_TOWN] of string
    = ('CS','RM','TW','IN','NC','DN','ST','FR','NE');

// HERO
  MAX_CLASSE=16;
  MAX_HERO=128;
  MAX_SLOT=18;
  MAX_PACK=22;
  MAX_ARMY=6;
  MAX_VISION=6;

// BATTLE
  MAX_BAX = 14;
  MAX_BAY = 10;
  nBaTiles = (MAX_BAX+1) * (MAX_BAY+1);
  nBaPath  = MAX_BAX + MAX_BAY;

// ACTIONS
  ActMoveTime=8;
  ActStartTime=5;

  ACT00_Nothing=0;
  ACT01_Move=1;
  ACT02_Delete=2;
  ACT03_Enter=3;
  ACT04_Battle=4;
  ACT05_Meet=5;
  ACT06_Town=6;
  ACT07_Teleport=7;
  ACT08_Boat=8;
  ACT09_Dialog=9;
  ACT10_CPU=10;
  ACT11_Gar=11;
  ACT12_CancelMove=12;
  ACT_String : Array [1..12] of string =
  ('Move','Delete','Enter','Battle','Meet','Town','TelePort','Boat','Dialog','CPU','Gar','CancelMove');

// MOUSE ID
  msAdv=0;
  msCbt=1;
  msArt=2;

  //msAdv cursor value
  CrDef=  0;
  CrWaits=1;
  CrHero= 2;
  CrTown= 3;
  CrMove= 4;
  CrFight=5;
  CrSail= 6;
  CrAncre=7;
  CrMeet= 8;
  CrBonus=9;

  CrMoveNN=32;
  CrMoveNE=33;
  CrMoveEE=34;
  CrMoveSE=35;
  CrMoveSS=36;
  CrMoveSW=37;
  CrMoveWW=38;
  CrMoveNW=39;

  //msCbt cursor value .. CrBaDef=0; // to be replace by 0 = sens interdit
  CrWalk=1;
  CrFLy=2;
  CrFire=3;
  CrBaHero=4;
  CrInfo=5;
  CrList=6;
  CrFightDir=7;
  CrFightSO=7;
  CrFightOO=8;
  CrFightNO=9;
  CrFightNE=10;
  CrFightEE=11;
  CrFightSE=12;
  CrBaFight=12 ;
  CrFireMalus=15;
  CrCatapult=16;
  CrHeal=17;
  CrSpel=20;

// DIALOG
  dsRes0=0;             //Quantity
  dsArtQ=7;
  dsArt=8;              //ID of artifact
  dsSpell=9;            //ID of spell
  dsFlag=10;
  dsLuck_p=11;          //(positive) 11 + of luck
  dsLuck_n=12;          //(neutral) 12 no matter
  dsLuck_m=13;          //(negative) Not supported in heroes. 13  - of luck
  dsMorale_p=14;        //(positive) 14 + of Morale
  dsMorale_n=15;        //(neutral) 15 no matter
  dsMorale_m=16;        //(negative) 16  - of Morale
  dsExperience=17;      //Quantity
  dsSecSkill=20;        //Skill + level*
  dsMonster=21;         //Type of monster
  dsBuilding=22;        //..30 town type (Format T) Type of building Format U)
  dsPriSkill=31;        //..34 Quantity
  dsSpellPoints=35;     //Quantity
  dsMoney=36;           //Quantity
  dsMoneyExp=37;
  dsStartHero=38;
  dsStartCity=39;
  dsStartBonus=40;
  dsMapBonus=41;
  dsTeamInfo=42;
  dsYesNo=50;
  dsNone=51;
  dsPop=52;
  dsInfoScroll=53;
//==============================================================================


Type

// Def
TInfoDef = record
  id: integer;
  name: string;
  t,u : integer;
  p,e : string;
end;

// HEROES Object   RES - ART - SPEL - CREA - BANK
TRes = array [0..MAX_RES] of integer;

TInfoRes = record
  id     : byte;
  name   : string;
  desc   : string;
  event  : string;
  mine   : string;
  resPic : string;
  minePic: string;
end;

TInfoArt = record
  id     : byte;
  name   : string;
  desc   : string;
  event  : string;
  slotOK : array [0..MAX_PACK] of boolean;
  pic    : string;
end;

TAnimList= array [0..21] of TStringList;

TInfoCrea = record
  id: byte;
  align: byte;
  name:   string;
  desc: string;
  flag: integer;
  growth: integer;
  growH : integer;
  cost:   integer;
  hit:    integer;
  speed:  integer;
  atk:    integer;
  def:    integer;
  dmgMin: integer;
  dmgMax: integer;
  shots:  integer;
  shotdef: string;
  shotdefid: integer;
  shotspin: boolean;
  shotstart: integer;
  shotux: integer;
  shotuy: integer;
  shotrx: integer;
  shotry: integer;
  shotdx: integer;
  shotdy: integer;
  level:  integer;
  PicMap: string;
  PicFight: string;
  PicLrg: string;
  PicSml: string;
  AnimList: TAnimList; //array [0..21] of TStringList;
end;

TArmy = record
  t: integer;
  n: integer;
  a: boolean;
end;

TArmys = array [0..MAX_ARMY] of TArmy;

TInfoBank = record
  name  : string;
  Armys : TArmys;
  bRes  : TRes;
  bCR   : TArmy;
  bArt1,bArt2,bArt3,bArt4: integer;
end;

TSSKMaster = record
  name : string;
  desc : string;
  pic  : string;
end;

TInfoSSK = record
  id    : integer;
  name  : string;
  lev   : array [0..2 ] of TSSKMaster;
end;

TPSK = record
  att: integer;
  def: integer;
  pow: integer;
  kno: integer;
  ptm: integer;
  mov: integer;
end;

TInfoEffect = record
  n: integer;
  defs: array [0..7] of string;
  obid: integer;
end;

TSpelMaster = record
  name   : string;
  desc   : string;
  effect : integer;
  cost   : integer;
end;

TInfoSpel = record
  id: integer;
  name: string;
  shortname: string;
  school: integer;
  level: integer;
  pow:integer;
  Bas: TSpelMaster;
  Nov: TSpelMaster;
  Exp: TSpelMaster;
  Mas: TSpelMaster;
  Rnd: array [0..MAX_TOWN] of integer;
  attrib: string;
  effect: integer;
  combat: integer;
  adv,cbt,tg0,tg1,tg2,loc,mnd,obs: boolean;
  // pic
  pic    : string;
  bookPic : string;
  townPic : string;
end;

//==============================================================================

TPos = record
  x,y,l: integer;
end;

TObjIndeX = record
  oid,
  t, u : integer;
end;

TDxMouse = record
  x,y   : integer;
  mx,my : integer;
  sx,sy : integer;
  button: TMouseButton;
  style : byte;
  id    : integer;
end;

//==============================================================================

TAction = record
  Id  : integer;
  HE  : integer;
  HE2 : integer;
  OB  : integer;
  Delay: integer;
end;

PAction = ^TAction;

//==============================================================================

TDialogType =
  (dsOK, dsAccept, dsNewTurn, dsInfo, dsCreaInfo);

TMapDialog = record
  mes: string;
  t: byte;
  v: integer;
  res: integer;
end;

//==============================================================================

TMapObj = record
  def     : integer;
  t,u,v   : integer;
  id      : integer;        // id in mObjs list
  pid     : shortint;
  hasEntry: boolean;
  msg     : string;
  pos     : TPos;
  Guarded : Boolean;
  Armys   : TArmys;
  Deading : integer;
end;

pTMapObj= ^TMapObj;

TMapTer = record
  t: byte;
  u: byte;
  m: byte;
end;

TMapTile = record
  TR    : TMapTer;
  RV    : TMapTer;
  RD    : TMapTer;
  P1    : shortint; // property rivage / entry / passy
  obX   : TObjIndeX;
  Vis   : array [0..7] of boolean;
  nCreas: integer;
  Obs   : boolean;
  Rnd   : byte;
  Plage : boolean;
end;

TTiles = array [-1..164,-1..164,0..1] of TMapTile;  //56=36+20

//==============================================================================

TPlayer = record
  name     : string;
  flag     : string;
  team     : byte;
  initial  : char;
  isHuman  : boolean;
  isCPU    : boolean;
  isAlive  : boolean;
  Attitude : integer;
  ownTown  : integer;
  rndTown  : integer;
  hasMainCT: boolean;
  hasNewHeroCT: boolean;
  ActiveHero:integer;
  ActiveCity:integer;
  PosCT:TPos;
  allTopMap: boolean;
  allSubMap: boolean;
  allWtrMap: boolean;
  TentVisited : array [0..7] of  boolean;
  TavHero  : array [0..1] of integer;
  LstHero  : array [0..7] of  integer;        //max of 8 hero   -1 for unused slot
  nHero    : integer;
  LstCity  : array [0..MAX_CITY] of integer;  //max of 48 Town  index to LstTown
  nCity    : integer;
  Res      : TRes;
  Mine     : TRes;
  Income   : TRes;
end;

TJoueur = record
  name: string;
  team: byte;
  faction: integer;
  isRndFaction:boolean ;
  isHuman: boolean;
  isCPU: boolean;
  isAlive: boolean;
  Attitude: integer;
  hasMainCT: boolean;
  hasNewHeroCT: boolean;
  PosCT:TPos;
  activeHero:integer;
  activeHeroName:string;
  activeCity:integer;
  bonus: byte;
end;

//==============================================================================

TMapHeader = record
  fname: string;
  name, des, vic, los, mdif       : string;
  ver, nPlr, pdif, dim, dfc, level: integer;
  vicId,losId : integer;
  vicPos      : TPos;
  joueurs : array [0..7] of TJoueur;
  nteams  : byte;
  custom  : boolean;
end;

TMapHeaderList = array [0..200] of TMapHeader ;

TMapData = record
  fName   : string;
  loadStep: integer;
  startload, starttile, endtile, startdef, enddef, startobj, endobj : string;
  ver, dim, lss, vct: integer;
  name, des,
  vic, los   : string;
  vicId,losId: integer;
  vicPos     : TPos;
  vicItem    : integer;
  vicQty     :integer;
  level, nPlr, dfc: integer;
  allblack   : boolean;
  day, week, month: integer;
  weekMsg : string;
  rumor   : integer;
  event   : integer;
end;

//==============================================================================

TMapBonus = record
  EXP: integer;
  PSK: TPSK;
  SSK: array [0..MAX_SSK] of integer;
  MORAL: shortint;
  LUCK : shortint;
  GiveRES: TRES;
  TakeRES: TRES;
  Arts:  array [0..MAX_PACK] of integer;
  Spels: array [0..MAX_SPEL] of boolean;
  nART : integer;
  nCR :  integer;
  CREAS: array [0..10] of TArmy;
end;

//==============================================================================

TInfoPuzzle = record
  pos: TPoint;
  puzzlepic: string;
end;

TInfoPuzzles = array [0..MAX_PUZZLE] of TInfoPuzzle;

//==============================================================================
TInfoWall = record
  id     : integer;
  pos    : TPoint;
  PicWall: string;
  des    : string
end;

TInfoWalls = array [0..14] of TInfoWall;

TInfoBuild = record
  id:   integer;
  name: string;
  basic:string;
  desc: string;
  cons: integer;
  slot: integer;
  pos: TPoint;
  Replace: integer;
  ResNec:  TRes;
  PicHall:  string;
end;

TInfoBuilds = array [0..MAX_BUILD-1] of TInfoBuild;

TInfoCons = record
  id     : integer;
  name   : string;
  build  : integer;
end;

TInfoConss = array[0..MAX_CONS] of TInfoCons;

TCons = array [0..40] of boolean;

TBuilds = array [0..43] of boolean;

TCity = record
  uid: integer; // uid for random object which type is linked to the town
  pos: TPos;
  t: byte;
  pid: shortint;
  name: string;
  align: integer;
  hasBuild: byte;
  VisArmys: TArmys;
  GarArmys: TArmys;
  ProdArmys:TArmys;
  DispArmys:TArmys;
  VisHero: integer;
  GarHero: integer;
  Cons:   TCons ;
  Builds: TBuilds;
  Spels: array [0..MAX_SPEL] of byte;
end;

TCityEvent = record
  City: integer;
  Name: string;
  Desc: string;
  giveRes : TRes;
  takeRes : TRes;
  startDay: integer;
  repeatperiod: integer;
  giveArmys : TArmys;
  PL: integer;
  //BU to build
  //CR to add
end;

//==============================================================================

TMapEvent = record
  Name: string;
  Desc: string;
  giveRes : TRes;
  takeRes : TRes;
  startDay: integer;
  repeatperiod: integer;
  PL: integer;
end;

//==============================================================================

TInfoHero = record
  name: string;
  agress: integer;
  ext: string;
  PSK_Init: array [0..3] of integer;
  PSK_Gain_LL: array [0..3] of integer;
  PSK_Gain_HL: array [0..3] of integer;
  SSK_GAIN:  array [0..MAX_SSK] of integer;
  town: array [0..7] of integer;
end;
{Aggression  AttDefPowKno init / lev-10 / lev+10   SSkl(112) Town appearance (8) }

TMapHero = record
  id: integer;
  oid:integer;
  DefaultName: string;
  name: string;
  pid: shortint;
  pos: TPos;
  tgt: TPos;
  obX: TObjIndex;
  castle: integer;
  desc: string;
  MapPic: string;
  //boolean
  used,
  cpu,
  sel,
  mov: boolean;
  level: integer;
  exp: integer;
  vision: integer;
  dst: TPoint;
  dir: integer;
  VisSwan,
  VisFaery,
  VisIdol,
  VisYough,
  VisFortune,
  VisMagicWell,
  VisMermaid,
  VisOasis,
  VisRallyFlag,
  VisStable,
  VisTemple,
  VisBuoy,
  VisMono: boolean;
  VisTown: integer;
  VisObj:     array [0..10,0..31] of boolean;
  VisCTskill: array [0..MAX_CITY] of boolean;
  hasBook,
  hasCast: boolean;
  BoatId: integer;
  //pic
  smlPic:string;
  lrgPic:string;
  classeId: integer;
  classeName: string;
  spec: string;
  spec1: string;
  specSK, specSKP: integer;
  Arts:  array [0..MAX_PACK] of integer;
  Spels: array [0..MAX_SPEL] of boolean;
  SSK: array [0..MAX_SSK] of integer;
  PSKB: TPSK;
  PSKA: TPSK;
  startArmys: TArmys;
  Armys: TArmys;
  nArmy: integer;
  luck:  integer;
  moral: integer;
  speed: integer;
  force: Integer;
  school : array [0..3] of integer;
end;

//==============================================================================

TMapCamp = record    // CP
  r: Byte;
  q: Byte;
end;

TMapChest = record   // CH 101
  t: Byte;           //type artif /   gold/exp
  a: integer;        //artifact
  b: integer;        //bonus  as gold/exp : 500*B / 500*B-500
end;

TMapMine = record    // MN  53
  pos: TPos;
  res: Byte;
  pid: shortint;
end;

TMapMonster = record
  oid:integer;
  qty: integer;
  agressiv: byte;
  custom: boolean;
  msg: string;
  res: TRes;
  artid: integer;
  questID:string;
end;

TMapScholar = record    // SC 81
  t: Byte;              //type PK / SS / SP
  pk: integer;          //primary skill
  ss: integer;          //secondary skill
  sp: integer;          //spell
end;

TMapSeer = record       // Seer 81
  Name:string;          // owner name
  Quest: byte;          // quest  type 0 .. 9
  QuestID:string;
  Q1,Q2 : integer;      // quest parameter 1, 2
  Reward: Byte;         // reward type 0 .. 9
  R1,R2 : integer;      // reward parameter 1, 2
  visited: array [0..MAX_PLAYER-1] of boolean;
  completed: boolean;
  Text1,Text2,Text3: string;
end;

TMapTomb = record       // WT 108
  a: integer;           // artifact
  t: integer;           // present or not
end;

TMapTree = record       // KT 102
  t: Byte;              // 0 (Free) =1 (2000 gold)  =2 (10 gems)
  n: Byte;              // Number of the Knowledge Tree (0...31)
end;

TMapLean = record       // LN 102
  r: Byte;
  q: integer;           // qty
  n: Byte;              // Number of the LeanTo (0...31)
end;

TMapBank = record
  bArts: Array [0..6] of integer;
  bArmy: TArmy;
  bRes: TRes;
  bTotalArts : integer;
  Take: boolean;
  Visited : Array [0..Max_Player-1] of Boolean;
end;

TMapRumor = record
  desc: string;
  date: integer;
end;

//==============================================================================

TBaUnit = record
  side:   integer;         // 0 left, 1 right
  x,y:    integer;         // position
  t:      integer;
  // attribut at creation
  n0,
  atk0,def0,move0,hit0,luck0,moral0: integer;
  // attribute current
  n,shot,HEXtravelled,
  atk1,def1,move1,hit1,luck1,moral1: integer;
  // attibute affected by spell
  atkSP,defSP,moveSP: integer;
  // state UN-1 free to play UN00_Wait=0;UN01_Done=1;UN02_Def=2;
  state:  integer;
  frozen: integer;    // spell effect
  contact:boolean;
  reply:  boolean;
  tower: integer;     // tower cr
  dirLeft:boolean;
  AnimList: ^TAnimList;
  AnimPos, AnimCount, AnimType: integer;
  SpelD: array [0..MAX_SPEL] of byte;
  SpelE: array [0..MAX_SPEL] of byte;
end;

//==============================================================================

var
  TxtCastInfo    : TstringList;
  TxtHelp        : TstringList;
  TxtVCDesc      : TStringList;
  TxtLCDesc      : TStringList;
  TxtAdvevent    : TstringList;
  TxtPlayerColor : TstringList;
  TxtTownName    : TStringList;
  TxtTcommand    : TStringList;
  TxtTownType    : TStringlist;
  TxtOVERVIEW    : TStringlist;
  TxtPRISKILL    : TStringlist;
  TxtSchoolName  : TStringList;
  TxtArtSlot     : TStringList;
  TxtObject      : TStringList;
  TxtCrGen1      : TStringList;
  TxtARRAYTXT    : TStringList;
  TxtMasterName  : TStringList;
  TxtHeroName    : TStringList;
  TxtGenrlTxt    : TStringList;
  TxtSeer        : TstringList;
  TxtRANDTVRN    : TstringList;
  TxtXtraInfo    : TstringList;

  iRES   : array [0..MAX_RES]  of TInfoRes;
  iSSK   : array [0..MAX_SSK]  of TInfoSSK;
  iART   : array [0..MAX_ART]  of TInfoArt;
  iSPEL  : array [0..MAX_SPEL] of TInfoSpel;
  iEffect: array [0..85]       of TInfoEffect;

  iWALL  : array [0..MAX_TOWN]  of TInfoWalls;
  iCONS  : TInfoConss;
  iBUILD : array [0..MAX_TOWN] of TInfoBuilds;

  iPUZZLE: array [0..MAX_TOWN] of TInfoPuzzles ;

  iCREA  : array [0..MAX_CREA] of TInfoCrea;

  iBank  : array[0..MAX_Bank,0..3] of TInfoBank;

  iDEF   : array [0..MAX_DEF] of TInfoDef;

  iHERO  : array [0..MAX_CLASSE-1] of TInfoHero;

  DimWH: integer;
  MapWH: integer;

  mHeader: TMapHeader;
  mList:   TMapHeaderList;
  nList:   integer;

  mData : TMapData;
  mPL   : integer;// = 1;
  mHE   : integer;
  mCT   : integer; // current player, hero , city
  hPL   : integer; // id of first human player

  Actions : TList;
  mes     : string;
  mDialog : TMapDialog;

  mHeros  :array[-1..MAX_HERO] of TMapHero;  // Hero -1 to use in Monster BATTLE
  mTiles  : TTiles;
  mPlayers: array [0..MAX_PLAYER-1] of TPlayer;

  mObjs    : array [0..MAX_OBJ] of TMapOBj;
  pObj     : pTMapOBj;
  mObj     : TMapObj;

  mSigns   : TStringList;

  mCitys   : array [0..MAX_CITY] of TCity;

  mBanks   : array [0..MAX_OB2] of TMapBank;
  mBonus   : array [0..MAX_OB2] of TMapBonus;
  mCamps   : array [0..MAX_OB1] of TMapCamp;
  mChests  : array [0..MAX_OB2] of TMapChest;
  mLeans   : array [0..MAX_OB1] of TMapLean;
  mMines   : array [0..MAX_OB2] of TMapMine;
  mMonsters: array [0..MAX_OB2] of TMapMonster;
  mSeers   : array [0..MAX_OB1] of TMapSeer;
  mScholar : array [0..MAX_OB2] of TMapScholar;
  mTombs   : array [0..MAX_OB1] of TMapTomb;
  mTrees   : array [0..MAX_OB1] of TMapTree;
  mRumors  : array [0..63] of TMapRumor;
  mEvents  : array [0..127] of TMapEvent;
  mCEvents : array [0..127] of TCityEvent;

  nObjs    : integer = 0;
  nCitys   : integer = 0;
  nCEvents : integer = 0;
  nArts    : integer = 0;
  nBanks   : integer =0;
  nCamps   : integer = 0;
  nChests  : integer = 0;
  nLeans   : integer = 0;
  nMagicSprings: integer = 0;
  nMonsters: integer = 0;
  nMines   : integer = 0;
  nBonus   : integer = 0;
  nScholars: integer = 0;
  nSeers   : integer = 0;
  nTombs   : integer = 0;
  nTrees   : integer = 0;
  nMarletto: integer;           //23
  nGarden  : integer = 0;       //32
  nAxis    : integer = 0;       //61
  nArena   : integer = 0;       //04
  nLearning: integer = 0;       //100
  nTreeofKnowledge: integer = 0;//102
  nRumors  : integer = 0;
  nEvents  : integer = 0;

const

  LOADSTEPDESC: Array[-1..20] of string =
  ('-1: loadmap NOT started',  //starting Load
   ' 0: loadmap Starting',
   ' 1: read Header',
   ' 2: read Tiles',
   ' 3: read Def  00%',
   ' 4: read Def  50%',
   ' 5: read Def End',
   ' 6: read Obj  00%',
   ' 7: read Obj  10%',
   ' 8: read Obj  20%',
   ' 9: read Obj  30%',
   '10: read Obj  40%',
   '11: read Obj  50%',
   '12: read Obj  60%',
   '13: read Obj  70%',
   '14: read Obj  80%',
   '15: read Obj  90%',
   '16: read Obj End',
   '17: read Event',
   '18: read Rumor',
   '19: end LoadMap',
   '20: end StartGame') ;

  START_RES: TRES =
    (10,20,30,40,50,60,5000,10); // (100,50,100,50,50,50,100000,10);// (10,5,10,5,5,5,10000,10);//

  START_RESDIF: Array [0..4] of TRES =
  ( (30,	15,	30,	15,	15,	15,	30000,  10),
    (20,	10,	20,	10,	10,	10,	20000,  10),
    (15,	7,	15,	7,	7,	7,	15000,  10),
    (10,	4,	10,	4,	4,	4,	10000,  10),
    (0,	        0,	0,	0,	0,	0,	0,      0)      ) ;

  START_ARMY:TARMYS=
    ((t:-1;n:0),(t:-1;n:0),(t:-1;n:0),(t:-1;n:0),(t:-1;n:0),(t:-1;n:0),(t:-1;n:0));


//*** Qty threshold ***//
  QtyQuelque=  4;
  QtyPlusieurs=9;
  QtyGroupe=  19;
  QtyBeaucoup=49;
  QtyHorde=   99;
  QtyFoule=  249;
  QtyNuee=   499;
  QtyMultitude=999;
  QtyLegion=1000;


  ExpLevel: array [1..15] of integer =
  (0,1000,2000,3200,4500,
  6000,7700,9000,11000,13200,
  15500,18500,22100,26420,31604 );

  RES0_Bois=0;
  RES1_Pierre=1;
  RES2_Mercure=2;
  RES3_Souffre=3;
  RES4_Gem=4;
  RES5_Crystal=5;
  RES6_Or=6;


  // BATTLE Unit
  MO_DOUBLE=$0001;
  MO_FLY=   $0002;
  MO_SHOOT= $0003;

  MO011_Cavalier=11;
  MO056_Skeleton=56;
  MO012_Champion=12;
  MO112_AELEM=112;
  MO113_EELEM=113;
  MO114_FELEM=114;
  MO115_WELEM=115;
  MO118_Catapult=118;
  MO119_Ballista=119;
  MO120_FirstAidTent=120;
  MO121_AmmoCart=121;


  // PSkill and Sec Skill
  PS0_ATT=0;
  PS1_DEF=1;
  PS2_KNO=2;
  PS3_POW=3;

  SK00_Pathfinding=0; //ok reduit penality of mov
  SK01_Archery=1;     //ok cf Ubattle
  SK02_Logistics=2;
  SK03_Scouting=3;
  SK04_Diplomacy=4;
  SK05_Navigation=5;
  SK06_Leadership=6;
  SK07_Wisdom=7;       //ok cf ucmd
  SK08_Mysticism=8;
  SK09_Luck=9;
  SK10_Ballistics=10;
  SK11_Eagle_Eye=11;
  SK12_Necromancy=12;
  SK13_Estates=13;     //ok  cf ucmd
  SK14_Fire_Magic=14;  //ok battle bonus
  SK15_Air_Magic=15;   //ok battle bonus
  SK16_Water_Magic=16; //ok battle bonus
  SK17_Earth_Magic=17; //ok battle bonus
  SK18_Scholar=18;
  SK19_Tactics=19;
  SK20_Artillery=20;
  SK21_Learning=21;
  SK22_Offence=22;
  SK23_Armorer=23;
  SK24_Intelligence=24;
  SK25_Sorcery=25;
  SK26_Resistance=26;
  SK27_First_Aid=27;


  //skill speciality
  SS00_Sklll=0;          //$2 secondary skill number (see Format SS )
  SS01_Creature=1;       //$2 creature type number
  SS02_Ressource=2;      //$2 resource type
  SS03_Spells=3;         //$2=spell number (see Format SP)
  SS04_Creature_extra=4; //$2=creature type number (see Format C )    ATT DEF DMG
  SS05_Speed_other=5;    //$2=subtype
  SS06_Upgrades=6;       //$2=creature1 /2 3 to upg
  SS0_7_Dragons=7;       //ATT DEF



  // Spell type  school and id
  ADV_SPELL=1;
  COMBAT_SPELL=2;
  CREATURE_SPELL=4;
  CREATURE_TARGET=8;
  CREATURE_TARGET_1=16; //(rem spel effect)
  CREATURE_TARGET_2=32;
  LOCATION_TARGET=64;
  OBSTACLE_TARGET=128;
  MIND_SPELL=256;

  SCHOOL3_Earth=3;
  SCHOOL2_Water=2;
  SCHOOL0_Fire=0;
  SCHOOL1_Air=1;
  SCHOOL4_All=4;

  //SP_AdvSpells=0;
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
  SP10_Quicksand=10;
  SP11_LandMine=11;
  SP12_ForceField=12;
  SP13_FireWall=13;
  SP14_Earthquake=14;
  SP15_MagicArrow=15;
  SP16_IceBolt=16;
  SP17_LightningBolt=17;
  SP18_Implosion=18;
  SP19_ChainLightning=19;
  SP20_FrostRing=20;
  SP21_Fireball=21;
  SP22_Inferno=22;
  SP23_MeteorShower=23;
  SP24_DeathRipple=24;
  SP25_DestroyUndead=25;
  SP26_Armageddon=26;
  SP27_Shield=27;
  SP28_AirShield=28;
  SP29_fireShield=29;
  SP30_ProtFromAir=30;
  SP31_ProtFromFire=31;
  SP32_ProtFromWater=32;
  SP33_ProtFromEarth=33;
  SP34_AntiMagic=34;
  SP35_Dispel=35;
  SP36_MagicMirror=36;
  SP37_Cure=37;
  SP38_Resurrection=38;
  SP39_AnimateDead=39;
  SP40_Sacrifice=40;
  SP41_Bless=41;
  SP42_Curse=42;
  SP43_Bloodlust=43;
  SP44_Precision=44;
  SP45_Weakness=45;
  SP46_StoneSkin=46;
  SP47_DisruptingRay=47;
  SP48_Prayer=48;
  SP49_Mirth=49;
  SP50_Sorrow=50;
  SP51_Fortune=51;
  SP52_Misfortune=52;
  SP53_Haste=53;
  SP54_Slow=54;
  SP55_Slayer=55;
  SP56_Frenzy=56;
  SP57_TitansLightningBolt=57;
  SP58_Counterstrike=58;
  SP59_Berserk=59;
  SP60_Hypnotize=60;
  SP61_Forgetfulness=61;
  SP62_Blind=62;
  SP63_Teleport=63;
  SP64_RemoveObstacle=64;
  SP65_Clone=65;
  SP66_FireElemental=66;
  SP67_EarthElemental=67;
  SP68_WaterElemental=68;
  SP69_AirElemental=69;

  
  AR000_Spellbook=0;
  AR001_SpellScroll=1;
  AR002_Grail=2;
  AR003_Catapult=3;
  AR004_Ballista=4;
  AR005_AmmoCart=5;
  AR006_FirstAidTent=6;
  AR007_CentaurAxe=7;
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
  AR045_StillEyeoftheDragon=45;
  AR046_CloverofFortune=46;
  AR047_CardsofProphecy=47;
  AR048_LadybirdofLuck=48;
  AR049_BadgeofCourage=49;
  AR050_CrestofValor=50;
  AR051_GlyphofGallantry=51;
  AR052_Speculum=52;
  AR053_Spyglass=53;
  AR054_AmuletoftheUndertaker=54;
  AR055_VampiresCowl=55;
  AR056_DeadMansBoots=56;
  AR057_GarnitureofInterference=57;
  AR058_SurcoatofCounterpoise=58;
  AR059_BootsofPolarity=59;
  AR060_BowofElvenCherrywood=60;
  AR061_BowstringoftheUnicornsMane=61;
  AR062_AngelFeatherArrows=62;
  AR063_BirdofPerception=63;
  AR064_StoicWatchman=64;
  AR065_EmblemofCognizance=65;
  AR066_StatesmansMedal=66;
  AR067_DiplomatsRing=67;
  AR068_AmbassadorsSash=68;
  AR069_RingoftheWayfarer=69;
  AR070_EquestriansGloves=70;
  AR071_NecklaceofOceanGuidance=71;
  AR072_AngelWings=72;
  AR073_CharmofMana=73;
  AR074_TalismanofMana=74;
  AR075_MysticOrbofMana=75;
  AR076_CollarofConjuring=76;
  AR077_RingofConjuring=77;
  AR078_CapeofConjuring=78;
  AR079_OrboftheFirmament=79;
  AR080_OrbofSilt=80;
  AR081_OrbofTempestuousFire=81;
  AR082_OrbofDrivingRain=82;
  AR083_RecantersCloak=83;
  AR084_SpiritofOppression=84;
  AR085_HourglassoftheEvilHour=85;
  AR086_TomeofFireMagic=86;
  AR087_TomeofAirMagic=87;
  AR088_TomeofWaterMagic=88;
  AR089_TomeofEarthMagic=89;
  AR090_BootsofLevitation=90;
  AR091_GoldenBow=91;
  AR092_SphereofPermanence=92;
  AR093_OrbofVulnerability=93;
  AR094_RingofVitality=94;
  AR095_RingofLife=95;
  AR096_VialofLifeblood=96;
  AR097_NecklaceofSwiftness=97;
  AR098_BootsofSpeed=98;
  AR099_CapeofVelocity=99;
  AR100_PendantofDispassion=100;
  AR101_PendantofSecondSight=101;
  AR102_PendantofHoliness=102;
  AR103_PendantofLife=103;
  AR104_PendantofDeath=104;
  AR105_PendantofFreeWill=105;
  AR106_PendantofNegativity=106;
  AR107_PendantofTotalRecall=107;
  AR108_PendantofCourage=108;
  AR109_EverflowingCrystalCloak=109;
  AR110_RingofInfiniteGems=110;
  AR111_EverpouringVialofMercury=111;
  AR112_InexhaustibleCartofOre=112;
  AR113_EversmokingRingofSulfur=113;
  AR114_InexhaustibleCartofLumber=114;
  AR115_EndlessSackofGold=115;
  AR116_EndlessBagofGold=116;
  AR117_EndlessPurseofGold=117;
  AR118_LegsofLegion=118;
  AR119_LoinsofLegion=119;
  AR120_TorsoofLegion=120;
  AR121_ArmsofLegion=121;
  AR122_HeadofLegion=122;
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
  AR133_StatueofLegion=133;
  AR134_PoweroftheDragonFather=134;
  AR135_TitansThunder=135;
  AR136_AdmiralsHat=136;
  AR137_BowoftheSharpshooter=137;
  AR138_WizardsWell=138;
  AR139_RingoftheMagi=139;
  AR140_Cornucopia=140;

//Visited Object on map Type value
  {OB100_LearningStone:         VisObjId:=0;    // (100)
   OB23_MarlettoTower:          VisObjId:=1;    // (23)
   OB32_GardenofRevelation:     VisObjId:=2;    // (32)
   OB51_MercenaryCamp:          VisObjId:=3;    // (51)
   OB61_StarAxis :              VisObjId:=4;    // (61)
   OB102_TreeOfKnowledge:       VisObjId:=5;    // (102)
   OB41_LibraryOfEnlightenment: VisObjId:=6;    // (41)
   OB04_Arena :                 VisObjId:=7;    // (4)
   OB47_SchoolofMagic:          VisObjId:=8;    // (47)
   OB107_SchoolofWar:           VisObjId:=9;}   // (107)


//Object on map Type value
  OB04_Arena=4;
  OB05_Artifact=5;
  OB06_Pandora=6;
  OB08_Boat=8;
  OB09_BorderGuard=9;
  OB10_KeyMaster=10;
  OB11_Buoy=11;
  OB12_Fire=12;
  OB13_Cartographer=13;
  OB14_SwanPond=14;
  OB15_CoverofDarkness=15;
  OB16_CreatureBank=16;
  OB17_Generator=17;
  OB20_Golem=20;
  OB22_Corpse=22;
  OB23_MarlettoTower=23;
  OB24_DerelictShip=24;
  OB25_DragonUtopia=25;
  OB26_Event=26;
  OB27_EyeoftheMagi=27;
  OB28_Faery=28;
  OB29_FlotSam=29;
  OB30_FountainofFortune=30;
  OB31_FountainofYouth=31;
  OB32_Garden=32;
  OB33_Garnison=33;
  OB34_Hero=34;
  OB35_HillFort=35;
  OB36_Grail=36;
  OB37_HutoftheMagi=37;
  OB38_IdolofFortune=38;
  OB39_LeanTo=39;
  OB41_Library=41;
  OB42_Lighthouse=42;
  OB43_Monolith_entrance=43;
  OB44_Monolith_exit=44;
  OB45_Monolith_2way=45;
  OB47_SchoolofMagic=47;
  OB48_MagicSpring=48;
  OB49_MagicWell=49;
  OB50_MKTT=50;
  OB51_MercenaryCamp=51;
  OB52_Mermaid=52;
  OB53_Mine=53;
  OB54_Monster=54;
  OB55_MysticalGarden=55;
  OB56_Oasis=56;
  OB57_Obelisk=57;
  OB58_Tree=58;
  OB59_Bottle=59;
  OB60_PillarofFire=60;
  OB61_StarAxis=61;
  OB62_Prison=62;
  OB63_Pyramid=63;
  OB64_RallyFlag=64;
  OB65_AvaRnd=65;
  OB76_ResRnd=76;
  OB78_RefugeeCamp=78;
  OB79_Res=79;
  OB80_Sanctuary=80;
  OB81_Schoolar=81;
  OB82_SeeChest=82;
  OB83_Seer=83;
  OB84_Crypt=84;
  OB85_Shipwreck=85;
  OB86_Survivor=86;
  OB87_ShipYeard=87;
  OB88_ShrineofMagicIncantation=88;
  OB89_ShrineofMagicGesture=89;
  OB90_ShrineofMagicThought=90;
  OB91_Sign=91;
  OB92_Sirens=92;
  OB93_Scroll=93;
  OB94_Stables=94;
  OB95_Tavern=95;
  OB96_Temple=96;
  OB97_DenofThieves=97;
  OB98_City=98;
  OB99_TradingPost=99;
  OB100_LearningStone=100;
  OB101_TreasureChest=101;
  OB102_TreeofKnowledge=102;
  OB103_Gate=103;
  OB105_Wagon=105;
  OB106_WarMachineFactory=106;
  OB107_SchoolofWar=107;
  OB108_WarriorsTomb=108;
  OB109_WaterWheel=109;
  OB110_WaterHole=110;
  OB111_WaterWhirl=111;
  OB112_WindMill=112;
  OB113_WitchHut=113;
  OB212_BorderGate=212;
  OB215_BorderGate1=215;
  OB215_Generator=215;
  OB216_Generator=216;
  OB217_Generator=217;
  OB218_Generator=218;
  OB220_ABmine=220;

//*** Construct type value ***//
  Cons0_Town=0;
  Cons1_City=1;
  Cons2_Capitol=2;
  Cons3_Fort=3;
  Cons4_Citadel=4;
  Cons5_Castle=5;
  Cons6_Tavern=6;
  Cons7_Blacksmith=7;
  Cons8_Market=8;
  Cons9_Silo=9;
  Cons10_Artifact=10;
  Cons11_Mage1=11;
  Cons12_Mage2=12;
  Cons13_Mage3=13;
  Cons14_Mage4=14;
  Cons15_Mage5=15;
  Cons16_Shipyard=16;
  Cons17_Grail=17;
  Cons18_SP1=18;
  Cons19_SP2=19;
  Cons20_SP3=20;
  Cons21_SP4=21;

  Cons22_StdCr0=22;
  Cons23_UpgCr0=23;
  Cons24_MorCr0=24;
  Cons25_StdCr1=25;
  Cons26_UpgCr1=26;
  Cons27_MorCr1=27;
  Cons28_StdCr2=28;
  Cons29_UpgCr2=29;
  Cons30_MorCr2=30;
  Cons31_StdCr3=31;
  Cons32_UpgCr3=32;
  Cons33_MorCr3=33;
  Cons34_StdCr4=34;
  Cons35_UpgCr4=35;
  Cons36_MorCr4=36;
  Cons37_StdCr5=37;
  Cons38_UpgCr5=38;
  Cons39_StdCr6=39;
  Cons40_UpgCr6=40;


implementation


end.
