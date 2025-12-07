unit DXWListBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DXClass, DXDraws ,DXWControls,DXWScroll,UConst;

Type

  TDXWListBox = class(TDXWObject)
  private
    FImage        : TPictureCollectionItem;
    FSurface      : TDirectDrawSurface;
    FStrings      : TStringList;
    FLineTop      : integer;
    FLineTopMax   : integer;
    FTextOffSetX   : byte;
    FTextOffSetY   : byte;
    TxtRect       : TRect;
    FLineHeight   : integer;
    FFocusedLineId: integer;
    FItemIndex    : integer;
    FFocusedLine  : string;
    FSorted       : Boolean;
    FHighLightedColor : TColor;
    FSelectedColor    : TColor;
    FScrollBar        : TDXWScroll;

    procedure SetSurface(Value: TDirectDrawSurface);
    Function  MousePosToLineId(X,Y : integer):integer;
    Function  BottomLine :integer;
    Function  GetLineUnderCursor(X,Y : integer):string;
    Procedure SetLineTop(Value : integer );
    Procedure SetItemIndex(Value : integer );
    Procedure SetStrings(Value: TStringList);
    Procedure SetSorted(Value : Boolean );
    Procedure SetFocusedLineId(Value : Integer);
    procedure SetImage(const Value: TPictureCollectionItem);
    procedure SetScrollBar(const Value: TDXWScroll);
Protected
   Procedure DoDraw;override;
   function  GetDrawImageIndex: Integer;virtual;
   procedure SetBounds;override;

   Procedure MouseUp(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);override;
   Procedure MouseDown(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);override;
   Procedure MouseMove(Shift:TShiftState;X,Y:Integer);override;

   Procedure KeyDown(var Key: Word; Shift: TShiftState);override;
   Procedure KeyUp(var Key: Word; Shift: TShiftState);override;
   Procedure KeyPress(var Key : char);override;

   Procedure StringsChanged(Sender : TObject);
   Procedure FontChanged(Sender: TObject);override;
   Procedure ScrollChanged(Sender : TObject);

 Public
   ImgVic : TPictureCollectionItem;
   ImgLos : TPictureCollectionItem;
   Title: boolean;
   Constructor Create(AOwner : TObject);override ;
   Destructor  Destroy; override;
   Function  LinesShow : integer;

   property Image : TPictureCollectionItem read FImage write SetImage;
   property Surface : TDirectDrawSurface read FSurface write SetSurface;
   property LineTop    :integer read FLineTop write SetLineTop default 0;
   property LineTopMax :integer read FLineTopMax;
   property FocusedLine   : string  read FFocusedLine ;
   property FocusedLineId : integer read FFocusedLineId write SetFocusedLineId;
   property TextOffsetX : byte read FTextOffsetX write FTextOffsetX;
   property TextOffsetY : byte read FTextOffsetY write FTextOffsetY;
   property Strings : TStringList read  FStrings  write  SetStrings;
   property ItemIndex : integer read FItemIndex write SetItemIndex;
   property LineHeight: integer read FLineHeight write FLineHeight;
   property HighLightedColor : TColor read FHighLightedColor write FHighLightedColor;
   property SelectedColor    : TColor read FSelectedColor write FSelectedColor;
   property Sorted : Boolean read FSorted write SetSorted;
   property ScrollBar : TDXWScroll read  FScrollBar write SetScrollBar;

end;

implementation


function MyCompare(List: TStringList; Index1, Index2: Integer): Integer;
var
  s1,s2:string;
begin
  s1:=List.Strings[index1];
  s2:=List.Strings[index2];
  if s1 > s2 then  Result := -1 else Result := 1;
  if s1=s2 then result:=0;
end;
{----------------------------------------------------------------------------}
Constructor TDXWListBox.Create(AOwner : TObject);
begin
  inherited Create(AOwner);
  Title:=true;
  FLineTop:=0;
  FFocusedLineId:=-1;
  FItemIndex:=-1;
  FFocusedLine:='';
  Font.Name:=H3Font;//'Arial';
  Font.Style:=[fsBold];
  Font.Size:=10;
  FTextOffsetY:=40;
  FTextOffsetX:=10;
  FHighLightedColor:=clRed;
  FSelectedColor:=clText ;
  FStrings:=TStringList.Create;
  FStrings.Sorted:=FSorted;
  FStrings.OnChange:=StringsChanged;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.DoDraw;
