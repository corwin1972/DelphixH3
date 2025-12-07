unit DXWGameSprite;

Interface

Uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,  DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DXWNavigator,
  UMap, UType, UConst, UPathRect;

type
  TGameSpriteEngine = class(TDXSpriteEngine)
  public
    procedure scroll(dx,dy:integer);  //[NRI extension] scroll the engine
  end;

  TGameSprite = class(TImageSprite)
  public
     pid: integer;                    //[NRI extension] player index
     oid: integer;                    //[NRI extension] index dans la liste mObjs to update pid
     L: Byte;                         //[NRI extension] map level
     procedure ChangeColor;
     procedure DoDraw; override;      //[NRI extension] draw with PL colors
  end;
  
  TGameHero = class(TGameSprite)
  private
    FDirection: integer;
    FPic :      string;
    FImageList: TDXImageList;
    FCanMove :  boolean;
    FSpeed: double;
    XCount,YCount : integer;
    procedure SetPatternXYCount;
    procedure SetPic(const Value: String);
  protected
    procedure SetDirection( Value : integer);
    procedure SetMove(Value : boolean);
    procedure DoMove(MoveCount: Integer); override;
    procedure DrawFlag;
  public
    hid: integer;
    property Direction : integer read FDirection write SetDirection;
    property Pic : string read FPic write SetPic;
    property CanMove : Boolean read FCanMove  write SetMove;
    constructor Create(AParent: TSprite;ImageList: TDXImageList);
    destructor Destroy; override;
    procedure DoDraw; override;
  end;

  TGameForeground = class(TBackGroundSprite)
  private
    PTiles:   ^TTiles;
    FImgPath: TPictureCollectionItem;
    FImgFog:  TPictureCollectionItem;
    FImgEdg:  TPictureCollectionItem;
  protected
    function  GetBoundsRect: TRect; override;
  public
    L: byte;  //[NRI extension] map level
    procedure DoDraw; override;
    constructor Create(AParent:TSprite;ImageList: TDXImageList);
  end;

  TGameBackground = class(TBackGroundSprite)
  private
    PTiles:   ^TTiles;
    FImgTer0: TPictureCollectionItem;
    FImgTer1: TPictureCollectionItem;
    FImgTer2: TPictureCollectionItem;
    FImgTer3: TPictureCollectionItem;
    FImgTer4: TPictureCollectionItem;
    FImgTer5: TPictureCollectionItem;
    FImgTer6: TPictureCollectionItem;
    FImgTer7: TPictureCollectionItem;
    FImgTer8: TPictureCollectionItem;
    FImgTer9: TPictureCollectionItem;
    FImgRoad1: TPictureCollectionItem;
    FImgRoad2: TPictureCollectionItem;
    FImgRoad3: TPictureCollectionItem;
    FimgRiver: TPictureCollectionItem;
    FImageList: TDXImageList;
  protected
    procedure DoDraw; override;
    function  GetBoundsRect: TRect; override;
  public
    L: byte;  //[NRI extension] map level
    procedure MakeMiniMap;
    constructor Create(AParent: TSprite;ImageList: TDXImageList);
  end;

var
  gBackGround: TGameBackGround;
  gForeGround: TGameForeGround;
  gNavigator:  TDXWNavigator;
  gHero :      TGameHero;
 
const
  ChipWH=32;


implementation

Uses
  UMain, Math, USnGame;
{----------------------------------------------------------------------------}
{- TGameSprite -}
{----------------------------------------------------------------------------}
procedure TGameSprite.ChangeColor;
var
  oldCol, NewCol: TRGBQuad;
const
  RD: array [-1..7] of byte =  (150,255,  0,140, 34,255,120, 45,235);
  GR: array [-1..7] of byte =  (150,40 ,  0, 90,140,128, 60, 75,100);
  BL: array [-1..7] of byte =  (150,40 ,210, 43, 34, 64,120,110,100);
begin

  pid := mObjs[oid].pid;
  if ((pid > -2) and (mObjs[oid].t <> OB34_Hero))
  then
  begin
    //check of need to change color ?
    GetDIBColorTable(Image.Picture.Bitmap.Canvas.Handle,  1, 1, oldCol);

    NewCol.rgbBlue := BL[pid];
    NewCol.rgbGreen:= GR[pid];
    NewCol.rgbRed  := RD[pid];
    NewCol.rgbReserved := 0;   //1;

    if  (oldcol.rgbBlue=newcol.rgbBlue)
    and (oldcol.rgbgreen=newcol.rgbgreen)
    and (oldcol.rgbred=newcol.rgbred)
    then exit;
    // put new color=plColor into colortable
    SetDIBColorTable(Image.Picture.Bitmap.Canvas.Handle, 1, 1, NewCol);
    Image.Restore;
  end;
