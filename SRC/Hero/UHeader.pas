unit UHeader;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DXSounds, DXSprite, DXDraws, DXClass, DXWScene, DXWLoad, StdCtrls,
  DXPlay, UType, UFile;

  procedure LoadHeader(filename:string);

implementation

uses
  UConst;

{----------------------------------------------------------------------------}
procedure LoadHeader(filename:string);
var
  F : file;
  ReadN: Integer;
  Buf:      array[1..4] of Byte;
  BufChar:  array[1..1024] of Char;
  l,HE : integer;
  x,y,z: integer;
  a,b:  shortint;
  s:string;


{----------------------------------------------------------------------------}
function ReadByte:Shortint;
begin
  //BlockRead(F, result, 1, ReadN);
  BlockRead(F, Buf, 1,ReadN);
  result:=ShortInt(Buf[1]);
  //LogP.InsertInt('ReadByte=',result);
end;
{----------------------------------------------------------------------------}
function ReadIntByte:integer;
begin
  //BlockRead(F, result, 1, ReadN);
  BlockRead(F, Buf, 1,ReadN);
  result:=Integer(Buf[1]);
  //LogP.InsertInt('ReadIntByte=',result);
end;
{----------------------------------------------------------------------------}
function ReadInt:integer;
begin
  //BlockRead(F, result, 2, ReadN);
  BlockRead(F, Buf, 1,ReadN);
  result:=Integer(Buf[1]);
  BlockRead(F, Buf, 1,ReadN);
  result:=result+256*Buf[1];
  //LogP.InsertInt('ReadInt=',result);
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
procedure ReadPad(pad:integer);
begin
  BlockRead(F, BufChar, pad, ReadN);
  //LogP.InsertStr(copy(string(BufChar),0,Pad),'Padding');
end;
{----------------------------------------------------------------------------}
function ReadString: string;
var
  l: integer;
begin
  //BlockRead(F, l, 4, ReadN);
  l:=ReadInt4B;
  if l>0 then
  begin
    BlockRead(F, BufChar, l, ReadN);
    result:=copy(string(BufChar),1,l);
  end
  else
    result:='';
end;
{----------------------------------------------------------------------------}
procedure ReadVic;
const
  VICartifact=0;
  VICgatherTroop=1;
  VICgatherResource=2;
  VICbuildCity=3;
  VICbuildGrail=4;
  VICbeatHero=5;
  VICcaptureCity=6;
  VICbeatMonster=7;
  VICtakeDwellings=8;
  VICtakeMines=9;
  VICtransportItem=10;
  VICwinStandard=-1;
begin
  ////LogP.enterProc('ReadVic');
 with mHeader do begin
    VicID:=ReadByte;
    if VicID = VICwinStandard
    then vic:=txtVCDESC[0]
    else
    begin
      b:=ReadByte;                 //normal vic en plus
      //LogP.InsertInt('VicNormal',b);
      b:=ReadByte;                 ///appply to cpu ?
      //LogP.InsertInt('VicCPU',b);
      case VicID of
        VICartifact: begin
          x:=ReadByte;
          vic:=format(txtVCDESC[1]+NT+' %d',[x]);
        end;

        VICgatherTroop :begin
          x:=ReadIntByte;
          if ver<> ver_ROE then   ReadPad(1);
          y:=ReadInt;
          if x > 116 then x:=1;
          vic:=format(txtVCDESC[2]+NT+' %d of %s',[y,iCrea[x].name]);
          ReadInt;     // maybe more
        end;

        VICgatherResource:begin
          x:=ReadByte;
          y:=ReadInt;
          vic:=format(txtVCDESC[3]+NT+' %d of %s',[y,iRes[x].name]);
          ReadInt;  // maybe more
        end;

        VICbuildCity:begin
          x:=ReadIntByte;
          y:=ReadIntByte;
          z:=ReadIntByte;
          a:=ReadByte;
          b:=ReadByte;
          vic:=format(txtVCDESC[4]+NT+' %d, %d, %d a citylevel %d  and fortlevel %d ',[x,y,z,a,b]);
        end;

        VICbuildGrail: begin
          x:=ReadIntByte;
          y:=ReadIntByte;
          z:=ReadIntByte;
          if z>2 then //LogP.Insert('BuildGrail anywhere')
          else
          vic:=format(txtVCDESC[5]+NT+' at %d, %d, %d',[x,y,z]);
        end;

        VICbeatHero: begin
          x:=ReadIntByte;
          y:=ReadIntByte;
          z:=ReadIntByte;
          vic:=format(txtVCDESC[6]+' at %d, %d, %d',[x,y,z]);
        end;

        VICcaptureCity: begin
          x:=ReadIntByte;
          y:=ReadIntByte;
          z:=ReadIntByte;
          vic:=format(txtVCDESC[7]+' at %d, %d, %d',[x,y,z]);
        end;

        VICbeatMonster: begin
          x:=ReadIntByte;
          y:=ReadIntByte;
          z:=ReadIntByte;
          vic:=format(txtVCDESC[8]+NT+' %d, %d, %d',[x,y,z]);
        end;

        VICtakeDwellings:begin
          vic:=txtVCDESC[9];
        end;

        VICtakeMines:begin
          vic:=txtVCDESC[10];
        end;

        VICtransportItem: begin
          a:=ReadByte;
          if (a < 0)  then a:=10;
          x:=ReadIntByte;
          y:=ReadIntByte;
          z:=ReadIntByte;
          vic:= format(txtVCDESC[11]+NT+'%s to this town '+NT+' %d, %d, %d',[iART[a].name,x,y,z]);
        end
        else
        begin
          vic:=txtVCDESC[VicID];
        end;
      end;
    end;
  //LogP.Insert('Vic' + NT + vic);
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadLos;
const
  LOSCastle=0;
  LOSHero=1;
  LOSTimeExpires=2;
  LOSStandard=-1;
