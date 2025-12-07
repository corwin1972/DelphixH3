unit DXWImageSprite;
 //rng
interface

uses
  Windows, SysUtils, Classes, DXClass, DXDraws, DXSprite;

Type

  TDirChangedXY=record
    x   : double;
    y   : double;
    Dir : Byte;
  end;

  TWImageSprite = class(TImageSprite)
  private
    FDirection            : integer;
    FDestPointX           : double;
    FDestPointY           : double;
    FDestChipX            : integer;
    FDestChipY            : integer;
    FSelected             : boolean;
    FCanMove              : boolean;
    function GetChipX     : integer;
    function GetChipY     : integer;
    function GetCX        : double;
    function GetCY        : double;

  protected
    procedure SetDirection( Value : integer);
    function  TestCollision(Sprite: TSprite): Boolean; override;
    function  GetAngleToUnit( DestUnit : TImageSprite ):double; virtual;
    procedure CalculatePatternXYCount;

  public
    XCount,YCount         : integer;
    FChipW,FChipH         : integer;
    DirChangedXYArr       : Array of TDirChangedXY; //
    DirChangedXYCount     : integer;
    CurrentDirChangedXYId : integer;

    constructor Create(AParent: TSprite); override;

    property Direction : integer read FDirection write SetDirection;
    property DestPointX : Double read FDestPointX write FDestPointX;
    property DestPointY : Double read FDestPointY write FDestPointY;
    property DestChipX : integer read FDestChipX write FDestChipX;
    property DestChipY : integer read FDestChipY write FDestChipY;

    Property ChipX : integer read GetChipX;
    Property ChipY : integer read GetChipY;

    Property cX : Double read GetCX;
    Property cY : Double read GetCY;

    property Selected : Boolean read FSelected write FSelected;
    property CanMove  : Boolean read FCanMove  write FCanMove;

  end;

implementation

Uses Math;
{------------------------  TWImageSprite ---------------------------- }

constructor TWImageSprite.Create(AParent: TSprite);
begin
 inherited Create(AParent);
end;

Procedure TWImageSprite.CalculatePatternXYCount;
begin
  XCount:= Image.Picture.Width div (Image.PatternWidth+Image.SkipWidth);
  YCount:= Image.Picture.Height div (Image.PatternHeight+Image.SkipHeight);
end;

Procedure TWImageSprite.SetDirection( Value : Integer);
Var
  PatternY : integer;
const
  DirToPatternY : Array[0..7] of byte=(0,2,4,6,7,1,3,5);
begin
  if Value=255 then exit;
  if Value=FDirection then exit;
  FDirection:=Value;
  PatternY:=DirToPatternY[FDirection];
  AnimStart:=XCount*PatternY;
end;

function TWImageSprite.TestCollision(Sprite: TSprite): Boolean;
var
  R1,R2 : TRect;
begin
  if Sprite is TWImageSprite then
  begin
    With Sprite do
      R1:=Bounds(BoundsRect.Left+Width div 4,BoundsRect.Top+Height div 2,Width div 2,Height div 3);
    R2:=Bounds(BoundsRect.Left+Width div 4,BoundsRect.Top+Height div 2,Width div 2,Height div 3);
    Result := OverlapRect(R1,R2);
  end;
end;

function TWImageSprite.GetChipX: integer;
begin
  Result:=Trunc((X+Width div 2 )/FChipW);
end;

function TWImageSprite.GetChipY: integer;
begin
  Result:=Trunc((Y+3*(Height div 4))/FChipH);
end;

function TWImageSprite.GetCX: Double;
begin
  Result:=(X+Width div 2 );
end;

function TWImageSprite.GetCY: Double;
begin
  //Result:=(Y+Height div 2);
  Result:=(Y+3*(Height div 4));
end;


function TWImageSprite.GetAngleToUnit(DestUnit: TImageSprite): double;
var
  dx,dy: double;
begin
  dx:=DestUnit.x-x;
  dy:=DestUnit.y-y;
  Result:=ArcTan2(dx,dy);
end;

end.
