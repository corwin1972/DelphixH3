{-----------------------------------------------------------------------------
 Unit Name: UPath
 Author:    Nicolas Risola
 LastUpdate: 23/05/02
 Purpose:
 History:

 Original idea by:
 John Christian Lonningdal, 5 May 1996
 Rewritten, improved, corrected by:
 George K., 23 December 1999
 Vladimir V.,  16.10.00 : W-develop@mtu-net.ru; http//www.GameDev.narod.ru
-----------------------------------------------------------------------------}

unit UPathRect;

interface

uses
  Windows, Messages, SysUtils, Classes, ExtCtrls, Utype;

Const { directions in which to go. both contstants are used in the same time }
  DirX   : Array[0..7] of ShortInt=( 0,1,0,-1,-1, 1,1,-1);
  DirY   : Array[0..7] of ShortInt=(-1,0,1, 0,-1,-1,1, 1);
  DirV   : Array[0..7] of double=(1,1,1,1, 1.42,1.42,1.42,1.42);
  RevDir : Array[0..7] of Byte=(2,3,0,1,6,7,4,5);
  //DirV   : Array[0..7] of double=(1.42,1.42,1.42,1.42,1,1,1,1);
  DirCol : Array[0..7] of byte=(0,2,4,6,7,1,3,5);
  DirRad : Array[0..7] of Double=(0, 1.57, 3.14, 4.71, 5.5, 0.79, 2.37, 3.93);
type
  TDirChangedPoints = record
    Point : TPoint;
    Dir   : Byte;
 end;

type
  TPath = class
  private
    dim   : Integer;
    pList : array[0..1] of array of TPoint;
    function inside(x,y:integer): boolean;
  public
    pHe:integer;
    pStart : TPoint;     // starting position
    l: integer;
    pDest : TPoint;     // the destination
    Green: integer;
    length: Integer;
    obStart: boolean;
    obDest:  boolean;
    Path       : array of TPoint;
    DirMap     : array of Array of Byte;
    Obstacle  : array of array of Boolean;
    CostTile  : array of array of Integer;
    CostPath  : array of array of Integer;
    Refresh: boolean;
    constructor Create(adim : integer ); virtual;
    destructor Destroy; override;
    procedure BuildDir;
    procedure BuildObs(HE: integer);
    function  FindPath(HE: integer):Boolean;
    function  IsPathTo(x,y: integer):Boolean;
  end;

var
  mPath: Tpath;

implementation

uses UMap, UHE;

constructor TPath.Create(aDim : integer);
begin
  inherited Create;
  Dim:=adim;
  pStart:=point(1,1);
  SetLength(Obstacle,dim,dim);
  SetLength(CostTile,dim,dim);
  SetLength(CostPath,dim,dim);
  SetLength(DirMap,dim,dim);
  SetLength(pList[0],dim*dim);   //dst paire
  SetLength(pList[1],dim*dim);   //dst impaire
  SetLength(Path,dim*dim);
end;
{----------------------------------------------------------------------------}
destructor TPath.Destroy;
begin
  inherited Destroy;
end;
{----------------------------------------------------------------------------}
function TPath.IsPathTo(x,y: integer):Boolean;
begin
  if (Inside(x,y))
  then result:=(DirMap[x,y]<>255)
  else result:=false;
end;
{----------------------------------------------------------------------------}
function TPath.FindPath(HE: integer):Boolean;
var
  x,y       : Integer;
  Direction : Byte;

begin  //ContructDir;
  length:=-1;
  result:=false;
  refresh:=result;
  with mHeros[HE] do
  begin
    pStart.x:= pos.x;
    pStart.y:= pos.y;
    pDest.x:=  tgt.x;
    pDest.y:=  tgt.y;
    //Green:=PSKA.mov; // div 100;
    if ( (tgt.x=pos.x) and (tgt.y=pos.y) ) then exit;
  end;

  x:=pDest.X;
  y:=pDest.Y;
  if (DirMap[x,y]=255) then exit;

  { adding fINAL position to our path }
  length:=0;
  Path[0]:=Point(x,y);

  { now adding more points to our PATH, starting from END
    and using Direction map to get back to starting point }

  while not((x=pStart.x) and (y=pStart.y))  do
  begin
    Direction:=DirMap[x,y];      // loading direction value
    if Direction=255 then exit;
    Direction:=RevDir[Direction]; // revert direction

    { moving in that direction }
    x:=x+DirX[Direction];
    y:=y+DirY[Direction];

    { adding new point to PATH array }
    Inc(length);
    Path[length]:=Point(x,y);

    { if got path overflow - leave }
    if length>Dim*Dim-1 then Exit;
  end;
  result:=true;
  refresh:=result;
