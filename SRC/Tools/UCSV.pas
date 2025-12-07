unit UCSV;
  //rng
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, forms, Dialogs;

type
  TSeparator=(spTab,spPointvirgule,spVirgule,spSpace);

  TCSVFile = class //**(TComponent)
  private
    fTxt: Textfile;
    fNom: String;
    fSeparator: TSeparator;
    fSep: String;
    fPartList: TStringList;
    procedure SetSeparator(aSeparator:TSeparator);
  public
    Constructor Create; //(AOwner:TComponent);override;
    function  Open(NomCSV: String): Integer;
    function  Eof: Boolean;
    function  ReadLine: Integer;
    function  Readstr(Index: integer): string;
    function  ReadInt(Index: integer): integer;
    procedure Close;
    procedure ResetCSV(NomCSV: string);
    procedure SaveString(Chaine: String; NomCSV: String);
  published
    property  Separator: TSeparator read FSeparator write SetSeparator;
  end;
//procedure Register;

implementation

{----------------------------------------------------------------------------}
constructor TCSVFile.Create; //**(AOwner:TComponent);
begin
   inherited Create; //**(Aowner);
   Separator:= spTab;
   fSep:= chr(9);
end;
{----------------------------------------------------------------------------}
procedure TCSVFile.SetSeparator(aSeparator:TSeparator);
begin
  If aSeparator=fSeparator then Exit;
  fSeparator:=aSeparator;
  Case fSeparator of
    spTab:           fSep:= Chr(9);
    spPointvirgule:  fSep:= ';';
    spVirgule:       fSep:= ',';
    spSpace :        fSep:= ' ';
  end;
end;
{----------------------------------------------------------------------------}
// Ouvre un fichier CSV en lecture
function TCSVFile.Open(NomCSV: String): Integer;
begin
  // Teste si le fichier existe
  if FileExists(NomCSV) then
  begin
    Fnom:=NomCSV;
    AssignFile(fTxt, NomCSV);
    Reset(fTxt);
    // Init de la Liste de paramètres
    fPartList:=TStringList.Create;
    Result:=0;
  end
  else Result:=1;
end;
{----------------------------------------------------------------------------}
// Ferme un fichier CSV
procedure TCSVFile.Close;
begin
  // Ferme le fichier
  System.CloseFile(fTxt);
  // Détruit la liste associée.
  fPartlist.Free;
end;
{----------------------------------------------------------------------------}
// crée le fichier nomcsv
procedure TCSVFile.ResetCSV(NomCSV: String);
var
  FCSV: textfile;
begin
  Assignfile(FCSV,NomCSV);
  rewrite(FCSV);
  closefile(FCSV);
end;
{----------------------------------------------------------------------------}
// crée le fichier noncsv s'il n'exite pas
// sinon rajoute la chaine en parametre
procedure TCSVFile.Savestring(chaine: string; NomCSV: String);
var
  FCSV: textfile;
begin
  Assignfile(FCSV,NomCSV);
  {$I-}
     append(FCSV);
     if ioresult <> 0 then rewrite(FCSV);
  {$I+}
  writeln(FCSV, chaine);
  closefile(FCSV);
end;
{----------------------------------------------------------------------------}
// test si fin du fichier
function TCSVFile.Eof: Boolean;
begin
  Result:=System.Eof(fTxt);
end;
{----------------------------------------------------------------------------}
function TCSVFile.ReadLine: Integer;
var
  Part,Ligne: String;
  Pos_Sep: Integer;
begin
  fPartList.Clear;
  Result:=0;
  // lit une ligne de paramètres
  ReadLn(fTxt,Ligne);
  // décompose la ligne
  while Ligne<>'' do
  begin
    Pos_Sep:=Pos(FSep,Ligne);
    if Pos_Sep=1 then
      // vire le séparateur
      Delete(Ligne,Pos_Sep,1)
    else
    begin
      // si on trouve un séparateur alors
      if Pos_Sep<>0 then
      begin
        // isoler le paramètre
        Part:=Copy(Ligne,1,Pos_Sep-1);
        // virer tout ça de la ligne!
        Delete(Ligne,1,Pos_Sep);
      end
      else
        // si plus de séparateur
      begin
        // c'est tout le reste, fin!
        Part:=Ligne;
        Ligne:='';
      end;
      fPartList.Add(Part);
      Inc(Result);
    end;
  end;
end;
{----------------------------------------------------------------------------}
function TCSVFile.ReadStr(Index: integer): string;
begin
  if index < fPartList.count
    then Result:=fPartList.Strings[Index]
    else Result:='';
end;
{----------------------------------------------------------------------------}
function TCSVFile.ReadInt(Index: integer): integer;
begin
  if index < fPartList.count
    then Result:=strtoint(fPartList.Strings[Index])
    else Result:=0;
end;
{----------------------------------------------------------------------------}



end.
