unit UMap;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, DateUtils,
  UType, UHero, UDef;

  procedure Cmd_Map_UnFogWaterLevel(PL:byte;l:integer);
  procedure Cmd_Map_UnFogEarthLevel(PL:byte; l:integer);
  procedure Cmd_Map_UnFog(PL:byte;x,y,l:integer; r:integer=5);
  procedure Cmd_Map_DoFog(PL:byte;x,y,l:integer; r:integer=6);
  function  Cmd_Map_Inside(x,y: integer): boolean;
  function  Cmd_Map_GetCursor(x,y,l: integer): string;
  function  Cmd_Map_GetTileDesc(x,y,l: integer): string;
  procedure Cmd_Map_Load(f1: string);
  procedure Cmd_Map_ResetObjcount ;
  function  Cmd_Map_GetDate: string;
  procedure Cmd_Map_AddmObj;
  function  Cmd_Map_GetObjDesc(obX: TObjIndex): string;
  procedure UpdateSplash;

var
  nDef: integer =0;

implementation

uses
  UConst, UMain, USnGame, USnDialog, UFile, DXWGameSprite, DXWload, UPathRect, UPL, UCT, UHE, Math, UsnLoadingMap;

{----------------------------------------------------------------------------}
var
  l:integer;
  x,y,z: integer;
  a,b,c: shortint;
  HE: integer;
  DefPtr:  integer;
  DefInfo: TInfoDef;
  DefName: string;
  DefTxt: TSTringList;
  s: string;
  f: file;
  ReadN: integer;
  Buf:     array[1..6] of Byte;
  CharBuf: array[1..4096] of Char;
  TileBuf: array[1..7] of Byte;
  mLog: TLog;
  SystemTime: TSystemTime;

procedure Cmd_Map_ResetObjcount ;
begin
  nObjs:= 0;
  nCitys:= 0;
  nCEvents:= 0;
  nArts:= 0;
  nBanks:=0;
  nCamps:= 0;
  nChests:= 0;
  nLeans:= 0;
  nMagicSprings:= 0;
  nMonsters:= 0;
  nMines:= 0;
  nBonus:= 0;
  nScholars:= 0;
  nSeers:= 0;
  nTombs:= 0;
  nTrees:= 0;
  nMarletto:=0;                 //23
  nGarden:= 0;                  //32
  nAxis:= 0;                    //61
  nArena:= 0;                   //04
  nLearning:= 0;                //100
  nTreeofKnowledge:= 0;         //102
  nRumors:= 0;
  nEvents:= 0;
end;

{----------------------------------------------------------------------------}
function Cmd_Map_GetDate: string;
// M W D are sarting by 0, adding 1 for display
begin
  result:=format('Month: %d, Week: %d, Day: %d',[mData.Month+1,mData.Week+1,mData.Day+1]);
end;
{----------------------------------------------------------------------------}
function Cmd_Map_Inside(x,y:integer): boolean;
begin
  result:=(x>=0)and(x<mData.Dim)and(y>=0)and(y<mData.Dim);
end;
{----------------------------------------------------------------------------}
procedure Cmd_Map_UnFog(PL:byte; x,y,l:integer; r:integer=5);
var
  i,j,p: integer;
begin
  for i:=x-r to x+r do
  for j:=y-r to y+r do
    if (( ((x-i)*(x-i)+ (y-j)*(y-j)) <= (r*r-1)) and Cmd_Map_inside(i,j)) then
    //if (( ( abs(x-i) + abs (y-j)   ) <= r+2) and Cmd_Map_inside(i,j)) then
    begin
      for p:=0 to MAX_PLAYER-1 do
      if mPlayers[p].team=mPlayers[PL].team then mTiles[i,j,l].vis[p]:=true;
    end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_Map_DoFog(PL:byte; x,y,l:integer; r:integer=6);
var
  i,j,p: integer;
begin
  for i:=x-r to x+r do
  for j:=y-r to y+r do
    if (((x-i)*(x-i)+(y-j)*(y-j)< r*r) and Cmd_Map_inside(i,j)) then
    begin
      for p:=0 to MAX_PLAYER-1 do
      if mPlayers[p].team<>mPlayers[PL].team then mTiles[i,j,l].vis[p]:=false;
    end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_Map_UnFogEarthLevel(PL:byte; l:integer);
var
  i,j,p: integer;
begin
  if l=1
    then mPlayers[PL].allSubMap:=true
    else mPlayers[PL].allTopMap:=true;

  for i:=0 to mData.dim-1 do
  for j:=0 to mData.dim-1 do
  if  (mTiles[i,j,l].TR.t <>TR08_Water) then
  for p:=0 to MAX_PLAYER-1 do
    if mPlayers[p].team=mPlayers[PL].team then mTiles[i,j,l].vis[p]:=true;
end;
{----------------------------------------------------------------------------}
procedure Cmd_Map_UnFogWaterLevel(PL:byte; l:integer);
var
  i,j,p: integer;
begin
  mPlayers[PL].allWtrMap:=true;
  for i:=0 to mData.dim-1 do
  for j:=0 to mData.dim-1 do
  if  (mTiles[i,j,l].TR.t = TR08_Water) then
  for p:=0 to MAX_PLAYER-1 do
    if mPlayers[p].team=mPlayers[PL].team then mTiles[i,j,l].vis[p]:=true;
end;
{----------------------------------------------------------------------------}
function Cmd_Map_GetTileDesc(x,y,l: integer): string;
var
  s1,s2:string;
  obX: TObjIndex;
  visid: integer;
  HE:integer;
const
  MSG_VIS=' (Visited)';
  MSG_NOV=' (not Visited)';
  MSG_OWNED = 'owned by ';
begin
  obX:=mTiles[x,y,l].obX;
  mObj:=mObjs[obX.oid];
  s1:=Cmd_Map_GetObjDesc(obX);
  s2:='';

  // visited object by Player
  case mObj.t of
  OB16_CreatureBank,
  OB24_DerelictShip,
  OB25_DragonUtopia,
  OB84_Crypt:
  if mBanks[mObj.v].Visited[mPL] then s2:=MSG_VIS else s2:=MSG_noV;
  OB53_Mine: if mObj.pid > -1 then s2:=MSG_OWNED + PL_COLOR[mObj.pid];
  end;

  // visited object by Hero
  HE:=mPlayers[mPL].ActiveHero;
  if HE<>-1 then
  begin
    // local object visited by Hero
    case obX.t of
      OB100_LearningStone:    VisId:=0;
      OB23_MarlettoTower:     VisId:=1;
      OB32_Garden:            VisId:=2;
      OB51_MercenaryCamp:     VisId:=3;
      OB61_StarAxis :         VisId:=4;
      OB102_TreeOfKnowledge:  VisId:=5;
      OB41_Library:           VisId:=6;
      OB04_Arena :            VisId:=7;
      OB47_SchoolofMagic:     VisId:=8;
      OB107_SchoolofWar:      VisId:=9;
      OB48_MagicSpring:       VisId:=10;
      else                    VisId:=-1;
    end;
    // map specific obj visited ?
    if VisId > -1 then
      if  mHeros[HE].VisObj[VisId,mObj.v] then s2:=MSG_VIS else s2:=MSG_noV;

    // generic object visited by hero ?
    case obX.t of
      OB14_SwanPond:
        if mHeros[HE].VisSwan then s2:=MSG_VIS else s2:=MSG_noV;
      OB28_Faery:
        if mHeros[HE].VisFaery then s2:=MSG_VIS else s2:=MSG_noV;
      OB30_FountainofFortune:
        if mHeros[HE].VisFortune then s2:=MSG_VIS else s2:=MSG_noV;
      OB31_FountainofYouth:
        if mHeros[HE].VisYough then s2:=MSG_VIS else s2:=MSG_noV;
      OB38_IdolofFortune:
        if mHeros[HE].VisIdol then s2:=MSG_VIS else s2:=MSG_noV;
      OB49_MagicWell:
        if mHeros[HE].VisMagicWell then s2:=MSG_VIS else s2:=MSG_noV;
      OB52_Mermaid:
        if mHeros[HE].VisMermaid then s2:=MSG_VIS else s2:=MSG_noV;
      OB56_Oasis:
        if mHeros[HE].VisOasis then s2:=MSG_VIS else s2:=MSG_noV;
      OB64_RallyFlag:
        if mHeros[HE].VisRallyFlag then s2:=MSG_VIS else s2:=MSG_noV;
      OB84_Crypt:
        if mHeros[HE].VisRallyFlag then s2:=MSG_VIS else s2:=MSG_noV;
      OB94_Stables:
        if mHeros[HE].VisStable then s2:=MSG_VIS else s2:=MSG_noV;
      OB96_Temple:
        if mHeros[HE].VisTemple then s2:=MSG_VIS else s2:=MSG_noV;
    end;
  end;
  result:=s1+NL+s2;
end;
{----------------------------------------------------------------------------}
function Cmd_Map_GetObjDesc(obX: TObjIndex): string;
begin
 //result:=format('{OB [T=%d - U=%d - oID=%d -v=%d] }'+' %s', [t, u, oid, mObjs[OID].v, TxtObject[t]]);
 result:='{'+ TxtObject[obX.t] + '}';
 case obX.t of
   OB04_Arena :         result:=result  + TxtXtraInfo[28];
   OB05_Artifact:       result:=result  + iArt[obX.u].name;
   OB14_SwanPond :      result:=result  + TxtXtraInfo[1];
   OB23_MarlettoTower : result:=result  + TxtXtraInfo[7];
   //OB32_Garden
   OB41_Library :       result:=result  + TxtXtraInfo[6];
   OB47_SchoolofMagic:  result:=result + TxtXtraInfo[9];
   OB49_MagicWell:      result:=result  + TxtXtraInfo[25];
   OB51_MercenaryCamp: result:=result  + TxtXtraInfo[8];
   OB53_Mine :          result:=iRES[obX.u].Mine;
   OB61_StarAxis  :     result:=result + TxtXtraInfo[4];
   OB79_Res  :          result:=iRES[obX.u].name;
   OB100_LearningStone: result:=result  + TxtXtraInfo[5];
   OB102_TreeOfKnowledge : result:=result  + TxtXtraInfo[18];
   OB107_SchoolofWar:  result:=result  + TxtXtraInfo[10];
   {OB48_MagicSpring:
   OB28_Faery:
   OB30_FountainofFortune:
   OB31_FountainofYouth:
   OB38_IdolofFortune:
   OB52_Mermaid:
   OB56_Oasis:
   OB64_RallyFlag:
   OB84_Crypt:
   OB94_Stables:
   OB96_Temple:  }
 end;

end;
{----------------------------------------------------------------------------}
function Cmd_Map_GetCursor(x,y,l:integer):string;
var
  s:string;
  p: integer;
  gid, HE, dist :integer;
