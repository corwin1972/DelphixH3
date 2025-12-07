unit ULoad;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, UType, UFile, UHero, UCSV, StrUtils, Math;


implementation

{----------------------------------------------------------------------------}
procedure InitArtInfo;
var
  i,j:integer;
  tmp:string;
  TxtPic  : TStringList;
  TxtEvent: TStringList;
  CSV: TCSVfile;
begin
  TxtArtSlot:=LoadTxt('Artslots');
  TxtPic:=LoadTxt('Artifact');
  TxtEvent:=LoadTxt('Artevent');
  CSV:=LoadCSV('Artraits');
  CSV.ReadLine;  // titre 1
  CSV.ReadLine;  // titre 2
  for i:=0 to MAX_ART-1 do
  begin
    with iART[i] do
    begin
      CSV.ReadLine;  // artf
      id:=i;
      name:=CSV.ReadStr(0);
      for j:=0 to MAX_SLOT-1 do SlotOK[j]:= false;
      for j:=0 to MAX_SLOT-1 do
      begin
        if (CSV.ReadStr(j+2) = 'x') then SlotOK[MAX_SLOT-1-j]:=true;
      end;
      for j:=MAX_SLOT to MAX_PACK  do
      begin
        SlotOK[j]:=true;
      end;
      tmp:=CSV.ReadStr(21);
      j:=ANSIPOS('}',tmp);
      tmp:=copy(tmp,j+1,length(tmp)-j-1);
      desc:=tmp;
      event:=TxtEvent[i];
      pic:=TxtPic[i+12];
    end;
  end;
  TxtEvent.free;
  TxtPic.free;
  CSV.Free;
end;
{-----------------------------------------------------------------------------}
procedure InitSklsInfo;
var
  temp:string;
  TxtPic: TStringlist;
  SK,l,p : integer;
  CSV: TCSVfile;
begin
  TxtPic:=LoadTxt('SecSkill');
  TxtMasterName:=LoadTxt('SKILLLEV');
  CSV:=LoadCSV('Sstraits');
  CSV.ReadLine;  // titre 1
  CSV.ReadLine;  // titre 1
  for SK:=0 to MAX_SSK do
  begin
    CSV.ReadLine;  // SkillS
     with iSSK[SK] do
    begin
      id:=SK;
      name:=CSV.ReadStr(0);
      for l:=0 to 2 do
      begin
      temp:=CSV.ReadStr(l+1);
      p:=ANSIPOS('}',temp)+1;
      temp:=copy(temp,p,length(temp)-p);
      lev[l].desc:=temp;
      lev[l].Pic:=TxtPic[3*SK+l+15];
      lev[l].name:=TxtMasterName[l];
      end;
    end;
  end;
  TxtPic.free;
  CSV.Close;
  CSV.free;
end;
{-----------------------------------------------------------------------------}
procedure InitCreaInfo;
var
  PicList, TxtPicMap, TxtPicFight, TxtPicLrg, TxtPicSml, TxtBio: TStringlist;
  Path:string;
  CR,i,j: integer;
  AnimID: integer;
  CSV:TCSVfile;
{-----------------------------------------------------------------------------}
begin
  TxtPicLrg:=LoadTxt('CrLarge');
  TxtPicSml:=LoadTxt('CrSmall');
  TxtPicMap:=LoadTxt('CrMap');
  TxtPicFight:=LoadTxt('CrFight');
  TxtBio:=LoadTxt('Crbios');
  CSV:=LoadCSV('Crtraits');
  CSV.ReadLine;  // title name cost
  CSV.ReadLine;  // title singular ..att...
  PicList:=TStringlist.Create;
  //LogL.InsertStr('EndCSV', 'Crtraits');
  for CR:=0 to MAX_CREA-1 do
  begin
    CSV.ReadLine;  // Crea
    with iCREA[CR] do begin
      id:=CSV.ReadInt(0);
      align:=CSV.ReadInt(1);
      level:=CR mod 14;
      growth:=CSV.ReadInt(2);
      growH:=CSV.ReadInt(3);
      Cost:=CSV.ReadInt(4);
      flag:=CSV.ReadInt(5);

      atk:=CSV.ReadInt(6);
      def:=CSV.ReadInt(7);
      shots:=CSV.ReadInt(8);
      dmgMin:=CSV.ReadInt(9);
      dmgMax:=CSV.ReadInt(10);
      hit:=CSV.ReadInt(11);
      speed:=CSV.ReadInt(12);
      name:=CSV.ReadStr(13);

      desc:=TxtBio[CR];
      PicFight:=TxtPicFight[CR];
      PicMap:=TxtPicMap[CR];
      PicLrg:=TxtPicLrg[CR];
      PicSml:=TxtPicSml[CR];

      // Save Anim PIC in AnimList
      Path:=Folder.Sprite+ PicFight +'\';
      PicList.LoadFromFile(Path+PicFight+'.txt');
      for AnimID:=0 to 21 do  // 22 animation type cAnimXXXX
        AnimList[AnimID]:=TStringList.Create;
      AnimID:=0;
      for i:=0 to picList.count-1 do
      begin
        if ANSIPOS('LIST NUMBER',picList[i])>0
          then AnimID:=strtoint(trim(picList[i+1]));
        if ANSIPOS('.BMP',picList[i])>0
          then AnimList[AnimID].Add(Path+PicList[i]);
      end;
    end;
  end;
  TxtPicLrg.free;
  TxtPicSml.free;
  TxtPicMap.free;
  TxtPicFight.free;
  PicList.Free;
  TxtBio.free;
  CSV.Close;
  CSV.free;
