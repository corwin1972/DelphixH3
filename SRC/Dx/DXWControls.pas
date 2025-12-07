unit DXWControls;

interface
uses
  Windows, SysUtils, Classes, Controls, Contnrs, Graphics ,Dialogs,
  DXClass, DXDraws, UConst ;


Type

////////////////////////////////////////////////////////////////////////////////
TDXWObject = class
  private
    FDxObjectType: string;
    FMouseInControl: Boolean;
    FFocused       : Boolean;
    FGroupIndex    : Integer;
    FDown          : Boolean;
    FCanHighLighted: Boolean;

    FLeft          : Integer;
    FTop           : Integer;
    FZ             : integer;
    FWidth         : Integer;
    FHeight        : Integer;
    FVisible       : Boolean;
    FEnabled       : Boolean;
    FMouseCaptured : boolean;
    FdClickedPoint  : TPoint;

    FOnMouseUp     : TMouseEvent;
    FOnMouseDown   : TMouseEvent;
    FOnMouseMove   : TMouseMoveEvent;
    FOnClick       : TNotifyEvent;
    FOnClickR      : TNotifyEvent;
    FOnKeyDown     : TKeyEvent;
    FOnKeyUp       : TKeyEvent;
    FOnKeyPress    : TKeyPressEvent;

    FName          : String;
    FFont          : TFont;
    FTag           : Integer;
    FOwner         : TObject;
    FBoundsRect    : TRect;

    procedure SetHeight(const Value: Integer);
    procedure SetLeft(const Value: Integer);
    procedure SetTop(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    procedure SetBoundsRect(const Value: TRect);
  protected
    FText: String;
    function  GetBoundsRect: TRect;
    procedure SetMouseInControl(const Value: Boolean);virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyUp(var Key: Word; Shift: TShiftState);virtual;
    procedure KeyPress(var Key : char); virtual;
    procedure FontChanged(Sender: TObject); virtual;abstract;
    procedure SetBounds; virtual;

  public
    Selected: boolean;
    CanCheck: boolean;
    ListID: integer;
    constructor Create(AOwner:TObject); virtual;
    destructor Destroy; override;
    procedure DoDraw;virtual;abstract;
    property Owner       : TObject read FOwner write FOwner;
    property MouseInControl : Boolean read FMouseInControl write SetMouseInControl;
    property Focused     : Boolean read FFocused write FFocused;
    property Down        : Boolean read FDown write FDown default False;
    property Visible     : Boolean read FVisible write FVisible;
    property Enabled     : Boolean read FEnabled write FEnabled;
    property CanHighLighted : Boolean read FCanHighLighted write FCanHighLighted;
    property MouseCaptured  : Boolean read FMouseCaptured write FMouseCaptured default False;
    property dClickedPoint  : TPoint read FdClickedPoint;

    property Tag        : Integer read FTag write FTag default 0;
    property GroupIndex : Integer read FGroupIndex write FGroupIndex default 0;
    property Name       : String read FName write FName;
    property Font       : TFont read FFont write FFont;
    property BoundsRect : TRect  read FBoundsRect write SetBoundsRect;

    property Z       : Integer read FZ write FZ default 0;
    property Left    : Integer read FLeft write SetLeft;
    property Top     : Integer read FTop write SetTop;
    property Width   : Integer read FWidth write SetWidth;
    property Height  : Integer read FHeight write SetHeight;

    property OnMouseUp   : TMouseEvent read FOnMouseUp   write FOnMouseUp;
    property OnMouseDown : TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove : TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnClick :     TNotifyEvent read FOnClick write FOnClick;
    property OnClickR :    TNotifyEvent read FOnClickR write FOnClickR;
    property OnKeyDown   : TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyUp     : TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnKeyPress  : TKeyPressEvent read FOnKeyPress write FOnKeyPress;
  end;

////////////////////////////////////////////////////////////////////////////////
TDXWObjectList = class(TObjectList)
  protected
     ZList: TList;
     function GetItems(Index   : Integer): TDXWObject;
     procedure SetItems(Index : Integer; ADXWObject: TDXWObject);
  public
     DxO_Captured : integer;
     DxO_MouseOver: integer;
     constructor Create; overload;

     function  Add(aDXWObject : TDXWObject): Integer;
     function  Remove(aDXWObject : TDXWObject): Integer;
     function  IndexOf(aDXWObject: TDXWObject): Integer;

     procedure Insert(Index  : Integer; aDXWObject: TDXWObject);
     procedure DoDraw;
     procedure DrawZList(first:integer;limit:integer=0);
     procedure SortZList(first:integer;limit:integer=0);
     procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
     procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
     procedure MouseMove(Shift: TShiftState; X, Y: Integer);
     procedure KeyDown(var Key: Word; Shift: TShiftState);
     procedure KeyUp(var Key: Word; Shift: TShiftState);
     procedure KeyPress(var Key : char);

     property Items[Index : Integer]: TDXWObject read GetItems write SetItems; default;
  end;

////////////////////////////////////////////////////////////////////////////////
TDXWImageObject = class (TDXWObject)
  private
    FImage  : TPictureCollectionItem;
    FSurface: TDirectDrawSurface;
    procedure SetSurface(Value: TDirectDrawSurface);
  protected
    procedure SetImage(const Value: TPictureCollectionItem);virtual;
    function GetDrawImageIndex: Integer;virtual;
  public
    SelectedImage:  TPictureCollectionItem;
    MouseOverImage: TPictureCollectionItem;
    MouseRegionImage: TPictureCollectionItem;
    MirrorH: boolean;
    procedure DoDraw; override; 
    property Image : TPictureCollectionItem read FImage write SetImage;
    property Surface : TDirectDrawSurface read FSurface write SetSurface;
  end;

////////////////////////////////////////////////////////////////////////////////
TDXWLabel = class (TDXWObject)
  private
    FAutoSize : Boolean;
    FSurface  : TDirectDrawSurface;
    FFrame: boolean;
    FAlignRight:  boolean;
    FAlignCenter: boolean;
    procedure SetSurface(Value: TDirectDrawSurface);
    procedure SetText(value: string);
  public
    constructor Create(AOwner:TObject;FSize:integer=9);
    procedure DoDraw; override;
    property Surface  : TDirectDrawSurface read FSurface write SetSurface;
    property Caption  : String read FText write SetText ;
    property AutoSize : Boolean read FAutoSize write FAutoSize;
    property AlignRight : Boolean read FAlignRight write FAlignRight;
    property AlignCenter : Boolean read FAlignCenter write FAlignCenter;
  end;

////////////////////////////////////////////////////////////////////////////////
TDXWFrame = class (TDXWObject)
  private
    FSurface  : TDirectDrawSurface;
    procedure SetSurface(Value: TDirectDrawSurface);
  public
    constructor Create(AOwner:TObject);
    procedure DoDraw; override;
    property  Surface  : TDirectDrawSurface read FSurface write SetSurface;
  end;

////////////////////////////////////////////////////////////////////////////////
TDXWEdit = class (TDXWImageObject)
  private
    FCaretPos : integer;
    FOnChange : TNotifyEvent;
    FOnEnter : TNotifyEvent;
    procedure SetText(const Value: String);
    procedure Change;
  public
    constructor Create(AOwner:TObject); override;
    procedure DoDraw; override;
    function GetDrawImageIndex: Integer;override;
    procedure KeyDown(var Key: Word; Shift: TShiftState);override;
    procedure KeyUp(var Key: Word; Shift: TShiftState);override;
    procedure KeyPress(var Key : char);override;
    property Text    : String read FText write SetText ;
    property OnChange : TNotifyEvent read FOnChange write FOnChange;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
  end;

/////////////////////////////////////////////////////////////////////////
TDXWButton = class (TDXWImageObject)
  public
    constructor Create(AOwner:TObject); override;
    property Caption : String read FText write FText ;
  end;

/////////////////////////////////////////////////////////////////////////
TDXWPanel = class (TDXWImageObject)
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer); override;
  procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer); override;
  public
    Tag: integer;
    function GetDrawImageIndex: Integer;override;
    constructor Create(AOwner:TObject); override;
    property Caption  : String read FText write FText ;
  end;