begin
  // def cursor already set DxMouse.Id:=CrDef;
  p:=mTiles[x,y,l].P1;
  s:=format('[%d,%d,%d] P%d DIR%d, COST%d, O%d nCR%d ',[x,y,l,p,mPath.DirMap[x,y],mPath.Costpath[x,y],mTiles[x,y,l].obX.t,mTiles[x,y,l].nCreas]);
  s:=s+format(' TR=%d T=%d M=%d ', [mTiles[x,y,l].TR.t,mTiles[x,y,l].TR.u,mTiles[x,y,l].TR.m]);
  s:=s+format(' RD=%d T=%d M=%d ', [mTiles[x,y,l].RD.t,mTiles[x,y,l].RD.u,mTiles[x,y,l].RD.m]);
  HE:=mPlayers[mPL].ActiveHero;
  if HE=-1
  then
  // cursor computation when no Hero selected
  begin
    if p<>TL_FREE then
    begin
      s:=s+Cmd_Map_GetObjDesc(mTiles[x,y,l].ObX);
      case mTiles[x,y,l].obX.t of
        OB34_Hero:
        begin
          DxMouse.id:=CrHero;
          gid:=mObjs[mTiles[x,y,l].obX.oid].v;
          s:=s+ 'over ' + Cmd_Map_GetObjDesc(mHeros[gid].obX);
        end;
        OB98_City :
          DxMouse.id:=CrTown;
      end;
    end;
  end
  else
  // cursor computation when Hero selected
  begin
    with mHeros[HE] do
    begin
      case p of
        //mouse on free tile check if move allowed
        TL_FREE: begin
          if BoatId=0     //player on horse, no move if water
          then
            if mTiles[x,y,l].TR.t<>TR08_Water
              then DxMouse.id:=CrMove
              else DxMouse.id:=CrDef
          else            //player on boat, check sailing or landing or no move
            if mTiles[x,y,l].TR.t=TR08_Water
              then DxMouse.id:=CrSail
              else DxMouse.id:=CrAncre;
          //need to check if surrounded by crea
          if mTiles[x,y,l].nCreas > 0
          then  DxMouse.id:=CrFight;         //TODO check mouse cursor = fight
        end;

        //mouse on obj
        TL_OBJ: begin
          //Obj:=mTiles[x,y,l].obj;
          mObj:=mObjs[mTiles[x,y,l].obX.oid];
          s:=s + Cmd_Map_GetObjDesc(mTiles[x,y,l].obX);
          if mObj.t=OB98_City
          then DxMouse.id:=CrTown;
        end;

        //mouse on obj entry
        TL_ENTRY: begin
          //Obj:=mTiles[x,y,l].obj;
          mObj:=mObjs[mTiles[x,y,l].obX.oid];
          s:=s + Cmd_Map_GetTileDesc(x,y,l);

          case mObj.t of
            OB08_Boat:  DxMouse.id:=CrSail;
            OB26_Event: DxMouse.id:=CrDef;
            OB34_Hero: begin
              gID:=mObjs[mTiles[x,y,l].obX.oid].v;
              if gID=HE
              then DxMouse.id:=CrHero
              else
                if mPlayers[mHeros[gid].pid].team=mPlayers[mPL].team
                then  DxMouse.id:=CrMeet
                else  DxMouse.id:=CrFight;
               end;
            OB54_Monster: DxMouse.id:=CrFight;
            //OB98_City:  DxMouse.id:=CrTown;
            else
            begin
            if BoatId=0     //player on horse, no move if water
            then
              DxMouse.id:=CrBonus
            else            //player on boat, check sailing or landing or no move
            if mTiles[x,y,l].TR.t=TR08_Water
              then DxMouse.id:=CrSail
              else DxMouse.id:=CrAncre;
            end;
          end;
        end;
      end;

      // complete cursor with distance info if required
      if (DxMouse.id >= CrMove)
      then
      begin
        if PSKA.mov > mPath.CostPath[x,y]
        then dist:=0
        else dist:= 1+ ((mPath.CostPath[x,y]-PSKA.mov) div PSKB.mov);
        if dist > 3 then dist:=3;
        DxMouse.id:=DxMouse.id+ 6* dist;
        if mPath.CostPath[x,y] > 9000 then
        DxMouse.id:=CrDef
      end;
    end;
  end;
  result:=s;
end;
{----------------------------------------------------------------------------}
procedure Cmd_Map_AddmObj;
var
  i: integer;
  x,y,l: integer;
begin;
  if mObj.t in [21,46,143,222] then exit; // do not add some obj
  if mObj.def=-1 then exit;
  //update passability : Blocking P1=1 / Entry P1=2 / or let Free P1=0
  mObj.hasEntry:=false;
  l:=mObj.pos.l;
  for i:=0 to DEF_W*DEF_H-1 do
  begin
    x:=mObj.pos.x-(i mod DEF_W);
    y:=mObj.pos.y-(i div DEF_W);
    if not(Cmd_Map_Inside(x,y)) then continue;  //skip out of board square
    // is blocking
    if iDef[mObj.Def].p[i+1]='0' then
    begin
      if mTiles[x,y,l].P1=TL_OBJ then continue;     // skip already modified square
      mTiles[x,y,l].P1:=TL_OBJ;
      mTiles[x,y,l].obX.t:=mObj.t;
      mTiles[x,y,l].obX.u:=mObj.u;
      mTiles[x,y,l].obX.oid:=mObj.id;
    end;
    // is providing entry
    if iDef[mObj.Def].e[i+1]='1' then
    begin
      if mObj.pid >=0 then Cmd_Map_Unfog(mObj.pid,x,y,l);
      mObj.hasEntry:=true;
      mTiles[x,y,l].P1:=TL_ENTRY;
      if mObj.t=26 then mTiles[x,y,l].P1:=TL_EVENT;  // event entry not blocking mov
      mTiles[x,y,l].obX.t:=mObj.t;
      mTiles[x,y,l].obX.u:=mObj.u;
      mTiles[x,y,l].obX.oid:=mObj.id;
    end;
  end;

  // add the sprite
  case mObj.t of
    OB08_Boat: SnGame.AddSprite('AVXMyboat',mObj.Pos);
    OB34_Hero:  i:=0;
    OB26_Event: i:=0;
    else SnGame.AddSprite(iDef[mObj.Def].name,mObj.Pos);
  end;
end;



// Reader for simple DATA Type : int , string ...

procedure ReadFilePos;
var
  fPos:integer;
begin
  fPos:=FilePos(f);
  //mLog.InsertStr('filepos',IntToStr(FilePos(f))) ;
  mLog.InsertStr('filepos',IntToHex(fPos,8)) ;
end;
{----------------------------------------------------------------------------}
function ReadBool:boolean;
begin
  BlockRead(F, Buf, 1,ReadN);
  result:=(ShortInt(Buf[1])=1);
end;
{----------------------------------------------------------------------------}
function ReadByte:byte;              //-127..128
begin
  BlockRead(F, Buf, 1,ReadN);
  result:=Byte(Buf[1]);
end;
{----------------------------------------------------------------------------}
function ReadShortInt:Shortint;     //0..255  -127 ...127 ???
begin
  BlockRead(F, Buf, 1,ReadN);
  result:=ShortInt(Buf[1]);
end;
{----------------------------------------------------------------------------}
function ReadInt1B:integer;
begin
  BlockRead(F, Buf, 1,ReadN);
  result:=Integer(Buf[1]);
end;
{----------------------------------------------------------------------------}
function ReadInt2B:integer;
begin
  BlockRead(F, Buf, 2,ReadN);
  result:=Integer(Buf[1])+256*Integer(Buf[2]);
end;
{----------------------------------------------------------------------------}
function ReadInt4B:integer;
begin
  BlockRead(F, Buf, 4,ReadN);
  result:=Integer(Buf[1])
     +256*Integer(Buf[2])
   +65536*Integer(Buf[3])
+16777216*Integer(Buf[4]);
end;
{----------------------------------------------------------------------------}
function ReadCreaType:integer;
begin
  if mData.ver = ver_ROE
  then result:=ReadShortInt
  else result:=Min(ReadInt2B,117);
end;
{----------------------------------------------------------------------------}
function ReadIntArt:integer;
begin
  if mData.ver = VER_ROE
  then
  begin
    result:=ReadShortInt;               //(127 means -1 ??? instead of max 127)
    if result > 126 then result :=-1;
  end
  else
  begin
    result:=ReadInt2B;
    if result > 126 then result :=-1;  //(INT2B 65535 means -1 instead of max 127)
  end;
end;
{----------------------------------------------------------------------------}
function ReadPad(padN:integer):string;
begin
  BlockRead(F, CharBuf, padN, ReadN);
  result:=copy(string(CharBuf),1,padN);
  //mLog.Insert('Padding '+ NT+inttostr(padN)+NT+'"'+ copy(string(Charbuf),0,PadN)+'"');
end;
{----------------------------------------------------------------------------}
function ReadString: string;
var
  l: integer;
begin
  BlockRead(F, Buf, 4,ReadN);
  l:=Integer(Buf[1])+256*Integer(Buf[2])+4096*(Integer(Buf[3])+256*Integer(Buf[4]));
  BlockRead(F, CharBuf, l, ReadN);
  result:=copy(string(CharBuf),1,l);
end;

// Reader per Specific Game DATA
{----------------------------------------------------------------------------}
function ReadRes: TRes;
var
  i: integer;
begin
  for i:=0 to MAX_RES-1 do
  begin
    Result[i]:=ReadInt2B;
  end;
end;
{----------------------------------------------------------------------------}
function ReadArmy: TArmys;
var
  i: integer;
  s:string;
begin
  s:='';
  for i:=0 to MAX_ARMY do begin        // guardien 7* type xxxx qty yyyy
    result[i].t:=ReadCreaType;
    result[i].n:=ReadInt2B;
    s:= s+ format('%d(%d) ',[result[i].t,result[i].n]);
  end;
  mLog.InsertStr('Army at init', s);
end;
{----------------------------------------------------------------------------}
function ReadCityArmy(CT:integer): TArmys;
var
  i: integer;
  s:string;
begin
  s:='';
  for i:=0 to MAX_ARMY do begin        // guardien 7* type xxxx qty yyyy
    result[i].t:=14*mCitys[CT].t+2*i;
    result[i].n:=ReadInt2B;
    s:= s+ format('%d(%d) ',[result[i].t,result[i].n]);
  end;
  mLog.InsertStr('Army at init', s);
end;
{----------------------------------------------------------------------------}
procedure ReadCons(CT: integer; Enable: boolean);
var
  i,j,cons: integer;
  val: byte;
  builded: boolean;
  BU:int64;
begin
  BU:=0;
  BlockRead(F, Buf, 6, ReadN);
  for i:=0 to 5 do
  begin
    val:=byte(Buf[i+1]);
    BU:=BU or val shl (8*i);
    for j:=0 to 7 do
    begin
      cons:=8*i+j;
      begin
        builded:=(val and 1 = 1);
        //mLog.InsertInt(iCons[cons].name, integer(builded));
        if (enable and builded)
        then cmd_CT_BuyCons(CT,Cons);
      end;
      val:=val shr 1;
      if cons=40 then break;
    end;
  end;
  mLog.InsertStr('bu=',inttostr(BU));
end;
{----------------------------------------------------------------------------}
procedure ReadCityEvent(CT: integer);
begin
  with mcEvents[ncEvents] do
  begin
    city:=CT;
    name:=ReadString;
    mLog.InsertStr('CT_Event', name);
    desc:=ReadString;
    mLog.InsertStr('EvtDes', desc);           //event des
    giveRes:=ReadRes;
    takeRes:=ReadRes;
    // applicable restriciton
    if mData.ver > VER_ARB then readbool;     // apply to human only
    PL:=ReadInt1B;                            // apply to player xxx
    y:=ReadInt1B;                             // apply to hero cpu
    //mEvents[nEvents].players[xxx]:=true;

    // date start, repeat interval
    startDay:=ReadInt2B;
    mLog.InsertInt('1st occurence ', startDay);
    repeatperiod:=ReadShortInt;         // repeat every x day
    ReadPad(17);
    ReadCons(CT,false);                 // building bonus   TODO : giveBuilding)
    giveArmys:=ReadCityArmy(CT);        // army bonus qty...!!!
    ReadPad(4);
  end;
  inc(ncEvents)
end;
{----------------------------------------------------------------------------}
procedure ReadEvent;
var
  i: integer;
begin
  nEvents:=ReadInt2B;
  ReadInt2B;
  mLog.InsertRedStr('NbEvent ',inttostr(nEvents));
  for i:=0 to nEvents-1 do
  with mEvents[i] do
  begin
    name:=ReadString;
    mLog.EnterProc(format('id=%d EvtName=%s',[i,name]));
    desc:=ReadString;
    mLog.InsertStr('EvtDes', desc);                                  //event des
    giveRes:=ReadRes;
    takeRes:=ReadRes;

    // applicable restriciton
    if mData.ver > VER_ARB then readbool;       // apply to human only
    PL:=ReadInt1B;                              // apply to player xxx
    y:=ReadInt1B;                               // apply to hero cpu
    //mEvents[nEvents].players[xxx]:=true;

    // date start, repeat interval
    startDay:=ReadInt2B;
    mLog.InsertInt('1st occurence ', startDay);
    repeatperiod:=ReadInt2B;                   // repeat every x day

    ReadPad(16);                               // padding ... ???
    mLog.QuitProc('---------------------------------------------');
  end;