end;
{-----------------------------------------------------------------------------}
procedure InitResInfo;
var
  i:integer;

  TxtResPic:  TStringList;
  TxtMinePic: TStringList;
  TxtResname: TStringList;
  TxtEvent:   TStringList;
  TxtMine:    TStringList;
begin
  TxtResname:=LoadTxt('resTypes');
  TxtResPic:=LoadTxt('res');
  Txtevent:=LoadTxt('MineEvnt');
  TxtMine:=LoadTxt('MineName');
  TxtMinePic:=LoadTxt('Mine');
  for i:=0 to MAX_RES-1 do
  begin
    with iRES[i] do
    begin
      id:=i;
      name:=TxtResName[i];
      event:=TxtEvent[i];
      //j:=ANSIPOS('}',event);
      //event:=copy(event,j+1,length(event)-j-1);  }
      mine:=Txtmine[i];
      MinePic:=TxtMinePic[i];
      ResPic:=TxtResPic[i];
    end;
  end;
  TxtResPic.free;
  TxtMinePic.Free;
  TxtResname.free;
  TxtMine.Free;
end;
{-----------------------------------------------------------------------------}
procedure InitSpellInfo;
var
  i,CT,SP: integer;
  VCBT: boolean;
  temp: string;
  TxtSpellPic,TxtSpellscrPic: Tstringlist;
  CSV:TCSVfile;
begin
  TxtSchoolName:=LoadTxt2('SchoolName');

  VCBT:=false;
  Txtspellpic:=LoadTxt('Spells');
  Txtspellscrpic:=LoadTxt('Spellscr');
  CSV:=LoadCSV('SPtraits');
  for i:=0 to 4 do
    CSV.ReadLine;  // titre 1

  for SP:=0 to MAX_SPEL do
  begin
    CSV.ReadLine;  // Spell
    with iSPEL[SP] do
    begin
      id:=SP;
      name:=CSV.ReadStr(0);
      shortname:=CSV.ReadStr(1);
      level:=CSV.ReadInt(2);
      cbt:=VCBT;
      if (CSV.ReadStr(3) = 'x') then School:=SCHOOL3_Earth;
      if (CSV.ReadStr(4) = 'x') then School:=SCHOOL2_Water;
      if (CSV.ReadStr(5) = 'x') then School:=SCHOOL0_Fire;
      if (CSV.ReadStr(6) = 'x') then School:=SCHOOL1_Air;
      bas.cost:=CSV.ReadInt(7);
      nov.cost:=CSV.ReadInt(8);
      exp.cost:=CSV.ReadInt(9);
      mas.cost:=CSV.ReadInt(10);
      pow:= CSV.ReadInt(11);
      bas.effect:=CSV.ReadInt(12);
      nov.effect:=CSV.ReadInt(13);
      exp.effect:=CSV.ReadInt(14);
      mas.effect:=CSV.ReadInt(15);

      for CT:=0 to MAX_TOWN-1 do
      rnd[CT]:=CSV.ReadInt(16+CT);

      combat:=CSV.ReadInt(28);
      adv := not ((combat and $01) = 0 );     //'ADV_SPELL':
      cbt := not ((combat and $02) = 0 );     //'COMBAT_SPELL':
      tg0 := not ((combat and $08) = 0 );     //'CREATURE_TARGET':
      tg1 := not ((combat and $10) = 0 );     //'CREATURE_TARGET_1':
      tg2 := not ((combat and $20) = 0 );     //'CREATURE_TARGET_2':
      loc := not ((combat and $40) = 0 );     //'LOCATION_TARGET':
      mnd := not ((combat and $80) = 0 );     //'MIND_SPELL':
      obs := not ((combat and $100) = 0 );    //'OBSTACLE_TARGET':

      temp:=CSV.ReadStr(29);
      bas.desc:=copy(temp,ANSIPOS('}',temp)+1,length(temp)-3);
      temp:=CSV.Readstr(30);
      nov.desc:=copy(temp,ANSIPOS('}',temp)+1,length(temp)-3);
      temp:=CSV.Readstr(31);
      exp.desc:=copy(temp,ANSIPOS('}',temp)+1,length(temp)-3);
      temp:=CSV.ReadStr(32);
      mas.desc:=copy(temp,ANSIPOS('}',temp)+1,length(temp)-3);
      bookpic:=TxtSpellPic[SP+12];
      townpic:=TxtSpellscrPic[SP+12];
      //todo try better negative/positive effect
      effect:=CSV.ReadInt(34);
      if SP=9 then begin
       CSV.ReadLine;
       CSV.ReadLine;
       CSV.ReadLine;
       VCBT:=true;//8 premier false...3 ligne vide adv/cbt
      end;
    end;
  end;
  TxtSpellPic.free;
  TxtSpellscrPic.free;
  CSV.free;