end;
{----------------------------------------------------------------------------}
procedure TGameSprite.DoDraw;
begin
 if L <> SnGame.level then exit;
 ChangeColor;         // Image reused need color update!!!!
 if mObjs[oid].Deading=-1
  then
    inherited dodraw
  else
  begin
    mObjs[oid].Deading:=mObjs[oid].Deading-10;
    Alpha:=mObjs[oid].Deading;
    BlendMode:=rtBlend;
    inherited dodraw;
    if mObjs[oid].Deading < 300 then Dead;
  end;
end;
{----------------------------------------------------------------------------}
{- TGameSpriteEngine -}
{----------------------------------------------------------------------------}
procedure TGameSpriteEngine.Scroll(dx,dy:integer);
var
  NewX, NewY: double;
  Xmax, Xmin, Ymax, Ymin: double;
begin
  if  ((dx=0) and (dy=0))  then  exit;
  Xmax:=0;
  Ymax:=0;
  Xmin:=Engine.Width -MapWH;
  Ymin:=Engine.Height-MapWH;

  NewX:=Engine.X+dx;
  NewY:=Engine.Y+dy;
  if ( NewX<=Xmax ) and ( NewX>=Xmin )
    then Engine.X:=NewX
    else
    if NewX>Xmax
      then Engine.X:=Xmax
      else Engine.X:=Xmin;

  if ( NewY<=Ymax ) and ( NewY>=Ymin )
    then Engine.Y:=NewY
    else
    if NewY>Ymax
      then Engine.Y:=Ymax
      else Engine.Y:=Ymin;
end;


{----------------------------------------------------------------------------}
{- TGameHero -}
{----------------------------------------------------------------------------}
constructor TGameHero.Create(AParent: TSprite;ImageList:TDXImageList);
begin
 inherited Create(AParent);
 FImageList:=ImageList;
 Fspeed:=0.05;
 //CanMove:=true;
end;
{----------------------------------------------------------------------------}
destructor TGameHero.Destroy;
begin
 inherited Destroy;
end;
{----------------------------------------------------------------------------}
procedure TGameHero.DoMove(MoveCount: Integer);
//  FAnimPos :=FAnimPos + FAnimSpeed * MoveCount;
begin
  if ((mPath.length<0) or (mHeros[hid].PSKA.mov <100)) then CanMove:=false;
  if CanMove=false then exit;
  // move code based on ActMoveTime=8
  // so 8 move anim of + 4 to finish 1 step  8*4
  // TODO check the framing time
  AnimPos:=AnimPos+ (opHeroSpeed/4 );
  if AnimPos = AnimCount then AnimPos:=0;

  Direction:=mPath.DirMap[mPath.Path[mPath.length-1].x,mPath.Path[mPath.length-1].y];
  X:= X + opHeroSpeed* DirX[Direction] ;    // 3.2 * DirV[Direction]
  Y:= Y + opHeroSpeed* DirY[Direction] ;    // 3.2 * DirV[Direction]
end;
{----------------------------------------------------------------------------}
procedure TGameHero.DrawFlag;
var
  r: TRect;
  flag: string;
const
  FLG: Array [0..7] of integer = (0,0,0,1,1,0,0,1);
  FLX: Array [0..7] of integer = (-8,3,9,-4,3,-3,8,-8);
begin
  r:=BoundsRect;
  flag:='ABF01'+PL_INITIAL[mHeros[hid].pid];
  FImageList.Items.Find(flag).Draw(Engine.Surface,r.Left+FLX[DIRECTION],r.Top+7,FLG[Direction]);
