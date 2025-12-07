unit UHero;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, UType,UFile, UCSV;

  procedure  InitHeroTraits;
  procedure  InitHeroBios;   
  procedure InitHeroCar;
  
implementation

uses
  UHE;
{-----------------------------------------------------------------------------}
procedure  InitHeroTraits;
var
  he, i,j,t,AR: integer;
  a,b: integer;
  base,rand: integer;
  CSV:TCSVFile;
begin
  randomize;
  CSV:=LoadCSV('Hotraits');
  CSV.ReadLine;  // titre 1
  CSV.ReadLine;  // titre 2

  with mHeros[-1] do
  begin
    name:='UnknowHero';
    for j:=0 to MAX_SSK do
     SSK[j]:=0;
    for j:=0 to MAX_PACK do
     Arts[j]:=-1;
    PSKB.att:=0;
    PSKB.def:=0;
    PSKB.pow:=0;
    PSKB.kno:=0;
    PSKB.ptm:=0;
    Luck:=0;
    Moral:=0;
  end;

  for HE:=0 to MAX_HERO-1 do
  with mHeros[HE] do
  begin
    PID:=-1;
    for j:=0 to MAX_SSK do  SSK[j]:=0;
    for j:=0 to MAX_PACK do Arts[j]:=-1;

    CSV.ReadLine;
    defaultName:=CSV.ReadStr(0);
    name:=defaultName;
    for j:=0 to 2 do
    begin
      t:=CSV.ReadInt(10+j);
      if t=128 then   // equippe of ammo
      begin
        case (HE div 16) of
        0:  AR:=4;  //balliste
        1:  AR:=6;  //dispensaire
        2:  AR:=5;  //chariot
        3:  AR:=6;  //dispensaire
        4:  AR:=4;  //balliste
        5:  AR:=4;  //balliste
        6:  AR:=4;  //balliste
        7:  AR:=6;  //dispensaire
        end;
        Cmd_HE_SetART(HE,AR);
        Armys[j].t:=-1;
        Armys[j].n:=0;
      end
      else
      begin
        Armys[j].t:=t;
        base:=CSV.ReadInt(1+3*j);
        rand:=random(CSV.ReadInt(2+3*j)-base);
        Armys[j].n:=base+rand;
      end;
    end;
    for j:=3 to MAX_ARMY do
    begin
      Armys[j].t:=-1;
      Armys[j].n:=0;
    end;
    nArmy:=3;
    cmd_HE_compactArmy(HE);
  end;
  CSV.Close;
  CSV.free;


  CSV:=LoadCSV('HOTRAITS_SKILLVCMI');
  //21 2 1 1 22 1
  CSV.Separator:=spSpace;
  CSV.ReadLine;  // titre 1
  //CSV.ReadLine;  // titre 2

  for HE:=0 to MAX_HERO-1 do
  with mHeros[HE] do
    begin
    CSV.ReadLine;
    a:=CSV.ReadInt(2);
    b:=CSV.ReadInt(3);
    for j:=0 to b-1 do Cmd_HE_AddSSK(HE,a);
    if  CSV.ReadInt(1)=2 then begin
    a:=CSV.ReadInt(4);
    b:=CSV.ReadInt(5);
    for j:=0 to b-1 do Cmd_HE_AddSSK(HE,a);
    end;
  end;

  CSV:=LoadCSV('Herospec2');
  ///$1=0 Secondary skills    $1=1 Creatures   $1=2 Resources  $1=3 Spells
  //CSV.Separator:=spSpace;
  CSV.ReadLine;  // titre 1
  CSV.ReadLine;  // titre 2
  mHeros[-1].specSK:=-1;

  for he:=0 to MAX_HERO-1 do
  with mHeros[HE] do
  begin
    CSV.ReadLine;
    mHeros[HE].specSK:=CSV.ReadInt(0);
    mHeros[HE].specSKP:=CSV.ReadInt(1);

    // add a book for magician and a catapult for all
    if Cmd_HE_isMagician(HE) and (Cmd_HE_FindART(HE,AR000_Spellbook) = 0)
    then Cmd_HE_SetART(HE,AR000_Spellbook);

    IF mHeros[HE].specSK = SS03_Spells then
       mHeros[HE].Spels[mHeros[HE].specSKP] := true;

    Cmd_HE_SetART(HE,AR003_Catapult);
  end;
end;

{-----------------------------------------------------------------------------}
procedure InitHeroCar;   //  att, def
var
  i,j,k: integer;
  CSV:TCSVfile;
const
  classeDir: array[0..15] of string = ('kn','cl','rn','dr','al','wz','hr','dm','dk','nc','ov','wl','br','bm','bs','wh');
