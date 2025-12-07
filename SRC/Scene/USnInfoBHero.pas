unit USnInfoBHero;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene, UBattle;

type

  TSnInfoBHero= class (TDxScene)
  private
  public
    constructor Create(HE: integer;side:integer);
  end;

var
  SnInfoBHero:TSnInfoBHero;

implementation

uses UMain, UType;

{----------------------------------------------------------------------------}
Constructor TSnInfoBHero.create(HE: integer;side:integer);
begin
  inherited Create('InfoBHero');
  Left:=0;
  Top:=0;

  AddBackground('CHRPOP');
  if side=1 then Left:=800-78;
  AddSPRPanel('HPL',10,6);
  TDXWPanel(ObjectList[ObjectList.count-1]).tag:=HE;
  AddLabel_Center(mHeros[HE].Name,5,128,65);

  AddLabel('Att',7,75,7);
  AddLabel('Def',7,86,7);
  AddLabel('Pow',7,97,7);
  AddLabel('Kno',7,108,7);
  AddLabel('Ptm',7,146,7);

  AddLabel_Right(inttostr(mHeros[HE].PSKB.att),40,75,30,7);
  AddLabel_Right(inttostr(mHeros[HE].PSKB.def),40,86,30,7);
  AddLabel_Right(inttostr(mHeros[HE].PSKB.pow),40,97,30,7);
  AddLabel_Right(inttostr(mHeros[HE].PSKB.kno),40,108,30,7);
  AddLabel_Right(inttostr(mHeros[HE].PSKA.ptm),40,146,30,7);

  HintY:=Top+288;
  HintX:=Left+30;

  AddButton('IOKAY',6,164,BtnOK);
  UpdateColor(mPL,1);
  AddScene;
end;
{----------------------------------------------------------------------------}


end.

