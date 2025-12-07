unit USnDialog;

interface

uses
  Windows, Messages, SysUtils, StrUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DXWControls, DxWLoad, DXWScene, UType, Umap;


type

  TSnDialog= class (TDxScene)
  protected
    FAnswer: integer;
  private
    FTitle: String;
    FText: String;
    FULLText: String;
    startline: integer;
    FTopTitle,
    FLengthText,
    FTopText,
    FTopPic ,
    FTopCaption : integer;
    FStyle: integer;
    Dxo_Text, DxO_Pic1, DxO_Pic2, DxO_OK : integer;
    HH,WW,HTXT: integer;
    procedure DrawBackGround(W,H,L,T: integer);
    procedure DrawBorder;
    procedure ScrollUp;
    procedure ScrollDown;
    procedure SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  public
    property  Style: integer read FStyle write FStyle;
    property  Answer: integer read FAnswer write FAnswer;
    Constructor Create(Text:string; style:integer; n: integer =0; p: integer=0);
    procedure SnDraw(Sender:TObject);
    procedure KeyDown(Sender:TObject;var Key: Word; Shift: TShiftState);
    procedure CloseDialog;
    procedure BtnOK(Sender: TObject);
    procedure BtnValid(Sender: TObject);
    procedure BtnCancel(Sender: TObject);
    procedure Btn1(Sender: TObject);
    procedure Btn2(Sender: TObject);
  end;

  function  processQuestion(s:string):boolean;
  procedure processDialog(s:string;t,v:integer; p: integer=-1);
  procedure processInfo(s:string);
  procedure processPreGameInfo(s:string);
  procedure processPreGameDialog(s:string;t,v:integer; p: integer=-1);
  procedure processEnterInfo(s:string);
  procedure popInfo(s:string);
  procedure processInfoScroll(s:string);
  procedure processInfoTurn;
  procedure ProcessMapRumor;
  procedure ProcessMapEvent;
var
  SnDialog: TSnDialog;

implementation

uses USnInfoMsg, UMain, UConst, USnGame, UFile, UPL;

{----------------------------------------------------------------------------}
procedure processInfoTurn;
begin
  if mPLayers[mPL].isCPU then exit;
  mDialog.res:=-1;
  TSnDialog.Create(mData.weekmsg+ NT+ mPlayers[mPL].name+ ' ''s turn',dsFlag,0);
  repeat
    Application.HandleMessage
  until mDialog.res <> -1;
end;
{----------------------------------------------------------------------------}
procedure processDialog(s:string;t,v:integer; p: integer=-1);
begin
  if mPLayers[mPL].isCPU then exit;
  if (sngame <> nil) and sngame.started = false then exit;
  if not(opShowObjectMessage) then
  begin
    case t of
      dsRes0..dSRes0+6:  begin
         SnGame.SubInfoRes.update(s,T,v);
         SnGame.SHOWID:=SHOW3_RES;
         exit;
      end;
      {else   // need to have process info(type/ proce info question
      begin
         SnGame.SubInfoMsg.update(s);
         SnGame.SHOWID:=SHOW7_MSG;
         exit
      end;}
    end;
  end;
  if SnGame <> NIL then SnGame.Drawing:=false;
  mDialog.res:=-1;
  TSnDialog.Create(s,t,v,p);
  repeat
    Application.HandleMessage
  until mDialog.res <> -1;
end;
{----------------------------------------------------------------------------}
procedure processPreGameDialog(s:string;t,v:integer; p: integer=-1);
begin
  mDialog.res:=-1;
  TSnDialog.Create(s,t,v,p);
  repeat
    Application.HandleMessage
  until mDialog.res <> -1;
end;
{----------------------------------------------------------------------------}
procedure processPreGameInfo(s:string);
begin
    mDialog.res:=-1;
    TSnDialog.Create(s,dsNone,0);
    repeat
      Application.HandleMessage
    until mDialog.res <> -1;
