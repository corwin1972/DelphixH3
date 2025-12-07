unit USnInfoFlag;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene,Math;

type

  TSnInfoFlag= class (TDxScene)
  private
    AnimCount: integer;
    DxO_Flag: integer;
  public
    AnimCycle: integer;
    Constructor Create(SUB: boolean=false);
    procedure Update(pId: integer);
    procedure SnDraw(Sender:TObject);
  end;



implementation

uses UMain, USnHero, Utype;

Constructor TSnInfoFlag.Create(SUB: boolean=false);
begin
  inherited Create('SnInfoFlag');
  Left:=614;
  Top:=400;
  AddBackground('ADSTATOT');
  //UpdateColor(mPL,0);
  DxO_Flag:=ObjectList.count;
  AddLabel_Center('PlayerName',40,13,100);
  AddSPRPanel('CREST58',20,58) ;
  AddSPRPanel('HOURSAND',100,58);
  AddSPRPanel('HOURGLAS',100,58);
  OnDraw:=SnDraw;
  if SUB then AddSubScene else AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoFlag.Update(Pid: integer);
begin
  redraw:=true;
  //UpdateColor(mPL,0);
  TDXWLabel(ObjectList[DxO_Flag]).caption:='PL_'+inttostr(mPL)+ '  '+mPlayers[mPL].name;
  TDXWPanel(ObjectList[DxO_Flag+2]).Tag:=0;
  TDXWPanel(ObjectList[DxO_Flag+3]).Tag:=0;
  AnimCount:=0;
  AnimCycle:=max(30,30*mPlayers[mPL].nHero);
  TDXWPanel(ObjectList[DxO_Flag+1]).tag:=mPL;
  Show;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoFlag.SnDraw;
begin
  if (animcount div AnimCycle)  < Imagelist.Items[2].PatternCount
  then
  TDXWPanel(ObjectList[DxO_Flag+2]).Tag:=animcount div AnimCycle;
  TDXWPanel(ObjectList[DxO_Flag+3]).Tag:=animcount div AnimCycle;
  ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  ObjectList.DoDraw;
  animcount:=(animcount+1) mod (10*AnimCycle);
end;
{----------------------------------------------------------------------------}
end.
