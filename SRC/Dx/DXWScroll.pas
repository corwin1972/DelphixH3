unit DXWScroll;

interface
uses
  Windows,Classes,Graphics,Controls,Forms,ExtCtrls,SysUtils,
  DXClass, DXDraws ,DXWControls;

type
  TDXWScroll = class (TDXWObject)
  Private
    FImage        : TPictureCollectionItem;
    FBtn1Image    : TPictureCollectionItem;
    FBtn2Image    : TPictureCollectionItem;
    FThumbImage   : TPictureCollectionItem;
    FSurface      : TDirectDrawSurface;
    FBtn1         : TDXWButton;
    FBtn2         : TDXWButton;
    FThumb        : TDXWImageObject;
    ScrollingRect : TRect;
    FMax          : integer;
    FMin          : integer;
    FPosition     : integer;
    FObjectList   : TDXWObjectList;
    FOnChange     : TNotifyEvent;

    procedure SetSurface(Value: TDirectDrawSurface);
    Procedure Change;

    Procedure CorrectThumbPosition;
    procedure Btn1Click(sender: TObject);
    procedure Btn2Click(sender: TObject);
    procedure SetBtn1Image(const Value: TPictureCollectionItem);
    procedure SetBtn2Image(const Value: TPictureCollectionItem);
    procedure SetThumbImage(const Value: TPictureCollectionItem);
    procedure SetImage(const Value: TPictureCollectionItem);
    function  GetPosition: integer;
    procedure SetPosition(const Value: integer);

 Protected
    Procedure DoDraw;override;
    function  GetDrawImageIndex: Integer;virtual;
    procedure SetBounds;override;
    procedure SetMouseInControl(const Value: Boolean);override;

    Procedure MouseDown(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);override;
    Procedure MouseUp(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);override;
    Procedure MouseMove(Shift:TShiftState;X,Y:Integer);override;

 Public
    Constructor Create(AOwner : TObject);override ;
    Procedure AllUp;
    Destructor  Destroy;override;

    property Image      : TPictureCollectionItem read FImage write SetImage;
    property Btn1Image  : TPictureCollectionItem read FBtn1Image write  SetBtn1Image;
    property Btn2Image  : TPictureCollectionItem read FBtn2Image write  SetBtn2Image;
    property ThumbImage : TPictureCollectionItem read FThumbImage write SetThumbImage;

    property Surface : TDirectDrawSurface read FSurface write SetSurface;

    property Max : integer read FMax write FMax;
    property Min : integer read FMin write FMin;
    property Position : integer read GetPosition write SetPosition;

    property OnChange : TNotifyEvent read FOnChange write FOnChange;

end;


type
  TDXWHzScroll = class (TDXWObject)
  Private
    FImage        : TPictureCollectionItem;
    FBtn1Image    : TPictureCollectionItem;
    FBtn2Image    : TPictureCollectionItem;
    FThumbImage   : TPictureCollectionItem;
    FSurface      : TDirectDrawSurface;
    FBtn1         : TDXWButton;
    FBtn2         : TDXWButton;
    FThumb        : TDXWImageObject;
    ScrollingRect : TRect;
    FMax          : integer;
    FMin          : integer;

    FPosition     : integer;
    FObjectList   : TDXWObjectList;
    FOnChange     : TNotifyEvent;

    procedure SetSurface(Value: TDirectDrawSurface);
    Procedure Change;
    Procedure CorrectThumbPosition;
    Procedure Btn1click(sender: TObject);
    Procedure Btn2click(sender: TObject);
    procedure SetBtn1Image(const Value: TPictureCollectionItem);
    procedure SetBtn2Image(const Value: TPictureCollectionItem);
    procedure SetThumbImage(const Value: TPictureCollectionItem);
    procedure SetImage(const Value: TPictureCollectionItem);
    function  GetPosition: integer;
    procedure SetPosition(const Value: integer);

 Protected
    Procedure DoDraw;override;
    function  GetDrawImageIndex: Integer;virtual;
    procedure SetBounds;override;
    procedure SetMouseInControl(const Value: Boolean);override;

    Procedure MouseUp(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);override;
    Procedure MouseDown(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);override;
    Procedure MouseMove(Shift:TShiftState;X,Y:Integer);override;

 Public
    FMinChange    : integer;
    Constructor Create(AOwner : TObject);override ;
    Destructor  Destroy;override;

    Procedure AllUp;
    property Image      : TPictureCollectionItem read FImage write SetImage;
    property Btn1Image  : TPictureCollectionItem read FBtn1Image write  SetBtn1Image;
    property Btn2Image  : TPictureCollectionItem read FBtn2Image write  SetBtn2Image;
    property ThumbImage : TPictureCollectionItem read FThumbImage write SetThumbImage;

    property Surface : TDirectDrawSurface read FSurface write SetSurface;

    property Max : integer read FMax write FMax;
    property Min : integer read FMin write FMin;
    property Position : integer read GetPosition write SetPosition;

    property OnChange : TNotifyEvent read FOnChange write FOnChange;

