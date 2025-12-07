unit USnPlayers;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene, UConst;

type

  TSnPlayers= class (TDxScene)
  public
    DxO_Player, DxO_Res: integer;
    Constructor Create;
    procedure SnDraw(Sender:Tobject);
    procedure SnRefresh;
  end;

var
  SnPlayers: TSnPlayers;

implementation

uses UMain, UPL, UType, UMap;

Constructor TSnPlayers.Create;
var
  i: integer;
begin
  inherited Create('SnPlayers');
  ALLClient:=true;
  AddBackground('TPRank');
  AddPanel('KRESBAR',5,575);
  UpdateColor(mPL,2);
  DxO_Player:=ObjectList.Count;
  for i:=0 to MAX_PLAYER -1 do
  begin
    AddSprPanel('PRSTRIPS',252+ 64 * i,7);
    TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=i-1;
    AddPanel('PR'+PL_COLOR[i],254+ 64 * i,332);
    AddPanel('PR'+PL_COLOR[i],254+ 64 * i,332);
    AddSprPanel('HPS',261 + 64 * i,358);
  end;

  DxO_Res:=ObjectList.Count;
  for i:=0 to MAX_RES-1 do
  AddLabel(inttostr(mPlayers[mPL].RES[i]),35+76*i,578);

  AddLabel_Center('Day Week Month',560,578,180);
  TDXWLabel(ObjectList[ObjectList.Count-1]).caption:=cmd_Map_GetDate;

  AddButton('TPMAGE1',748,556,BtnOK);

  OnDraw:=SnDraw;
  SnRefresh;
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnPlayers.SnRefresh;
var
  i,j,count: integer;
begin
  count:=0;

  for i:=0 to MAX_PLAYER -1 do
  begin
    if  mPlayers[i].nHero > 0
    then
      TDXWPanel(ObjectList[DxO_Player+4*i+3]).Tag:=mPlayers[i].LstHero[0]
    else
      TDXWPanel(ObjectList[DxO_Player+4*i+3]).Tag:=130;
  end;

  for i:=0 to MAX_PLAYER -1 do
  begin
    if (mPlayers[i].isAlive) then
    begin
      for j:=0 to 3 do
      begin
        TDXWObject(ObjectList[DxO_Player+4*i+j]).Left:=TDXWObject(ObjectList[DxO_Player+4*i+j]).Left-64*i+64*count;
      end;
      count:=count+1;
    end
    else
    begin
      for j:=0 to 3 do
        TDXWObject(ObjectList[DxO_Player+4*i+j]).visible:=false;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnPlayers.SnDraw(Sender:Tobject);
var
  PL: integer;
  l: integer;
  count:integer;
begin
  ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DoDraw;
  with DxSurface.Canvas do
  begin
    Brush.Style:=bsClear;
    Font.Color:=ClText;
    Font.Name:=H3Font;// 'Times New Roman';'
    Font.Size:=8;
    Textout(55,44,      'Number of Towns' );
    Textout(55,44+1*32, 'Number of Heroes' );
    Textout(55,44+2*32, 'Gold' );
    Textout(55,44+6*32, 'Artifact' );
    Textout(55,44+7*32, 'Kingdom Army Strength' );
    Textout(55,44+8*32, 'Income' );
    Textout(55,385, 'Best Hero' );
    Textout(55,450, 'Personality' );
    Textout(55,500, 'Best Monster' );
    count:=0;
    for PL:= 0 to 7 do
    if  mPlayers[PL].isAlive then
    with mPlayers[PL] do
    begin
      Cmd_PL_Income(PL);
      l:=264+ 64 * count;
      Textout(l+10-length(name),12, name);
      Textout(l,44, inttostr(nCity));
      Textout(l,76, inttostr(nHero));
      Textout(l,108, inttostr(Res[6]));
      Textout(l,300, inttostr(Income[6]));
      if  nHero > 0 then Textout(l+6-length(mHeros[LstHero[0]].name),450, mHeros[LstHero[0]].name);
      count:=count+1;
    end;
    Release;
  end;
end;

end.
