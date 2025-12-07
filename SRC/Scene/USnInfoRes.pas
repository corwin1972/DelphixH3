unit USnInfoRes;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnInfoRes= class (TDxScene)
  private
    DxO_Res,AnimCount: integer;
  public
    AnimEnd: boolean;
    constructor Create(SUB: boolean);
    procedure Update(text:string; RE,QTY : integer);
    procedure SnDraw(Sender:TObject);
  end;

var
  SnInfoRes:TSnInfoRes;

implementation

uses UMain, USnHero,  UType;

{----------------------------------------------------------------------------}
constructor TSnInfoRes.Create(SUB: boolean);
begin
  inherited Create('SnInfoRes');
  Left:=605;
  Top:=389;
  AddPanel('ADSTATOT',8,8);
  DxO_Res:=ObjectList.count;
  AddSPRPanel('Resour82',56,50);
  AddMemo('', 30, 17,132, 40);
  AddMemo('', 30,160,132, 40);
  Visible:=true;
  AddSubScene;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoRes.Update(text:string; RE,QTY : integer);
begin
  redraw:=true;
  TDXWPanel(ObjectList[DxO_Res]).tag:=RE;
  TDXWlabel(ObjectList[DxO_Res+1]).caption:=format(text,[iRes[RE].name]);  //text; // format(txtADVEVENT[113],[iRes[RE].name]);   //AD113_Res_Bonus] not in UType , in Enter only


     if qty > 0
          then TDXWlabel(ObjectList[DxO_Res+2]).caption:=inttostr(qty) + ' ' +  iRes[re].name
          else TDXWlabel(ObjectList[DxO_Res+2]).caption:=inttostr(-qty ) + '/day';
  AnimCount:=0;
  AnimEnd:=false;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoRes.SnDraw(Sender:TObject);
begin
  if ((animcount div 8) = 10)
    then AnimEnd:=True
    else inc(animcount);
  ObjectList.DoDraw;
end;
{----------------------------------------------------------------------------}
end.
