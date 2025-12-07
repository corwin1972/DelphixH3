unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DXSounds, DXSprite, DXDraws, DXClass, DXWScene, DXWLoad, StdCtrls,
  DXPlay, UType, MMSystem, DxWave, UFile, DXInput, ExtCtrls, DIB;

type
  TDXMain = class(TDXForm)
    DXImageList: TDXImageList;
    DXCursorList: TDXImageList;
    DXEngine: TDXSpriteEngine;
    DXSound: TDXSound;
    DXWaveList: TDXWaveList;
    DXPlay: TDXPlay;
    DXDIBREF: TDXDIB;
    DXTimer: TDXTimer;
    DxDraw: TDXDraw;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DXTimerTimer(Sender: TObject; LagCount: Integer);
    procedure DXDrawInitialize(Sender: TObject);
    procedure DXDrawFinalize(Sender: TObject);
    procedure DXSoundInitialize(Sender: TObject);
    procedure AddSound(SoundName: string);
    procedure DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DXDrawMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DXDrawMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DrawScreen;
    procedure DxDrawRestoreSurface(Sender: TObject);
  private
    { Private declarations }
    DxAction : boolean;
    procedure ProcessAction;
    procedure DrawScenes;
    procedure DrawInfo;
    procedure DrawCursor;
    procedure CleanScenes;
    procedure DelScene(sn: TDxScene);
    procedure PlaySound(const Name: string; Wait: Boolean);
    procedure SwitchFullScreen;
  public
    { Public declarations }
    procedure AddScene(sn:TDxScene);
  end;

var
  DxMain:  TDxMain;
  DxScene: TDxScene;
  DxSceneList: TList;
  DxMouse: TDxMouse;
  DxBlack: integer;
const
  FullScreen=false;

implementation

{$R *.dfm}

uses USnMenu,USnGame;

{----------------------------------------------------------------------------}
procedure TDXMain.DXTimerTimer(Sender: TObject; LagCount: Integer);
begin
  CleanScenes;
  if (DxScene=nil) then Exit;
  DxAction:= not(DxAction);
  if DxAction
  then ProcessAction
  else DrawScreen;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.ProcessAction;
begin
  DxScene.ProcessAction;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DrawScreen;
begin
  if DXDraw.CanDraw then
  begin
    DrawScenes;
    DrawInfo;
    DrawCursor;
    DXDraw.Flip;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.CleanScenes;
var
  i: integer;
begin
  i:=0;
  while i<DxSceneList.Count  do
  begin
    if TDxScene(DxSceneList[i]).AutoDestroy
    then DelScene(TDxScene(DxSceneList[i]))
    else inc(i);
  end;
  if DxSceneList.count=0
    then Application.Terminate;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.AddScene(sn:TDxScene);
begin
  DxMouse.id:=CrDef;
  sn.Parent:=DxScene;
  DxSceneList.Add(sn);
  DxScene:=sn;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DelScene(sn:TDxScene);
begin
  sn.Visible:=false;
  DxSceneList.Remove(sn);
  DxSceneList.Capacity:=DxSceneList.Count;
  sn.Destroy;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DrawScenes;
var
  i,DxMainScene: integer;
begin
  DxMainScene:=0;
  for i:=DxSceneList.Count-1 downto 0 do
  begin
    DxMainScene:=i;
    if TDxScene(DxSceneList[i]).AllClient then Break
  end;
  for i:=DxMainScene to DxSceneList.Count-1 do
  begin
    TDxScene(DxSceneList[i]).DoDraw;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DrawCursor;
var
  offx, offy : integer;
begin
  with DxMouse do
  if style=msAdv then
  begin
    case id of
      CrDef    :  begin offx:=0;  offy:=0;  end;
      CrFight  :  begin offx:=0;  offy:=0;  end;
      CrMoveNN :  begin offx:=6;  offy:=0;  end;
      CrMoveWW :  begin offx:=0;  offy:=6;  end;
      CrMoveSS :  begin offx:=6;  offy:=20; end;
      CrMoveEE :  begin offx:=20; offy:=6;  end;
      CrMoveNE :  begin offx:=20; offy:=0;  end;
      CrMoveNW :  begin offx:=0;  offy:=0;  end;
      CrMoveSE :  begin offx:=20; offy:=20; end;
      CrMoveSW :  begin offx:=0;  offy:=20; end;
      else        begin offx:=16; offy:=16; end;
    end;
    DxCursorList.Items.Find('CRADVNTR').Draw(DXDraw.Surface,DxMouse.x-offx,DxMouse.y-offy,id);
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DrawInfo;
var
  s:string;
