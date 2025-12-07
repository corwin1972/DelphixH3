unit USnBattleField;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Math,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWLoad , DXWControls, DXWScene, UConst, UDef, UBattle,USnBattleOption, USnInfoUnit, USnInfoBHero;

type
  TSnBattleField= class (TDxScene)
  private
    DxO_Button, DxO_Effect, DxO_Unit,DxO_NextUnit: integer;
    DxO_Sel1, DxO_Sel2, DxO_Hint: integer;
    DxO_Tower, DxO_DRW, DxO_W1, DxO_W3, DxO_W4, DxO_W6,
    DxO_Hero, DxO_Info, DxO_SPA, DxO_Cast, DxO_Shot, Dxo_chain: integer;
    DxO_Luck, DxO_Moral, DxO_Heal, DxO_Def,DxO_Grid: integer;
    DxO_quicksand,DxO_landMine,DxO_fireWall,
    DxO_bigForceField0,DxO_bigForceField1,DxO_smallForceField0,DxO_smallForceField1:     integer;
    bLogId:integer;
    pType: integer;
    pSpin: boolean;
    procedure CreateHero;
    procedure CreateUnit;
    procedure AddUnit(uid, x,y: integer);
    procedure CreateWall;
    procedure Create_CR_Shot;
    procedure Create_SP_Shot;
    procedure CreateEffect;
    procedure CreateProj;
    procedure CreateCursor;
    procedure CreateButton;
    procedure CreateNextUnit;
    procedure CreateBattlefield;
    procedure BtnOption(Sender: TObject);
    procedure DestroyWall;
    procedure RefreshWall;
    procedure BtnBattleLog(Sender: TObject);
    procedure BtnAutoBattle(Sender: TObject);
    procedure BtnFleeBattle(Sender: TObject);
    procedure BtnBook(Sender: TObject);
    procedure BtnDef(Sender: TObject);
    procedure BtnWait(Sender: TObject);
    procedure BtnUP(Sender: TObject);
    procedure BtnDOWN(Sender: TObject);
    procedure BtnEdit(Sender: TObject);
    procedure EndBattle;
    function ComputeDirTag(a,b: integer): integer;
    procedure SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    procedure UpdateUnitAnim(uid: integer);
    procedure UpdateUnitPic(uid,anim,pos: integer);
    procedure ChangeUnitAnim(uid,AnimType: integer);
    procedure UpdateUnit;
    procedure UpdateAttak;
    procedure UpdateReplyAtt;
    procedure UpdateReplyDmg;
    procedure UpdateReplyDeath;
    procedure UpdateDmgAll;
    procedure UpdateDmg;
    procedure UpdateDeath;
    procedure UpdateMove;
    procedure UpdateState;
    procedure UpdateEffectLuck;
    procedure UpdateEffectMoral;
    procedure UpdateEffectHeal;
    procedure UpdateEffectDef;
    procedure UpdateEffect(pEffect: TDXwPanel; id: integer);
    procedure UpdateHeroCastSpell;
    procedure UpdateSpell;
    procedure CreateCast;
    procedure UpdateCast;
    procedure UpdateCastEnd;
    procedure PrepareCastEnd;
    procedure StartShot;
    procedure UpdateProj;
    procedure DestroyProj;
    procedure UpdateShot;
    procedure UpdateCatapult;
    procedure UpdateStartShot;
    procedure FlyUnit ;
    procedure WalkUnit ;
    procedure AdaptUnitPos;
    procedure PlaceObstacle;
    procedure UpdateAction;
    procedure UpdateUnitPos(uid: integer);
  public
    constructor Create;
    procedure ProcessAction; override;
    procedure SnDraw(Sender:TObject);
    procedure DrawCursor;
    procedure DrawUnit;
    procedure DrawUnitRange;
    procedure DrawGrid;
    procedure DrawHint;
    procedure DrawMassSpell;
    procedure SummonUnit(uid:integer);
    procedure MakeLighningArc(u: integer);
    procedure drawLightning(DIB: TDIB;x1,y1,x2,y2 :integer;displace,mindisplace : single) ;
  end;


implementation

uses UMain, USnHero, USnGame, USnSelect, UType,  UsnBattleResult, USnBook, UFile, UEnter,USnDialog;

const

  SA0_Prayer=0;
  SA1_Lightning=1;
  SA2_Air_Shield=2;
  SA3_Magic_Mirror=3;
  SA4_Regeneration=4;
  SA5_AntiMagic=5;
  SA6_Blind=6;
  SA7_Counterstrike=7;
  SA8_Death_Ripple=8;
  SA9_Inferno=9;
  SA10_Implosion=10;
  SA11_Fire_Shield=11;
  SA12_Armageddon=12;
  SA13_Disrupting_Ray_fly=13;
  SA14_Disrupting_Ray_hit=14;
  SA15_Fear=15;
  SA16_Meteor_Shower=16;
  SA17_Frenzy=17;
  SA18_Good_Luck=18;
  SA19_Slow=19;
  SA20_Good_Morale=20;
  SA21_Hypnotize=21;
  SA22_Protection_from_Air=22;
  SA23_Protection_from_Water=23;
  SA24_Protection_from_Fire=24;
  SA25_Precision=25;
  SA26_Protection_from_Earth=26;
  SA27_Shield=27;
  SA28_Slayer=28;
  SA29_Destroy_Undead=29;
  SA30_Bad_Morale=30;
  SA31_Haste=31;
  SA32_Force_Field_S=32;
  SA33_Force_Field_L=33;
  SA34_Remove_Obstacle=34;
  SA35_Berserk=35;
  SA36_Bless=36;
  SA37_Lightning_bolt=37;
  SA38_Lightning_hitting_target=38;
  SA39_Cure=39;
  SA40_Curse=40;
  SA41_Dispel=41;
  SA42_Forgetfulness=42;
  SA43_Fire_Wall_S_start=43;
  SA44_Fire_Wall_L_start=44;
  SA45_Frost_Ring=45;
  SA46_Ice_Bolt_hit=46;
  SA47_Land_Mine_start=47;
  SA48_Bad_Luck=48;
  SA49_Lightning_hit=49;
  SA50_First_Aid_Heal=50;
  SA51_Sacrifice=51;
  SA52_First_Aid_Tent_Heal2=52;
  SA53_Fireball=53;
  SA54_Stone_Skin=54;
  SA55_Quicksand_start=55;
  SA56_Weakness=56;
  SA57_Land_Mine=57;
  SA58_Quicksand_end=58;
  SA59_Land_Mine_start=59;
  SA60_Forcefield_start=60;
  SA61_Forcefield_start=61;
  SA62_Fire_Wall_S_start=62;
  SA63_Fire_Wall_L_start=63;
  SA64_Magic_Arrow_hit=64;
  SA65_Fire_Wall_start=65;
  SA69_Disease=69;
  SA70_Paralyze=70;
  SA71_Aging=71;
  SA72_Death_Cloud=72;
  SA73_Death_Strike=73;
  SA74_First_Aid_Heal3=74;
  SA75_Mana_Absorbtion=75;
  SA76_Mana_Given=76;
  SA77_Mana_Drain=77;
  SA78_Magic_Resistance=78;
  SA79_Healing=79;
  SA80_Death_Stare=80;
  SA81_Weakness=81;
  SA82_Small_explosion=82;
  SA83_Gain_Lifeforce=83;
  SA84_Block_ability=84;

{----------------------------------------------------------------------------}
procedure TSnBattleField.BtnEdit(Sender: TObject);
//interface to show spell animation
var
  id:integer ;
begin
  //Cmd_Parse(TDXWEdit(sender).Text);
  //ProcessInfo(TDxWEdit(sender).Text + chr(10) + mDialog.mes);
  for id:= 0 to 82 do
  TDXwPanel(ObjectList.Items[iEFFECT[0].obid+id]).visible:=false;

  id:=strtoint(TDxWEdit(sender).Text);
  TDXwPanel(ObjectList.Items[iEFFECT[0].obid+id]).visible:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.CreateButton;
begin
  AddPanel('COPLACBR',0,556);
  AddPanel('CROLLOVR',216,562,BtnBattleLog);
  DxO_Button:=ObjectList.count;
  AddButton('ICM003',3,560,BtnOption);          //Option
  AddButton('ICM001',54,560,BtnFleeBattle);     //Redition
  AddButton('ICM002',105,560,BtnFleeBattle);    //Flee
  AddButton('ICM004',156,560,BtnAutoBattle);    //AutoBattle
  AddButton('COMSLIDEUP',624,560,BtnUP);        //BText Prev
  AddButton('COMSLIDEDN',625,579,BtnDown);      //BText Next
  AddButton('ICM005',646,560,BtnBook);          //Magie
  AddButton('ICM006',697,560,BtnWait);          //Wait
  AddButton('ICM007',748,560,BtnDef);           //Defend
  //AddEdit('Edit',5,525,BtnEdit);
  DxO_Info:=ObjectList.count;
  AddLabel('--Info on Action--',54,1);
  AddLabel('Battle History',220,580);
  TDXwLabel(Objectlist.Items[DxO_Info]).Font.Color:=ClBlack;
  TDXwLabel(Objectlist.Items[DxO_Info+1]).Font.Color:=ClYellow;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.CreateBattlefield;
var
  s: string;
begin
  if bCT > -1
  then
    s:='SG'+TN_INITIAL[mCitys[bCT].t]+ 'BACK'
  else
  case bTR of
    0: s:='CMBKDRTR';
    1: s:='CMBKDES';
    2: s:='CMBKGRTR';
    3: s:='CMBKSNTR';
    4: s:='CMBKSWMP';
    5: s:='CMBKRGH';
    6: s:='CMBKSUB';
    7: s:='CMBKLAVA';
    8: s:='CMBKDECK';
  else s:='CMBKGRTR';
  end;
  AddBackground(s);
  FHeight:=600;
  OpShowBattleGrid:=true;
  DxO_Grid:=ObjectList.count;
  AddPanel('ImGrid',59,85);
  AddImage('Cell_Shadow');
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.CreateCursor;
begin
  LoadSprite(ImageList,'CRCOMBAT');
  DxMouse.style:=msCbt;
  DxMouse.id:=CrDef;
  HintY:=Top+562;
  HintX:=Left+220;
  OnMouseMove:=SnMouseMove;
  OnMouseDown:=SnMousedown;
end;
{----------------------------------------------------------------------------}
constructor TSnBattleField.Create;
var
  tempbackground: integer;
begin
  if mPlayers[mPL].isCPU  then
  begin
    cmd_BA_AutoBattle;
    cmd_BA_Exp;
    cmd_BA_End;
    exit;
  end;
  inherited Create('SnBattleField');
  AllClient:=true;
  CreateBattleField;
  CreateNextUnit;
  if bCT > -1 then CreateWall;
  CreateHero;
  CreateUnit;
  CreateButton;
  CreateCursor;
  OnDraw:=SnDraw;
  Create_CR_Shot;
  Create_SP_Shot;
  CreateEffect;
  AddScene;
  UpdateUnit;
  tempbackground:=background;
  background:=-1;
  UpdateColor(mPL,1);
  background:=tempbackground;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.RefreshWall;