begin
  with mHeader do begin
    losid:=ReadByte;
    case losid of
      LOSStandard: los:=txtLCDESC[0];
      LOSCastle:  begin
        x:=ReadIntByte;
        y:=ReadIntByte;
        l:=ReadIntByte;
        los:=txtLCDESC[1] + format(' at [%d %d %d]',[x,y,l]); ;
      end;
      LOSHero: begin
        x:=ReadByte;
        y:=ReadByte;
        l:=ReadByte;
        los:=txtLCDESC[2] + format(' at [%d %d %d]',[x,y,l]); ;
      end;
      LOStimeExpires: begin
        x:=ReadInt;
        los:=txtLCDESC[3] + format('%d]',[x]);
      end
      else
      begin
        ReadByte;
        ReadByte;
       los:=txtLCDESC[a];
     end;
   end;
   //LogP.Insert('Los' + NT + los);
   end;
end;
{----------------------------------------------------------------------------}
procedure ReadTeam;
var
  i,t:integer;
  hasTeam : byte;
begin
  with mHeader do begin
    //nTeams:=0; for i:=0 to MAX_PLAYER-1 do mHeader.Joueurs[i].team:=i;
    nTeams:=ReadByte;
    if (nTeams > 0) then
    begin
      ////LogP.Insert('Team customisation');
      for i:=0 to MAX_PLAYER-1 do mHeader.Joueurs[i].team:=ReadByte;
    end
    else
    begin
      t:=0;
      for i:=0 to MAX_PLAYER-1 do
      if mHeader.Joueurs[i].isalive then
      begin
        mHeader.Joueurs[i].team:=t;
        inc(t);
        inc(nTeams);
      end;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure ReadPlayer;
var
  i,j,n:integer;