end;

implementation



/////////////////////////////////////////////////////////////
Constructor TDXWScroll.Create(AOwner : TObject);
begin
 inherited;// Create(AOwner);
 MouseCaptured:=true;
 FObjectList:=TDXWObjectList.Create;

 FBtn1 :=TDXWButton.Create(Self);
 FBtn2 :=TDXWButton.Create(Self);
 FThumb:=TDXWImageObject.Create(Self);
 FThumb.MouseCaptured:=true;

 FObjectList.Add(FBtn1);
 FObjectList.Add(FBtn2);
 FObjectList.Add(FThumb);
 FBtn1.OnClick:=Btn1Click;
 FBtn2.OnClick:=Btn2Click;
 FMax:=100;
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.AllUp;
begin;
  FBtn1.Down:=false;
  FBtn2.Down:=false;
  FThumb.Down:=false;
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.DoDraw;
var
  ImageIndex : integer;
begin;
  if Not Visible then Exit;
  ImageIndex := GetDrawImageIndex;
  Image.Draw( FSurface, Left, Top, ImageIndex);
  FObjectList.DoDraw;
end;
{----------------------------------------------------------------------------}
Destructor  TDXWScroll.Destroy;
begin
  FObjectList.Free;
  inherited Destroy;
end;
{----------------------------------------------------------------------------}
Procedure TDXWScroll.Btn1Click(Sender:TObject);
begin
  Position:=Position-1;
  Change;
end;
{----------------------------------------------------------------------------}
Procedure TDXWScroll.Btn2Click(Sender:TObject);
begin
  Position:=Position+1;
  Change;
