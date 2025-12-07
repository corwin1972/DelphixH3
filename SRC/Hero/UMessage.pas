unit UMessage;

interface

uses
  Windows, Messages, SysUtils, Classes, DxPlay, UType;

const
  DXCHAT_MESSAGE = 0;
  DXSTART_MESSAGE = 1;
  DXWHOLE_MAP_MESSAGE =2;
  DXTILE_MAP_MESSAGE =3;
  DXMOVE_MESSAGE =4;

type
  TDXChatMessage = record
    dwType: DWORD;  {  dwType is absolutely necessary.  }
    Len: Integer;
    C: array[0..0] of Char;
  end;


  TDXStartMessage = record
    dwType: DWORD;  {  dwType is absolutely necessary.  }
    Len: Integer;
    status: byte;
  end;

  TDXTileMapMessage = record
    dwType: DWORD;  {  dwType is absolutely necessary.  }
    x: integer;
    y: integer;
    v: byte;
  end;

  TDXWholeMapMessage = record
    dwType: DWORD;  {  dwType is absolutely necessary.  }
    mdata: array [0..20, 0..10] of byte;
  end;

  TDXMoveMessage = record
    dwType: DWORD;  {  dwType is absolutely necessary.  }
    Keydirection:byte;
  end;

  TMessageHelper = class
  private
    FDxPlay: TDxPlay;
  public
    Constructor Create;
    procedure  IpConnect;
    procedure PlayMessage(Sender: TObject; From: TDXPlayPlayer;Data: Pointer; DataSize: Integer);
    procedure SendMsg(S:string);
    procedure SendMove(key:DWORD);
  end;

implementation

uses UFile, UMap, UMain, UPathRect, USnGame;
{----------------------------------------------------------------------------}
Constructor TMessageHelper.Create;
begin
  FDxPlay:=DXMain.DxPlay;
  FDxPlay.OnMessage:=PlayMessage;
end;
{----------------------------------------------------------------------------}
procedure TMessageHelper.IpConnect;
var
  n:integer;
begin
  LogP.EnterProc('Begin_IPconnect');
  DxMouse.Id:=CrWaits;
  FDXPlay.ProviderName:=FDXPlay.Providers[2];
  //FDxPlay.TCPIPSetting.HostName:='192.168.1.19';  no hostname lets discover or prompt and put nothing
  //FDxPlay.TCPIPSetting.Port:=1000;                default listening port
  FDxPlay.TCPIPSetting.Enabled:=True;
  try
    LogP.Insert('1st try Port 1000 ' +FDxPlay.ProviderName);
    FDxPlay.GetSessions;
    LogP.Insert('apres get session,');
    n:=FDxPlay.Sessions.Count-1;
  except
    LogP.Insert('2nd try Port 2000 ' +FDxPlay.ProviderName);
    FDxPlay.TCPIPSetting.Port:=2000;  //to connecton the default listening port
    FDxPlay.GetSessions;
    n:=FDxPlay.Sessions.Count-1;
  end;
  if n<0 then begin
    LogP.Insert('No existing session, initiate H3GAME as Player1');
    FDxPlay.Open2(True, 'H3GAME', 'Player1');
    //DXMain.Caption := Format('%s : %s : %s', [FDxPlay.ProviderName, FDxPlay.SessionName,FDxPlay.localPlayer.name]);
  end
  else
  begin
    LogP.Insert('Found existing session, connect to H3GAME as Player2');
    FDXPlay.Open2(False, 'H3GAME', 'Player2');
    //DXMain.Caption := Format('%s : %s : %s', [FDXPlay.ProviderName, FDXPlay.SessionName,FDXPlay.localPlayer.name]);
  end;
  LogP.quitProc('End_IPconnect');
end;

{----------------------------------------------------------------------------}
procedure TMessageHelper.SendMove(key:DWORD);
var
  Msg: ^TDXMoveMessage;
  MsgSize: Integer;
begin

  MsgSize := SizeOf(TDXMoveMessage);
  GetMem(Msg, MsgSize);
  try
    Msg.dwType := DXMOVE_MESSAGE;
    Msg.keydirection:=key;

    {  The message is sent all.  }
    FDXPlay.SendMessage(0, Msg, MsgSize);     //DPID_ALLPLAYERS=0

    {  The message is sent also to me.  }
    FDXPlay.SendMessage(FDXPlay.LocalPlayer.ID, Msg, MsgSize);
  finally
    FreeMem(Msg);
  end;

end;
{----------------------------------------------------------------------------}
procedure TMessageHelper.SendMsg(S:string);
var
  Msg: ^TDXChatMessage;
  MsgSize: Integer;
begin
  MsgSize := SizeOf(TDXChatMessage)+Length(s);
  GetMem(Msg, MsgSize);
  try
    Msg.dwType := DXCHAT_MESSAGE;
    Msg.Len := Length(s);
    StrLCopy(Msg^.c, PChar(s), Length(s));

    //  The message is sent all.
    FDXPlay.SendMessage(0, Msg, MsgSize);

    // The message is sent also to me.
    FDXPlay.SendMessage(FDXPlay.LocalPlayer.ID, Msg, MsgSize);
  finally
    FreeMem(Msg);
  end;
end;
{----------------------------------------------------------------------------}
procedure TMessageHelper.PlayMessage(Sender: TObject; From: TDXPlayPlayer;
  Data: Pointer; DataSize: Integer);
var
  s: string;
  HE:integer;
begin
  mPath.length:=-1;
  case DXPlayMessageType(Data) of
    DXCHAT_MESSAGE:
    begin
      if TDXChatMessage(Data^).Len<=0 then
        s := ''
      else begin
        SetLength(s, TDXChatMessage(Data^).Len);
        StrLCopy(PChar(s), PChar(@TDXChatMessage(Data^).c), Length(s));
      end;
      if s= '' then exit;
      //TODO get the string as result ...TDXWEdit(Objectlist[DxO_Level+12]).Text:=s;
    end;

    DXMove_MESSAGE:  begin
      HE:=mPlayers[mPL].ActiveHero;
      if HE=-1 then HE:=mPlayers[mPL].LstHero[0];
      case TDXMoveMessage(Data^).keydirection of
        VK_PRIOR:  SnGame.MoveHeroBy(HE,1,-1);
        VK_NEXT:   SnGame.MoveHeroBy(HE,1,1);
        VK_END:    SnGame.MoveHeroBy(HE,-1,1);
        VK_HOME:   SnGame.MoveHeroBy(HE,-1,-1);
        VK_LEFT:   SnGame.MoveHeroBy(HE,-1,0);
        VK_RIGHT:  SnGame.MoveHeroBy(HE,1,0);
        VK_UP:     SnGame.MoveHeroBy(HE,0,-1);
        VK_DOWN:   SnGame.MoveHeroBy(HE,0,1);
      end;
    end;
  end;
end;


end.