end;
{-----------------------------------------------------------------------------}
procedure InitPlayerInfo;
var
  i :integer;
const
  chrFlag: Array [0..MAX_PLAYER-1] of char = ('R','B','Y','G','O','P','T','S');
begin
  TxtPlayerColor:=loadtxt('PlColors');
  for i:=0 to MAX_PLAYER-1 do
  begin
    mPlayers[i].name:=TxtPlayerColor[i];
    mPlayers[i].initial:=chrFlag[i];
    mPlayers[i].flag:='ADOPFLG'+chrFlag[i];
  end;
end;
{-----------------------------------------------------------------------------}
procedure InitPuzzle;
var
  TnId,i,j,id,x,y:integer;
  CSV:TCSVfile;
const
  MAX_PUZZLE=48;
begin
  // init pic Town Mask Over Hall and pos
  CSV:=LoadCSV('PuzzlePos');
  for j:=0 to MAX_TOWN-1 do
  begin
    TnId:=j;
    CSV.ReadLine;
    for i:=0 to MAX_PUZZLE-1 do
    begin
      CSV.ReadLine;
      id:=i; //if Tnid=0 then id:=i else id:=CSV.ReadInt(2)-1;
      x:=CSV.ReadInt(0);
      y:=CSV.ReadInt(1);
      with iPUZZLE[TnId][id] do
      begin
        pos.X:=x;
        pos.Y:=y;
      end;
    end;
  end;
  CSV.Close;
  CSV.free;
end;
{-----------------------------------------------------------------------------}
procedure InitTownInfo;
begin
  TxtTownName:=loadtxt('TownName');
  TxtTownType:=loadtxt('TownType')
end;
{-----------------------------------------------------------------------------}
procedure InitWallInfo;
var
  w,TN: integer;
  CSV:TCSVfile;
  //s:string;
  //TxtWall: Tstringlist;
begin
  //TxtWall:=LoadTxt('Walls');
  CSV:=LoadCSV('WallsInfo');
  CSV.ReadLine;
  for TN:=0 to MAX_TOWN-1 do
  begin
    CSV.ReadLine;
    for w:=0 to 14 do
    begin
      CSV.ReadLine;
      iWall[TN][w].des:=CSV.ReadSTR(0);
      iWall[TN][w].pos.X:=CSV.ReadInt(2);
      iWall[TN][w].pos.Y:=CSV.ReadInt(4);
    end;
  end;
  CSV.Close;
  CSV.free;
end;
{-----------------------------------------------------------------------------}
procedure InitBuildInfo;
var
  i:integer;
  s:string;
  TxtPicHall,TxtDesc: Tstringlist;
  CSV:TCSVfile;
const
  TnPaths: array [0..MAX_TOWN-1] of string =
    ('cstl','ramp','towr','infr','Necr','DUNG','STRN','fort');

procedure InitBuPic;
var
  TN,BU:integer;
