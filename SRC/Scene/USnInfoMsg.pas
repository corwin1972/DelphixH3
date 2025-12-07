unit USnInfoMsg;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnInfoMsg= class (TDxScene)
  private
    DxO_Msg,AnimCount: integer;
    ftitle, ftext: string;
  public
    AnimEnd: boolean;
    constructor Create(SUB: boolean);
    procedure Update(text:string); //RE,QTY : integer);
    procedure SnDraw(Sender:TObject);
  end;

var
  SnInfoMsg:TSnInfoMsg;

implementation

uses UMain, USnHero,  UType;

{----------------------------------------------------------------------------}
constructor TSnInfoMsg.Create(SUB: boolean);
begin
  inherited Create('SnInfoMsg');
  Left:=605;
  Top:=389;
  AddPanel('ADSTATOT',8,8);
  DxO_Msg:=ObjectList.count;
  //AddSPRPanel('Resour82',56,50);
  AddLabel_YellowCenter('', 14, 20 ,160);
  AddMemo('', 14, 38 ,160, 120);
  Visible:=true;
  AddSubScene;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoMsg.Update(text : string); // RE,QTY : integer);
var
  i,j,k :integer;

begin
  redraw:=true;
  //TDXWPanel(ObjectList[DxO_Res]).tag:=RE;
  //TDXWlabel(ObjectList[DxO_Res+1]).caption:=format(txtADVEVENT[113],[iRes[RE].name]);   //AD113_Res_Bonus] not in UType , in Enter only
  // TDXWlabel(ObjectList[DxO_Res+2]).caption:=inttostr(qty) + ' ' + iRes[RE].name;


    // extract text with { } to find a title
    i:=ANSIPOS('{',text);
    j:=ANSIPOS('}',text);
    if j >0 then
    begin
      FTitle:=copy(Text,i+1,j-i-1);
      if Text[j+1]=Chr(10) then k:=j+2 else k:=j+1;
      FText:= copy(Text,k ,length(Text)-(k-1));
    end
    else
    begin
      FTitle:='';
      FText:=Text;
    end;

  TDXWlabel(ObjectList[DxO_Msg]).caption:= ftitle;
  TDXWlabel(ObjectList[DxO_Msg+1]).caption:= ftext;
  AnimCount:=0;
  AnimEnd:=false;
end;
{----------------------------------------------------------------------------}
procedure TSnInfoMsg.SnDraw(Sender:TObject);
begin
  if ((animcount div 8) = 100)
    then AnimEnd:=True
    else inc(animcount);
  ObjectList.DoDraw;
end;
{----------------------------------------------------------------------------}
end.