var
  i,pos         : integer;
  LineOutCounter: integer;
  CurrentLine   : String;
  SubItem       : String;
  CurrentLineId : Integer;
  ImageIndex    : Integer;
begin
  if not Visible then Exit;
  TxtRect:=Bounds(Left+FTextOffSetX,Top+FTextOffsetY,Width,Height-FTextOffsetX);
  ImageIndex:=GetDrawImageIndex;
  Image.Draw(FSurface, Left, Top, ImageIndex);

  with FSurface.Canvas do
  begin
    Font.Assign(Self.Font);
    Brush.Style := bsClear;

    //Drawing Text Lines
    for LineOutCounter:=0 to LinesShow-1 do
    begin
      CurrentLineId:=FLineTop+LineOutCounter;
      // example of line = 'ID;pL;size; map title    ;vic;los
      // example of line = 'XX;2 ; XL ; The civil War; 1 ; 2
      CurrentLine:=Strings[CurrentLineId];
      Font.Style:=Self.Font.Style;
      Font.Color:=Self.Font.Color;
      if CurrentLineId=FItemIndex then
      Font.Color:=FSelectedColor
      else
      if (CurrentLineId=FFocusedLineId) and (MouseInControl) then
      begin Font.Style:=[fsBold]; Font.Color:=FSelectedColor; end;
      //Lock;
      // TEXT PART = 'PL;size; map title
      pos:=ANSIPOS(';',CurrentLine);
      CurrentLine:=copy(CurrentLine,pos+1,length(CurrentLine)-(pos));
      for i:=0 to 2 do  // nb d element  texte
      begin
      pos:=ANSIPOS(';',CurrentLine);
      if pos=0
          then SubItem:=copy(CurrentLine,1,length(CurrentLine))
          else SubItem:=copy(CurrentLine,1,pos-1);

       TextRect(TxtRect,TxtRect.Left+32*i,TxtRect.Top+LineOutCounter*LineHeight,SubItem);
       CurrentLine:=copy(CurrentLine,pos+1,length(CurrentLine)-(pos));
     end;
    end;
    Release;

    for LineOutCounter:=0 to LinesShow-1 do
    begin
      CurrentLineId:=FLineTop+LineOutCounter;
      CurrentLine:=Strings[CurrentLineId];
      // skip TEXT PART = 'PL;size; map title
      for i:=0 to 3 do  // nb d element  texte
      begin
        pos:=ANSIPOS(';',CurrentLine);
        CurrentLine:=copy(CurrentLine,pos+1,length(CurrentLine)-(pos));
      end;
      // PIC PART = VIC / LOS Pic
      pos:=ANSIPOS(';',CurrentLine);
      if pos=0
      then SubItem:=copy(CurrentLine,1,length(CurrentLine))
      else SubItem:=copy(CurrentLine,1,pos-1);
      CurrentLine:=copy(CurrentLine,pos+1,length(CurrentLine)-(pos));
      ImgVic.Draw(FSurface, TxtRect.Left+242, TxtRect.Top+LineOutCounter*LineHeight-7, (strtoint(subitem)+12) mod 12);
      pos:=ANSIPOS(';',CurrentLine);
      if pos=0
      then SubItem:=copy(CurrentLine,1,length(CurrentLine))
      else SubItem:=copy(CurrentLine,1,pos-1);
      ImgLos.Draw(FSurface, TxtRect.Left+274, TxtRect.Top+LineOutCounter*LineHeight-7, (strtoint(subitem)+4) mod 4);
    end;
  end;
end;
{----------------------------------------------------------------------------}
Destructor  TDXWListBox.Destroy;
begin
  FStrings.Free;
  inherited Destroy;
