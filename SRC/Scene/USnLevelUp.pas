unit USnLevelUp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DxWLoad, DXWScene, Utype, Umap;
type

  TSnLevelUp= class (TDxScene)
  private
    FAnswer: byte;
    DxO_Pic, DxO_OK: integer;
  public
    Constructor Create(HE,psk,sk1,sk1Level, sk2,sk2Level: integer);
    procedure KeyDown(Sender:TObject;var Key: Word; Shift: TShiftState);
    procedure CloseDialog;
    procedure BtnOK(Sender: TObject);
    procedure Btn1(Sender: TObject);
    procedure Btn2(Sender: TObject);
  end;

var
  SnLevelUp: TSnLevelUp;

implementation

uses UMain, UConst;

{----------------------------------------------------------------------------}
constructor TSnLevelUp.create(HE,psk,sk1,sk1Level, sk2,sk2Level: integer);
begin
  if mPLayers[mPL].isCPU then
  begin
    mDialog.res:=1;
    exit;
  end;
  inherited Create('SnLevelUp');
  FAnswer:=0;
  OnKeyDown:=KeyDown;
  AddBackground('LVLUPBKG');

  Left:=195;
  Top:=40;
  HintX:=230;
  HintY:=440;
  AddLabel_Center(mHeros[HE].name + ' has gained a level', 30, 25,330);
  AddSprPanel('HPL',170,66);
  TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=HE;
  AddLabel_Center(mHeros[HE].name + ' is now a level ' + inttostr(mHeros[HE].level)+ ' ' + iHero[mHeros[HE].classeId].Name, 30, 154,320);
  AddSprPanel('PSKIL42',175,190);
  TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=psk;
  AddLabel_Center( TxtPRISKILL[psk] + ' + 1', 30, 245,330);

  DxO_Pic:=ObjectList.Count;

  AddSprPanel('SECSKILL',100,330,Btn1);
  TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=3+3*sk1+sk1level-1;
  AddSprPanelSelectedImage(ObjectList.Count-1,'sel42x42');
  // no preselection TDXWPanel(ObjectList[ObjectList.Count-1]).selected:=true;

  AddLabel_Center( TxtMasterName[sk1level-1], 70, 380,100);
  AddLabel_Center( iSSK[sk1].name, 70, 395,100);

  AddSprPanel('SECSKILL',240,330,Btn2);
  TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=3+3*sk2+sk2level-1;
  AddSprPanelSelectedImage(ObjectList.Count-1,'sel42x42');
  TDXWPanel(ObjectList[ObjectList.Count-1]).selected:=false;

  AddLabel_Center( TxtMasterName[sk2level-1], 210, 380,100);
  AddLabel_Center( iSSK[sk2].name, 210, 395,100);


  AddLabel_Center( 'Your Hero may learn one those skills',30, 290,330);
  DxO_OK:=ObjectList.Count;
  AddButton('IOKAY',  297,414,BtnOk);
  TDXWButton(ObjectList[DxO_OK]).Enabled:=false;
  UpdateColor(mPL,1);
  DxMouse.id:=0;
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnLevelUp.KeyDown(Sender:TObject;var Key: Word; Shift: TShiftState);
begin
  if fAnswer=0 then exit;
  mDialog.res:=fAnswer;
  CloseScene;
end;
{----------------------------------------------------------------------------}
procedure TSnLevelUp.Btn1(Sender:Tobject);
begin
  TDXWPanel(Objectlist[DxO_Pic]).selected:=false;
  TDXWPanel(Objectlist[DxO_Pic+3]).selected:=false;
  TDXWPanel(sender).selected:=true;
  fAnswer:=1;
  TDXWButton(ObjectList[DxO_OK]).Enabled:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnLevelUp.Btn2(Sender:Tobject);
begin
  TDXWPanel(Objectlist[DxO_Pic]).selected:=false;
  TDXWPanel(Objectlist[DxO_Pic+3]).selected:=false;
  TDXWPanel(sender).selected:=true;
  fAnswer:=2;
  TDXWButton(ObjectList[DxO_OK]).Enabled:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnLevelUp.CloseDialog;
begin
  mDialog.res:=fAnswer;
  CloseScene;
end;
{----------------------------------------------------------------------------}
procedure TSnLevelUp.BtnOK(Sender:Tobject);
begin
  if fAnswer=0 then exit;
  CloseDialog;
end;

end.