/////////////////////////////////////////////////////////////////////////
implementation
/////////////////////////////////////////////////////////////////////////



function Shorten(S: string; Cut: Integer): string;
begin
  SetLength(S, Length(S) - Cut);
  Result:=S;
end;


/////////////////////////////////////////////////////////////////////////
constructor TDXWObject.Create(AOwner:TObject);
begin
  inherited Create;
  FFont:=TFont.Create;
  FFont.Color:=clWhite;
  FVisible:=true;
  FEnabled:=true;
  FText:='';
  FOwner:=AOwner;
  FDxObjectType:='TDXWObject';
end;
{----------------------------------------------------------------------------}
destructor TDXWObject.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.SetMouseInControl(const Value: Boolean);
begin
  if FMouseInControl=Value then Exit;
  FMouseInControl:=Value;
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then FOnKeyDown(self,Key,Shift);
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.KeyPress(var Key: char);
begin
  if Assigned(FOnKeyPress) then FOnKeyPress(self,Key);
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then FOnKeyUp(self,Key,Shift);
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  FDown:=true;
  FFocused:=true;
  FdClickedPoint:=Point(X-Left,Y-Top);
  if Assigned(FOnMouseDown) then FOnMouseDown(Self,Button,Shift,X,Y);
  if ((Button=MBRight) and Assigned(FOnClickR)) then FOnClickR(Self);
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  MouseInControl:=true;
  if Assigned(FOnMouseMove) then FOnMouseMove(Self,Shift,X,Y);
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  FDown:=not(FDown);
  if ( PtInRect(BoundsRect,Point(X,Y)) ) then
  begin
    if Assigned(FOnMouseUp) then FOnMouseUp(Self,Button,Shift,X,Y);
    if ((Button=MBLeft) and Assigned(FOnClick)) then FOnClick(Self);
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  SetBounds;
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.SetLeft(const Value: Integer);
begin
  FLeft := Value;
  SetBounds;
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.SetTop(const Value: Integer);
begin
  FTop := Value;
  SetBounds;
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  SetBounds;
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.SetBoundsRect(const Value: TRect);
begin
  FLeft:=Value.Left;
  FTop:=Value.Top;
  FWidth:=Value.Right-Value.Left;
  FHeight:=Value.Bottom-Value.Top;
  SetBounds;