end;
{----------------------------------------------------------------------------}
procedure processInfoScroll(s:string);
begin
    mDialog.res:=-1;
    TSnDialog.Create(s,dsInfoScroll,0);
    repeat
      Application.HandleMessage
    until mDialog.res <> -1;
end;
{----------------------------------------------------------------------------}
procedure processInfo(s:string);
begin
  if mPLayers[mPL].isCPU then exit;
  mDialog.res:=-1;
  TSnDialog.Create(s,dsNone,0);
  repeat
    Application.HandleMessage
  until mDialog.res <> -1;
end;
{----------------------------------------------------------------------------}
procedure processEnterInfo(s:string);
begin
  if mPLayers[mPL].isCPU then exit;
  if (opShowObjectMessage)
  then
  begin
    mDialog.res:=-1;
    TSnDialog.Create(s,dsNone,0);
    repeat
      Application.HandleMessage
    until mDialog.res <> -1;
  end
  else
  begin
     SnGame.SubInfoMsg.update(s);
     SnGame.SHOWID:=SHOW7_MSG;
  end;
end;
{----------------------------------------------------------------------------}
procedure popInfo(s:string);
begin
  if mPLayers[mPL].isCPU then exit;
  TSnDialog.Create(s,dsPop,0);
end;
{----------------------------------------------------------------------------}
function processQuestion(s:string):boolean;
begin
  if mPLayers[mPL].isCPU then begin
    result:=true;
    exit;
  end;
  mDialog.res:=-1;
  TSnDialog.Create(s ,dsYesNo, mDialog.v);
  repeat
    Application.HandleMessage
  until mDialog.res <> -1;
  if mDialog.res=1 then result:=true else result:=false
end;
{----------------------------------------------------------------------------}
procedure ProcessMapEvent;
var
  EV: integer;
begin
  if nEvents > 0 then
  begin
    for EV:=0 to nEvents-1 do
    begin
      if mEvents[EV].startday=28*mData.month+7*mData.week+mData.day
      then
      begin
        if  (   (mEvents[EV].PL and (1 shl mPL)) =  (1 shl mPL) ) then
        begin
        processInfo(mEvents[EV].desc);
        Cmd_PL_ApplyEvent(mPL,EV);
        end;
      end;
    end;
  end;

  if ncEvents > 0 then
  begin
    for EV:=0 to ncEvents-1 do
    begin
      if mcEvents[EV].startday=28*mData.month+7*mData.week+mData.day
      then
      begin
        if mCitys[mcEvents[EV].city].pid = mPL then
        if  (   (mcEvents[EV].PL and (1 shl mPL)) =  (1 shl mPL) ) then
        begin
        processInfo(mcEvents[EV].desc);
        Cmd_PL_ApplycEvent(mPL,EV);
        end;
      end;
    end;
  end;

end;
{----------------------------------------------------------------------------}
procedure ProcessMapRumor;
var
  RM: integer;
begin
  if nRumors > 0 then
    begin
      for RM:=0 to nRumors-1 do
      begin
        if mRumors[RM].date=28*mData.month+7*mData.week+mData.day
        then
          processInfo(mRumors[RM].desc);
      end;
    end;
