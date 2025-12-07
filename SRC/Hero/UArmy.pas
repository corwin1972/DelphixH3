unit UArmy;


interface

uses
   Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math, UType;

type

TArmyGUI = class
  private
   procedure swap(a:integer);
  public
    pArmys: Array [0..2] of  ^TArmys;
    pHE: Array [0..2] of Integer;
    CT,aid,sid,tid: integer;
    sep: boolean;
    constructor create;
    procedure init(var Armys1,Armys2: TArmys);
    procedure initHE(aHE: integer);
    procedure initCT(aCT: integer);
    procedure initMeet(aHE1,aHE2: integer);
    function  canlose: boolean;
    function  select(a,slot:integer): boolean;
    function  merge(aCT: integer): boolean;
    // procedure lose;
    function  hint(a,slot:integer):string;
end;

var
  gArmy:TArmyGUI;

implementation


uses USnInfoCrea, USnSepCrea;
{----------------------------------------------------------------------------}
constructor TArmyGUI.Create;
begin
  inherited;
  sid:=-1;
  tid:=-1;
end;
{----------------------------------------------------------------------------}
procedure TArmyGUI.init(var Armys1,Armys2: TArmys);
begin
  pArmys[1]:=@Armys1;
  pArmys[2]:=@Armys2;
  CT:=-1;
  sid:=-1;
  tid:=-1;
  //rmvActif;
end;
{----------------------------------------------------------------------------}
procedure TArmyGUI.initMeet(aHE1,aHE2: integer);
begin
  pHE[1]:=aHE1;
  pHE[2]:=aHE2;
  pArmys[1]:=@mHeros[pHE[1]].Armys;
  pArmys[2]:=@mHeros[pHE[2]].Armys;
  CT:=-1;
  sid:=-1;
  tid:=-1;
end;
{----------------------------------------------------------------------------}
procedure TArmyGUI.initCT(aCT: integer);
begin
  CT:=aCT;
  pHE[0]:=-1;
  sid:=-1;
  tid:=-1;
  pHE[1]:= mCitys[CT].GarHero;
  if pHE[1] <> -1 then
  pArmys[1]:=@mHeros[pHE[1]].Armys else
  pArmys[1]:=@mCitys[CT].GarArmys;
  pHE[2]:= mCitys[CT].VisHero;
  if pHE[2] <> -1 then
  pArmys[2]:=@mHeros[pHE[2]].Armys else
  pArmys[2]:=nil;
  //rmvActif;
end;
{----------------------------------------------------------------------------}
procedure TArmyGUI.initHE(aHE: integer);
begin
  sid:=-1;
  tid:=-1;
  pHE[0]:=aHE;
  CT:=-1;
  pArmys[0]:=@mHeros[pHE[0]].Armys ;
end;
{----------------------------------------------------------------------------}
function TArmyGUI.CanLose: boolean;
var i,n : integer;
begin
  if pHE[aid]= -1 then
    result:=true
  else
  begin
    n:=0;
    for i:=0 to 6 do
    if  pArmys[aid,i].t<>-1 then inc(n);
    result:=(n> 1);
  end;
end;
{----------------------------------------------------------------------------}
function TArmyGUI.select(a,slot:integer): boolean;
var
  t, n: integer;
begin
  if slot=-1 then begin sid:=-1; exit; end;
  if (sId=-1)
  then
  begin
    aid:=a;
    if pArmys[a,slot].t<>-1 then sId:=slot
  end
  else
  begin
    tid:=slot;
    if ((tid=sid) and (aid=a))
    then
    begin
      sid:=-1;
      t :=pArmys[a,tid].t;
      n:= pArmys[a,tid].n;
      TSnInfoCrea.Create(CT,pHE[a],t,n);
    end
    else swap(a);
  end;
  result:=not(sid=-1);
  sep:=false;
end;
{----------------------------------------------------------------------------}
procedure TArmyGUI.swap(a: integer);
var
  t,n:integer;
