unit DXWNavigator;

interface

uses
  Graphics,Windows, Messages, SysUtils, Classes, ExtCtrls, Controls,
  DXClass, DXDraws, DXSprite,DIB;

Type

TDXWCustomNavigator = class
  private

    FInitLeft    : Integer;
    FInitTop     : Integer;
    FInitWidth   : Integer;
    FInitHeight  : Integer;
    FVisible     : Boolean;

    FLeft     : Integer;
    FTop      : Integer;
    FWidth    : Integer;
    FHeight   : Integer;

    FMapW,FMapH   : Integer;

    FGidRect      : TRect;   // in Screen CS
    FGidW,FGidH   : Integer;
    FGidX,FGidY   : Integer; // in OutRect CS

    FkX,FkY,Fk    : Double;

    FGidClicked   : Boolean;
    FClicked      : Boolean;

    procedure SetInitHeight(const Value: Integer);
    procedure SetInitWidth(const Value: Integer);

    procedure SetMapH(const Value: Integer);
    procedure SetMapW(const Value: Integer);
    procedure Calculate;

  protected
    procedure DoDraw ; virtual; abstract;
    function  GetBoundsRect : TRect;

    function MapXToX(AMapX : Double):Integer;
    function MapYToY(AMapY : Double):Integer;
    function XToMapX(AX : Integer ) : Double;
    function YToMapY(AY : Integer ) : Double;

  public

    constructor Create;
    destructor Destroy; override;

    property BoundsRect: TRect read GetBoundsRect;

    property InitLeft   : Integer write FInitLeft;
    property InitTop    : Integer write FInitTop;
    property InitWidth  : Integer write SetInitWidth;
    property InitHeight : Integer write SetInitHeight;

    property MapW    : Integer write SetMapW;
    property MapH    : Integer write SetMapH;

    property GidRect : TRect read FGidRect;

    property Visible : Boolean read FVisible write FVisible;

  end;


TDXWNavigator = class (TDXWCustomNavigator)
  private
    FL: byte;
    FSpriteEngine : TDXSpriteEngine;
    FImageList:TDXImageList;
    FImage: TPictureCollectionItem;
    FRadar: TPictureCollectionItem;
    FRadarTag: byte;
    FTmpImage,
    FTmp2Image: TPictureCollectionItem;
    FShield:  TPictureCollectionItem;
    procedure SetSpriteEngine(Value: TDXSpriteEngine);
    procedure SetLevel(Value: byte);
  protected
    procedure ScrollTo(X,Y : Integer);
    procedure DoDraw; override;
    function DarkenColor(c:integer):TColor;
  public
    Refresh: boolean;
    RadarSize: real;
    constructor Create(ASpriteEngine: TDXSpriteEngine; aSize: integer; ImageList:TDXimageList);
    procedure DrawSelf;
    procedure NavigatorMouseMove(Shift: TShiftState;Const X,Y: Integer);
    procedure NavigatorMouseDown(Shift: TShiftState;Const X, Y: Integer);
    procedure NavigatorMouseUp(Shift: TShiftState;Const X, Y: Integer);
    destructor Destroy; override;

    property L: byte read FL write SetLevel;
    property Radar: TPictureCollectionItem read FRadar write FRadar;
    property RadarTag: byte read FRadarTag write FRadarTag;
    property Image: TPictureCollectionItem read FImage write FImage;
    property TmpImage: TPictureCollectionItem read FTmpImage write FTmpImage;
    property Tmp2Image: TPictureCollectionItem read FTmp2Image write FTmp2Image;
    property SpriteEngine: TDXSpriteEngine write SetSpriteEngine;
  end;

implementation

uses Math, UMain,  DXWGameSprite, UMap, UType;

{ TDXWCustomNavigator }

{----------------------------------------------------------------------------}
constructor TDXWCustomNavigator.Create;
begin
  inherited Create;
  FInitWidth:=0;
  FInitHeight:=0;
  FMapW:=0;
  FMapH:=0;
  FkX:=0;
  FkY:=0;
  Fk :=0;
  FVisible:=true;
  FGidClicked:=false;
  FClicked:=false;
end;
{----------------------------------------------------------------------------}
destructor TDXWCustomNavigator.Destroy;
begin
  inherited Destroy;
end;
{----------------------------------------------------------------------------}
function TDXWCustomNavigator.GetBoundsRect: TRect;
begin
 //Result := Bounds(FLeft+40,FTop+40,FWidth-80,FHeight-80);
  Result := Bounds(FLeft,FTop,FWidth,FHeight);
