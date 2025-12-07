unit USnScenario;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type

  TSnScenario= class (TDxScene)
  private
     DxO_Desc: integer;
  public
    Constructor Create;
  end;

var
  SnScenario:TSnScenario;

implementation

uses UMap, UMain, USnHero, UType;

Constructor TSnScenario.Create;
var
  i,n: integer;
  s:string;
begin
  inherited Create('SnScenario');
  Left:=100;
  AddBackground('GSELPOP1');
  AddButton('SORETRN',210,515,BtnOK);

  AddLabel_Yellow('Scenario Name:',25,25);             // 424,32);
  AddLabel_Yellow('Scenario Description:',25,120);     // 424,114);
  AddLabel_Yellow('Victory Condition:',25,283);        //424,290);
  AddLabel_Yellow('Loss Condition:',25,339);           //424,346);
  AddLabel_Yellow('Joueurs:',25,401);                  //424,408);
  AddLabel_Yellow('Map Diff.',25,430);                 //424,437);
  AddLabel_Yellow('Player Difficulty',146,430);        //545,437);
  AddLabel_Yellow('Rating',291,430);                   //690,437);

  DxO_Desc:=ObjectList.Count;
  AddLabel(mData.name,25,45,10);
  AddLabel(mData.des,25,140,10);
  with TDXWLabel(ObjectList[ObjectList.Count-1]) do
  begin
    width:=330;
    height:=200;
    autosize:=false
  end;
  //DxO_Desc:=Objectlist.count;
  //AddLabel('No file selected',425,50,12);
  //AddMemo('Description',424,134,320,200);
  //TDXWLabel(ObjectList[DxO_Desc+1]).fcenter:=false;

  AddLabel(mData.vic,61,308,10);                       //460,315,10);
  AddLabel(mData.los,61,364,10);                       //460,371,10);
  AddLabel(inttostr(mdata.nPlr),101,401,10);            //500,408,10);

  AddSPRPanel('SCNRVICT',25,302);                       //424,309);
  AddSPRPanel('SCNRLOSS',25,356);                       //424,363);
  AddSPRPanel('SCNRMPSZ',315,21);                       //714,28);
  for i:=0 to MAX_PLAYER do AddSPRPanel('ITGFLAGS',144+ 16* i,398);    //540+ 16* i,405);

  AddButton('GSPBUT3',110,450);                         //507,457);
  AddButton('GSPBUT4',142,450);                         //539,457);
  AddButton('GSPBUT5',174,450);                         //571,457);
  AddButton('GSPBUT6',206,450);                         //603,457);
  AddButton('GSPBUT7',238,450);                         //635,457);


  TDXWPanel(ObjectList[DxO_Desc+5]).Tag:= (mData.vicid+12) mod 12;
  TDXWPanel(ObjectList[DxO_Desc+6]).Tag:= (mData.losId+4)  mod 4;
  TDXWPanel(ObjectList[DxO_Desc+7]).Tag:= mData.dim div 36 - 1 ;

  case mData.dfc of
  0:  s:='Easy';
  1:  s:='Normal';
  2:  s:='Hard';
  3:  s:='Expert';
  4:  s:='Impossible';
  end;

  //TDXWLabel(ObjectList[IDXdif+6]).caption:=s;
  n:=0 ;
  for i:=0 to MAX_PLAYER do
  if mPlayers[i].isAlive then
  begin
    TDXWPanel(ObjectList[DxO_Desc+8+n]).Tag:=i;
    TDXWPanel(ObjectList[DxO_Desc+8+n]).visible:=true;
    n:=n+1;
  end;
  for i:=n to MAX_PLAYER do
    TDXWPanel(ObjectList[DxO_Desc+8+i]).visible:=false;

  AddScene;
end;

end.


