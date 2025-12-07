unit DXWScene;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Contnrs, IniFiles,
  DXClass, DXSprite, DXInput, DXDraws, DXSounds, DIB, DXWControls, DXWLoad, UFile;

Type
  TFontOption = (CLY,BLD,SZS,SZM,SZL,ALL,ALR,ALC);
  TFontOptionSet = set of TFontOption;

  TDxScene = class(TObject)
  private
    FName: string;
    FHint: string;
    FHintX, FHintY: integer;
    FDXDraw: TCustomDXDraw;
    FLeft: integer;
    FTop: integer;
    procedure SetDXDraw(Value: TCustomDXDraw);
    procedure ShowHint;
    procedure SetLeft(Value: integer);
    procedure SetTop(Value: integer);
    procedure DrawBasic;
    function  CanDraw:boolean;
  protected
    FAutoDestroy: boolean;
    FVisible: boolean;
    FText: TStringlist;
    FOnDraw: TNotifyEvent;
    FOnRefresh: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseUp:TMouseEvent;
    FOnKeyDown: TKeyEvent;
    procedure AddScene;
    procedure AddSubScene;
    procedure AddPopScene;
    procedure SnPopMouseUp(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BtnOK(Sender: TObject);
    procedure BtnCancel(Sender: TObject);
    procedure LoadDxG;
    procedure SaveDxG;
    procedure SavePicName;
    procedure ScreenShot;
    procedure SaveSurface;
    procedure ShowHintClick(Sender: TObject); virtual;
  public
    Initialized: boolean;
    Drawing: boolean;
    AllClient: boolean;
    AutoRefresh: boolean;
    FPop: boolean;

    ObjectList: TDXWObjectList;
    DxSurface : TDirectDrawSurface;
    LastSurface : TDirectDrawSurface;
    Redraw : boolean;
    MyRect: TRect;
    FHeight, FWidth :integer;
    ImageList:  TDXImageList;
    Background: integer;
    Parent: TDxScene;
    constructor Create(name:string);
    destructor Destroy; override;
    procedure Show;
    procedure Hide;
    procedure SetAutoDestroy(Value: boolean);
    procedure CloseScene;
    procedure ProcessAction; virtual;
    procedure UpdateColor(PL, nImage: integer);
    procedure LoadFromFile(filename: string);
    procedure AddBackground(pic: string);

    function  AddTitleScene(text:String;y:integer):integer;

    function  AddDxLabel(text:String;x,y:integer;op: TFontOptionSet =[SZM]): integer;

    function  AddLabel(text:String;x,y:integer;size:integer=9):integer;
    function  AddLabel_Center(text:String;x,y,w:integer;size:integer=9):integer;
    function  AddLabel_Right(text:String;x,y,w:integer;size: integer=9):integer;
    function  AddLabel_Yellow(text:String;x,y:integer;size: integer=9):integer;
    function  AddLabel_YellowCenter(text:String;x,y,w:integer;size: integer=9):integer;
    function  AddMemo(text:String;x,y,w,h: integer;size: integer=9):integer;
    function  AddLabel_MultiLine(text:String;x,y:integer):integer;

    function  AddEdit(pic: string; x,y: integer;proc: TNotifyEvent=nil):integer;

    function  AddImage(pic: string):integer;
    function  AddButton(pic: string; x,y: integer; proc: TNotifyEvent=nil; TxtId: integer=-1):integer;
    function  AddFrame(w,h,x,y: integer;proc:TNotifyEvent=nil;highlighted:boolean=true):integer;
    function  AddPanel(pic: string; x,y: integer; proc: TNotifyEvent=nil): integer;
    function  AddSprPanel(pic: string; x,y: integer; proc: TNotifyEvent=nil; TxtId: integer=-1;procR: TNotifyEvent=nil):integer;
    procedure AddSprPanelSelectedImage(DxO_ID:integer;pic: string);
    procedure AddSprPanelMouseOverImage(DxO_ID:integer;pic: string);
    procedure AddSprPanelRegionImage(DxO_ID:integer;pic: string);
    procedure ChgSprPanel(DxO_ID:integer; DefName: string);

    function  AddCreaPanel(CR: integer; x,y: integer; proc: TNotifyEvent=nil; TxtId: integer=-1):integer;
    function  AddBuildPanel(Def: string; x,y: integer; proc: TNotifyEvent=nil; TxtId: integer=-1):integer;
    procedure ChgBuildPanel(DxO_ID:integer; Def: string);

    procedure DoDraw; virtual;
    procedure DoRefresh; virtual;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer);
    procedure KeyDown(var Key: Word; Shift: TShiftState);
    procedure KeyUp(var Key: Word; Shift: TShiftState);
    procedure KeyPress(var Key : char);

    property  Name: string read FName write FName;
    property  Visible: boolean read FVisible write FVisible;
    property  AutoDestroy: boolean read FAutoDestroy write SetAutoDestroy;
    property  DXDraw: TCustomDXDraw read FDXDraw write SetDXDraw;
    property  OnDraw: TNotifyEvent read FOnDraw write FOnDraw;
    property  OnRefresh: TNotifyEvent read FOnRefresh write FOnRefresh;
    property  OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property  OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property  OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property  OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property  Left: integer read FLeft write setLeft;
    property  Top: integer read FTop write setTop;
    property  Hint: string read FHint write FHint;
    property  HintX: integer read FHintX write FHintX;
    property  HintY: integer read FHintY write FHintY;
 end;