end;
{----------------------------------------------------------------------------}
function TDXWCustomNavigator.MapXToX(AMapX: Double): Integer;
begin
end;
{----------------------------------------------------------------------------}
function TDXWCustomNavigator.MapYToY(AMapY: Double): Integer;
begin
end;
{----------------------------------------------------------------------------}
procedure TDXWCustomNavigator.Calculate;
begin
  if ((FInitHeight=0) or (FMapH=0) or (FInitWidth=0) or (FMapW=0))  then Exit;

  FkY:=FInitHeight/FMapH;
  FkX:=FInitWidth/FMapW;
  Fk:=min(FkX,FkY);

  FWidth:=Trunc(Fk*FMapW);
  FHeight:=Trunc(Fk*FMapH);

  FLeft:=FInitLeft+(FInitWidth-FWidth)div 2;
  FTop:=FInitTop+(FInitHeight-FHeight)div 2;
end;
{----------------------------------------------------------------------------}
procedure TDXWCustomNavigator.SetInitHeight(const Value: Integer);
begin
  FInitHeight:=Value;
  Calculate;
end;
{----------------------------------------------------------------------------}
procedure TDXWCustomNavigator.SetMapH(const Value: Integer);
begin
  FMapH:=Value;
  Calculate;
end;
{----------------------------------------------------------------------------}
procedure TDXWCustomNavigator.SetMapW(const Value: Integer);
begin
  FMapW:=Value;
  Calculate;
end;
{----------------------------------------------------------------------------}
procedure TDXWCustomNavigator.SetInitWidth(const Value: Integer);
begin
  FInitWidth:=Value;
  Calculate;
end;
{----------------------------------------------------------------------------}
function TDXWCustomNavigator.XToMapX(AX: Integer): Double;
begin
end;
{----------------------------------------------------------------------------}
function TDXWCustomNavigator.YToMapY(AY: Integer): Double;
begin
end;


{ TDXWNavigator }

constructor TDXWNavigator.Create(ASpriteEngine: TDXSpriteEngine; aSize: integer; ImageList:TDXImageList);
begin
  inherited Create;
  FImageList:=ImageList;
  FL:=0;
  FShield:=FImageList.Items.Find('AISHIELD');
  RadarSize:=144 / aSize;
  case aSize of
    36 :RadarTag:=4;
    72 :RadarTag:=3;
    108:RadarTag:=2;
    144:RadarTag:=1;
  end;
  InitLeft:=  630-trunc(RadarSize*10);
  InitTop:=    26-trunc(RadarSize*10);
  InitWidth:= 144+trunc(RadarSize*20);
  InitHeight:=144+trunc(RadarSize*20);
  MapW:=MapWH;
  MapH:=MapWH;
  SpriteEngine:=aSpriteEngine;
  Refresh:=true;
end;
{----------------------------------------------------------------------------}
function TDXWNavigator.DarkenColor(c:integer):TColor;
begin
  c:=c+$00111111;
  result:=FImage.PatternSurfaces[0].colorMatch(c);
end;
{----------------------------------------------------------------------------}
procedure TDXWNavigator.DoDraw;
var
  x,y,i,pid       : integer;
  r: real;
  obX: TObjIndex;
  SpriteR : TRect;
  clMatch:  Array[-1..MAX_PLAYER-1] of TColor;
const
  plColor:  Array [-1..MAX_PLAYER-1] of integer
      =(clGray,clRed,$00FF3151,$0052759C,$00299642,$000082FF,$00A52C8C,$00A59A08,$008C79C6);
  TerColor: array [0..9] of integer
      =($000F3F50,$008FCFDF,$00004000,$00C0B0C0,$006F804F,$00307080,$00003080,$004F4F4F,$0090500F,clBlack);