begin
  // destroyable 1,4, 5, 7, 10
  TDXwPanel(Objectlist.Items[DxO_W1]).Visible :=   (bWall[10]=2);   //9 non desctructible
  TDXwPanel(Objectlist.Items[DxO_W1+1]).Visible := (bWall[10]=1);
  TDXwPanel(Objectlist.Items[DxO_W1+2]).Visible := (bWall[10]=0);   //9 non desctructible

  TDXwPanel(Objectlist.Items[DxO_W3]).Visible :=   (bWall[7]=2);
  TDXwPanel(Objectlist.Items[DxO_W3+1]).Visible := (bWall[7]=1);
  TDXwPanel(Objectlist.Items[DxO_W3+2]).Visible := (bWall[7]=0);

  //TDXwPanel(Objectlist.Items[DxO_DRW]).Visible := (bWall[5]=2)
  //TDXwPanel(Objectlist.Items[DxO_DRW+1]).Visible := (bWall[5]=2);
  TDXwPanel(Objectlist.Items[DxO_DRW+2]).Visible := (bWall[5]=0);

  TDXwPanel(Objectlist.Items[DxO_W4]).Visible :=   (bWall[4]=2);
  TDXwPanel(Objectlist.Items[DxO_W4+1]).Visible := (bWall[4]=1);
  TDXwPanel(Objectlist.Items[DxO_W4+2]).Visible := (bWall[4]=0);

  TDXwPanel(Objectlist.Items[DxO_W6]).Visible :=   (bWall[1]=2);
  TDXwPanel(Objectlist.Items[DxO_W6+1]).Visible := (bWall[1]=1);
  TDXwPanel(Objectlist.Items[DxO_W6+2]).Visible := (bWall[1]=0);  //1  non desctructible
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.CreateWall;
var
  s: string;
  iW: TInfoWalls;
