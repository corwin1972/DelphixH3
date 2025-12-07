unit USnBattleOption;


interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnBattleOption= class (TDxScene)
  private
     DxO_Option,DxO_Speed:integer;
     procedure BtnOption(Sender: TObject);
     procedure BtnSpeed(Sender: TObject);
  public
    constructor Create;
   end;

var
  SnBattleOption:TSnBattleOption;

implementation

uses UMain, USnBattlefield, UConst, Utype, Ubattle;

{----------------------------------------------------------------------------}
constructor TSnBattleOption.Create;
var
  i: integer;
begin
  inherited Create('SnBattleOption');
  Left:=120;
  Top:=35;
  HintY:=Top+30;
  HintX:=Left+30;
  AddBackground('COMOPBCK');
  AddTitleScene('Battle Options',18);
  AddButton('CODEFAUL',246,359);
  AddButton('SORETRN',356,359,BtnOK);

  DxO_Option:=Objectlist.Count;
  for i:=0 to 3 do AddButton('SYSOPCHK',23,55+33*i,btnOption);
  for i:=0 to 3 do TDXWButton(ObjectList[DxO_Option+i]).cancheck:=true;
  TDXWButton(ObjectList[DxO_Option]).selected:=opShowBattleGrid;
  TDXWButton(ObjectList[DxO_Option+1]).selected:=opShowBattleMoveRange;
  for i:=0 to 4 do AddButton('SYSOPCHK',246,85+30*i,btnOption);
  for i:=0 to 4 do TDXWButton(ObjectList[DxO_Option+4+i]).canCheck:=true;

  Addlabel('View Grid',65,62,10);
  Addlabel('Shadow',65,62+33,10);
  Addlabel('Cursor',65,62+33*2,10);
  Addlabel('Spell book',65,62+33*3,10);
  Addlabel('Creature', 284,90     ,10);
  Addlabel('Spells',   284,90+30  ,10);
  Addlabel('Catapult', 284,90+30*2,10);
  Addlabel('Ballist',  284,90+30*3,10);
  Addlabel('First aid',284,90+30*4,10);

  Addlabel_Center('Anim Speed',   26,204,190,10);
  Addlabel_Center('Music Volume', 26,284,190,10);
  Addlabel_Center('Effect Volume',26,350,190,10);
  Addlabel_Center('Auto-Combat Options',246,56,210,10);
  Addlabel_Center('Creature Infos',246,256,210,10);

  Addlabel('All Statistic',284,286,10);
  Addlabel('Spells Only',284,315,10);

  AddButton('SYSOPCHK',246,283);
  AddButton('SYSOPCHK',246,314);
  DxO_Speed:=Objectlist.Count;
  AddButton('SYSOPB9',28,225,Btnspeed);
  AddButton('SYSOB10',92,225,Btnspeed);
  AddButton('SYSOB11',156,225,Btnspeed);
  case DxMain.DXTimer.Interval of
    15:TDXWButton(ObjectList[DxO_Speed+0]).selected:=true;
    50:TDXWButton(ObjectList[DxO_Speed+1]).selected:=true;
    700:TDXWButton(ObjectList[DxO_Speed+2]).selected:=true;
  end;

  UpdateColor(mPL,1);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleOption.BtnOption(Sender: TObject);
begin
  TDXWButton(sender).selected:=not(TDXWButton(sender).selected);
  opShowBattleGrid:=TDXWButton(ObjectList[DxO_Option]).selected;
  opShowBattleMoveRange:=TDXWButton(ObjectList[DxO_Option+1]).selected;
end;
{----------------------------------------------------------------------------}
procedure TSnBattleOption.BtnSpeed(Sender: TObject);
var
  i:integer;
begin
  for i:=0 to 2 do
    TDXWButton(ObjectList[DxO_Speed+i]).selected:=false;
  TDXWButton(sender).selected:=true;
  case TDXWButton(sender).listid of
    30 : opAnimspeed:=1;
    31 : opAnimspeed:=5;
    32 : opAnimspeed:=30;
  end;
end;
{----------------------------------------------------------------------------}

end.