end;
{----------------------------------------------------------------------------}
constructor TSnDialog.create(Text:string; Style: integer; n: integer =0; p:integer =0);
var
  x: integer;
  costSpel: integer;
  s: string;
  pic1: string;
  pic2: string;
  tag1: integer;
  tag2: integer;
  DxPic: integer;
  pic1_x: integer;
  pic2_x: integer;
  caption1: string ;
  caption2: string ;
  TextRect:TRect;

  {----------------------------------------------------------------------------}
  procedure DefinePosition;
  begin
    // Title impact
    DxSurface.Canvas.Font.size:=12;
    if fTitle = ''
    then begin
      fTopTitle:=28;
      fTopText:=32;
      hh:=32;
      ww:=128;
    end
    else begin
      fTopTitle:=28;
      fTopText:=48;
      hh:=48;
      ww:=max(ww, 64 + DxSurface.Canvas.TextWidth(FTitle));
    end;

    // Text Impact
    DxSurface.Canvas.Font.size:=10;
    if fText <> ''
    then begin
      fLengthText:=DxSurface.Canvas.TextWidth(FText);
      if fLengthText < 450
      then ww:=max(ww, 96  + fLengthText div 2 )
      else ww:=max(ww, 384);

      //estimation de la hauteur
      TextRect := Rect(0,0,ww-40,0);
      HTXT:=DrawText(DxSurface.Canvas.handle,
            PChar(fTExt), length(FText),
            TextRect, DT_CALCRECT or DT_CENTER or DT_WORDBREAK);
      TextRect := Rect(0,0,ww-40,htxt);
      hh:=min(hh+HTXT+8,440);  //TO DO CAPE the hh to avoid blank bakground above 512*412
    end;

    // Pic Impact
    if pic1 <> ''
    then begin
      DxPic:=LoadSprite(ImageList,pic1);
      fTopPic:= hh ;
      ww:=max(ww,256);
      hh:=hh + ImageList.Items.Items[DxPic].height;
      pic1_x:= (ww - ImageList.Items[DxPic].Width) div 2;
      FTopCaption:=hh+4;
    end;

    if caption1 <> ''
    then hh:=hh+32;

    if Style= dsYesNo   then ww:=max(ww,256);

    case Style of
      dsPop : begin
        Top:= Max(0,Min(550-hh,DxMouse.Y-(hh div 2)));
        Left:=Max(0,Min(600-ww,DxMouse.X-(ww div 2)));
      end;
      dsMonster:  begin
        hh:=hh+20;
        Top:= Max(0,Min(550-hh,DxMouse.Y-(hh div 2)));
        Left:=Max(0,Min(600-ww,DxMouse.X-(ww div 2)));
      end;
      dsTeamInfo : begin
        hh:=hh + 20 + 58 + 46 * mHeader.nTeams;
        top :=  (550-hh) div 2;
        left:= (800-ww) div 2;
      end;

      else begin
        hh:=hh+64;
        top:=  (550-hh) div 2;
        left:= (600-ww) div 2;
      end;

    end;

    HintX:=left+20;
    HintY:=top+hh-35;

    if pic2 <> ''
    then begin
      DxPic:=LoadSprite(ImageList,pic2);
      pic1_x:=(ww - ImageList.Items[DxPic].Width) div 2 -50;
      pic2_x:=(ww - ImageList.Items[DxPic].Width) div 2 +50;
    end;

    if hh < 112 then hh:=hh+16;

  end;

  {----------------------------------------------------------------------------}
  procedure DefinePicture;
  var
    sk:integer;
  begin

    pic1:='';
    pic2:='';

    case style of
      dsRes0..dSRes0+6:   //DS 0..6  N=Qty of ressource or regular earned qty
        begin
          pic1:='RESOUR82';
          tag1:=style-dsRes0;
          FText:=format(FText,[iRes[tag1].name]);
          if n > 0
          then caption1:=inttostr(n) + ' ' +  iRes[tag1].name
          else caption1:=inttostr(-n) + '/day';
        end;

      dsArtQ:              //DS 8     N=Artifact id
      begin
          pic1:='ARTIFACT';
          tag1:=n;
          //FTitle:= iArt[n].name;
          //FText:=iArt[n].desc;
      end;

      dsArt:              //DS 8     N=Artifact id
        begin
          pic1:='ARTIFACT';
          tag1:=n;
          //FTitle:= iArt[n].name;
          //FText:=iArt[n].desc;
        end;

      dsSpell:            //DS 9     N=Spell id
        begin
         pic1:='SPELLSCR'; //'SPELLS';
         tag1:=n;
         FTitle:=iSpel[n].name + ' Lev '  + inttostr(iSPEL[n].level);

         if (FText='') then begin
         if (p=-1) then fText:=NL  + iSPEL[n].Bas.desc
         else
         begin
           Case iSpel[n].school of
           SCHOOL0_Fire:   SK:=SK14_Fire_Magic;
           SCHOOL1_Air:    SK:=SK15_Air_Magic;
           SCHOOL2_Water:  SK:=SK16_Water_Magic;
           SCHOOL3_Earth : SK:=SK17_Earth_Magic;
           end;

           case mHeros[p].SSK[SK] of
           0 : begin
              FTitle:='Novice '  + iSpel[n].name + ' Lev '  + inttostr(iSPEL[n].level);
              FText:=iSpel[n].BAS.desc;
              costSpel:=iSpel[n].BAS.cost;
              end;
           1: begin
              FTitle:='Basic '  + iSpel[n].name + ' Lev '  + inttostr(iSPEL[n].level);
              FText:=iSpel[n].NOV.desc;
              costSpel:=iSpel[n].NOV.cost;
              end;
           2:  begin
              FTitle:='Advanced ' +iSpel[n].name + ' Lev '  + inttostr(iSPEL[n].level);
              FText:= iSpel[n].EXP.desc;
              costSpel:=iSpel[n].EXP.cost;
              end;
           3:  begin
              FTitle:='Expert ' + iSpel[n].name + '  Lev '  + inttostr(iSPEL[n].level);
              FText:= iSpel[n].MAS.desc;
              costSpel:=iSpel[n].MAS.cost;
              end;
          end;
          FText:=NL + FText + NL + ' for a cost of ' + inttostr(costSpel);
          end;
        end;
        end;

      dsFlag:             //DS 10;       //Number of flag
        begin
          pic1:='CREST58';
          tag1:=mPL;
          caption1:=mPlayers[mPL].name;
        end;

      dsLuck_p:           //DS 11        11 + , 12 ,  13 - of luck
        begin
          pic1:='ILCK82';
          tag1:=3+ n;
          caption1:='Luck level'+ inttostr(n);
        end;

      //dsLuck_n=12;      (neutral) 12 no matter
      //dsLuck_m=13;      (negative) Not supported in heroes. 13  - of luck

      dsMorale_p :        //DS 14        14 + , 15 ,  16 - of moral
      begin
        pic1:='IMRL82';
        tag1:=3+n;
        caption1:='Moral level '+ inttostr(n);
      end;

      //dsMorale_n=15;    (neutral) 15 no matter
      //dsMorale_m=16;    (negative)16 - of Morale

      dsExperience:       //DS 17        N=Qty of expertience
      begin
        pic1:='PSKILL';
        tag1:=4;
        caption1:=inttostr(n) +' Expérience';
      end;

      dsSecSkill:         //DS 20        N=Skill + level*
      begin
        pic1:='SECSK82';
        tag1:=n;
        if Ftext='' then
        begin
          FTitle:=TxtMasterName[n mod 3] + ' ' + iSSK[(n-3)div 3].name;
          FText:=iSSK[(n-3)div 3].Lev[n mod 3].desc;
        end;
        caption1:=TxtMasterName[n mod 3] + ' ' + iSSK[(n-3)div 3].name;
      end;

      dsMonster:          //DS 21        N=Map object id
      begin
        pic1:='TWCRPORT';  // pannel of crea
        tag1:=2+mObjs[n].u;
        case mMonsters[mObjs[n].v].qty of
           0..4 : s:=TxtARRAYTXT[170];
           5..9 : s:=TxtARRAYTXT[173];
          10..19: s:=TxtARRAYTXT[176];
          20..49: s:=TxtARRAYTXT[179];
          50..99: s:=TxtARRAYTXT[182];
          else    s:=TxtARRAYTXT[185];
        end;
        caption1:=format('%s %s'+ NT+ ' (%d)',[s,iCrea[mObjs[n].u].name,mMonsters[mObjs[n].v].qty]);
      end;
      //  QtyQuelque=4 QtyPlusieurs=9 QtyGroupe=19 QtyBeaucoup=49
      //  QtyHorde=99  QtyFoule=249   QtyNuee=499  QtyMultitude=999 Qtylegion ++

      //dsBuilding=22;     //DS 22..30 town type (Format T) Type of building Format U

      dsPriSkill..dsPriSkill+3:   //DS 31..34 each skill N=Qty
      begin
        pic1:='PSKILL';
        tag1:=style-dsPriSkill ;
        caption1:=format('+%d %s',[n,TxtPRISKILL[tag1]]);
        if tag1=5 then //  if tag1=3 why a second skill to show ??
        begin
        pic2:='PSKILL';
        tag2:=2;
        caption2:=format('+%d %s',[n,TxtPRISKILL[tag2]]);
        Style:= dsYesNo;
        if Ftext='' then FTitle:='Primary skill';

        end;
      end;

      dsSpellPoints:       //DS 35 spell points  N=Qty
      begin
        pic1:='PSKILL';
        tag1:=5;
        caption1:='+ '+ inttostr(n)+ ' spoints';
      end;

      dsMoney:             //DS 36  money        N=Qty
      begin
        pic1:='RESOUR82';
        tag1:=6;
      end;

      dsMoneyExp:          //DS 37  money or exp
      begin
        pic1:='RESOUR82';
        tag1:=6;
        pic2:='PSKILL';
        tag2:=4;
        caption1:=inttostr(500* n) ;
        caption2:=inttostr(500*n-500);
      end;

      dsStartHero:
      begin
        pic1:= 'HPS';
        Tag1:=n;
        if n = 136 then caption1:= 'Random Hero for Town Selected'
        else
        begin
        caption1:=mHeros[n].name + ' Spec ' + mHeros[n].spec1;
        end;
      end;

      dsStartCity:
      begin
        pic1:= 'ITPA';
        Tag1:=2*n+2;
        if n = 16  then caption1:= 'Random City'
        else
        begin
        caption1:=TxtTownType[n];
        end;
      end;

      dsStartBonus:
      begin
        pic1:= 'SCNRSTAR';
        Tag1:=n;
        case n of
          0..7: caption1:=TxtGenrlTxt[86];
          8   : caption1:=TxtGenrlTxt[85];
          9   : caption1:=TxtGenrlTxt[84];
          else  caption1:=TxtGenrlTxt[87];
        end;
      end;

      dsMapBonus :
      begin
        pic1:='RESOUR82';
        tag1:=6;
        pic2:='RESOUR82';
        tag2:=n;
        caption1:=inttostr(100* p) + ' ' + iRes[6].name;
        caption2:=inttostr(p) + ' ' + iRes[n].name;
      end;

    end;   // end case style = DSxxxx

  end;
  {----------------------------------------------------------------------------}
  procedure DefineText;
  var
    i,j,k :integer;
  begin
    // extract text with { } to find a title
    i:=ANSIPOS('{',Text);
    j:=ANSIPOS('}',Text);
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

    i:=ANSIPOS(chr(9),fText);
    if i >1 then  FText:= copy(FText,0,i-2);

    // remove unnecessary " from text
    FText:=AnsiReplaceStr(FText, '""', 'zzz');
    FText:=AnsiReplaceStr(FText, '"', '');
    FText:=AnsiReplaceStr(FText, 'zzz', '"');

    caption1:='';
    caption2:='';


    if Style =DSInfoScroll then
    begin
      FullText:=Ftext;
      startline:=0;
      OnMouseDown:=SnMouseDown;
      ScrollUp;
    end;
  end;
  {--------------------------------------------------------------------------}
  procedure AddTeamFlag;
  var
    i,j,t: integer;
    TeamArray: array [0..7,0..7] of shortint;
    nTeamMember: integer;
  begin
    for i:=0 to 7 do
    for j:= 0 to 7 do TeamArray[i,j]:=-1;

    for i:=0 to MAX_PLAYER-1 do
    begin
      if mHeader.Joueurs[i].isAlive then
      begin
        t:=mHeader.Joueurs[i].team;
        for j:= 0 to 6 do
        if TeamArray[t,j]=-1 then
        begin
          TeamArray[t,j]:=i;
          break;
        end;
        TeamArray[t,7]:=TeamArray[t,7]+1;
      end;
    end;
    for t:=0 to mHeader.nteams-1 do
    begin
      AddLabel('Team_' + inttostr(t+1), 50 , 60+ 50*t);
      nTeamMember:=TeamArray[t,7];
      for i:=0 to nTeamMember do
      begin
        AddSPRPanel('ITGFLAGS', 66 + 20*i - 10* nTeamMember , 80+ 50*t);
        TDXWPanel(ObjectList[ObjectList.Count-1]).Tag:=TeamArray[t,i];
      end;
    end;
  end;
   {----------------------------------------------------------------------------}
  procedure AddObject;
  begin
    Dxo_text:=ObjectList.count;
    if Ftext <> '' then
    AddLabel_YellowCenter(FTitle,0,30,WW,10);
    AddMemo(FText,20,FTopText, ww-40, HTXT) ;
    if style = dsInfoScroll then TDXWLabel(ObjectList[DxO_Text+1]).AlignCenter:=false;

    if style = dsTeamInfo then  AddTeamFlag;

    if pic2 <> ''
    then
    begin
      DxO_Pic2:=ObjectList.Count;
      AddSprPanel(pic2, pic2_x, fTopPic,Btn2);
      TDXWPanel(ObjectList[DxO_Pic2]).Tag:=tag2;

      // AddSprPanelSelectedImage(DxO_Pic2,'SEL82x93'); // ? why a selection
      AddLabel(caption2,ww div 2 +50 - DxSurface.Canvas.TextWidth(caption2) div 2  ,fTopCaption,10);
    end;

    if pic1 <> ''
    then
    begin
      DxO_Pic1:=ObjectList.Count;
      AddSprPanel(pic1, pic1_x, fTopPic,Btn1);
      TDXWPanel(ObjectList[DxO_Pic1]).Tag:=tag1;

      //if pic2 <> '' then AddSprPanelSelectedImage(DxO_Pic1,'SEL82x93');

      if pic2 <> '' then
        x:=ww div 2 -50 - DxSurface.Canvas.TextWidth(caption1) div 2
      else
        x:=ww div 2 -  (DxSurface.Canvas.TextWidth(caption1) div 2);
      AddLabel(caption1,x,fTopCaption,10);
    end;

    if not((Style=dsPop) or (Style=dsMonster)) then
    begin
      if (Style= dsYesNo) or (Style=dsArtQ)
      then
      begin
        DxO_OK:=ObjectList.Count;
        AddButton('IOKAY',  (ww div 2) - 82 ,hh - 55 ,BtnValid);
        AddButton('ICANCEL',(ww div 2) + 30 ,hh - 55 ,BtnCancel);
      end
      else
      begin
        DxO_OK:=ObjectList.Count;
        AddButton('IOKAY',  (ww div 2) - 32, hh - 55 ,BtnOK);
      end;
      // cancel or ok by default
      AddSprPanelSelectedImage(ObjectList.Count-1,'BOX64X30');
      TDXWPanel(ObjectList[ObjectList.Count-1]).focused:=true;

      if style=dsMoneyExp then
      begin
        AddSprPanelSelectedImage(DxO_Pic1,'SEL82x93');
        AddSprPanelSelectedImage(DxO_Pic2,'SEL82x93');
        TDXWButton(ObjectList[DxO_OK]).focused:=false;
        TDXWButton(ObjectList[DxO_OK]).Enabled:=false;
      end;
    end;
  end;

