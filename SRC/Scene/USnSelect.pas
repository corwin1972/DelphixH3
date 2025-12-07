unit USnSelect;

interface
uses
  Classes, Graphics, Controls, SysUtils, StrUtils,
  DXWLoad, DXWScene, DXWControls, DXWListBox, DXWScroll, forms, UConst;

type

  TLoadMAPSThread = class(TThread)
  private
  protected
    procedure Execute; override;
  public
    constructor Create;
  end;

  TSnSelect= class (TDxScene)
  protected
    procedure ShowHintClick(Sender: TObject); override;
  private
    DxO_Desc, DxO_Dfc, DxO_ListBox, DxO_List, DxO_Option, DxO_Player, DxO_Size: integer;
    DxO_FLGTeamA, DxO_FLGTeamE : integer;
    procedure CreateListBox;
    procedure CreateOption;
    procedure CreateDescription;
    procedure CreateButton;procedure BtnBegin(Sender: TObject);
    procedure SetScrollBar(Sender: TObject);
    procedure BtnList(Sender: TObject);
    procedure ListClick(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure UpdateDescription(FileId: integer);
    procedure UpdateTeamFlag(PL : integer);
    procedure UpdateListBox(size: integer);
    procedure ChangePlayerName(sender: tobject);
    procedure BtnTeam(Sender: TObject);
    procedure BtnSortListBoxByPL(Sender: TObject);
    procedure BtnSortListBoxBySize(Sender: TObject);
    procedure BtnSortListBoxByName(Sender: TObject);
    procedure FilterListBox(size:integer);
    procedure ShowPlrOption;
    procedure HidePlrOption;
    function  UniqueFaction(faction:integer):boolean;
    procedure BtnOption(Sender: TObject);
    function  FindAllowedHero(CT:integer): integer;
    procedure BtnBonus(Sender: TObject);
    procedure BtnStartBonus(Sender: TObject);
    procedure BtnHero(Sender: TObject);
    procedure BtnStartHero(Sender: TObject);
    procedure BtnCity(Sender: TObject);
    procedure BtnStartCity(Sender: TObject);
    procedure BtnDfc(Sender: TObject);
    procedure BtnSize(Sender: TObject);
    procedure BtnPlayer(Sender: TObject);
    procedure SnMouseUp(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  public
    constructor Create;
  end;

const
  M_SIZE : array [1..4] of string = ('S','M','L','XL');
  RANDOM_CT=34;
  RANDOM_HE=136;
var
  SnSelect: TSnSelect;
  mFiles: TStringList;
  order: integer;
  
implementation

uses UMap, UMain, USnHero, USnGame, UHeader, UFile, UType, USnLoadingMap, USnDialog;

{----------------------------------------------------------------------------}
constructor TLoadMAPSThread.Create;
begin
  FreeOnTerminate := True;
  inherited Create(False);
end;
{----------------------------------------------------------------------------}
procedure TLoadMAPSThread.Execute;
begin
  SnSelect.UpdateListBox(5);
end;
{----------------------------------------------------------------------------}

procedure TSnSelect.SnMouseUp(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // MouseUp(Button,Shift,X,Y);
  ObjectList.MouseUp(Button,Shift,X,Y);
  TDXWScroll(ObjectList[DxO_List-1]).Allup;
end;

procedure TSnSelect.CreateDescription;
var
  i: integer;
begin
  AddLabel_Yellow('Scenario Name:',424,32);
  AddLabel_Yellow('Scenario Description:',424,114);
  AddLabel_Yellow('Victory Condition:',424,290);
  AddLabel_Yellow('Loss Condition:',424,346);
  AddLabel_Yellow('Allies:',424,408);
  AddLabel_Yellow('Enemies:',545,408);
  AddLabel_Yellow('PL:',708,408);
  AddLabel_Yellow('Map Diff:',424,438);
  AddLabel_Yellow('Player Difficulty:',545,438);
  AddLabel_Yellow('Rating:',690,438);
  DxO_Desc:=Objectlist.count;
  AddLabel('No file selected',425,50,10);
  AddMemo('Description',424,134,320,200,9);
  TDXWLabel(ObjectList[DxO_Desc+1]).AlignCenter:=false;
  AddLabel('VicText',460,315);
  AddLabel('LossText',460,371);
  AddLabel('nPlayers',728,408);
  AddSPRPanel('SCNRVICT',424,309);
  AddSPRPanel('SCNRLOSS',424,363);
  AddSPRPanel('SCNRMPSZ',712,28);
  AddLabel_Center('Size number',696,56,60,8);
  DxO_FLGTeamA:=Objectlist.count;
  for i:=0 to MAX_PLAYER-2 do AddSPRPanel('ITGFLAGS',455+ 16* i,405);
  DxO_FLGTeamE:=Objectlist.count;
  for i:=0 to MAX_PLAYER-2 do AddSPRPanel('ITGFLAGS',592+ 16* i,405);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.UpdateTeamFlag(PL : integer);
var
  i,n : integer;
  xFlag: integer;
  hTeam: integer;
begin
  hTeam:=mHeader.Joueurs[PL].team;
  xFlag:=DxO_FLGTeamA;
  n:=0;
  for i:=0 to MAX_PLAYER-1 do
  if mHeader.Joueurs[i].isAlive then
  if mHeader.Joueurs[i].team=hTeam then
  begin
    TDXWPanel(ObjectList[xFlag+n]).Tag:=i;
    TDXWPanel(ObjectList[xFlag+n]).visible:=true;
    n:=n+1;
  end;

  for i:=n to MAX_PLAYER-2 do
    TDXWPanel(ObjectList[xFlag+i]).visible:=false;

  n:=0;
  xFlag:=DxO_FLGTeamE;
  for i:=0 to MAX_PLAYER-1 do
  if mHeader.Joueurs[i].isAlive then
  if mHeader.Joueurs[i].team <> hTeam   then
  begin
    TDXWPanel(ObjectList[xFlag+n]).Tag:=i;
    TDXWPanel(ObjectList[xFlag+n]).visible:=true;
    n:=n+1;
  end;
  for i:=n to MAX_PLAYER-2 do
    TDXWPanel(ObjectList[xFlag+i]).visible:=false;
end;
{----------------------------------------------------------------------------}
function getFileId(des:string):integer;
 var Strings: TStringlist;
begin
   Strings:=TStringList.Create;
   Assert(Assigned(Strings)) ;
   Strings.Clear;
   //Strings.StrictDelimiter := true;
   Strings.Delimiter := ';';
   Strings.DelimitedText := StringReplace(des,' ','',[rfReplaceAll, rfIgnoreCase]);
   result:=strtoint(Strings[0]);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.UpdateDescription(FileId: integer);
var
  i , mFileId: integer;
  s: string;
  //PL: integer;
begin
  if FileId = -1 then exit;
  if TDXWListBox(ObjectList[DxO_List]).Strings.Count = 0 then Exit;
  mFileId:=getFileId(TDXWListBox(ObjectList[DxO_List]).Strings[FileId]);
  TDXWLabel(ObjectList[DxO_Desc]).Caption:=mFiles[mfileid];
  LoadHeader(mFiles[mfileid]);
  TDXWLabel(ObjectList[DxO_Desc+1]).Caption:= mHeader.des;
  TDXWLabel(ObjectList[DxO_Desc+2]).Caption:= mHeader.vic;
  TDXWLabel(ObjectList[DxO_Desc+3]).Caption:= mHeader.los;
  TDXWLabel(ObjectList[DxO_Desc+4]).Caption:=inttostr(mHeader.nPlr);
  TDXWPanel(ObjectList[DxO_Desc+5]).Tag:= (mHeader.vicid+12) mod 12;
  TDXWPanel(ObjectList[DxO_Desc+6]).Tag:= (mHeader.losId+4)  mod 4;
  TDXWPanel(ObjectList[DxO_Desc+7]).Tag:= (mHeader.dim div 36) - 1 ;
  TDXWLabel(ObjectList[DxO_Desc+8]).Caption:=inttostr(mHeader.dim)+ 'x'+ inttostr(mHeader.dim);
  case mHeader.dfc of
    0:  s:='Easy';
    1:  s:='Normal';
    2:  s:='Hard';
    3:  s:='Expert';
    4:  s:='Impossible';
  end;

  TDXWLabel(ObjectList[DxO_Dfc+6]).caption:=s;

  // find first human player
  mPL:=-1;
  for i:=0 to MAX_PLAYER do
    if (mHeader.Joueurs[i].isAlive) and (mHeader.Joueurs[i].isHuman) then
    begin
      mPL:=i;
      break;
    end;

  if mPL <> -1 then UpdateTeamFlag(mPL);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnTeam(Sender: TObject);
begin
  //ProcessInfo('team to show');
  TSndialog.create('Team Alignment', dsTeamInfo); // n: integer =0; p:integer =0);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.CreateButton;
var i: integer;
begin
  DxO_Dfc:=Objectlist.count;
  AddButton('GSPBUT3',507,457,BtnDfc,22);
  AddButton('GSPBUT4',539,457,BtnDfc,23);
  AddButton('GSPBUT5',571,457,BtnDfc,24);
  AddButton('GSPBUT6',603,457,BtnDfc,25);
  AddButton('GSPBUT7',635,457,BtnDfc,26);

  TDxWButton(ObjectList[DxO_Dfc+1]).selected:=true;

  AddLabel('100%', 695, 470);
  AddLabel('MapDfc', 440, 470);
  AddButton('GSPBUTT',417,83,BtnList,43);
  TDXWButton(ObjectList[ObjectList.Count-1]).caption:='Scénarios Disponibles';
  AddButton('GSPBGIN',417,535,BtnBegin);
  AddButton('GSPEXIT',588,535,BtnCancel);
  AddButton('GSPBUTT',417,510,BtnOption,44);
  TDXWButton(ObjectList[ObjectList.Count-1]).caption:='Options Supplémentaires';
  AddFrame(345,25,415,400,BtnTeam);
end;
{----------------------------------------------------------------------------}
constructor TSnSelect.Create ;
begin
  inherited Create('SnSelect');

  fText:=TxtHelp; //TxtGenrlTxt;
  HintX:=-1; //90;
  AllClient:=true;
  AddBackground('SELSCENARIO');
  CreateListBox;
  UpdateListBox(5);
  CreateOption;
  CreateDescription;
  CreateButton;
  UpdateDescription(0);
  AddScene;
  OnMouseUp:=SnMouseUp;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnPlayer(Sender: TObject);
var
  i:integer;
begin
  for i:=0 to MAX_PLAYER-1 do
  begin
    TDXWButton(ObjectList[DxO_Player+15*i+2]).down:=false;
  end;

  TDXWButton(sender).down:=true;
  for i:=0 to MAX_PLAYER-1 do
  begin
    if TDXWButton(ObjectList[DxO_Player+15*i+2]).down then
    begin
      TDXWLabel(ObjectList[DxO_Player+15*i+1]).caption:='NICO';
      mPL:=i;
    end
    else
      TDXWLabel(ObjectList[DxO_Player+15*i+1]).caption:=TxtPlayerColor[i];//'Comptuter';
  end;
  UpdateTeamFlag(mPL);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.CreateListBox;
var
  id: integer;
begin

  DxO_ListBox:=Objectlist.count;
  // 8 items Panel Backkground - Scroll - ListBox - 5 size map button
  AddPanel('SCSELBCK',40,7);
  AddLabel_YellowCenter('Select a Scenario to Play',60,26,330,10);
  AddLabel_Yellow('Map Sizes',80,62);
  DxO_Size:=Objectlist.count;
  AddButton('SCSMBUT',162,53,BtnSize);
  AddButton('SCMDBUT',209,53,BtnSize);
  AddButton('SCLGBUT',256,53,BtnSize);
  AddButton('SCXLBUT',303,53,BtnSize);
  AddButton('SCALBUT',350,53,BtnSize);
  TDxWButton(ObjectList[DxO_Size+4]).selected:=true;

  LoadBmp(imageList,'SELGRID');
  LoadBmp(imageList,'SCROLL');
  LoadSprite(ImageList,'SCNRBUP');
  LoadSprite(ImageList,'SCNRBDN');
  LoadSprite(ImageList,'SCNRBSL');
  LoadSprite(ImageList,'SCNRVICT');
  LoadSprite(ImageList,'SCNRLOSS');

  id:=ObjectList.Add(TDXWScroll.Create(self));
  with TDXWScroll(ObjectList[id]) do
  begin
    Image:=ImageList.Items.Find('SCROLL');
    Btn1Image:=ImageList.Items.Find('SCNRBUP');
    Btn2Image:=ImageList.Items.Find('SCNRBDN');
    ThumbImage:=ImageList.Items.Find('SCNRBSL');
    Left:=376;
    Top:=94;
    Surface:=DxSurface;
    Visible:=true;
  end;
  id:=ObjectList.Add(TDXWListBox.Create(self));
  DxO_List:=id;
  with TDXWListBox(ObjectList[id]) do
  begin
    TDXWListBox(ObjectList[id]).OnMouseUp:=ListClick;
    Image:=ImageList.Items.Find('SELGRID');
    ImgVic:=ImageList.Items.Find('SCNRVICT');
    ImgLos:=ImageList.Items.Find('SCNRLOSS');
    Width:=Image.Width;
    Height:=Image.Height;
    Left:=58;
    Top:=91;
    Font.Color:=clWhite;
    Font.Size:=9;
    Font.Name:=H3Font;// 'Times New Roman';'
    Font.Style:=[];
    Surface:=DxSurface;
    LineHeight:=25;
    Visible:=True;
  end;
  AddButton('SCBUTT1',60,93, BtnSortListBoxByPL);
  AddButton('SCBUTT2',92,93, BtnSortListBoxBySize);
  AddButton('SCBUTT3',125,93,BtnSortListBoxByName);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.SetScrollBar(Sender: TObject);
begin
  with TDXWListBox(ObjectList[DxO_List]) do
  ScrollBar:=TDXWScroll(ObjectList[DxO_List-1]);
end;


{----------------------------------------------------------------------------}
procedure TSnSelect.changePlayerName(sender: tobject);
begin
// with TDXWEdit(sender).Text
end;

{----------------------------------------------------------------------------}
procedure TSnSelect.CreateOption;
var
  i: integer;
begin
  DxO_Option:=Objectlist.count;
  AddPanel('ADVOPTBK',4,7);
  AddLabel_Center(TxtGenrlTxt[516],57,48,392-57,10);            // TxtGenrlTxt[516],
  AddLabel_YellowCenter(TxtGenrlTxt[518],57,95,164-57);         // TxtGenrlTxt[256],  'Name'
  AddLabel_YellowCenter(TxtGenrlTxt[519],164,95,239-164);       // TxtGenrlTxt[519],  'Town'
  AddLabel_YellowCenter(TxtGenrlTxt[520],239,95,315-239);       // TxtGenrlTxt[520],  'Hero'
  AddLabel_YellowCenter(TxtGenrlTxt[521],315,95,394-315);       // TxtGenrlTxt[521],  'Bonus'

  DxO_Player:=Objectlist.count;

  for i:=0 to MAX_PLAYER-1 do begin
    AddPanel('ADOP'+PL_INITIAL2[i]+'PNL',58,129);

    //AddLabel_Center(TxtPlayerColor[i],60,138,100);  //100 is widt of centered area
    AddEdit('Edit66x32',60,138,ChangePlayerName);
    TDXWEdit(ObjectList[DxO_Player+15*i+1]).Text:=TxtPlayerColor[i];
    //AddPanel('ADOPFLG'+PL_INITIAL2[i],15,129);
    AddButton('AOflgb'+PL_INITIAL2[i],15,129,BtnPlayer);
    AddButton('ADOPLFA',164,381,BtnCity,143);
    AddSPRPanel('ITPA',176,381,BtnStartCity);
    AddButton('ADOPRTA',225,381,BtnCity,143);
    AddLabel_Center('RandomT',165,163,235-165,8);

    AddButton('ADOPLFA',240,101,BtnHero,159);
    AddSPRPanel('HPS',252,381,BtnStartHero);
    AddButton('ADOPRTA',301,121,BtnHero,156);
    AddLabel_Center('RandomH',240,163,313-240,8);

    AddButton('ADOPLFA',315,101,BtnBonus,175);
    AddSPRPanel('SCNRSTAR',328,131, BtnStartBonus);
    AddButton('ADOPRTA',377,121,BtnBonus,175);
    AddLabel_Center('RandomR',317,163,389-317,8);

  end;

  for i:=DxO_Option to DxO_Player+15*MAX_PLAYER-1 do
    TDXWPanel(ObjectList[i]).Visible:=false;
end;
 {----------------------------------------------------------------------------}
function getPL(des:string):string;
var Strings: TStringlist;
begin
  Strings:=TStringList.Create;
  Assert(Assigned(Strings)) ;
  Strings.Clear;
  //Strings.StrictDelimiter := true;
  Strings.Delimiter := ';';
  Strings.DelimitedText := StringReplace(des,' ','',[rfReplaceAll, rfIgnoreCase]);
  result:=Strings[1];
end;
{----------------------------------------------------------------------------}
function comparePL(List: TStringList; Index1, Index2: Integer): Integer;
var
  n1, n2: string;
begin
  n1:=getPL(List[Index1]);
  n2:=getPL(List[Index2]);
  if n1 = n2 then
    result := 0
    else
    if n1 < n2 then
    result := order
    else
    result := -order;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnSortListBoxbyPL(Sender: TObject);
begin
  with TDXWListBox(ObjectList[DxO_List]) do
  begin
    Strings.BeginUpdate;
    if (order=- 1) then order:=1 else order:=-1;
    Strings.CustomSort(@comparePL); //(format('%d ; %s ;  %s;%d;%d',[nPlr ,M_SIZE[dim div 36] , name,vicId,losId]));
    Strings.EndUpdate;
  end;
end;
 {----------------------------------------------------------------------------}
function getName(des:string):string;
var Strings: TStringlist;
begin
   Strings:=TStringList.Create;
   Assert(Assigned(Strings)) ;
   Strings.Clear;
   //Strings.StrictDelimiter := true;
   Strings.Delimiter := ';';
   Strings.DelimitedText := StringReplace(des,' ','',[rfReplaceAll, rfIgnoreCase]);
   result:=UpperCase(Strings[3]);
end;
  {----------------------------------------------------------------------------}
function compareName(List: TStringList; Index1, Index2: Integer): Integer;
var
  n1, n2: string;
begin
  n1:=getName(List[Index1]);
  n2:=getName(List[Index2]);
  if n1 = n2 then
    result := 0
    else
    if n1 < n2 then
    result := order
    else
    result := -order;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnSortListBoxbyName(Sender: TObject);
begin
  with TDXWListBox(ObjectList[DxO_List]) do
  begin
    if (order=- 1) then order:=1 else order:=-1;
    Strings.BeginUpdate;
    Strings.CustomSort(@compareName); //(format('%d ; %s ;  %s;%d;%d',[nPlr ,M_SIZE[dim div 36] , name,vicId,losId]));
    Strings.EndUpdate;
  end;
end;
{----------------------------------------------------------------------------}
function getSize(des:string):integer;
var Strings: TStringlist;
begin
   Strings:=TStringList.Create;
   Assert(Assigned(Strings)) ;
   Strings.Clear;
   //Strings.StrictDelimiter := true;
   Strings.Delimiter := ';';
   Strings.DelimitedText := StringReplace(des,' ','_',[rfReplaceAll, rfIgnoreCase]);
   //result:=Strings[2];
   result:= AnsiIndexStr(Strings[2], ['_S_','_M_','_L_','_XL_'])
end;
 {----------------------------------------------------------------------------}
function compareSize(List: TStringList; Index1, Index2: Integer): Integer;
var
  n1, n2: integer;
begin
  n1:=getSize(List[Index1]);
  n2:=getSize(List[Index2]);
  if n1 = n2 then
    result := 0
    else
    if n1 < n2 then
    result := order
    else
    result := -order;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnSortListBoxbySize(Sender: TObject);
begin
  with TDXWListBox(ObjectList[DxO_List]) do
  begin
    Strings.BeginUpdate;
    if (order=- 1) then order:=1 else order:=-1;
    Strings.CustomSort(@compareSize); //(format('%d ; %s ;  %s;%d;%d',[nPlr ,M_SIZE[dim div 36] , name,vicId,losId]));
    Strings.EndUpdate;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.FilterListBox(size:integer);
var
  i : integer;
begin
  with TDXWListBox(ObjectList[DxO_List]) do
  begin
    mFiles.Clear;
    Strings.Clear;
    Strings.BeginUpdate;
    for i:=0 to nList-1 do
    begin
      with mList[i] do
      if (size=5) or (size=dim div 36) then
      begin
        mFiles.Add(fname);
        Strings.Add(format('%d ; %d ; %s ;  %s;%d;%d',[mFiles.Count-1,nPlr ,M_SIZE[dim div 36] , name,vicId,losId]));
      end;
    end;
    Strings.EndUpdate;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.UpdateListBox(size:integer);
var
  sr: TSearchRec;
begin
  if mFiles=nil then mFiles:=TStringList.Create else mFiles.Clear;

  with TDXWListBox(ObjectList[DxO_List]) do
  begin
    LogP.Insert('UpdateListBOX') ;
    DxMouse.Id:=CrWaits;
    Strings.Clear;
    Strings.BeginUpdate;
    if FindFirst(folder.map+'*.*', FaAnyFile, sr) = 0 then   //*.h3m
    begin
      repeat
        Application.ProcessMessages;
        DxMain.DrawScreen;

        if sr.Size > 10 then
        begin
          LogP.EnterProc(inttostr(mFiles.count)+ ' - ' + sr.Name );
          LoadHeader(sr.Name);
          if (mHeader.ver<>0) then
          begin
            if (size=5) or (size=mHeader.dim div 36) then
            begin
            mList[mFiles.count]:=mHeader;
            mFiles.Add(sr.Name);
            Strings.Add(format('%d; %d ; %s ;  %s;%d;%d',[mFiles.Count-1,mHeader.nPlr ,M_SIZE[mHeader.dim div 36] , mHeader.name,mHeader.vicId,mHeader.losId]));
            end;
          end;
          LogP.QuitProc('---------------------------------------------');
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
      if size=5 then nList:=mFiles.count;
    end;
    Strings.EndUpdate;
  end;
  SetScrollBar(self);
  DxMouse.Id:=CrDef;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnList(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to 12 do  //todo 10 to replace by xx -1...
    ObjectList[DxO_ListBox+i].Visible:=not(ObjectList[DxO_ListBox+i].Visible);

  for i:=DxO_Option to DxO_Player+15*MAX_PLAYER-1 do
    TDXWPanel(ObjectList[i]).Visible:=false;
end;
{----------------------------------------------------------------------------}
function TSnSelect.UniqueFaction(faction:integer):boolean;
var
  i,t:integer;
begin
  t:=0;
  for i:=0 to 9 do
  begin
    t:=t+ ((faction div 2 ) and (1) );
    faction:= faction div 2;
  end;
  result:= (t=1);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.ShowPlrOption;
var
  HE,CT,i,j,k, n: integer;
const
  myTop : array [0..14] of integer = (129,133,129,135,132,135,163,135,132,135,163,135,132,135,163);
begin
  for i:=DxO_Option to DxO_Player-1 do
    TDXWPanel(ObjectList[i]).Visible:=true;
  n:=0;
  for i:=0 to MAX_PLAYER-1 do
  begin
    k:=DxO_Player+15*i;
    TDXWPanel(ObjectList[DxO_Player+15*i+2]).down:=false;
    TDXWLabel(ObjectList[DxO_Player+15*i+1]).caption:= TxtPlayerColor[i]  ;//'Computer';
    if mHeader.Joueurs[i].isAlive=false then
    begin
      for j:=0 to 14 do
        ObjectList[k+j].Visible:=false;
    end
    else
    begin
      for j:=0 to 14 do
      begin
        ObjectList[k+j].Visible:=true;
        ObjectList[k+j].top:=myTop[j]+n*50;
      end;

      if mHeader.Joueurs[i].isHuman
      then  ObjectList[k+2].Visible:=true
      else  ObjectList[k+2].Visible:=false;
      inc(n);

      if mHeader.Joueurs[i].isHuman then
      if mPL=-1 then mPl:=i;

      HE:=mHeader.Joueurs[i].ActiveHero;
      if HE > -1 then
      begin
        TDXWButton(ObjectList[k+7]).visible:=false;
        TDXWPanel(ObjectList[k+8]).tag:=HE;
        TDXWButton(ObjectList[k+9]).visible:=false;
        if mHeader.Joueurs[i].ActiveHeroName =''
        then TDXWLabel(ObjectList[k+10]).caption:=mHeros[HE].name
        else TDXWLabel(ObjectList[k+10]).caption:=mHeader.Joueurs[i].ActiveHeroName;
      end
      else
      begin
        TDXWButton(ObjectList[k+7]).visible:=true;
        TDXWPanel(ObjectList[k+8]).tag:=RANDOM_HE;
        TDXWButton(ObjectList[k+9]).visible:=true;
        TDXWLabel(ObjectList[k+10]).caption:='Random';
      end;
      case mHeader.Joueurs[i].Faction of
        1 :  CT:=0;
        2 :  CT:=1;
        4 :  CT:=2;
        8 :  CT:=3;
        16:  CT:=4;
        32:  CT:=5;
        64:  CT:=6;
        128: CT:=7;
        else CT:=-1;
      end;

      mHeader.Joueurs[i].ActiveCity:=CT;
      if CT > -1 then
      begin
        TDXWButton(ObjectList[k+3]).visible:=false;
        TDXWPanel(ObjectList[k+4]).tag:=2+2*CT;
        TDXWButton(ObjectList[k+5]).visible:=false;
        TDXWLabel(ObjectList[k+6]).caption:=TxtTownType[CT];
      end
      else
      begin
        TDXWButton(ObjectList[k+3]).visible:=true;
        TDXWPanel(ObjectList[k+4]).tag:=RANDOM_CT;
        TDXWButton(ObjectList[k+5]).visible:=true;
        TDXWLabel(ObjectList[k+6]).caption:='Random';
      end;
      if UniqueFaction(mHeader.joueurs[i].Faction) then
      begin
        ObjectList[k+3].Visible:=false;
        ObjectList[k+5].Visible:=false;
      end;

    end;
    TDXWPanel(ObjectList[k+12]).tag:=10;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.HidePlrOption;
var
  i: integer;
begin
  for i:=DxO_Option to DxO_Player+15*MAX_PLAYER-1 do   //15 obj per plr strip
    TDXWPanel(ObjectList[i]).Visible:=false;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnOption(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to 12 do  //todo 10 to replace by xx -1...
    ObjectList[DxO_ListBox+i].Visible:=false;

  if ObjectList[DxO_Option].Visible then
    HidePlrOption
  else
    ShowPlrOption;

  TDXWPanel(ObjectList[DxO_Player+15*mPL+2]).down:=true;
  TDXWLabel(ObjectList[DxO_Player+15*mPL+1]).caption:='NICO';

end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnStartBonus(Sender: TObject);
var
  sBO:integer;
begin
  sBO:=TDxWPanel(sender).tag;
  ProcessPregameDialog('Starting Bonus', dsStartBonus,sBO);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnBonus(Sender: TObject);
var
  BtnId,OptionId,
  PL,
  Action:integer;
  old, new, v: integer;
  TXT: string;
begin
  BtnId:=TDxWButton(sender).ListId-DxO_Player;
  PL:=BtnId div 15;             //lineid=PL not line position
  Action:=(BtnId mod 15) - 12;  //-1 +1
  OptionId:=DxO_Player+15*PL+12;
  old:=TDxWPanel(ObjectList[OptionId]).tag;
  if old < 8 then old:=0 else old:=old-7;
  new:=(4+ old+action) mod 4;     //7+((old-7)+action+4) mod 4 ;

  if new = 0 then
  begin
    if mHeader.Joueurs[PL].ActiveCity = -1
    then new:=9-action
    else new:=mHeader.Joueurs[PL].ActiveCity;
  end
  else
    new:=new+7;

  v:=new;
  mHeader.Joueurs[PL].bonus:=v;

  TDXWPanel(ObjectList[OptionId]).tag:=new;
  case v of
    0 : txt:='Bois/Pierre';     //693;
    1 : txt:='Crystal';         //693;
    2 : txt:='Gem';             //693;
    3 : txt:='Mercure';         //693;
    4 : txt:='Bois/Pierre';     //693;
    5: txt:='Sulfure';          //693;
    6: txt:='Bois/Pierre';      //86
    7: txt:='Bois/Pierre';      //86;
    8: txt:='Or';               //85;
    9: txt:='Artefact';         //84;
   10: txt:='Random';           //87;
  end;
  TDXWLabel(ObjectList[OptionId+2]).caption:=Txt; //TxtGenrlTxt[txt]; //85-8+v];
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnHero(Sender: TObject);
var
  BtnId,OptionId,
  PL, HE,
  Action:integer;
  oldTag: integer;
  i:integer;
  CT :integer;
begin
  BtnId:=TDxWButton(sender).ListId-DxO_Player;
  PL:=BtnId div 15;                     //lineid=PL not line position
  if mHeader.joueurs[PL].ActiveCity=-1 then exit;

  Action:=(BtnId mod 15) - 8 ;          //-1 +1
  OptionId:=DxO_Player+15*PL+8;
  oldTag:=TDxWPanel(ObjectList[OptionId]).tag;
  CT:=(TDxWPanel(ObjectList[DxO_Player+15*PL+4]).tag -2) div 2 ;

  if oldTag = RANDOM_HE then
  begin
    for i:=1 to 16 do
    begin
      if action=1  then HE:=16*CT -1 + i ;
      if action=-1 then HE:=16*CT +16- i;
      if mHeros[HE].used=false then break;
    end;
  end
  else
  begin
    for i:=1 to 17 do
    begin
      if action=1  then HE:=oldtag + i ;
      if action=-1 then HE:=oldtag - i;
      if HE=16*CT+16 then HE:=-1;
      if HE=16*CT-1 then HE:=-1;  //if HE=16*CT-16 then HE:=-1;
      if mHeros[HE].used=false then break;
    end;
   end;

  mHeros[oldTag].used:=false ;      // do not care if -1 or real
  if HE = -1
  then
  begin
    TDXWPanel(ObjectList[OptionId]).tag:=RANDOM_HE;
    TDXWLabel(ObjectList[OptionId+2]).caption:='Random';
  end
  else
  begin
    mHeros[HE].used:=true;
    TDXWPanel(ObjectList[OptionId]).tag:=HE;
    TDXWLabel(ObjectList[OptionId+2]).caption:=mHeros[HE].name;
  end;
  mHeader.joueurs[PL].ActiveHero:=HE;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnStartHero(Sender: TObject);
var
  sHE:integer;
begin
  sHE:=TDxWPanel(sender).tag;
  ProcessPregameDialog('Starting Hero', dsStartHero,sHE);
end;
{----------------------------------------------------------------------------}
function TSnSelect.FindAllowedHero(CT:integer):integer;
var
  i, HE : integer;
begin
  for i:=1 to 16 do
  begin
    HE:=16* CT + i ;
    if mHeros[HE].used=false then break
  end;
  result:=HE;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnStartCity(Sender: TObject);
var
  sCT:integer;
begin
  sCT:=(TDxWPanel(sender).tag-2) div 2;
  ProcessPregameDialog('Starting CITY', dsStartCity,sCT);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnCity(Sender: TObject);
var
  i, BtnId, OptionId,
  PL, CT, HE,
  Action:integer;
  oldtag,newtag: integer;
begin
  BtnId:=TDxWButton(sender).ListId-DxO_Player;
  PL:=BtnId div 15;                 //lineid=PL not line position
  Action:=(BtnId mod 15) - 4;       //-1 +1
  OptionId:=DxO_Player+15*PL+4;
  oldTag:=TDxWPanel(ObjectList[OptionId]).tag;
  if oldTag=RANDOM_CT then CT:=-1 else CT:=(oldTag-2) div 2;

  if mHeader.joueurs[PL].isRndFaction then
  for i:=1 to 9 do
  begin
    CT:=((CT+action+10 ) mod 9) -1;
    case CT of
      -1: break;
      0: if (mHeader.joueurs[PL].Faction and 1) = 1 then break;
      1: if (mHeader.joueurs[PL].Faction and 2) = 2 then break;
      2: if (mHeader.joueurs[PL].Faction and 4) = 4 then break;
      3: if (mHeader.joueurs[PL].Faction and 8) = 8 then break;
      4: if (mHeader.joueurs[PL].Faction and 16) = 16 then break;
      5: if (mHeader.joueurs[PL].Faction and 32) = 32 then break;
      6: if (mHeader.joueurs[PL].Faction and 64) = 64 then break;
      7: if (mHeader.joueurs[PL].Faction and 128) = 128 then break;
    end;
  end;

  if not(mHeader.joueurs[PL].isRndFaction) then
  for i:=1 to 8 do
  begin
    CT:=(CT+action+8) mod 8;
    case CT of
      //-1: break;
      0: if (mHeader.joueurs[PL].Faction and 1) = 1 then break;
      1: if (mHeader.joueurs[PL].Faction and 2) = 2 then break;
      2: if (mHeader.joueurs[PL].Faction and 4) = 4 then break;
      3: if (mHeader.joueurs[PL].Faction and 8) = 8 then break;
      4: if (mHeader.joueurs[PL].Faction and 16) = 16 then break;
      5: if (mHeader.joueurs[PL].Faction and 32) = 32 then break;
      6: if (mHeader.joueurs[PL].Faction and 64) = 64 then break;
      7: if (mHeader.joueurs[PL].Faction and 128) = 128 then break;
    end;
  end;


  if CT=-1 then
  begin
    newtag:=RANDOM_CT;
    TDXWPanel(ObjectList[OptionId]).tag:=newTag;
    TDXWLabel(ObjectList[OptionId+2]).caption:='Random'
  end
  else
  begin
    newTag:=2*CT+2;
    TDXWPanel(ObjectList[OptionId]).tag:=newTag;
    TDXWLabel(ObjectList[OptionId+2]).caption:=TxtTownType[CT];
  end;
  //if old=new ??? then exit;
  if oldtag=newtag then exit;

  oldTag:=TDXWPanel(ObjectList[OptionId+4]).tag;
  if oldTag <> RANDOM_HE then mHeros[oldTag].used:=false;
  // on changing CT propose a random hero
     HE:=-1;
     TDXWPanel(ObjectList[OptionId+4]).tag:=RANDOM_HE;
     TDXWLabel(ObjectList[OptionId+6]).caption:='Random';

  mHeader.joueurs[PL].ActiveCity:=CT;
  mHeader.joueurs[PL].ActiveHero:=HE;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnDfc(Sender: TObject);
var
  i:integer;
  s:string;
begin
  for i:=0 to 4 do
    TDXWButton(ObjectList[DxO_Dfc+i]).selected:=false;
    TDXWButton(sender).selected:=true;
  for i:=0 to 4 do
    if TDXWButton(ObjectList[DxO_Dfc+i]).selected then
    mHeader.dfc:=i;
  case mHeader.dfc of
    0 : s:='80 %';
    1 : s:='100 %';
    2 : s:='130 %';
    3 : s:='160 %';
    4 : s:='200 %';
  end;
  TDXWLabel(ObjectList[DxO_Dfc+5]).caption:=s;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnSize(Sender: TObject);
var
  i:integer;
  size: integer;
begin
  for i:=0 to 4 do
    TDXWButton(ObjectList[DxO_Size+i]).selected:=false;
  TDXWButton(sender).selected:=true;
  size:=1+TDXWObject(sender).listid-DxO_Size;
  FilterListbox(size);
  UpdateDescription(0);
  TDXWListBox(ObjectList[DxO_List]).ScrollBar:=TDXWScroll(ObjectList[DxO_List-1]);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.BtnBegin(Sender: TObject);
begin
  LogP.InsertRedSTR('NEW GAME', mHeader.fName);
  mHeader.custom:=true;
  mData.fName:=mHeader.fName;
  mData.LoadStep:=-1;
  SnGame:=TSnGame.Create;
  Parent:=SnLoadingMap;
  AutoDestroy:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.ListClick(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LineID: integer;
begin
  LineID:=TDXWListBox(ObjectList[DxO_List]).ItemIndex;
  UpdateDescription(LineID);
end;
{----------------------------------------------------------------------------}
procedure TSnSelect.ShowHintClick(Sender: TObject);
begin
   processPreGameInfo(TDxwObject(sender).name);
end;

end.