begin
  t:=pArmys[aid,sid].t;
  n:=pArmys[aid,sid].n;
  if (sep) and ((pArmys[a,tid].t=t) or (pArmys[a,tid].t=-1))
  then
  begin
  // split of same army
    mDialog.res:=-1;
    if pArmys[a,tid].t=-1 then pArmys[a,tid].n:=0;
    TSnSepCrea.Create(t,n,pArmys[a,tid].n);
    repeat
      Application.HandleMessage
    until mDialog.res <> -1;

    if mDialog.res > 0 then
    begin
      pArmys[aid,sid].n:=pArmys[a,tid].n+n- mDialog.res;
      pArmys[a,tid].t:=pArmys[aid,sid].t;
      pArmys[a,tid].n:=mDialog.res;
      if pArmys[a,tid].n=0 then pArmys[a,tid].t:=-1;
      if pArmys[aid,sid].n=0 then pArmys[aid,sid].t:=-1;
    end;
  end
  else
  begin
  // combination on target slot
    if pArmys[a,tid].t=t then
    begin
      if CanLose or (a=aid)  then
      begin
      pArmys[aid,sid].t:=-1;
      pArmys[aid,sid].n:=0;
      pArmys[a,tid].n:=pArmys[a,tid].n+n;
      end else
      begin
      //Armys[aid,sid].t:=-1;
      pArmys[aid,sid].n:=1;
      pArmys[a,tid].n:=pArmys[a,tid].n+n-1;
      end
    end
    else
    begin
   // exchange of 2 army type
      if CanLose or (a=aid) or (pArmys[a,tid].t> -1) then
      begin
      pArmys[aid,sid].t:=pArmys[a,tid].t;
      pArmys[aid,sid].n:=pArmys[a,tid].n;
      pArmys[a,tid].t:=t;
      pArmys[a,tid].n:=n;
      end;
    end;
  end;
  sId:=-1;
  tid:=-1;
  //rmvactif;
end;
{----------------------------------------------------------------------------}
function TArmyGUI.Merge(aCT: integer):boolean;
var
  slot1,slot2: integer;
  slotFree: integer;
  slotFound: boolean;
begin
  result:=false;
  //count free slot on army2
  slotFree:=0;
  for slot2:=0 to MAX_ARMY  do
  if  pArmys[2,slot2].t = -1 then inc(slotFree);

  //put army1 unit into army2

  for slot1:=0 to MAX_ARMY  do
  if  pArmys[1,slot1].t <> -1 then
  begin
    slotfound:=false;
    for slot2:=0 to MAX_ARMY  do
      if pArmys[2,slot2].t=pArmys[1,slot1].t then
      begin
        slotFound:=true;
        break;
      end;
    if slotFound=false then
    dec(slotFree)
  end;

  if slotFree < 0 then exit;

  for slot1:=0 to MAX_ARMY  do
  if  pArmys[1,slot1].t <> -1 then
  begin
    slotFound:=false;
    for slot2:=0 to MAX_ARMY  do
      if pArmys[2,slot2].t=pArmys[1,slot1].t then
      begin
        slotFound:=true;
        pArmys[2,slot2].n:=pArmys[2,slot2].n+pArmys[1,slot1].n;
        break;
    end;
    if slotFound=false then
    for slot2:=0 to MAX_ARMY  do
      if  pArmys[2,slot2].t = -1 then
      begin
        slotFound:=true;
        pArmys[2,slot2].n:=pArmys[1,slot1].n;
        pArmys[2,slot2].t:=pArmys[1,slot1].t;
        break;
    end;
  end;

  for slot1:=0 to MAX_ARMY  do
  begin
    pArmys[1,slot1].t:=-1;
    pArmys[1,slot1].n:=0;
  end;
  result:=true;
end;

{----------------------------------------------------------------------------
procedure TArmyGUI.Lose;   // lose selected army and remove selection
begin
  pArmys[1,sid].t:=-1;
  pArmys[1,sid].n:=0;
  pArmys[1,sid].a:=false;
  sid:=-1;
end;
{----------------------------------------------------------------------------}
function TArmyGUI.hint(a,slot:integer):string;        //a army 1 2
var
  t: shortint;
  fText: TStringlist;
begin
  result:='vide';
  if pArmys[a]=nil then exit;
  fText:=TxTTcommand;
  t:=pArmys[a,slot].t;
  if (sid=-1)  // no current selection
  then
    if t=-1
    then result:=fText[11]
    else
    begin
       if a=0 then   result:=iCrea[t].name;
       if a=1 then   result:=format(fText[12],[iCrea[t].name]);
       if a=2 then   result:=format(fText[32],[iCrea[t].name]) ;
    end
  else        // crea selected, so what ...
    if (slot=sid) and (a=aid)
    then
      if t=-1
      then result:=fText[11]
      else result:=format(fText[4],[iCrea[t].name])
    else
     if t=-1
     then
       if sep
       then result:=fText[3]
       else begin
         if CanLose or (a=aid)
         then result:=format(fText[6],[iCrea[pArmys[aid,sid].t].name])
         else result:=fText[5];
       end
     else
       if t=pArmys[aid,sid].t
       then begin
          if CanLose or (a=aid) or (pArmys[aid,sid].n >1)
          then result:=format(fText[2],[iCrea[t].name])
          else result:=fText[1];
       end
       else result:=format(fText[7],[iCrea[pArmys[aid,sid].t].name , iCrea[t].name]) ;
end;
{----------------------------------------------------------------------------}

initialization

begin
  gArmy:=TArmyGUI.create;
end;

end.