begin
  //DxO_Tower:=ObjectList.count;
  //Addunit(30,400,200);
  //Addunit(31,500,300);
  //Addunit(32,400,400);
{
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

  s:='SG'+TN_INITIAL[mCitys[bCT].t];    // SGST for stronghold
  //if fossé do
  //AddPanel(s+'MLIP',390,25);  // 13/14. mlip,
  //if pont levis ouvert

  iW:=iWall[mCitys[bCT].t];

  DxO_DRW:=ObjectList.count;
  AddPanel(s+'DRW2',iW[1].pos.x,iW[1].pos.y);
  TDXwPanel(Objectlist.Items[DxO_DRW]).Visible:=false;
  AddPanel(s+'DRWC',iW[1].pos.x,iW[1].pos.y);
  TDXwPanel(Objectlist.Items[DxO_DRW+1]).Visible:=false;
  AddPanel(s+'DRW3',iW[1].pos.x,iW[1].pos.y);
  TDXwPanel(Objectlist.Items[DxO_DRW+2]).Visible:=false;

  if FileExists(Folder.bmp+s+'TPWL'+'.bmp') then
  AddPanel(s+'TPWL',iW[2].pos.x,iW[2].pos.y)            // 01. HR backgtound top wall
  else
  AddPanel(s+'TPW1',iW[2].pos.x,iW[2].pos.y);           // 07. upper wall,      SGCSTPW1 hs ?


  AddPanel(s+'TW21',iW[9].pos.x,iW[9].pos.y);           // 17. toptower         "TW21"     "TW2C"

  DxO_W6:=ObjectList.count;
  AddPanel(s+'WA61',iW[13].pos.x,iW[13].pos.y);         // 07. upper            "WA61" ... "WA63"
  AddPanel(s+'WA62',iW[13].pos.x,iW[13].pos.y);         // 07. upper            "WA61" ... "WA63"
  AddPanel(s+'WA63',iW[13].pos.x,iW[13].pos.y);         // 07. upper            "WA61" ... "WA63"

  AddPanel(s+'WA5',iW[4].pos.x,iW[4].pos.y);            // 12. upper non destru "WA5"

  DxO_W4:=ObjectList.count;
  AddPanel(s+'WA41',iW[14].pos.x,iW[14].pos.y);         // 06. upMid 12         "WA41" ... "WA43"
  AddPanel(s+'WA42',iW[14].pos.x,iW[14].pos.y);         // 06. upMid 12         "WA41" ... "WA43"
  AddPanel(s+'WA43',iW[14].pos.x,iW[14].pos.y);         // 06. upMid 12         "WA41" ... "WA43"

  AddPanel(s+'MAN1',iW[7].pos.x,iW[7].pos.y);           // 15. keep             "MAN1"     "MANC"
  AddPanel(s+'ARCH',iW[0].pos.x,iW[0].pos.y);           // 09. gate             "ARCH"

  DxO_W3:=ObjectList.count;
  AddPanel(s+'WA31',iW[12].pos.x,iW[12].pos.y);         // 05. botMid           "WA31" ... "WA33"
  AddPanel(s+'WA32',iW[12].pos.x,iW[12].pos.y);         // 05. botMid           "WA31" ... "WA33"
  AddPanel(s+'WA33',iW[12].pos.x,iW[12].pos.y);         // 05. botMid           "WA31" ... "WA33"

  AddPanel(s+'WA2',iW[3].pos.x,iW[3].pos.y);            // 11. bottom non destr "WA2"

  DxO_W1:=ObjectList.count;
  AddPanel(s+'WA11',iW[11].pos.x,iW[11].pos.y);         // 04. bottom           "WA11" ... "WA13"
  AddPanel(s+'WA12',iW[11].pos.x,iW[11].pos.y);         // 04. bottom           "WA11" ... "WA13"
  AddPanel(s+'WA13',iW[11].pos.x,iW[11].pos.y);         // 04. bottom           "WA11" ... "WA13"

  AddPanel(s+'TW11',iW[5].pos.x,iW[5].pos.y);           // 16. bottower         "TW11"     "TW1C

 
  RefreshWall;
{"top" :
"tower" :     // "TW21" ... "TW22"
"battlement" :// "TW2C"
"creature" :
// Central keep description
"keep" :
"tower" :       // "MAN1" ... "MAN2"
"battlement" :  // "MANC"
"creature" :
// Bottom tower description
"bottom" :
"tower" :       // "TW11" ... "TW12"
"battlement" :  // "TW1C"
"creature" :
//Two parts of gate: gate itself and arch above it
"gate" :
"gate" :        // "DRW1" ... "DRW3" and "DRWC" (rope)
"arch" :        // "ARCH"
// Destructible walls. In this example they are ordered from top to bottom
// Each of them consist from 3 files: undestroyed, damaged, destroyed
"walls" :
"upper"     :   // "WA61" ... "WA63"
"upperMid"  :   // "WA41" ... "WA43"
"bottomMid" :   // "WA31" ... "WA33"
"bottom"    :   // "WA11" ... "WA13"
// Two pieces for moat: moat itself and shore
"moat" :  // moat: "MOAT", shore: "MLIP"
// Static non-destructible walls. All of them have only one piece
"static" :
// Section between two bottom destructible walls
"bottom" :      // "WA2"
// Section between two top destructible walls
"top" :         // "WA5"
// Topmost wall located behind hero
"background" :  // "TPWL"
;}

end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.CreateHero;
begin
  DxO_Hero:=ObjectList.count;
    AddSPRPanel('ABF01'+PL_INITIAL[mHeros[bHeroLeft].pid],1,21);
    AddSPRPanel('CH0'+inttostr(bHeroLeft div 8),-40,-20);
  if (bHeroRight > -1) then
  begin
    AddSPRPanel('ABF01'+PL_INITIAL[mHeros[bHeroRight].pid],704,21);
    AddSPRPanel('CH0'+inttostr(bHeroRight div 8),690,-20);
    TDXwPanel(Objectlist.Items[DxO_Hero+2]).MirrorH:=true;
    TDXwPanel(Objectlist.Items[DxO_Hero+3]).MirrorH:=true;
  end;
end;
{----------------------------------------------------------------------------}
procedure TsnBattleField.CreateUnit;
var
  sx,sy,i:integer;
  NB,MO: integer;
  s:string;
   iW: TInfoWalls;
begin
  AddImage('CrQTY_0');    //CMNUMWIN.BMP    + alpha transform RED
  AddImage('CrQTY_1');    //CMNUMWIN.BMP    + alpha transform BLUE
  DxO_Sel2:=ObjectList.count;
  AddPanel('Cell_Blue',0,0);
  TDXwPanel(Objectlist.Items[DxO_Sel2]).Visible:=false;
  DxO_Sel1:=ObjectList.count;
  AddPanel('Cell_Red',0,0);
  if bCT > -1 then begin
    s:='SG'+TN_INITIAL[mCitys[bCT].t];
  iW:=iWall[mCitys[bCT].t];
  end;

  DxO_Unit:=ObjectList.count;
  for i:=0 to 41 do
  begin
    NB:=bUnits[i].n;
    MO:=bUnits[i].t;
    if (MO <> -1) then //(NB > 0) and
    begin
      with bUnits[i] do
      begin
        sx:=Hex2PosXY(x,y).x-172;
        sy:=Hex2PosXY(x,y).y-225;
        if dirLeft then
        begin
          sx:=sx-59;
          //if is2HexCR(i) then sx:=sx+42;
        end;

        Case BUnits[i].tower of
          1: begin
            sx:=iW[6].pos.x; //346;
            sy:=iW[6].pos.y; //-175;
          end;
          2: begin
            sx:=iW[8].pos.x; //499;
            sy:=iW[8].pos.y; //-16;
          end;
          3: begin
            sx:=iW[10].pos.x; //355;
            sy:=iW[10].pos.y; //311;
          end;
        end;
        AddUnit(i,sx,sy);
        if NB=0 then TDXWPanel(Objectlist.Items[DxO_Unit+i]).Visible:=false;
      end;
    end
    else
    begin
      AddLabel('',0,0);
      TDXWLabel(Objectlist.Items[DxO_Unit+i]).Visible:=false;
    end;
  end;

  //add cover
  if BCT >-1 then begin
  //AddTowerCrea    no needed see BUnits[i].tower
  DxO_Tower:=ObjectList.count;
  AddPanel(s+'TW1C',iW[5].pos.x,iW[5].pos.y);           // 04. bottom          "TW1C"
  AddPanel(s+'MANC',iW[7].pos.x,iW[7].pos.y);           // 04. bottom          "MANC"
  AddPanel(s+'TW2C',iW[9].pos.x,iW[9].pos.y);           // 04. bottom          "WTW1C"
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.CreateNextUnit;
var
  i:integer;
begin
  DxO_NextUnit:=ObjectList.count;
  for i:=0 to 7 do begin
     //AddSprPanel('TWCRPORT',62+62*i,18);
     //AddSprPanelSelectedImage(DxO_NextUnit+i,'CPrLXXX');
    AddSprPanel('CPRSMALL',64+44*i,30);
    TDXwPanel(Objectlist.Items[DxO_NextUnit+i]).tag:=i;
    AddSprPanelSelectedImage(DxO_NextUnit+i,'CPrSXXX');
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.Create_CR_Shot;
var
  i:integer;
  Cr: integer;
begin
  i:=0;
  DxO_Shot:=ObjectList.count;
  for CR:=0 to MAX_CREA-1 do
  if  iCrea[CR].shotdef <> '' then
  begin
    AddSprPanel(iCrea[CR].shotdef,50,50);
    TDXwPanel(Objectlist.Items[DxO_Shot+i]).visible:=false;
    inc(i);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.Create_SP_Shot;
var
  i:integer;
begin
  DxO_chain:=ObjectList.count;
  AddSprPanel('C0CHAIN',59,50);
  with TDXwPanel(Objectlist.Items[DxO_Chain]) do
  begin
    visible:=false;
    top:=0;
    left:=0;
    image.transparent:=true;
    image.transparentcolor:=clBlack;
  end;
  DxO_Cast:=ObjectList.count;
  //magicarrow
  for i:=0 to 4 do
  begin
    AddSprPanel('C20SPX'+inttostr(i),50,50);
    TDXwPanel(Objectlist.Items[DxO_Cast+i]).visible:=false;
  end;
    AddSprPanel('C20SPX',50,50);
    TDXwPanel(Objectlist.Items[DxO_Cast+5]).visible:=false;
  //icebolt
  for i:=0 to 5 do
  begin
    AddSprPanel('C08SPW'+inttostr(i),50,50);
    TDXwPanel(Objectlist.Items[DxO_Cast+6+i]).visible:=false;
  end;
  //Lightning bolt fixed
  AddSprPanel('C03SPA0',50,50);
  TDXwPanel(Objectlist.Items[ObjectList.count-1]).visible:=false;
  //Lightning bolt EXPLOSION
  for i:=0 to 4 do
  begin
  AddSprPanel('C03SPA1',50,50);
  TDXwPanel(Objectlist.Items[ObjectList.count-1]).visible:=false;
  end;


end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.CreateEffect;
  //hypnotyse  C10SPA0
  //luck       C09SPW0
  //def        C13SPE0
  //noluck     C14SPE0
var
  i:integer;
  s:string;
begin
  //create permanent effect

  DxO_Quicksand:=AddSprPanel('C17SPE1', 255,10);
  DxO_LandMine:=AddSprPanel('C09SPF1', 305,10);
  DxO_FireWall:=AddSprPanel('C07SPF61', 355,10);
  DxO_BigForceField0:=AddSprPanel('C15SPE10', 405,10);
  DxO_BigForceField1:=AddSprPanel('C15SPE7', 455,10);
  DxO_SmallForceField0:=AddSprPanel('C15SPE1', 505,10);
  DxO_SmallForceField1:=AddSprPanel('C15SPE4', 555,10);

  for i:=DxO_QuickSand to  DxO_QuickSand+6 do
    TDXwPanel(ObjectList.Items[i]).Visible:=false;

  //create animated effect
  DxO_Effect:=ObjectList.count;
  for i:=0 to  82 do
  begin
    //for j:=0 to iEFFECT[i].n - 1 do
    s:=iEFFECT[i].defs[0];
    if s='' then s:=iEFFECT[5].defs[0];
    AddSprPanel(s,65 * (i mod 12),65*(i div 12));
    TDXwPanel(ObjectList.Items[DxO_Effect+i]).Visible:=false;
    TDXwPanel(ObjectList.Items[DxO_Effect+i]).tag:=2;
    iEFFECT[i].obid:=DxO_Effect+i;
  end;

  DxO_Moral:=iEFFECT[SA20_Good_Morale].obid;
  DxO_Def:=  iEFFECT[SA27_Shield].obid;
  DxO_Luck:= iEFFECT[SA30_Bad_Morale].obid;
  DxO_Heal:= iEFFECT[SA79_Healing].obid;
end;



{----------------------------------------------------------------------------}
procedure TSnBattleField.SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  s:string ;
begin
  cmd_BA_Info(x,y,s);
  if s<>'' then Hint:=s;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  CR: integer;
begin
  if DxMouse.id=CrBaHero then
  begin
    if (x<60)
    then  TSnInfoBHero.Create(bHeroLeft,0)
    else  TSnInfoBHero.Create(bHeroRight,1);
    exit;
  end;

  if button = mbLeft then
  begin
    DxMouse.sx:=DxMouse.mx;
    DxMouse.sy:=DxMouse.my;
    cmd_BA_MoveTo(DxMouse.sX,DxMouse.sY,DxMouse.id);
  end
  else
  begin
    CR:=bTiles[DxMouse.mX,DxMouse.my];
    if CR> -1 then
      TSnInfoUnit.Create(CR)
    else
      if bState=bsSpell then cmd_BA_CancelSpellAction;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.BtnBook(Sender: TObject);
var
  HE:integer;
begin
  if bSide=SD_LEFT then HE:=bHeroLeft else HE:=bHeroRight;
  if HE=-1 then exit;
  TSnBook.create(HE)
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.BtnBattleLog(Sender: TObject);
begin
  processInfoScroll( '{Battle logs}' + chr(10) +bText.Text);
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.BtnFleeBattle(Sender: TObject);
begin
  cmd_BA_FleeBattle(0);
  EndBattle;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.BtnOption(Sender: TObject);
begin
  TSnBattleOption.Create;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.BtnAutoBattle(Sender: TObject);
begin
  cmd_BA_AutoBattle;
  EndBattle;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.BtnDef(Sender: TObject);
begin
  if ((bAction=bActionNo) and
  ( (bState = BsPlay) or (bState = BsRePlay)) and
  ( (oState = BsPlay) or (oState = BsRePlay)))
  then  cmd_BA_Def;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.BtnWait(Sender: TObject);
begin
    if ((bAction=bActionNo) and
  ( (bState = BsPlay) or (bState = BsRePlay)) and
  ( (oState = BsPlay) or (oState = BsRePlay)))
  then  cmd_BA_Wait;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.BtnUP(Sender: TObject);
begin
  DxO_Hint:=DxO_Hint-1;
  if DxO_Hint<0 then DxO_Hint:=max(0,bText.Count-1);
  TDXWLabel(ObjectList[DxO_Info+1]).caption:=inttostr(DxO_Hint) + ' - ' + bText[DxO_Hint];
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.BtnDown(Sender: TObject);
begin
  DxO_Hint:=DxO_Hint+1;
  if DxO_Hint>=bText.Count then  DxO_Hint:=0;
  TDXWLabel(ObjectList[DxO_Info+1]).caption:=inttostr( DxO_Hint) + ' - ' + bText[DxO_Hint];
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.CreateCast;
var
  i,j,k,l, x0,Y0, x1, Y1: integer;
begin
  j:=-1;
  if bSide=SD_LEFT then i:=-1 else i:=14;
  x0:=Hex2PosXY(i,j).x- hexww;
  y0:=Hex2PosXY(i,j).y-15;

  k:=bUnits[bTgt].x+1;
  l:=bUnits[bTgt].y;

  if bSide=SD_LEFT
  then x1:=Hex2PosXY(k,l).x-hexww
  else x1:=Hex2PosXY(k,l).x+5;
  y1:=Hex2PosXY(k,l).y+5;

  pType:=ComputeDirTag(abs(x1-x0),y1-y0)-4 ;

  case bSpel of
    SP15_MagicArrow :   pType:=pType;
    SP16_IceBolt    :   pType:=pType+6;
    SP17_LightningBolt: pType:=12;
    SP19_ChainLightning : begin
      pType:=12;
      cmd_SP_ChainDMG_Prepare(bSpel);
    end;
    //else              pType:=pType;
  end;

  case bSpel of
    SP15_MagicArrow, SP16_IceBolt :
    begin
      if bSide=SD_LEFT
      then x1:=Hex2PosXY(k,l).x-hexww- (TDXwPanel(Objectlist.Items[DxO_Cast+ pType]).image.width  div 2)
      else x1:=Hex2PosXY(k,l).x+5    - (TDXwPanel(Objectlist.Items[DxO_Cast+ pType]).image.width  div 2);
      y1:=Hex2PosXY(k,l).y+5         - (TDXwPanel(Objectlist.Items[DxO_Cast+ pType]).image.height div 2);
      bActionTime:=2*(1+abs(i-k)+abs(j-l));
      bproj.x:=(x1-x0) div (bActionTime-1);
      bproj.y:=(y1-y0) div (bActionTime-1);
    end;
    SP17_LightningBolt, SP19_ChainLightning:
    begin
      x0:=Hex2PosXY(k,l).x+20- (TDXwPanel(Objectlist.Items[DxO_Cast+ pType]).image.width div 2);
      y0:=Hex2PosXY(k,l).y+20- (TDXwPanel(Objectlist.Items[DxO_Cast+ pType]).image.height);
      bActionTime:=8;
      bproj.x:=0;
      bproj.y:=0;
    end;
  end;

  with TDXwPanel(Objectlist.Items[DxO_Cast+ pType]) do
  begin
    left:=x0;
    top:=y0;
    visible:=true;
    tag:=0;
    if bSide=SD_LEFT then MirrorH:=false else  MirrorH:=true;
  end;

end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateCast;
begin
  case bSpel of
    SP15_MagicArrow,SP16_IceBolt,SP17_LightningBolt:
    begin
      if bActionTime = 0 then CreateCast;
      dec(bActionTime);
      with TDXwPanel(Objectlist.Items[DxO_Cast+ pType]) do
      begin
        left:=left+bProj.x;
        top:= top+ bProj.y;
        tag:=tag+1;
        if tag=image.patterncount then tag:=0;
      end;
      if bActionTime = 0 then
      begin
        TDXwPanel(Objectlist.Items[DxO_Cast+ pType]).visible:=false;
        PrepareCastEnd;
      end;
    end;
    SP19_ChainLightning:
    begin
      if bActionTime = 0 then CreateCast;
      dec(bActionTime);
      if (bActionTime = 0) and (TDXwPanel(ObjectList.Items[Dxo_chain]).visible)  then
      begin
         TDXwPanel(ObjectList.Items[Dxo_chain]).visible:=false;
         PrepareCastEnd;
      end;
      if (bActionTime = 0) and not(TDXwPanel(ObjectList.Items[Dxo_chain]).visible)  then
      begin
         TDXwPanel(Objectlist.Items[DxO_Cast+ pType]).visible:=false;
         bActionTime:= 32;
         MakeLighningArc(1);
         TDXwPanel(ObjectList.Items[Dxo_chain]).visible:=true;
      end;
      if (bActionTime = 24) then MakeLighningArc(2);
      if (bActionTime = 16) then MakeLighningArc(3);
      if (bActionTime = 8) then MakeLighningArc(4);
    end;
    else begin
      updateSpell;
      exit;
    end;
  end;


end;
{----------------------------------------------------------------------------}
procedure  TSnBattleField.PrepareCastEnd;
var
  u,v,i,j,x,y,id: integer;
begin

  i:=bUnits[btgt].x;
  j:=bUnits[btgt].y;
  x:=Hex2PosXY(i,j).x+15;
  y:=Hex2PosXY(i,j).y;
  case bSpel of
    SP15_MagicArrow :    id:=DxO_Cast+ 5;
    SP16_IceBolt    :    id:=DxO_Cast+ 11;
    SP17_LightningBolt:  id:=DxO_Cast+ 13;
    SP19_ChainLightning: id:=DxO_Cast+ 13;
    else                 id:=DxO_Cast+ 5;
  end;
  with TDXwPanel(Objectlist.Items[id]) do
  begin
    bActionTime:=image.PatternCount;
    left:=x-50;
    top:= y-30;
    tag:=0;
    visible:=true;
  end;
  // add more target  of chain...
  if bSpel = SP19_ChainLightning then
  begin
    for u:=1 to bUnitNb_Chain  do
    begin
      v:=bUnitID_Chain[u];
      i:=bUnits[v].x;
      j:=bUnits[v].y;
      x:=Hex2PosXY(i,j).x+15;
      y:=Hex2PosXY(i,j).y;
      with TDXwPanel(Objectlist.Items[id+u]) do
      begin
        bActionTime:=image.PatternCount;
        left:=x-50;
        top:= y-30;
        tag:=0;
        visible:=true;
      end;
    end;
  end;

  bAction:=bActionCastEnd;
  UpdateCastEnd;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateCastEnd;
var
  u,id : integer;
begin
  dec(bActionTime);
  case bSpel of
    SP15_MagicArrow :   id:=DxO_Cast+ 5;
    SP16_IceBolt    :   id:=DxO_Cast+ 11;
    SP17_LightningBolt: id:=DxO_Cast+ 13;
    SP19_ChainLightning: id:=DxO_Cast+ 13;
    else                id:=DxO_Cast+ 5;
  end;

  with TDXwPanel(Objectlist.Items[id]) do
  begin
    tag:= image.PatternCount - bActionTime;
    if bActionTime = 0 then
    begin
      visible:=false;
      //bAction:=bActionNo;
      cmd_BA_Spell(bSPel,bTgt); //cmd_BA_AttackCast;
    end;
  end;

  if bSpel = SP19_ChainLightning then
  begin
  for u:=1 to bUnitNb_Chain  do
  begin
    with TDXwPanel(Objectlist.Items[id+u]) do
    begin
      tag:= image.PatternCount - bActionTime;
      if bActionTime = 0 then visible:=false;
    end;
  end;
  end;

end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.PlaceObstacle;
{ DxO_fireWall:=AddSprPanel('C07SPF61', 355,10);
  DxO_bigForceField0:=AddSprPanel('C15SPE10', 405,10);
  DxO_bigForceField1:=AddSprPanel('C15SPE7', 455,10);
  DxO_smallForceField0:=AddSprPanel('C15SPE1', 505,10);
  DxO_smallForceField1:=AddSprPanel('C15SPE4', 555,10); }
begin
  case bSpel of
    SP10_Quicksand:  begin
      TDXwPanel(Objectlist.Items[DxO_quicksand]).visible:=true;
      TDXwPanel(Objectlist.Items[DxO_quicksand]).Left:=Hex2PosXY(DxMouse.sX,DxMouse.sY).x+5;
      TDXwPanel(Objectlist.Items[DxO_quicksand]).top:= Hex2PosXY(DxMouse.sX,DxMouse.sY).y+5;
    end;
    SP11_LandMine:   begin
      TDXwPanel(Objectlist.Items[DxO_landmine]).visible:=true;
      TDXwPanel(Objectlist.Items[DxO_landmine]).Left:=Hex2PosXY(DxMouse.sX,DxMouse.sY).x+5;
      TDXwPanel(Objectlist.Items[DxO_landmine]).top:= Hex2PosXY(DxMouse.sX,DxMouse.sY).y+5;
    end;
    SP12_ForceField:  begin
      TDXwPanel(Objectlist.Items[DxO_bigForceField1]).visible:=true;
      TDXwPanel(Objectlist.Items[DxO_bigForceField1]).Left:=Hex2PosXY(DxMouse.sX,DxMouse.sY).x-10;
      TDXwPanel(Objectlist.Items[DxO_bigForceField1]).top:= Hex2PosXY(DxMouse.sX,DxMouse.sY).y-5;
    end;
    SP13_FireWall:   begin
      TDXwPanel(Objectlist.Items[DxO_fireWall]).visible:=true;
      TDXwPanel(Objectlist.Items[DxO_fireWall]).Left:=Hex2PosXY(DxMouse.sX,DxMouse.sY).x+5;
      TDXwPanel(Objectlist.Items[DxO_fireWall]).top:= Hex2PosXY(DxMouse.sX,DxMouse.sY).y+5;
    end;
  end;
  bActionTime := 0;
  bAction:=bActionNo;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateHeroCastSpell;
begin
  if bActionTime=0 then  // hero anim spec not yet initializd
  begin
     bActionTime:=TDXwPanel(Objectlist.Items[DxO_Hero+1]).Image.PatternCount;
  end;
  TDXwPanel(Objectlist.Items[DxO_Hero+1]).tag:=TDXwPanel(Objectlist.Items[DxO_Hero+1]).Image.PatternCount-bActionTime ;

  dec(bActionTime);
  if bActionTime = 0 then
  begin
    TDXwPanel(Objectlist.Items[DxO_Hero+1]).tag:=0;
    bAction:=bActionCast;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateSpell;
var
  spellAnim,ID: integer;

begin
  case bSpel of
    SP10_Quicksand:     spellAnim:=SA55_Quicksand_start;
    SP11_LandMine:      spellAnim:=SA57_Land_Mine;
    SP12_ForceField:    spellAnim:=SA33_Force_Field_L;
    SP13_FireWall:      spellAnim:=SA44_Fire_Wall_L_start;
    //SP14_Earthquake:=;
    SP15_MagicArrow:    spellAnim:=SA64_Magic_Arrow_hit;
    SP16_IceBolt:       spellAnim:=SA46_Ice_Bolt_hit;
    SP17_LightningBolt: spellAnim:=SA37_Lightning_bolt;   //38in VCMI
    SP18_Implosion:     spellAnim:=SA10_Implosion;
    SP19_ChainLightning:spellAnim:=SA1_Lightning;         //36in VMCI
    SP20_FrostRing:     spellAnim:=SA45_Frost_Ring;
    SP21_Fireball:      spellAnim:=SA53_Fireball;
    SP22_Inferno:       spellAnim:=SA9_Inferno;
    SP23_MeteorShower:  spellAnim:=SA16_Meteor_Shower;
    SP24_DeathRipple:   spellAnim:=SA8_Death_Ripple;
    SP25_DestroyUndead: spellAnim:=SA29_Destroy_Undead;
    SP26_Armageddon:    spellAnim:=SA12_Armageddon;
    SP27_Shield:        spellAnim:=SA27_Shield;
    SP28_AirShield:     spellAnim:=SA2_Air_Shield;
    SP29_fireShield:    spellAnim:=SA11_Fire_Shield;
    SP30_ProtFromAir:   spellAnim:=SA22_Protection_from_Air;
    SP31_ProtFromFire:  spellAnim:=SA24_Protection_from_Fire;
    SP32_ProtFromWater: spellAnim:=SA23_Protection_from_Water;
    SP33_ProtFromEarth: spellAnim:=SA26_Protection_from_Earth;
    SP34_AntiMagic:     spellAnim:=SA5_AntiMagic;
    SP35_Dispel:        spellAnim:=SA41_Dispel;
    SP36_MagicMirror:   spellAnim:=SA3_Magic_Mirror;
    SP37_Cure:          spellAnim:=SA39_Cure;
    SP38_Resurrection:  spellAnim:=SA4_Regeneration; // 79 in VCMI
    //SP39_AnimateDead:=;                            // 79 in VCMI
    SP40_Sacrifice:     spellAnim:=SA51_Sacrifice;
    SP41_Bless:         spellAnim:=SA36_Bless;
    SP42_Curse:         spellAnim:=SA40_Curse;
    //SP43_Bloodlust:=;                              //4 in VCMI
    SP44_Precision:     spellAnim:=SA25_Precision;
    SP45_Weakness:      spellAnim:=SA56_Weakness;
    SP46_StoneSkin:     spellAnim:=SA54_Stone_Skin;
    SP47_DisruptingRay: spellAnim:=SA13_Disrupting_Ray_fly; //14 in VCMI
    SP48_Prayer:        spellAnim:=SA0_Prayer;
    SP49_Mirth:         spellAnim:=SA20_Good_Morale;
    SP50_Sorrow:        spellAnim:=SA30_Bad_Morale;
    SP51_Fortune:       spellAnim:=SA18_Good_Luck;
    SP52_Misfortune:    spellAnim:=SA48_Bad_Luck;
    SP53_Haste:         spellAnim:=SA31_Haste;
    SP54_Slow:          spellAnim:=SA19_Slow;
    SP55_Slayer:        spellAnim:=SA28_Slayer;
    SP56_Frenzy:        spellAnim:=SA17_Frenzy;
    SP57_TitansLightningBolt:spellAnim:=SA1_Lightning; //38 in VCMI
    SP58_Counterstrike: spellAnim:=SA7_Counterstrike;
    SP59_Berserk:       spellAnim:=SA35_Berserk;
    SP60_Hypnotize:     spellAnim:=SA21_Hypnotize;
    SP61_Forgetfulness: spellAnim:=SA42_Forgetfulness;
    SP62_Blind:         spellAnim:=SA6_Blind;
    //SP63_Teleport:=;
    SP64_RemoveObstacle:spellAnim:=SA34_Remove_Obstacle;
    //SP65_Clone:=;
    //SP66_FireElemental:=;
    //SP67_EarthElemental:=;
    //SP68_WaterElemental:=;
    //SP69_AirElemental:=;
    //70StoneGAZ =>  70
    //71 Poison =>  67
  else
    SpellAnim:=20;
  end;

  DxO_SPA:=iEFFECT[SpellAnim].obid;

  case bSpel of
    SP10_Quicksand,
    SP11_LandMine,
    SP12_ForceField,
    SP13_FireWall:  begin
      PlaceObstacle;
      bState:=bsPlay;
      exit;
    end;

    SP20_FrostRing,
    SP21_Fireball,
    SP22_Inferno,
    SP23_MeteorShower:  begin
      TDXwPanel(Objectlist.Items[DxO_SPA]).visible:=true;
      TDXwPanel(Objectlist.Items[DxO_SPA]).Left:=
                Hex2PosXY(DxMouse.sx,DxMouse.sy).x
                +22
                -(TDXwPanel(Objectlist.Items[DxO_SPA]).Image.Width div 2);
      TDXwPanel(Objectlist.Items[DxO_SPA]).top:=
                Hex2PosXY(DxMouse.sx,DxMouse.sy).y
                +21
                -(TDXwPanel(Objectlist.Items[DxO_SPA]).Image.Height div 2);

    end;

    SP26_Armageddon:   begin
      TDXwPanel(Objectlist.Items[DxO_SPA]).visible:=true;
      TDXwPanel(Objectlist.Items[DxO_SPA]).Left:= 0;//STARTX;
      TDXwPanel(Objectlist.Items[DxO_SPA]).Top:= 0; //STARTY;
    end;

    SP66_FireElemental,
    SP67_EarthElemental,
    SP68_WaterElemental,
    SP69_AirElemental :  begin
      ID:=cmd_SP_Summon(bSpel);
      SummonUnit(ID);
      bState:=bsPlay;
      exit;
    end;

    else begin
      with TDXwPanel(Objectlist.Items[DxO_SPA]) do begin
      //anim at center of crea
      Left:=Hex2PosXY(bUnits[bTgt].x,bUnits[bTgt].y).x  + HEXww div 2
            -(TDXwPanel(Objectlist.Items[DxO_SPA]).Image.Width div 2);
      Top:= Hex2PosXY(bUnits[bTgt].x,bUnits[bTgt].y).y  +5
            -(TDXwPanel(Objectlist.Items[DxO_SPA]).Image.Height div 2);
      // anil at center of double wide crea
      if Is2HexCR(bTgt) then
      begin
         if bunits[btgt].dirLeft
         then Left:=left - HEXww div 2
         else Left:=left + HEXww div 2;
      end;
      //anim above crea
      if SpellAnim=SA0_Prayer then
      Top:= top-(TDXwPanel(Objectlist.Items[DxO_SPA]).Image.Height div 2);
      //anim belo crea
      if SpellAnim=SA19_Slow then
      Top:= top+30;

      TDXwPanel(Objectlist.Items[DxO_SPA]).visible:=true;
      end;
    end;
  end; //end case bSpell

  if (bActionTime=0)
    then bActionTime:=TDXwPanel(Objectlist.Items[DxO_SPA]).Image.PatternCount;

  TDXwPanel(Objectlist.Items[DxO_SPA]).tag:=TDXwPanel(Objectlist.Items[DxO_SPA]).Image.PatternCount-bActionTime ;

  dec(bActionTime);
  if bActionTime = 0 then
  begin
    TDXwPanel(Objectlist.Items[DxO_SPA]).visible:=false;
    bAction:=bActionNo;
    //ChangeUnitAnim(bid,cAnimStand);
    cmd_BA_Spell(bSpel,bTgt);
    bState:=bsPlay;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.StartShot;
begin
  ChangeUnitAnim(bid,cAnimShoot_side);
  bActionTime:=bUnits[bid].AnimCount;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateStartShot;
begin
  UpdateUnitAnim(bid);
  dec(bActionTime);
  if bActionTime -1 = bUnits[bid].AnimCount - iCrea[Bunits[bid].t].shotstart  //(bProj.time - bUnits[bid].AnimCount div 2)
  then CreateProj;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateShot;
begin
  if bActionTime = 0 then startShot;
  if TDXwPanel(Objectlist.Items[DxO_Shot+ pType]).visible
  then UpdateProj
  else UpdateStartShot;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateCatapult;
begin
  if bActionTime = 0 then startShot;
  if TDXwPanel(Objectlist.Items[DxO_Shot+ pType]).visible
  then UpdateProj
  else UpdateStartShot;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateProj;
begin
  with TDXwPanel(Objectlist.Items[DxO_Shot+ pType]) do
  begin
    //if (bActionTime > (bproj.time - (bUnits[bid].AnimCount))) // div 2)))
    if  bUnits[bid].AnimType <>2
    then  UpdateUnitAnim(bid);
    left:=left+bproj.x;
    top:= top+ bproj.y;
    if bAction=bActionCatapult // add hyperbole effect
    then
    begin
      //top:=top - round(0.2* sqr((bproj.time-1)/2)) + round(0.2 * sqr((bproj.time-1)/2-bactiontime));
      top:=top
      +
      round(
      0.35 * (
      sqr(1+(bproj.time+1)/2-bactiontime)  -  sqr((bproj.time+1)/2-bactiontime)
      )

      );
      {if bactiontime <  bproj.time div 2
      then
      if bactiontime <  (bproj.time div 4)    then top:=top+12   else  top:=top+6
      else
      if bactiontime <  (3* bproj.time div 4) then top:=top-6   else  top:=top-12;}
    end;
    if pSpin then
    begin
      inc(TDXwPanel(Objectlist.Items[DxO_Shot+ pType]).tag);
      if TDXwPanel(Objectlist.Items[DxO_Shot+ pType]).tag=TDXwPanel(Objectlist.Items[DxO_Shot+ pType]).Image.PatternCount
      then  TDXwPanel(Objectlist.Items[DxO_Shot+ pType]).tag:=0;
    end;
  end;
  dec(bActionTime);
  if bActionTime = 1 then DestroyProj;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.CreateProj;
var
  i,j,k,l: integer;
  offx,offy:integer;
begin
  i:=bUnits[bid].x;
  j:=bUnits[bid].y;
  Case bshotdir of
    dirU: begin
        offx:=iCrea[bUnits[bid].t].ShotUX;
        offY:=iCrea[bUnits[bid].t].ShotUY;
    end;
    dirR: begin
        offx:=iCrea[bUnits[bid].t].ShotRX;
        offy:=iCrea[bUnits[bid].t].ShotRY;
    end;
    dirD : begin
        offx:=iCrea[bUnits[bid].t].ShotDX;
        offy:=iCrea[bUnits[bid].t].ShotDY;
    end;
  end;
  bproj.x0:=Hex2PosXY(i,j).x+ offx;
  //if baction=BactionCatapult then bproj.x0 := bproj.x0 + 30;
  bproj.y0:=Hex2PosXY(i,j).y + offy + 36;
  k:=DxMouse.mx;
  l:=DxMouse.my;
  //k:=bUnits[bTgt].x;
  //l:=bUnits[bTgt].y;

  bproj.x1:=Hex2PosXY(k,l).x;        //+5
  bproj.y1:=Hex2PosXY(k,l).y-20;
  bActionTime:=2*(1+abs(i-k)+abs(j-l)); //time to reach target
  if baction=BactionCatapult then bActionTime:=10+bActionTime;
  bproj.x:=(bproj.x1-bproj.x0) div (bActionTime-2); //-1
  bproj.y:=(bproj.y1-bproj.y0) div (bActionTime-2); //-1
  bproj.time:=bActionTime;
  pType:= iCrea[bUnits[bid].t].shotdefid;
  pSpin:= iCrea[bUnits[bid].t].shotspin;

  with TDXwPanel(Objectlist.Items[DxO_Shot+ pType]) do
  begin
    if (bUnits[bid].dirLeft) then MirrorH:=true else MirrorH:=false;
    left:=bproj.x0;
    top:=bproj.y0;
    visible:=true;
    tag:=ComputeDirTag(abs(bproj.x1-bproj.x0),bproj.y1-bproj.y0);
  end;
end;
{----------------------------------------------------------------------------}
function TSnBattleField.ComputeDirTag(a,b: integer): integer;
//PROJ DIR
// 0=-90°, 1=-45°, 2=-30°, 3=-15°, 4=0°,  5=15°, 6=30°, 7=45°, 8=90°
// 0=-90°, 1=-72°, 2=-45°, 3=-27°, 4=0°,  5=27°, 6=45°, 7=72°, 8=90°
var
  degree: integer ;
  float: single;
begin
  float:=arcsin(b / sqrt(a*a+b*b));
  degree:=round(radtodeg(float));
  case degree of
  -90..-81 : result:=0;   //  -90
  -80..-59 : result:=1;   //  -72 45
  -58..-37 : result:=2;   //  -45 30
  -36..-16  : result:=3;  //  -27 15
  -15..15   : result:=4;   //    0
   16..36  : result:=5;   //   15
   37..58  : result:=6;   //   30
   59..80  : result:=7;   //   45
   81..90  : result:=8;   //   90
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.DestroyWall;
//destroy one wall (at 1,4, 5, 7, 10 )
begin
  cmd_BA_AttackWALL;
  RefreshWall;
  bState:=bsEnd;
  bAction:=bActionNo;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.DestroyProj;
begin
  TDXWPanel(Objectlist.Items[DxO_Shot+ptype]).visible:=false;
  bActionTime:=0;
  if bUnits[bid].t= MO118_Catapult then
    DestroyWall
  else
  begin
    cmd_BA_AttackSHOT;
    if bAction=bActionDmg   then UpdateDmg;
    if bAction=bActionDeath then UpdateDeath;
  end;
  ChangeUnitAnim(bid,cAnimStand);
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.AdaptUnitPos;
begin
  with TDXwPanel(Objectlist.Items[DxO_Unit+bid]) do
  begin
    if bunits[bid].dirLeft  // going left  dir
    then
    begin
      left:=left-59;
      if (bunits[bid].side=SD_LEFT) and is2HexCR(bid) then left:=left+42;
    end
    else
    begin                 //  going right  dir
    //  if (bunits[bid].side=SD_LEFT) and is2HexCR(bid) then left:=left-42;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattlefield.WalkUnit;
const
  count=7;
begin
  //LogF.Insert(format('WalkUnit %d type %d',[bid,bUnits[bid].t]));
  case bUnits[bid].AnimType of
    cAnimTurn_LeftFront:  UpdateUnitAnim(bid);
    cAnimTurn_RightFront: UpdateUnitAnim(bid);
    cAnimTurn_LeftBack:   UpdateUnitAnim(bid);
    cAnimTurn_RightBack:  UpdateUnitAnim(bid);
    canimStart:           UpdateUnitAnim(bid);
    cAnimStand:           ChangeUnitAnim(bid,cAnimMove);
    cAnimMove :
    begin
      if bActionTime > count then bActionTime := count;
      if bActionTime <= 0 then bActionTime:=count;
      with bPath do
      begin
        dec(bActionTime);
        with TDXwPanel(Objectlist.Items[DxO_Unit+bid]) do
        begin
          //compute left whatever the direction
          left:=(bActionTime * Hex2PosXY(WayHex[step].x,WayHex[step].y).x
          + (count-bActionTime) * Hex2PosXY(WayHex[step+1].x,WayHex[step+1].y).x
          ) div count  -172;
          top:= (bActionTime * Hex2PosXY(WayHex[step].x,WayHex[step].y).y
          + (count-bActionTime) * Hex2PosXY(WayHex[step+1].x,WayHex[step+1].y).y
          ) div count  -225;

          bunits[bid].dirLeft:=(Hex2PosXY(WayHex[step+1].x,WayHex[step+1].y).x < Hex2PosXY(WayHex[step].x,WayHex[step].y).x) ;
          // addapt pos in case of cur direction
          AdaptUnitPos;
          UpdateUnitAnim(bid);
        end;
        if bActionTime<=0 then
        begin
          bActionTime:=count;
          inc(step);
          bUnits[bId].x:=WayHex[step].x;
          bUnits[bId].y:=WayHex[step].y;
          if cmd_BA_OpenBridge then
          begin
            TDXwPanel(Objectlist.Items[DxO_DRW]).Visible:=true;
            TDXwPanel(Objectlist.Items[DxO_DRW+1]).Visible:=true;
          end;

        end;
        if ((dst.x=bUnits[bId].x) and (dst.y=bUnits[bId].y))
        then begin
          ChangeUnitAnim(bid,cAnimEnd);  // end of walking
          if cmd_BA_CloseBridge then
          begin
            TDXwPanel(Objectlist.Items[DxO_DRW]).Visible:=false;
            TDXwPanel(Objectlist.Items[DxO_DRW+1]).Visible:=false;
          end;
        end;
      end;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattlefield.FlyUnit;
begin
  if  bUnits[bId].x < bPath.dst.x then
  if bUnits[bId].dirLeft=true  then
  begin
    bUnits[bId].dirLeft:=false;
    TDXwPanel(Objectlist.Items[DxO_Unit+bid]).left:=TDXwPanel(Objectlist.Items[DxO_Unit+bid]).left+59;
  end;

  if  bUnits[bId].x > bPath.dst.x then
  if bUnits[bId].dirLeft=false  then
  begin
    bUnits[bId].dirLeft:=true;
    TDXwPanel(Objectlist.Items[DxO_Unit+bid]).left:=TDXwPanel(Objectlist.Items[DxO_Unit+bid]).left-59;
  end;

  case bUnits[bid].AnimType of
    cAnimStand: ChangeUnitAnim(bid,cAnimTurn);
    cAnimTurn_LeftFront:  UpdateUnitAnim(bid);
    cAnimTurn_RightFront: UpdateUnitAnim(bid);
    cAnimTurn_LeftBack:   UpdateUnitAnim(bid);
    cAnimTurn_RightBack:  UpdateUnitAnim(bid);
    canimStart:           UpdateUnitAnim(bid);
    cAnimEnd:             UpdateUnitAnim(bid);
    cAnimMove:
    begin
      dec(bActionTime);
      if bActionTime <=0 then
      begin
        ChangeUnitAnim(bid,cAnimEnd);
        bActionTime:=1;
        bUnits[bId].x:=bPath.dst.x;
        bUnits[bId].y:=bPath.dst.y;
      end;
      with TDXwPanel(Objectlist.Items[DxO_Unit+bid]) do
      begin
        left:=left+bProj.x;
        top:=top+bProj.y;
        UpdateUnitAnim(bid);
      end;
    end;
  end;
end;

{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateEffectDef;
begin
  UpdateEffect(TDXwPanel(Objectlist.Items[DxO_Def]), bid)
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateEffectLuck;
begin
  UpdateEffect(TDXwPanel(Objectlist.Items[DxO_Luck]), bid)
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateEffectHeal;
begin
  UpdateEffect(TDXwPanel(Objectlist.Items[DxO_Heal]), bid)
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateEffectMoral;
begin
  UpdateEffect(TDXwPanel(Objectlist.Items[DxO_Moral]), bid)
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateEffect(pEffect: TDXwPanel; id: integer);
begin
  with pEffect do begin
    Left:=Hex2PosXY(bUnits[id].x,bUnits[id].y).x  + HEXww div 2
            -(TDXwPanel(Objectlist.Items[DxO_Def]).Image.Width div 2);
    Top:= Hex2PosXY(bUnits[id].x,bUnits[id].y).y  +5
            -(TDXwPanel(Objectlist.Items[DxO_Def]).Image.Height div 2);
    // anim at center of double wide crea
    if Is2HexCR(id) then
    begin
      if bunits[id].dirLeft
         then Left:=left - HEXww div 2
         else Left:=left + HEXww div 2;
    end;
    visible:=true;

    if (bActionTime=0) then bActionTime:=image.PatternCount;

    dec(bActionTime);
    tag:=image.PatternCount-bActionTime;
    if bActionTime = 0 then
    begin
      visible:=false;
      bAction:=bActionNo;
    end;
  end
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateMove;
begin
  //LogF.Insert(format('UpdateMove %d type %d',[bid,bUnits[bid].t]));
  if (iCrea[bUnits[bid].t].flag and UN_FLY) = UN_FLY
  then
  FlyUnit
  else
  WalkUnit;
  if bActionTime=0    // end of move what to do ?
  then
  begin
    with TDXwPanel(Objectlist.Items[DxO_Unit+bId]) do
    begin
      left:=Hex2PosXY(bUnits[bid].x,bUnits[bid].y).x-172;
      top:= Hex2PosXY(bUnits[bid].x,bUnits[bid].y).y-225;
      if bid <=20
      then
      begin
        bunits[bid].dirLeft:=false;
      end
      else
      begin
        bunits[bid].dirLeft:=true;
        left:=left-59;
      end;
    end;
    if btgt > -1
    then
    begin
      ChangeUnitAnim(bid,cAnimAttak_side);
      bActionTime:=bUnits[bid].AnimCount;
      bAction:=bActionAtt;
    end
    else
    begin
      bUnits[bid].HexTravelled:=0;
      //LogF.Insert(format('Move l=%d t=%d',[left,top]));
      ChangeUnitAnim(bid,cAnimStand);
      //LogF.Insert(format('Move new l=%d t=%d',[left,top]));
      bAction:=bActionNo;
      bState:=bsEnd;
    end;
  end;
end ;
{----------------------------------------------------------------------------}
procedure  TSnBattleField.UpdateState;
var
  i,j,b:integer;
begin
  cmd_BA_ChangeState;
  for j:=0 to 7 do
  TDXwPanel(Objectlist.Items[DxO_NextUnit+j]).visible:=false;

  j:=0;
  for i:=0 to 41 do
  begin
    b:=bUnitID_P1_ToMove[i];
    // ignore machine
    if (bUnits[b].t=MO121_AmmoCart) or (bUnits[b].t=MO120_FirstAidTent)  then
       continue;


    if (bUnits[b].t > -1)  and  (bUnits[b].n > 0)  and  (bUnits[b].state =UN_READY)
    then
    begin
      TDXwPanel(Objectlist.Items[DxO_NextUnit+j]).tag:=bUnits[b].t+2;
      TDXwPanel(Objectlist.Items[DxO_NextUnit+j]).selected:=true;
      TDXwPanel(Objectlist.Items[DxO_NextUnit+j]).visible:=true;
      TDXWPanel(ObjectList[DxO_NextUnit+j]).caption:=inttostr(bUnits[b].n);
      j:=j+1 ;
      if j > 7 then break;
    end;
  end;

  TDXwButton(Objectlist.Items[DxO_button+6]).enabled:=false;
  if bHeroAtk > -1
  then
     if mHeros[bHeroAtk].hasBook
     then TDXwButton(Objectlist.Items[DxO_button+6]).enabled:=true;

  if ((bFinished)  and (mDialog.res<>-1))
  then
  begin
    Drawing:=false;
    EndBattle;
  end
  else
  begin
    case bAction of
      bActionAtt:  ChangeUnitAnim(bid,cAnimAttak_side);
      bActionDef:  ChangeUnitAnim(bid,cAnimDef);
      bActionDmg:  ChangeUnitAnim(bid,cAnimDmg);
      bActionShot: ChangeUnitAnim(bid,cAnimShoot_side);
      bActionCatapult: ChangeUnitAnim(bid,cAnimShoot_side); //not necessary
    //bActionCast: ChangeUnitAnim(bid,cAnimCast_side);
      bActionWalk, bActionFly:  ChangeUnitAnim(bid,cAnimstart);
      bActionNo:   UpdateUnit;
    end;
  end;
end;


{----------------------------------------------------------------------------}
procedure  TSnBattleField.UpdateDmgAll;
var
  i : integer;
begin
  //not initialized change anim for DMG and start timer
  if bActionTime<=0 then
  begin
    //if bstate = bsreply then ChangeUnitAnim(bid,cAnimDef) else
    for i:=0 to 41 do
    if (bUnits[i].N0>0) then
    begin
      if (bUnits[i].Animtype=cAnimDmg) and  (bUnits[i].AnimPos <> bUnits[i].AnimList[cAnimDmg].count-1) then
      begin
        ChangeUnitAnim(i,cAnimDmg);
        bActionTime:=max(bUnits[i].AnimList[cAnimDmg].count,bActionTime) ;
      end;
      if (bUnits[i].Animtype=cAnimDeath) and  (bUnits[i].AnimPos <>bUnits[i].AnimList[cAnimDeath].count-1) then
      begin
        ChangeUnitAnim(i,cAnimDeath);
        bActionTime:=max(bUnits[i].AnimList[cAnimDeath].count,bActionTime);
      end;
    end;
  end;
  dec(bActionTime);
  for i:=0 to 41 do if (bUnits[i].N0>0) then
  begin
    if (bUnits[i].AnimType=cAnimDmg) and (bUnits[i].AnimPos <>bUnits[i].AnimList[cAnimDmg].count-1) then
    UpdateUnitAnim(i);
    if (bUnits[i].AnimType=cAnimDeath) and (bUnits[i].AnimPos <>bUnits[i].AnimList[cAnimDeath].count-1) then
    UpdateUnitAnim(i);
  end;
  if bActionTime <= 0 then
  begin
    bAction:=bActionNo;
    if bstate = bsreply then
    begin
      bAction:=bActionReplyAtt;
      ChangeUnitAnim(btgt,cAnimAttak_side);
      bActionTime:=bUnits[bTgt].AnimCount;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure  TSnBattleField.UpdateDmg;
begin
  if btgt < 0 then begin
    bAction:=bActionNo;
    exit;
  end;
  //not initialized change anim for DMG and start timer
  if bActionTime=0 then
  begin
  ChangeUnitAnim(btgt,cAnimDef);
  bActionTime:=bUnits[btgt].AnimCount;
  end;
  dec(bActionTime);
  UpdateUnitAnim(btgt);
  //on end of dmg animation timer is set to zero)
  if bActionTime = 0 then
  begin
    bAction:=bActionNo;
    if bstate = bsreply then
    begin
      bAction:=bActionReplyAtt;
      ChangeUnitAnim(btgt,cAnimAttak_side);
      bActionTime:=bUnits[bTgt].AnimCount;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure  TSnBattleField.UpdateReplyDmg;
begin
  //not initialized change anim for DMG and start timer
  if bActionTime=0 then
  begin
    ChangeUnitAnim(bid,cAnimDef);
    bActionTime:=bUnits[bid].AnimCount;
  end;
  dec(bActionTime);
  UpdateUnitAnim(bid);
  //on end of dmg animation timer is set to zero)
  if bActionTime = 0 then
    bAction:=bActionNo;
end;
{----------------------------------------------------------------------------}
procedure  TSnBattleField.UpdateDeath;
var
  i : integer;
begin
  //not initialized change anim for DMG and start timer
  if bActionTime<=0 then
  begin
    //if bstate = bsreply then ChangeUnitAnim(bid,cAnimDef) else
    for i:=0 to 41 do
    if (bUnits[i].N0>0) then
    if (bUnits[i].Animtype=cAnimDeath) and  (bUnits[i].AnimPos <>bUnits[i].AnimList[cAnimDeath].count-1) then
    begin
    ChangeUnitAnim(i,cAnimDeath);
    bActionTime:=bUnits[i].AnimCount;
    end;
  end;
  dec(bActionTime);
  for i:=0 to 41 do if (bUnits[i].N0>0) then
    if (bUnits[i].AnimType=cAnimDeath) and (bUnits[i].AnimPos <>bUnits[i].AnimList[cAnimDeath].count-1) then
    UpdateUnitAnim(i);
  if bActionTime = 0 then
    bAction:=bActionNo;
end;
{----------------------------------------------------------------------------}
procedure  TSnBattleField.UpdateReplyDeath;
begin
  //not initialized change anim for DMG and start timer
  if bActionTime=0 then
  begin
    ChangeUnitAnim(bid,cAnimDeath);
    bActionTime:=bUnits[bid].AnimList[cAnimDeath].count-1;
  end;
  dec(bActionTime);
  UpdateUnitAnim(bid);
  if bActionTime = 0 then
    bAction:=bActionNo;
end;
{----------------------------------------------------------------------------}
procedure  TSnBattleField.UpdateAttak;
begin
  //not initialized change anim for DMG and start timer
  if bActionTime=0 then
  begin
    ChangeUnitAnim(btgt,cAnimAttak_side);
    bActionTime:=bUnits[btgt].AnimCount;
  end;
  dec(bActionTime);
  UpdateUnitAnim(bid);
  if bActionTime = 0 then
    cmd_BA_AttackHAND;
end;
{----------------------------------------------------------------------------}
procedure  TSnBattleField.UpdateReplyAtt;
begin
  //not initialized change anim for DMG and start timer
  case bunits[btgt].t of
    112..115: begin
      bAction:=bActionNo;
      exit;
    end;
  end;
  if bActionTime=0 then
  begin
    ChangeUnitAnim(btgt,cAnimAttak_side);
    bActionTime:=bUnits[btgt].AnimCount;
  end;
  dec(bActionTime);
  UpdateUnitAnim(btgt);
  if bActionTime = 0 then
    cmd_BA_Reply;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateAction;
begin
  DxMouse.id:=CrList;
  TDXwPanel(Objectlist.Items[DxO_Sel1]).visible:=false;
  TDXwPanel(Objectlist.Items[DxO_Sel2]).visible:=false;
  case bAction of

    bActionDef:   UpdateEffectDef;
    bActionMoral: UpdateEffectMoral;
    bActionLuck:  UpdateEffectLuck;
    bActionHeal:  UpdateeffectHeal;
    bActionAtt:   UpdateAttak;
    bActionDmg:   UpdateDmgAll; //UpdateDmg;
    bActionDeath: UpdateDmgAll; //UpdateDeath;
    bActionShot:  UpdateShot;
    bActionCatapult:  UpdateCatapult;
    bActionWalk:  UpdateMove;
    bActionFly:   UpdateMove;
    bActionSpel:  UpdateHeroCastSpell;
    bActionCast:  UpdateCast;
    bActionCastEnd:   UpdateCastEnd;
    bActionReplyAtt:  UpdateReplyAtt;
    bActionReplyDmg:  UpdateReplyDmg;
    bActionReplyDeath:UpdateReplyDeath;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.DrawGrid;
var
  i:integer;
begin
  TDXwPanel(Objectlist.Items[DxO_Grid]).visible:=opShowBattleGrid;

  if bAction=bActionWalk then
  begin
    for i:=0 to bPath.DstPath  do
    with bPath do
      Imagelist.Items.Find('Cell_Shadow').Draw(DxSurface,Hex2PosXY(wayhex[i].x,wayhex[i].y).x+3,Hex2PosXY(wayhex[i].x,wayhex[i].y).y,0)
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.DrawHint;
var
  s:string;
begin
  s:=bText[bText.count-1];
  s:=s+ format(' Time=%d %s %s' ,[bActionTime , iAction[bAction], istate[integer(bState)]]);
  TDXwLabel(Objectlist.Items[DxO_Info]).caption:=s;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.DrawMassSpell;
var
  i:integer;
begin
// Try multieffect
  if bSpel=SP26_Armageddon then
  if TDXwPanel(ObjectList.Items[iEFFECT[SA12_Armageddon].obid]).visible then
  begin
     with TDXwPanel(ObjectList.Items[iEFFECT[SA12_Armageddon].obid]) do
     begin
       for i:=0 to 11 do
       image.Draw( DxSurface,  200* (i mod 4),  200* (i div 4), tag);
     end;
  end;
end;

{----------------------------------------------------------------------------}
procedure TSnBattleField.MakeLighningArc(u: integer);
const
  ArcWidth=800;
  ArcHeigh=600;
var
  DIB   :  TDIB;
  image : TPictureCollectionItem;
  v,i,j, x1,y1,x2,Y2, distance : integer;
begin
  Image:= TDXwPanel(ObjectList.Items[DxO_chain]).image;

  DIB := TDIB.Create;
  Try
    DIB.SetSize(Image.Width,Image.Height,24);
    DIB.FillDIB8(0);

    v:=bUnitID_Chain[u-1];
    i:=bUnits[v].x;
    j:=bUnits[v].y;
    x1:=Hex2PosXY(i,j).x+26;
    y1:=Hex2PosXY(i,j).y-5;

    if Is2HexCR(V) then
      begin
         if bunits[V].dirLeft
         then x1:=x1 - HEXww div 2
         else x1:=x1 + HEXww div 2 -5;
      end;


    v:=bUnitID_Chain[u];
    i:=bUnits[v].x;
    j:=bUnits[v].y;
    x2:=Hex2PosXY(i,j).x+26;
    y2:=Hex2PosXY(i,j).y-5;

    if Is2HexCR(V) then
      begin
         if bunits[V].dirLeft
         then x2:=x2 - HEXww div 2
         else x2:=x2 + HEXww div 2 -5;
      end;


    distance:= bPath.distance(point(x1,y1), point(x2,y2));
    drawLightning(DIB,x1,y1,x2,y2, distance / 4 , distance / 32) ;
    x1:=x2;
    y1:=y2;
  Finally
  Image.Picture.Graphic := DIB;
  Image.Picture.SaveToFile('arc'+ inttostr(v) + '.bmp');
  Image.Restore;
    DIB.Free
  end;

end;

procedure TSnBattleField.drawLightning(DIB: TDIB;x1,y1,x2,y2 :integer;displace, minDisplace: Single) ;
var
  mid_x, mid_y: integer;
begin
  if (x1=x2) and (y1=Y2) then
  exit;

  if (displace < MinDisplace) then
  begin
    DIB.ColoredLine(
       Point(x1, y1),
       Point(x2, y2),
       TColorLineStyle(1),
       clwhite,
       clwhite,
       TColorLinePixelGeometry(1),2);
  end
  else
  begin
    mid_x := round((x2+x1)/2);
    mid_y := round((y2+y1)/2);
    mid_x := round(mid_x + (random-0.5)*displace);
    mid_y := round(mid_y + (random-0.5)*displace);
    drawLightning(DIB,x1,y1,mid_x,mid_y,displace/2, mindisplace);
    drawLightning(DIB,x2,y2,mid_x,mid_y,displace/2, mindisplace);
  end;
end;

{----------------------------------------------------------------------------}
procedure TSnBattleField.ProcessAction;
begin
  //update state or action animation
  bAnimCount := (bAnimcount + 1) mod (opAnimSpeed) ;
  if bAnimCount <>0 then exit;
  if bAction=bActionNo
    then UpdateState
    else UpdateAction;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.SnDraw(Sender:TObject);
begin
  if AutoDestroy then exit;
  ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  DrawGrid;
  DrawUnitRange;
  DrawUnit;
  DrawMassSpell;
  DrawCursor;
  DrawHint;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.DrawUnit;
var
  n,x,y:integer;
  i: integer;
begin
  // draw qty on still creature not dead
  // if ObjectList.count < 20 then exit;

  if not( DxMouse.Id in [0,4,6]) then
    Imagelist.Items.Find('Cell_Shadow').Draw(DxSurface,Hex2PosXY(DxMouse.mx,DxMouse.my).x+3,Hex2PosXY(DxMouse.mx,DxMouse.my).y,0);

  // sort draw list and print
  ObjectList.SortZList(DxO_Unit,MAX_UNIT);
  ObjectList.DrawZList(DxO_Unit,MAX_UNIT);

  for i:=0 to MAX_UNIT-1 do
  begin
    n:=bUnits[i].n;
    if (n > 0) and (bUnits[i].AnimType = cAnimStand) and (bUnits[i].tower=0) then
    begin
      n:=bunits[i].n;
      x:= Hex2PosXY(bunits[i].x,bunits[i].y).X +35;
      y:= Hex2PosXY(bunits[i].x,bunits[i].y).y +25;
      ImageList.Items.find('CrQTY_'+inttostr(bunits[i].side)).Draw(DxSurface, x-13, y+1, 0);
      with DxSurface.Canvas do
      begin
        Brush.Style:=bsClear;
        Font.Color:=ClText;
        Font.Name:=H3Font;// 'Times New Roman';'
        Font.Size:=7;
        Textout(x,y, inttostr(n));
        Release;
      end;
    end;
  end;

  if bLogID <> bText.count-1 then
  begin
    blogID:=  bText.count-1;
    DxO_Hint:=bText.count-1;
    //if Hint='' then TDXWLabel(ObjectList[DxO_Info]).caption:=inttostr(DxO_Hint) + ' - ' + bText[bText.count-2];
    TDXWLabel(ObjectList[DxO_Info+1]).caption:=inttostr(DxO_Hint) + ' - ' + bText[bText.count-1];
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.DrawCursor;
var
  i,j:integer;
const
  //                                       def wlk fly fir he inf lst SO OT NO NE ET SE
  HotPointX : array [0..20] of integer = ( 12, 10, 10, 0 , 0 , 7, 0 , 20,32,20, 0, 0, 0, 0, 0,12,0, 0, 0, 0, 17);
  HotPointY : array [0..20] of integer = ( 12, 10, 10, 0 , 0 ,10, 0 ,  0, 0,20,20, 0, 0, 0, 0,4 ,0, 0, 0, 0, 24);
begin
  if DxScene = self then
  begin
    DxMouse.style:=msCbt;
    i:=DxMouse.x;
    j:=DxMouse.y;
    if DxMouse.id < 21 then
    begin
      i:=i-HotPointX[DxMouse.id];
      j:=j-HotPointY[DxMouse.id];
    end;
    Imagelist.Items.Find('crCombat').Draw(DxSurface,i,j,DxMouse.id);
  end
  else
  begin
    DxMouse.id:=0;
    DxMouse.style:=msAdv;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.DrawUnitRange;
var
  i,j:integer;
begin
  if (bid < 0) then exit;

  if (bState=bsPlay) and opShowBattleMoveRange then
  begin
    for i:=0 to MAX_BaX do
    for j:=0 to MAX_BaY do
    begin
      if bPath.HexMove[i,j] then
      Imagelist.Items.Find('Cell_Shadow').Draw(DxSurface,Hex2PosXY(i,j).x+3,Hex2PosXY(i,j).y,0)
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateUnit;
var
  i,j,t: integer;
  n: integer;
  showsel,hidesel: integer;
begin
  if (bid < 0) then exit;

  if (bState=bsPlay) then
  begin
    i:=bUnits[bId].x;
    j:=bUnits[bId].y;

    if bSide=SD_LEFT then
    begin
      showSel:=DxO_Sel1;
      hideSel:=DxO_Sel2;
    end
    else
    begin
      showSel:=DxO_Sel2;
      hideSel:=DxO_Sel1;
    end;

    with TDXwPanel(Objectlist.Items[showSel]) do
    begin
      left:=Hex2PosXY(i,j).x+3;
      top:=Hex2PosXY(i,j).y;
      visible:=true;
    end;

    //if Bid is turret
    if bUnits[bId].tower > 0 then
    TDXwPanel(Objectlist.Items[showSel]).visible:=false;
    TDXwPanel(Objectlist.Items[HideSel]).visible:=false;
  end;

  //TODO find a way to recover last inset
  //if Hint = '' then
  //TDXWlabel(objectList[DxO_Info+1]).caption:=bText[bText.count-1];

  for i:=0 to 41 do
  begin
    n:=bUnits[i].n;
    t:=bUnits[i].t;
    if (n > 0)  and (t > -1) then
      ChangeUnitAnim(i,cAnimstand);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateUnitPos(uid: integer);
var
  x,y: integer;
begin
  if uid >=30 then exit;
  x:=bUnits[uid].x;
  y:=bUnits[uid].y;
  with TDXwPanel(Objectlist.Items[DxO_Unit+uid]) do
  begin
     left:=Hex2PosXY(x,y).x-172;
     top:=Hex2PosXY(x,y).y-225;
     if bUnits[uid].dirLeft then left:=left-59;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.AddUnit(uid: integer; x,y: integer);
var
  id: integer;
begin
  id:=ObjectList.Add(TDXWPanel.Create(self));
  with TDXWPanel(ObjectList[id]) do
  begin
    Name:=inttostr(uid);
    LoadUnit(uid,bUnits[uid].t,ImageList);
    Image:=ImageList.Items.Find(inttostr(uid));
    Width:=Image.Width;
    Height:=Image.Height;
    Left:=X;
    Top:=Y;
    Surface:=DxSurface;
    Enabled:=false;
  end;
  updateUnitPic(uid,cAnimStand,0);
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.SummonUnit(uid: integer);
var
  id,pic_ID: integer;
begin
  id:= DxO_Unit +uid;
  with TDXWPanel(ObjectList[id]) do
  begin
    Name:=inttostr(uid);
    PIC_ID:= LoadUnit(uid,bUnits[uid].t,ImageList);
    Image:=ImageList.Items[PIC_ID];
    Width:=Image.Width;
    Height:=Image.Height;
    Left:=Hex2PosXY(bUnits[uid].x,bUnits[uid].y).x-172;
    Top:=Hex2PosXY(bUnits[uid].x,bUnits[uid].y).y-225;
    Surface:=DxSurface;
    Enabled:=false;
  end;
  updateUnitPic(uid,cAnimStand,0);
  TDXWPanel(Objectlist.Items[id]).Visible:=true;
  bActionTime := 0;
  bAction:=bActionNo;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.ChangeUnitAnim(uid,animtype: integer);
var
  Count: integer;
  Anim: integer;
  pos: integer;
  tid: integer;
  x1,y1,x2,y2: integer;
begin
  if uid < 0 then exit;
  pos:=0;
  anim:=AnimType;
  if uid=bid then tid:=btgt else tid:=bid ;

  if anim=cAnimStand then
  begin
    if uid > 20
    then bUnits[uid].dirLeft:=true
    else bUnits[uid].dirLeft:=false;
    UpdateUnitPos(uid);
    if iCrea[bUnits[uid].t].AnimList[cAnimStand].count = 0
    then Anim:=0;
  end;

  if Anim=cAnimAttak_side
  then
  begin
    with TDXwPanel(Objectlist.Items[DxO_Unit+uid]) do
    begin

      if bUnits[uid].dirLeft  then
      left:=left+59;
      bUnits[uid].dirLeft:=(bUnits[tid].x < bUnits[uid].x);
      if (bUnits[uid].y mod 2)=0 then  bUnits[uid].dirLeft:=(bUnits[tid].x <= bUnits[uid].x);

      if bUnits[tid].y > bUnits[uid].y then
      Anim:=cAnimAttak_down;
      if bUnits[tid].y < bUnits[uid].y then
      Anim:=cAnimAttak_up;

      if bUnits[uid].dirLeft
      then
      begin
        left:=left-59;
        if (is2HexCR(uid) and (uid < 21)) then left:=left+42;
      end
      else
        if (is2HexCR(uid) and (uid > 20)) then left:=left-42;
    end;
  end;

  if Anim=cAnimShoot_side then
  begin
    with TDXwPanel(Objectlist.Items[DxO_Unit+uid]) do
    begin
      bshotDir:=dirR;
      if bUnits[uid].dirLeft  then
        left:=left+59;
      bUnits[uid].dirLeft:=(bunits[tid].x < bunits[uid].x);
      if (bUnits[uid].y mod 2)=0 then
        bUnits[uid].dirLeft:=(bunits[tid].x <= bunits[uid].x);
      if bUnits[uid].dirLeft  then
        left:=left-59;
      if bunits[tid].y > bunits[uid].y+1 then
      begin
        Anim:=cAnimShoot_down;
        bshotDir:=dirD;
      end;
      if bunits[tid].y < bunits[uid].y-1 then
      begin
        Anim:=cAnimShoot_up;
        bshotDir:=dirU;
      end;
      // if target is neard side vide then force side


       x1:=Hex2PosXY(bunits[tid].x,bunits[tid].y).x;
       y1:=Hex2PosXY(bunits[tid].x,bunits[tid].y).y;

       x2:=Hex2PosXY(bUnits[bTgt].x,bUnits[bTgt].y).x;
       y2:=Hex2PosXY(bUnits[bTgt].x,bUnits[bTgt].y).y;

      case (ComputeDirTag(abs(x2-x1),y2-y1)) of
       -1..1 : Anim:=cAnimShoot_side
      end;

    end;
  end;

  if Anim=cAnimTurn
  then begin
    Anim:=cAnimstart;

    if  bpath.Dst.x < bUnits[uid].x then
    begin
      if not(bUnits[uid].dirLeft)
      then
      begin
        if bPath.Dst.y > bUnits[uid].y
        then Anim:=cAnimTurn_RightFront
        else Anim:=cAnimTurn_RightBack;
      end;
    end;

    if bPath.Dst.x >  bUnits[uid].x  then
    begin
     if (bUnits[uid].dirLeft)
     then
     begin
       if bPath.Dst.y > bUnits[uid].y
       then Anim:=cAnimTurn_LeftFront
       else Anim:=cAnimTurn_LeftBack;
     end;
    end;

  end;

  count:=bUnits[uid].AnimList[anim].count;

  if Anim=cAnimStart
  then
  begin
    if count=0 then anim:=cAnimMove;
  end;

  if Anim=cAnimEnd
  then
  begin
    if count=0 then anim:=cAnimStand;
    bActionTime:=0;
  end;

  bUnits[uid].AnimType:=Anim;
  bUnits[uid].Animcount:=bUnits[uid].AnimList[anim].count;
  UpdateUnitPic(uid,anim,pos);
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateUnitAnim(uid: integer);
var
  pos: integer;
  count: integer;
  Anim: integer;
begin
  if uid < 0 then exit;
  anim:= bUnits[uid].AnimType;
  count:=bUnits[uid].AnimList[anim].count;
  pos:=  bUnits[uid].AnimPos+1;

  if pos=count then
  begin
    case Anim of
      cAnimMove:
      begin
        UpdateUnitPic(uid,cAnimMove,0);
        //special evil
        if count=1 then  TDXWPanel(Objectlist.Items[DxO_Unit+uid]).visible:=false;
      end;
      cAnimStart:          UpdateUnitPic(uid,cAnimMove,0);
      cAnimTurn_LeftFront: UpdateUnitPic(uid,cAnimMove,0);
      cAnimTurn_RightFront:UpdateUnitPic(uid,cAnimMove,0);
      cAnimTurn_LeftBack:  UpdateUnitPic(uid,cAnimMove,0);
      cAnimTurn_RightBack: UpdateUnitPic(uid,cAnimMove,0);
      cAnimShoot_side,cAnimShoot_up, cAnimShoot_down : UpdateUnitPic(uid,cAnimStand,0);
      else
      begin
        TDXWPanel(Objectlist.Items[DxO_Unit+uid]).visible:=true;
        bActionTime:=0;
      end;
    end;
    if Anim=cAnimDeath
    then  bUnits[uid].AnimPos:=bUnits[uid].AnimList[cAnimDeath].count-1;
  end
  else
    UpdateUnitPic(uid,anim,pos);
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.UpdateUnitPic(uid,anim,pos: integer);
var
  NewDib  : TDIB;
  picFile: string;
begin
  bUnits[uid].AnimType:=Anim;
  bUnits[uid].AnimPos:=Pos;
  picFile:=bUnits[uid].AnimList[anim].Strings[pos];
  //improve load all anim in a single pic, for dislay change AnimPos/AnimCount
  if FileExists(picFile) then
  begin
    NewDib:=TDIB.Create;
    NewDib.LoadFromFile(picFile);
    with ImageList.Items.Find(inttostr(uid)) do
    begin
      Picture.Graphic:=NewDib;
      Restore;
    end;
    NewDib.Free;
  end;
  if uid >=30 then
    TDXwPanel(Objectlist.Items[DxO_Unit+uid]).MirrorH:=true
  else
    TDXwPanel(Objectlist.Items[DxO_Unit+uid]).MirrorH:=(bUnits[uid].dirLeft);
end;
{----------------------------------------------------------------------------}
procedure TSnBattleField.EndBattle;
begin
  cmd_BA_Exp;
  ProcessInfoBattleResult;
  CloseScene;
  cmd_BA_End;
  bText.SaveToFile('Combat.txt');
  SnGame.CheckWinLose;
end;
{----------------------------------------------------------------------------}

end.

td::pair<int, int> CBattleHex::getXYUnitAnim(int hexNum, bool attacker, CCreature * creature)
{
	std::pair<int, int> ret = std::make_pair(-500, -500); //returned value
	ret.second = -139 + 42 * (hexNum/17); //counting y
	//counting x
	if(attacker)
	{
		ret.first = -160 + 22 * ( ((hexNum/17) + 1)%2 ) + 44 * (hexNum % 17);
	}
	else
	{
		ret.first = -219 + 22 * ( ((hexNum/17) + 1)%2 ) + 44 * (hexNum % 17);
	}
	//shifting position for double - hex creatures
	if(creature->isDoubleWide())
	{
		if(attacker)
		{
			ret.first -= 42;
		}
		else
		{
			ret.first += 42;
		}
	}
	//returning
	return ret;
}
