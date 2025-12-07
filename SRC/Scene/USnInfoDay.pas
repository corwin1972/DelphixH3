unit USnInfoDay;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnInfoDay= class (TDxScene)
  private
    DxO_Pic: integer;
    Pic: integer;
    AnimCount: integer;
    AnimStart: boolean;

  public
    AnimEnd: boolean;
    constructor Create(SUB: boolean=false);
    procedure Init;
    procedure Start;
    procedure SnDraw(Sender:TObject);
  end;

var
  SnInfoDay:TSnInfoDay;

implementation

uses UMain, UType;
{----------------------------------------------------------------------------}
procedure TSnInfoDay.Init;
var
  i:integer;
begin
  for i:=0 to 4 do
    TDXWPanel(ObjectList[i+DxO_Pic]).visible:=false;
  AnimCount:=0;
  AnimStart:=false;
  AnimEnd:=false;
  if mData.day=0
  then
  begin
    pic:=mData.week+DxO_Pic;
    TDXWPanel(ObjectList[pic]).visible:=true;
    TDXWPanel(ObjectList[pic]).Tag:=0;
    TDXWLabel(ObjectList[5+DxO_Pic]).Caption:='Week ' +inttostr(mData.week+1);
  end
  else
  begin
    pic:=4+DxO_Pic;
    TDXWPanel(ObjectList[pic]).visible:=true;
    TDXWPanel(ObjectList[pic]).Tag:=0;
    TDXWlabel(ObjectList[5+DxO_Pic]).Caption:='Day ' +inttostr(mData.Day+1);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoDay.Start;
begin
  AnimStart:=true;
end;
{----------------------------------------------------------------------------}
constructor  TSnInfoDay.Create(SUB: boolean);
begin
  inherited Create('SnInfoDay');
  Left:=614;
  Top:=400;
  DxO_Pic:=ObjectList.Count;
  AddSprPanel('NEWWeek1',0,0);
  AddSprPanel('NEWWeek2',0,0);
  AddSprPanel('NEWWeek3',0,0);
  AddSprPanel('NEWWeek4',0,0);
  AddSprPanel('NEWDAY',0,0);
  AddLabel('Label Day of',70,10);
  AnimCount:=0;
  AnimStart:=false;
  AnimEnd:=false;
  OnDraw:=SnDraw;
  DxMouse.id:=CrDef;
  if SUB then AddSubScene else AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoDay.SnDraw;
begin
  with TDXWPanel(ObjectList[pic]) do begin
  if (animCount div 8)  < Image.PatternCount
  then Tag:=animCount div 8;
  ObjectList.DoDraw;
  if AnimStart then inc(animCount);
  if ((animCount div 8) = Image.PatternCount +4) then AnimEnd:=True;
  end;
end;
{----------------------------------------------------------------------------}
end.