end;
{----------------------------------------------------------------------------}
procedure TGameHero.DoDraw;
var Boatsprite: TGameSprite;
begin
  if L <> SnGame.level then  exit;
  if mHeros[hid].BoatId=0
  then
    inherited DoDraw
  else
    if mObjs[mHeros[hid].BoatId].Deading=290
    then
      Dead  // kill hero sprite on killing boad
    else
    begin
      Boatsprite:=snGame.FindObjectbyIndex(mHeros[hid].boatId);
      Boatsprite.X:=X ;
      Boatsprite.Y:=Y ;
      Boatsprite.AnimStart:=AnimStart;
      Boatsprite.AnimPos:=AnimPos;
    end;
  DrawFlag;
end;
{----------------------------------------------------------------------------}
procedure TGameHero.SetPatternXYCount;
begin
  XCount:= Image.Picture.Width  div (Image.PatternWidth+Image.SkipWidth);
  YCount:= Image.Picture.Height div (Image.PatternHeight+Image.SkipHeight);
end;
{----------------------------------------------------------------------------}
procedure TGameHero.SetPic(const Value: String);
begin
  if Value=FPic then Exit;
  FPic:= Value;
  Image:= FImageList.Items.Find(Value);
  Image.SystemMemory:=true; //opMemory
  Width:= Image.Width;
  Height:= Image.Height;
  SetPatternXYCount;
  AnimPos:=0;
  Direction:=0;
end;
{----------------------------------------------------------------------------}
Procedure TGameHero.SetDirection(Value : Integer);
var
  PatternY : integer;
const
  DirToPatternY : Array[0..7] of byte=(0,2,4,6,7,1,3,5);
begin
  if Value=255 then exit;
  if Value=FDirection then exit;
  FDirection:=Value;
  PatternY:=DirToPatternY[FDirection];
  AnimStart:=XCount*PatternY;
  AnimCount:=XCount;
end;
{----------------------------------------------------------------------------}
Procedure TGameHero.SetMove(Value : boolean);
Begin
  FCanMove:=value;
  AnimPos:=0;
  AnimLooped:=false;
end;

{----------------------------------------------------------------------------}
{ TGameforeground }
{----------------------------------------------------------------------------}
function TGameForeGround.GetBoundsRect: TRect;
begin
  Result:=Bounds(Trunc(WorldX),Trunc(WorldY),DL*MapWidth,DL*MapHeight);
end;
{----------------------------------------------------------------------------}
constructor TGameForeGround.Create(AParent:TSprite;ImageList: TDXImageList);
begin
  inherited Create(AParent);
  DimWH:=mData.dim;
  MapWH:=ChipWH*(DB+DimWH+DB);
  PTiles:=@mTiles;
  SetMapSize(DB+DimWH+DB,DB+DimWH+DB);
  X:=0;
  Y:=0;
  Z:=2000000;
  Tile:=false;
  Collisioned:=false;
  FImgEdg:=ImageList.Items.Find('edg');
  FImgEdg.SystemMemory:=true;
  FImgFog:=ImageList.Items.Find('tshrc');
  FImgFog.SystemMemory:=true;
  FImgPath:=ImageList.Items.Find('pathRG');
  FImgPath.SystemMemory:=true;
end;
{----------------------------------------------------------------------------}
// Draw of cadre !!
procedure TGameForeground.DoDraw;
var
  _x, _y,level: integer;
  StartX, StartY, EndX, EndY, StartX_, StartY_, OfsX, OfsY, dWidth, dHeight: integer;
  cfg: integer;
  x,y:integer;
{----------------------------------------------------------------------------}
procedure SetBit(Position: Integer; Value: Byte; var ChangeByte: Byte);
var
  bt: Byte;
begin
  bt:=$01;
  bt:=bt shl Position;
  if Value = 1
  then
   ChangeByte:= ChangeByte or bt
  else begin
   bt:=bt xor $FF;
   ChangeByte:=ChangeByte and bt;
  end;
end;
{----------------------------------------------------------------------------}
function Reducebits(cBits:byte):byte;
var
  bits:byte;
begin
  bits:=cbits;
  if((bits and $0101)=$0101)                        //bits 0&2 = 1
  or((bits and $1010)=$1010)                        //bits 1&3 = 1