end;
{----------------------------------------------------------------------------}
procedure TDXWObject.SetBounds;
begin
  FBoundsRect:=Bounds(FLeft,FTop,FWidth,FHeight);
end;
{----------------------------------------------------------------------------}
function TDXWObject.GetBoundsRect: TRect;
begin
  Result:=Bounds(FLeft,FTop,FWidth,FHeight);
end;

/////////////////////////////////////////////////////////////////////////



{----------------------------------------------------------------------------}
constructor TDXWObjectList.Create;
begin
  inherited Create;
  DxO_Captured:=-1;
end;
{----------------------------------------------------------------------------}
function TDXWObjectList.Add(ADXWObject: TDXWObject): Integer;
begin
  Result := inherited Add(ADXWObject);
  ADXWObject.listid:=count-1;
end;
{----------------------------------------------------------------------------}
procedure TDXWObjectList.DrawZList(first:integer; limit:integer=0);
var
  i: integer;
begin
  for i:=0 to first-1 do
    TDXWObject(items[i]).DoDraw;

  if ZList=nil then exit;
  for i:=0 to ZList.Count-1 do
    TDXWObject(ZList.items[i]).DoDraw;

  if limit=0 then exit;
  for i:=first+limit to count-1 do
    TDXWObject(items[i]).DoDraw;
end;
{----------------------------------------------------------------------------}
procedure TDXWObjectList.SortZList(first:integer;limit:integer=0);
var
  i,j: integer;
  max:integer;
  L, H, C: Integer;