begin
  if mPLayers[mPL].isCPU then
  begin
    mDialog.res:=1; // TODO AuToAnswer By CPU to Dialog quest  is YES
    exit;
  end;
  inherited Create('SnDialog');
  FStyle:=Style;
  Answer:=1;
  LoadSprite(ImageList,'Dialgbox');
  LoadBmp(ImageList,'Diboxbck');
  DefineText;
  DefinePicture;
  DefinePosition;
  AddObject;
  if DxScene.name = 'SnSelect'
  then UpdateColor(1,1)
  else UpdateColor(mPL,1);
  OnDraw:=SnDraw;
  OnKeyDown:=KeyDown;
  if (Style = dsPop) or (Style = dsMonster)
  then addPopScene
  else addScene;

  LogP.Insert(format('[%d,%d], lTxt=%d, hTxt=%d, Top [Text=%d,Pic=%d,Caption=%d]',
  [ww,hh,FlengthText,htxt,FTopText,FTopPic,FTopCaption ]));
  Fwidth:=ww;
  Fheight:=hh;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.SnDraw(Sender:Tobject);
begin
  DxMouse.id:=0;
  DrawBackGround(WW,HH,Left,Top);
  DrawBorder;
  ObjectList.DoDraw;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.DrawBackGround(W,H,L,T: integer);
