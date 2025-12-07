unit UDef;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Utype;

  function iDefFind(s:string):integer;   overload;
  function iDefFind(t,u:integer):integer;overload;

implementation


uses UCSV, UConst, UFile;
{----------------------------------------------------------------------------}
function iDefFind(s:string):integer;
var
  i: integer;
begin
  result:=-1;
  for i:=0 to MAX_DEF do
  begin
    if iDef[i].Name=s then
    begin
      result:=i;
      break;
    end;
  end;
end;
{----------------------------------------------------------------------------}
function iDefFind(t,u:integer):integer;
var
  i: integer;
begin
  for i:=0 to MAX_DEF do
  begin
    if ((iDef[i].t=t) and (iDef[i].u=u)) then break;
  end;
  result:=i;
end;
{----------------------------------------------------------------------------}
procedure iDefInit;
var
  CSV: TCSVfile;
  i,k: integer;
begin
  TxtObject:=LoadTxt('ObjNames');
  TxtXtraInfo:=LoadTxt('XtraInfo');

  CSV:=TCSVFile.Create;
  CSV.Separator:=spSpace;
  CSV.Open(folder.Data+'Objects.txt');
  CSV.ReadLine;
  for i:=0 to MAX_DEF do
  begin
    CSV.ReadLine;
    with iDef[i] do
    begin
      id:=i;
      Name:=CSV.readstr(0);
      k:=ANSIPOS('.',Name);
      Name:=copy(Name,0,k-1);
      t:=CSV.readint(5);
      u:=CSV.readint(6);
      p:=CSV.readstr(1);
      e:=CSV.readstr(2);
      //LandPlace:=CSV.Readstr(3);
      //LandMenu:=CSV.Readstr(4);
      //EditorMenu:=CSV.Readint(7);
    end;
  end;
  CSV.Close;
end;
{----------------------------------------------------------------------------}
initialization
begin
  iDefInit;
end;


end.