begin
  if Zlist=nil
  then Zlist:=TList.create else ZList.Clear;
  if limit=0
  then max:=count-1 else max:=first+limit-1;
  ZList.Insert(0, items[first]);
  for i:=first+1  to max do
  begin
    with TDXWObject(items[i]) do
    begin
      L := 0;
      H := ZList.Count - 1;
      while L <= H do
      begin
        j := (L + H) div 2;
        C := TDXWObject(ZList[j]).Top+TDXWObject(ZList[j]).Height-(top+height);
        //if C > 0 then L := j + 1 else
        // original en avant plan les plus bas...
        if C < 0 then L := j + 1 else
        H := j - 1;
      end;
      ZList.Insert(L, items[i]);
    end;
  end;
  for i:=0  to ZList.Count-1 do
    TDXWObject(ZList[i]).Z:=i;
end;

{----------------------------------------------------------------------------}
procedure TDXWObjectList.DoDraw;
var
  i: integer;
begin
  for i:=0 to Count-1 do
    Items[i].DoDraw;
end;
{----------------------------------------------------------------------------}
function TDXWObjectList.GetItems(Index: Integer): TDXWObject;
begin
  Result := TDXWObject(inherited Items[Index]);
end;
{----------------------------------------------------------------------------}
function TDXWObjectList.IndexOf(ADXWObject: TDXWObject):
  Integer;
begin
  Result := inherited IndexOf(ADXWObject);
end;
{----------------------------------------------------------------------------}
procedure TDXWObjectList.Insert(Index: Integer;
  ADXWObject: TDXWObject);
begin
  inherited Insert(Index, ADXWObject);
end;
{----------------------------------------------------------------------------}
procedure TDXWObjectList.KeyDown(var Key: Word; Shift: TShiftState);
var
  i: integer;
begin
  for i:=0 to Count-1 do
  if Items[i].Focused then
  begin
    Items[i].KeyDown(Key,Shift);
  end
end;
{----------------------------------------------------------------------------}
procedure TDXWObjectList.KeyPress(var Key: char);
var
  i: integer;
begin
  for i:=0 to Count-1 do
  if Items[i].Focused then
  begin
    Items[i].KeyPress(Key);
  end
end;
{----------------------------------------------------------------------------}
procedure TDXWObjectList.KeyUp(var Key: Word; Shift: TShiftState);
var
  i: integer;
begin
  for i:=0 to Count-1 do
  if Items[i].Focused then
  begin
    Items[i].KeyUp(Key,Shift);
  end
end;
{----------------------------------------------------------------------------}
procedure TDXWObjectList.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: integer;
  n: integer;
  DownPoint : TPoint;
begin
  DxO_MouseOver:=-1;
  DownPoint:=Point(x,y);

  if ZList=nil then
  n:=0 else n:=ZList.count;

  for i:=0 to count-1-n do
  //for i:=Count-1 downto 0 do
  begin
    if ( PtInRect(Items[i].BoundsRect,DownPoint) ) and
      (Items[i].Visible) and
      (Items[i].Enabled) then
    begin
      DxO_MouseOver:=i;
      Items[i].MouseDown(Button,Shift,X,Y);
      if Items[i].MouseInControl
        then DxO_MouseOver:=i;
      if Items[i].MouseCaptured then
      begin
        DxO_Captured:=i;
      end;
    end;
  end;

  for i:=n-1 downto 0 do
  //for i:=Count-1 downto 0 do
  begin
    if ( PtInRect(TDXWObject(ZList.items[i]).BoundsRect,DownPoint) ) and
      (TDXWObject(ZList.items[i]).Visible) and
      (TDXWObject(ZList.items[i]).Enabled) then
    begin
      //DxO_MouseOver:=TDXWObject(DrawList.items[i]).listid;
      TDXWObject(ZList.items[i]).MouseDown(Button,Shift,X,Y);
      if TDXWObject(ZList.items[i]).MouseInControl
        then DxO_MouseOver:=TDXWObject(ZList.items[i]).listid;
      if TDXWObject(ZList.items[i]).MouseCaptured then
      begin
        DxO_Captured:=TDXWObject(ZList.items[i]).listid;
      end;
    end;
    if DxO_MouseOver<>-1 then break;
  end;

  for i:=Count-1 downto 0 do
  begin
    if not(( PtInRect(Items[i].BoundsRect,DownPoint) ) and
      (Items[i].Visible) and
      (Items[i].Enabled)) then
    begin
      Items[i].Focused:=false;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXWObjectList.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i, n: integer;
  MousePoint : TPoint;