//or((bits and $01010000)=$01010000)                //bits 4&6 = 1
//or((bits and $10100000)=$10100000) )              //bits 5&7 = 1
  then bits:=255//AllBitN                           //all bits = 1
  else begin
  if ((bits and 48)=48)   then SetBit(1,1,bits);    //bit 1=1
  if ((bits and 96)=96)   then SetBit(2,1,bits);    //bit 2=1
  if ((bits and 192)=192) then SetBit(3,1,bits);    //bit 3=1
  if ((bits and 144)=144) then SetBit(0,1,bits);    //bit 0=1
  if ((bits and 1)=1)     then bits:=(bits or 144); //bit 1=1
  if ((bits and 2)=2)     then bits:=(bits or 48);  //bit 2=1
  if ((bits and 4)=4)     then bits:=(bits or 96);  //bit 3=1
  if ((bits and 8)=8)     then bits:=(bits or 192); //bit 0=1
  end;
  ReduceBits:=bits
end;
{----------------------------------------------------------------------------}
function  CheckVoisin(i,j,l:integer): integer;
const
  vX:     Array[0..7]  of ShortInt=(-1, 0, 1, 0,-1, 1, 1,-1);
  vY:     Array[0..7]  of ShortInt=( 0,-1, 0, 1,-1,-1, 1, 1);
var
  x,y,n: integer;
  b,c,d: byte;
begin
  b:=0;
  for n:=0 to 7 do // repeat cycle to check neighbours
  begin
    x:=i+vx[n];
    y:=j+vy[n];
    if  PTiles[x,y,l].vis[mPL] then
    b:=b + 1 shl n;
  end;
  c:=Reducebits(b);
  d:=c;
  d:=d and 15;    // mask 00001111 extract lo bits
  if (d<16)and(d>0)
  then CheckVoisin:=d
  else CheckVoisin:=16 + c SHR 4; //extract hi bits
end;
{----------------------------------------------------------------------------}
procedure DrawPath;
var
  i,j,
  dirNew, dirOld: integer;
const
  PicID: Array [0..7,0..7] of byte =
   ( ( 0, 9, 8, 8, 8, 9, 9, 8) ,
     (11, 1,10,10,11,11,10,10),
     (12,12, 2,13,13,12,12,13),
     (14,15,14, 3,15,14,14,14),
     (16,16,17,17, 4,16,16,17),
     (18,19,19,18,18, 5,19,18),
     (20,21,20,21,20,21, 6,21),
     (22,23,22,23,22,23,22, 7));
begin
  DirOld:=mPath.DirMap[mPath.Path[0].X,mPath.Path[0].Y];
  for i:=0 to mPath.length-1 do
  begin
    if (gHero.CanMove) and (i=mPath.length-1) then continue; //avoid draw path on last step
    x:=(mPath.Path[i].X -(-StartX+StartX_-DB)) * 32 +OfsX;
    y:=(mPath.Path[i].Y -(-StartY+StartY_-DB)) * 32 +OfsY;

    DirNew:=mPath.DirMap[mpath.Path[i].X,mpath.Path[i].Y];
    {if DirOld <> DirNew then
    begin
      j:=8+2*DirOld+(DirNew mod 2);
      //if i=1 then j:=8+2*DirOld+ (DirOld div 4 + 1-((( 7+ DirNew + (DirOld mod 4 + DirOld div 4)) mod 4 ) div 2)) mod 2 ;
      DirOld:=DirNew;
    end
    else
      j:=DirNew; }

    if OverlapRect(Engine.SurfaceRect, rect(x,y,x+31,y+31)) then
    begin
      if i=0 then j:=24 else j:=PicID[DirOld,DirNew];
      //if mPath.MaxPath-2-i < mPath.Green
      if mPath.CostPath[mPath.Path[i].X,mPath.Path[i].Y] <= mPath.Green
         then FImgPath.Draw(Engine.Surface, x, y, j)
         else FImgPath.Draw(Engine.Surface, x, y, j+25)
    end;

    DirOld:=DirNew;

  end;
end;
{----------------------------------------------------------------------------}
procedure DrawTile;
var
  i,j :integer;
  cx,cy: integer;
