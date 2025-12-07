unit UFile;

interface

uses Windows, Messages, Forms, 
     SysUtils, Classes, StdCtrls, ExtCtrls, inifiles, UCSV,DateUtils;

type
  TFolder = record
    Src,
    Log,
    Save,
    Map,
    Data,
    Img,
    Bmp,
    Fnt,
    Sprite,
    PView,
    Sound,
    Dxg: string;
  end;

  TLog = class
  private
    //FileName: string;
    indent: integer;
    //f: TextFile;
  public
    TimeShow: boolean;
    Nolog : boolean;
    constructor Create(aFileName: string);
    procedure Insert(s: string);
    procedure InsertBlueStr(s1, s2: string);
    procedure InsertRedStr(s1,s2:string);
    procedure InsertStr(s1,s2: string);
    procedure InsertInt(s: string; v: integer);
    procedure InsertBool(s: string; v: bool);
    procedure EnterProc(s: string);
    procedure QuitProc(s: string);
  end;

  TMem = class
  private
    RAM:string;
    Swap:string;
    function  FmtMem(N: Integer): string;
    procedure Update;
  public
    constructor Create;
    function ShowRAM:string;
    function ShowSwap:string;
  end;

  function LoadTxt(filename:string):TStringList;
  function LoadTxt2(filename:string):TStringList;
  function LoadCSV(filename:string):TCSVfile;
  
const
  IniFile='H_EVO.ini';
  ProgFile ='Main.log';
  LoadFile ='Load.log';
  FightFile='Fight.log';
  NS='  ';
  NL=chr(13);
  NT=chr(9);

var
  Folder: TFolder;
  LogP, LogL, LogF: Tlog;
  Mem: TMem;
  LastLog: string;

implementation


{----------------------------------------------------------------------------}
function LoadTxt(filename:string):TStringList;
begin
  LogL.InsertStr('OpenTxt', filename);
  result:=TStringList.Create;
  result.LoadFromFile(folder.data+filename+'.txt');
end;

{----------------------------------------------------------------------------}
function LoadTxt2(filename:string):TStringList;
var
  F1: TextFile;
  Ch: Char;
  s:string;
begin
  result:=TStringList.Create;
  AssignFile(F1,folder.data+filename+'.txt');
  Reset(F1);
  while not Eof(F1) do
  begin
    s:='';
    repeat
      Read(F1, Ch);
      if (ch<>char(13))  and (ch<>char(9)) then s:=s+ch;         //and (ch<>char(10))
    until ((ch=char(13)) or (Eof(F1)));
    if (ch=char(13)) then Read(F1, Ch);

    if pchar(s)[0]='"' then
    s:=copy(s,2, length(s)-2);
    result.add(s);
  end;
end;


{----------------------------------------------------------------------------}
function LoadCSV(filename:string):TCSVfile;
begin
  LogL.InsertStr('OpenCSV', filename);
  result:=TCSVFile.create;
  result.Open(folder.data+filename+'.txt');
end;
{----------------------------------------------------------------------------}
procedure FolderInitialize;
var
  FIni: TiniFile;