begin
  ImageList.Items.find('Diboxbck').PatternWidth:=W;
  ImageList.Items.find('Diboxbck').PatternHeight:=H;
  ImageList.Items.find('Diboxbck').Restore;
  ImageList.Items.find('Diboxbck').Draw(DxSurface, L, T, 0);
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.DrawBorder;
var
  i,j : integer;
begin
  for i:=1 to (ww div 64) -1
  do
  begin
    ImageList.Items.Find('DialgBox').Draw(DxSurface,Left+i*64, Top, 6);
    ImageList.Items.Find('DialgBox').Draw(DxSurface,Left+i*64, Top+hh-64,7);
  end;
  for j:=1 to (hh div 64) - 1
  do
  begin
    ImageList.Items.Find('DialgBox').Draw(DxSurface,Left, Top+j*64, 4);
    ImageList.Items.Find('DialgBox').Draw(DxSurface,Left+ww-64, Top+j*64, 5);
  end;

  ImageList.Items.Find('DialgBox').Draw(DxSurface,Left, Top, 0);
  ImageList.Items.Find('DialgBox').Draw(DxSurface,Left+ww-64, Top, 1);
  ImageList.Items.Find('DialgBox').Draw(DxSurface,Left, Top+hh-64, 2);
  ImageList.Items.Find('DialgBox').Draw(DxSurface,Left+ww-64, Top+hh-64, 3);
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.ScrollUp;
var
  i: integer;
  MaxText: TStringlist;