end;

function TPath.inside(x,y:integer): boolean;
begin
  result:=(x>=0)and(y>=0)and(x<=Dim-1)and(y<=Dim-1);
end;
{----------------------------------------------------------------------------
  Path-finding routine
----------------------------------------------------------------------------}

procedure TPath.BuildDir;
var
 pLength     : Array[0..1] of Integer; // length of our point arrays
 PointStart  : Array[0..1] of Integer; //my
 CurPoint    : Integer; // point array we're processing at the moment
 P           : TPoint;
 i,x,y,j,k   : Integer;
 costDir     : integer;
 Skip:         Boolean;
 Stuck       : Boolean; // used to avoid Lock-ups
 { direction
   0 - Up         1 - Right       2 - Down       3 - Left
   4 - Up&Left    5 - Up&Right    6 - Down&Right 7 - Down&Left
   255 - No Direction }

{ pick a new direction }
  function NewDirection(Dir:Byte):Byte;
  begin
    Inc(Dir);
    if Dir>7 then Dir:=0;
    NewDirection:=Dir;
  end;


  function finddst(x,y:integer): boolean;
  begin
    result:=(x=pDest.X)and(y=pDest.Y);
  end;

  //end local
begin
  //*if fObstacle[fDst.x,fDst.y] then exit;
  // !!!!!!! fillChar does not work with dinamic Array
  //fillChar(fDirMap,SizeOf(fDirMap),255); // filling our direction map with value 255 = no direction

  { adding starting position to Point Array #0 }
  pLength[0]:=1;
  pList[0,0]:=pStart;
  CostPath[pStart.X,pStart.y]:=0;
  { Point Array #1 is empty }
  pLength[1]:=0;

  CurPoint:=0; // current Point array is #0

  PointStart[0]:=0;
  PointStart[1]:=0;

  repeat
    Stuck:=True;

    for j:= PointStart[CurPoint] to pLength[CurPoint]-1 do
    begin

      p:=pList[CurPoint,j];
      { expanding the direction map from current position P by checking specific directions }
      { variable "i" is our direction. there're 8 directions... }
      for i:=0 to 7 do
      begin
        { getting new coordinates if we're going in current direction }
        x:=p.X+DirX[i];
        y:=p.Y+DirY[i];
        if ((obStart) and (p.X=pStart.x) and (p.y=pStart.y)) then
        if (i in  [4,0,5])  then continue; // exit from north forbidden

        { check if our new place is valid }
        { to be valid it must be:
        1) inside DIMWH boundaries
        2) empty or a destination
        3) the direction map at this place must be empty (i.e. set to NoDirection = 255) }
        if inside(x,y)then
        begin
          if ((CostTile[p.x,p.y] < 0) and (not(mTiles[x,y,l].obX.T=OB54_Monster)))
          then continue;

          //add entry as target
          if  (Obstacle[x,y])   then
          begin
            // destination obstacle included in the allowed path
            if (mTiles[x,y,l].p1=TL_ENTRY)  // TODO understand why ???and (finddst(x,y))
            then
            begin
              // access from top
              // skip direction from top (north)
              skip:= (i in  [7,2,6]);
              // except samll object  Obj::SHIPWRECK_SURVIVOR,  Obj::WHIRLPOOL,  or gate
              if (mTiles[x,y,l].obX.t in
              [OB05_Artifact, OB08_Boat, OB09_BorderGuard, OB10_KeyMaster,
               OB11_Buoy, OB12_Fire, OB29_FlotSam, OB22_Corpse,
               OB34_Hero, OB33_Garnison,  OB54_Monster, OB59_Bottle, OB79_Res,
               OB81_Schoolar,OB82_SeeChest, OB101_TreasureChest,OB212_borderGate])
              then skip:=false;
              if skip then continue;
              costDir:=Abs(CostTile[x,y]);
              // todo faut il check reste sur route ?
              if ( CostPath[p.x,p.y] + costDir ) < CostPath[x,y] then
              begin
                CostPath[x,y]:=CostPath[p.x,p.y] + costDir;
                DirMap[x,y]:=i;
              end;
            end;

            if ((mTiles[x,y,l].plage) and (mHeros[pHE].boatId > 0))
            then
            begin
              costDir:=Abs(CostTile[x,y]);
              if CostPath[p.x,p.y]+ costDir< CostPath[x,y] then
              begin
                CostPath[x,y]:=CostPath[p.x,p.y] + costDir;
                DirMap[x,y]:=i;
              end;
            end;
            continue;
          end;

          // not an obstacle
          costDir:=Abs(CostTile[x,y]);
          // todo faut il check reste sur route ?
          if CostPath[p.x,p.y]+ costDir < CostPath[x,y] then
          //if CostPath[pStart.x,pStart.y]+ Abs(CostTile[x,y])< CostPath[x,y] then
          begin
            CostPath[x,y]:=Costpath[p.x,p.y] +costDir;
            //CostPath[x,y]:=Costpath[pStart.x,pStart.y] + Abs(CostTile[x,y]);
            DirMap[x,y]:=i; // filling the direction map
            { adding this position to ANOTHER Point Array so our current array won't be corrupted }

            k:=pLength[CurPoint xor 1];
            pList[CurPoint xor 1,k]:=Point(x,y);
            Inc(k);
            { if we got overflow - exit }
            if k>Dim*Dim-1 then
            begin
              //result:=false;
              Exit;
            end;

            pLength[CurPoint xor 1]:=k;
            // we added new point so we're not stuck!
            Stuck:=false;

          //if finddst(x,y) then result:=true;
        end;{ add point to point array }
      end;
      end; // i
    end;//j

    PointStart[CurPoint]:=pLength[CurPoint];
    { changing current Point Array }
    CurPoint:=CurPoint xor 1;

  until Stuck=true;

end;

{----------------------------------------------------------------------------}
procedure TPath.BuildObs(HE: integer);
var
 i,j: integer;
 //rivage: boolean;
 p: TPos;
begin
  pHe:=HE;
  pStart.x:= mHeros[HE].pos.x;
  pStart.y:= mHeros[HE].pos.y;
  l:= mHeros[HE].pos.l;
  pDest.x:= mHeros[HE].tgt.x;
  pDest.y:= mHeros[HE].tgt.y;
  obDest:=false;
  obStart:=(mHeros[HE].obX.t <> 0);
  Green:=mHeros[HE].PSKA.mov; // div 100;
  if mHeros[HE].obX.t=OB33_Garnison  then obstart:=false;
  //(mTiles[Pos.x,Pos.y,Pos.l].P1=2) and(mTiles[Pos.x,Pos.y,Pos.l].Obj.T <> 34 );
  //reinit obstacle
  p.l:=l;
  for i:=0 to(Dim-1) do
   for j:=0 to(Dim-1) do
   begin
     Obstacle[i,j]:=( not(mTiles[i,j,l].vis[mHeros[HE].pid])
                       or (mTiles[i,j,l].TR.t=9)
                       or (mTiles[i,j,l].P1 > 0)
                       or ((mHeros[HE].boatId > 0) and (mTiles[i,j,l].TR.t<>TR08_Water))
                       or ((mHeros[HE].boatId = 0) and (mTiles[i,j,l].TR.t=TR08_Water))  );

   {if ((mHeros[HE].boatId > 0) and (mTiles[i,j,l].TR.t<>TR08_Water)  )
   then
   begin
     Rivage:=false;
     for k:=-1 to 1 do
     for m:=-1 to 1 do
     if  mTiles[i+k,j+m,l].TR.t=TR08_Water then Rivage:=true;
     if rivage then Obstacle[i,j]:=false;
   end; }

    p.x:=i;
    p.y:=j;
    DirMap[i,j]:=255;
    if mTiles[i,j,l].nCreas <= 0
    then CostTile[i,j]:=Cmd_HE_PathCost(HE,p)
    else CostTile[i,j]:=-Cmd_HE_PathCost(HE,p); //-1
    CostPath[i,j]:=100000;
   end;
  Obstacle[pStart.x,pStart.y]:=false;
  CostPath[pStart.x,pStart.y]:=0;
  CostTile[pStart.x,pStart.y]:=0;
  BuildDir;
end;


end.