begin
  MousePoint:=Point(x,y);
  DxO_MouseOver:=-1;
  if DxO_Captured>=0
  then
    Items[DxO_Captured].MouseMove(Shift,X,Y)
  else
  begin

  if ZList=nil then
  n:=0 else n:=ZList.count;

  for i:=0 to count-1-n do
    begin
      if ( PtInRect(TDXWObject(items[i]).BoundsRect,MousePoint) )
        // and ( TDXWObject(items[i]).Visible )
         and (TDXWObject(items[i]).Enabled )
      then
      begin
        TDXWObject(items[i]).MouseMove(Shift,X,Y);
        DxO_MouseOver:=i;
      end
      else
        TDXWObject(items[i]).MouseInControl:=false;
    end;
  end;

  if ZList=nil then
  n:=0 else n:=ZList.count;

  for i:=n-1 downto 0 do
    begin
      if ( PtInRect(TDXWObject(ZList.items[i]).BoundsRect,MousePoint) )
         and ( TDXWObject(ZList.items[i]).Visible )
         and (TDXWObject(ZList.items[i]).Enabled )
         and (DxO_MouseOver=-1)
      then
      begin
        TDXWObject(ZList.items[i]).MouseMove(Shift,X,Y);
        if TDXWObject(ZList.items[i]).MouseIncontrol then DxO_MouseOver:=TDXWObject(ZList.items[i]).listid;
      end
      else
        TDXWObject(ZList.items[i]).MouseInControl:=false;
    end;

end;
{----------------------------------------------------------------------------}
procedure TDXWObjectList.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  i         : integer;
  DownPoint : TPoint;
begin
  DxO_Captured:=-1;
  DownPoint:=Point(x,y);
  for i:=Count-1 downto 0 do
  begin
    if ( PtInRect(Items[i].BoundsRect,DownPoint) and
       Items[i].Visible  and
       Items[i].FEnabled and
       Items[i].Down ) then
    begin
      Items[i].MouseUp(Button,Shift,X,Y);
      break;
    end;
  end;
end;
{----------------------------------------------------------------------------}
function TDXWObjectList.Remove(ADXWObject: TDXWObject):
  Integer;
begin
  Result:=inherited Remove(ADXWObject);
end;
{----------------------------------------------------------------------------}
procedure TDXWObjectList.SetItems(Index: Integer; ADXWObject: TDXWObject);
begin
  inherited Items[Index]:=ADXWObject;
end;




/////////////////////////////////////////////////////////////////////////

function TDXWImageObject.GetDrawImageIndex: Integer;
const
  btNormal=0;
  btSelected=1;
  btDisabled=2;
  btHighlighted=3;
begin
  Result:=btNormal;
  case Image.PatternCount of
    2: begin
    if canCheck and Selected  then Result:=btSelected;
    if not(canCheck) and not(Down) then Result:=btSelected;  // on inverse le down / selected pour les boutons 2 états
    end;
    3: begin
      if not(enabled) then Result:=btDisabled;
      if Down then Result:=btSelected;
      if Selected then Result:=btSelected; //Highlighted;
    end;
    4: begin
      if MouseInControl then Result:=btHighlighted;
      if not(enabled) then Result:=btDisabled;
      if Down then Result:=btSelected;
      if Selected then Result:=btHighlighted;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXWImageObject.DoDraw;
var
  ImageIndex: Integer;
