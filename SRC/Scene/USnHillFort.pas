unit USnHillFort;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DXWScene, DxWLoad , UFile;

type
  TSnHillFort= class (TDXScene)
  private
    DxO_Vis, DxO_Btn: integer;
    hid: integer;
    FocusedSlot:integer;
    procedure PnlvisCrea(Sender: TObject);
    procedure BtnBuy1(Sender: TObject);
    procedure BtnBuyAll(Sender: TObject);
  public
    constructor Create(HE:integer);
    procedure SnRefresh(Sender:TObject);
    procedure SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  end;

var
  SnHillFort: TSnHillFort;

implementation

uses UMain, USnInfoCrea, USnBook, USnDialog, UType, UArmy;

{----------------------------------------------------------------------------}
constructor TSnHillFort.Create(HE: integer);
var
  i: integer;
begin
  inherited Create('SnHillFort');

  hid:=HE;
  gArmy.initHE(hid);
  Left:=100;
  Top:=100;
  HintX:=100;
  HintY:=420;
  AddBackground('APHLFTBK');
  AddTitleScene('Hill Fort',20);
  AddImage('HPSYYY');

  AddSprPanel('HPL',30,60);
  DxO_Vis:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
    AddSprPanel('TWCRPORT',107+76*i,60,PnlVisCrea);
    AddSprPanelSelectedImage( Objectlist.count-1,'TPTAVSEL');
  end;

  AddButton('IOKAY', 330, 270 ,BtnOK);

  DxO_Btn:=ObjectList.Count;
  for i:=0 to MAX_ARMY do
  begin
    AddButton('APHLF1R', 107+76*i, 171);  // impossible
    AddButton('APHLF1Y', 107+76*i, 171);  // done
    AddButton('APHLF1G', 107+76*i, 171, BtnBuy1);
    AddLabel_Center('0', 107+76*i, 128, 60 );
  end;

  AddButton('APHLF4G', 30, 231 ,BtnBuyAll);     // global buy
  AddLabel_Center('0', 30, 211, 60 );           // global cost
  OnMouseMove:=SnMouseMove;
  OnRefresh:=SnRefresh;
  UpdateColor(mPL,1);
  SnRefresh(self);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnHillFort.SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  slot: integer;
begin
  slot:=ObjectList.DxO_MouseOver;
  case slot of
    2..2 +MAX_ARMY:   Hint:=gArmy.Hint(0,slot-DxO_Vis);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnHillFort.SnRefresh(Sender:TObject);
var
  i:integer;
  CR,NB, Cost, TotalCost :integer;
{
1	Free
2	25% of normal
3	50% of normal
4	75% of normal
5–7	Normal
}
begin
  TotalCost:=0;
  with mHeros[Hid] do
  begin
    TDXWPanel(ObjectList[1]).tag:=hid;
    for i:=0 to MAX_ARMY do
    begin
      TDXWPanel(ObjectList[DxO_Vis+i]).visible:=true;
      TDXWPanel(ObjectList[DxO_Btn+4*i]).visible:=false;
      TDXWPanel(ObjectList[DxO_Btn+4*i+1]).visible:=false;
      TDXWPanel(ObjectList[DxO_Btn+4*i+2]).visible:=false;
      TDXWLabel(ObjectList[DxO_Btn+4*i+3]).visible:=false;
      CR:= Armys[i].t;
      NB:=Armys[i].n;
      if CR > -1
      then
      begin
        TDXWPanel(ObjectList[DxO_Vis+i]).tag:=CR+2;
        TDXWLabel(ObjectList[DxO_Vis+i]).caption:=inttostr(NB);
        if ((CR mod 2) =0)
        then
        begin
             TDXWPanel(ObjectList[DxO_Btn+4*i+2]).visible:=true;   // TODO
             TDXWLabel(ObjectList[DxO_Btn+4*i+3]).visible:=true;
             cost:=NB*(iCrea[CR+1].cost - iCrea[CR].cost);
             case (CR mod 14) of
               0:  cost:=0;
               2:  cost:=cost div 4;
               4:  cost:=cost div 2;
               6:  cost:= 3* (cost div 4);
             end;
             TDXWLabel(ObjectList[DxO_Btn+4*i+3]).caption:=inttostr(cost);
             totalcost:=totalcost+cost;
        end
        else TDXWPanel(ObjectList[DxO_Btn+4*i+1]).visible:=true;  // DONE

      end
      else
      begin
        TDXWPanel(ObjectList[DxO_Vis+i]).tag:=0;
        TDXWLabel(ObjectList[DxO_Vis+i]).caption:='';
      end;
    end;
  end ;
  TDXWLabel(ObjectList[DxO_Btn+28+1]).caption:=inttostr(totalcost);
end;
{----------------------------------------------------------------------------}
procedure TSnHillFort.BtnBuy1(Sender: TObject);
var
  i, CR, NB, cost: integer;
begin
  i:= (TDXWPanel(sender).ListID - DxO_Btn)  div 4;
  with mHeros[Hid] do
  begin
    CR:=Armys[i].t;
    NB:=Armys[i].n;
    Armys[i].t:= CR+1;
    cost:=NB*(iCrea[CR+1].cost - iCrea[CR].cost);
    case (CR mod 14) of
     0:  cost:=0;
     2:  cost:=cost div 4;
     3:  cost:=cost div 2;
     4:  cost:= 3* (cost div 4);
    end;
    mPlayers[mPL].res[6]:=mPlayers[mPL].res[6] - cost;
    //pay upg
  end;
  AutoRefresh:=true;
  Parent.Autorefresh:=true
end;
{----------------------------------------------------------------------------}
procedure TSnHillFort.BtnBuyAll(Sender: TObject);
var
  i,CR,NB,cost: integer;
begin
  with mHeros[Hid] do
  begin
    for i:=0 to MAX_ARMY do
    begin
      CR:= Armys[i].t;
      NB:=Armys[i].n;
      if ((CR > -1)  and ((CR mod 2)=0)) then
      begin
        CR:=Armys[i].t;
        Armys[i].t:= CR+1;
        cost:=NB*(iCrea[CR+1].cost - iCrea[CR].cost);
        case (CR mod 14) of
         0:  cost:=0;
         2:  cost:=cost div 4;
         3:  cost:=cost div 2;
         4:  cost:= 3* (cost div 4);
        end;
       mPlayers[mPL].res[6]:=mPlayers[mPL].res[6] - cost;
     end;
    end;
  end;
  AutoRefresh:=true;
  Parent.Autorefresh:=true
end;
{----------------------------------------------------------------------------}
procedure TSnHillFort.PnlVisCrea(Sender: TObject);
begin
  FocusedSlot:=ObjectList.DxO_MouseOver-(DxO_Vis);
  TDxWPanel(sender).Focused:=gArmy.Select(0,FocusedSlot);  //2=vis
  AutoRefresh:=true;
end;
{----------------------------------------------------------------------------}

end.