begin
  for TN:=0 to MAX_TOWN-1 do
  begin
    TxtPicHall:=LoadTxt('Hall'+TnPaths[TN]);
    CSV:=LoadCSV('BuPos'+TnPaths[TN]);
    for BU:=0 to MAX_BUILD-1 do
    with iBUILD[TN][BU] do
    begin
      id:=BU;
      //if ((i<=26) or (i>29)) then CSV.ReadLine; //pb interne sur pos manque 3 build
      CSV.ReadLine;
      pos.X:=CSV.ReadInt(2);
      pos.Y:=CSV.ReadInt(3);
      PicHall:=TxtPicHall[BU+12];
    end;
    CSV.Close;
    CSV.free;
  end;
end;
{-----------------------------------------------------------------------------}
procedure InitBuSpec;      // SPEC // buid=17 to 27
var
  TN,BU,i,r:integer;
begin
  TxtDesc:=LoadTxt('BldgSpec');
  for TN:=0 to MAX_TOWN-1 do
  begin
    CSV.ReadLine;  // titre 1
    for i:=0 to MAX_SPEC-1 do
    begin
      BU:=MAX_NEUT+i;
      if BU=27 then BU:=15;
      with iBUILD[TN][BU] do
      begin
        name:='spec-' + inttostr(i);
        desc:='legende';
        s:=TxtDesc[i+MAX_SPEC*TN];
        name:=Copy(s,1,AnsiPos(chr(9),s)-1);
        desc:=Copy(s,AnsiPos(chr(9),s)+1,length(s));
        if ((BU=26) or (BU=15)) then continue;
        CSV.ReadLine;
        for r:=0 to 6 do resnec[r]:=CSV.ReadInt(r);
        basic:= CSV.ReadStr(7);
      end;
    end;
    CSV.ReadLine;
  end;
  TxtDesc.free;
end;
{-----------------------------------------------------------------------------}
procedure InitBuNeut;     // NEUT // buid=0 to 16 => 17
var
  TN,BU,r:integer;
begin
  CSV.ReadLine;
  CSV.ReadLine;
  TxtDesc:=LoadTxt('BldgNeut');

  for BU:=0 to MAX_NEUT-1 do
  begin
    CSV.ReadLine;
    for TN:=0 to MAX_TOWN-1 do
    begin
      with iBUILD[TN][BU] do
      begin
        for r:=0 to 6 do resnec[r]:=CSV.ReadInt(r);
        if BU=15 then continue;
        basic:= CSV.ReadStr(7);
        s:=TxtDesc[BU];
        if BU=16 then s:=TxtDesc[16+3+TN];
        name:=Copy(s,1,AnsiPos(chr(9),s)-1);
        desc:=Copy(s,AnsiPos(chr(9),s)+1,length(s));
      end;
    end;
  end;
  CSV.ReadLine;
  TxtDesc.free;
end;
{-----------------------------------------------------------------------------}
procedure InitBuDwell;
var
  TN,BU,i,r:integer;
begin
  CSV.ReadLine;
  CSV.ReadLine;
  TxtDesc:=LoadTxt('Dwelling');

  for TN:=0 to MAX_TOWN-1 do
  begin
    CSV.ReadLine;  // titre 1
    for i:=0 to MAX_DWELL-1 do
    begin
      BU:=30+i;
      with iBUILD[TN][BU] do
      begin
        CSV.ReadLine;
        for r:=0 to 6 do resnec[r]:=CSV.ReadInt(r);
        basic:= CSV.ReadStr(7);
        s:=TxtDesc[i+MAX_DWELL*TN];
        name:=Copy(s,1,AnsiPos(chr(9),s)-1);
        desc:=Copy(s,AnsiPos(chr(9),s)+1,length(s));
      end;
    end;
    CSV.ReadLine; //space
  end;
  TxtDesc.free;
end;

begin
  InitBuPic;
  CSV:=LoadCSV('Building');
  for i:=0 to 2 do CSV.ReadLine; // header

  InitBuSpec;
  InitBuNeut;
  InitBuDwell;
  CSV.close;
  CSV.free;
  TxtPicHall.free;
end;
{-----------------------------------------------------------------------------}
procedure InitConsInfo;
var
  i:integer;
  s:string;