end;
{----------------------------------------------------------------------------}
Procedure TDXWListBox.MouseUp(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
  inherited MouseUp(Button,Shift,X,Y);
end;
{----------------------------------------------------------------------------}
Procedure TDXWListBox.MouseDown(Button: TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
  inherited MouseDown(Button,Shift,X,Y);
  FItemIndex:=FFocusedLineId;
end;
{----------------------------------------------------------------------------}
Procedure TDXWListBox.MouseMove(Shift:TShiftState;X,Y:Integer);
Var
 LN:integer;
begin
  inherited MouseMove(Shift,X,Y);
  LN:=MousePosToLineId(X,Y);
  FFocusedLineId:=LN;
  if (ssLeft in Shift) and (FFocusedLineId>=0)
  then FItemIndex:=LN;
end;
{----------------------------------------------------------------------------}
Procedure TDXWListBox.SetFocusedLineId(Value : Integer);
begin
  if(Value<>-1)and
  (Value<>FFocusedLineId)
  then FFocusedLineId:=Value;
end;
{----------------------------------------------------------------------------}
Procedure TDXWListBox.SetItemIndex(Value : Integer);
begin
  if(Value<>-1)and
  (Value<>FItemIndex)
  then FItemIndex:=Value;
end;
{----------------------------------------------------------------------------}
function TDXWListBox.MousePosToLineId(X,Y : integer):integer;
var
  LineOutCounter:integer;
begin
  Result:=-1;
  if Not PtInRect(TxtRect,Point(X,Y))then Exit;
  LineOutCounter:=(Y - TxtRect.Top) div LineHeight;
  Result:=FLineTop+LineOutCounter;
  if Result > BottomLine then Result:=-1;
end;
{----------------------------------------------------------------------------}
function TDXWListBox.GetLineUnderCursor(X,Y : integer):string;
var
  CurrentLine:String;
  CurrentLineId:Integer;
begin
  Result:='';
  CurrentLineId:=MousePosToLineId(X,Y);
  if CurrentLineId=-1 then Exit;
  CurrentLine:=Strings[CurrentLineId];
  Result:=CurrentLine;
end;
{----------------------------------------------------------------------------}
function  TDXWListBox.LinesShow : integer;
begin
  result :=( Height- FTextOffsetY+8 ) Div LineHeight;
  if result>Strings.Count
  then result:=Strings.Count;
end;
{----------------------------------------------------------------------------}
Function TDXWListBox.BottomLine :integer;
begin
  result :=Strings.Count-1;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.SetLineTop(Value : integer );
begin
  if(Value<>FLineTop)and
    (Value<=FLineTopMax) and
    (Value>=0) then
  begin
    FLineTop := Value;
    if Assigned(FScrollBar)
    then FScrollBar.Position:=FLineTop;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.SetStrings(Value : TStringList );
begin
  FStrings.Assign(Value);
end;
{----------------------------------------------------------------------------}
Procedure TDXWListBox.StringsChanged(Sender : TObject);
begin
  FItemIndex:=-1;
  FLineTop:=0;
  FLineTopMax:=(BottomLine-LinesShow+1);
end;
{----------------------------------------------------------------------------}
Procedure TDXWListBox.SetSorted(Value : Boolean );
begin
  FSorted:=Value;
  FStrings.Sorted:=FSorted;
end;
{----------------------------------------------------------------------------}
function TDXWListBox.GetDrawImageIndex: Integer;
begin
//if Down then Result :=1 else Result :=0;
Result :=0;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.SetSurface(Value: TDirectDrawSurface);
begin
  FSurface := Value;
  with FSurface.Canvas do
  begin
    LineHeight:=TextHeight('A');
    //Release;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.FontChanged(Sender: TObject);
begin
{
 inherited FontChanged(Sender);

 if FSurface=nil then Exit;
 with Surface.Canvas do
 begin
  LineHeight:=TextHeight('A');
  Release;
 end;
}
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  Case key of
    vk_Up   : LineTop:=LineTop-1;
    vk_Down : LineTop:=LineTop+1;
  end;
  inherited;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.KeyPress(var Key: char);
begin
  inherited;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.SetBounds;
begin
  inherited;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.SetImage(const Value: TPictureCollectionItem);
begin
  FImage := Value;
  Width:=Value.Width;
  Height:=Value.Height;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.SetScrollBar(const Value: TDXWScroll);
begin
  FScrollBar:=Value;
  FScrollBar.OnChange:=ScrollChanged;
  FScrollBar.Max:=FLineTopMax;
  FScrollBar.Position:=0;
end;
{----------------------------------------------------------------------------}
procedure TDXWListBox.ScrollChanged(Sender: TObject);
begin
  LineTop:=FScrollBar.Position;
end;
{----------------------------------------------------------------------------}

end.
