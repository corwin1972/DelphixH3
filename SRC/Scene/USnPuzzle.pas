unit USnPuzzle;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnPuzzle= class (TDxScene)
  public
    selectedPuzzle: integer;
    constructor Create;
    procedure SnDraw(Sender:TObject);
    procedure BtnPuzzle(Sender: TObject);
    procedure SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

  end;

var
  SnPuzzle:TSnPuzzle;

implementation

uses UMain, USnHero, UType;

constructor TSnPuzzle.Create;
var
  i: integer;
  s:string;
  CT:integer;
begin
  if mPLayers[mPL].isCPU then
  begin
    mDialog.res:=1;
    exit;
  end;

  inherited Create('SnPuzzle');
  ALLClient:=true;
  selectedPuzzle:=-1;
  Left:=0;
  Top:=0;
  AddBackground('Puzzle');

  CT:=random(8);
  s:=TNext2[CT];
  for i:=0 to 47 do
    loadBmp(ImageList,format('PUZCAS%2.2d',[i]) );
  for i:=0 to 47 do
    //AddPanel(format('PUZCAS%2.2d',[i]),5+ 70*(i div 6), 5+ 63*(i mod 6),BtnPuzzle);
    AddPanel(format('PUZ%s%2.2d',[s,i]),iPuzzle[CT,i].pos.x, iPuzzle[CT,i].pos.y,BtnPuzzle);


  AddPanel('PUZZLOGO',607,1);
  AddButton('IOKAY',690,540,BtnOK);
  UpdateColor(mPL,1);

  OnDraw:=SnDraw;
  OnMouseMove:=SnMouseMove;
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnPuzzle.SnDraw(Sender:TObject);
begin
  if Background>-1
  then ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DoDraw;
end;
{----------------------------------------------------------------------------}
procedure TSnPuzzle.BtnPuzzle(Sender: TObject);
begin
  if selectedPuzzle=-1 then
     selectedPuzzle:= ObjectList.DxO_MouseOver
  else selectedPuzzle:=-1;
end;
{----------------------------------------------------------------------------}
procedure TSnPuzzle.SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if selectedPuzzle <>-1 then
  begin
    TDXWPanel(ObjectList[selectedPuzzle]).left:=DxMouse.x;
    TDXWPanel(ObjectList[selectedPuzzle]).top:=DxMouse.y;
    TDXWPanel(ObjectList[selectedPuzzle]).caption:= format('id=%d, pos %d, %d',[selectedPuzzle-1,DxMouse.X,DxMouse.y]);
  end;
end;

end.
