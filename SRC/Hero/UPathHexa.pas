unit UPathHexa;
  //rng
interface

uses
  Windows, Messages, SysUtils, Classes, ExtCtrls, UType;

Const { directions in which to go. both constants are used in the same time }
  DirXL1: Array[0..5] of ShortInt=( 1,-1, 0, 0,-1,-1);
  DirXL2: Array[0..5] of ShortInt=( 1,-1, 0, 0, 1, 1);
  DirY  : Array[0..5] of ShortInt=( 0, 0, 1,-1,-1, 1);

  // Hex à droite                   1   0
  // Hex à gauche                  -1   0
  // Hex en bas                     0   1
  // Hex en haut                    0  -1
  // Hex en diag 1 haut  -1+2(Ymod2)   -1
  // Hex en diag 2 bas   -1+2(Ymod2)    1


    //cell at Range 2 from center
Dir2XL1: Array[0..11] of ShortInt=( 2,-2,  -1, 0, 1,  -1, 0, 1,  -2,-2, 1, 1);
Dir2XL2: Array[0..11] of ShortInt=( 2,-2,  -1, 0, 1,  -1, 0, 1,  -1,-1, 2, 2);
Dir2Y  : Array[0..11] of ShortInt=( 0, 0,   2, 2, 2,  -2,-2,-2,  -1, 1,-1, 1);







type
  TBaPath = class
  public
    Pos: Tpoint;
    Dst: Tpoint;
    Speed: integer;
    Step: integer;
    HexMove: array [-1..MAX_BaX+1,-1..MAX_BaY+1] of boolean;   // status portée des cases
    WayHex:  array [0..nBaPath] of TPoint;               // cases formant le chemin
    DstPath: integer;
    function  Inside(x,y: integer): boolean;
    function  Contact(uid :integer): boolean;
    procedure ResetMoveHex;
    procedure SetFlyHex;
    procedure SetWalkHex;
    function  FindWalk(x,y:integer):boolean;
    function  FindFly(x,y:integer):boolean;
    function  Distance(Hex1, Hex2:TPoint): integer;

  private
    HexMax:integer;
    DstMax:integer;

    RangedHex: array [0..nBaTiles] of TPoint;  // cases rangées par distance
    HexDst:    array [0..nBaTiles] of integer; // distance des cases de RangedHex
    PrevHex:   array [0..nBaTiles] of TPoint;  // cases precurseur
    function  FreeTile(x,y:integer): boolean;
  end;

implementation

uses Ubattle;
{----------------------------------------------------------------------------}
function TBaPath.Inside(x,y: integer): boolean;
begin
  result:=(x <= MAX_BaX) and (x >= 0) and (y <= MAX_BaY) and (y >=0);
end;
{----------------------------------------------------------------------------}
function TBaPath.Contact(uid: integer): boolean;
var
  i,x,y: integer;
begin
  result:=False;
  for i:=0 to 5 do
  begin
    if (Pos.y mod 2 = 1)
    then x:=Pos.x+DirXL1[i]
    else x:=Pos.x+DirXL2[i];
    y:=Pos.y+DirY[i];
    if Inside(x,y) then
    if (bTiles[x,y]<> -1)
    then result:=result or ((bTiles[x,y]>=21) and (uid < 21)) or ((bTiles[x,y]<21) and (uid >= 21));
  end;

  if is2HexCR(uid) then
  for i:=0 to 5 do
  begin
    if (Pos.Y mod 2 = 1)
    then X:=Pos.X+1+DirXL1[i]
    else X:=Pos.X+1+DirXL2[i];
    Y:=Pos.Y+DirY[i];
    if Inside(X,Y) and (bTiles[X,Y]<> -1)
    then result:=result or ((bTiles[X,Y]>=21) and (uid < 21)) or ((bTiles[X,Y]<21) and (uid >= 21));
  end;
end;
{----------------------------------------------------------------------------}
procedure TBaPath.ResetMoveHex;
var
  i,j:integer;
begin
  for i:=-1 to MAX_BaX+1 do
    for j:=-1 to MAX_BaY+1 do HexMove[i,j]:=False;
  if BUnits[bid].tower=0 then HexMove[Pos.X, Pos.Y]:=true;
end;
{----------------------------------------------------------------------------}
procedure TBaPath.SetFlyHex;
var
  Hex:TPoint;
  i,j:integer;
begin
  for i:=0 to MAX_BaX do
   for j:=0 to MAX_BaY do
   begin
    Hex.X:=i;
    Hex.Y:=j;
    if Distance(Pos, Hex) <= Speed  then
      HexMove[i,j]:=FreeTile(i,j);
   end;

end;
{----------------------------------------------------------------------------}
function TBaPath.FreeTile(x,y:integer): boolean;
var
  second : integer;