implementation

uses UMain, USnDialog, UConst, UType;


{ TDxScene }

{----------------------------------------------------------------------------}
procedure TDxScene.LoadFromFile(filename: string);
var
  i           : integer;
  l,t: integer;
  SectionName : string;
  SectionList : TStringList;
  s:  string;
begin
  SectionList := TStringList.Create;
  try
    with TIniFile.Create(Folder.Data+filename+'.dat') do
    try
      ReadSections(SectionList);
      Left:=ReadInteger('Window','Left',0);
      top:=ReadInteger('Window','Top',0);
      AddBackground(ReadString('Window','Background',''));
      HintX:=ReadInteger('Window','HintX',60);
      HintY:=ReadInteger('Window','HintY',558);
      For i:=0 to SectionList.Count-1 do
      begin
        SectionName:=SectionList[i];
        if SectionName='Window' then continue;
        if ReadString(SectionName,'Type','')='Label' then
        begin
          l:=ReadInteger(SectionName,'left',0);
          t:=ReadInteger(SectionName,'top',0);
          s:=ReadString(SectionName,'text','');
          AddLabel(s,l,t);
        end;
        if ReadString(SectionName,'Type','')='Panel' then
        begin
          s:=ReadString(SectionName,'img','');
          //if s='s1'....
          l:=ReadInteger(SectionName,'left',0);
          t:=ReadInteger(SectionName,'top',0);
          AddPanel(s,l,t);
        end;
      end;
    finally
      Free;
    end;
  Finally
    SectionList.Free;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.AddBackground(pic: string);
begin
  Background:=LoadBmp(ImageList,pic);
  fHeight:=ImageList.items[Background].height;
  fWidth:=ImageList.items[Background].width;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddFrame(w,h,x,y: integer;proc:TNotifyEvent=nil;highlighted:boolean=true): integer;
var
  DxO_ID: integer;
begin
  DxO_ID:=ObjectList.Add(TDXWFrame.Create(self));
  with TDXWFrame(ObjectList[DxO_ID]) do
  begin
    Left:=FLeft+X;
    Top:=FTop+Y;
    Width:=w;
    Height:=h;
    Surface:=DxSurface;
    OnClick:=proc;
    CanHighlighted:=Highlighted;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddDxLabel(text:String;x,y:integer;op: TFontOptionSet =[SZM]): integer;
var
  DxO_ID:integer;
begin
  DxO_ID:=ObjectList.Add(TDXWLabel.Create(self));
  With TDXWLabel(ObjectList[DxO_ID]) do
  begin
    Autosize:=true;
    Left:=FLeft+X;
    Top:=FTop+Y;
    Width:=60;
    Height:=24;
    Surface:=DxSurface;
    Caption:=text;
    if SZS in op then Font.size:=09;
    if SZM in op then Font.size:=10;
    if SZL in op then Font.size:=12;
    if CLY in op then Font.color:=ClText;
    if ALC in op then begin
      Autosize:=false;
      AlignCenter:=true;
      Height:=48;
    end;
    if ALR in op then begin
      Autosize:=false;
      AlignRight:=true;
      Height:=48;
    end;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddLabel(text:String;x,y:integer;size: integer=9): integer;
var
  DxO_ID:integer;
