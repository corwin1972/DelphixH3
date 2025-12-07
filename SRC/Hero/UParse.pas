unit UParse;

interface
{ parse of string command }
uses  SysUtils, UType, Forms, Math, UHE;

type

RCV = (
  cAR,cBA,cBG,cBH,cBU,cCA,cCD,cCE,cCM,cDO,
  cFU,cGE,cHE,cHL,cHO,cHT,cIF,cLE,cMA,cMC,
  cMO,cOB,cOW,cPO,cQW,cTM,cTR,cUN);


  TRC = record
    rAB,
    rID,
    rX,
    rY,
    rl: integer;
    rBody: string
   end;

   procedure Cmd_Parse(cmd: string);
   procedure Cmd_HE(body: string);
   procedure Cmd_CMD(body: string);
   //procedure Cmd_Parse(cmd: string);
   //procedure Cmd_HE(id: integer;op:string);


const
  RCV_MAX=27;
  RCVstr : array [0..RCV_MAX] of string =(
  'AR','BA','BG','BH','BU','CA','CD','CE','CM','DO',
  'FU','GE','HE','HL','HO','HT','IF','LE','MA','MC',
  'MO','OB','OW','PO','QW','TM','TR','UN');

var
  Msg: string;
  RC: TRC;

implementation

procedure parseID(ID:string);
var
  p: integer;
  token :string;
begin
  if pos('/',ID)>0
  then
  begin
    token:=ID;
    p:=pos('/',token);
    RC.rx:=strtoint(copy(token,0,p-1));
    token:=copy(token,p+1,length(token)-p) ;
    p:=pos('/',token);
    RC.ry:=strtoint(copy(token,0,p-1));
    token:=copy(token,p+1,length(token)-p) ;
    RC.rl:=strtoint(copy(token,0,p-1));
    msg:= msg
          + chr(10) + format('_ID: x=%d,y=%d,l=%d_',[rc.rx,rc.ry,rc.rl]);
  end
  else
  begin
    RC.rID:=strtoint(ID);
    msg:= msg
          + chr(10) + format('_ID: id=%d_',[rc.rid]) ;
  end;
end;

{----------------------------------------------------------------------------}
procedure ParseHeader(header: string);
// ABidX/idY/idL&COND:...
var
  AB, ID, Condition: string;
  c,q: integer;
begin
  AB:=copy(header,0,2);
  for c:=0 to RCV_MAX do
    if AB=RCVstr[c] then break;

  RC.rAB:=c;

  q:=pos('&',header);
  if q>0
    then Condition:=copy(header,q+1,length(header)-q)
    else q:=2;

  ID:=copy(header,3,length(header)-q);

  msg:= format('_Header: AB=%s ID=%s ?=%s_', [AB,ID,condition]);

  parseId(ID);
end;

procedure parseBody(body: string);
// ABid:RC
begin
  RC.rBody:=body;
  case RC.rAB of
    ord(cAR):  cmd_CMD(Body);
    ord(cBA):  cmd_CMD(Body);
    ord(cBG):  cmd_CMD(Body);
    ord(cBH):  cmd_CMD(Body);
    ord(cBU):  cmd_CMD(Body);
    ord(cCA):  cmd_CMD(Body);
    ord(cCD):  cmd_CMD(Body);
    ord(cCE):  cmd_CMD(Body);
    ord(cCM):  cmd_CMD(Body);
    ord(cDO):  cmd_CMD(Body);
    ord(cFU):  cmd_CMD(Body);
    ord(cGE):  cmd_CMD(Body);
    ord(cHE):  cmd_HE(Body);
    ord(cHL):  cmd_CMD(Body);
    ord(cHO):  cmd_CMD(Body);
    ord(cHT):  cmd_CMD(Body);
    ord(cIF):  cmd_CMD(Body);
    ord(cLE):  cmd_CMD(Body);
    ord(cMA):  cmd_CMD(Body);
    ord(cMC):  cmd_CMD(Body);
    ord(cMO):  cmd_CMD(Body);
    ord(cOB):  cmd_CMD(Body);
    ord(cOW):  cmd_CMD(Body);
    ord(cPO):  cmd_CMD(Body);
    ord(cQW):  cmd_CMD(Body);
    ord(cTM):  cmd_CMD(Body);
    ord(cTR):  cmd_CMD(Body);
    ord(cUN):  cmd_CMD(Body);
    else msg:= msg + chr(10) + '_Unknown Command_';
  end;
end;

{----------------------------------------------------------------------------}
procedure Cmd_Parse(cmd: string);
var
  p: integer;
  Header,Body: string ;
  // HE1/2/3:A123
begin
  msg:='cmd parsing';
  p:=pos(':',cmd);
  Header:=copy(cmd,0,p-1);
  Body  :=copy(cmd,p+1,length(cmd)-p);
  parseHeader(Header);
  parseBody(Body);
  mdialog.mes:=msg;
end;
{----------------------------------------------------------------------------}
procedure cmd_HE(Body: string);
var
  c: char;
  s: string;
begin
  //msg:=msg+ chr(10) + 'cmd_HE ';
  c:=Body[1];
  s:=copy(body,2,length(body)-1);
  msg:=msg
        + chr(10) + format('_Body: OP=%s Val=%s_',[c,s]);
  case c of
  'A' : begin
    msg:=msg + chr(10) + format('_Art: AR=%s_',[iART[strtoint(s)].name]);
    Cmd_He_setART(rc.rID,strtoint(s));
  end;
  'S'  : begin
    msg:=msg + chr(10) + '_All spell added';
    Cmd_He_AddAllSpell(rc.rID);
  end;
  else
    msg:=msg + chr(10) + '_HE' + c + 'not implemented_';
end;
  {msg:=msg+ format('OP=%s Body=%s',[c,Body]);
  msg:=msg
    + chr(10)
    + chr(10)
    + format('Parse AB=%d ID=%d (%d,%d,%d) body=%s',
              [RC.rAB,RC.rID, RC.rx, RC.ry, RC.rl, RC.rBody]);
  //Cmd_He_setART(id,strtoint(s));    }
end;
{----------------------------------------------------------------------------}
procedure cmd_CMD(Body: string);
begin
  msg:=msg
        + chr(10) + '_not implemented_';
end;
{----------------------------------------------------------------------------
procedure Cmd_Parse(cmd: string);
var
  s:  string;
  rv: string;
  id: integer;
  p: integer;
  op: string;
begin
  s :=cmd;
  rv:=copy(s,0,2);
  s :=copy(s,3,length(s)-2);
  p :=ansipos(':',s);
  id:=strtoint(copy(s,0,p-1));
  s :=copy(s,p+1,length(s)-p+1);
  op:=s;
  case rv[1] of
    'H': begin
       case rv[2] of
         'E' : begin mDialog.mes:=(' parsing ok '); Cmd_HE(id,op); end;
       end;
    end;
  end;
end;
{----------------------------------------------------------------------------
procedure Cmd_HE(id: integer; op: string);
var
  s:  string;
begin
  s:=copy(op,2,length(op)-1);
  case op[1] of
    'A' : begin
      Cmd_He_setART(id,strtoint(s));
    end;
  end;
end;   }
end.
