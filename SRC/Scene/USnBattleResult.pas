unit USnBattleResult;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

TSnBattleResult= class (TDxScene)
  private
    procedure BtnQuit(Sender: TObject);
  public
    constructor  Create(name:string);
  end;

procedure processInfoBattleResult;

var
  SnBattleResult: TSnBattleResult;

implementation

uses UMain, USnHero, UType, UBattle;

{----------------------------------------------------------------------------}
procedure processInfoBattleResult;
begin
  if mPLayers[mPL].isCPU then exit;
  mDialog.res:=-1;
  TSnBattleResult.Create('SnBattleResult');
  repeat
    Application.HandleMessage
  until mDialog.res <> -1;
end;
{----------------------------------------------------------------------------}
constructor TSnBattleResult.Create(name:string);
var
  i,j, ndead: integer;
  CR, n: integer;
begin
  inherited Create('SnBattleResult');
  DxMouse.id:=CrDef;;
  DxMouse.Style:=msAdv;
  Left:=180;
  AddBackground('CPRESULT');

  AddSPRPanel('HPL',20,38);
  TDXWPanel(ObjectList[ObjectList.count-1]).tag:=bHeroLeft;
  AddLabel(mHeros[bHeroLeft].name,88,38,10);

  //Defenter PIC to display Hero or Main Army from OBJ
  if bHeroRight = -1
  then
  begin
    CR:=-1;
    AddSPRPanel('TWCRPORT',390,38);
    for i:=21 to 28 do
    if (CR mod 14) < (bUnits[i].t mod 14) then CR:=bUnits[i].t;
    TDXWPanel(ObjectList[ObjectList.count-1]).tag:=CR+2;
    AddLabel_Right(iCrea[CR].name,242,38,140,10);
  end
  else
  begin
    AddSPRPanel('HPL',390,38);
    TDXWPanel(ObjectList[ObjectList.count-1]).tag:=bHeroRight;
    AddLabel_Right(mHeros[bHeroRight].name,242,38,140,10);
  end;

  if bWinLeft
  then
  begin
    bMsg:='A Glorious victory !';
    bMsg:= bMsg + NL + NL + 'For valor in combat, ' + mHeros[bHeroLeft].name +  ' recieves ' + inttostr(bExp) + ' experience';
    AddPanel('BTWIN',106,70);
    AddLabel('Victorious',30,116,10);
    AddLabel('Defeated',390,116,10);
  end

  else
  begin
    bMsg:='Your force suffer a bitter defeat, ' + mHeros[bHeroLeft].name +  ' abandon your cause';
    AddPanel('BTLOSE',106,70);
    AddLabel('Defeated',30,114,10);
    AddLabel('Victorious',395,114,10);
  end;

  AddLabel_Center(bMsg,70,213,330);

  AddLabel_YellowCenter('BattleField Casualties',40,285,380,14);

  AddLabel_Center('Attacker',40,319,380,14);
  nDead:=0;
  for i:=0 to MAX_ARMY do
  if (bUnits[i].n0-bUnits[i].n) > 0 then inc(nDead);
  j:=0;
  for i:=0 to MAX_ARMY do
  begin
    CR:=bUnits[i].t;
    n:=bUnits[i].n0-bUnits[i].n;
    if ((CR > -1) and (n>0)) then
    begin
      AddSprPanel('CPRSMALL',3*55-(ndead div 2)*55+50+55*j,345);
      TDXWPanel(ObjectList[ObjectList.count-1]).tag:=CR+2;
      AddLabel(inttostr(n),3*55-(ndead div 2)*55+50+55*j+15,380);
      inc(j);
    end;
  end;

  AddLabel_Center('Defender',40,418,380,14);
  nDead:=0;
  if bHeroRight = -1
  then
  begin
    CR:=0;
    n:=0;
    for i:=0 to MAX_ARMY do
       if bUnits[i+21].t <> -1
       then
       begin
         n:=n+bUnits[i+21].n0-bUnits[i+21].n;
         CR:=bUnits[i+21].t;
       end;
    if n=0
    then  AddLabel('None',40,414,450)
    else
    begin
    AddSprPanel('CPRSMALL',50+55*3,442);
    TDXWPanel(ObjectList[ObjectList.count-1]).tag:=CR+2;
    AddLabel(inttostr(n),50+55*3+15,479);
    end;
  end
  else
  begin
    for i:=0 to MAX_ARMY do
    if (bUnits[i+21].n0-bUnits[i+21].n) > 0 then inc(nDead);

    j:=0;
    for i:=0 to MAX_ARMY do
    begin
      CR:=bUnits[i+21].t;
      n:=bUnits[i+21].n0-bUnits[i+21].n;
      if ((CR > -1) and (n>0)) then
      begin
        AddSprPanel('CPRSMALL',3*55-(nDead div 2)*55+50+55*j,442);
        TDXWPanel(ObjectList[ObjectList.count-1]).tag:=CR+2;
        AddLabel(inttostr(n),3*55-(nDead div 2)*55+50+55*j+15,479);
        inc(j);
      end;
    end;
  end;
  AddButton('IOKAY',380,505,BtnQuit);
  UpdateColor(mPL,1);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleResult.BtnQuit(Sender: TObject);
begin
  CloseScene;
  mDialog.res:=0;
end;


end.
