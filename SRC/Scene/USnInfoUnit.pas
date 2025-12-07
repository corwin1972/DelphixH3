unit USnInfoUnit;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene,  UBattle;

type

  TSnInfoUnit= class (TDxScene)
  private
  public
    constructor Create(slot: integer);
  end;

var
  SnInfoUnit:TSnInfoUnit;

implementation

uses UMain, USnHero,  USnSelect, UType;

{----------------------------------------------------------------------------}
Constructor TSnInfoUnit.create(slot: integer);
var
  i,j:integer;
begin
  inherited Create('InfoUnit');
  Left:=0;
  Top:=270;
  if slot > 20 then left:=800-78;
  HintY:=Top+288;
  HintX:=Left+30;
  AddBackground('CCRPOP');

  with bUnits[slot] do
  begin
    AddSprPanel('TWCRPORT',10,6);
    TDXWPanel(ObjectList[ObjectList.count-1]).tag:=t+2;

    AddLabel(inttostr(n),58,55);
    AddLabel('Att',    7, 74,7);
    AddLabel('Def',    7, 87,7);
    AddLabel('Dmg',    7,100,7) ;
    AddLabel('Health', 7,113,7);
    AddLabel('Speed',  7,138,7);
    AddLabel_Right(format('%d (%d)',[iCrea[t].atk,atk1]),               40,74,30,7);
    AddLabel_Right(format('%d (%d)',[iCrea[t].def,def1]),               40,87,30,7);
    AddLabel_Right(format('%d - %d',[iCrea[t].dmgMin,iCrea[t].dmgMax]),40,100,30,7);
    AddLabel_Right(format('%d/%d',[hit1,hit0]),                      40,113,30,7);
    j:=0;
    for i:=0 to MAX_SPEL -1 do
    begin
      if spelD[i] > 0 then
      begin
        //AddLabel(iSpel[i].shortname +' D' +inttostr(spelD[i]) + ' E' + inttostr(spelE[i]), 10,170+j,7);
        //j:=j+13;
        AddSprPanel('SPELLINT',15,168+37*j);
        inc(j);
        TDXWPanel(ObjectList[ObjectList.count-1]).tag:=i+1;
        TDXWPanel(ObjectList[ObjectList.count-1]).caption:=' D' +inttostr(spelD[i]) +' E' + inttostr(spelE[i]);
      end;
    end;
    //if move <> iCrea[t].speed
    //then AddLabel(format('%d (%d)', [iCrea[t].speed,move]), 40,138)
    //else AddLabel(format('%d',[move]), 40,138);
    //AddLabel(IntToStr(bUnits[slot].shot),30,84,7);
  end;

  AddButton('IOKAY',7,128,BtnOK);
  UpdateColor(mPL,1);
  AddScene;
end;
{----------------------------------------------------------------------------}

end.

