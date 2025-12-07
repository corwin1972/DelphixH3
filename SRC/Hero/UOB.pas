unit UOB;

interface

uses  SysUtils, UType, Forms, Math, UAI, Classes;

{-----------------------------------------------------------------------------
  Procedure: Cmd_OB_xx
  Operation on MAP OBJECT
-----------------------------------------------------------------------------}

  procedure Cmd_OB_Del(n: integer);
  function  Cmd_OB_FindGuard(x,y,l: integer): integer;
  function  Cmd_OB_Find(t,i0: integer): integer; // Find obj index of type T
  function  Cmd_OB_FindGate(pos:Tpos): integer;
  procedure Cmd_OB_NewWeek;


implementation

uses UHE;

{----------------------------------------------------------------------------}
procedure Cmd_OB_NewWeek;  //todo new week for obj
var
  i: integer;
const
  OB946_GEN1=946;
begin
  for i:=0 to nObjs-1 do
  case mObjs[i].t of
    OB17_Generator:     mObjs[i].v:=iCrea[2*(mObjs[i].def-OB946_GEN1)].growth;
    OB32_Garden:        mObjs[i].v:=0;
    OB48_MagicSpring:   mObjs[i].v:=1;
    OB55_MysticalGarden:mObjs[i].v:=random(2);
    OB109_WaterWheel:   mObjs[i].v:=1000;
    OB112_WindMill:     mObjs[i].v:=random(MAX_RES);
  end;
end;
{----------------------------------------------------------------------------}
function Cmd_OB_Find(t, i0: integer): integer;
var
  i: integer;
begin
  result:=-1;
  for i:=i0 to nObjs-1 do
  begin
    if  mObjs[i].t=t then
    begin
      result:=i;
      exit;
    end;
  end;
end;
{----------------------------------------------------------------------------
No Monster = -1
1st Monster= OID for fight
                                                                             }
function Cmd_OB_FindGuard(x,y,l: integer): integer;
var
  i,j: integer;
begin
  result:=-1;
  if mTiles[x,y,l].nCreas>0 then
  begin
    for i:=x-1 to x+1  do
    begin
      for j:= y-1 to y+1  do
      begin
        if mTiles[i,j,l].obX.t=OB54_Monster then break;
      end;
      if mTiles[i,j,l].obX.t=OB54_Monster then break;
    end;
    result:=mTiles[i,j,l].obX.oid
  end;
end;
{----------------------------------------------------------------------------}
function Cmd_OB_FindGate(pos:TPos): integer;
var
  d,i: integer;
  p: TPOS;
  found: boolean;
begin
  found:=false;
  p.l:=1-pos.l;
  for d:=1 to 20 do // dist
  begin
   for i:=-d to d do
   begin
     p.x:=pos.x-d;
     p.y:=pos.y+i; // column -d
     if mTiles[p.x,p.y,p.l].obX.t=OB103_Gate then
     begin
       found:=true;
       break;
     end;
     p.x:=pos.x+d;
     p.y:=pos.y+i;  // column +d
     if mTiles[p.x,p.y,p.l].obX.t=OB103_Gate then
     begin
       found:=true;
       break;
     end;
     p.x:=pos.x+i;  // line -d
     p.y:=pos.y-d;
     if mTiles[p.x,p.y,p.l].obX.t=OB103_Gate then
     begin
       found:=true;
       break;
     end;
     p.x:=pos.x+i; // line +d
     p.y:=pos.y+d;
     if mTiles[p.x,p.y,p.l].obX.t=OB103_Gate then
     begin
      found:=true;
      break;
     end;
   end;
   if found then break;
 end;
 if found then result:= mTiles[p.x,p.y,p.l].obX.oid else result:=-1;
end;
{----------------------------------------------------------------------------}
procedure Cmd_OB_Del(n: integer);
var
  i,x,y,l: integer;
begin
  if mObjs[n].t=OB34_Hero
  then Cmd_HE_Del(mObjs[n].v)
  else
  begin
    mObjs[n].Deading:=500;
    x:=mObjs[n].pos.x;
    y:=mObjs[n].pos.y;
    l:=mObjs[n].pos.l;
    if  mObjs[n].t =8 then x:=x+1;
    mTiles[x,y,l].P1:=0;
    mTiles[x,y,l].obX.T:=0;
    mTiles[x,y,l].obX.oid:=0;

    if  mObjs[n].t =OB54_Monster
    then
    for i:=0 to 8 do
    begin
      x:=1+mObjs[n].pos.x-(i mod 3);
      y:=1+mObjs[n].pos.y-(i div 3);
      if mtiles[x,y,l].nCreas > 0 then
      mtiles[x,y,l].nCreas:=mtiles[x,y,l].nCreas-1;
    end;
  end;
end;
{----------------------------------------------------------------------------}


end.