begin
  DxO_ID:=ObjectList.Add(TDXWLabel.Create(self));
  With TDXWLabel(ObjectList[DxO_ID]) do
  begin
    Autosize:=true;
    Left:=FLeft+X;
    Top:=FTop+Y;
    Width:=60;
    Height:=24;
    Surface:=DxSurface;
    Caption:=text;
    Font.size:=size;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddLabel_MultiLine(text:String;x,y:integer): integer;
var
  DxO_ID:integer;
begin
  DxO_ID:=AddLabel(text,x,y,9);
  with TDXWLabel(ObjectList[DxO_ID]) do
  begin
    Autosize:=false;
    Width:=180;
    Height:=64;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddLabel_Center(text:String;x,y,w:integer;size: integer=9): integer;
var
  DxO_ID:integer;
begin
  DxO_ID:=AddLabel(text,x,y,size);
  with TDXWLabel(ObjectList[DxO_ID]) do
  begin
    Autosize:=false;
    AlignCenter:=true;
    Width:=w;
    Height:=48;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddLabel_Right(text:String;x,y,w:integer;size: integer=9): integer;
var
  DxO_ID:integer;
begin
  DxO_ID:=AddLabel(text,x,y,size);
  with TDXWLabel(ObjectList[DxO_ID]) do
  begin
    Autosize:=false;
    AlignRight:=true;
    Width:=w;
    Height:=48;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddLabel_Yellow(text:String;x,y:integer;size: integer=9): integer;
var
  DxO_ID:integer;
begin
  DxO_ID:=AddLabel(text, x ,y, size);
  TDXWLabel(ObjectList[DxO_ID]).Font.color:=ClText;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddLabel_YellowCenter(text:String;x,y,w:integer;size: integer=9): integer;
var
  DxO_ID:integer;
begin
  DxO_ID:=AddLabel_Center(text,x,y,w,size);
  TDXWLabel(ObjectList[DxO_ID]).Font.color:=ClText;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddTitleScene(text:String; y:integer): integer;
var
  DxO_ID:integer;
begin
  DxO_ID:=AddLabel(text, 0 ,y);
  with TDXWLabel(ObjectList[DxO_ID]) do
  begin
    Font.size:=14;
    Font.Style:=[fsbold];
    Font.color:=ClText;
    AlignCenter:=true;
    Autosize:=false;
    Caption:=text;
    Width:=ImageList.Items[Background].Width;    //Background should be initialized
    Height:=24;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddMemo(text:String;x,y,w,h: integer;size: integer=9): integer;
var
  DxO_ID:integer;
begin
  DxO_ID:=ObjectList.Add(TDXWLabel.Create(self));
  With TDXWLabel(ObjectList[DxO_ID]) do
  begin
    Autosize:=false;
    Left:=FLeft+X;
    Top:=FTop+Y;
    Width:=w;
    Height:=h;
    Surface:=DxSurface;
    Caption:=text;
    Visible:=true;
    AlignCenter:=true;
    Font.size:=size;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddEdit(pic: string; x,y: integer;proc: TNotifyEvent=nil): integer;
var
  DxO_ID, PIC_ID:integer;
begin
  PIC_ID:=ImageList.Items.IndexOf(pic);
  if PIC_ID=-1 then PIC_ID:=LoadBmp(ImageList,pic);
  DxO_ID:=ObjectList.Add(TDXWEdit.Create(self));
  with TDXWEdit(ObjectList[DxO_ID]) do
  begin
    left:=FLeft+X;
    top:=FTop+Y;
    Image:=ImageList.Items[PIC_ID];
    Image.SystemMemory:=true; //opMemory
    Height:=Image.Height div 2;
    Font.Color:=clBlack;
    Font.Size:=10;
    Text:='HE11:20';
    Surface:=DxSurface;
    OnEnter:=proc;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddImage(pic: string): integer;
begin
  result:=LoadBmp(ImageList,pic);
end;
{----------------------------------------------------------------------------}
function TDxScene.AddButton(pic: string; x,y: integer; proc: TNotifyEvent=nil; TxtId: integer=-1): integer;
var
  DxO_ID, PIC_ID:integer;
begin
  PIC_ID:=LoadSprite(ImageList,pic);
  DxO_ID:=ObjectList.Add(TDXWButton.Create(self));
  with TDXWButton(ObjectList[DxO_ID]) do
  begin
    if TxtId=-1
      then Name:=pic
      else Name:=FText[TxtId];
    Image:=ImageList.Items[PIC_ID];
    Image.SystemMemory:=true; //opMemory
    Left:=FLeft+X;
    Top:=FTop+Y;
    Surface:=DxSurface;
    Visible:=true;
    OnClick:=proc;
    OnClickR:=ShowHintClick;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddPanel(pic: string; x,y: integer; proc:TNotifyEvent=nil): integer;