begin
  s:='Heroes III ';
  s:=s+format('FPS=%d ',[DXTimer.FrameRate]);
  if DxScene <> nil then
  begin
    s:=s+ ' Total Scenes=' + inttostr(DxSceneList.Count) +' Active Scene='+ DxScene.Name;
    s:=s+format(' Mouse[%d_%d] ID=%d',[DxMouse.X-DxScene.left,DxMouse.Y-DxScene.top,DxMouse.id]);
    if DxScene=SnGame then s:=s+ ' SpriteCount='+ inttostr(DXEngine.Engine.DrawCount);
  end;
  caption:=s;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DXDrawInitialize(Sender: TObject);
begin
  DxBlack:=DXDraw.Surface.ColorMatch(clBlack);
  LoadSprite(DxCursorList,'CRADVNTR');
  DXDraw.Cursor:=crNone;
  DxMouse.id:=crDef;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DXDrawFinalize(Sender: TObject);
begin
  DXTimer.Enabled:=False;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.FormCreate(Sender: TObject);
begin
  SwitchFullscreen;
  mPL:=1;
  DxSceneList:=TList.Create;
  DxScene:=TSnMenu.Create;
  DXTimer.Enabled:=True;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.FormDestroy(Sender: TObject);
begin
  DXTimer.Enabled:=False;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  DxMouse.X:=X;
  DxMouse.Y:=Y;
  DxScene.MouseMove(Shift,X,Y);
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DXDrawMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DxMouse.Button:=Button;
  DxMouse.X:=X;
  DxMouse.Y:=Y;
  DxScene.MouseDown(Button,Shift,X,Y);
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DXDrawMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DxMouse.Button:=Button;
  DxMouse.X:=X;
  DxMouse.Y:=Y;
  DxScene.MouseUp(Button,Shift,X,Y);
end;
{----------------------------------------------------------------------------}
procedure TDXMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  DxScene.KeyDown(Key,Shift);
end;
{----------------------------------------------------------------------------}
procedure TDXMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  DxScene.KeyPress(Key);
end;

{----------------------------------------------------------------------------}
procedure TDXMain.DxDrawRestoreSurface(Sender: TObject);
var
  i: integer;
begin
  if DxSceneList= nil then exit;
  for i:=0 to DxSceneList.Count-1 do
  begin
    TDxScene(DxSceneList[i]).Drawing:=false;
  end;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.SwitchFullScreen;
begin
  DXDraw.Finalize;
  if not(FullScreen)  then
  begin
    RestoreWindow;
    DXDraw.Cursor := crDefault;
    BorderStyle := bsSingle;
    ClientWidth:=800;
    ClientHeight:=600;
    DXDraw.Options := DXDraw.Options - [doFullScreen];
    DXDraw.Options := DXDraw.Options + [doFlip];
  end else
  begin
    StoreWindow;
    DXDraw.Cursor  := crNone;
    BorderStyle    := bsNone;
    DXDraw.Options := DXDraw.Options + [doFullScreen];
    DXDraw.Options := DXDraw.Options - [doFlip];
  end;
  DXDraw.Initialize;
end;
{----------------------------------------------------------------------------}
procedure TDXMain.PlaySound(const Name: string; Wait: Boolean);
begin
  DXWaveList.Items.Find(Name).Play(Wait);
end;
{----------------------------------------------------------------------------}
procedure TDXMain.DXSoundInitialize(Sender: TObject);
var
  WaveFormat:TWaveFormatEx;
begin
  MakePCMWaveFormatEx(WaveFormat,22050,16,1);
  DXSound.Primary.SetFormat(WaveFormat);
  //AddSound('Test.wav');
  //AddSound('HORSE00.wav');
  //PlaySound('Test.wav', false);
end;
{----------------------------------------------------------------------------}
procedure TDXMain.AddSound(SoundName: string);
begin
  with TWaveCollectionItem.Create(DXWaveList.Items) do
  begin
    Name:=SoundName;
    Wave.LoadFromFile(folder.sound+Name);
    Restore;
  end;
end;
end.