begin
  if not FVisible then Exit;
  ImageIndex:=GetDrawImageIndex;
  if MirrorH
   then Image.DrawFlipH(FSurface, FLeft, FTop, ImageIndex)
   else Image.Draw( FSurface, FLeft, FTop, ImageIndex);
  //image.Restore;
  if FText<>'' then
  begin
    with FSurface.Canvas do
    begin
      Font.Assign(Self.Font);
      Brush.Style:=bsClear;
      if MouseInControl and CanHighLighted then
      Font.Style:=[fsBold];
      Font.Color:=ClText;
      Font.Size:=8;
      if FDxObjectType='TDXWEdit'
      then
        if (Focused)
          then TextRect(BoundsRect,FLeft+10 ,FTop+(FHeight-TextHeight('A'))div 2, FText + '_')
           else TextRect(BoundsRect,FLeft+10 ,FTop+(FHeight-TextHeight('A'))div 2, FText)
        else
        if FDxObjectType='TDXWButton'
          //then TextRect(BoundsRect,FLeft+ FWidth -TextWidth(FText) -8 , FTop + FHeight - TextHeight('A')-4  , FText)
          then TextRect(BoundsRect,FLeft+ (FWidth -TextWidth(FText)) div 2 , FTop + FHeight - TextHeight('A')-4  , FText)
          else TextRect(BoundsRect,FLeft+ FWidth -TextWidth(FText) -2 , FTop + FHeight - TextHeight('A')    , FText);
      Release;
    end;
  end;

  if (Selected or Focused) and (SelectedImage <> nil) then
    SelectedImage.Draw( FSurface, FLeft, FTop, 0);
  if MouseInControl and (MouseOverImage <> nil) then
    MouseOverImage.Draw( FSurface, FLeft, FTop, 0);

end;

/////////////////////////////////////////////////////////////////////////

{ TDXWEdit }

procedure TDXWImageObject.SetSurface(Value: TDirectDrawSurface);
begin
  FSurface := Value;
end;

{----------------------------------------------------------------------------}
procedure TDXWImageObject.SetImage(const Value: TPictureCollectionItem);
begin
  FImage := Value;
  Width:=Value.Width;
  Height:=Value.Height;
  FImage.SystemMemory:=true; //opMemory
end;

/////////////////////////////////////////////////////////////////////////

{ TDXWEdit }

procedure TDXWEdit.Change;
begin
 if Assigned(FOnChange) then FOnChange(Self);
end;
{----------------------------------------------------------------------------}
constructor TDXWEdit.Create(AOwner: TObject);
begin
 inherited Create(AOwner);
 FCaretPos:=0;
 FDxObjectType:='TDXWEdit';
end;
{----------------------------------------------------------------------------}
procedure TDXWEdit.DoDraw;
begin
  inherited DoDraw;
end;
{----------------------------------------------------------------------------}
function TDXWEdit.GetDrawImageIndex: Integer;
begin
 if Focused then Result :=1 else Result :=0;
end;
{----------------------------------------------------------------------------}
procedure TDXWEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  Case key of
    //vk_left  :
    //vk_right :
    VK_RETURN: if Assigned(FOnEnter) then FOnEnter(self);
    VK_BACK: Text:=Shorten(FText,1);
  end;
  inherited KeyDown(Key,Shift);
end;
{----------------------------------------------------------------------------}
procedure TDXWEdit.KeyPress(var Key: char);
begin
 //ShowMessage(IntToStr( Ord(key) ));
 //BackSpace pressed  Enter pressed
 if ( Ord(key)=8 ) or  ( Ord(key)=13 )
    then Exit;
 Text:=FText+Key;
 inherited KeyPress(Key);
end;
{----------------------------------------------------------------------------}
procedure TDXWEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
end;
{----------------------------------------------------------------------------}
procedure TDXWEdit.SetText(const Value: String);
begin
  if FText=Value then Exit;
  FText:=Value;
  Change;
end;

/////////////////////////////////////////////////////////////////////////

{ TDXWLabel }

constructor TDXWLabel.Create(AOwner:TObject;FSize:integer=9);
begin
  inherited Create(AOwner);
  FAutoSize:=true;
  Font.Color:=clWhite;
  Font.Name:=H3Font;// 'Times New Roman';
  Font.Size:=FSize;
  FFrame:=false;
  FDxObjectType:='TDXWLabel';
  FEnabled:=false;
  FVisible:=true;