var
  DxO_ID, PIC_ID:integer;
begin
  PIC_ID:=ImageList.Items.IndexOf(pic);
  if PIC_ID=-1 then PIC_ID:=LoadBmp(ImageList,pic);
  DxO_ID:= ObjectList.Add(TDXWPanel.Create(self));
  result:=DxO_ID;
  if PIC_ID=-1 then PIC_ID:=0;    // defense for no pic found
  with TDXWPanel(ObjectList[DxO_ID]) do
  begin
    Name:=pic;
    Image:=ImageList.Items[PIC_ID];
    Image.SystemMemory:=true;
    Left:=FLeft+X;
    Top:=FTop+Y;
    Surface:=DxSurface;
    OnClick:=proc;
  end;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddSprPanel(pic: string; x,y: integer; proc: TNotifyEvent=nil; TxtId: integer=-1;procR: TNotifyEvent=nil):integer;
var
  DxO_ID, PIC_ID:integer;
begin
  PIC_ID:=LoadSprite(ImageList,pic);
  DxO_ID:=ObjectList.Add(TDXWPanel.Create(self));
  with TDXWPanel(ObjectList[DxO_ID]) do
  begin
    if TxtId=-1
      then Name:=pic
      else Name:=FText[TxtId];
    Image:=ImageList.Items[PIC_ID];
    Image.SystemMemory:=true;
    Width:=Image.Width;
    Height:=Image.Height;
    Left:=FLeft+X;
    Top:=FTop+Y;
    Surface:=DxSurface;
    OnClick:=proc;
    OnClickR:=procR;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
function TDxScene.AddCreaPanel(CR: integer; x,y: integer; proc: TNotifyEvent=nil; TxtId: integer=-1):integer;
var
  DxO_ID, PIC_ID:integer;
begin
  PIC_ID:=LoadUnit(CR,CR,ImageList);
  DxO_ID:=ObjectList.Add(TDXWPanel.Create(self));
  with TDXWPanel(ObjectList[DxO_ID]) do
  begin
    Name:=iCrea[CR].name;
    Image:=ImageList.Items[PIC_ID];
    Image.SystemMemory:=true;
    Left:=FLeft+X;
    Top:=FTop+Y;
    Surface:=DxSurface;
    OnClick:=proc;
  end;
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.ChgBuildPanel(DxO_ID:integer;Def: string);
var
  PIC_ID: integer;
  p: integer;
  s:string;
  Path: string;
  PicList: TStringList;
  NewDib: TBitmap;
  PicFile : string;
  pic,picOver,picRegion: string ;
begin
  PIC_ID:=ImageList.Items.IndexOf(Def);
  picOver:='TO'+DEF;
  picRegion:='TZ'+DEF;

  if PIC_ID=-1 then
  begin
    PicList:=TStringList.Create;
    Path:=Folder.Sprite+Def+'\';
    PicList.LoadFromFile(Path+Def+'.txt');
    Pic:= Piclist[12];
    PicFile:=Path+Pic;

    NewDIB:= TBitmap.Create;
    NewDib.LoadFromFile(PicFile);
    NewDib.Width:= strtoint((copy(picList[3],2,length(picList[3])-2)));
    NewDib.Height:=strtoint((copy(picList[5],2,length(picList[5])-2)));

    with TPictureCollectionItem.Create(ImageList.Items) do
    begin
      Picture.Graphic := Newdib;
      Name:=Def;
      PatternHeight:=NewDIB.Height;
      PatternWidth:=NewDIB.Width;
      SkipHeight:=0;
      SkipWidth:=0;
      Transparent:=True;
      TransparentColor:=ClAqua;
      SystemMemory:=true; //opMemory
      Restore;
    end;
    PIC_ID:=ImageList.Items.Count-1;
    NewDIB.Free;
    picList.free;

    p:=ANSIPOS('.',pic);
    s:=copy(pic,3,p-3);
    p:=LoadBmp(ImageList,'TO'+s);
    ImageList.Items[p].Name:='TO'+DEF;
    p:=LoadBmp(ImageList,'TZ'+s);
    ImageList.Items[p].Name:='TZ'+DEF;
  end;

  TDXWPanel(ObjectList[DxO_ID]).Image:=ImageList.Items[PIC_ID];
  AddSprPanelMouseOverImage(DxO_ID,picOver);
  AddSprPanelRegionImage(DxO_ID,picRegion);
