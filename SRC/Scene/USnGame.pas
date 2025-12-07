unit USnGame;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws, Math,
  DXSounds, DIB, DxWLoad , DxPlay, DXWControls, DXWScene,
  DXWNavigator, DXWGameSprite,
  USnInfoPlayer, USnInfoFlag, USnInfoHero, USnInfoTown,USnInfoRes, USnInfoMsg, USnInfoday, USnInfoGar, USnLoadingMap,
  UType, UHeader, USnPuzzle, UAI;

const
  SHOW1_TOWN=1;
  SHOW2_HERO=2;
  SHOW3_RES=3;
  SHOW4_FLAG=4;
  SHOW5_PLAYER=5;
  SHOW6_DAY=6;
  SHOW7_MSG=7;
type

  TSnGame= class (TDxScene)
  private
    SubInfoTown:   TSnInfoTown;
    SubInfoHero:   TSnInfoHero;
    SubInfoFlag:   TSnInfoFlag;
    SubInfoPlayer: TSnInfoPlayer;
    SubInfoDay:    TSnInfoDay;
    DxO_Hero, DxO_Town, DxO_Res, DxO_Mana, DxO_Mobil, DxO_Level: integer;
    offsetH, offsetC: integer;
    ProcessingAction: boolean;
    CanScroll: boolean;
    procedure DoTab;
    procedure SetLevel(Value: integer);

    procedure BtnEdit(Sender: TObject);
    procedure BtnMove(Sender: TObject);
    procedure PnlHero(Sender: TObject);
    procedure PnlTown(Sender: TObject);
    procedure PnlHeroR(Sender: TObject);
    procedure PnlTownR(Sender: TObject);
    procedure BtnLevel(Sender: TObject);
    procedure BtnBook(Sender: TObject);
    procedure BtnPlayer(Sender: TObject);
    procedure BtnOption(Sender: TObject);
    procedure BtnScenario(Sender: TObject);
    procedure BtnOverView(Sender: TObject);
    procedure BtnPuzzle(Sender: TObject);
    procedure BtnEndTurn(Sender: TObject);
    procedure BtnPrevHero(Sender: TObject);
    procedure BtnPrevCity(Sender: TObject);
    procedure BtnNextHero(Sender: TObject);
    procedure BtnNextCity(Sender: TObject);
    procedure DoScrollHero(delta:integer);
    procedure DoScrollCity(delta:integer);
    procedure SnRefresh(Sender:TObject);
    procedure PopInfoTown(CT:integer);
    procedure PopInfoHero(HE:integer);
    procedure PopInfoGar(OB: integer);
    procedure ChangeSub;
    procedure CreateSubScene;
    procedure CreateInterface;
    procedure LoadPicGUI;
    procedure CreateButton;
    procedure RefreshCenterView;
    procedure RefreshHeroList;
    procedure RefreshCityList;
    procedure RemoveCHSelection;
    procedure RefreshRes;

    function MoveHeroTo(HE,x,y,l: integer): boolean;
    procedure MoveHeroOB(HE,OB: integer);
    procedure SnKeyDown(Sender:Tobject;var Key: Word; Shift: TShiftState);
    procedure SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Scroll;
    procedure SnMouseUp(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MapLeftClick;
    procedure MapRightClick;
  public
    FDxEngine: TGameSpriteEngine;
    started: boolean;
    SHOWID : integer;
    SubInfoRes:  TSnInfoRes;
    SubInfoMsg:  TSnInfoMsg;
    Level: integer;
    Constructor Create;
    procedure CreateGame;
    procedure AddDef(DefName:string);
    procedure AddSprite(DefName:string;Pos: TPos);
    procedure AddHero(HE:integer);
    procedure DelHero(HE:integer);

    function  FindObject(x,y,l: integer): TGameSprite;
    function  FindObjectByIndex(oid: integer):TGamesprite;
    procedure FindHero(HE: integer);
    procedure UpdateHero(HE:integer);
    procedure AddMoveAction(HE:integer);
    procedure MoveHeroBy(HE,dx,dy: integer);


    procedure ProcessAction; override;
    procedure DoEndTurn;
    procedure CheckWinLose;

    procedure CenterOnHero;
    procedure CenterOnCity;

    procedure SnDraw(Sender:TObject);
    procedure DrawSubScene(Sender:TObject);
  end;

var
  SnGame:TSnGame;


implementation

uses UFile, UConst, UOB,
   UMap, UMain, UHE, UPL, UEnter, UParse, UBattle, UText,
   USnBook, USnHero, USnTown, USnGarnison, USnOverView, USnScenario,
   USnPlayers, USnLevelUp,
   USnDialog, USnOption, USnBattleResult, USnMeet, UPathRect, USnBattleField;

var
  TmpInfoT: TSnInfoTown;
  TmpInfoG: TSnInfoGar;
  TmpInfoP: TSnInfoPlayer;
  TmpInfoF: TSnInfoFlag;
  TmpInfoH: TSnInfoHero;

{----------------------------------------------------------------------------}
procedure TSnGame.ProcessAction;
var
  x,y,l: integer;
  p:TPos;
  HE,CT,OB: integer;
  Action: ^Taction;
begin
  if DxScene <> Self then exit;

  if Actions.count = 0 then
  begin
    if mPlayers[mPL].isCPU then
    begin
      cmd_AI_PlayTurn(mPL);
    end;
    exit;
  end;

  DxMouse.id:=CrDef;

  Action:=Actions[0];
  Action.Delay:=Max(Action.Delay-1,0);

  if Action.Id=ACT01_Move then
  begin
    // Cmd_HE_Move(HE,x,y,l);   check tl free or enter then real move processing if TL free or Action enter
    CenterOnHero;
    if Action.Delay= (32 div opHeroSpeed) -1 then   // prepa the next move....
    begin
      HE:=Action.HE;
      p.x:=mPath.Path[mPath.length-1].x;
      p.y:=mPath.Path[mPath.length-1].y;
      p.l:=mHeros[HE].pos.l;
      if ((mPath.length<0) or (mHeros[HE].PSKA.mov < Cmd_HE_PathCost(HE,p))) then
      begin                              // plus assez de déplacement
       gHero.CanMove:=false;
       UpdateHero(HE);
       Actions.Delete(0);
       Exit;
      end;
      x:=mPath.Path[mPath.length-1].x;
      y:=mPath.Path[mPath.length-1].y;
      l:=mHeros[HE].pos.l;
      if Cmd_HE_CancelMove(HE,x,y,l) then    // next x,y is not free to enter
         gHero.CanMove:=false;         //Action.Delay:=0;   no animation
      if (mHeros[HE].BoatId <> 0) and (mTiles[x,y,l].TR.t <> TR08_Water)
      then begin
        gHero.CanMove:=false;
        UpdateHero(HE);
      end;
    end;
  end;

  if Action.Delay=0 then
  begin
    gNavigator.refresh:=true;
    case Action.Id of


      ACT01_Move:                       // ActMoveTime expire, process next step
      begin
        HE:=Action.HE;
        gHero.CanMove:=false;           // stop moving
        p.x:=mPath.Path[mPath.length-1].x;
        p.y:=mPath.Path[mPath.length-1].y;
        p.l:=mHeros[HE].pos.l;
        if ((mPath.length<0) or (mHeros[HE].PSKA.mov < Cmd_HE_PathCost(HE,p))) then
        begin                           // plus assez de déplacement
          gHero.CanMove:=false;
          UpdateHero(HE);
          Actions.Delete(0);
          Exit;
        end;

        x:=mPath.Path[mPath.length-1].x;
        y:=mPath.Path[mPath.length-1].y;
        l:=mHeros[HE].pos.l;
        MoveHeroTo(HE,x,y,l);           // move compute hidden action

        if mPath.length <=1
        then
        begin
          UpdateHero(HE);
          Actions.Delete(0);            // on est arrivé
        end
        else
        begin
          Action.Delay:= 32 div OpHeroSpeed;    // movetime=8 : 1 move per frame ??????
          gHero.CanMove:=true;                  // relaunch moving by frame
        end;

        if (Actions.count >= 2) then
        if (TAction(Actions[1]^).id <> ACT11_Gar)
        then
        begin
          Actions.Delete(0);            // next action=fight so delete the next move
          UpdateHero(HE);
          gHero.CanMove:=false;
        end;

        mPath.FindPath(HE);
      end;

      ACT02_Delete:                    // next action=tak obkect so delte the next move
      begin
        OB:=Action.OB;
        cmd_OB_DEL(OB);
        Actions.Delete(0);
      end;

      ACT03_Enter:
      begin
        HE:=Action.HE;
        Actions.Delete(0);
      end;

      ACT04_Battle:
      begin
        Actions.Delete(0);
        TSnBattleField.Create;
      end;

      ACT05_Meet:
      begin
        HE:=Action.HE;
        OB:=Action.OB;
        Actions.Delete(0);
        if not(mPLayers[mPL].isCPU)
        then TSnMeet.create(HE,mobjs[OB].v);
      end;

      ACT06_Town:
      begin
        HE:=Action.HE;
        Actions.Delete(0);
        CT:=mObjs[mHeros[HE].obX.oid].v;
        if not(mPLayers[mPL].isCPU)
        then TSnTown.Create(CT);
      end;

      ACT07_TelePort:
      begin
        HE:=Action.HE;
        Actions.Delete(0);
        x:=mHeros[HE].tgt.x;
        y:=mHeros[HE].tgt.y;
        l:=mHeros[HE].tgt.l;
        Cmd_HE_Move(HE,x,y,l);
        mPath.pDest.x:=x;
        mPath.pDest.y:=y;
        mPath.pStart.x:=x;
        mpath.pStart.y:=y;
        SetLevel(l);
        UpdateHero(HE);
        CenterOnHero;
      end;

      ACT11_Gar:
      begin
        HE:=Action.HE;
        Actions.Delete(0);
        if not(mPLayers[mPL].isCPU)
        then TSnGarnison.Create(HE,mHeros[HE].obX.oid);
      end;

      ACT12_CancelMove:
      begin
        Actions.Delete(0);
      end;

    end;
    CheckWinLose;
    //gNavigator.refresh:=true;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.CheckWinLose;
var
  g: integer;
begin
  g:=Cmd_PL_CheckWINLOS(mPL);
  case g of
    1:
    begin
      processQuestion('Game Won ' + mData.vic);
      application.Terminate;
    end;
    -1:
    begin
      processQuestion('Game Lost' + mData.los);
      application.Terminate;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.CreateGame;
begin
  LogP.EnterProc('Begin_StartGame');
  started:=true;
  mPath:=TPath.Create(mData.dim);
  Hint:='';
  CreateInterface;
  CreateSubScene;
  OnDraw:=SnDraw;
  OnKeyDown:=SnKeyDown;
  OnMouseDown:=SnMouseDown;
  OnMouseMove:=SnMouseMove;
  OnMouseUp:=SnMouseUp;
  OnRefresh:=SnRefresh;
  Initialized:=true;
  //SnDraw(self);
  //SaveDxG;  do not save it will slow reload
  //SavePicName;
  mData.allBlack:=true;
  DoEndTurn;
  LogP.QuitProc('End_StartGame');
  Initialized:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.AddDef(DefName: string);
begin
  LoadSprite(ImageList,DefName);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.AddSprite(DefName: string; Pos: TPos);
var
  gs: TGameSprite;
begin
  gs:=TGameSprite.Create(FDxEngine.Engine);
  with gs do
  begin
    oid:=mObj.id;
    Image:=ImageList.Items.Find(Defname);
    Image.SystemMemory:=true; //opMemory
    AnimCount:=Image.Picture.Height div Height;
    AnimSpeed:=0.01;
    if mObj.t=OB08_Boat then AnimCount:=0;
    AnimPos:=random(AnimCount);
    AnimLooped:=True;
    //image Anchor are on botom rigth corner
    //need to substract -width -height to get correct anchor and add border width
    X:=DL*pos.x-Image.Width +DL+DL*DB;
    Y:=DL*pos.y-Image.Height+DL+DL*DB;
    Z:=1000+Trunc(mData.dim*(pos.y+1)+pos.x);
    if mObj.hasEntry then     Z:=Z+3;
    case mObj.t of
      21, 46, 143, 222..231 : Z:=1;
      34 :                    Z:=Z+4;
      54 : x:=x + 8 * (icrea[mObj.u].flag and 1 )  // 1= UN_DOUBLE)
    end;
    L:=pos.l;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.AddHero(HE:integer);
begin
  gHero:=TGameHero.Create(FDxEngine.Engine,ImageList);
  With gHero do
   begin
    hid:=HE;
    oid:=mHeros[HE].oid;
    pic:='AH'+format('%2.2d',[mHeros[HE].classeId])+'_';
    X:=DL*mHeros[HE].pos.x-DL+DL*DB;
    Y:=DL*mHeros[HE].pos.y-DL+DL*DB;
    L:=mHeros[HE].pos.l;
    Z:=1500+Trunc(mData.dim*(Y+1)+X); //Trunc(1000*Y-X);
    Direction:=1;
    Visible:=True;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.DelHero(HE: integer);
var
  oid:integer;
begin
  oid:=mHeros[HE].oid;
  gHero:=TGameHero(FindObjectByIndex(oid));
  gHero.visible:=false;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnEdit(Sender: TObject);
begin
  //if TDXWEdit(sender).Text='s' then ImageList.Items.SaveToFile('C:\Users\risola\Desktop\sngame.dxg');
  {else
  begin
  Cmd_Parse(TDXWEdit(sender).Text);
  processInfo(TDxWEdit(sender).Text + chr(10) + mDialog.mes);
  sendMsg(TDxWEdit(sender).Text);
  end;  }
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnMove(Sender: TObject);
var
  HE : integer;
begin
  HE:=mPlayers[mPL].ActiveHero;
  if (HE <> -1) then AddMoveAction(HE);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnPlayer(Sender: TObject);
begin
  TSnPlayers.Create;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.PnlHeroR(Sender: TObject);
var
  HE:integer;
begin
  HE:=mPlayers[mPL].LstHero[OffsetH+(TDXWPanel(sender).top-212) div 32];
  TmpInfoH:=TSnInfoHero.Create;
  with TmpInfoH do
  begin
    Left:=410;
    Top:=TDXWPanel(sender).top;
    Update(HE);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.PnlHero(Sender: TObject);
var
  HE:integer;
begin
  HE:=mPlayers[mPL].LstHero[OffsetH+ (TDXWPanel(sender).top-212) div 32];

  if HE = mPlayers[mPL].ActiveHero
  then
    TSnHero.Create(HE,false)
  else
  begin
    RemoveCHSelection;
    TDXWPanel(sender).selected:=true;
    SHOWID:=SHOW2_HERO;
    SubInfoHero.Update(HE);
  end;
  mPlayers[mPL].ActiveHero:=HE;
  mPlayers[mPL].ActiveCity:=-1;
  CenterOnHero;
  mPath.BuildObs(HE);
  mPath.FindPath(HE);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.PnlTownR(Sender: TObject);
var
  CT: integer;
begin
  CT:=mPlayers[mPL].LstCity[offsetC+ (TDXWPanel(sender).top-212) div 32];
  TmpInfoT:=TSnInfoTown.Create;
  with TmpInfoT do
  begin
    Left:=410;
    Top:=TDXWPanel(sender).top;
    Update(CT);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.PnlTown(Sender: TObject);
var
  CT: integer;
begin
  CT:=mPlayers[mPL].LstCity[OffsetC+ ((TDXWPanel(sender).top-212) div 32)];
  if CT = mPlayers[mPL].ActiveCity then
  begin
    TSnTown.Create(CT);
  end
  else
  begin
    RemoveCHSelection;
    TDXWPanel(sender).selected:=true;
    SHOWID:=SHOW1_TOWN;
    SubInfoTown.update(CT);
  end;
  mPlayers[mPL].ActiveCity:=CT;
  mPlayers[mPL].ActiveHero:=-1;
  CenterOnCity;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnLevel(Sender: TObject);
begin
  SetLevel(1-Level);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.SetLeveL(Value: integer);
begin
  if Level=Value then exit;
  Level:=Value;
  TDXWButton(ObjectList[DxO_Level]).visible:=(Level=1);
  TDXWButton(ObjectList[DxO_Level+1]).visible:=(Level=0);
  gBackground.L:=Level;
  gForeground.L:=Level;
  gNavigator.L:=Level;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnOption(Sender: TObject);
begin
  TSnOption.Create;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnBook(Sender: TObject);
begin
  if mPlayers[mPL].ActiveHero= -1 then exit;
  TSnBook.create(mPlayers[mPL].ActiveHero);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnScenario(Sender: TObject);
begin
  TSnScenario.create;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnOverView(Sender: TObject);
begin
  TSnOverView.create;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnPuzzle(Sender: TObject);
begin
  TSnPuzzle.Create;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnEndTurn(Sender: TObject);
begin
  DoEndTurn;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnPrevHero(Sender: TObject);
begin
  DoScrollHero(-1);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnNextHero(Sender: TObject);
begin
  DoScrollHero(+1);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.DoScrollHero(delta:integer);
var
  i: integer;
begin
  with mPlayers[mPL] do
  begin
    if nHero= 0 then Exit;
    RemoveCHSelection;
    ActiveCity:=-1;
    if ActiveHero=-1 then
    begin
      ActiveHero:=LstHero[0];
      OffSetH:=0;
      //TDXWPanel(ObjectList[DxO_Hero]).selected:=true;
    end
    else
    begin
      for i:=0 to 4 do
        if LstHero[OffsetH+i]=ActiveHero
        then break;
      ActiveHero:=LstHero[(OffsetH+i+delta+nHero) mod nHero];
      if (i+delta)> 4  then OffsetH := OffsetH+1;
      if (i+delta+OffsetH) > nHero then OffsetH:=0;
      if (i+delta)< 0  then OffsetH := OffsetH-1;
      if OffsetH < 0 then OffsetH:=Max(nHero-5,0);

      //TDXWPanel(ObjectList[DxO_Hero+(i+delta) mod nHero]).selected:=true;
    end;
    SubInfoHero.update(ActiveHero);
    SHOWID:=SHOW2_HERO;
    CenterOnHero;
    mPath.BuildObs(ActiveHero);
    mPath.FindPath(ActiveHero);
    RefreshHeroList;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnPrevCity(Sender: TObject);
begin
  DoScrollCity(-1);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.BtnNextCity(Sender: TObject);
begin
  DoScrollCity(+1);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.DoScrollCity(delta:integer);
var
  i: integer;
begin
  with mPlayers[mPL] do
  begin
    if nCity= 0 then Exit;
    RemoveCHSelection;
    ActiveHero:=-1;
    if ActiveCity=-1 then
    begin
      ActiveCity:=LstCity[0];
      OffSetC:=0;
      //TDXWPanel(ObjectList[DxO_Hero+5]).selected:=true;
    end
    else
    begin
      for i:=0 to 4 do
        if LstCity[OffsetC+i]=ActiveCity
        then break;
      ActiveCity:=LstCity[(OffsetC+i+delta+nCity) mod nCity];
      if (i+delta)> 4  then OffsetC := OffsetC+1;
      if (i+delta+OffsetC) > nCity then OffsetC:=0;
      if (i+delta)< 0  then OffsetC := OffsetC-1;
      if OffsetC < 0 then OffsetC:=Max(nCity-5,0);
      //TDXWPanel(ObjectList[DxO_Hero+5+(i+delta) mod nCity]).selected:=true;
    end;
    SubInfoTown.update(ActiveCity);
    SHOWID:=SHOW1_TOWN
  end;
  CenterOnCity;
  RefreshCityList;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.DoTab;
begin
  TextFrm.FormShowDir(folder.Log);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.DoEndTurn;
begin
  DxMouse.Id:=CrDef;
  mData.AllBlack:=true;
  Cmd_PL_EndTurn;
  offsetH:=0;
  offsetC:=0;
  //if not(mPlayers[mPL].isCPU) then
  if mPL=hPL then
  begin
    UpdateColor(mPL,13);
    SHOWID:=SHOW6_DAY;
    SubInfoDay.Init;
    SubInfoPlayer.Update(mPL);
    show;
    ProcessInfoTurn;
    SHOWID:=SHOW6_DAY;
    ProcessMapRumor;
    ProcessMapEvent;
    SubInfoDay.Start;
  end
  else
  begin
    SubInfoFlag.Update(mPL);
    SHOWID:=SHOW4_FLAG;
  end;
  //if mPL=hPL then
  mData.AllBlack:=false;
  show;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.DrawSubScene(Sender:TObject);
begin
  case SHOWID of
    SHOW1_TOWN:   SubInfoTown.DoDraw;
    SHOW2_HERO:   SubInfoHero.DoDraw;
    SHOW3_RES:
    begin
      if not(SubInfoRes.AnimEnd)
      then SubInfoRes.SnDraw(sender)
      else if mPlayers[mPL].ActiveHero=-1
        then SHOWID:=SHOW1_TOWN
        else SHOWID:=SHOW2_HERO;
    end;
    SHOW4_FLAG:   SubInfoFlag.DoDraw;
    SHOW5_PLAYER: SubInfoPlayer.DoDraw;
    SHOW6_DAY:
    begin
      if not(SubInfoDay.AnimEnd)
      then SubInfoDay.SnDraw(sender)
      else if mPlayers[mPL].ActiveHero=-1
        then SHOWID:=SHOW1_TOWN
        else SHOWID:=SHOW2_HERO;
    end;
    SHOW7_MSG:
    begin
      if not(SubInfoMsg.AnimEnd)
      then SubInfoMsg.SnDraw(sender)
      else if mPlayers[mPL].ActiveHero=-1
        then SHOWID:=SHOW1_TOWN
        else SHOWID:=SHOW2_HERO;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.SnDraw(Sender:TObject);
var
  DrawCount: integer;
begin
  if DxScene=Self then
  begin
    if DXMain.DXTimer.FrameRate<>0
    then drawcount:=trunc(1000/DXMain.DXTimer.FrameRate)
    else drawcount:=25;

    FDxEngine.Dead;
    FDxEngine.Move(drawcount);   //80 ? Trunc(6000/DXMain.DXTimer.FrameRate...25*4 *20 ou *10
    //if CanScroll then
    Scroll;

  end;
  if (mData.allBlack) then
  begin
    DxSurface.FillRect(Rect(0,0,800,600),DxBlack);
    gNavigator.DrawSelf;     // since all black show the blason only
    ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  end
  else
  begin
    FDxEngine.Draw;
    DxSurface.FillRect(Rect(600,0,800,400),DxBlack);
    gNavigator.DrawSelf;
    ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
    ObjectList.DoDraw;
  end;
  DrawSubScene(Sender);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.RefreshHeroList;
var
  HE, i: integer;
begin
  RemoveCHSelection;

  if (mPlayers[mPL].nHero <=5) then offsetH:=0;
  for i:=0 to 4 do
  begin
    if i < mPlayers[mPL].nHero
    then
    begin
      HE:=mPlayers[mPL].LstHero[offsetH+i];

      TDXWPanel(Objectlist[DxO_Hero+i]).Tag:=HE;
      TDXWPanel(Objectlist[DxO_Hero+i]).visible:=true;
      TDXWPanel(ObjectList[DxO_Mobil+i]).Tag:=Min(mHeros[HE].PSKA.mov div 100,23);
      TDXWPanel(ObjectList[DxO_Mana+i]).Tag:= Min(mHeros[HE].PSKB.ptm div 5,23);

      if HE=mPlayers[mPL].ActiveHero
      then
      begin
        TDXWPanel(ObjectList[DxO_Hero+i]).selected:=true;
        SubInfoHero.update(HE);
        if not((SHOWID=SHOW6_DAY) or (SHOWID=SHOW3_RES) or (SHOWID=SHOW7_MSG)) then SHOWID:=SHOW2_HERO;
      end
    end
    else
    begin
      TDXWPanel(Objectlist[DxO_Hero+i]).visible:=false;
      TDXWPanel(ObjectList[DxO_Mana+i]).Tag:=0;
      TDXWPanel(ObjectList[DxO_Mobil+i]).Tag:=0;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.RefreshCityList;
var
  CT, i: integer;
begin
  if (mPlayers[mPL].nCity <=5) then offsetC:=0;
  for i:=0 to 4 do
  begin
    if i < mPlayers[mPL].nCity
    then
    begin
      CT:=mPlayers[mPL].LstCity[offsetC+i];
      TDXWPanel(ObjectList[DxO_Town+i]).Tag:=2+2*mCitys[CT].t +mCitys[CT].hasbuild;
      TDXWPanel(ObjectList[DxO_Town+i]).visible:=true;
      if CT=mPlayers[mPL].ActiveCity
      then
      begin
        TDXWPanel(ObjectList[DxO_Town+i]).selected:=true;
        SubInfoTown.Update(CT);
        if not(SHOWID=SHOW6_DAY) then SHOWID:=SHOW1_TOWN;
      end
    end
    else TDXWPanel(ObjectList[DxO_Town+i]).visible:=false;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.RefreshCenterView;
var
  HE: integer;
begin
  HE:=mPlayers[mPL].ActiveHero;
  if ((HE = -1) or (mPlayers[mPL].nHero=0))
  then
    CenterOnCity
  else
  begin
    CenterOnHero;
    mPath.BuildObs(HE);
    mPath.FindPath(HE)
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.RefreshRes;
var
  i:integer;
begin
  for i:=0 to MAX_RES-1 do
    TDXWLabel(ObjectList[DxO_Res+i]).caption:=inttostr(mPlayers[mPL].RES[i]);
  TDXWLabel(ObjectList[DxO_Res+7]).caption:=Cmd_Map_getDate;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.RemoveCHSelection;
var
  i: integer;
begin
  for i:=0 to 9 do
    TDXWPanel(ObjectList[DxO_Hero+i]).selected:=false;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.SnRefresh(Sender:TObject);
begin
  RemoveCHSelection;
  RefreshCityList;
  RefreshHeroList;
  RefreshRes;
  RefreshCenterView;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.SnKeyDown(Sender:TObject;var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_PRIOR,
    VK_NEXT,
    VK_END,
    VK_HOME,
    VK_LEFT,
    VK_RIGHT,
    VK_UP,
    VK_DOWN: CenterOnHero; //SendMove(ord(key)) ;
    ord('E') :  BtnEndTurn(sender);
    ord('H') :  BtnNextHero(sender);
    ord('T') :  BtnNextCity(sender);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.SnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if DxScene<>Self then exit;
  if Actions.count > 0 then exit;

  //CanScroll:= Ptinrect(Rect(-5,5,805,605),Point(x,y));
  with DxMouse do
  begin
    mX:=(round(-FDxEngine.Engine.x)+x) div DL -DB;
    mY:=(round(-FDxEngine.Engine.y)+y) div DL -DB;
    gNavigator.NavigatorMouseMove(Shift,x,y);
    DxMouse.id:=CrDef;
    if (x<600) and (y<550) and Cmd_Map_Inside(mX,mY)
    then
    begin
      if mTiles[mX,mY,Level].Vis[mPL] = false then Exit;
      Hint:=Cmd_Map_GetCursor(mX,mY,Level)
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.Scroll;
const
  SCROLLBY8=8;
var
  d,dx, dy, ScrollCount: integer;
  ptCursor: TPoint;
begin
  GetCursorPos(ptCursor);
  if not PtinRect(DxMain.BoundsRect, ptCursor) then exit;

  with DXMain do begin
    if DXTimer.FrameRate=0
      then ScrollCount:=Trunc(SCROLLBY8)
      else ScrollCount:=Trunc(SCROLLBY8*(80/DXTimer.FrameRate));
    dx:=0;
    dy:=0;
    if DxMouse.X<=10             then dx:=1;
    if DxMouse.X>=ClientWidth-8  then dx:=-1;
    if DxMouse.Y<=10             then dy:=1;
    if DxMouse.Y>=ClientHeight-8 then dy:=-1;

    d:=dx+10*dy;
    case d of
     -11: DxMouse.id:=CrMoveSE;
     -10: DxMouse.id:=CrMoveSS;
      -9: DxMouse.id:=CrMoveSW;
      -1: DxMouse.id:=CrMoveEE;
       1: DxMouse.id:=CrMoveWW;
       9: DxMouse.id:=CrMoveNE;
      10: DxMouse.id:=CrMoveNN;
      11: DxMouse.id:=CrMoveNW;
    end;
    dx:=dx* ScrollCount;
    dy:=dy* ScrollCount;
    FDxEngine.scroll(dx,dy);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.ChangeSub;
begin
  case SHOWID of
  SHOW5_PLAYER: begin
              SHOWID:=SHOW6_DAY;
              SubInfoDay.Init;
              SubInfoDay.Start;
  end;
  SHOW6_DAY: if mPlayers[mPL].ActiveHero > -1 then
              SHOWID:=SHOW2_HERO else
              SHOWID:=SHOW1_TOWN;
  SHOW1_TOWN: SHOWID:=SHOW5_PLAYER;
  SHOW2_HERO: SHOWID:=SHOW5_PLAYER;
  end;
  if SHOWID=SHOW5_PLAYER then SubInfoPlayer.update(mPL);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (gHero <> nil) then if (gHero.CanMove) then exit; // no click during a move
  if (X > 600) and (Y < 200)
    then gNavigator.NavigatorMouseDown(Shift,X,Y);
  if (X > 600) and (Y > 400)
    then changeSub;
  if (X <600) and (Y < 550)
  then
  begin
    DxMouse.mX:=(round(-FDxEngine.Engine.X)+X) div DL -DB;
    DxMouse.mY:=(round(-FDxEngine.Engine.Y)+Y) div DL -DB;
    if Cmd_Map_Inside(DxMouse.mX,DxMouse.mY) then
    begin
      if Button=mbLeft // select hero, move hero, select town
      then MapLeftClick
      else MapRightClick;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.SnMouseUp(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  gNavigator.NavigatorMouseUp(Shift,X,Y);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.MapRightClick;
begin
  //TODO check if action clear is relevant
  Actions.Clear;
  // show generic info or spec info of a Map Tile and associated OBJ
  with mTiles[DxMouse.mX,DxMouse.mY,Level]do
  begin
    if Vis[mPL] = false then Exit;
    case obx.t of
      OB33_Garnison:  PopInfoGar(obx.oid);
      OB34_Hero:      PopInfoHero(mObjs[obx.oid].v);
      OB98_City:      PopInfoTown(mObjs[obx.oid].v);
      OB54_Monster:   ProcessDialog('',DsMonster,obx.oid);
      OB17_Generator: PopInfo(TxtCRGEN1[obx.u]);
      else            PopInfo(Cmd_Map_GetTileDesc(DxMouse.mX,DxMouse.mY,Level));
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.PopInfoTown(CT:integer);
begin
  TmpInfoT:=TSnInfoTown.Create;
  with TmpInfoT do
  begin
    Top:= Max(0,Min(550-180,DxMouse.y-95));
    Left:=Max(0,Min(600-190,DxMouse.x-95));
    TmpInfoT.Update(CT);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.PopInfoHero(HE:integer);
begin
  TmpInfoH:=TSnInfoHero.Create;
  with TmpInfoH do
  begin
    Top:= Max(0,Min(550-180,DxMouse.y-95));
    Left:=Max(0,Min(600-190,DxMouse.x-95));
    TmpInfoH.Update(HE);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.PopInfoGar(OB: integer);
begin
  TmpInfoG:=TSnInfoGar.Create;
  with TmpInfoG do
  begin
    Top:= Max(0,Min(550-180,DxMouse.y-95));
    Left:=Max(0,Min(600-190,DxMouse.x-95));
    TmpInfoG.Update(OB);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.MapLeftClick;
var
  X,Y,L, HE, CT: integer;
  i: integer;
begin
  if mTiles[DxMouse.mX,DxMouse.mY,Level].Vis[mPL] = false then Exit;
  HE:=mPlayers[mPL].ActiveHero;
  x:=DxMouse.mX;
  y:=DxMouse.mY;
  l:=level;

  if (HE <> -1) then
  // hero highlighted check move or new path
  begin
    if (mHeros[HE].tgt.x=x) and (mHeros[HE].tgt.y=y) then
    begin
      AddMoveAction(HE);
    end
    else
    if (Cmd_HE_CheckMove(HE,x,y,l) <>-1 )  then
    begin
      mHeros[HE].tgt.x:= x;
      mHeros[HE].tgt.y:= y;
      mHeros[HE].tgt.l:= l;
      mPath.BuildObs(HE);
      mPath.FindPath(HE);
      if Actions.Count=1 then Actions.Delete(0);
      exit;
    end
    else
    if mTiles[x,y,l].obX.t=  OB98_City
    then
    begin
      CT:=mObjs[mTiles[x,y,l].obX.oid].v;
      mPlayers[mPL].ActiveHero:=-1;
      for  i:=0 to mPlayers[mPL].nCity-1 do
      begin
        if   mPlayers[mPL].LstCity[i] = CT
        then mPlayers[mPL].ActiveCity:=CT;
      end;
    end;
  end
  else
  begin
    with mTiles[x,y,l].obX do
    begin
      if t= OB98_City  then
      begin
        CT:=mObjs[oid].v;  //.idx  val contains town id
        for i:=0 to  mPlayers[mPL].nCity-1 do
        begin
          if  mPlayers[mPL].LstCity[i] = CT
          then begin
            mPlayers[mPL].ActiveCity:=CT;
            mPlayers[mPL].ActiveHero:=-1;
            TSnTown.Create(CT);
            break;
          end;
        end;
      end;
      if t= OB34_Hero then
      begin
        HE:=mObjs[oid].v;
        for i:=0 to  mPlayers[mPL].nHero-1 do
        begin
          if  mPlayers[mPL].LstHero[i] = HE
          then begin
            mPlayers[mPL].ActiveHero:=HE;
            mPlayers[mPL].ActiveCity:=-1;
            break;
          end;
        end;
      end;
    end;
  end;
  AutoRefresh:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.CenterOnCity;
var
  CT: integer;
begin
  CT:=mPlayers[mPL].ActiveCity ;
  FDxEngine.Engine.X:=FDxEngine.Engine.Width  div 2 - DL*DB-DL*mCitys[CT].pos.x;
  FDxEngine.Engine.Y:=FDxEngine.Engine.Height div 2 - DL*DB-DL*mCitys[CT].pos.y;
  SetLevel(mCitys[CT].pos.l);
  mPath.Refresh:=false;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.CenterOnHero;
var
  HE: integer;
begin
  HE:=mPlayers[mPL].ActiveHero ;
  if HE=-1 then exit;
  SetLevel(mHeros[HE].pos.l);
  FindHero(HE);
  FDxEngine.Engine.X:=FDxEngine.Engine.Width  div 2 - (gHero.x +2*DL);
  FDxEngine.Engine.Y:=FDxEngine.Engine.Height div 2 - (gHero.y +2*DL);
end;
{----------------------------------------------------------------------------}
procedure TSnGame.FindHero(HE: integer);
var
  oid: integer;
begin
  oid:=mHeros[HE].oid;
  gHero:=TGameHero(FindObjectbyIndex(oid));
end;
{----------------------------------------------------------------------------}
function TSnGame.FindObject(x,y,l: integer):TGamesprite;
var
  oid: integer;
begin
  oid:= mTiles[x,y,l].obX.oid ;
  result:=FindObjectbyIndex(oid);
end;
{----------------------------------------------------------------------------}
function TSnGame.FindObjectbyIndex(oid: integer):TGameSprite;
var
  i: integer;
begin
  result:=nil;
  for i:=0 to FDxEngine.Engine.AllCount-1 do
    if TGameSprite(FDxEngine.Engine.Items[i]).oid=oid  then
    begin
      result:= TGameSprite(FDxEngine.Engine.Items[i]);
      break;
    end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.UpdateHero(HE: integer);

begin
  if HE =-1 then exit;
  with mHeros[HE] do
  begin
   gHero.Direction:=mPath.DirMap[pos.x,pos.y];
   gHero.X:=DL*(pos.x-1+DB);
   gHero.Y:=DL*(pos.y-1+DB);
   gHero.L:=pos.l;
   gHero.Z:=Trunc(1000*gHero.Y-gHero.X);
   if BoatId >0 then
   begin
     with FindObjectbyIndex(boatId) do
     begin
       X:=gHero.X;
       Y:=gHero.Y;
       Z:=gHero.Z;
       AnimStart:=gHero.AnimStart;
       AnimCount:=gHero.AnimCount;
     end;
   end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.AddMoveAction(HE:integer);
var
  Action: ^Taction;
begin
  New(Action);
  Action.ID:=ACT01_Move;
  Action.HE:=HE;
  //try dynamic moving galopper pendant un déplacement
  if (mPath.length>0)
  then if (mHeros[HE].PSKA.mov >= mPath.CostPath[mPath.Path[mPath.length-1].x,mPath.Path[mPath.length-1].y])
  then
  begin
    gHero.CanMove:=true;
    Action.Delay:= 32 div OpHeroSpeed;
    Actions.add(Action);
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.MoveHeroBy(HE,dx,dy: integer);
const
  adir: Array [-1..1,-1..1] of integer = ((4,3,7), (0,0,2),(5,1,6));
var
  x,y,l:integer;
begin
  if HE=-1 then exit;
  FindHero(HE);
  x:=mHeros[HE].pos.x+dx;
  y:=mHeros[HE].pos.y+dy;
  l:=mHeros[HE].pos.l;
  gHero.direction:=aDir[dx,dy];
  MoveHeroTo(HE,x,y,l);
  RefreshHeroList;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.MoveHeroOB(HE,OB: integer);
var
  Action: ^TAction;
begin
  New(Action);
  Action.ID:=Cmd_HE_EnterObj(HE,mOBJs[OB].pos.x,mOBJs[OB].pos.y,mOBJs[OB].pos.l);
  Action.Delay:=2; //ActStartTime;
  Action.HE:=HE;
  Action.OB:=OB;
  Actions.Add(Action);
end;
{----------------------------------------------------------------------------}
function TSnGame.MoveHeroTo(HE,x,y,l: integer):boolean;
var
  TL:integer;
  OB: integer;
  Action: ^TAction;
begin
  result:=false;
  if HE = -1 then exit;
  TL:=Cmd_HE_CheckMove(HE,x,y,l);
  case TL of
    TL_OUT:
    begin
      // no move : obstacle or water or out of map
    end;
    TL_FREE:
    begin
      // move to the free tile... if nCrea > 0 prepare fight
      Cmd_HE_Move(HE,x,y,l);
      result:=true;
      //UpdateHero(HE);
      OB:=Cmd_OB_FindGuard(x,y,l);
      if OB > -1 then //MoveHeroOB(HE,OB);
      begin
        New(Action);
        Action.ID:=Cmd_HE_EnterObj(HE,mOBJs[OB].pos.x,mOBJs[OB].pos.y,mOBJs[OB].pos.l);
        Action.Delay:=2; //ActStartTime;
        Action.HE:=HE;
        Action.OB:=OB;
        Actions.Add(Action);
      end;
    end;
    else  // can enter E of object, message appear after entering
          // need to fight first
    begin
      mes:='nothing';
      //todo check if try find gard works
      OB:=Cmd_OB_FindGuard(x,y,l);
      if (TL<>OB79_Res) and (OB > -1) then
      Begin
        //MoveHeroOB(HE,OB);
        New(Action);
        Action.ID:=Cmd_HE_EnterObj(HE,mOBJs[OB].pos.x,mOBJs[OB].pos.y,mOBJs[OB].pos.l);
        Action.Delay:=2; //ActStartTime;
        Action.HE:=HE;
        Action.OB:=OB;
        Actions.Add(Action);
      // hope something happens after...
      end
      else
      begin
        New(Action);
        Action.ID:=Cmd_HE_EnterObj(HE,x,y,l);
        Action.Delay:=1;  //ActStartTime;
        Action.HE:=HE;
        Action.OB:=mTiles[x,y,l].obX.oid;
        //end;
        if Action.ID = ACT04_Battle then
        begin
          if not(mOBJs[Action.OB].t in [OB06_Pandora, OB34_Hero, OB54_Monster, OB98_City]) then
          begin
            Cmd_HE_Move(HE,x,y,l);
            result:=true;
          //UpdateHero(HE); // canmove processing does update at the end//
          end;
        end;

        if Action.ID in [ACT03_Enter, ACT06_Town, ACT07_Teleport, ACT11_Gar] then
        begin
          Cmd_HE_Move(HE,x,y,l);
          result:=true;
          //UpdateHero(HE); // canmove processing does update at the end//
        end;
        if (Action.ID > ACT00_Nothing) then
          Actions.Add(Action);
      end;//end
    end;
  end;

  CenterOnHero;
  RefreshHeroList;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.CreateInterface;
var
  i : integer;
begin
  gForeground:=TGameForeground.Create(FDxEngine.Engine,ImageList);
  gNavigator:= TDXWNavigator.Create(  FDxEngine,mData.dim,ImageList);
  gBackground:=TGameBackground.Create(FDxEngine.Engine,ImageList);
  gBackground.MakeMiniMap;

  DxO_Hero:=ObjectList.Count;
  for i:=0 to 4 do begin
    AddSprPanel('HPS',617,212+32*i,PnlHero,243);
    TDXWPanel(Objectlist[Objectlist.Count-1]).OnClickR:=PnlHeroR;
    AddSprPanelSelectedImage(Objectlist.count-1,'HPSYYY');
    TDXWPanel(Objectlist[Objectlist.Count-1]).Tag:=130;
  end;

  DxO_Town:=ObjectList.Count;
  for i:=0 to 4 do begin
    AddSprPanel('ITPA',747,212+32*i,PnlTown,246);
    TDXWPanel(Objectlist[Objectlist.Count-1]).OnClickR:=PnlTownR;
    AddSprPanelSelectedImage( Objectlist.count-1,'HPSYYY');
  end;

  DxO_Mobil:=ObjectList.Count;
  for i:=0 to 4 do
    AddSprPanel('IMOBIL',610,212+32*i);

  DxO_Mana:=ObjectList.Count;
  for i:=0 to 4 do
    AddSprPanel('IMANA',666,212+32*i);

end;
{----------------------------------------------------------------------------}
procedure TSnGame.CreateSubScene;
const
  SUB=true;
begin
  SubInfoTown:=TSnInfoTown.Create(SUB);
  SubInfoTown.Parent:=Self;
  SubInfoHero:=TSnInfoHero.Create(SUB);
  SubInfoHero.Parent:=Self;
  SubInfoRes:=TSnInfoRes.Create(SUB);
  SubInfoRes.Parent:=Self;
  SubInfoFlag:=TSnInfoFlag.Create(SUB);
  SubInfoTown.Parent:=Self;
  SubInfoPlayer:=TSnInfoPlayer.Create(SUB);
  SubInfoPlayer.Parent:=Self;
  SubInfoDay:=TSnInfoDay.Create(SUB);
  SubInfoDay.Parent:=Self;
  SubInfoMsg:=TSnInfoMsg.Create(SUB);
  SubInfoMsg.Parent:=Self;
end;
{----------------------------------------------------------------------------}
procedure TSnGame.CreateButton;
begin
  LogP.EnterProc('Begin_CreateButton');
  AddButton('IAM000',679,324,BtnNextHero,239);
  AddButton('IAM001',679,356,BtnEndTurn,240);
  AddButton('IAM002',679,196,BtnOverView,231);
  DxO_Level:=Objectlist.count;
  AddButton('IAM010',711,196,BtnLevel,232);
  AddButton('IAM003',711,196,BtnLevel,232);
  AddButton('IAM004',679,228,BtnPuzzle,233); //quest
  AddButton('IAM005',711,228,BtnPlayer,234); //inactif
  AddButton('IAM006',679,260,BtnMove,235);
  AddButton('IAM007',711,260,BtnBook,236);
  AddButton('IAM008',679,292,BtnScenario,237);
  AddButton('IAM009',711,292,BtnOption,238);
  AddButton('IAM012',608,196,BtnPrevHero,241);      // up hero
  AddButton('IAM013',608,372,BtnNextHero,242);      // down hero
  AddButton('IAM014',747,196,BtnPrevCity,244);      // up town
  AddButton('IAM015',747,372,BtnNextCity,245);      // down town
  //AddEdit('Edit',5,523,BtnEdit);
  LogP.QuitProc('End_CreateButton');
end;
{----------------------------------------------------------------------------}
procedure TSnGame.LoadPicGUI;
var
  i,idx:integer;
begin
LogP.EnterProc('Begin_LoadPicGUI'+name);

LogP.Insert('-LoadBoat');
  LoadBoat(ImageList,'AB01_');

LogP.Insert('-LoadHero');
  LoadHero(ImageList,'AH00_');
  LoadHero(ImageList,'AH01_');
  LoadHero(ImageList,'AH02_');
  LoadHero(ImageList,'AH03_');
  LoadHero(ImageList,'AH04_');
  LoadHero(ImageList,'AH05_');
  LoadHero(ImageList,'AH06_');
  LoadHero(ImageList,'AH07_');
  LoadHero(ImageList,'AH09_');
  LoadHero(ImageList,'AH08_');
  LoadHero(ImageList,'AH10_');
  LoadHero(ImageList,'AH11_');
  LoadHero(ImageList,'AH12_');
  LoadHero(ImageList,'AH13_');
  LoadHero(ImageList,'AH14_');
  LoadHero(ImageList,'AH15_');

LogP.Insert('-LoadHeroFlag');
for i:=0 to 7 do
  LoadTile(ImageList,'ABF01'+PL_INITIAL[i],64,96);

LogP.Insert('-LoadTile');
  LoadTile(ImageList,'DIRTRD',32,32);
  LoadTile(ImageList,'GRAVRD',32,32);
  LoadTile(ImageList,'COBBRD',32,32);
  LoadTile(ImageList,'CLRRVR',32,32);
  LoadTile(ImageList,'ROUGTL',32,32);
  LoadTile(ImageList,'SANDTL',32,32);
  LoadTile(ImageList,'DIRTTL',32,32);
  LoadTile(ImageList,'GRASTL',32,32);
  LoadTile(ImageList,'SNOWTL',32,32);
  LoadTile(ImageList,'SUBBTL',32,32);
  LoadTile(ImageList,'LAVATL',32,32);
  LoadTile(ImageList,'ROCKTL',32,32);
  LoadTile(ImageList,'SWMPTL',32,32);
  LoadTile(ImageList,'WATRTL',32,32);
LogP.Insert('-LoadEDGE') ;
  LoadSprite(ImageList,'EDG');
  LoadSprite(ImageList,'Radar');
LogP.Insert('-LoadFog');
  LoadFog(ImageList,'tshrc',32,32);
LogP.Insert('-LoadPath') ;
  LoadPath(ImageList,'pathrg',32,32);
LogP.Insert('-LoadAirShield');
  LoadBmp(ImageList,'AISHIELD');
LogP.QuitProc('End_LoadPicGUI_'+name);
end;
{----------------------------------------------------------------------------}
Constructor TSnGame.Create;
var
  i: integer;
begin
  ProcessingAction:=true;
  DxMouse.Id:=CrWaits;
  LogP.Insert('-start create');
  inherited Create('SnGame');
  DxMain.AddScene(self);
  LogP.Insert('-start loading');
  SnLoadingMap:=TSnLoadingMap.Create;
  LogP.Insert('-end create');
  AllClient:=True;
  fText:=TxtHelp;
  HintX:=10;
  Level:=0;
  FDxEngine:=TGameSpriteEngine(DXMain.DXEngine);
  //FDxEngine.Engine.FSurfaceRect:=Rect(0,0,590,550); //check if this is limiting draw out of view

  AddBackground('ADVMAP');
  ImageList.Items[0].TransparentColor:=ClBlack;

  AddPanel('ARESBAR',3,575);
  DxO_Res:=ObjectList.Count;
  for i:=0 to MAX_RES-1 do
  AddLabel('ResX',40+84*i,578);
  AddLabel_Center('Day Week Month',610,578,180);
  LogP.Insert('-start gui');
  CreateButton;
  LoadPicGUI;
  //ImageList.Items.SaveToFile(folder.dxg + Name+'.dxg');
  LogP.Insert('-end gui');
  ProcessingAction:=false;
end;
{----------------------------------------------------------------------------}

end.