begin
  r:=RadarSize;
  if Not FVisible then Exit;

  FGidX:=Trunc(Abs(FSpriteEngine.Engine.X*Fk));
  FGidY:=Trunc(Abs(FSpriteEngine.Engine.Y*Fk));
  FGidRect:=Bounds(FLeft+FGidX,FTop +FGidY,FGidW,FGidH);

  with FSpriteEngine.DXDraw do
  begin
    //if mData.allblack then
    if (mPL<>hPL) or (mData.allblack) then
    begin
      FShield.Draw(FSpriteEngine.Engine.Surface, FLeft+trunc(10*r),FTop+trunc(10*r), 0); // change this
      exit;
    end;

    if self.refresh then
    begin
      for i:=-1 to MAX_PLAYER-1 do
        ClMatch[i]:=FImage.PatternSurfaces[0].colorMatch(plColor[i]);
      FImage.Draw(FTmpImage.PatternSurfaces[0],0,0,l);
      for x:=0 to mData.dim-1 do
        for y:=0 to mData.dim-1 do
        begin
          SpriteR:=Rect(trunc(r*x),trunc(r*y),trunc(r*x+r),trunc(r*y+r));
          with  FTmpImage.PatternSurfaces[0] do
          begin
            if  mTiles[x,y,l].vis[mPL]=false
            then
              FillRect(SpriteR,DxBlack) //ColorMatch(clBlack))
            else
              begin
                obX:=mTiles[x,y,l].obX;
                if obX.t <> 0 then
                begin
                  if obX.t=OB34_Hero then
                  pid:=mHeros[mObjs[obX.oid].v].pid
                  else
                  pid:=mObjs[obX.oid].pid;
                  if pid <> -2
                    then FillRect(SpriteR,ClMatch[pid])
                    else FillRect(SpriteR,DarkenColor(TerColor[mTiles[x,y,l].TR.t]));  // pour level zero ???
               end
               else
               FillRect(SpriteR,ColorMatch(TerColor[mTiles[x,y,l].TR.t]));

          end;
        end;
      end;
      self.Refresh:=false;
    end;

    FTmpImage.Draw(FTmp2Image.PatternSurfaces[0],0,0,0);
    FRadar.Draw(FTmp2Image.PatternSurfaces[0],FGidX-round(r*10),FGidY-round(r*10),FRadarTag);
    FTmp2Image.Draw(Surface,FLeft+trunc(10*r),FTop+trunc(10*r),0);
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXWNavigator.DrawSelf;
begin
  DoDraw;
end;
{----------------------------------------------------------------------------}
procedure TDXWNavigator.SetLevel(Value: byte);
begin
  FL:=Value;
  Refresh:=true;
end;
{----------------------------------------------------------------------------}
procedure TDXWNavigator.SetSpriteEngine(Value: TDXSpriteEngine);
begin
  FSpriteEngine:=Value;
  FGidW:=trunc(600* Fk); //Trunc(FSpriteEngine.Engine.Width*Fk);   RadarView show this part of engine
  FGidH:=trunc(554* Fk); //Trunc(FSpriteEngine.Engine.Height*Fk);  RadarView show this part of engine
end;
{----------------------------------------------------------------------------}
procedure TDXWNavigator.ScrollTo( X,Y : Integer);
Var
 eX,eY: Double;
 r:  real;
begin
  r:=RadarSize;
  if ((X < FLeft+trunc(10*r)) or (X > Fleft-trunc(10*r)+Fwidth) or (Y < Ftop+trunc(10*r)) or (Y> Ftop+fHeight-trunc(10*r))) then exit;
  eX:=( X-FLeft-(FGidW div 2))/Fk;
  eY:=( Y-FTop-(FGidH div 2) )/Fk;

  //if eX>FMapW then eX:=FMapW;// working
  //if eY>FMapH then eY:=FMapH;// without it !!! ???
  FSpriteEngine.Engine.X:=-eX;
  FSpriteEngine.Engine.y:=-eY;
  //if (ssLeft in Shift) then FGidClicked := TRUE;

end;
{----------------------------------------------------------------------------}
procedure TDXWNavigator.NavigatorMouseDown(Shift: TShiftState; Const X, Y: Integer);
begin
  if PointInRect(Point(X,Y),BoundsRect)then
  begin
    FClicked:=true;
    ScrollTo(X,Y);
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXWNavigator.NavigatorMouseMove(Shift: TShiftState;Const X,Y: Integer);
begin
  if FClicked then
  begin
    ScrollTo(X,Y);
  end
end;
{----------------------------------------------------------------------------}
procedure TDXWNavigator.NavigatorMouseUp(Shift: TShiftState;Const X, Y: Integer);
begin
  FGidClicked:=false;
  FClicked:=false;
end;
{----------------------------------------------------------------------------}
destructor TDXWNavigator.Destroy;
begin
  //MiniMapGraphic.Free;
  inherited Destroy;
end;
{----------------------------------------------------------------------------}

end.
