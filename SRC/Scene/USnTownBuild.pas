unit USnTownBuild;


interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene,Math;

type

  TSnTownBuild= class (TDxScene)
  private
    CT: integer;
    FocusedSlot:integer;
    DxO_Crea,DxO_Res: integer;
    SelectedBuild: integer;
    DxO_City, DxO_Vis,DxO_Gar, DxO_Hero, DxO_Build, DxO_Prod: integer;

    procedure CreateBuild;
    procedure CreateDwelling;
    procedure BtnTavern(Sender: TObject);
    procedure BtnCrea(Sender: TObject);
    procedure BtnHorde(Sender: TObject);
    procedure BtnRes(Sender: TObject);
    procedure BtnShip(Sender: TObject);
    procedure BtnForge(Sender: TObject);
    procedure BtnMage(Sender: TObject);
    procedure BtnHall(Sender: TObject);
    procedure BtnCstl(Sender: TObject);
    procedure BuyShip;
    procedure BtnBuild(Sender: TObject);
  public
    Constructor Create(_CT: integer; SUB: boolean=false);
    procedure Update(_CT: integer);
    procedure SnRefresh(Sender:TObject);
    procedure SnDraw(Sender:TObject);
    procedure SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  end;


implementation

uses UMain, USnInfoCrea,  UMap, UCT, UHE, UArmy,USnBuyHero, USnBuyCrea,
  USnHero, USnMage, USnHall, USnCstl, USnBuyRes, USnBuyForge, USnDialog,USnBuyArtf,USnBuyShip,UPL,USnGame,UType;

const
  BuildName: array [0..43] of String  =
  ('MAGE','MAG2','MAG3','MAG4','MAG5',
   'TVRN','DOCK','CSTL','CAS2','CAS3',
   'HALL','HAL2','HAL3','HAL4','MARK',
   'SILO','BLAK','SPEC','HRD1','HRD2',
   'BOAT','EXT0','EXT1','EXT2','HRD3',
   'HRD4','HOLY','EXT3','EXT4','EXT5',
   'DW_0','DW_1','DW_2','DW_3','DW_4','DW_5','DW_6',
   'UP_0','UP_1','UP_2','UP_3','UP_4','UP_5','UP_6');


Constructor TSnTownBuild.Create(_CT: integer; SUB: boolean=false);
var
  i: integer;
  t: integer;
begin
  CT:=_CT;
  t:=mCitys[CT].t;
  inherited Create('SnTownBuild' + TN_INITIAL[t]);
  Left:=0;
  Top:=0;
  HintX:=400;
  AddBackground('TB'+TN_INITIAL[t] + 'BACK');
  CreateBuild;
  CreateDwelling;
  for i:=0 to MAX_BUILD-1 do
  begin
    TDXWPanel(ObjectList[DxO_Build+i]).left:=iBuild[t,i].pos.x;
    TDXWPanel(ObjectList[DxO_Build+i]).top:=iBuild[t,i].pos.y;
  end;
  AutoRefresh:=true;
  OnMouseMove:=SnMouseMove;
  OnRefresh:=SnRefresh;
  OnDraw:=SnDraw;
  if SUB then AddSubScene else AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.CreateBuild;
var
  s: string;
begin
  s:='TB'+TN_INITIAL[mCitys[CT].t];
  DxO_Build:=ObjectList.Count;                          // DxO_Build=52
  AddBuildPanel(s+BuildName[0],705,165,BtnMage);        //Build0_MageGuildlevel1=0;  // 52
  AddBuildPanel(s+BuildName[1],705,134,BtnMage);        //Build1_MageGuildlevel2=1;
  AddBuildPanel(s+BuildName[2],705,110,BtnMage);        //Build2_MageGuildlevel3=2;
  AddBuildPanel(s+BuildName[3],705,78,BtnMage);         //Build3_MageGuildlevel4=3;
  AddBuildPanel(s+BuildName[4],1000,10,BtnMage);        //Build4_MageGuildlevel5=4;

  AddBuildPanel(s+BuildName[5],1,227,BtnTavern);        //Build5_Tavern=5;          //   57
  AddBuildPanel(s+BuildName[6],478,133,BtnShip);        //Build6_Shipyard=16;       //   58
  AddBuildPanel(s+BuildName[7],593,65,BtnCstl);         //Build7_Fort=3;
  AddBuildPanel(s+BuildName[8],479,65,BtnCstl);         //Build8_Citadel=4;
  AddBuildPanel(s+BuildName[9],477,37,BtnCstl);         //Build9_Castle=5;
  AddBuildPanel(s+BuildName[10],0,217,BtnHall);         //Build10_Village:
  AddBuildPanel(s+BuildName[11],0,173,BtnHall);         //Build11_TownHall:
  AddBuildPanel(s+BuildName[12],0,164,BtnHall);         //Build12_CityHall=1é;
  AddBuildPanel(s+BuildName[13],0,156,BtnHall);         //Build13_Capitol=13;
  AddBuildPanel(s+BuildName[14],414,264,BtnRes);        //Build14_Marketplace=8;
  AddBuildPanel(s+BuildName[15],489,229,BtnRes);        //Build15_ResourceSilo=9;
  AddBuildPanel(s+BuildName[16],215,251,BtnForge);      //Build16_Blacksmith=7;
  AddBuildPanel(s+BuildName[17],535,73,BtnBuild);       //Build17_Lighthouse=18;
  AddBuildPanel(s+BuildName[18],49,112,BtnHorde);       //Build18_GriffinBastion=30;
  AddBuildPanel(s+BuildName[19],49,112,BtnHorde);       //Build19_GriffinBastion=30;
  AddBuildPanel(s+BuildName[20],705,165, BtnBuild);     //??
  AddBuildPanel(s+BuildName[21],372,188,BtnBuild);      //Build21_Stables=20;
  AddBuildPanel(s+BuildName[22],0,220,BtnBuild);        //Build22_BrotherhoodoftheSword=19;
  AddBuildPanel(s+BuildName[23],705,165,BtnBuild);      //23
  AddBuildPanel(s+BuildName[24],705,165,BtnBuild);      //24
  AddBuildPanel(s+BuildName[25],705,165,BtnBuild);      //25
  AddBuildPanel(s+BuildName[26],0,220,BtnBuild);        //Build26_Colossus=17;
  AddBuildPanel(s+BuildName[27],705,165,BtnBuild);      //27;
  AddBuildPanel(s+BuildName[28],705,165,BtnBuild);      //28
  AddBuildPanel(s+BuildName[29],705,165,BtnBuild);      //29
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.CreateDwelling;
var
  s:string;
