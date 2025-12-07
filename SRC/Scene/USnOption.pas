unit USnOption;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnOption= class (TDxScene)
  private
    procedure BtnMenu(Sender: TObject);
    procedure BtnOption(Sender: TObject);
    procedure BtnHeroSpeed(Sender: TObject);
    procedure BtnEnemySpeed(Sender: TObject);
    procedure BtnScrollSpeed(Sender: TObject);
    procedure MusicLevel(sender: TObject);
    procedure SoundLevel(sender: TObject);
  public
    DxO_Level: integer;
    DxO_HeroSpeed: integer;
    DxO_EnemySpeed: integer;
    DxO_ScrollSpeed: integer;
    DxO_Option: integer;
    constructor Create;

  end;

var
  SnOption:TSnOption;

implementation

uses UMain, USnHero,  USnSelect, Utype, UConst, USnGame;

{----------------------------------------------------------------------------}
constructor TSnOption.Create;
var
  i: integer;
begin
  inherited Create('SnOption');
  Left:=120;
  Top:=35;
  HintY:=Top+30;
  HintX:=Left+30;
  FText:=TxtGenrlTxt;
  AddBackground('SYSOPBCK');
  AddTitleScene('System Options',18);
  AddButton('SOLOAD',246,298);
  AddButton('SOSAVE',356,298);
  AddButton('SORSTRT',246,356,BtnOK);

  AddButton('SOMAIN',356,356,BtnMenu);
  AddButton('SOQUIT',246,415);
  AddButton('SORETRN',356,415,BtnOK);

  AddLabel_Center(TxtGenrlTxt[570+i],25,59+66*0,190,10);
  AddLabel_Center(TxtGenrlTxt[570+i],25,59+66*1,190,10);
  AddLabel_Center(TxtGenrlTxt[570+i],25,59+66*2,190,10);
  AddLabel_Center(TxtGenrlTxt[21],   25,59+66*3,190,10);
  AddLabel_Center('Volume sonore',   25,76+66*4,190,10);
  AddLabel_Center('Volume music' ,   25,76+66*5,190,10);

  DxO_Option:=ObjectList.count;
  for i:=0 to 6 do AddButton('SYSOPCHK',246,55+32*i,btnOption);
  for i:=0 to 6 do TDXWButton(ObjectList[DxO_Option+i]).cancheck:=true;
  TDXWButton(ObjectList[DxO_Option+5]).selected:=opShowMapGrid;
  TDXWButton(ObjectList[DxO_Option+6]).selected:=opShowObjectMessage;
  for i:=0 to 4 do AddLabel(TxtGenrlTxt[573+i],280,60+32*i,10);
  AddLabel('Show Map Grid',280,60+32*5,10);
  AddLabel('Show Message object',280,60+32*6,10);


  DxO_HeroSpeed:=ObjectList.count;
  for i:=0 to 3 do
  AddButton('SYSOPB'+ inttostr(i+1),27+48*i,76,BtnHeroSpeed);

  case opHeroSpeed of
  1: TDXWButton(ObjectList[DxO_HeroSpeed+0]).selected:=true;
  2: TDXWButton(ObjectList[DxO_HeroSpeed+1]).selected:=true;
  4: TDXWButton(ObjectList[DxO_HeroSpeed+2]).selected:=true;
  8: TDXWButton(ObjectList[DxO_HeroSpeed+3]).selected:=true;
  end;



  DxO_EnemySpeed:=ObjectList.count;
  for i:=0 to 3 do
  AddButton('SYSOPB'+ inttostr(i+1),27+48*i,144,BtnEnemySpeed);


  DxO_ScrollSpeed:=ObjectList.count;
  AddButton('SYSOPB9',28,209,BtnScrollSpeed);
  AddButton('SYSOB10',28+64*1,209,BtnScrollSpeed);
  AddButton('SYSOB11',28+64*2,209,BtnScrollSpeed);


  DxO_Level:=ObjectList.count;
  AddSPrPanel('SYSLB',27,359);
  AddSprPanel('SYSLB',27,425);
  AddFrame(192,36, 27, 360 , SoundLevel, false);
  AddFrame(192,36, 27, 424 , MusicLevel, false);
  UpdateColor(mPL,1);
  AddScene;
end;
{----------------------------------------------------------------------------}
procedure TSnOption.SoundLevel(sender: TObject);
var
  x: integer;
begin
  x:=(DxMouse.x-TDXWObject(sender).left) div 19;
  TDXWPanel(ObjectList[DxO_Level]).left:=2+TDXWObject(sender).left+x*19;
  TDXWPanel(ObjectList[DxO_Level]).tag:=x;
end;
{----------------------------------------------------------------------------}
procedure TSnOption.MusicLevel(sender: TObject);
var
  x: integer;
begin
  x:=(DxMouse.x-TDXWObject(sender).left) div 19;
  TDXWPanel(ObjectList[DxO_Level+1]).left:=2+TDXWObject(sender).left+x*19;
  TDXWPanel(ObjectList[DxO_Level+1]).tag:=x;
end;
{----------------------------------------------------------------------------}
procedure TSnOption.BtnMenu(Sender: TObject);
begin
  AutoDestroy:=true;
  DxMain.DxEngine.Engine.Clear;
  Parent.AutoDestroy:=true;
  DxScene:=DXSceneList[0];
end;
{----------------------------------------------------------------------------}
procedure TSnOption.BtnOption(Sender: TObject);
var
  SelOption :integer;
begin
  TDXWButton(sender).selected:=not(TDXWButton(sender).selected);
  opShowMapGrid:=TDXWButton(ObjectList[Dxo_Option+5]).selected;
  opShowObjectMessage:=TDXWButton(ObjectList[Dxo_Option+6]).selected;
end;
{----------------------------------------------------------------------------}
procedure TSnOption.BtnHeroSpeed(Sender: TObject);
var
  i, speed:integer ;
begin
  for i:=0 to 3 do
    TDXWButton(ObjectList[DxO_HeroSpeed+i]).selected:=false;
  TDXWButton(sender).selected:=true;
  Speed:= TDXWButton(sender).listid - Dxo_HeroSpeed;
  case speed of
  0:opHeroSpeed:=1;
  1:opHeroSpeed:=2;
  2:opHeroSpeed:=4;
  3:opHeroSpeed:=8;
  end;
end;

{----------------------------------------------------------------------------}
procedure TSnOption.BtnEnemySpeed(Sender: TObject);
var
  i, speed:integer ;
begin
  for i:=0 to 3 do
    TDXWButton(ObjectList[DxO_EnemySpeed+i]).selected:=false;
  TDXWButton(sender).selected:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnOption.BtnScrollSpeed(Sender: TObject);
var
  i, speed:integer ;
begin
  for i:=0 to 2 do
    TDXWButton(ObjectList[DxO_ScrollSpeed+i]).selected:=false;
  TDXWButton(sender).selected:=true;
end;
{----------------------------------------------------------------------------}


end.