begin
  for i:=0 to 40 do
  begin
    case i of
      0: s:='Town Hall';
      1: s:='City Hall' ;
      2: s:='Capitol' ;
      3: s:='Fort' ;
      4: s:='Citadel';
      5: s:='Castle';
      6: s:='Tavern';
      7: s:='Blacksmith';
      8: s:='Marketplace';
      9: s:='Resource Silo';
      10:s:='NOT USED';
      11:s:='Mage Guild level 1';
      12:s:='Mage Guild level 2';
      13:s:='Mage Guild level 3';
      14:s:='Mage Guild level 4';
      15:s:='NOT USED';
      16:s:='Shipyard';
      17:s:='Colossus';
      18:s:='Lighthouse';
      19:s:='Brotherhood of the Sword';
      20:s:='Stables';
      21:s:='NOT USED';
      22:s:='Guardhouse';
      23:s:='Upg. Guardhouse';
      24:s:='NOT USED';
      25:s:='Archers Tower';
      26:s:='Upg. Archers Tower';
      27:s:='NOT USED';
      28:s:='Griffin Tower';
      29:s:='Upg. Griffin Tower';
      30:s:='Griffin Bastion';
      31:s:='Barracks';
      32:s:='Upg. Barracks';
      33:s:='NOT USED';
      34:s:='Monastery';
      35:s:='pg. Monastery';
      36:s:='NOT USED';
      37:s:='Training Grounds';
      38:s:='Upg. Training Grounds';
      39:s:='Portal of Glory';
      40:s:='Upg. Portal of Glory';
    end;
    iCONS[i].name:=s;
  end;
end;
{-----------------------------------------------------------------------------}
procedure InitText;
begin
  TxtTCommand:=LoadTxt('TCommand');
  TxtHeroName:=LoadTxt('Heronames'); //*
  TxtARRAYTXT:=LoadTxt2('ARRAYTXT');
  TxtCastInfo:=LoadTxt('CastInfo');
  TxtTownType:=LoadTxt('Towntype');
  TxtAdvEvent:=LoadTxt2('Advevent');
  TxtCRGEN1:=LoadTxt('CRGEN1');
  TxtOVERVIEW:=LoadTxt('OVERVIEW');
  TxtPRISKILL:=LoadTxt('PRISKILL');
  TxtHelp:=LoadTxt2('Help');
  TxtVCDesc:=LoadTxt('VCDesc');
  TxtLCDesc:=LoadTxt('LCDesc');
  TxtSeer:=LoadTxt('SEERHUT');
  TxtGenrlTxt:=LoadTxt2('GenrlTxt');
  TxtRANDTVRN:=LoadTxt2('RANDTVRN');
end;
{-----------------------------------------------------------------------------}
procedure InitBankInfo;
var
  CSV:TCSVfile;
  BK, i,k, CR, nCR: integer;
const
  crIds: array [0..11,0..4] of integer =
    ((94,0,0,0,0),
      (16,0,0,0,0),
      ( 4,0,0,0,13),
      (42,0,0,0,0),
      (76,0,0,0,0),
      (38,0,0,0,0),
      (104,0,0,0,0),
      (60,0,0,0,0),
      (52,0,0,0,0),
      (56,57,58,59,0),
      (26,82,27,83,0),
      (27,41,55,69,0));
begin
  CSV:=LoadCSV('CrBanks');
  CSV.ReadLine;
  CSV.ReadLine;
  for BK:=0 to MAX_BANK-1 do
     for i:=0 to 3 do
       with  iBank[BK,i] do
       begin
         CSV.ReadLine;
         name:=CSV.ReadStr(0);
         Armys[0].t:=crids[BK,0];
         Armys[0].n:=CSV.ReadInt(3);
         for k:=1 to 3 do
         begin
           Armys[k].t:=crids[BK,k];
           Armys[k].n:=CSV.ReadInt(4+2*k);
         end;
         CR:=Armys[0].t;
         nCR:=Armys[0].n;
         if Armys[1].n=0  then
         begin
         for k:=0 to 4  do
         begin
           Armys[k].t:=CR;
           Armys[k].n:=nCR div 5;
         end;
         end
         else
         begin
           Armys[0].t:=CR;
           Armys[0].n:=nCR div 2;
           Armys[4].t:=CR;
           Armys[4].n:=nCR div 2;
         end;
         Armys[5].t:=-1;
         Armys[6].t:=-1;
         for k:=0 to MAX_RES-1 do
           bRes[k]:=CSV.ReadInt(13+k);
         bCR.t:=crids[BK,4];            //TODO....angel ok but wyvern
         bCR.n:=CSV.ReadInt(20);
         bArt1:=CSV.ReadInt(22);        // kind of ART relic , major, minor
         bArt2:=CSV.ReadInt(23);
         bArt3:=CSV.ReadInt(24);
         bArt4:=CSV.ReadInt(25);
       end;