begin
  if mPL=-1 then exit;
  for cy:=EndY downto StartY do    //endy-1
   for cx:=StartX to EndX-1 do
    begin
      i:=cx-StartX+StartX_-DB;
      j:=cy-StartY+StartY_-DB;
      x:=cx*ChipWH+OfsX;
      y:=cy*ChipWH+OfsY;

      if (i<0) or (j<0) or (i>dimWH-1) or (j>dimWH-1) then
      begin
        cfg:=Abs(i) mod 8 + Abs(j) mod 8;
        if (i>=-1) and (j>=-1) and (i<=dimWH) and (j<=dimWH)
        then begin
        if (i=-1)    then cfg:=32+ (j mod 4);
        if (i=dimWH) then cfg:=24+ (j mod 4);
        if (j=-1)    then cfg:=20+ (i mod 4);
        if (j=dimWH) then cfg:=28+ (i mod 4);

        if (i=-1)    and (j=-1)    then cfg:=16;
        if (i=dimWH) and (j=-1)    then cfg:=17;
        if (i=-1)    and (j=dimWH) then cfg:=19;
        if (i=dimWH) and (j=dimWH) then cfg:=18;
        end;
        FImgEdg.Draw(Engine.Surface, x, y, cfg);
        continue;
      end

      else
      begin
        if not(PTiles[i,j,level].vis[mPL])
        then FImgFog.Draw(Engine.Surface, x, y, CheckVoisin(i,j,level)) ;
      end;
   end;
end;

begin
  level:=L;
  //dWidth:= (Engine.SurfaceRect.Right+ChipWH)  div ChipWH +1;
  //dHeight:=(Engine.SurfaceRect.Bottom+ChipWH) div ChipWH +1;
  dWidth:= (630 div ChipWH) +1;
  dHeight:=(570 div ChipWH) +1;
  
  _x:=Trunc(WorldX);
  _y:=Trunc(WorldY);

  OfsX:=_x mod ChipWH;
  OfsY:=_y mod ChipWH;

  StartX:=_x div ChipWH; StartX_:= 0;
  if StartX < 0 then
  begin StartX_:=-StartX; StartX:=0; end;

  StartY:=_y div ChipWH; StartY_:= 0;
  if StartY < 0 then
  begin StartY_:=-StartY; StartY:=0; end;

  EndX:=Min(StartX+MapWidth -StartX_, dWidth);
  EndY:=Min(StartY+MapHeight-StartY_, dHeight);

  DrawTile;
  if (not(mPlayers[mPL].isCPU) and mPath.refresh and (mPath.l=l)) then DrawPath;
end;

{----------------------------------------------------------------------------}
{ TGameBackground  }
{----------------------------------------------------------------------------}
function TGameBackground.GetBoundsRect: TRect;
begin
  Result:=Bounds(Trunc(WorldX),Trunc(WorldY),DL*MapWidth,DL*MapHeight);
end;
{----------------------------------------------------------------------------}
procedure SmoothResize(var Src, Dst: TDIB);
var
  x,y,xP,yP,yP2,xP2 :  Integer;
  Read,Read2        :  PByteArray;
  t,t3,t13,z,z2,iz2 :  Integer;
  pc                :  PBytearray;
  w1,w2,w3,w4       :  Integer;
  col1r,col1g,col1b,
  col2r,col2g,col2b:   byte;
begin
  xP2:=((src.Width-1) shl 15)div Dst.Width;
  yP2:=((src.Height-1)shl 15)div Dst.Height;
  yP:=0;
  for y:=0 to Dst.Height-1 do
  begin
    xP:=0;
    Read:=src.ScanLine[yP shr 15];
    if yP shr 16<src.Height-1
    then  Read2:=src.ScanLine[yP shr 15+1]
    else Read2:=src.ScanLine[yP shr 15];
    pc:=Dst.scanline[y];
    z2:=yP and $7FFF;
    iz2:=$8000-z2;
    for x:=0 to Dst.Width-1 do
    begin
      t:=xP shr 15;
      t3:=t*3;
      t13:=t3+3;
      Col1r:=Read[t3];
      Col1g:=Read[t3+1];
      Col1b:=Read[t3+2];
      Col2r:=Read2[t3];
      Col2g:=Read2[t3+1];
      Col2b:=Read2[t3+2];
      z:=xP and $7FFF;
      w2:=(z*iz2)shr 15;
      w1:=iz2-w2;
      w4:=(z*z2)shr 15;
      w3:=z2-w4;
      pc[x*3+2]:=(Col1b*w1+Read[t13+2]*w2+Col2b*w3+Read2[t13+2]*w4)shr 15;
      pc[x*3+1]:=(Col1g*w1+Read[t13+1]*w2+Col2g*w3+Read2[t13+1]*w4)shr 15;
      // (t+1)*3  is now t13
      pc[x*3]:=(Col1r*w1+Read2[t13]*w2+Col2r*w3+Read2[t13]*w4)shr 15;
      Inc(xP,xP2);
    end;
    Inc(yP,yP2);
  end;