end;
{----------------------------------------------------------------------------}
Procedure TDXWScroll.MouseUp(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
  inherited;// MouseUp(Button,Shift,X,Y);
  FObjectList.MouseUp(Button,Shift,X,Y);
end;
{----------------------------------------------------------------------------}
Procedure TDXWScroll.MouseDown(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);
var
  OldTop : integer;
begin
  inherited;// MouseDown(Button,Shift,X,Y);
  FObjectList.MouseDown(Button,Shift,X,Y);
  //if  FThumb.Down = true then
  if not((FBtn1.Down) or (FBtn2.Down)) then
  begin
    OldTop:=FThumb.Top;
    FThumb.Top:=Y-FThumb.dClickedPoint.y;
    CorrectThumbPosition;
    if FThumb.Top<>OldTop then Change;
  end;
end;
{----------------------------------------------------------------------------}
Procedure TDXWScroll.MouseMove(Shift:TShiftState;X,Y:Integer);
var
  OldTop : integer;
begin
  inherited;
  FObjectList.MouseMove(Shift,X,Y);

  if ( FThumb.Down )and( ssLeft in Shift )then
  begin
    OldTop:=FThumb.Top;
    FThumb.Top:=Y-FThumb.dClickedPoint.y;
    CorrectThumbPosition;
    if FThumb.Top<>OldTop then Change;
  end;
end;
{----------------------------------------------------------------------------}
Procedure TDXWScroll.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.SetSurface(Value: TDirectDrawSurface);
begin
  FSurface := Value;
  FBtn1.Surface:=Value;
  FBtn2.Surface:=Value;
  FThumb.Surface:=Value;
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.SetBtn1Image(const Value: TPictureCollectionItem);
begin
  FBtn1Image := Value;
  FBtn1.Image:= Value;
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.SetBtn2Image(const Value: TPictureCollectionItem);
begin
  FBtn2Image := Value;
  FBtn2.Image:= Value;
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.SetThumbImage(const Value: TPictureCollectionItem);
begin
  FThumbImage := Value;
  FThumb.Image:= Value;
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.SetBounds;
begin
  inherited;
  FBtn1.Left:=Left;
  FBtn1.Top:=Top;
  FBtn2.Left:=Left;
  FBtn2.Top:=Top+Height-FBtn2.Height;
  FThumb.Left:=Left;
  FThumb.Top:=Top+FBtn1.Height;

  ScrollingRect:=Bounds(Left,Top+FBtn1.Height,Width,Height-FBtn1.Height-FBtn2.Height-FThumb.Height)
end;
{----------------------------------------------------------------------------}
function TDXWScroll.GetDrawImageIndex: Integer;
begin
  Result:=0;
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.SetImage(const Value: TPictureCollectionItem);
begin
  FImage := Value;
  Width:=Value.Width;
  Height:=Value.Height;
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.SetMouseInControl(const Value: Boolean);
var
  i : integer;                       
begin
  inherited;

  if Not MouseInControl then
  For i:=0 to FObjectList.Count-1 do
    FObjectList.Items[i].MouseInControl:=false;
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.CorrectThumbPosition;
begin
  if FThumb.Top>ScrollingRect.Bottom
  then FThumb.Top:=ScrollingRect.Bottom;

  if FThumb.Top<ScrollingRect.Top
  then FThumb.Top:=ScrollingRect.Top;

  if Max=Min
  then FThumb.Top:=ScrollingRect.Top;
end;
{----------------------------------------------------------------------------}
function TDXWScroll.GetPosition: integer;
Var
  ThumbRange : integer;
  PosRange   : integer;
  PosShift   : integer;
  ThumbShift : integer;
begin
  ThumbRange:=ScrollingRect.Bottom-ScrollingRect.Top;
  PosRange:=FMax-FMin;
  ThumbShift:=FThumb.Top-Top-FBtn1.Height;
  PosShift:=Round(ThumbShift*(PosRange/ThumbRange));
  Result:=FMin+PosShift;
end;
{----------------------------------------------------------------------------}
procedure TDXWScroll.SetPosition(const Value: integer);
var
  ThumbRange : integer;
  PosRange   : integer;
  PosShift   : integer;
  ThumbShift : integer;
begin
  if FPosition=Value then Exit;
  if Value < FMin then exit;
  if Value > FMax then exit;
  FPosition:=Value; // check why it is needed
  ThumbRange:=ScrollingRect.Bottom-ScrollingRect.Top;
  PosRange:=FMax-FMin;
  PosShift:=Value-FMin;
  ThumbShift:=Round(PosShift*(ThumbRange/PosRange));
  FThumb.Top:=Top+FBtn1.Height+ThumbShift;
end;
{----------------------------------------------------------------------------}


/////////////////////////////////////////////////////////////
Constructor TDXWHzScroll.Create(AOwner : TObject);
begin
  inherited;
  MouseCaptured:=true;
  FObjectList:=TDXWObjectList.Create;

  FBtn1 :=TDXWButton.Create(Self);
  FBtn2 :=TDXWButton.Create(Self);
  FThumb:=TDXWImageObject.Create(Self);
  FThumb.MouseCaptured:=true;

  FObjectList.Add(FBtn1);
  FObjectList.Add(FBtn2);
  FObjectList.Add(FThumb);
  FBtn1.OnClick:=Btn1Click;
  FBtn2.OnClick:=Btn2Click;
  FMinChange:=1;
  FMin:=0;
  FMax:=100;
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.AllUp;
begin;
  FBtn1.Down:=false;
  FBtn2.Down:=false;
  FThumb.Down:=false;
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.DoDraw;
var
  ImageIndex : integer;
begin;
  if Not Visible then Exit;
  ImageIndex := GetDrawImageIndex;
  Image.Draw( FSurface, Left, Top, ImageIndex);
  FObjectList.DoDraw;
end;
{----------------------------------------------------------------------------}
Destructor  TDXWHzScroll.Destroy;
begin
  FObjectList.Free;
  inherited Destroy;
end;
{----------------------------------------------------------------------------}
Procedure TDXWHzScroll.Btn1Click(Sender:TObject);
begin
  Position:=Position-FMinChange;
  Change;
end;
{----------------------------------------------------------------------------}
Procedure TDXWHzScroll.Btn2Click(Sender:TObject);
begin
  Position:=Position+FMinChange;
  Change;
end;
{----------------------------------------------------------------------------}
Procedure TDXWHzScroll.MouseUp(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
  inherited;
  FObjectList.MouseUp(Button,Shift,X,Y);
end;
{----------------------------------------------------------------------------}
Procedure TDXWHzScroll.MouseDown(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);
var
  OldLeft : integer;
begin
  inherited;
  FObjectList.MouseDown(Button,Shift,X,Y);
  if not((FBtn1.MouseInControl) or (FBtn2.MouseInControl)) then
  begin
    OldLeft:=FThumb.Left;
    FThumb.Left:=left+self.dClickedPoint.x;
    CorrectThumbPosition;
    if FThumb.Left<>OldLeft then Change;
  end;
end;
{----------------------------------------------------------------------------}
Procedure TDXWHzScroll.MouseMove(Shift:TShiftState;X,Y:Integer);
var
  OldLeft : integer;
begin
  inherited;
  FObjectList.MouseMove(Shift,X,Y);

  if ( FThumb.Down )and( ssLeft in Shift )then
  begin
    OldLeft:=FThumb.Left;
    FThumb.Left:=X-FThumb.dClickedPoint.x;
    CorrectThumbPosition;
    if FThumb.Left<>OldLeft then Change;
  end;
end;
{----------------------------------------------------------------------------}
Procedure TDXWHzScroll.Change;
begin
 if Assigned(FOnChange) then FOnChange(Self);
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.SetSurface(Value: TDirectDrawSurface);
begin
  FSurface:=Value;
  FBtn1.Surface:=Value;
  FBtn2.Surface:=Value;
  FThumb.Surface:=Value;
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.SetBtn1Image(const Value: TPictureCollectionItem);
begin
  FBtn1Image := Value;
  FBtn1.Image:= Value;
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.SetBtn2Image(const Value: TPictureCollectionItem);
begin
  FBtn2Image := Value;
  FBtn2.Image:= Value;
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.SetThumbImage(const Value: TPictureCollectionItem);
begin
  FThumbImage := Value;
  FThumb.Image:= Value;
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.SetBounds;
begin
  inherited;
  FBtn1.Left:=Left;
  FBtn1.Top:=Top;
  FBtn2.Top:=top;
  FBtn2.Left:=Left+Width-FBtn2.Width;
  FThumb.Top:=top;
  FThumb.Left:=Left+FBtn1.Width;

  ScrollingRect:=Bounds(Left+FBtn1.Width,Top,Width-FBtn1.Width-FBtn2.Width-FThumb.Width,Height);
end;
{----------------------------------------------------------------------------}
function TDXWHzScroll.GetDrawImageIndex: Integer;
begin
  Result:=0;
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.SetImage(const Value: TPictureCollectionItem);
begin
  FImage := Value;
  Width:=Value.Width;
  Height:=Value.Height;
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.SetMouseInControl(const Value: Boolean);
Var
  i : integer;
begin
  inherited;
  if Not MouseInControl then
  For i:=0 to FObjectList.Count-1 do
    FObjectList.Items[i].MouseInControl:=false;
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.CorrectThumbPosition;
var
  ThumbRange : integer;
  PosRange   : integer;
  PosShift   : integer;
  ThumbShift : integer;

begin
  if FThumb.Left>ScrollingRect.Right
    then FThumb.Left:=ScrollingRect.Right;

  if FThumb.Left<ScrollingRect.Left
    then FThumb.Left:=ScrollingRect.Left;

  ThumbRange:=ScrollingRect.Right-ScrollingRect.Left;
  PosRange:=FMax-FMin;
  PosShift:=Position-FMin;
  ThumbShift:=Round(PosShift*(ThumbRange/PosRange));
  FThumb.Left:=Left+FBtn1.Width+ThumbShift;
end;
{----------------------------------------------------------------------------}
function TDXWHzScroll.GetPosition: integer;
var
  ThumbRange : integer;
  PosRange   : integer;
  PosShift   : integer;
  ThumbShift : integer;
begin
  ThumbRange:=ScrollingRect.right-ScrollingRect.Left;
  PosRange:=FMax-FMin;
  ThumbShift:=FThumb.Left-Left-FBtn1.Width;
  PosShift:=FMinchange * Round(ThumbShift*(PosRange/ThumbRange) / Fminchange);
  Result:=FMin+PosShift;
end;
{----------------------------------------------------------------------------}
procedure TDXWHzScroll.SetPosition(const Value: integer);
var
  ThumbRange : integer;
  PosRange   : integer;
  PosShift   : integer;
  ThumbShift : integer;
begin
  if Position=Value then Exit;
  if Value < Fmin then exit;
  if Value > Fmax then exit;
  FPosition:=Value;
  ThumbRange:=ScrollingRect.Right-ScrollingRect.Left;
  PosRange:=FMax-FMin;
  PosShift:=Value-FMin;
  ThumbShift:=Round(PosShift*(ThumbRange/PosRange));
  FThumb.Left:=Left+FBtn1.Width+ThumbShift;
end;
{----------------------------------------------------------------------------}
end.