end;

{----------------------------------------------------------------------------}
procedure ReadPlayer;
var
  i,j,n:integer;
begin
  mLog.InsertRedStr('ReadPlayer','');
  if mHeader.custom then hPL:=mPL else hPL:=-1;
  with mData do

    for i:=0 to MAX_PLAYER-1 do
    with mPlayers[i] do
    begin
      nCity:=0;
      nHero:=0;
      // Handle Player name / human CPU
      mLog.InsertStr('Players name ', name);
      isHuman:=ReadBool;
      mLog.InsertBool('IsHuman',isHuman);
      isCPU:=ReadBool;
      mLog.InsertBool('IsCPU  ',isCPU);

      // Discard this unused Player
      if not(isCPU) and not(isHuman)
      then begin
        isAlive:=false;
        case ver of                                      // do some padding
          VER_ROE: ReadPad(6);
          VER_ARB: ReadPad(12);
          VER_SOD: ReadPad(13);
        end
      end
      // Handle used player
      else
      begin
        if hPL=-1 then
                if (isHuman) then hPL:=i;
        if (i=hPL) then isCPU:=false else isCPU:=true;
        isAlive:=true;
        inc(nPlr);
        Attitude:=ReadShortInt;                         //(00 - random, 01 -  warrior, 02 - builder, 03 - explorer)
        mLog.InsertInt('Atitud',attitude);
        case ver of
          VER_SOD: ReadShortInt;                       //p7=ReadShortInt else p7=-1
        end ;

        // Player Alignment and Town
        a:=ReadShortInt;                                      //(01 - castle; 02 - rampart; 04 - tower; 08 - inferno; 16 - necropolis; 32 - dungeon; 64 - stronghold; 128 - fortress; 256 - conflux);
        if ver <> VER_ROE then ReadShortInt;                  // to have the ninth town
        mLog.Insert('Aligne'+NT+inttostr(a));             // exemple 20 : 0010 0000  bit5 dungeon

        a:=ReadShortInt;
        mLog.Insert('RndCT'+NT+inttostr(a));              // 00 own random town

        hasMainCT:=(ReadBool);
        mLog.InsertBool('MainCT' , hasMainCT);
        if hasMainCT then
        begin                                             // ville principal
          if ver <> VER_ROE then begin
            hasNewHeroCT:=(ReadBool);                     //generateHeroAtMainTown
            mLog.InsertBool('NewTownHero', hasNewHeroCT);
            ReadShortInt;                                     //generateHero
          end
          else
            hasNewHeroCT:=true;
          posCT.x:=ReadInt1B;                              // main town pos
          posCT.y:=ReadInt1B;
          posCT.l:=ReadInt1B;
          mLog.Insert(format('PosCT'+NT+'%d, %d, %d',[posCT.x,posCT.y,posCT.l]));
        end;

        // Default Hero
        a:=ReadShortInt;                                      //p8
        mLog.Insert('MainHE?'+NT+inttostr(a));
        HE:=ReadInt1B;                                  //p9
        mLog.Insert('Hero'+NT+inttostr(HE));

        if HE <> 255
        then  begin
          a:=ReadShortInt;
          s:=ReadString;
          if HE > 127
          then HE:=255
          else
          begin
          mHeros[HE].used:=true;                          // Hero aleatoire
          mLog.Insert('NameDef'+NT+TxtHeroName[HE]);     // mHeros[HE].name

          mLog.Insert('Name'+NT+ s);
          if s<> '' then mHeros[HE].name:=s;              // rename HE for scenario
          end;
        end;

        if ver <> VER_ROE then
        begin
          ReadShortInt;
          n:=ReadShortInt;                                    // heroCount
          ReadPad(3);
          for j:=0 to n-1 do
          begin
            HE:=ReadInt1B;
            if HE > 127
            then HE:=0; //TODO improve set hereo above 127
            mHeros[HE].used:=true;                        // Hero aleatoire
            LogP.Insert('NameDef'+NT+TxtHeroName[HE]);   // mHeros[HE].name);
            s:=ReadString;
            mLog.Insert('Name'+NT+ s);
            if s<> '' then mHeros[HE].name:=s;
         end;
      end;
    end;
    // enf of alive player handling
    mLog.Insert('------------------------------------');
  end;
  mLog.QuitProc('Players');
end;

{----------------------------------------------------------------------------}
procedure ReadVic;
const
  VIC00_artifact=0;
  VIC01_gatherTroop=1;
  VIC02_gatherResource=2;
  VIC03_buildCity=3;
  VIC04_buildGrail=4;
  VIC05_beatHero=5;
  VIC06_captureCity=6;
  VIC07_beatMonster=7;
  VIC08_takeDwellings=8;
  VIC09_takeMines=9;
  VIC10_transportItem=10;
  VICDF_winStandard=-1;
begin
  mLog.enterProc('ReadVic');
  with mData do begin
    vct:=ReadShortInt;
    if vct = VICDF_winStandard
    then vic:=txtVCDESC[0]
    else
    begin
      b:=ReadShortInt;                            //normal vic en plus
      mLog.InsertInt('VicNormal',b);
      b:=ReadShortInt;                            //appply to cpu ?
      mLog.InsertInt('VicCPU',b);
      case VCT of
        VIC00_artifact: begin
          vicitem:=ReadShortInt;
          vic:=format(txtVCDESC[1]+NT+' %d',[vicitem]);
        end;

        VIC01_gatherTroop :begin
          vicitem:=ReadInt1B;
          if ver<> ver_ROE then   ReadPad(1);
          vicqty:=ReadInt2B;
          if vicitem > 116 then vicitem:=1;
          vic:=format(txtVCDESC[2]+NT+' %d of %s',[vicqty,iCrea[vicitem].name]);
          ReadInt2B;     // maybe more
        end;

        VIC02_gatherResource:begin
          vicitem:=ReadShortInt;
          vicqty:=ReadInt2B;
          vic:=format(txtVCDESC[3]+NT+' %d of %s',[vicqty,iRes[vicitem].name]);
          ReadInt2B;     // maybe more
        end;

        VIC03_buildCity:begin
          vicpos.x:=ReadInt1B;
          vicpos.y:=ReadInt1B;
          vicpos.l:=ReadInt1B;
          a:=ReadShortInt;
          b:=ReadShortInt;
          vic:=format(txtVCDESC[4]+NT+' %d, %d, %d a citylevel %d  and fortlevel %d ',[vicpos.x,vicpos.y,vicpos.l,a,b]);
        end;

        VIC04_buildGrail: begin
          vicpos.x:=ReadInt1B;
          vicpos.y:=ReadInt1B;
          vicpos.l:=ReadInt1B;
          if vicpos.l>2 then LogP.Insert('BuildGrail anywhere')
          else
          vic:=format(txtVCDESC[5]+NT+' at %d, %d, %d',[vicpos.x,vicpos.y,vicpos.l]);
        end;

        VIC05_beatHero: begin
          x:=ReadInt1B;
          y:=ReadInt1B;
          z:=ReadInt1B;
          vic:=format(txtVCDESC[6]+NT+' at %d, %d, %d',[x,y,z]);;
        end;

        VIC06_captureCity: begin
          vicpos.x:=ReadInt1B;
          vicpos.y:=ReadInt1B;
          vicpos.l:=ReadInt1B;
          vic:=format(txtVCDESC[7] +' %d, %d, %d',[vicpos.x,vicpos.y,vicpos.l]);
        end;

        VIC07_beatMonster: begin
          vicpos.x:=ReadInt1B;
          vicpos.y:=ReadInt1B;
          vicpos.l:=ReadInt1B;
          vic:=format(txtVCDESC[8]+NT+' %d, %d, %d',[vicpos.x,vicpos.y,vicpos.l]);
        end;

        VIC08_takeDwellings:begin
          vic:=txtVCDESC[9];
        end;

        VIC09_takeMines:begin
          vic:=txtVCDESC[10];
        end;

        VIC10_transportItem: begin
          vicitem:=ReadByte;
          if vicItem > MAX_ART then vicItem:=Random(Max_ART);
          vicpos.x:=ReadInt1B;
          vicpos.y:=ReadInt1B;
          vicpos.l:=ReadInt1B;
          vic:= format(txtVCDESC[11] + ' %s to this town %d, %d, %d',[iART[vicitem].name,vicpos.x,vicpos.y,vicpos.l]);
        end
        else
        begin
          vic:=txtVCDESC[vct];
        end;
      end;
    end;
    mLog.Insert('Vic' + NT + vic);
    mLog.QuitProc('ReadVic');
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadLos;
const
  LOSCastle=0;
  LOSHero=1;
  LOStimeExpires=2;
  LOSStandard=-1;
begin
  with mData do
  begin
    lss:=ReadShortInt;
    case lss of
      LOSStandard: los:=txtLCDESC[0];
      LOSCastle: begin
        x:= ReadShortInt;
        y:=ReadShortInt;
        l:=ReadShortInt;
        los:=txtLCDESC[1] + format(' at [%d %d %d]',[x,y,l]); ;
      end;
      LOSHero: begin
        x:=ReadShortInt;
        y:=ReadShortInt;
        l:=ReadShortInt;
        los:=txtLCDESC[2] + format(' at [%d %d %d]',[x,y,l]); ;
      end;
      LOStimeExpires: begin
        x:=ReadInt2B;
        los:=txtLCDESC[3] + format('%d]',[x]);
      end
      else begin
        ReadShortInt;
        ReadShortInt;
        los:=txtLCDESC[lss];
      end;
    end;
    mLog.Insert('Los' + NT + los);
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadTeam;
var
  i:integer;
  hasTeam : byte;
begin
  with mData do
  begin
    for i:=-1 to MAX_PLAYER-1 do
      mPlayers[i].team:=i;
    hasTeam:=ReadShortInt;
    if (hasTeam >0 ) then
    begin
      mLog.InsertInt('Map with Team, qty=',hasTeam);
      for i:=0 to MAX_PLAYER-1 do
        mPlayers[i].team:=ReadShortInt;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadRumor;
var
  i,n: integer;
  s: string;
begin
  mLog.EnterProc('ReadRumor');
  n:=ReadShortInt;                                    // Rumor
  ReadPad(3);
  mLog.InsertInt('RumorQty',n);
  for i:=0 to n-1 do begin
    s:=ReadString;
    mLog.Insert('Title    '+ NT + s);
    s:=ReadString;
    mLog.Insert('Des      '+NT+s);
  end;
  mLog.QuitProc('ReadRumor');
end;
{----------------------------------------------------------------------------}
procedure ReadCustomHero;
var
  i,j,k,n,x: integer;
  val: byte;
const
  mxHero=156;
  mxspel=65;
begin
  if mData.ver < VER_SOD then exit;
  for k:=0 to 155 do
  begin
    if ReadShortInt = 0  then
      mLog.InsertStr('no custom Hero' , inttostr(k) +' ' + mHeros[k].name)
    else
    begin
      mLog.InsertStr('is custom Hero' , inttostr(k) +' ' + mHeros[k].name);

      // custom experience
      if ReadShortInt<> 0 then
      begin
        x:=ReadInt4B;
        mLog.Insertint('Experience', x);
      end;

      //ability qty
      if ReadShortInt<> 0 then
      begin
        n:=ReadShortInt;
        ReadPad(3);
        if n<>0 then
        for j:=0 to n-1  do
        begin
          a:=ReadShortInt;
          b:=ReadShortInt;
          mLog.InsertStr('sec skills', iSSK[a].name);
        end;
      end;

      // specific art set ?
      if ReadShortInt<> 0 then
      begin
        for j:=0 to 15  do
        begin
          x:=ReadInt2B;
        end;
        //misc5 art //17
        if mData.ver >=VER_SOD then
        ReadPad(2);
        //spellbook ??
        x:=ReadInt2B;
        //19
        ReadPad(2);

        // artifacts in hero's bag ?
        n:=ReadInt2B;
        if n>0 then begin
          for i:=0 to n-1 do
          begin
            x:=ReadInt2B;
          end;
        end;
      end; //artifacts

      //custom Bio ?
      if ReadShortInt<>0 then begin
        s:=ReadString;
        mLog.InsertStr('bio', s);
      end;
      ReadShortInt; //   sex

      //custom spells
      if ReadShortInt<>0 then
      begin
        for i:=0 to 8 do     //9 byte desc for spels
        begin
          val:=Readbyte;
          for j:=0 to 7 do
          begin
            if (val and 1 = 1) and (8*i+j < mxspel) then
            begin
              mLog.InsertStr('SpellDenied', iSPEL[8*i+j].name);
            end;
            val:=val shr 1;
          end;
        end;
      end;

      //custom PrimSkills
      if Readbool then
      begin
        for j:=0 to 3 do
          ReadShortInt;
      end;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadAllowedHero;