begin
  randomize;
  CSV:=LoadCSV('Hctraits');
  CSV.ReadLine;  // titre 1
  CSV.ReadLine;  // titre 2
  for i:=0 to MAX_CLASSE-1 do
  begin
  with iHero[i] do
    begin
      CSV.ReadLine;
      Name:=CSV.ReadStr(0);
      //Agressiveness
      k:=2;
      Ext:=classedir[i];
      for j:=0 to 3 do
      PSK_Init[j]:=CSV.ReadInt(j+k);
      k:=k+4;
      PSK_Gain_LL[0]:=CSV.ReadInt(k);
      for j:=1 to 3 do
      PSK_Gain_LL[j]:=CSV.ReadInt(j+k)+ PSK_Gain_LL[j-1];
      k:=k+4;
      PSK_Gain_HL[0]:=CSV.ReadInt(k);
      for j:=1 to 3 do
      PSK_Gain_HL[j]:=CSV.ReadInt(j+k)+ PSK_Gain_HL[j-1];
      k:=k+4;
      SSK_Gain[0]:=CSV.ReadInt(k);
      for j:=1 to MAX_SSK do
      SSK_Gain[j]:=CSV.ReadInt(j+k)+ SSK_Gain[j-1];
      k:=k+27;
      Town[0]:=CSV.ReadInt(k);
      for j:=1 to 7 do
      Town[j]:=CSV.ReadInt(j+k)+Town[j-1];
    end;
  end;
  CSV.Close;
  CSV.free;

  for i:=0 to MAX_HERO-1 do
  with mHeros[i] do
    begin
      classeId:=i div 8;
      classeName:=iHero[classeId].name;
      id:=i;
      vision:=8;
      obX.t:=0;
      obX.oid:=0;
      level:=1;
      exp:=70;
      visTown:=-1;
      //SmlPic:='hps'+format('%.3d',[i])+classeDir[classeId]+'.bmp';
      //LrgPic:='hpl'+format('%.3d',[i])+classeDir[classeId]+'.bmp';
      PSKB.att:=iHero[classeId].PSK_Init[0];
      PSKB.def:=iHero[classeId].PSK_Init[1];
      PSKB.pow:=iHero[classeId].PSK_Init[2];
      PSKB.kno:=iHero[classeId].PSK_Init[3];
      PSKB.ptm:=PSKB.kno*10;
      PSKB.mov:=2000;

      PSKA.att:=PSKB.att;
      PSKA.def:=PSKB.def;
      PSKA.pow:=PSKB.pow;
      PSKA.kno:=PSKB.kno;
      PSKA.ptm:=PSKB.ptm;
      PSKA.mov:=PSKB.mov;
    end;
end;
{-----------------------------------------------------------------------------}
procedure InitHeroBios;   //  att, def   procedure InitHeroCar; 
var
  i,j: integer;
  s: string;
  DescTxt,
  SpecTxt: Tstringlist;
begin
  DescTxt:=LoadTxt('HeroBios');
  SpecTxt:=LoadTxt('HeroSpec');
  for i:=0 to MAX_HERO-1 do
  with mHeros[i] do
  begin
    desc:=DescTxt[i];
    s:=SpecTxt[i+2];
    j:=ANSIPOS(NT,s);
    spec1:=copy(s,0,j-1);
    s:=copy(s,j+1,length(s));
    j:=ANSIPOS(NT,s);
    if j > 0 then  s:=copy(s,j+1,length(s));
    spec:=s;
  end;
  DescTxt.free;
  SpecTxt.free;
end;
{----------------------------------------------------------------------------}



end.



!!HE#:X$1/$2/$3/$4/$5/$6/$7; - get/set/check all speciality settings.
$1...$7 - parameters. 

Speciality types (defined by $1)

  $1=0 Secondary skills    $1=1 Creatures   $1=2 Resources  $1=3 Spells
    $2=secondary skill number (see Format SS )
   ($3...$7 ignored, preferably 0)

  $1=1 Creatures
    $2=creature type number (see Format C )
   ($3...$7 ignored, preferably 0)

  $1=2 Resources
    $2=resource type (see Format R )
   ($3...$7 ignored, preferably 0)

  $1=3 Spells
    $2=spell number (see Format SP)
   ($3...$7 ignored, preferably 0)

  $1=4 Creatures extra
    $2=creature type number (see Format C )
    $3=attack bonus
    $4=defence bonus
    $5=damage bonus
  ($6...$7 ignored, preferably 0)

  $1=5 Speed and other
    $2=subtype
   ($3...$7 ignored, preferably 0)

  $1=6 Upgrades
    $2=creature 1 to upgrade(see Format C )
    $6=creature 2 to upgrade(see Format C )
    $7=creature to upgrade to(see Format C )
   ($3...$5 ignored, preferably 0)

  $1=7 Dragons
    $2=attack bonus
    $3=defense bonus
   ($4...$7 ignored, preferably 0)