end;
{----------------------------------------------------------------------------}
function TDxScene.AddBuildPanel(Def: string; x,y: integer; proc: TNotifyEvent=nil; TxtId: integer=-1): integer;
var
  PIC_ID: integer;
  p: integer;
  s:string;
  Path: string;
  PicList: TStringList;
  NewDib: TBitmap;
  PicFile : string;
  pic,picOver,picRegion: string ;
  DxO_ID:integer;
begin
  PIC_ID:=ImageList.Items.IndexOf(Def);
  picOver:='TO'+DEF;
  picRegion:='TZ'+DEF;
  if PIC_ID=-1 then
  begin
    PicList:=TStringList.Create;
    Path:=Folder.Sprite+Def+'\';
    if FileExists(Path+'\'+Def+'.txt')
    then PicList.LoadFromFile(Path+Def+'.txt')
    else
    begin
         Path:=Folder.Sprite+'TBCSMAGE\';
         PicList.LoadFromFile(Path+'TBCSMAGE.txt')
    end;
    Pic:= Piclist[12];
    PicFile:=Path+Pic;

    NewDIB:= TBitmap.Create;
    NewDib.LoadFromFile(PicFile);
    NewDib.Width:= strtoint((copy(picList[3],2,length(picList[3])-2)));
    NewDib.Height:=strtoint((copy(picList[5],2,length(picList[5])-2)));

    with TPictureCollectionItem.Create(ImageList.Items) do
    begin
      Picture.Graphic := Newdib;
      Name:=Def;
      PatternHeight:=NewDIB.Height;
      PatternWidth:=NewDIB.Width;
      SkipHeight:=0;
      SkipWidth:=0;
      Transparent:=True;
      TransparentColor:=ClAqua;
      SystemMemory:=true; //opMemory
      Restore;
    end;
    PIC_ID:=ImageList.Items.Count-1;
    NewDIB.Free;
    picList.free;

    p:=ANSIPOS('.',pic);
    s:=copy(pic,3,p-3);
    p:=LoadBmp(ImageList,'TO'+s);
    if p > -1 then ImageList.Items[p].Name:='TO'+DEF;
    p:=LoadBmp(ImageList,'TZ'+s);
    if p > -1 then ImageList.Items[p].Name:='TZ'+DEF;
  end;

  DxO_ID:=ObjectList.Add(TDXWPanel.Create(self));

  with TDXWPanel(ObjectList[DxO_ID]) do
  begin
    if TxtId=-1
      then Name:=Def
      else Name:=FText[TxtId];
    Image:=ImageList.Items[PIC_ID];
    Image.SystemMemory:=true; //opMemory
    Left:=FLeft+X;
    Top:=FTop+Y;
    Surface:=DxSurface;
    OnClick:=proc;
  end;

  AddSprPanelMouseOverImage(DxO_ID,picOver);
  AddSprPanelRegionImage(DxO_ID,picRegion);
  result:=DxO_ID;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.ChgSprPanel(DxO_ID:integer; DefName: string);
var
  PIC_ID: integer;
begin
  PIC_ID:=LoadSprite(ImageList,DefName);
  with TDXWPanel(ObjectList[DxO_ID]) do
  begin
    Name:=DefName;
    Image:=ImageList.Items[PIC_ID];
    Image.Restore;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.AddSprPanelSelectedImage(DxO_ID:integer;pic: string);
var
  PIC_ID: integer;
begin
  PIC_ID:=ImageList.Items.IndexOf(pic);
  if PIC_ID=-1 then PIC_ID:=LoadBmp(ImageList,pic);
  with TDXWPanel(ObjectList[DxO_ID]) do
    SelectedImage:=ImageList.Items[PIC_ID];
end;
{----------------------------------------------------------------------------}
procedure TDxScene.AddSprPanelRegionImage(DxO_ID:integer;pic: string);
var
  PIC_ID: integer;
begin
  PIC_ID:=ImageList.Items.IndexOf(pic);
  if PIC_ID=-1 then PIC_ID:=LoadBmp(ImageList,pic);
  if PIC_ID>-1 then TDXWPanel(ObjectList[DxO_ID]).MouseRegionImage:=ImageList.Items[PIC_ID];
end;
{----------------------------------------------------------------------------}
procedure TDxScene.AddSprPanelMouseOverImage(DxO_ID:integer;pic: string);
var
  PIC_ID: integer;
begin
  PIC_ID:=ImageList.Items.IndexOf(pic);
  if PIC_ID=-1 then PIC_ID:=LoadBmp(ImageList,pic);
  if PIC_ID>-1 then TDXWPanel(ObjectList[DxO_ID]).MouseOverImage:=ImageList.Items[PIC_ID];
end;
{----------------------------------------------------------------------------}
procedure TDxScene.UpdateColor(PL, nImage: integer);
var
  newCol: TRGBQuad;
  i,c:integer;
const
  RD: array [0..7] of byte =  (255,0  ,200,34  ,255,120,0  ,0  );
  GR: array [0..7] of byte =  (40 ,0  ,170,140  ,128,60 ,0  ,0  );
  BL: array [0..7] of byte =  (40 ,210,125,34  ,64,120,0  ,0 );
begin
  if PL<0 then exit;
  for i:=0 to nImage-1 do
  with ImageList.items[i].Picture.Bitmap do
  begin

    for c:=224 to 255 do //i:=145;
    begin
      GetDIBColorTable(DXMAIN.DXDIBREF.DIB.Canvas.Handle,  c, 1, newCol);
      case PL of
        0:        //clRed:
        begin
           newcol.rgbgreen:=0;;
           newcol.rgbred:=newcol.rgbblue;
           newcol.rgbblue:=0;
        end;
        2:       // clMaroon     $0052759C
        begin
           newcol.rgbgreen:=trunc(0.6*newcol.rgbblue);
           newcol.rgbred:=newcol.rgbblue;
           newcol.rgbblue:=0;
        end;
        3:        //clGreen       $00299642
        begin
           newcol.rgbgreen:=newcol.rgbblue;
           newcol.rgbred:=trunc(0.2*newcol.rgbblue);;
           newcol.rgbblue:=trunc(0.1*newcol.rgbblue);;
        end;
        4:        //clOrange      $000082FF
        begin
           newcol.rgbgreen:=trunc(0.4*newcol.rgbblue);
           newcol.rgbred:=newcol.rgbblue;
           newcol.rgbblue:=trunc(0.1*newcol.rgbblue);
        end;
        5:        //clPurple:     $00A52C8C:
        begin
           newcol.rgbgreen:=trunc(0.2*newcol.rgbblue);;
           newcol.rgbred:=newcol.rgbblue;
        end;
        6:        //clAqua       $00A59A08:
        begin
           newcol.rgbgreen:=newcol.rgbblue;
           newcol.rgbred:=0;
           //newcol.rgbblue:=newcol.rgbblue ;
        end;
        7:        //clFuchsia    $008C79C6:
        begin
           newcol.rgbgreen:=trunc(0.2*newcol.rgbblue);
           newcol.rgbred:=newcol.rgbblue;;
           newcol.rgbblue:=trunc(0.7*newcol.rgbblue);
        end;
      end;
      SetDIBColorTable(Canvas.Handle, c, 1, newcol);
    end;
    ImageList.items[i].restore;
  end;

  if (BackGround>  nImage-1) then
  with ImageList.items[BackGround].Picture.Bitmap do
  begin
    for c:=224 to 255 do
    begin
      GetDIBColorTable(DXMAIN.DXDIBREF.DIB.Canvas.Handle,  c, 1, newCol);
      case PL of
        0:        //clRed:
        begin
           newcol.rgbgreen:=0;;
           newcol.rgbred:=newcol.rgbblue;
           newcol.rgbblue:=0;
        end;
        2:       // clMaroon     $0052759C
        begin
           newcol.rgbgreen:=trunc(0.6*newcol.rgbblue);
           newcol.rgbred:=newcol.rgbblue;
           newcol.rgbblue:=0;
        end;
        3:        //clGreen       $00299642
        begin
           newcol.rgbgreen:=newcol.rgbblue;
           newcol.rgbred:=trunc(0.2*newcol.rgbblue);;
           newcol.rgbblue:=trunc(0.1*newcol.rgbblue);;
        end;
        4:        //clOrange      $000082FF
        begin
           newcol.rgbgreen:=trunc(0.4*newcol.rgbblue);
           newcol.rgbred:=newcol.rgbblue;
           newcol.rgbblue:=trunc(0.1*newcol.rgbblue);
        end;
        5:        //clPurple:     $00A52C8C:
        begin
           newcol.rgbgreen:=trunc(0.2*newcol.rgbblue);;
           newcol.rgbred:=newcol.rgbblue;
        end;
        6:        //clAqua       $00A59A08:
        begin
           newcol.rgbgreen:=newcol.rgbblue;
           newcol.rgbred:=0;
           //newcol.rgbblue:=newcol.rgbblue ;
        end;
        7:        //clFuchsia    $008C79C6:
        begin
           newcol.rgbgreen:=trunc(0.2*newcol.rgbblue);
           newcol.rgbred:=newcol.rgbblue;;
           newcol.rgbblue:=trunc(0.7*newcol.rgbblue);
        end;
      end;
      SetDIBColorTable(Canvas.Handle, c, 1, newcol);
    end;
    ImageList.items[BackGround].restore;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.LoadDxG;
begin
  LogP.Insert('-BEG LoadDxG_'+name);
  ImageList:= TDXImageList.create(nil);
  DXDraw:=DXMain.DXDraw;
  if FileExists(Folder.Dxg + FName+'.dxg') then
  begin
    ImageList.Items.LoadFromfile(Folder.Dxg + FName+'.dxg');
    //SavePicNanme;
  end;
  LogP.Insert('-END LoadDxG_'+name);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.SaveDxG;
begin
  ImageList.Items.SaveToFile(folder.dxg + Name+'.dxg');
end;
{----------------------------------------------------------------------------}
procedure TDxScene.SavePicName;
var
  i:integer;
  sl:TStringList;
begin
  sl:=TStringList.create;
  for i:=0 to ImageList.Items.Count -1 do
    sl.add( ImageList.Items[i].Name );
  sl.SaveToFile(folder.dxg + FName+'.txt');
  sl.free;
end;
{----------------------------------------------------------------------------}
constructor TDxScene.Create(name:string);
begin
  inherited Create;
  Initialized:=false;
  Drawing:=false;
  LogP.EnterProc('Begin_CreateScene_'+name);
  FName:=Name;
  LoadDxg;

  ObjectList:=TDXWObjectList.Create;

  AllClient:=false;
  fHeight:=600;
  fWidth:=800;
  Background:=-1;
  FLeft:=0;
  FTop:=0;
  FHintX:=60;
  FHintY:=558;

  DxMouse.Id:=CrDef;
  DxMouse.Style:=CrDef;
  Redraw:=true;
  LogP.Insert('-END_Create__'+name); // we quit proc on addscene
end;
{----------------------------------------------------------------------------}
procedure TDxScene.AddSubScene;
begin
  Initialized:=true;
  Visible:=true;
  //SaveDxG;
  LogP.QuitProc('Endof_AddSubScene_'+name);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.AddScene;
begin
  DxMain.AddScene(self);
  if Parent <> Nil then Parent.SaveSurface;
  Hint:='';
  Initialized:=true;
  Visible:=true;
  //SaveDxG;
  LogP.QuitProc('Endof_AddScene_'+name);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.SaveSurface;
begin
  MyRect:=Rect(left,top,left+fWidth,top+fHeight);
  LastSurface.Draw(left,top,MyRect,DxSurface, false);
  Screenshot;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.AddPopScene;
begin
  DxMain.AddScene(self);
  FPop:=true;
  if Parent <> Nil then Parent.SaveSurface;
  Hint:='';
  FHintY:=800;
  Initialized:=true;
  Visible:=true;
  OnMouseUp:=SnPopMouseUp;
  //SaveDxG;
  LogP.QuitProc('Endof_AddPopScene_'+name);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.SnPopMouseUp(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CloseScene;
end;
{----------------------------------------------------------------------------}
destructor TDxScene.Destroy;
begin
  LogP.EnterProc('Begin_DelScene_'+name);
  ObjectList.Free;
  FreeAndNil(ImageList);
  LastSurface.Free;
  inherited Destroy;
  LogP.QuitProc('Endof_DelScene_'+name);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.ScreenShot;
var
 B: TBitmap;
begin
  B:= TBitmap.Create;
  B.assign(LastSurface) ;
  B.SaveToFile(folder.src+'\screenshot\'+ name+ '.bmp');
  B.free;
end;
{----------------------------------------------------------------------------}
function TDxScene.CanDraw:boolean;
begin
  result:= Initialized and Visible;
  result:= result and not(AutoDestroy);
  result:= result and not(Drawing);
end;


{----------------------------------------------------------------------------}
procedure TDxScene.DrawBasic;
begin
  if Background>-1
  then ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DoDraw;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.DoDraw;
begin
  if CanDraw=false then Exit;
  Drawing:=true;
  if AutoRefresh then DoRefresh;
  if Assigned(FOnDraw)
  then FOnDraw(self)
  else DrawBasic;;
  ShowHint;
  Drawing:=false;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.ProcessAction;
begin
end;
{----------------------------------------------------------------------------}
procedure TDxScene.DoRefresh;
begin
  if Assigned(FOnRefresh) then FOnRefresh(self);
  AutoRefresh:=false;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.ShowHint;
begin
  if AutoDestroy then exit;
  if Hint='' then exit;
  with DxSurface.Canvas do
  begin
    Brush.Style:=bsClear;
    Font.Color:=ClText;
    Font.Name:='MS Sans Serif';
    Font.Size:=8;
    Textout(HintX,HintY,Hint);
    Release;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.KeyDown(var Key: Word; Shift: TShiftState);
begin
  ObjectList.KeyDown(Key,Shift);
  if Assigned(FOnKeyDown) then FOnKeyDown(Self,Key,Shift);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.KeyPress(var Key: char);
begin
  ObjectList.KeyPress(Key);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.KeyUp(var Key: Word; Shift: TShiftState);
begin
  ObjectList.KeyUp(Key,Shift);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if not(Initialized) then exit ;
  ObjectList.MouseDown(Button,Shift,X,Y);
  if Assigned(FOnMouseDown) then FOnMouseDown(self,Button,Shift,X,Y);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DxO_ID, i,j: integer;
begin
  Hint:='';
  ObjectList.MouseMove(Shift,X,Y);
  DxO_ID:=ObjectList.DxO_MouseOver;
  if (DxO_ID>-1) and (FHintX >0)
    then
    begin
      Hint:=ObjectList.Items[DxO_ID].name;  // without extra {}
      i:=ANSIPOS('{',Hint);
      j:=ANSIPOS('}',Hint);
      if i > 0 then Hint:=copy(Hint,i+1,j-i-1) else hint:='';
    end;
  if Assigned(FOnMouseMove)
    then FOnMouseMove(self,Shift,X,Y);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Assigned(FOnMouseUp)
    then FOnMouseUp(self,Button,Shift,X,Y);
  ObjectList.MouseUp(Button,Shift,X,Y);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.SetDXDraw(Value: TCustomDXDraw);
begin
  FDXDraw:=Value;
  ImageList.DXDraw:=Value;
  DxSurface:=FDXDraw.surface;
  LastSurface := TDirectDrawSurface.Create(FDXDraw.DDraw);
  LastSurface.SetSize(FDXDraw.Width,FDXDraw.Height);
  LastSurface.FillRect(Rect(0,0,800,600),DxBlack);
  LastSurface.SystemMemory:=true;
  MyRect.Left:=0;
  MyRect.Top:=0;
  MyRect.Right:=DxSurface.Width;
  MyRect.Bottom:=DxSurface.Height;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.ShowHintClick(Sender: TObject);
begin
   processInfo(TDxwObject(sender).name);
end;
{----------------------------------------------------------------------------}
procedure TDxScene.BtnOK(Sender:TObject);
begin
  mDialog.res:=1;
  DxMouse.style:=msAdv;
  DxMouse.id:=crDef;
  CloseScene;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.BtnCancel(Sender:Tobject);
begin
  mDialog.res:=0;
  CloseScene;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.CloseScene;
begin
  AutoDestroy:=true;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.SetAutoDestroy(Value: boolean);
begin
  FAutoDestroy:=true;
  If Parent <> nil then begin
    DxScene:=Parent;
    if fPop=false then DxScene.AutoRefresh:=true;
    DxScene.Visible:=true;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.SetLeft(Value: integer);
var
  i: integer;
begin
  for i:=0 to ObjectList.Count -1 do
    TDXWObject(ObjectList[i]).left:= TDXWObject(ObjectList[i]).left + Value - FLeft;
  FLeft:=Value;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.SetTop(Value: integer);
var
  i: integer;
begin
  for i:=0 to  ObjectList.Count -1 do
    TDXWObject(ObjectList[i]).Top:= TDXWObject(ObjectList[i]).Top + Value - FTop;
  FTop:=Value;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.Hide;
begin
  Visible:=false;
end;
{----------------------------------------------------------------------------}
procedure TDxScene.Show;
begin
  Visible:=true;
end;
{----------------------------------------------------------------------------}
end.