end;
{----------------------------------------------------------------------------}
procedure TGameBackground.MakeMiniMap;
var
  TmpSurface: TDirectDrawSurface;
  NewGraphic: TDIB;
  Item: TPictureCollectionItem;

const
  MiniWidth= 144;
  MiniHeight=144;
 var
  id: integer;
begin
  TmpSurface:=TDirectDrawSurface.Create(Engine.Surface.DDraw);
  TmpSurface.SystemMemory:=true;
  TmpSurface.SetSize(MiniWidth, 2 * MiniHeight);

  NewGraphic:=TDIB.Create;
  TmpSurface.AssignTo(NewGraphic);
  TmpSurface.Free;

  id:=FImageList.Items.IndexOf('MiniMapGraphic');
  if id =-1
  then Item := TPictureCollectionItem.Create(FImageList.Items)
  else Item := FImageList.Items[id];
  Item.Name:='MiniMapGraphic';
  Item.SystemMemory:=true; //opmemory
  Item.Picture.Graphic := NewGraphic;
  Item.PatternHeight:=MiniHeight;
  Item.PatternWidth:=MiniWidth;
  Item.Transparent:=False;
  Item.Restore;
  gNavigator.Image:=Item;

  id:=FImageList.Items.IndexOf('TmpImage');
  if id =-1
  then Item := TPictureCollectionItem.Create(FImageList.Items)
  else Item := FImageList.Items[id];
  Item.Name:='TmpImage';
  Item.SystemMemory:=true; //opmemory
  Item.Picture.Graphic := NewGraphic;
  Item.PatternHeight:=MiniHeight;
  Item.PatternWidth:=MiniWidth;
  Item.Transparent:=false;
  Item.Restore;
  gNavigator.TmpImage:=Item;

  id:=FImageList.Items.IndexOf('Tmp2Image');
  if id =-1
  then Item := TPictureCollectionItem.Create(FImageList.Items)
  else Item := FImageList.Items[id];
  Item.Name:='Tmp2Image';
  Item.SystemMemory:=true; //opmemory
  Item.Picture.Graphic := NewGraphic;
  Item.PatternHeight:=MiniHeight;
  Item.PatternWidth:=MiniWidth;
  Item.Transparent:=false;
  Item.Restore;
  gNavigator.Tmp2Image:=Item;

  gNavigator.Radar:=FImageList.Items.Find('Radar');
  NewGraphic.free;
end;
{----------------------------------------------------------------------------}
procedure TGameBackground.DoDraw;
var
  _x, _y, cx, cy,i,j : Integer;
  StartX, StartY, EndX, EndY, StartX_, StartY_, OfsX, OfsY, dWidth, dHeight: Integer;
  t,u,m : integer;
  x,y:integer;