end;
{----------------------------------------------------------------------------}
procedure TDXWLabel.DoDraw;
var
  dt: cardinal;
  fRect: Trect;
begin
  if Not FVisible then Exit;
  with FSurface.Canvas do
  begin
    try
      Brush.Style:=bsClear;
      Font.Assign(Self.Font);
      if FAutoSize
      then TextOut(FLeft,FTop,FText)
      else
      begin
        dt:=DT_WORDBREAK;
        if FAlignCenter then dt:= dt or DT_CENTER;
        if FAlignRight  then dt:= dt or DT_RIGHT;
        fRect:=BoundsRect;
        drawText(FSurface.Canvas.Handle,Pchar(FText),length(FText),fRect,dt);
        if FFrame then
        begin
          FSurface.Canvas.Brush.Color:=$0080FF80;
          FSurface.Canvas.FrameRect(BoundsRect);
        end;
      end;
    finally
      Release;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXWLabel.SetSurface(Value: TDirectDrawSurface);
begin
  FSurface:=Value;
end;
{----------------------------------------------------------------------------}
procedure TDXWLabel.SetText(Value: String);
begin
  FText:=Value;
end;
{----------------------------------------------------------------------------}

/////////////////////////////////////////////////////////////////////////
{Frame}

constructor TDXWFrame.Create(AOwner:TObject);
begin
  inherited Create(AOwner);
  FDxObjectType:='TDXWFrame';
  FCanHighlighted:=true;
end;
{----------------------------------------------------------------------------}
procedure TDXWFrame.DoDraw;
var
  fRect: Trect;
begin
  if not FVisible then Exit;
  if not FCanHighlighted then exit;
  if Selected then
  with FSurface.Canvas do
  begin
    FRect:=BoundsRect;
    FSurface.Canvas.Brush.Color:=$0080FFFF;
    FSurface.Canvas.FrameRect(BoundsRect);
    Release;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXWFrame.SetSurface(Value: TDirectDrawSurface);
begin
  FSurface:=Value;
end;

/////////////////////////////////////////////////////////////////////////
{ TDXWPanel }

function TDXWPanel.GetDrawImageIndex: Integer;
begin
  Result:=Tag;
  //if FSelected then Image.Draw( FSurface, FLEft, FTop, 127);
end;
{----------------------------------------------------------------------------}
constructor TDXWPanel.Create(AOwner:TObject);
begin
  inherited Create(AOWner);
  Tag:=0;
  FDxObjectType:='TDXWPanel';
  FEnabled:=true;
end;
{----------------------------------------------------------------------------}
procedure TDXWPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  MouseInControl:=false;
  if MouseRegionImage = nil
  then MouseInControl:=true
  else
    if MouseRegionImage.Picture.Bitmap.Canvas.Pixels[x-left,y-top] <> clAqua
    then MouseInControl:=true;
  if MouseInControl
  then
    if Assigned(FOnMouseMove) then FOnMouseMove(Self,Shift,X,Y);
end;
{----------------------------------------------------------------------------}
procedure TDXWPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  MouseInControl:=false;
  if MouseRegionImage = nil
  then   MouseInControl:=true
  else
    if MouseRegionImage.Picture.Bitmap.Canvas.Pixels[x-left,y-top] <> clAqua
    then MouseInControl:=true;
  if MouseInControl
  then
  begin
   FDown:=true;
   if Assigned(FOnMouseDown) then FOnMouseDown(Self,Button,Shift,X,Y);
   if ((Button=MbRight) and (Assigned(FOnClickR))) then FOnClickR(Self);
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXWPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if MouseInControl
  then
  begin
    FDown:=false;
    if Assigned(FOnMouseUp) then FOnMouseUp(Self,Button,Shift,X,Y);
    if ((Button=MbLeft) and (Assigned(FOnClick)))   then FOnClick(Self);
  end;
end;

/////////////////////////////////////////////////////////////////////////
{ TDXWButton }

constructor TDXWButton.Create(AOwner: TObject);
begin
  inherited Create(AOwner);
  FCanHighLighted:=true;
  Font.Color:=ClText;
  FDxobjectType:='TDXWButton';
end;




end.