begin
   if style <> dsInfoScroll then exit;

   MaxText:=TStringlist.create;
   MaxText.text:=Fulltext;
   Startline:=max(0,Startline-1);
   for i:=1 to StartLine do
      MaxText.delete(0) ;
   for i:=1 to MaxText.Count-30 do
      MaxText.delete(MaxText.Count-1) ;
   ftext:=MaxText.Text;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.ScrollDown;
var
  i: integer;
  MaxText: TStringlist;
begin
   if style <> dsInfoScroll then exit;

   MaxText:=TStringlist.create;
   MaxText.text:=Fulltext;
   Startline:=min(max(0,MaxText.Count-30),Startline+1);
   for i:=1 to StartLine do
      MaxText.delete(0) ;
   for i:=1 to MaxText.Count-30 do
      MaxText.delete(MaxText.Count-1) ;
   ftext:=MaxText.Text;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.SnMouseDown(Sender: TObject;Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft 
      then ScrollUp
      else ScrollDown;;
  TDXWLabel(ObjectList[DxO_Text+1]).caption:=FText;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.KeyDown(Sender:TObject;var Key: Word; Shift: TShiftState);
begin
  CloseDialog;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.BtnOK(Sender:Tobject);
begin
  CloseDialog;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.BtnCancel(Sender:Tobject);
begin
  Answer:=0;
  CloseDialog;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.BtnValid(Sender:Tobject);
begin
  Answer:=1;
  CloseDialog;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.Btn1(Sender:Tobject);
begin
  Answer:=1;
  TDxWPanel(sender).Focused:=true;
  TDXWButton(ObjectList[DxO_OK]).Enabled:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.Btn2(Sender:Tobject);
begin
  Answer:=2;
  TDxWPanel(sender).Focused:=true;
  TDXWButton(ObjectList[DxO_OK]).Enabled:=true;
end;
{----------------------------------------------------------------------------}
procedure TSnDialog.CloseDialog;
begin
  mDialog.res:=Answer;
  CloseScene;
end;
{----------------------------------------------------------------------------}
end.