var
  i,j,n: integer;
  val: byte;
  mxhero: integer;
begin
  mLog.Insert('Mark hero used 16 or 20 byte');
  if mData.ver = VER_ROE
  then mxhero:=16
  else mxhero:=20;
  ReadFilePos;
  //mark used hero
  for i:=0 to mxhero-1 do
  begin
    val:=Readbyte;
    for j:=0 to 7 do
    begin
      if (8*i+j < 128) then
      begin
        if (val and 1 = 0) then
        begin
          mHeros[8*i+j].used:=true;
          mLog.InsertStr('Used Hero', mHeros[8*i+j].name);
        end
        else
          mHeros[8*i+j].used:=false;
        val:=val shr 1;
      end;
    end;
  end;

  if mData.ver > VER_ROE then ReadPad(4);
  ReadFilePos;
  // Hero customised SOD version minimun
  if mData.ver >= VER_SOD then
  begin
    n:=ReadInt1B;
    for i:=0 to n-1 do
    begin
      ReadShortInt;    //id
      ReadShortInt;    //custom portrait
      ReadString;      //custom name
      ReadShortInt;    //owner ?
    end;
  end;
  ReadPad(31);
end;
{----------------------------------------------------------------------------}
procedure ReadAllowedArt;
var
  i,j: integer;
  val: byte;
  maxArt: integer;
begin
  if mData.ver = VER_ROE then exit;
  // Art allowed, ARB version minimun
  if (mData.ver = VER_ARB) then maxArt:=17 else maxArt:=18;
  for i:=0 to maxArt-1 do
  begin
    val:=ReadByte;
    for j:=0 to 7 do
    begin
      if (val and 1 = 1) and (8*i+j < 127) then
        mLog.InsertStr('ForbiddenART', iART[8*i+j].name);
      val:=val shr 1;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadAllowedSpell;
var
  i,j: integer;
  val: byte;
begin
  if mData.ver < VER_SOD then exit;
  for i:=0 to 8 do     //9 byte desc for spels
  begin
    val:=ReadByte;
    for j:=0 to 7 do
    begin
      if (val and 1 = 1) and (8*i+j < MAX_SPEL) then
        mLog.InsertStr('ForbiddenSpell', iSPEL[8*i+j].name);
      val:=val shr 1;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadAllowedAbility;
var
  i,j: integer;
  val: byte;
begin
  if mData.ver < VER_SOD then exit;
  for i:=0 to 3 do
  begin
    val:=ReadByte;
    for j:=0 to 7 do
    begin
      if (val and 1 = 1) and (8*i+j < MAX_SSK) then
        mLog.InsertStr('ForbiddenSkil', iSSK[8*i+j].name);
      val:=val shr 1;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadHeader;
var
  levelLimit: byte;
begin
  mLog.EnterProc('MAP_Header');
  updateSplash;
  with mData do
  begin
    ver:=ReadShortInt;
    mLog.Insert('Ver'+NT+inttostr(ver));
    ReadPad(4);
    dim:=ReadInt2B;
    mLog.Insert('Dim'+NT+inttostr(dim));
    ReadPad(2);
    level:=ReadShortInt;
    mLog.Insert('Level  '+NT+inttostr(level));
    name:=ReadString;
    mLog.Insert('Name'+NT+name);
    des:=ReadString;
    mLog.Insert('Des '+NT+ des);
    dfc:=ReadShortInt;
    mLog.Insert('Dfc '+NT+inttostr(dfc));

    if(ver <> VER_ROE)
    then levelLimit := ReadShortInt  // hero level limit
    else levelLimit := 0;

    ReadPlayer;
    ReadVic;
    ReadLos;
    ReadTeam;
    UpdateSplash;
    ReadAllowedHero;
    ReadAllowedArt;
    ReadAllowedSpell;
    ReadAllowedAbility;
    UpdateSplash;
    ReadRumor;
    ReadCustomHero;
  end;
  mLog.QuitProc('MAP_Header');
end;
{----------------------------------------------------------------------------}
procedure ReadTile;
var
  i,j:integer;
  x,y,l:integer;
begin
  GetLocalTime(SystemTime);
  mData.starttile:='['+ TimeToStr(Time)+'-'+ format('%.3d',[SystemTime.wMilliseconds])+ '] ' +NT+'Start TILE'
  + ' DrawCount ' + inttostr(SnLoadingMap.drawcounter);
  mLog.EnterProc('Tiles');
  with mData do
  begin
    //s:=NT+'Ter'+ NT +'Tile'+ NT+'River'+ NT + 'RvCfg'+ NT +'Road' + NT + 'Rdcfg' + NT+ 'Mirror';
    //mLog.Insert(s);
    for l:=0 to level do
    begin
      for i:=0 to dim*dim-1 do
      begin
        BlockRead(F, TileBuf, SizeOf(TileBuf), ReadN);
        x:=i mod dim;
        y:=i div dim;
        if (i mod 8000) = 0
        then updateSplash;

        mTiles[x,y,l].TR.t:=TileBuf[1];
        mTiles[x,y,l].TR.u:=TileBuf[2];
        mTiles[x,y,l].TR.m:=TileBuf[7] and $03;
        mTiles[x,y,l].RV.t:=TileBuf[3];
        mTiles[x,y,l].RV.u:=TileBuf[4];
        mTiles[x,y,l].RV.m:=(TileBuf[7] and $0C) div 4;
        mTiles[x,y,l].RD.t:=TileBuf[5];
        mTiles[x,y,l].RD.u:=TileBuf[6];
        mTiles[x,y,l].RD.m:=(TileBuf[7] and $30) div 16;
        mTiles[x,y,l].obX.t:=0;
        mTiles[x,y,l].P1:=TL_FREE;
        mTiles[x,y,l].nCreas:=0;
        if mTiles[x,y,l].TR.t=8 then
        for j:=0 to 8 do
         mTiles[1+x-(j mod 3),1+y-(j div 3),l].plage:=true;
        //mLog.Insert(format('%d %d %d',[mTiles[x,y,l].TR.t,mTiles[x,y,l].TR.u,mTiles[x,y,l].TR.m] ));
      end;
    end;
  end;
  mLog.QuitProc('Tiles');
  GetLocalTime(SystemTime);
  mData.endtile:='['+ TimeToStr(Time)+'-'+ format('%.3d',[SystemTime.wMilliseconds])+ '] ' +NT+'End   TILE ' + inttostr(mData.dim*mData.dim)
  + ' DrawCount ' + inttostr(SnLoadingMap.drawcounter);

end;
{----------------------------------------------------------------------------}
procedure  Read_nDef;
begin
  GetLocalTime(SystemTime);
  mData.StartDef:='['+ TimeToStr(Time)+'-'+ format('%.3d',[SystemTime.wMilliseconds])+ '] ' +NT+'Start DEF'
  + ' DrawCount ' + inttostr(SnLoadingMap.drawcounter);
  nDef:=ReadInt2B;
  mLog.InsertRedStr('Number of Def entry',inttostr(nDef));
end;
{----------------------------------------------------------------------------}
procedure  ReadDef;
var
  i,p,x:integer;
  DefName:string;

   procedure ProgressInfo_ReadDef;
   begin
      x:=mData.loadStep;
      mData.loadStep:=1 + (4 * i) div (nDef-1);
      if x<> mData.loadStep then mLog.InsertRedStr('Step DEF',inttostr(mData.loadStep));
      UpdateSplash;
    end;

begin
  Read_nDef;
  mLog.EnterProc('ReadDef');
  DefTxt:=TStringList.Create;
  ReadPad(2);
  for i:=0 to nDef-1 do
  begin
    if (i mod 10) = 0 then ProgressInfo_ReadDef;     // 1 splash update tous les  10 Def
    Defname:=ReadString;
    p:=ANSIPOS('.',DefName);
    DefName:=copy(DefName,0,p-1);
    
    // change defname to known def
    if DefName='AVA0129'  then DefName:='AVA0120';
    if DefName='AVA0130'  then DefName:='AVA0120';
    if DefName='AVA0131'  then DefName:='AVA0120';
    if DefName='AVA0132'  then DefName:='AVA0120';
    if DefName='AVA0133'  then DefName:='AVA0120';
    if DefName='AVA0134'  then DefName:='AVA0120';
    if DefName='AVA0135'  then DefName:='AVA0120';
    if DefName='AVA0136'  then DefName:='AVA0120';
    if DefName='AVA0138'  then DefName:='AVA0120';
    if DefName='AVA0139'  then DefName:='AVA0120';
    if DefName='AVA0140'  then DefName:='AVA0120';
    if DefName='AVA0141'  then DefName:='AVA0120';
    if DefName='AVA0135'  then DefName:='AVA0120';
    if DefName='AVGnoll'  then DefName:='AVGgnll0';
    if DefName='ah16_e'   then DefName:='ahrandom';
    if DefName='ah17_e'   then DefName:='ahrandom';
    if DefName='ahPlace'  then DefName:='ahrandom';
    if DefName='AVCrand0' then DefName:='AVCranx0';
    if DefName='AVCstro0' then DefName:='AVCstrx0';
    if DefName='AVCramp0' then DefName:='AVCramx0';
    if DefName='AVCnecr0' then DefName:='AVCnecx0';
    if DefName='AVCstro0' then DefName:='AVCstrx0';
    if DefName='AVCtowr0' then DefName:='AVCtowx0';
    if DefName='AVCinft0' then DefName:='AVCinfx0';

    SnGame.AddDef(DefName);

    DefTxT.Add(DefName);
    ReadPad(42); // Def definition...
    {   Block[6], Vis[6], ?[2], TER[2], ID[4], SUB[4], TP[1], Print[1], empty[16]
	animationFile = reader.readString();
	setSize(8, 6);
	ui8 blockMask[6];
	ui8 visitMask[6];
	for(auto & byte : blockMask)
		byte = reader.readUInt8();
	for(auto & byte : visitMask)
		byte = reader.readUInt8();
	reader.readUInt16();
	ui16 terrMask = reader.readUInt16();
	id = Obj(reader.readUInt32());
	subid = reader.readUInt32();
	int type = reader.readUInt8();
	printPriority = reader.readUInt8() * 100; // to have some space in future
	if (isOnVisitableFromTopList(id, type))
		visitDir = 0xff;
	else
		visitDir = (8|16|32|64|128);
	reader.skip(16);
    }
  end;

  mLog.QuitProc('ReadDef');
  GetLocalTime(SystemTime);
  mData.endDef:='['+ TimeToStr(Time)+'-'+ format('%.3d',[SystemTime.wMilliseconds])+ '] ' +NT+'End  DEF ' + inttostr(nDef) 
  + ' DrawCount ' + inttostr(SnLoadingMap.drawcounter);
end;
{----------------------------------------------------------------------------}
procedure ReadBonus;
var
  n,i: integer;
