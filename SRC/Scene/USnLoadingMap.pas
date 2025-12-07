unit USnLoadingMap;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene, UConst;

type

  TSnLoadingMap= class (TDxScene)
  public
    DrawCounter,WaitCounter: integer;
    DxO_ProgressionSquare,
    DxO_ProgressionLabel,
    DxO_MapInfo: integer;
    constructor Create;
    procedure SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SnDraw(Sender: TObject);
    procedure SnRefresh(Sender:TObject);
    procedure ProcessAction; override;
  end;

var
  SnLoadingMap: TSnLoadingMap;

implementation

uses UMain, USnSelect, UType, USnGame, UFile, UMap;

{----------------------------------------------------------------------------}
Constructor TSnLoadingMap.Create;
var
  i: integer;
begin
  inherited Create('SnLoadingMap');
  DrawCounter:=0;
  AllClient:=True;
  AddBackground('Title');
  DxO_ProgressionSquare:=ObjectList.count;
  for i:=0 to 19 do
  begin
    AddSprPanel('LOADPROG',40+20*i,559);
    TDXWPanel(ObjectList[DxO_ProgressionSquare+i]).tag:=i;
    TDXWPanel(ObjectList[DxO_ProgressionSquare+i]).visible:=false;
  end;
  DxO_ProgressionLabel:=ObjectList.count;
  AddLabel_Yellow('Step',22,520,10);
  AddLabel_Yellow('Draw',22,540,10);
  AddLabel('FileName',410,60,10);
  AddLabel('Start at',410,100,10) ;
  DxO_MapInfo:=ObjectList.count;
  AddLabel(mData.fname,500,60,10) ;     //map name not yet loaded
  AddLabel('Total DEF',410,140,10) ;
  AddLabel('Total OBJ',410,180,10) ;
  AddLabel('START LOAD',500,100,10) ;
  AddLabel('START DEF',500,120,10) ;
  AddLabel('END DEF',500,140,10) ;
  AddLabel('START OBJ',500,160,10) ;
  AddLabel('END OBJ',500,180,10) ;
  HintY:=520;
  HintX:=200;
  OnMouseDown:=SnMouseDown;
  OnDraw:=SnDraw;
  OnRefresh:=SnRefresh;
  AddScene;
end;


{----------------------------------------------------------------------------}
procedure  TSnLoadingMap.SnDraw(sender: TObject);
begin
  if mData.LoadStep < 20 then
  begin
    SnRefresh(self);
     //if Background>-1 then
    ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
    ObjectList.DoDraw;
  end
  else
  DxSurface.FillRect(Rect(0,0,800,600),DxBlack)
end;
{----------------------------------------------------------------------------}
procedure TSnLoadingMap.ProcessAction;
begin
  case mData.LoadStep of
    -1   : Cmd_Map_Load(mData.fName);
    {19   : if not(SnGame.started) and (DrawCounter> WaitCounter)   then
       begin
         AllClient:=false;
         Autodestroy:=true;
         DxScene:=Sngame;
         SnGame.CreateGame;
       end;   }
  end;
end;

{----------------------------------------------------------------------------}
procedure TSnLoadingMap.SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if mData.LoadStep = 19 then
  begin
    if not(SnGame.started) and (DrawCounter> WaitCounter)  then
    begin
      AllClient:=false;
      Autodestroy:=true;
      DxScene:=Sngame;
      SnGame.CreateGame;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnLoadingMap.SnRefresh(Sender:TObject);
var
  i: integer;
begin
  for i:=0 to mData.LoadStep do
  begin
    TDXWLabel(Objectlist[DxO_ProgressionLabel]).caption:=  'LoadStep  '+ LOADSTEPDESC[mData.LoadStep];
    TDXWPanel(ObjectList[DxO_ProgressionSquare+i]).visible:=true;
  end;

  DrawCounter:=(DrawCounter+1) mod 60000;
  TDXWLabel(Objectlist[DxO_ProgressionLabel+1]).caption:='DrawCount '+ inttostr(DrawCounter) ;

  TDXWLabel(Objectlist[DxO_MapInfo+1]).caption:='DEF = ' + inttostr(nDef);
  TDXWLabel(Objectlist[DxO_MapInfo+2]).caption:='OBJ = ' + inttostr(nObjs);
  TDXWLabel(Objectlist[DxO_MapInfo+3]).caption:= mData.startload;
  TDXWLabel(Objectlist[DxO_MapInfo+4]).caption:= mData.startdef;
  TDXWLabel(Objectlist[DxO_MapInfo+5]).caption:= mData.enddef;
  TDXWLabel(Objectlist[DxO_MapInfo+6]).caption:= mData.startobj;
  TDXWLabel(Objectlist[DxO_MapInfo+7]).caption:= mData.endobj;
end;
end.