begin
  Folder.Src:=ExtractFilePath(Application.ExeName);
  with Folder do
  begin
    FIni:=TiniFile.Create(src+Inifile);
    //Log   :=src+fIni.ReadString('Dir','log','\log\');
    LogP.Insert('Log  '+Log);
    Save:=FIni.ReadString('Dir','save',Src+'save\');
    LogP.Insert('Save '+Save);
    Map:=FIni.ReadString('Dir','map',Src+'map\');
    LogP.Insert('Map '+Map);
    Data:=FIni.ReadString('Dir','data',Src+'file\');
    LogP.Insert('Data '+Data);
    Img:=FIni.ReadString('Dir','img' ,Src+'image\');
    LogP.Insert('Img '+ Img);
    Bmp:=FIni.ReadString('Dir','bmp',Src+'image\');
    LogP.Insert('Bmp '+Bmp);
    Sprite:=FIni.ReadString('Dir','sprite',Src+'image\');
    LogP.Insert('Sprite '+Sprite);
    PView:=FIni.ReadString('Dir','pview',Src+'image\');
    LogP.Insert('PView '+PView);
    Sound:=FIni.ReadString('Dir','sound',Src+'sound\');
    LogP.Insert('Sound '+Sound);
    Dxg:=FIni.ReadString('Dir','dxg',Src+'dxg\');
    LogP.Insert('Dxg '+dxg);
    Fnt:=FIni.ReadString('Dir','font',Src+'fnt\');
  end;
  FIni.free;
end;
{-----------------------------------------------------------------------------
  Procedure: Mem
  Date:      23-févr.-2002
*-----------------------------------------------------------------------------}
function TMem.FmtMem(N: Integer): string;
begin
  if N > 1024*1024 then
    FmtMem:=format('%.1f Mo', [n / (1024*1024)])
  else
    FmtMem:=format('%.1f Ko', [n / 1024])
end;
{----------------------------------------------------------------------------}
procedure TMem.Update;
var
  MemInfo : TMemoryStatus;
begin
  MemInfo.dwLength:=Sizeof(MemInfo);
  GlobalMemoryStatus(MemInfo);
  RAM:=format ('RAM: %s/%s',
    [FmtMem(MemInfo.dwAvailPhys), FmtMem(MemInfo.dwTotalPhys)]);
  Swap:=format ('Swap: %s/%s',
    [FmtMem(MemInfo.dwAvailPageFile), FmtMem(MemInfo.dwTotalPageFile)]);
end;
{----------------------------------------------------------------------------}
function TMem.ShowRAM:string;
begin
  Update;
  result:=RAM;
end;
{----------------------------------------------------------------------------}
function TMem.ShowSwap:string;
begin
  Update;
  result:=Swap;
end;
{----------------------------------------------------------------------------}
constructor TMem.Create;
begin
  LogP.insert('TMem.Create;');
  Update;
end;
{-----------------------------------------------------------------------------
  Procedure: Log
  Date:      23-févr.-2002
-----------------------------------------------------------------------------}
constructor TLog.Create(aFileName: string);
//var f: TextFile;
begin
  TimeShow := true;
  NoLog := false;
  indent := -1;
  {if SetCurrentDir(Folder.Log) then
  begin
    FileName := aFileName;
    AssignFile(F, FileName);
    Rewrite(F);
    Append(f);
    Writeln(F, '[' + TimeToStr(Time)+ ']' +' Logging into '+ FileName);
    //CloseFile(F);
  end;}
end;
{----------------------------------------------------------------------------}
procedure TLog.EnterProc(s: string);
begin
  insert('>> ' + s);
  inc(indent);
  lastlog:=s;
end;
{----------------------------------------------------------------------------}
procedure TLog.QuitProc(s: string);
begin
  dec(indent);
  insert('<< ' + s);
end;
{----------------------------------------------------------------------------}
procedure TLog.InsertStr(s1, s2: string);
begin
  Insert(s1 + NT + s2) ;
end;
{----------------------------------------------------------------------------}
procedure TLog.InsertRedStr(s1, s2: string);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED);
  Insert(s1 + NT + s2) ;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN);
end;
{----------------------------------------------------------------------------}
procedure TLog.InsertBlueStr(s1, s2: string);
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_BLUE);
  Insert(s1 + NT + s2) ;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN);
end;
{----------------------------------------------------------------------------}
procedure TLog.InsertInt(s: string; v: integer);
begin
  Insert(s + NT + inttostr(v));
end;
{----------------------------------------------------------------------------}
procedure TLog.InsertBool(s: string; v: bool);
begin
  Insert(s + NT + inttostr(-ord(v)));
end;
{----------------------------------------------------------------------------}
procedure TLog.Insert(s: string);
var
  i: integer;
  t: string;
  //f: TextFile;
  SystemTime: TSystemTime;
begin
  if Nolog then exit;
  if SetCurrentDir(Folder.Log) then
  begin
    //AssignFile(f, FileName);
    //Append(f);
    t := '';
    for i := 0 to indent do t:=t+NT;
    if TimeShow
    then begin
      GetLocalTime(SystemTime);
      s := '['+ TimeToStr(Time)+'-'+ format('%.3d',[SystemTime.wMilliseconds])+ '] '+ t + s
    end
    else s := t + s;
    //Writeln(f, s);  //Uncomment for real write
    //Flush(f);
    //CloseFile(f);
  end;
  writeln(s);         //write on console only
end;

{-----------------------------------------------------------------------------
  Procedure: Dir
  Date:      23-févr.-2002
-----------------------------------------------------------------------------}
initialization
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN);
  writeln('HEROES Console : Creating');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED or FOREGROUND_BLUE or FOREGROUND_GREEN);
  Folder.Log:=ExtractFilePath(Application.ExeName)+'\Log\';
  LogP:=TLog.Create(ProgFile);
  LogL:=TLog.Create(LoadFile);
  LogF:=TLog.Create(FightFile);
  FolderInitialize;
  //Mem:=TMem.Create;
end;
{----------------------------------------------------------------------------}

end.