begin
  with mBonus[nBonus] do
  begin
    EXP:=ReadInt4B;
    mLog.insertint('Reward Exp: ',EXP);
    PSK.ptm:=ReadInt2B;
    PSK.ptm:=PSK.ptm-ReadInt2B;
    mLog.insertint('Reward PtMagie: ',PSK.ptm);
    MORAL:=ReadShortInt;
    mLog.insertint('Reward  Moral: ',MORAL);
    LUCK:=ReadShortInt;
    mLog.insertint('Reward Chance: ',LUCK);

    GIVERES:=ReadRes;
    ReadRes;      //TakeRES ?
    PSK.att:=ReadShortInt;
    PSK.def:=ReadShortInt;
    PSK.pow:=ReadShortInt;
    PSK.kno:=ReadShortInt;

    n:=ReadShortInt; //nb of secckill
    for i:=0 to n-1 do
    begin
      a:=ReadShortInt;
      b:=ReadShortInt;
      SSK[a]:=b;
      mLog.insert('Reward secskill: '+inttostr(b) + ' of ' + iSSK[a].name);
    end;
    //give artifact
    nART:=ReadShortInt; //qty of artifact
    for i:=0 to nART-1 do
    begin
      ARTS[i]:=ReadIntArt;
      mLog.insertstr('Reward ART: ',iArt[ARTS[i]].name);
    end;
    // Spell
    a:=ReadShortInt; //qty of Spell
    for i:=0 to a-1 do
    begin
      b:=ReadShortInt;
      SPELS[b]:=true;
      mLog.insertstr('Reward Spell: ',iSpel[b].name);
    end;
    // give crea
    nCR:=ReadShortInt; //nb of crea
    for i:=0 to nCR-1 do
    begin
      b:=ReadCreaType;
      x:=ReadInt2B;
      CREAS[i].t:=b;
      CREAS[i].n:=x;
      mLog.insert('Reward Crea: '+ inttostr(x) + ' '+iCrea[b].name);
    end;
  end;
