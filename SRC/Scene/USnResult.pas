unit USnResult;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnResult= class (TScene)
  private
    procedure BtnQuit(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  public
    constructor  Create(name:string);  override;
  end;

var
  SnResult:TSnResult;

implementation

uses UMain, USnHero,  Utype, UBattle;

{----------------------------------------------------------------------------}
constructor TSnResult.Create(name:string);
var
  i,j, ndead: integer;
  CR, n: integer;
begin
  inherited Create('SnResult');
  gMouse.id:=CrDef;;
  gMouse.Style:=msAdv;
  Left:=180;
  AddBackground('CPRESULT');

  AddSPRPanel('HPL',20,38);
  TDXWPanel(ObjectList[ObjectList.count-1]).tag:=battHero;
  AddLabel(mHeros[battHero].name,88,38);

  if bDefHero = -1
  then
  begin
    AddSPRPanel('TWCRPORT',390,38);
    TDXWPanel(ObjectList[ObjectList.count-1]).tag:=mobjs[bDefObj].u+2;
    AddLabel(iCrea[mObjs[bDefObj].u].name,248,38);
  end
  else
  begin
    AddSPRPanel('HPL',390,38);
    TDXWPanel(ObjectList[ObjectList.count-1]).tag:=bDefHero;
    AddLabel(mHeros[bDefHero].name,248,38);
  end;

  if bWin
  then
  begin
    bMsg:='A Glorious victory';
    AddPanel('BTWIN',106,70);
    AddLabel('Victorious',30,114);
    AddLabel('Defeated',400,114);
  end

  else
  begin
    bMsg:='Your force suffer a bitter defeat, ' + mHeros[bAttHero].name +  ' abandon your cause';
    AddPanel('BTLOSE',106,70);
    AddLabel('Defeated',30,114);
    AddLabel('Victorious',400,114);
  end;

  AddLabel_Center(bMsg,70,213,330);

  AddLabel_Center('Attaker',40,315,380);
  nDead:=0;
  for i:=0 to MAX_ARMY do
  if (bUnits[i].n0-bUnits[i].n) > 0 then inc(ndead);
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

  AddLabel_Center('Defender',40,414,380);
  if bDefHero = -1
  then
  begin
    //CR:=mobjs[bDefObj].u;
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
    begin
      AddSprPanel('CPRSMALL',50+55*i,442);
      CR:=bUnits[i+21].t;
      n:=bUnits[i+21].n0-bUnits[i+21].n;
      if ((CR > -1) and (n>0)) then
      begin
        TDXWPanel(ObjectList[ObjectList.count-1]).tag:=CR+2;
        AddLabel(inttostr(n),50+55*i+15,479);
      end;
    end;
  end;
  AddButton('HSBTNS',350,505,BtnQuit);
  UpdateColor(mPL,1);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnResult.BtnQuit(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CloseScene;
  mDialog.res:=0;
end;


end.