begin
  s:='TB'+TN_INITIAL[mCitys[CT].t];
  DxO_Crea:=ObjectList.Count;
  AddBuildPanel(s+BuildName[30],306,92,BtnCrea);        //Build30_Guardhouse=22;
  AddBuildPanel(s+BuildName[31],360,129,BtnCrea);       //Build31_ArchersTower=25
  AddBuildPanel(s+BuildName[32],80,53,BtnCrea);         //Build32_GriffinTower=28;
  AddBuildPanel(s+BuildName[33],180,102,BtnCrea);       //Build33_Barracks=31;
  AddBuildPanel(s+BuildName[34],565,210,BtnCrea);       //Build34_Monastery=34;
  AddBuildPanel(s+BuildName[35],188,198,BtnCrea);       //Build35_TrainingGrounds=37;
  AddBuildPanel(s+BuildName[36],304,0,BtnCrea);         //Build36_PortalofGlory=39;
  AddBuildPanel(s+BuildName[37],306,65,BtnCrea);        //Build37_Upg.Guardhouse=23;
  AddBuildPanel(s+BuildName[38],360,115,BtnCrea);       //Build38_Upg.ArchersTower=26;
  AddBuildPanel(s+BuildName[39],80,31,BtnCrea);         //Build39_Upg.GriffinTower=29
  AddBuildPanel(s+BuildName[40],177,84,BtnCrea);        //Build40_Upg.Barracks=32;
  AddBuildPanel(s+BuildName[41],565,210,BtnCrea);       //Build41_Upg.Monastery=35;
  AddBuildPanel(s+BuildName[42],188,201,BtnCrea);       //Build42_Upg.TrainingGrounds=38;
  AddBuildPanel(s+BuildName[43],304,0,BtnCrea);         //Build43_Upg.PortalofGlory=40

end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BtnTavern(Sender: TObject);
begin
  mDialog.res :=-1;
  TSnBuyHero.Create(CT);
  repeat
    Application.HandleMessage
  until mDialog.res <> -1;
  with mCitys[CT] do gArmy.initCT(CT);
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BtnCrea(Sender: TObject);
var
  Slot: integer;
  CR, n: integer;
begin
  Slot:=(TDXWOBject(sender).listid-DxO_Crea) mod 7;
  CR:=mCitys[CT].prodArmys[Slot].t;
  n:=mCitys[CT].dispArmys[Slot].n;
  if CR=-1then exit ;
  mDialog.res :=-1;
  TSnBuyCrea.Create(CR,n);
  repeat
    Application.HandleMessage
  until mDialog.res <> -1;
  if mDialog.res > 0 then
  cmd_CT_AddCrea(CT,CR,mDialog.res);
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BtnHorde(Sender: TObject);
var
  crSlot: integer;
  crId, crQty: integer;
begin
  //crSlot:=(Objectlist.MouseOverObjectId-DxO_Crea) mod 7;
  if mCitys[CT].t=0 then crSlot:=2 else crslot:=1; //to improve
  crId:=mCitys[CT].prodArmys[crSlot].t;
  crQty:=mCitys[CT].dispArmys[crSlot].n;
  mDialog.res :=-1;
  TSnBuyCrea.Create(crId,crQty);
  repeat
    Application.HandleMessage
  until mDialog.res <> -1;
  if mDialog.res > 0 then
  cmd_CT_AddCrea(CT,crId,mDialog.res);
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BtnRes(Sender: TObject);
begin
  TsnBuyRes.Create;
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BuyShip;
var
  x,y,l ,i: integer;
  p : TPos;
  OB: integer;
  found: boolean;