end;
{----------------------------------------------------------------------------}
{TMapArt = record
  t:    integer;  // Fmt A1 / R
  pos:  TPos;     // x y l
  msg:  string;   // M msg
  guard:boolean;
  armys:TArmys;   // G guardian
  val:  integer;  // Scroll value , res qty             }

procedure ReadOB05_Artifact;
begin
  if ReadBool then
  begin
    mObj.msg:=ReadString;
    mLog.InsertStr('Msg',mObj.msg);
    mObj.guarded:=(ReadBool);
    if mObj.guarded then mObj.Armys:=ReadArmy;
    ReadPad(4);
  end
end;
{----------------------------------------------------------------------------}
procedure ReadOB06_Pandora; // pandora msg + gardien
var
  i,n:integer;
begin
  if ReadBool then
  begin
    mObj.msg:=ReadString;
    mLog.InsertStr('Msg',mObj.msg);
    mObj.guarded:=(ReadBool);
    if mObj.guarded then mObj.Armys:=ReadArmy;
    ReadPad(4);
  end;
  mObj.u:=nBonus;

  ReadBonus;
  ReadPad(8);
  inc(nBonus);
end;
{----------------------------------------------------------------------------}
procedure ReadOB12_Campfire;
begin
  mObj.u:=random(6);   // type of res bonus
  mObj.v:=4+random(3); // qty 4 TO 6
end;
{----------------------------------------------------------------------------}
procedure ReadOB16_CreatureBank;
var
  c,n, t,i, BK : integer;
begin
  BK:=mObj.u;
  case random(100) of
  0..29  : t:=0;
  30..59 : t:=1;
  60..89 : t:=2;
  90..99 : t:=3;
  end;
    with mBanks[nBanks] do
    begin

    for i:=0 to MAX_ARMY do  begin
      mObj.Armys[i].t:=iBank[BK,t].Armys[i].t;
      mObj.Armys[i].n:=iBank[BK,t].Armys[i].n;
    end;
    bRes:=iBank[BK,t].bRes;
    bArmy.t:=iBank[BK,t].bCR.t;
    bArmy.n:=iBank[BK,t].bCR.n;  //0 most of the time
    bTotalArts:=0;
    Take:=false;
    for i:=0 to MAX_PLAYER-1 do Visited[i]:=false;
  end;

  mObj.v:=nBanks;
  inc(nBanks);
end;
{----------------------------------------------------------------------------}
procedure ReadOB17_Generator;           // Creature generator
var
  i: integer;
begin
  mObj.pid:=ReadShortInt;
  ReadPad(3);
  i:= 2*(mobj.Def-157);  //835         //TODO: better  Def to Crea allocation
  if i< 112
  then mObj.v:=iCrea[i].growth
  else mObj.v:=1;
end;
{----------------------------------------------------------------------------}
procedure ReadOB20_Golem;               // golem factory
begin
  mObj.pid:=ReadShortInt;                   //owner
  ReadPad(3);
end;
{----------------------------------------------------------------------------}
procedure ReadOB22_Corpse;
var
  AR: integer;
begin
  if random(100) > 80
  then mObj.v:=7+ random(128)           //Todo MAXART
  else mObj.v:=0;
end;
{----------------------------------------------------------------------------}
procedure ReadOB24_DerelictShip;       // to merge with ReadOB84_Crypt;
var
  c,n, t,i, BK : integer;
begin
  BK:=8;
  case random(100) of
  0..29  : t:=0;
  30..59 : t:=1;
  60..89 : t:=2;
  90..99 : t:=3;
  end;
  with mBanks[nBanks] do
  begin
    for i:=0 to MAX_ARMY do  begin
      mObj.Armys[i].t:=iBank[BK,t].Armys[i].t;
      mObj.Armys[i].n:=iBank[BK,t].Armys[i].n;
    end;
    bRes:=iBank[BK,t].bres;
    bArmy.t:=iBank[BK,t].bCR.t;
    bArmy.n:=iBank[BK,t].bCR.n;
    bTotalArts:=0;
    Take:=false;
    for i:=0 to MAX_PLAYER-1 do Visited[i]:=false;
  end;
  mObj.v:=nBanks;
  inc(nBanks);
end;
{----------------------------------------------------------------------------}
procedure ReadOB25_DragonUtopia;
var
  c,n, t,i, BK : integer;
begin
  BK:=10;
  case random(100) of
  0..29  : t:=0;
  30..59 : t:=1;
  60..89 : t:=2;
  90..99 : t:=3;
  end;
  with mBanks[nBanks] do
  begin
    for i:=0 to MAX_ARMY do  begin
      mObj.Armys[i].t:=iBank[BK,t].Armys[i].t;
      mObj.Armys[i].n:=iBank[BK,t].Armys[i].n;
    end;
    bRes:=iBank[BK,t].bres;
    bArmy.n:=iBank[BK,t].bCR.t;
    bArmy.n:=iBank[BK,t].bCR.n;
    n:=0;
    for i:=0 to iBank[BK,t].bArt1 -1 do
    begin
      bArts[n]:=90+random(30); //relique
      inc(n);
    end;
    for i:=0 to iBank[BK,t].bArt2 -1 do
    begin
      bArts[n]:=60+random(30); //majeur
      inc(n);
    end;
    for i:=0 to iBank[BK,t].bArt3 -1 do
    begin
      bArts[n]:=30+random(30); //mineur
      inc(n);
    end;
    for i:=0 to iBank[BK,t].bArt4 -1 do
    begin
      bArts[n]:=7+ random(23); //trésor
      inc(n);
    end;
    bTotalArts:=n;
    Take:=false;
    for i:=0 to MAX_PLAYER-1 do Visited[i]:=false;
  end;
  mObj.v:=nBanks;
  inc(nBanks);
end;
{----------------------------------------------------------------------------}
procedure ReadOB26_Event;               // local event
var
  i:integer;
  s:string;
begin
  if ReadBool then
  begin
    s:=ReadString;
    mLog.InsertStr('EventMessage', s);
    mObj.v:=mSigns.count;
    mSigns.Add(s);
    if ReadBool then ReadArmy;
    ReadPad(4);
  end;
  mObj.u:=nBonus;
  ReadBonus;
  ReadPad(8);
  inc(nBonus);
  ReadShortInt; // apply to all plr      FF
  ReadShortInt; // apply to all cpu      1
  ReadShortInt; // apply to human        1
  ReadShortInt; // autodestructoion      0
  ReadShortInt; // formation             0
  ReadShortInt; // bonus no              0
  ReadShortInt; // Bonus val             0
end;
{----------------------------------------------------------------------------}
procedure ReadOB29_FlotSam;
begin
  mObj.v:=random(4);   // 25% rien, 25% 5 bois ,25% 5bois+200or, 25% 5bois+500 or
end;
{----------------------------------------------------------------------------}
procedure ReadOB33_Garnison;
begin
  mObj.pid:=ReadShortInt;                         //Owner
  ReadPad(3);
  mObj.Armys:=ReadArmy;
  if mData.ver > VER_ROE then ReadShortInt ;      //removableUnits
  ReadPad(8);
end;
{----------------------------------------------------------------------------}
procedure ReadOB34_Hero;
var
  i,n,p: integer;
  CT: integer;
  mxspel: integer  ;
  val:byte;
const
isDay1 : boolean = true;
begin
  if(mData.ver>VER_RoE)
  then ReadPad(4);
  mObj.pid:=ReadShortInt;
  HE:=ReadInt1B;

  if (HE=255) or (HE>127) then
  begin
     if mTiles[mObj.pos.x-2,mObj.pos.y,mObj.pos.l].obX.T=OB98_City
     then
     begin
       CT:=mObjs[mTiles[mObj.pos.x-2,mObj.pos.y,mObj.pos.l].obX.oid].v;
       if mHeader.Joueurs[mObj.pid].hasMainCT then
       begin
         if (mHeader.Joueurs[mObj.pid].PosCT.x=mCitys[CT].Pos.x) and (mHeader.Joueurs[mObj.pid].PosCT.y=mCitys[CT].Pos.y)
         then HE:=mHeader.Joueurs[mObj.pid].ActiveHero;
       end
       else
       begin
         HE:=mHeader.Joueurs[mObj.pid].ActiveHero;
         if mHeros[HE].used=true  // already used in the map .....
         then HE:=-1;
       end;
       if HE=-1 
       then HE:=Cmd_HE_NewHero(mCitys[CT].t,isDay1);
       mHeros[HE].used:=true;
    end
    else
     HE:=Cmd_HE_NewHero(-1,isDay1);
  end;

  mObj.v:=HE;
  mObj.t:=OB34_Hero;
  mObj.u:=HE div 8;

  with mHeros[HE] do
  begin
    oid:=mObj.id;

    // add a book for magician and a catapult for all
    if Cmd_HE_isMagician(HE) then Cmd_HE_SetART(HE,AR000_Spellbook);
    Cmd_HE_SetART(HE,AR003_Catapult);

    mLog.InsertStr('Heroes=' , name);
    used:=true;
    pid:=mObj.pid;
    if pid <> -1 then
    begin
      mPlayers[pid].LstHero[mPlayers[pid].nHero]:=HE;
      inc(mPlayers[pid].nHero);
    end;
    if ReadBool then
      name:=ReadString;

    // experience
    if mData.ver > VER_ARB then //TODO check map exp custom is ok
    begin
      if ReadBool then
      begin
        exp:=ReadInt2B;
        exp:=exp+4096*ReadInt2B;
      end
    end
    else
    begin
      exp:=ReadInt2B;
      exp:=exp+4096*ReadInt2B;
    end ;
    if exp=0 then exp:=70;

    // portrait custom
    if ReadBool then
      ReadShortInt;

    // skills custom
    if ReadBool then
    begin
      //reset skills
      for p:=0 to MAX_SSK-1 do
      begin
        SSK[p]:=0;
      end;
      n:=ReadShortInt;
      ReadPad(3);
      for p:=0 to n-1 do
      begin
        a:=ReadShortInt;
        b:=ReadShortInt;
        for i:=0 to b-1 do Cmd_HE_AddSSK(HE,a); // increase SSK by level 1,2,3
        mLog.InsertStr('Custom Skill ',iSSK[a].name);
      end;
    end;
    // army custom
    if ReadBool then
      Armys:=ReadArmy;
    ReadShortInt;                        //FF army strategy ?

    // artifcat custom
    if ReadBool then
    begin
      for p:=0 to 15 do              //max_slot16
      begin
        x:=ReadIntArt;           //complement for artid;
        if (x=65535) or (x=-1) then continue;
        cmd_HE_SetART(HE,x,p);
        mLog.InsertStr('Arts at init',iArt[x].name);
      end;
      //
      if mData.ver >=VER_SOD then
      ReadInt2B;                             //misc5 art in slot17

      //spellbook ??
      x:=ReadIntArt; //complement for artid;
      if x=0 then Cmd_HE_SetART(HE,AR000_Spellbook);

      //slot19
      x:=ReadIntArt;

      n:=ReadInt2B;
      if n > 0 then
      for p:=0 to n-1 do
      begin
        x:=ReadIntArt; //complement for artid;
        mLog.InsertInt('Arts:',x);
        if x=65535 then continue;
        cmd_He_setART(HE,x,MAX_SLOT+p);
        mLog.InsertStr('Arts in pack',iArt[x].name);
      end

    end;
    //artifacts

    ReadShortInt; //patrol.patrolRadious = readNormalNr(bufor,i, 1); ++i;

    if(mData.ver>VER_RoE) then
    begin
      if ReadShortInt <> 0 then
        ReadString;        //biography
      ReadShortInt;	           //sex
    end;

    //spells
    if(mData.ver > VER_ARB) then
    begin
      a:=ReadShortInt;           //areSpells
      if a <>0 then
      begin
        mxspel:=70;
        for i:=0 to 8 do     //9 byte desc for spels
        begin
          val:=Readbyte;
          { for j:=0 to 7 do
          begin
            if (val and 1 = 1) and (8*i+j < mxspel) then
            begin
              mLog.InsertStr('MandatorySpell', iSPEL[8*i+j].name);
              //2014-JAN-10 correction add custo map spell
              cmd_HE_AddSpell(HE,8*i+j);
            end;
            val:=val shr 1;
          end; //end for j  }
        end;   //end for i
      end // end a<>0
    end
    else
      if (mData.ver=VER_ARB) then     //we can read one spell
      begin
        a:=ReadShortInt;
        //if(buff!=254)	nhi->spells.insert(buff);
      end;
      //spells loaded
    end;
    //customPrimSkills
    if(mData.ver > VER_ARB) then
    begin
      a:=ReadShortInt;
      if a<>0 then
      begin
        cmd_HE_SetSkill(HE,0,0,0,0);
        cmd_HE_AddSkill(HE,ReadShortInt,0,0,0);
        cmd_HE_AddSkill(HE,0,ReadShortInt,0,0);
        cmd_HE_AddSkill(HE,0,0,0,ReadShortInt);
        cmd_HE_AddSkill(HE,0,0,ReadShortInt,0);
        mHeros[HE].PSKA.ptm:=10*mHeros[HE].PSKB.kno;
        mHeros[HE].PSKB.ptm:=10*mHeros[HE].PSKB.kno;
      end;
    end;

  ReadPad(16);

  // get position and CT improvment if inside CT
  with mHeros[HE] do begin
  pos.x:=mObj.pos.x-1;
  pos.y:=mObj.pos.y;
  pos.l:=mObj.pos.l;
  if mTiles[pos.x-1,pos.y,pos.l].obX.T=OB98_City then
  begin
    mObj.pos.x:=mObj.pos.x-1;
    pos.x:=mObj.pos.x-1;
    obX:=mTiles[pos.x,pos.y,pos.l].obX;
    mTiles[pos.x,pos.y,pos.l].P1:=2;
    CT:=mObjs[mTiles[pos.x,pos.y,pos.l].obX.oid].v;
    Cmd_HE_VisitCity(HE,CT);
    //TODO move to a better place  Cmd_HE_VisitCity  ?
    mTiles[pos.x,pos.y,pos.l].obX.T:=OB34_Hero;
    mTiles[pos.x,pos.y,pos.l].obX.U:=HE div 8 ;
    mTiles[pos.x,pos.y,pos.l].p1:=2;
    mTiles[pos.x,pos.y,pos.l].obX.oid:=oid;
  end;
  end;
  if (mObj.pid  <> -1) then SnGame.AddHero(HE);

end;
{----------------------------------------------------------------------------}
procedure ReadOB36_Grail;
begin
  x:=ReadInt2B;                   // rayon  to hide the grail randomly
  ReadPad(2);
end;
{----------------------------------------------------------------------------}
procedure ReadOB39_LeanTo;
begin
  mObj.v:=1+random(3);          // qty of res
end;
{----------------------------------------------------------------------------}
procedure ReadOB42_Phare;
begin
   ReadPad(4);                  // owner no=FF
end;
{----------------------------------------------------------------------------}
procedure ReadOB53_Mine;
begin
  mObj.pid:=ReadShortInt;
  if mObj.u = 7 then mObj.pid:=-1;
  ReadPad(3);                   // owner no=FF
  mMines[nMines].res:=mObj.u;
  mMines[nMines].pid:=mObj.pid;
  mObj.v:=nMines;
  inc(nMines);
end;
{----------------------------------------------------------------------------}
procedure ReadOB54_Monster;
var
  DF,i: integer;
  defname:string;
begin
  // ncreas next to tile xyl
  if mObj.u> 112 then      //replace by random
  begin
    DF:=948+random(110) ;
    DefName:= iDef[DF].name;
    SnGame.AddDef(DefName);
    mObj.Def:=DF;
    mObj.t:=OB54_Monster;
    mObj.u:=iDef[DF].u;
  end;

  for i:=0 to 8 do
  begin
    x:=1+mObj.pos.x-(i mod 3);
    y:=1+mObj.pos.y-(i div 3);
    l:=mObj.pos.l;
    //if mTiles[x,y,l].P1=TL_FREE then
    mTiles[x,y,l].nCreas:=mTiles[x,y,l].nCreas+1;
  end;

  mOBj.v:=nMonsters;
  with mMonsters[nMonsters] do
  begin
    if mData.ver > VER_ROE then   //identifier for a Monster list  used in Seer quest
    begin
    QuestID:=ReadPad(4);
    end;
    oid:=mObj.id;
    msg:='';
    qty:=ReadInt2B;                             // qty 0 =aléatoire
    if qty=0 then  qty:=1+random(15);
    mLog.InsertInt(iCrea[mObj.u].name ,qty);
    agressiv:=ReadShortInt;                     // comportement 0 docile 2 agressif
    custom:=(ReadBool);
    if custom then
    begin
      msg:=ReadString;
      mLog.insert('Msg ' + msg);
      for i:=0 to MAX_RES-1 do                  //treasure bonus
         res[i]:=ReadInt4B;                     //treasure bonus
      artId:=ReadIntArt;                        //artifact bonus
    end;
  end;
  ReadShortInt;                                 //neverFlees
  ReadShortInt;                                 //notGrowingTeam
  ReadPad(2);
  inc(nMonsters);
end;
{----------------------------------------------------------------------------}
procedure ReadOB59_Bottle; // botle in ocean => message
begin
  s:=ReadString;
  mLog.insertStr('Bottle Msg ',s);
  mObj.v:=mSigns.count;
  mSigns.Add(s);
  ReadPad(4);
end;
{----------------------------------------------------------------------------}
procedure ReadOB62_Prison;
begin
  mObj.pid:=-1;
  ReadOB34_Hero;
  mOBJ.t:=OB62_Prison;
end;
{----------------------------------------------------------------------------}
procedure ReadOB65_AvaRnd;
var
  DF: integer;
begin
  DefName:= format('AVA%4.4d',[8+random(100)]) ;
  DF:=iDefFind(DefName);
  SnGame.AddDef(DefName);
  mObj.Def:=DF;
  mObj.t:=OB05_Artifact;
  mObj.u:=iDef[DF].u;
  ReadOB05_Artifact;
end;
{----------------------------------------------------------------------------}
procedure ReadOB74_Monster(level:integer);
var
  DF: integer;
begin
  if level=0
  then DF:=948+random(110)
  else DF:=948+14*random(8)+2*(level-1)+random(2);
  DefName:= iDef[DF].name;
  SnGame.AddDef(DefName);
  mObj.Def:=DF;
  mObj.t:=OB54_Monster;
  mObj.u:=iDef[DF].u;
  ReadOB54_Monster;
end;
{----------------------------------------------------------------------------}
procedure ReadOB79_Res; //76 rnd ,79 ressource
begin
  mLog.Insert(iRes[mObj.u].name);
  if ReadBool then
  begin
    mObj.msg:=ReadString;
    mLog.InsertStr('Msg',mObj.msg);
    mObj.guarded:=(ReadBool);
    if mObj.guarded then mObj.Armys:=ReadArmy;
    ReadPad(4);
  end;
  mObj.v:=ReadInt2B; // qty
  ReadInt2B;
  if mObj.v = 0 then
  begin
    case mObj.u of
      RES0_Bois:        mObj.v:=(6+random(5));
      RES1_Pierre:      mObj.v:=(6+random(5));
      RES2_Mercure:     mObj.v:=(3+random(3));
      RES3_Souffre:     mObj.v:=(3+random(3));
      RES4_Gem:         mObj.v:=(3+random(3));
      RES5_Crystal:     mObj.v:=(3+random(3));
      RES6_Or:          mObj.v:=100*(5+random(6));
    end
  end;
  ReadPad(4);
end;
{----------------------------------------------------------------------------}
procedure ReadOB76_Res; //76 rnd ,79 ressource
var
  DF: integer;
begin
  DF:=936+random(9);         //AVTcrys0.def   START A 938 TODO: better detection !!!!
  if DF=940 then DF:=944;
  if DF=943 then DF:=944;
  DefName:= iDef[DF].name;
  SnGame.AddDef(DefName);
  mObj.Def:=DF;
  mObj.t:=OB79_Res;
  mObj.u:=iDef[DF].u;
  ReadOB79_Res;
end;
{----------------------------------------------------------------------------}
procedure ReadOB81_schoolar;
{TMapScholar = record   // SC 81
  t: Byte;     //type PK / SS / SP
  pk: integer; //primary skill
  ss: integer; //secondary skill
  sp: integer; //spell}
begin
  with mScholar[nScholars] do
  begin
    t:=ReadInt1B;
    if t=255 then
    begin
      t:=random(3);
      case t of
        0:  pk:=random(4);
        1:  ss:=random(MAX_SSK);
        2:  sp:=random(MAX_SPEL);
      end;
      ReadShortInt;
    end
    else
    begin
      case t of
        0:  pk:=ReadShortInt;
        1:  ss:=ReadShortInt;
        2:  sp:=ReadShortInt;
      end;
    end;
  end;
  ReadPad(6);
  mObj.v:=nScholars;
  inc(nScholars);
end;
{----------------------------------------------------------------------------}
procedure ReadOB82_SeeChest;
begin
  // 20% rien 70% 1500 or 10% 1500or+art
  case random(100) of
  0..19:  mObj.v:=0;
  20..89: mObj.v:=1;
  90..100:mObj.v:=2;
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadOB83_Seer;
var
  i,n :integer;
begin
  with mSeers[nSeers] do
  begin
    Name:=TxtSeer[83-nSeers];
    Completed:=false;
    Quest:=0;
    if mData.ver > VER_ROE then //Quest hut)
    begin

      Quest:=ReadShortInt;
      case Quest of
        1,2,3: ReadPad(4);
        //1:gain exp level , 
        //2 have pri skill, 
        //3 have defeat hero
        4: begin
         QuestID:=ReadPad(4);
         mLog.insert('Defeat a monster');
        end;
        5: begin
          // art to bring  N ART , Q1 ....
          n:=ReadShortInt;
          for i:=0 to n-1 do
          begin
            Q1:=ReadInt2B;                //artid
            if Q1 <128 then mLog.insert('Return with ART '+iArt[Q1].name);
          end;
        end;
        6: begin
          // crea to bring  N crea , Q1 ....
          n:=ReadShortInt;
          for i:=0 to n-1 do
          begin
            Q1:=ReadInt2B; //cr_type
            Q2:=ReadInt2B; //cr_numb
            if Q1<112  then mLog.insert('Return with '+inttostr(Q2) + ' of Crea: '+ iCrea[Q1].name);
          end;
        end;
        7: begin
          // res to bring
          for i:=0 to MAX_RES-1 do
          begin
            Q1:=ReadInt2B;
            Q2:=ReadInt2B;
            mLog.insert('Return with '+inttostr(Q1) + ' of Res: ' + iRes[i].name);
          end;
        end;
        // what are the last option ?? TODO
        8,9:  ReadShortInt;
      end;

      // custom string for Quest  identified
      if Quest <> 0 then 
      begin
        ReadPad(4);
        Text1:=ReadString; mLog.insert(Text1);
        Text2:=ReadString; mLog.insert(Text2);
        Text3:=ReadString; mLog.insert(Text3);
      end
      else
        ReadPad(1);
    end

    else //ROE
    begin
      Q1:=ReadInt1B;  //Q1 is artID
      if Q1=255
      then
      begin
       ReadShortInt;      // no extra....
       Completed:=true;
      end
      else
      begin
        Quest:=5;
        mLog.insert('Return with '+iArt[Q1].name);
      end;
    end;

    // if there is a Quest there may be a reward
    if Quest <> 0 then
    begin
      Reward:=ReadInt1B;
      case Reward of
        1: begin      // give exp
          R1:=ReadInt4B; //ReadInt2B;
          mLog.insert('Reward Exp ' + inttostr(R1));
          //ReadPad(2);
        end;
        2: begin      // give mana
          R1:=ReadInt2B;
          mLog.insert('Reward PtMagie ' + inttostr(R1));
          ReadPad(2);
        end;
        3: begin      // give moral
          R1:=ReadShortInt;
          mLog.insert('Reward Moral ' + inttostr(R1));
        end;
        4: begin      // give chance
          R1:=ReadShortInt;
          mLog.insert('Reward Chance ' + inttostr(R1));
        end;
        5: begin     //give res
          R1:=ReadShortInt;
          R2:=ReadInt2B;
          mLog.insert('Reward '+inttostr(R2) + ' of Res  ' + iRes[R1].name);
          ReadPad(2);
        end;
        6: begin      //give pskil
          R1:=ReadShortInt;
          R2:=ReadShortInt;
          mLog.insert('Reward '+inttostr(R2) + ' of SKL ' + inttostr(R1));
        end;
        7: begin      //give secskil
          R1:=ReadShortInt;
          R2:=ReadShortInt;
          mLog.insert('Reward '+inttostr(R2) + ' of SSKL ' + inttostr(R1));
        end;
        8: begin      //give artf
          R1:=ReadIntArt;
          mLog.insert('Reward ART '+iArt[R1].name);
        end;
        9: begin     // give spell
          R1:=ReadShortInt;
          mLog.insert('Reward Sort '+iSpel[R1].name);
        end;
        10: begin    // give crea
          R1:=ReadCreaType;
          R2:=ReadInt2B;
          if R1<112  then mLog.insert('Reward '+inttostr(R2) + ' of crea'+ iCrea[R1].name);
        end;
      end;
    end;

  end;
  ReadPad(2);
  mobj.v:=nSeers;
  inc(nSeers);
end;
{----------------------------------------------------------------------------}
procedure ReadOB84_Crypt;
var
  c,n, t,i, BK : integer;
begin
  BK:=9;
  case random(100) of
  0..29  : t:=0;
  30..59 : t:=1;
  60..89 : t:=2;
  90..99 : t:=3;
  end;
    with mBanks[nBanks] do
    begin
    for i:=0 to MAX_ARMY do  begin
      mObj.Armys[i].t:=iBank[BK,t].Armys[i].t;
      mObj.Armys[i].n:=iBank[BK,t].Armys[i].n;
    end;
    bRes:=iBank[BK,t].bRes;
    bArmy.t:=iBank[BK,t].bCR.t;
    bArmy.n:=iBank[BK,t].bCR.n;  //0 most of the time
    bTotalArts:=0;
    Take:=false;
    for i:=0 to MAX_PLAYER-1 do Visited[i]:=false;
  end;
  mObj.v:=nBanks;
  inc(nBanks);
end;
{----------------------------------------------------------------------------}
procedure ReadOB85_Shipwreck;
var
  c,n, t,i, BK : integer;
begin
  BK:=7;
  case random(100) of
  0..29  : t:=0;
  30..59 : t:=1;
  60..89 : t:=2;
  90..99 : t:=3;
  end;
    with mBanks[nBanks] do
    begin
    for i:=0 to MAX_ARMY do  begin
      mObj.Armys[i].t:=iBank[BK,t].Armys[i].t;
      mObj.Armys[i].n:=iBank[BK,t].Armys[i].n;
    end;
    bRes:=iBank[BK,t].bRes;
    bArmy.t:=iBank[BK,t].bCR.t;
    bArmy.n:=iBank[BK,t].bCR.n;  //0 most of the time
    bTotalArts:=0;
    Take:=false;
    for i:=0 to MAX_PLAYER-1 do Visited[i]:=false;
  end;
  mObj.v:=nBanks;
  inc(nBanks);
end;
{----------------------------------------------------------------------------}
procedure ReadOB86_Survivor;
begin
  case random(100) of
    0..5 : mObj.v:=90+random(30); //relique
    6..25: mObj.v:=60+random(30); //majeur
    26..45:mObj.v:=30+random(30); //mineur
    46..99:mObj.v:=7+ random(23); //trésor
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadOB87_ShipYeard;
begin
  moBj.pid:=ReadShortInt;         //pid
  ReadPad(3);                 // hero id inside
end;
{----------------------------------------------------------------------------}
procedure ReadOB88_ShrineofMagicXX;
begin
  mObj.v:=ReadShortInt;
  ReadPad(3);
end;
{----------------------------------------------------------------------------}
procedure ReadOB91_Sign;
begin
  s:=ReadString;
  mLog.insertStr('Sign Msg ',s);
  mObj.v:=mSigns.count;
  mSigns.Add(s);
  ReadPad(4);
end;
{----------------------------------------------------------------------------}
procedure ReadOB93_Scroll ;
begin
  if ReadBool then
  begin
    mObj.msg:=ReadString;
    mLog.InsertStr('Msg',mObj.msg);
    mObj.guarded:=(ReadBool);
    if mObj.guarded then mObj.Armys:=ReadArmy;
    ReadPad(4);
  end;
  mObj.v:=ReadShortInt;
    mLog.Insert('Spell' + NT + iSpel[mObj.v].name);
  ReadPad(3);
end;
{----------------------------------------------------------------------------}
procedure ReadOB98_City;
var
 CT,i,n,c :integer;
 mxspel: integer;
 val : byte;
 CustomGarnison: boolean;
begin
  CT:=nCitys;
  mObj.v:=CT;
  with mCitys[CT] do
  begin
    if mData.ver > VER_ROE then
    begin
       UID:=ReadInt2B;
       ReadPad(2);
    end;
    for i:=0 to MAX_ARMY do
      ProdArmys[i].t:=-1;
      
    visHero:=-1;
    garHero:=-1;
    mObj.pid:=ReadShortInt;
    pid:=mObj.pid;

    if pid <> -1 then       // FF no owner
    begin
      mPlayers[pid].LstCity[mPlayers[pid].nCity]:=nCitys;
      inc(mPlayers[pid].nCity);
    end;
    pos:=mObj.Pos;
    t:=mObj.u;
    if t=8 then t:=1;      //TODO:LIMIT of 8 town
    mLog.insert('pID'+NT+inttostr(mCitys[CT].pid));

    // custom name
    if ReadBool then
    begin
      name:=inttostr(nCitys)+'-'+ReadString;
      mLog.insertStr('Name' ,name);
    end
    else
      name:=TxtTownName[random(TxtTownName.count)];
    //custom garnison
    CustomGarnison:=ReadBool;
    if CustomGarnison
    then GarArmys:=ReadArmy
    else GarArmys:=START_ARMY;

    ReadShortInt; // formation

    // clear spel
    for i:=0 to MAX_SPEL-1 do Spels[I]:=0;


    //buildings
    Builds[10]:=true;
    if ReadBool
    then begin
        ReadCons(nCitys,true);
        ReadCons(nCitys,false);
    end
    else begin
      if ReadBool then Cmd_CT_BuyCons(nCitys,Cons3_Fort);  // has fortif only
      Cmd_CT_BuyCons(nCitys,Cons6_Tavern);                 // has tavern
      Cmd_CT_BuyCons(nCitys,Cons22_StdCr0);                // has gen 1
      if (random(100) > 50) then
      Cmd_CT_BuyCons(nCitys,Cons25_StdCr1);                // has gen 2   TODO should be random ?
    end;


    //spells
    mxSpel:=70;
    //mandatory spells
    for i:=0 to 8 do     //9 byte desc for spels
    begin
    val:=Readbyte;
    {for j:=0 to 7 do
      begin
        if (val and 1 = 1) and (8*i+j < mxspel) then
        begin
          //mLog.InsertStr('MandatorySpell', iSPEL[8*i+j].name);
        end;
        val:=val shr 1;
      end; }
    end;

    //potential spell to allow
    if mData.ver > VER_ROE then
    begin
      for i:=0 to 8 do     //9 byte desc for spels
      begin
      val:=Readbyte;
      {for j:=0 to 7 do
        begin
          if (val and 1 = 0) and (8*i+j < mxspel) then
          begin
            mLog.InsertStr('PossibleSpell', iSPEL[8*i+j].name);
          end;
          val:=val shr 1;
        end;  }
      end; 
    end;

    //city related events
    n:=ReadInt2B;
    ReadInt2B;
    for i:=0 to n-1 do ReadCityEvent(CT);

    if mData.ver > VER_ARB then
    align:=ReadShortInt;     //alignment to player ?

    if (mObj.T=77) or (mObj.U=8) then  //sub=8 HFORX not coded
    begin
      mObj.u:=random(7) ;
      if pid> -1
      then
      begin
        c:=mHeader.Joueurs[pid].ActiveCity;
        if c>-1 then mObj.u:=c;
      end;
      if (pid =-1) and (align> -1) then
      begin
        c:=mHeader.Joueurs[align].ActiveCity;
        if c>-1 then mObj.u:=c;
      end;
      mObj.t:=OB98_City;
      mObj.def:=mObj.def-9+mObj.u;
      SnGame.AddDef(iDef[mObj.def].name);
      t:=mObj.u;

      for i:=0 to MAX_ARMY do
      if (ProdArmys[i].t > -1) then ProdArmys[i].t:= 14*t+ (ProdArmys[i].t mod 14);

    end;
    if not(CustomGarnison) and (pid=-1) then   //only free town no pid with some crea
    begin
      GarArmys[0].n:=random(7);
      if (GarArmys[0].n > 0) then GarArmys[0].t:=14*t
    end;
    ReadPad(3);   // 2 ou 3
    hasbuild:=0;
  end;
  inc(nCitys);
end;
{----------------------------------------------------------------------------}
procedure ReadOB101_TreasureChest;
begin
  mChests[nChests].b:=0;
  case Random(100) of
    0..31:   mChests[nChests].b:=2;             // 32% 1000 or 500 exp
    32..63:  mChests[nChests].b:=3;             // 32% 1500 or 1000 exp
    64..95:  mChests[nChests].b:=4;             // 32% 2000 or 1500 exp
    else     mChests[nChests].a:=random(100);   //  5% art
  end;
  if mChests[nChests].b=0
    then mChests[nChests].t:=1
    else mChests[nChests].t:=0;
  mObj.v:=nChests;
  inc(nChests);
end;
{----------------------------------------------------------------------------}
procedure ReadOB105_Wagon;
begin
  mChests[nChests].b:=0;
  case Random(100) of
    0..10:   mObj.v:=-1;                  // 10% vide
    11..50:  mObj.v:=random(100);         // 40% art min or treseor
    else     mObj.v:=200+random(MAX_RES); // 50% res <> or
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadOB113_WitchHut;
var
  i,j :integer;
  val: byte;
begin
  if mData.ver > VER_ROE then
  begin
    for i:=0 to 3  do
    begin
      val :=Readbyte;
      for j:=0 to 7 do
      begin
        //sskil allowed...	if ((8*i+j) < 27) ) then allowedskil:=val push
        if (val and 1 = 0) and (8*i+j < MAX_SSK) then
        begin
          mLog.InsertStr('PossibleSkill', iSSK[8*i+j].name);
        end;
        val:=val shr 1;
      end;
    end;
  end
  else
  begin
    for i:=0 to 27 do
    begin
      //???
    end;
  end;

  mObj.v:=random(MAX_SSK);
end;
{----------------------------------------------------------------------------}
procedure ReadOB214_herolastCampaign;
begin
  readFilePos;
  ReadShortInt;            // apply to PL     hp->setOwner(PlayerColor(reader.readUInt8()));
  HE:=ReadInt1B ;    // specific heroe  htid = reader.readUInt8();; //hero type id
  if HE=255 then       // top hero        hp->power = reader.readUInt8();
  ReadInt1B ;
end;
{----------------------------------------------------------------------------}
procedure ReadOB215_GuardQuest;
var
  i,b,x :integer;
begin
  with mSeers[nSeers] do
  begin
    if mData.ver > VER_ROE then
    begin
    x:=ReadShortInt;
    case x of
      1,2,3,4: ReadPad(4);
      5: begin
        b:=ReadShortInt;
        for i:=0 to b-1 do
        begin
          y:=ReadInt2B; //artid
          if y <128 then mLog.insert('Apporter '+iArt[y].name);
        end;
      end;
      6: begin
        b:=ReadShortInt;
        for i:=0 to b-1 do
        begin
          ReadInt2B; //crtype
          ReadInt2B; //crnumb
        end;
      end;
      7: begin
      for i:=0 to 6 do
      begin
        ReadInt2B;
        ReadInt2B;
      end;
      end;
      8,9:  ReadShortInt;
    end;
    ReadPad(4);
    ReadString;
    ReadString;
    ReadString;
    end
    else //ROE
    begin
      x:=ReadInt1B;
      if x=255
      then ReadPad(1)
      else
      begin
        mLog.insert('Apporter '+iArt[x].name);
      end;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadOB220_ABmine;
begin
  mObj.v:=ReadByte;
  ReadPad(3);
end;                 
{----------------------------------------------------------------------------}
procedure ReadOB216_Generator;
var
  i, val, CT , CR  :integer;
begin
  mObj.pid:=ReadShortInt;
  ReadPad(3);
  mLog.insertstr('OB216 for player ', inttostr(mObj.pid));

  x:=ReadInt2B;
  y:=ReadInt2B;
  if x=0
  then val:=ReadInt2B
  else
  begin
    CT:=0;
    for i:=0 to nCitys-1 do
    begin
      if mCitys[i].uid=x then
      begin
        mLog.insertstr('similar faction as city uid', inttostr(mCitys[CT].uid));
        mLog.insertstr('reminder of type ', inttostr(mCitys[CT].t));
        CT:=i;
        break
      end;
    end;
    val:=1 shl mcitys[CT].t;
  end;

  CR:=mObj.u;

  for i:=0 to 8 do
  begin
    if (val and (1 shl i)) <> 0 then
    begin
      CR:=i*7+mObj.u;
      break; //todo random if several town is matching
    end;
  end;

  //CR:=mObj.u;
  mobj.t:=17;
  mobj.def:=158+CR;
  mobj.u:=iDef[mObj.def].u;
  mobj.v:=iCrea[2*CR].growth;
  mLog.insertstr('NEW DEF ', iDef[mObj.def].name);
  SnGame.AddDef(iDef[mObj.def].name);
end;

procedure Read_nObj;
begin
  nObjs:=ReadInt4B;
  if nObjs > MAX_OBJ
  then mLog.InsertRedStr('TooManyObject ',inttostr(nObjs))
  else mLog.InsertRedStr('NbObject ',inttostr(nObjs));
  nObjs:=min(MAX_OBJ,nObjs) ;
  GetLocalTime(SystemTime);
  mData.startObj:='['+ TimeToStr(Time)+'-'+ format('%.3d',[SystemTime.wMilliseconds])+ '] ' +NT+'Start OBJ'
  + ' DrawCount ' + inttostr(SnLoadingMap.drawcounter);
end;
{----------------------------------------------------------------------------}
procedure ReadObj;
var
  OB,X: integer;

  procedure ProgressInfo_ReadObj;
  begin
    x:=mData.loadStep;
    mData.loadStep:=5+ round(150 *OB / (nObjs-1)) div 12;
    if x<> mData.loadStep then mLog.InsertRedStr('Step ',inttostr(mData.loadStep));
    updateSplash;
  end;

begin
  mLog.EnterProc('ReadObj');
  DxMouse.id:=crWaits;
  Read_nObj;
  for OB:=0 to nObjs-1 do
  begin
    if (OB mod 25) = 0 then ProgressInfo_ReadObj;   //un splash update tous les 25 obj

    with mObj do
    begin
      pos.x:=ReadInt1B;
      pos.y:=ReadInt1B;
      pos.l:=ReadInt1B;
      DefPtr:=ReadInt4B;
      mLog.EnterProc(format('OB=%d (%d,%d,%d), DefIx=%d',[OB,pos.x,pos.y,pos.l,DefPtr]));
      if  DefPtr=0 then
      begin
        mLog.Insert('Bad Obj def');
        ReadPad(50);
        exit;
      end;
      ReadPad(5);

      DefName:=DefTxt[DefPtr];
      Def:=iDefFind(DefName);
      DefInfo:=iDef[Def];
      t:=DefInfo.t;
      u:=DefInfo.u;
      id:=OB;
      v:=0;
      guarded:=false;
      msg:='';
      pid:=-2;
      mLog.Insert(format('Adding mDef=%s main=%d sub=%d des=%s',
                 [DefInfo.Name,DefInfo.t,DefInfo.u,TxtObject[DefInfo.t]]));

      case DefInfo.t of
         4: begin mObj.v:=nArena; inc(nArena); end;
         5: ReadOB05_Artifact;
         6: ReadOB06_Pandora;
        12: ReadOB12_Campfire;
        16: ReadOB16_CreatureBank;
        17: ReadOB17_Generator;
        20: ReadOB20_Golem;
        22: ReadOB22_Corpse;
        23: begin mObj.v:=nMarletto; inc(nMarletto); end;
        24: ReadOB24_DerelictShip;
        25: ReadOB25_DragonUtopia;
        26: ReadOB26_Event;
        29: ReadOB29_FlotSam;
        32: begin mObj.v:=nGarden; inc(nGarden); end;
        33: ReadOB33_Garnison;
        34: ReadOB34_Hero;
        36: ReadOB36_Grail;
        39: ReadOB39_LeanTo;
        42: ReadOB42_Phare;
        48: mObj.v:=0;                 //magic spring not drink
        53: ReadOB53_Mine;
        54: ReadOB54_Monster;
        55: mObj.v:=random(2);         // garden not visited  50% or/50  5 gem
        57: mObj.v:=0;                 // obelisk notvisited
        59: ReadOB59_Bottle;
        61: begin mObj.v:=nAxis; inc(nAxis); end;
        62: ReadOB62_Prison;
    65..69: ReadOB65_AvaRnd;
        70: ReadOB34_Hero;
    71..75: ReadOB74_Monster(DefInfo.t-71);
        76: ReadOB76_Res;
        77: ReadOB98_City;
        79: ReadOB79_Res;
        81: ReadOB81_Schoolar;
        82: ReadOB82_SeeChest;
        83: ReadOB83_Seer;
        84: ReadOB84_Crypt;
        85: ReadOB85_Shipwreck;
        86: ReadOB86_Survivor;
        87: ReadOB87_ShipYeard;
    88..90: ReadOB88_ShrineofMagicXX;
        91: ReadOB91_Sign;
        93: ReadOB93_Scroll;
        98: ReadOB98_City;
       100: begin mObj.v:=nLearning; inc(nLearning); end;
       101: ReadOB101_TreasureChest;
       102: begin mObj.v:=nTreeofKnowledge; inc(nTreeofKnowledge); mObj.u:=random(3); end;
       103: mObj.v:=0;
       105: ReadOB105_Wagon;
       108: mObj.v:=random(100);
       112: mObj.v:=1+random(5);       // ni bois ni or
       113: ReadOB113_WitchHut;
  162..164: ReadOB74_Monster(5+DefInfo.t-162);
       206: begin mObj.pid:=-2; end;
       214: ReadOB214_HeroLastCampaign;
       215: ReadOB215_GuardQuest;
       216: ReadOB216_Generator;
       217: ReadOB216_Generator;
       218: ReadOB216_Generator;
       219: ReadOB33_Garnison;  //vertical gar
       220: ReadOB220_abmine;
       else mObj.pid:=-2;
      end;

      Cmd_Map_AddmObj;
      mLog.QuitProc('---------------------------------------------');
     end;
     mObjs[OB]:=mObj;
     mObjs[OB].Deading:=-1;
   end;
   mLog.QuitProc('ReadObj');
   GetLocalTime(SystemTime);
   mData.endObj:='['+ TimeToStr(Time)+'-'+ format('%.3d',[SystemTime.wMilliseconds])+ '] ' +NT+'End  OBJ '  + inttostr(nObjs)
   + ' DrawCount ' + inttostr(SnLoadingMap.drawcounter);
end;


{----------------------------------------------------------------------------}
procedure Cmd_Map_Load(f1: string);
begin
  Cmd_Map_ResetObjcount ;
  mData.LoadStep:=0;
  AssignFile(F, folder.map+f1);
  Reset(F, 1);
  mLog:=TLog.Create(ExtractFileName(folder.map+f1)+'.log');
  mData.fName:=f1;
  GetLocalTime(SystemTime);
  mData.startload:='['+ TimeToStr(Time)+'-'+ format('%.3d',[SystemTime.wMilliseconds])+ '] ' + NT+'Start LOAD'
  + ' DrawCount ' + inttostr(SnLoadingMap.drawcounter);
  mData.LoadStep:=0;
        mLog.InsertRedStr('Step HEADER',inttostr(0));
        mLog.InsertRedStr('Draw count',inttostr(SnLoadingMap.drawcounter));
        ReadHeader;
  mData.LoadStep:=0;
        mLog.InsertRedStr('Step TILES.',inttostr(0));
        mLog.InsertRedStr('Draw count',inttostr(SnLoadingMap.drawcounter));
        ReadTile;
  mData.LoadStep:=1;
        mLog.InsertRedStr('Step DEFOBJ',inttostr(1));
        mLog.InsertRedStr('Draw count',inttostr(SnLoadingMap.drawcounter));
        ReadDef;
  mData.LoadStep:=5;
        mLog.InsertRedStr('Step OBJECT',inttostr(5));
        mLog.InsertRedStr('Draw count',inttostr(SnLoadingMap.drawcounter));
        ReadObj;
  mData.LoadStep:=18;
        mLog.InsertRedStr('Step EVENTS',inttostr(18));
        mLog.InsertRedStr('Draw count',inttostr(SnLoadingMap.drawcounter));
        ReadEvent;
  mData.LoadStep:=19;
        mLog.InsertRedStr('Step CLOSEF',inttostr(18));
        mLog.InsertRedStr('Draw count',inttostr(SnLoadingMap.drawcounter));
        SnLoadingMap.waitcounter:=SnLoadingMap.drawcounter+1;
  CloseFile(F);

  Cmd_PL_InitHero;
  Cmd_PL_InitPlayer;

  mData.LoadStep:=19; mLog.InsertRedStr('Step ENDED',inttostr(19));
  mLog.InsertRedStr('','----------------------------------------------------');
  mLog.InsertStr('',mDATA.startload );
  mLog.InsertStr('',mDATA.starttile );
  mLog.InsertStr('',mDATA.endtile  );
  mLog.InsertStr('',mDATA.startdef );
  mLog.InsertStr('',mDATA.enddef );
  mLog.InsertStr('',mDATA.startobj );
  mLog.InsertStr('',mDATA.endobj );
  mLog.InsertRedStr('','----------------------------------------------------');
end;
{----------------------------------------------------------------------------}
procedure UpdateSplash;
begin
  Application.ProcessMessages;
  mLog.InsertBlueStr('','splash ---------------- upd');
  DxMain.DrawScreen;
end;
{----------------------------------------------------------------------------}
initialization
begin
  mSigns:=TStringList.Create;
  Actions:=TList.Create;
end;
{----------------------------------------------------------------------------}
end.