begin
  result:=false;
  if inside(x,y) then
  begin
    if (bTiles[X,Y] = -1) then
    begin
      result:=true ;
      if is2HexCR(bId)
      then // need to check 2nd hex
      begin
        if
        ((bTiles[X+1,Y] <> -1) and (bTiles[X+1,Y] <> bid))
        and
        ((bTiles[X-1,Y] <> -1) and (bTiles[X-1,Y] <> bid))
        then result:=false;
      end;
    end;
    if (bTiles[X,Y] = bId)
    then result:=true;
  end;
  if bCT>-1 then begin
    if (Y=5) and ((X=9) or (X=10))
    then result:=isBridgePassable and (bTiles[X,Y] = -1);
  end;
end;
{----------------------------------------------------------------------------}
 // recherche pour pieton
procedure TBaPath.SetWalkHex;
var
  x,y,d:integer;
  InRangedHex, TrouveHex:Boolean;
  i,j,k:integer;
  StartDstd, EndDstd, TempMax:integer;
begin
  //  initialise RangedHex[0] à Pos
  Step:=0;
  RangedHex[0]:=Pos;
  HexDst[0]:=0;
  TempMax:=0;
  StartDstd:=0;
  EndDstd:=0;
  // cherche les Hex situé à une Distance d = 1 à speed
  //  si libre alors X,Y rentre dans les RangedHex
  for d:=0 To Speed-1  do
  begin
    TrouveHex:=False;
    // Parcours les Hex de RangedHex situés à la Distance d
    // et insère les Hex situés à la Distance d+1 }
    for i:=StartDstd To endDstd do
    begin
      // fait le tour des Hex voisins
      for j:=0 to 5 do
      begin
        if (RangedHex[i].Y mod 2 = 1)
        then X:=RangedHex[i].X+DirXL1[j]
        else X:=RangedHex[i].X+DirXL2[j];
        Y:=RangedHex[i].Y+DirY[j];
        if FreeTile(X,Y) then
        begin
            InRangedHex:=False;
            // parcour du RangedHex existant et si inRangedHex sort du parcour
            for k:=0 To TempMax do
            begin
              if (X = RangedHex[k].x) and (Y = RangedHex[k].y) Then
              begin
                InRangedHex:=True;
                Break;
              end;
            end; // for k
            // insère dans RangedHex
            if InRangedHex = False Then
            begin
              TempMax:=TempMax + 1;
              RangedHex[TempMax].X:=X;
              RangedHex[TempMax].Y:=Y;
              HexDst[TempMax]:=d+1;
              PrevHex[TempMax]:=RangedHex[i];
              HexMove[X,Y]:=true;
              TrouveHex:=True;
            end;
        end; // inmap
      end; // next j
    end; // next i de StartDstd à endDstd

    if (TrouveHex = False) Then
    begin
      HexMax:=TempMax;
      DstMax:=d;
      Exit;
    end
    else
    begin
      StartDstd:=endDstd+1;
      endDstd:=TempMax;
    end;
  end; // next d de 0 à 5

  HexMax:=TempMax;
  DstMax:=HexDst[TempMax];
end;
{----------------------------------------------------------------------------}
function TBaPath.FindWalk(x,y:integer):boolean;
var
 i: integer;
 CurHex: TPoint;
begin
  dst:=point(x,y);
  DstPath:=-1;
  result:=HexMove[Dst.x,Dst.y];
  if result=false then exit;
  CurHex.X:=Dst.x;
  CurHex.Y:=Dst.Y;
  for i:=HexMax downto 0 do
  begin
    if  (RangedHex[i].x=CurHex.x) and  (RangedHex[i].y=CurHex.y) then
    begin
      WayHex[HexDst[i]]:=RangedHex[i];
      inc(DstPath);
      CurHex:=PrevHex[i];
    end;
  end;
end;
{----------------------------------------------------------------------------}
function TBaPath.FindFly(x,y:integer):boolean;
var
 i: integer;
 CurHex: TPoint;
begin
  dst:=point(x,y);
  DstPath:=Distance(pos,dst);
  result:=HexMove[Dst.x,Dst.y];
end;
{----------------------------------------------------------------------------}
function  TBaPath.Distance(Hex1, Hex2:TPoint): integer;
var
  i,j:integer;
  nRange:integer;
begin
  nRange:=0;
  if (Hex2.x = Hex1.x) then   // meme colonne
  begin
    nRange:=ABS(Hex2.y - Hex1.y);
  end;

  if (Hex2.y = Hex1.y) then   // meme ligne
  begin
    nRange:=ABS(Hex2.x - Hex1.x);
  end;

  if nRange = 0 then  // colone et ligne differente
  begin
    j:=ABS(Hex2.y - Hex1.y); // delta ligne
    i:=ABS(Hex2.x - Hex1.x); // delta colonne

    if j mod 2 = 0 then // delta ligne paire donc pas d'ajustement
    begin
      if i <= j / 2 then result:=j else result:=round(i+j/2); // cas |- ou |--
    end
    else
    begin              // delta ligne impaire donc ajustement
      j:=j-1;
      if  Hex1.y mod 2 = 0 then
      begin
        if  (Hex2.x - Hex1.x) > 0 then i:=i-1;
      end
      else
      begin
        if  (Hex2.x - Hex1.x) < 0 then i:=i-1;
      end;
      if i <= j / 2 then result:=j+1 else result:=1+round(i+j/2);
    end;
  end
  else result:=nRange;
end;

end.
