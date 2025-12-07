unit USnInfoGar;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type
  TSnInfoGar= class (TDxScene)
  private
    DxO_Gar: integer;
   public
    constructor Create;
    procedure Update(oid: integer);
    procedure KeyDown(Sender:TObject;var Key: Word; Shift: TShiftState);
  end;

var
  SnInfoGar:TSnInfoGar;

implementation

uses UMain,  UType;

{----------------------------------------------------------------------------}
constructor  TSnInfoGar.Create;
var
  i: integer;
begin
  inherited Create('SnInfoGar');
  Left:=614-9;
  Top:=400-11;
  OnKeyDown:=KeyDown;
  AddBackground('GARRIPOP');
  AddLabel('Garnison',110,26);
  DxO_Gar:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
     AddSprPanel('CPRSMALL',24+36*i,58);
     AddSprPanelSelectedImage(Objectlist.count-1,'TPTAVSEL');
  end;
  AddPopScene;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoGar.Update(oid: integer);
var
  i: integer;
  CR, nCR: integer;
begin
  redraw:=true;
  pobj:=@mobjs[oid];
  UpdateColor(pobj.pid,1);
  for i:=0 to MAX_ARMY do
  begin
    CR:= pobj.Armys[i].t;
    nCR:=pobj.Armys[i].n;
    if CR > -1
    then
    begin
      TDXWPanel(ObjectList[DxO_Gar+i]).tag:=CR+2;
      TDXWPanel(ObjectList[DxO_Gar+i]).caption:=inttostr(nCR);
    end
    else
    begin
      TDXWPanel(ObjectList[DxO_Gar+i]).tag:=0;
      TDXWPanel(ObjectList[DxO_Gar+i]).caption:='';
    end;
  end;
  visible:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoGar.KeyDown(Sender:TObject;var Key: Word; Shift: TShiftState);
begin
  CloseScene;
end;
{----------------------------------------------------------------------------}
end.
