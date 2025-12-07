unit USnMage;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DxWLoad , DXWScene;

type
  TSnMage= class (TDxScene)
  private
  public
    constructor Create(CT: integer);
    procedure BtnSpells(Sender:Tobject);
  end;

var
  SnMage:TSnMage;

implementation

uses UMain, UFile, USnDialog, UMap, UType;

{----------------------------------------------------------------------------}
constructor TSnMage.create(CT: integer);
var
  i, SP, DxO_Spell, SpellMax: integer;
  slot: integer;
begin
  inherited  Create('SnMage');
  AllClient:=true;
  HintX:=70;
  HintY:=560;
  AddBackground('TPMAGE');
  AddPanel('TResBAR',6,576);
  AddPanel('TPMAGE'+TNext4[mCitys[CT].t],331,74);
  DxO_Spell:=ObjectList.Count;

  if mCitys[CT].CONS[Cons11_Mage1] then
  for i:=0 to 5 do
     AddSprPanel('SPELLSCR',222+90*i+ 28* (i div 3),445,BtnSPELLS);

  if mCitys[CT].CONS[Cons12_Mage2] then
  for i:=0 to 4 do
     AddSprPanel('SPELLSCR',52,52+ 94*i,BtnSPELLS);

  if mCitys[CT].CONS[Cons13_Mage3] then
  for i:=0 to 3 do
     AddSprPanel('SPELLSCR',580+85*(i mod 2),81 + 80* (i div 2),BtnSPELLS);

  if mCitys[CT].CONS[Cons14_Mage4] then
  for i:=0 to 2 do
     AddSprPanel('SPELLSCR',188,42+106*i,BtnSPELLS);

  if mCitys[CT].CONS[Cons15_Mage5] then
  for i:=0 to 1 do
     AddSprPanel('SPELLSCR',517+85*i,324,BtnSPELLS);

  SpellMax:=ObjectList.Count;

  for SP:=0 to MAX_SPEL do
  begin
    slot:=mCitys[CT].Spels[SP];
    if ((slot > 0) and (slot < SpellMax)) then
    begin
      TDXWPanel(ObjectList[DxO_Spell+slot-1]).Tag:=SP;
      TDXWPanel(ObjectList[DxO_Spell+slot-1]).Name:=iSpel[SP].name;
    end;
  end;

  for i:=DxO_Spell to SpellMax-1 do
  begin
    if TDXWPanel(ObjectList[i]).Tag=0 then TDXWPanel(ObjectList[i]).visible:=false;
  end;

  slot:=mCitys[CT].Spels[0];
  if slot <>0 then
  TDXWPanel(ObjectList[DxO_Spell+slot-1]).visible:=true;


  for i:=0 to MAX_RES-1 do
    AddLabel(inttostr(mPlayers[mPL].RES[i]),35+76*i,578);

  AddLabel(Cmd_Map_GetDate,572,578);

  AddButton('TPMAGE1',748,556,BtnOK);
  UpdateColor(mPL,2);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnMage.BtnSpells(Sender:Tobject);
var
  SP: integer;
begin
  SP:=TDXWPanel(sender).Tag;
  ProcessDialog('',dsSpell,SP,-1);
end;
{----------------------------------------------------------------------------}
end.