begin
  Engine.Surface.Canvas.Brush.Color:=$0080FFFF;

  //dWidth:= (Engine.SurfaceRect.Right+ChipWH)  div ChipWH +1;
  //dHeight:=(Engine.SurfaceRect.Bottom+ChipWH) div ChipWH +1;
  dWidth:= (630 div ChipWH) +1;
  dHeight:=(570 div ChipWH) +1;

  _x:=Trunc(WorldX);
  _y:=Trunc(WorldY);

  OfsX:=_x mod ChipWH;
  OfsY:=_y mod ChipWH;

  StartX:=_x div ChipWH; StartX_:= 0;
  if StartX < 0 then
  begin StartX_:=-StartX; StartX:=0; end;

  StartY:=_y div ChipWH; StartY_:= 0;
  if StartY < 0 then
  begin StartY_:=-StartY; StartY:=0; end;

  EndX:=Min(StartX+MapWidth -StartX_, dWidth);
  EndY:=Min(StartY+MapHeight-StartY_, dHeight);

  for cy:=EndY-1 downto StartY do
   for cx:=StartX to EndX-1 do
    begin
      i:=cx-StartX+StartX_-DB;
      j:=cy-StartY+StartY_-DB;
      if (i<0) or (j<0) or (i>dimWH-1) or (j>dimWH-1) then continue;
      //if not(PTiles[i,j,l].vis[mPL]) then continue;
      x:=cx*ChipWH+OfsX;
      y:=cy*ChipWH+OfsY;
      t:=pTiles[i,j,l].TR.t;
      m:=pTiles[i,j,l].TR.m;
      u:=4*pTiles[i,j,l].TR.u + m;
      Case t of
        0: FImgTer0.Draw(Engine.Surface, x, y, u);
        1: FImgTer1.Draw(Engine.Surface, x, y, u);
        2: FImgTer2.Draw(Engine.Surface, x, y, u);
        3: FImgTer3.Draw(Engine.Surface, x, y, u);
        4: FImgTer4.Draw(Engine.Surface, x, y, u);
        5: FImgTer5.Draw(Engine.Surface, x, y, u);
        6: FImgTer6.Draw(Engine.Surface, x, y, u);
        7: FImgTer7.Draw(Engine.Surface, x, y, u);
        8: FImgTer8.Draw(Engine.Surface, x, y, u);
        9: FImgTer9.Draw(Engine.Surface, x, y, u);
      end;

      if OpShowMapGrid then
      begin
        Engine.Surface.Canvas.FrameRect(rect(x,y,x+32,y+32));
        Engine.Surface.Canvas.Font.color:=ClBlack;
        Engine.Surface.Canvas.textout(x,y,format('%d %d',[i,j]));
        Engine.Surface.Canvas.release;
      end;

      if pTiles[i,j,l].RV.t>0 then
      begin
        m:=pTiles[i,j,l].RV.m; //4;
        u:=4*pTiles[i,j,l].RV.U+m;
        FImgRiver.Draw(Engine.Surface, x, y, u);
      end;

      if pTiles[i,j,l].RD.t>0 then
      begin
        t:=pTiles[i,j,l].RD.t;
        m:=pTiles[i,j,l].RD.m; //4;
        u:=4*pTiles[i,j,l].RD.u+m;
        Case t of
        1:FImgRoad1.Draw(Engine.Surface, x, y+16, u);
        2:FImgRoad2.Draw(Engine.Surface, x, y+16, u);
        3:FImgRoad3.Draw(Engine.Surface, x, y+16, u);
        //+ 16 met le bas du tile au milieu de la route
        end;
      end;
    end;
end;
{----------------------------------------------------------------------------}
constructor TGameBackground.Create(AParent:TSprite;ImageList: TDXImageList);
begin
  inherited Create(AParent);
  FImageList:=ImageList;
  DimWH:=mData.dim;
  MapWH:=ChipWH*(DB+DimWH+DB);
  SetMapSize(DB+DimWH+DB,DB+DimWH+DB);
  pTiles:=@mTiles;
  FImgTer0 :=FImageList.Items.Find('dirttl');
  FImgTer0.SystemMemory:=true;
  FImgTer1:= FImageList.Items.Find('sandtl');
  FImgTer1.SystemMemory:=true;
  FImgTer2:= FImageList.Items.Find('Grastl');
  FImgTer2.SystemMemory:=true;
  FImgTer3:= FImageList.Items.Find('snowtl');
  FImgTer3.SystemMemory:=true;
  FImgTer4:= FImageList.Items.Find('swmptl');
  FImgTer4.SystemMemory:=true;
  FImgTer5:= FImageList.Items.Find('rougtl');
  FImgTer5.SystemMemory:=true;
  FImgTer6:= FImageList.Items.Find('subbtl');
  FImgTer6.SystemMemory:=true;
  FImgTer7:= FImageList.Items.Find('lavatl');
  FImgTer7.SystemMemory:=true;
  FImgTer8:= FImageList.Items.Find('watrtl');
  FImgTer8.SystemMemory:=true;
  FImgTer9:= FImageList.Items.Find('rocktl');
  FImgTer9.SystemMemory:=true;
  FImgRiver:=FImageList.Items.Find('CLRRVR');
  FImgRiver.SystemMemory:=true;
  FImgRoad1:=FImageList.Items.Find('DIRTRD');
  FImgRoad1.SystemMemory:=true;
  FImgRoad2:=FImageList.Items.Find('GRAVRD');
  FImgRoad2.SystemMemory:=true;
  FImgRoad3:=FImageList.Items.Find('COBBRD');
  FImgRoad3.SystemMemory:=true;
  X:=0;
  Y:=0;
  Z:=0;
  Tile:=false;
  Collisioned:=false;
end;
{----------------------------------------------------------------------------}

end.
