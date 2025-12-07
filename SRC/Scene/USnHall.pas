unit USnHall;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DxWLoad , DXWScene;

type

  Tlines = array [0..4] of integer;

  TSnHall= class (TDxScene)
  private
    DxO_Build, DxO_Res: integer;
    CT: integer;
    nItems : Tlines;
    MaxSlot: integer;
  public
    constructor Create(Value: integer);
    procedure SnRefresh(Sender: TObject);
    procedure BtnBuild(Sender: TObject);
  end;


var
  SnHall:TSnHall;

implementation

uses UMain, UFile, USnDialog, UType, USnBuyBuild, UCT, UMap;

{----------------------------------------------------------------------------}
constructor TSnHall.create(Value: integer);
var
  i: integer;
  SLOT, BU: integer;
  l,t: integer;
  s,ext, ext2: string;
const
  CSItems: Tlines =(4,3,2,4,3);// 9
  RMItems: Tlines =(4,3,3,4,3);//10
  FRItems: Tlines =(4,3,3,4,3);
  ALItems: Tlines =(4,4,3,4,3);//11
begin
  inherited Create('SnHall');
  AllClient:=true;
  CT:=Value;
  t:=mCitys[CT].t;
  case t of
    0:   nItems:=CSItems;
    1:   nItems:=RMItems;
    7:   nItems:=FRItems;
    else nItems:=AlItems;
  end;
  Maxslot:=0;
  for i:=0 to 4 do
  MaxSlot:=MaxSlot+nItems[i];

  ext:=TNext[t];
  ext2:=TNext3[t];

  HintX:=70;
  HintY:=558;
  AddBackground('TPTHBK'+EXT2);
  AddTitleScene('CITY HALL' ,2);
  AddPanel('KRESBAR',5,575);

  DxO_Build:=ObjectList.Count;
  slot:=0;
  for l:=0 to 4 do
  begin
    for i:=0 to ALItems[l]-1 do
    begin
      AddSprPanel('HALL'+ext, 421 -97*nItems[l] + 194*i , 37+104*l , BtnBuild);
      with TDxWPanel(ObjectList[DxO_Build+4*SLOT]) do
      begin
        AddSprPanel('TPTHBAR',left, top+71);
        AddLabel_Center('info',left, top+73,152,8);
        AddSprPanel('TPTHChk',left+132, top+53);
        if i < nItems[l] then
        begin
          BU:=cmd_CT_ShowWhatToBuild(CT,SLOT);
          tag:=BU;
          if not(mCitys[CT].Builds[BU])
          then  TDxWPanel(ObjectList[DxO_Build+4*SLOT+1]).tag:=1;
          s:=iBuild[mCitys[CT].t,BU].name;
          TDxWLabel(ObjectList[DxO_Build+4*SLOT+2]).caption:=s;
        end
        else
        begin
          TDxWPanel(ObjectList[DxO_Build+4*SLOT]).visible:=false;
          TDxWPanel(ObjectList[DxO_Build+4*SLOT+1]).visible:=false;
          TDxWPanel(ObjectList[DxO_Build+4*SLOT+2]).visible:=false;
          TDxWPanel(ObjectList[DxO_Build+4*SLOT+3]).visible:=false;
        end;
      end;
      inc(slot);
    end;
  end;

  DxO_Res:=ObjectList.Count;
  for i:=0 to MAX_RES-1 do
  AddLabel(inttostr(mPlayers[mPL].RES[i]),35+76*i,578);

  AddLabel_Center('Day Week Month',555,578,190);
  TDxWLabel(ObjectList[ObjectList.Count-1]).caption:=cmd_Map_GetDate;

  AddButton('TPMAGE1',748,556,BtnOK);
  UpdateColor(mPL,2);
  OnRefresh:=SnRefresh;
  AutoRefresh:=True  ;
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnHall.BtnBuild(Sender: TObject);
var
  id : integer;
begin
  id:=TDxWPanel(sender).Tag;
  mDialog.res :=-1;
  TSnBuyBuild.create(CT,id);
end;
{----------------------------------------------------------------------------}
procedure TSnHall.SnRefresh(sender: TObject);
var
  i, slot, BU: integer;
  test: integer;
  s: string;
begin
  for i:=0 to MAX_RES -1 do
     TDxWLabel(ObjectList[DxO_Res+i]).caption:=inttostr(mPlayers[MPL].res[i]);
  for slot:=0 to 17 do
  begin
    BU:=Cmd_CT_ShowWhatToBuild(CT,Slot);
    TDxWPanel(ObjectList[DxO_Build+4*slot]).tag:=BU;
    if Cmd_CT_ShowBuild(CT,BU)
    then
    begin
      TDxWPanel(ObjectList[DxO_Build+4*slot+1]).tag:=0 ;
      TDxWPanel(ObjectList[DxO_Build+4*slot+3]).tag:=0 ;
      TDxWPanel(ObjectList[DxO_Build+4*slot+3]).visible:=true;
    end
    else
    begin
    // Yellow already built; Green to do, Red miss res/req, E disabled
      test:=Cmd_CT_CanBuild(CT,BU) ;
      case test of
        0: begin
        TDxWPanel(ObjectList[DxO_Build+4*slot+1]).tag:=3;
        TDxWPanel(ObjectList[DxO_Build+4*slot+3]).tag:=1;
        TDxWPanel(ObjectList[DxO_Build+4*slot+3]).visible:=true
      end;
        1: begin
        TDxWPanel(ObjectList[DxO_Build+4*slot+1]).tag:=1;
        TDxWPanel(ObjectList[DxO_Build+4*slot+3]).visible:=false;
      end;
        2: begin
        TDxWPanel(ObjectList[DxO_Build+4*slot+1]).tag:=2;
        TDxWPanel(ObjectList[DxO_Build+4*slot+3]).tag:=1;
        TDxWPanel(ObjectList[DxO_Build+4*slot+3]).visible:=true
      end;
        3: begin
        TDxWPanel(ObjectList[DxO_Build+4*slot+1]).tag:=2;
        TDxWPanel(ObjectList[DxO_Build+4*slot+3]).tag:=2;
        TDxWPanel(ObjectList[DxO_Build+4*slot+3]).visible:=true
      end;
      end;
    end;
    s:= iBuild[mCitys[CT].t,BU].name;
    TDxWLabel(ObjectList[DxO_Build+4*slot+2]).caption:=s;
  end;
end;



end.

