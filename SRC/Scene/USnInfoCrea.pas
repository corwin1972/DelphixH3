unit USnInfoCrea;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWLoad , DXWControls, DXWScene,  UCT, USnDialog;

type

  TSnInfoCrea= class (TDXScene)
  private
    fAnim: integer;
    DxO_PicCr,DxO_InfoCr: integer;
    procedure BtnUp(Sender: TObject);
    procedure BtnLose(Sender: TObject);
  public
    CT,HE,CR,NB:integer;
    constructor Create(_CT,_HE,_CR,_NB: integer);

    procedure SnDraw(Sender:TObject);
    procedure SnRefresh(Sender:TObject);
  end;

var
  SnInfoCrea:TSnInfoCrea;

implementation

uses UMain, USnHero,  USnSelect, UType, UArmy;


{----------------------------------------------------------------------------}
procedure TSnInfoCrea.SnRefresh(Sender:TObject);
begin
  TDxWLabel(ObjectList[DxO_PicCr-2]).caption:=iCrea[CR].name;

  with TDXWPanel(ObjectList[DxO_PicCr]) do
  begin
    Name:=inttostr(CR);
    LoadUnit(CR,CR,ImageList);
    Image:=ImageList.Items.Find(inttostr(CR));
  end;

  with iCrea[CR] do
  begin
    TDXWLabel(ObjectList[  DxO_InfoCr]).Caption:=TxtCastInfo[0];   //genrltxt line 227
    TDXWLabel(ObjectList[7+DxO_InfoCr]).Caption:=inttostr(atk);
    if HE <>-1 then
    TDXWLabel(ObjectList[7+DxO_InfoCr]).Caption:=inttostr(atk) + ' ('+inttostr(atk+MHeros[HE].PSKB.att)+')';
    TDXWLabel(ObjectList[  DxO_InfoCr+1]).Caption:=TxtCastInfo[1];
    TDXWLabel(ObjectList[7+DxO_InfoCr+1]).Caption:=inttostr(def);
    if HE <>-1 then
    TDXWLabel(ObjectList[7+DxO_InfoCr+1]).Caption:=inttostr(def) + ' ('+inttostr(def+MHeros[HE].PSKB.def)+')';

    if (Shots > 0) then
    begin
    TDXWLabel(ObjectList[7+DxO_InfoCr+2]).Caption:=inttostr(shots) ;
    TDXWLabel(ObjectList[  DxO_InfoCr+2]).Caption:='Munitions';
    end;

    TDXWLabel(ObjectList[  DxO_InfoCr+3]).Caption:='Degat'; //copy(TxtHelp[376],2,Ansipos(chr(9),TxtHelp[376])-2);
    TDXWLabel(ObjectList[7+DxO_InfoCr+3]).Caption:=format('%d - %d',[dmgMin,dmgMax]);

    TDXWLabel(ObjectList[  DxO_InfoCr+4]).Caption:=TxtCastInfo[3];
    TDXWLabel(ObjectList[7+DxO_InfoCr+4]).Caption:=inttostr(hit);
    TDXWLabel(ObjectList[  DxO_InfoCr+6]).Caption:=TxtCastInfo[4];
    TDXWLabel(ObjectList[7+DxO_InfoCr+6]).Caption:=inttostr(speed);
  end;

  TDXWButton(ObjectList[DxO_PicCr+1]).visible:=false;
  if CT<>-1 then
    if ((CR mod 2=0) and cmd_CT_ShowBuild(CT,37+(CR div 2) mod 7)) then
      TDXWButton(ObjectList[DxO_PicCr+1]).visible:=true;


end;
{----------------------------------------------------------------------------}
Constructor TSnInfoCrea.Create(_CT,_HE,_CR,_NB: integer);
var
  i,id: integer;
  ext: string;
begin
  inherited Create('SnInfoCrea');
  CT:=_CT;
  HE:=_HE;
  CR:=_CR; ext:=TNext2[CR div 14];
  NB:=_NB;
  //LoadFromFile('SnInfoCrea');
  OnRefresh:=SnRefresh;
  OnDraw:=SnDraw;

  Left:=200;
  Top:=100;
  HintX:=Left+30;
  HintY:=Top+288;
  fAnim:=0;

  DxO_InfoCr:=ObjectList.Count;
  for i:=0 to 6 do AddLabel(' ',155,47+19*i,10);
  for i:=0 to 6 do AddLabel_Right('0',220,47+19*i,50);

  AddBackground('CRSTKPU');
  AddTitleScene(iCrea[CR].name,20);
  AddPanel('CRBKG'+ ext,21,47);

  DxO_PicCr:=ObjectList.Count;
  TDXWPanel(ObjectList[DxO_PicCr-1]).Caption:=inttostr(NB);

  ObjectList.Add(TDXWPanel.Create(self));

  with TDXWPanel(ObjectList[DxO_PicCr]) do
  begin
    Name:=inttostr(CR);
    id:=LoadUnit(CR,CR,ImageList);
    Image:=ImageList.Items[ID];  //.Find(inttostr(CR));
    Width:=Image.Width;
    Height:=Image.Height;
    Left:=50;
    Top:=0;
    Surface:=DxSurface; // DXDraw.Surface;
  end;

  AddButton('IVIEWCR',74,238,BtnUp);
  AddButton('IVIEWCR2',232,188,BtnLOSE);
  TDxWButton(ObjectList[ObjectList.Count-1]).Enabled:=gArmy.canlose;
  AddButton('IOKAY',214,238,BtnOK);
  UpdateColor(mPL,1);
  SnRefresh(self);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoCrea.SnDraw(Sender:TObject);
begin
  if Background>-1
  then ImageList.Items[Background].Draw(DxSurface, Left, Top, 0);
  fAnim:=(fAnim +1) mod (4 * TDXWPanel(ObjectList[DxO_PicCr]).Image.Patterncount);
  TDXWPanel(ObjectList[DxO_PicCr]).Tag:=fAnim div 8;
  ObjectList.DoDraw;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoCrea.BtnUp(Sender:TObject);
begin
  with gArmy do
  begin
    if ((pArmys[aid,tid].t mod 2)=0) then
      if processQuestion('Update Creature Level')
        then begin
          CR:=pArmys[aid,tid].t+1;
          pArmys[aid,tid].t:=CR;
          autorefresh:=true;
        end;
  end;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoCrea.BtnLOSE(Sender:TObject);
begin
  if processQuestion('Sure to Lose this crea') then
  with gArmy do
  begin
    pArmys[aid,tid].t:=-1;
    parent.autorefresh:=true;
  end;
  CloseScene;
end;
{----------------------------------------------------------------------------}

end.

