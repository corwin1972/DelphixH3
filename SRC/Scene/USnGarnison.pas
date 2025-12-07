unit USnGarnison;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DXWScene, DxWLoad , UFile;

type
  TSnGarnison= class (TDxScene)
  private
    DxO_Gar, DxO_Vis: integer;
    hid: integer;
    FocusedSlot:integer;
    procedure PnlGarCrea(Sender: TObject);
    procedure PnlVisCrea(Sender: TObject);
    procedure BtnSep(Sender: TObject);
    procedure BtnHero(Sender: TObject);
  public
    constructor Create(HE,oid: integer);
    procedure SnRefresh(Sender:TObject);
    procedure SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  end;

var
  SnGarnison: TSnGarnison;

implementation

uses UMain, USnHero, USnInfoCrea, USnBook, USnDialog, UType, UArmy;

{----------------------------------------------------------------------------}
constructor TSnGarnison.Create(HE,oid: integer);
var
  i: integer;
begin
  inherited Create('SnGarnison');

  pObj:=@mobjs[oid];
  hid:=HE;
  gArmy.init(pObj.Armys,mHeros[Hid].Armys);
  gArmy.pHE[0]:=HE; //TODO check if required
  Left:=50;
  HintY:=350;
  AddBackground('GARRISON');
  AddImage('HPSYYY');
  AddTitleScene('Garnison',20);
  AddSprPanel('AVCGAR10',195,45);
  AddSprPanel('HPL',29,223,BtnHero);
  DxO_Gar:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
     AddSprPanel('TWCRPORT',93+62*i,127,PnlGarCrea);
     AddSprPanelSelectedImage(Objectlist.count-1,'TPTAVSEL');
  end;

  DxO_Vis:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
    AddSprPanel('TWCRPORT',93+62*i,223,PnlVisCrea);
    AddSprPanelSelectedImage(Objectlist.count-1,'TPTAVSEL');
  end;
  AddButton('IOKAY',399,314,BtnOK);
  AddButton('IDV6432',88,314,BtnSep);
  OnMouseMove:=SnMouseMove;
  OnRefresh:=SnRefresh;
  UpdateColor(mPL,1);
  SnRefresh(self);
  AddScene;
end;

procedure TSnGarnison.BtnSep(Sender: TObject);
var
  i: integer;
begin
  if FocusedSlot=-1 then exit;
  gArmy.sep:=true;
  for i:=0 to MAX_ARMY do
  begin
    if TDXWPanel(ObjectList[DxO_Vis+i]).tag=0 then TDXWPanel(ObjectList[DxO_Vis+i]).Focused:=true;
    if TDXWPanel(ObjectList[DxO_Gar+i]).tag=0 then TDXWPanel(ObjectList[DxO_Gar+i]).Focused:=true;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGarnison.SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  slot: integer;
begin
  slot:=ObjectList.DxO_MouseOver-DxO_Gar;
  case slot of
    0..6:   Hint:=gArmy.Hint(1,slot);       //MAX_ARMY
    7..13:  Hint:=gArmy.Hint(2,slot-6);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGarnison.SnRefresh(Sender:TObject);
var
  i:integer;
  CR,nCR:integer;
begin
  TDXWPanel(ObjectList[DxO_Gar-1]).tag:=Hid;
  with mHeros[Hid] do
  begin
    for i:=0 to MAX_ARMY do
    begin
      TDXWPanel(ObjectList[DxO_Vis+i]).visible:=true;
      CR:= Armys[i].t;
      nCR:=Armys[i].n;
      if CR > -1
      then
      begin
        TDXWPanel(ObjectList[DxO_Vis+i]).tag:=CR+2;
        TDXWPanel(ObjectList[DxO_Vis+i]).caption:=inttostr(nCR);
      end
      else
      begin
        TDXWPanel(ObjectList[DxO_Vis+i]).tag:=0;
        TDXWPanel(ObjectList[DxO_Vis+i]).caption:='';
      end;
    end;
  end ;


  for i:=0 to MAX_ARMY do
  begin
    CR:= pObj.Armys[i].t;
    nCR:=pObj.Armys[i].n;
    if CR > 0
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
end;
{----------------------------------------------------------------------------}
procedure TSnGarnison.PnlGarCrea(Sender: TObject);
begin
  FocusedSlot:=ObjectList.DxO_MouseOver-(DxO_Gar);
  TDxWPanel(sender).Focused:=gArmy.Select(1,FocusedSlot); //1= Gar
  AutoRefresh:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnGarnison.PnlVisCrea(Sender: TObject);
begin
  FocusedSlot:=ObjectList.DxO_MouseOver-(DxO_Vis);
  TDxWPanel(sender).Focused:=gArmy.Select(2,FocusedSlot); //2=vis
  AutoRefresh:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnGarnison.BtnHero(Sender: TObject);
begin
  TSnHero.Create(HID,false);
end;

end.