begin
  //LogP.Insert('Reading Player');
  with mHeader do
    for i:=0 to MAX_PLAYER-1 do
    with Joueurs[i] do
    begin
      Bonus:=10; // random bonus
      // Handle Player name / human CPU
      //LogP.InsertStr('Players name ', PL_COLOR[i]);
      a:=ReadByte;
      isHuman:=(a=1);
      //LogP.InsertInt('IsHuman',a);                        // 01 human flag
      a:=ReadByte;
      isCPU:=(a=1);
      //LogP.InsertInt('IsCPU  ',a);                        // 01 CPU flag

      // Discard this unused Player
      if not((isCPU) or (isHuman))
      then begin
        isAlive:=false;
        case ver of                                       // do some padding
          VER_ROE: ReadPad(6);
          VER_ARB: Readpad(12);
          VER_SOD: Readpad(13);
        end
      end
      // Handle used player
      else begin
        isAlive:=true;
        inc(nPlr);
        Attitude:=ReadByte;
        //LogP.InsertInt('Atitud',attitude);                // 00 aleatoire
        case ver of
          VER_SOD: Readpad(1);                            //p7
        end ;

        // Player Faction and Town
        faction:=ReadIntByte;
        if ver <> VER_ROE then faction:=faction+256*ReadIntByte; // to have the ninth town
        //LogP.Insert('Faction'+NT+inttostr(faction));             // 20 own towns xyz 0010 0000  bit5 dungeon

        a:=ReadByte;
        isRndFaction:=(a=1);
        //LogP.Insert('isRndFaction'+NT+inttostr(a));              // 00 own random town

        a:=ReadByte;
        hasMainCT:=(a=1);
        //LogP.Insert('MainCT?'+NT+inttostr(a));
        ActiveCity:=-1;
        //for i:=0 to 8

        if hasMainCT then
        begin                                             // 01 ville principal
          if ver <> VER_ROE then
          begin
            hasNewHeroCT:=(ReadByte=1);                    //generateHeroAtMainTown
            ReadByte;                                     //generateHero
          end
          else
            hasNewHeroCT:=true;
          posCT.x:=ReadIntByte;                            // x1E y03 z00 main town pos
          posCT.y:=ReadIntByte;
          posCT.l:=ReadIntByte;
          //LogP.Insert(format('PosCT'+NT+'%d, %d, %d',[poscity.x,poscity.y,poscity.l]));
        end;

        // Default Hero
        a:=ReadByte;                                      //p8
        //LogP.Insert('MainHE?'+NT+inttostr(a));
        HE:=ReadIntByte;                                  //p9
        //LogP.Insert('Hero'+NT+inttostr(HE));


        if HE <> 255
        then  begin
          if HE > 127
          then HE:=1; //TODO improve set HE when above 127 HE
          ActiveHero:=HE;
          mHeros[HE].used:=true;                          // Hero aleatoire
          //LogP.Insert('NameDef'+NT+TxtHeroNames[HE]);     // mHeros[HE].name
          a:=ReadByte;                                    // custom portrait
          ActiveHeroName:=ReadString;                     // custom name
          if ActiveHeroName <> '' then mHeros[HE].name:=ActiveHeroName;
          //LogP.Insert('NameNew'+NT+ ActiveHeroName);
        end
        else
          ActiveHero:=-1;

        if ver <> VER_ROE then
        begin
          ReadByte;
          n:=ReadByte;                                    // heroCount
          ReadPad(3);
          for j:=0 to n-1 do
          begin
            HE:=ReadIntByte;
            if HE > 127
            then HE:=0; //TODO improve set HE when above 127 HE
            mHeros[HE].used:=true;                         // Hero aleatoire
            //LogP.Insert('NameDef'+NT+TxtHeroNames[HE]);    // mHeros[HE].name
            s:=ReadString;
            //LogP.Insert('Name'+NT+ s);
            if s<> '' then mHeros[HE].name:=s;
         end;
      end;
    end;
    // enf of alive player handling
    //LogP.Insert('------------------------------------');
  end;
end;

{----------------------------------------------------------------------------}
procedure ReadAllowedHero;
var
  i,j,n: integer;
  val: byte;
  mxhero: integer;
begin
  //LogP.Insert('Mark hero used 16 or 20 byte');
  if mHeader.ver = VER_ROE
  then mxhero:=16 else mxhero:=20;
  //mark used hero
  for i:=0 to mxhero-1 do
  begin
    val:=ReadIntByte;
    for j:=0 to 7 do
    begin
      if (8*i+j < 128) then
      begin
        if (val and 1 = 0) then
          mHeros[8*i+j].used:=true  //LogP.InsertStr('Used Hero', mHeros[8*i+j].name);
        else
          mHeros[8*i+j].used:=false;
      end;
      val:=val shr 1;
    end;
  end;

  if mHeader.ver > VER_ROE then readpad(4);

  // Hero customised SOD version minimun
  if mHeader.ver >= VER_SOD then
  begin
    n:=readbyte;
    for i:=0 to n-1 do
    begin
      readbyte;    //id
      readbyte;    //custom portrait
      readstring;  //custom name
      readbyte;    //owner ?
    end;
  end;
  ReadPad(31);
end;
{----------------------------------------------------------------------------}
begin
  AssignFile(F, folder.map+FileName);
  Reset(F, 1);	{ Record size = 1 }
  with mHeader do begin
    fName:=FileName;                   //LogP.Insert(FileName);
    nPlr:=0;
    vic:='';
    los:='';


    ver:=ReadByte;                     //LogP.InsertInt('VER...',ver);
    ReadPad(4);                        //x0001 x=version et 1=heroOnMap

    dim:=ReadInt;                      //LogP.InsertInt('DIM...',dim);
    ReadPad(2);

    level:=ReadByte;                   //LogP.InsertInt('LEVEL.',level);

    name:=ReadString;                  //LogP.InsertStr('NAME..',name);

    des:=ReadString;                   //LogP.InsertStr('DES...',des);
    dfc:=ReadByte;                     //LogP.InsertInt('DFC...',dfc);


    if(ver <> VER_ROE)
    then readByte;                     //levelLimit := hero level limit else levelLimit := 0


    for x:=0 to 127 do
      mHeros[x].name:=mHeros[x].defaultName;

    if ver <= VER_SOD  then //not a wog map
    begin
      ReadPlayer;
      ReadVic;
      ReadLos;
      ReadTeam;
      ReadAllowedHero;
    end;
  end;
  CloseFile(F);
end;


end.