begin
  mDialog.mes:='{Question} Need a boat ?';
  begin
    mDialog.res:=-1;
    TSnBuyShip.Create;
    repeat
      Application.HandleMessage
    until mDialog.res <> -1;
    if mDialog.res >0 then
    begin
      x:=mCitys[CT].pos.x-2;
      y:=mCitys[CT].pos.y;
      l:=mCitys[CT].pos.l;
      found:=false;
      for i:=-1 to 1 do
      begin
        p.x:=x+i;
        p.y:=y+1;
        p.l:=l;
        if mTiles[p.x,p.y,p.l].TR.t=TR08_Water then
        begin
          found:=true;
          break;
        end;
      end;

      if found=false then exit;

      //map.AddObj(-1,711, 0,dst.x+1,dst.y-1,pos.z);
      OB:=nObjs;
      mObj.id:=OB;
      mObj.t:=OB08_Boat;
      mObj.u:=0;
      mObj.v:=0;
      mTiles[p.x,p.y,p.l].P1:=2;
      mTiles[p.x,p.y,p.l].obX.t:=mObj.t;
      mTiles[p.x,p.y,p.l].obX.u:=mObj.u;
      mTiles[p.x,p.y,p.l].obX.oid:=mObj.id;
      mObjs[OB]:=mObj;
      inc(nObjs);
      Cmd_PL_AddRes(mPL,6,-1000);
      Cmd_PL_AddRes(mPL,0,-10);
      p.x:=p.x+1;
      SnGame.AddSprite('AVXMyboat',p);
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BtnShip(Sender: TObject);
begin
  BuyShip;
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BtnForge(Sender: TObject);
begin
  TSnBuyForge.Create(CT);
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BtnMage(Sender: TObject);
begin
  if (mCitys[CT].VisHero >= 0)
  then
  begin
    if mHeros[mCitys[CT].VisHero].hasBook
    then
    begin
      TSnMage.Create(CT);
    end
    else
    begin
      if mPlayers[mPL].res[6] >= 500
      then
      begin
        //if ProcessQuestion(TXTgenrltxt[215]) //TODO icone dsART avec ARTID=0
        ProcessDialog(TXTgenrltxt[215],dsArtQ,0);
        if mDialog.res = 1
        then
        begin
          mPlayers[mPL].res[6]:=mPlayers[mPL].res[6]-500;
          Cmd_He_SetART(mCitys[CT].VisHero,AR000_Spellbook);
          Cmd_HE_VisitCity(mCitys[CT].VisHero,CT);
          TSnMage.Create(CT);
        end
      end
      else
        ProcessInfo(TXTgenrltxt[215]) //TODO icone dsART avec ARTID=0
    end;
  end
  else TSnMage.Create(CT);
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BtnHall(Sender: TObject);
begin
  TSnHall.Create(CT);
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BtnCstl(Sender: TObject);
begin
  TSnCstl.Create(CT);
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.BtnBuild(Sender: TObject);
var
  BU: integer;
begin
  {if selectedBuild=-1 then
     selectedBuild:= ObjectList.MouseOVERObjectID
  else selectedBuild:=-1;   }
  selectedBuild:=TDXWPanel(sender).listid;
  BU:=selectedBuild-DxO_Build;
  case BU of
  17 :   //lighhouse ?
  if mCitys[CT].cons[Cons10_Artifact]
  then  TSnBuyArtf.Create
  else  ProcessInfo(iBuild[mCitys[CT].t,BU].name);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.SnDraw;
begin
  if Background>-1
  then ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DrawZList(DxO_Build);
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.SnRefresh(Sender:TObject);
begin
  Update(CT);
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.Update(_CT: integer);
var
  i,id: integer;
  CR, n: integer;
  s,pic:string;
begin
  for i:=0 to MAX_BUILD-1 do
  TDXWPanel(ObjectList[DxO_Build+i]).visible:=cmd_CT_ShowBuild(CT,i); //builds[i]; // and not(builds[rep[i]]);
  ObjectList.SortZList(DxO_Build);
end;
{----------------------------------------------------------------------------}
procedure TSnTownBuild.SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  slot: integer;
begin
  slot:=ObjectList.DxO_MouseOver;
  Hint:='';
  if slot > -1 then
  with ObjectList[slot] do Hint:=iBuild[mCitys[CT].t][slot-DxO_Build].name+ format('  %d [X=%d Y=%d H=%d Z=%d], ',[slot,left,top,height,z]);
  Hint:=inttostr(slot)+' - '+   Hint;
  {if selectedbuild <>-1 then
  begin
    TDXWPanel(ObjectList[selectedbuild]).left:=mouse.x;
    TDXWPanel(ObjectList[selectedbuild]).top:=mouse.y;
    TDXWPanel(ObjectList[selectedbuild]).caption:= format('id=%d, pos %d, %d',[selectedbuild-DxO_Build,mouse.X,mouse.y]);
  end;  }
end;
{----------------------------------------------------------------------------}

end.