end;

{-----------------------------------------------------------------------------}
procedure InitShootInfo;
var
  CR,i,j: integer;
  DEF: string;
  CSV,CSV2:TCSVfile;
{-----------------------------------------------------------------------------}
begin
  CSV:=LoadCSV('Cr_shots');
  CSV.ReadLine;  // title   unit_ID def_name spin_projectile
  i:=0;
  repeat
  begin
    CSV.ReadLine;
    CR:=CSV.ReadInt(0);
    if (CR<> -1) and (CR < 123) then
    begin
      DEF:=CSV.ReadStr(1);
      iCREA[CR].ShotDEFID:=i;
      iCREA[CR].ShotDEF:=LeftStr(DEF,ANSIPOS('.DEF',DEF)-1);
      iCREA[CR].ShotSPIN:=(CSV.ReadInt(2) = 1);
      inc(i);
    end;
  end
  until CR=-1;
  CSV.Close;
  CSV.free;

  CSV2:=LoadCSV('CrAnim');
  CSV2.ReadLine;  // title
  CSV2.ReadLine;  // title
  for i:=0 to 7 do begin
    for j:=0 to 13 do begin
      CR:=14*i+j;
      CSV2.ReadLine;
      iCREA[CR].ShotStart:=CSV2.ReadInt(23);
      iCREA[CR].ShotUX:=CSV2.ReadInt(4);
      iCREA[CR].ShotUY:=CSV2.ReadInt(5);
      iCREA[CR].ShotRX:=CSV2.ReadInt(6);
      iCREA[CR].ShotRY:=CSV2.ReadInt(7);
      iCREA[CR].ShotDX:=CSV2.ReadInt(8);
      iCREA[CR].ShotDY:=CSV2.ReadInt(9);
    end;
    CSV2.ReadLine;  // title
    CSV2.ReadLine;  // title
    CSV2.ReadLine;  // title
  end;
  for i:=0 to 8 do begin
    CSV2.ReadLine;  // title
  end;
  for i:=0 to 3 do begin
    CR:=118+i;
    CSV2.ReadLine;
    iCREA[CR].ShotStart:=CSV2.ReadInt(23);
      iCREA[CR].ShotUX:=CSV2.ReadInt(4);
      iCREA[CR].ShotUY:=CSV2.ReadInt(5);
      iCREA[CR].ShotRX:=CSV2.ReadInt(6);
      iCREA[CR].ShotRY:=CSV2.ReadInt(7);
      iCREA[CR].ShotDX:=CSV2.ReadInt(8);
      iCREA[CR].ShotDY:=CSV2.ReadInt(9);
  end;
end;
{-----------------------------------------------------------------------------}
procedure InitEffectInfo;
var
  EF,i,n: integer;
  DEF: string;
  CSV:TCSVfile;
{-----------------------------------------------------------------------------}
begin
  CSV:=LoadCSV('AC_desc');
  CSV.ReadLine;  // title   unit_ID def_name spin_projectile
  repeat
  begin
    CSV.ReadLine;
    EF:=CSV.ReadInt(0);
    if (EF<> -1)  then
    begin
      n:=CSV.ReadInt(1);
      iEFFECT[EF].n:=n;
      for i:=0 to n-1 do
      begin
      DEF:=CSV.ReadStr(i+2);
      iEFFECT[EF].DEFS[i]:=LeftStr(DEF,ANSIPOS('.DEF',DEF)-1);
      end;
    end;
  end
  until EF=-1;
  CSV.Close;
  CSV.free;
  iEFFECT[37].n:=1 ;
  iEFFECT[37].DEFS[0]:='C0CHAIN'
end;
{-----------------------------------------------------------------------------}
initialization
begin
  //SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED);
  InitPuzzle;
  InitText;
  InitArtInfo;
  InitSklsInfo;
  InitCreaInfo;
  InitShootInfo;
  InitResInfo;
  InitSpellInfo;
  InitEffectInfo;
  InitPlayerInfo;
  InitTownInfo;
  InitBuildInfo;
  InitConsInfo;
  InitWallInfo;
  InitBankInfo;
  InitHeroCar;     //  att, def
  InitHeroTraits;  // first creature
  InitHerobios;
end;


end.
