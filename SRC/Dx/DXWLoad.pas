unit DXWLoad;

interface

uses
  Windows, Forms, SysUtils, Classes, Graphics, Controls, DXClass, DXDraws, DIB;

type
  TRGBArray = ARRAY[0..0] OF TRGBTriple;
  pRGBArray = ^TRGBArray;

  function LoadBmp(var DXImageList: TDXImageList; PicName: string): integer;
  function LoadSprite(var DXImageList: TDXImageList; DefName: string): integer;
  function LoadTile(var DXImageList : TDXImageList; DefName: string;h,w:integer):integer;
  function LoadHero(var DXImageList : TDXImageList; DefName: string):integer;
  function LoadBoat(var DXImageList : TDXImageList; Defname: string): integer;
  function LoadUnit(var uid,t: integer; DXImageList: TDXImageList):integer;
  function LoadFog(var DXImageList : TDXImageList; Defname: string;h,w:integer):integer;
  function LoadPath(var DXImageList: TDXImageList; Defname: string;h,w:integer):integer;

implementation

uses UFile, UType;

{----------------------------------------------------------------------------}
function LoadBmp( var DXImageList: TDXImageList; PicName: string): integer;
begin
  // check BMP presence in DXimageList to avoid multiple load
  // if found, send image ID
  result:=DxImageList.Items.IndexOf(PicName);
  if result=-1 then
  begin
    // since not found, fetch BMP file
    if FileExists(Folder.bmp+PicName+'.bmp')
    then
    begin
      // loading file and send image ID
      with TPictureCollectionItem.Create(DXImageList.Items) do
      begin
        Picture.LoadFromFile(Folder.bmp+PicName+'.bmp');
        Name:=PicName;
        TransparentColor:=clAqua;
        SystemMemory:=true; //opMemory
        Restore;
      end;
      result:=DXImageList.Items.Count-1;
    end;
  end;
end;
{----------------------------------------------------------------------------}
function LoadSprite(var DXImageList: TDXImageList; DefName: string): integer;
var
  PicPath: string;
  PicList: TStringList;
  h,w: integer;

procedure LoadSpriteToCache;
var
  PicFile : string;
  NewGraphic  : TBitmap;
  TmpGraphic  : TBitmap;
  nPic: integer;
  i: integer;
begin
  nPic:=strtoint(Trim(PicList[11]));

  PicFile:=PicPath+Piclist[12];
  NewGraphic:= TBitmap.Create;
  NewGraphic.LoadFromFile(PicFile);
  NewGraphic.Width:=w;
  NewGraphic.Height:=npic*h;
  if ((DefName='HPS') or (DefName='HPL')) then NewGraphic.PixelFormat := pf24Bit;

  TmpGraphic := TBitmap.Create;
  for i:=0 to nPic-1 do
  begin
    PicFile:=PicPath+PicList[12+i];
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw(0,i*h,TmpGraphic);
  end;

  if (DefName='CH05') then
  begin
    NewGraphic.Height:=9*h;
    for i:=1 to 8 do
    begin
      PicFile:=PicPath+PicList[54+i];
      TmpGraphic.LoadFromFile(PicFile);
      NewGraphic.Canvas.Draw(0,i*h,TmpGraphic);
    end;
  end;
  NewGraphic.SaveToFile(Folder.Img+ DefName+ '.bmp');
  NewGraphic.Free;
  TmpGraphic.Free;
end;


begin
  // check DEF presence in DXimageList to avoid multiple load
  result:=DxImageList.Items.IndexOf(DefName);
  if result=-1 then
  begin
    // since not found, fetch DEF file
    if NOT(FileExists(Folder.Sprite+DefName+'\'+DefName+'.txt'))
    then
      result:=LoadSprite(DXImageList,'ABF01P')
    else
    begin
      PicPath:=Folder.Sprite+DefName+'\';
      PicList:=TStringList.Create;
      PicList.LoadFromFile(PicPath+DefName+'.txt');
      w:= strtoint(Trim(picList[3]));
      h:=strtoint(Trim(PicList[5]));

      // if not found in Picture cache , load from multiple file
      if Not(FileExists(Folder.Img + DefName+ '.bmp')) then
      LoadSpriteToCache;

      PicList.free;
      with TPictureCollectionItem.Create(DXImageList.Items) do
      begin
        Picture.LoadFromFile(Folder.Img+DefName+'.bmp');
        Name:=DefName;
        PatternHeight:=h;
        PatternWidth:=w;
        TransparentColor:=ClAqua;
        SystemMemory:=true; //opMemory
        Restore;
      end;
      result:=DXImageList.Items.Count-1;
    end;
  end;
end;
{----------------------------------------------------------------------------}
function LoadTile(var DXImageList : TDXImageList; Defname: string;h,w:integer):integer;

procedure LoadTileToCache;
var
  PicPath: string;
  PicList: TStringList;
  PicFile : string;
  s:string ;
  i,j,k, npic: integer;
  NewGraphic  : TBitmap;
  TmpGraphic  : TBitmap;
  OldLine, NewLine: PRGBarray;
begin
  PicPath:= Folder.Sprite+DefName+'\';
  PicList:=TStringList.Create;
  PicList.LoadFromFile(PicPath+DefName+'.txt');
  NewGraphic := TBitmap.Create;
  TmpGraphic := TBitmap.Create;

  PicFile:=PicPath+PicList[12];
  NewGraphic.LoadFromFile(PicFile);
  s:=copy(PicList[11],2,length(PicList[11])-2);
  npic:=strtoint(copy(PicList[11],2,length(PicList[11])-2));
  NewGraphic.Width:=4*w;
  NewGraphic.PixelFormat := pf24Bit;

  NewGraphic.Height:=npic*h;
  for i:=0 to npic-1 do
  begin
    PicFile:=PicPath+PicList[12+i];
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw(0,h*i,TmpGraphic);
  end;
  s:=copy(DefName,5,2);
  with NewGraphic do
  begin
    for I := 0 to Height- 1 do   // Mir V
    begin
      OldLine:=NewGraphic.ScanLine[I];
      NewLine:=NewGraphic.ScanLine[I];
      for J := 0 to (W - 1) do
      begin
        NewLine[J+W]:= OldLine[W-1-J];
      end;
    end;

    for k := 0 to nPic- 1 do    // Mir H , Mir H+V
    for i:=0 to h-1 do
    begin
      OldLine:=NewGraphic.ScanLine[k*h+I];
      NewLine:=NewGraphic.ScanLine[k*h+H-1-I];
      for J := 0 to (2*W - 1) do
        NewLine[J+2*W]:= OldLine[J];
    end;
  end;

  TmpGraphic.Free;
  NewGraphic.SaveToFile(Folder.Img+ DefName+ '.bmp');
  NewGraphic.Free;
  PicList.free;
end;

begin
  result:=DxImageList.Items.IndexOf(DefName);
  if result=-1 then
  begin
    // if not found in Picture cache , load from multiple file
    if Not(FileExists(Folder.Img + DefName+ '.bmp')) then
    LoadTileToCache;

    with TPictureCollectionItem.Create(DXImageList.Items) do
    begin
      Picture.LoadFromFile(Folder.Img+DefName+'.bmp');
      Name:=DefName;
      PatternHeight:=h;
      PatternWidth:=w;
      TransparentColor:=ClAqua;
      SystemMemory:=true; //opMemory
      Restore;
    end;
  end;
end;
{----------------------------------------------------------------------------}
function LoadUnit(var uid,t: integer;DXImageList: TDXImageList):integer;
var
  Anim: integer;
begin
  result:=DxImageList.Items.IndexOf(inttostr(uid));
  if result=-1 then
  begin
    if iCrea[t].AnimList[2].count > 0 then Anim:=2 else Anim:=0;
    if FileExists(iCrea[t].AnimList[Anim].Strings[0]) then
    begin
      with TPictureCollectionItem.Create(DXImageList.Items) do
      begin
        Picture.LoadFromFile(iCrea[t].AnimList[Anim].Strings[0]);
        Name:=inttostr(uid);
        TransparentColor:=clAqua;
        SystemMemory:=true; //opMemory
        Restore;
      end;
      result:=DXImageList.items.count-1;
    end;
  end;
end;
{----------------------------------------------------------------------------}
function LoadHero(var DXImageList : TDXImageList; defname: string): integer;

procedure LoadHeroToCache;
var
  PicPath: string;
  PicList: TStringList;
  PicFile: string;
  i,j,k, h,w: integer;
  NewGraphic  : TBitmap;
  TmpGraphic  : TBitmap;
  OldLine, NewLine: PRGBarray;
begin
  PicPath:= Folder.Sprite+DefName+'\';
  PicList:=TStringList.Create;
  PicList.LoadFromFile(PicPath+DefName+'.txt');
  NewGraphic := TBitmap.Create;
  TmpGraphic := TBitmap.Create;

  PicFile:=PicPath+defname+'01.BMP';
  NewGraphic.LoadFromFile(PicFile);
  w:= strtoint((copy(PicList[3],2,length(PicList[3])-2)))+1;

  NewGraphic.Width:=8*w;
  NewGraphic.PixelFormat := pf24Bit;
  h:=strtoint((copy(PicList[5],2,length(PicList[5])-2)))+1;
  NewGraphic.Height:=8*h;

  for i:=6 to 9 do
  begin
    PicFile:=PicPath+DefName+ format('%2.2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-6)*w,4*h,TmpGraphic);
  end;
  for i:=11 to 14 do
  begin
    PicFile:=PicPath+DefName+ format('%2.2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-7)*w,4*h,TmpGraphic);
  end;

  for i:=16 to 23 do
  begin
    PicFile:=PicPath+DefName+ format('%2.2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-16)*w,3*h,TmpGraphic);
  end;

  for i:=24 to 26 do
  begin
    PicFile:=PicPath+DefName+ format('%2.2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-24)*w,2*h,TmpGraphic);
  end;

  for i:=28 to 32 do
  begin
    PicFile:=PicPath+DefName+ format('%2.2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-25)*w,2*h,TmpGraphic);
  end;
  for i:=33 to 37 do
  begin
    PicFile:=PicPath+defname+ format('%2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-33)*w,h,TmpGraphic);
  end;

  for i:=39 to 41 do
  begin
    PicFile:=PicPath+DefName+ format('%2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-34)*w,h,TmpGraphic);
  end;
  for i:=42 to 48 do
  begin
    PicFile:=PicPath+DefName+ format('%2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-42)*w,0,TmpGraphic);
  end;

  for i:=50 to 50 do
  begin
    PicFile:=PicPath+DefName+ format('%2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-43)*w,0,TmpGraphic);
  end;

  with NewGraphic do
  begin
    for I := 0 to h- 1 do   // Mir V
    begin
      OldLine:=NewGraphic.ScanLine[3*h+I];
      NewLine:=NewGraphic.ScanLine[5*h+I];
      for K:=0 to 7 do
      for J := 0 to (w - 2) do
      begin
        NewLine[k*w+J]:= OldLine[k*w+w-2-J];
      end;

      OldLine:=NewGraphic.ScanLine[2*h+I];
      NewLine:=NewGraphic.ScanLine[6*h+I];
           for K:=0 to 7 do
      for J := 0 to (w - 2) do
      begin
        NewLine[k*w+J]:= OldLine[k*w+w-2-J];
      end;

      OldLine:=NewGraphic.ScanLine[1*h+I];
      NewLine:=NewGraphic.ScanLine[7*h+I];
            for K:=0 to 7 do
      for J := 0 to (w - 2) do
      begin
        NewLine[k*w+J]:= OldLine[k*w+w-2-J];
      end;
    end;
  end;

  TmpGraphic.Free;
  NewGraphic.SaveToFile(Folder.Img+ DefName+ '.bmp');
  NewGraphic.Free;
  PicList.free;
end;

begin
  result:=DxImageList.Items.IndexOf(DefName);
  if result=-1 then
  begin
    if Not(FileExists(Folder.Img+ DefName+ '.bmp')) then
    LoadHeroToCache;

    with TPictureCollectionItem.Create(DxImageList.Items) do
    begin
      Picture.LoadFromFile(Folder.Img+DefName+'.bmp');
      Name:=DefName;
      PatternHeight:=64;
      PatternWidth:=96;
      SkipHeight:=1;
      SkipWidth:=1;
      Transparent:=True;
      TransparentColor:=ClAqua;
      SystemMemory:=true; //opMemory
      Restore;
    end;
  end;
end;
{----------------------------------------------------------------------------}
function LoadBoat(var DXImageList : TDXImageList; Defname: string): integer;
var
  PicPath: string;

procedure LoadBoatToCache;
var
  PicList: TStringList;
  PicFile : string;
  i,j, h,w: integer;
  NewGraphic  : TBitmap;
  TmpGraphic  : TBitmap;
  OldLine, NewLine: PRGBarray;
begin
  PicList:=TStringList.Create;
  PicList.LoadFromFile(PicPath+DefName+'.txt');
  NewGraphic := TBitmap.Create;
  TmpGraphic := TBitmap.Create;

  PicFile:=PicPath+DefName+'01.BMP';
  NewGraphic.LoadFromFile(PicFile);
  w:= strtoint((copy(PicList[3],2,length(PicList[3])-2)))+1;

  NewGraphic.Width:=8*w;
  NewGraphic.PixelFormat := pf24Bit;
  h:=strtoint((copy(PicList[5],2,length(PicList[5])-2)))+1;
  NewGraphic.Height:=8*h;

  for i:=2 to 9 do
  begin
    PicFile:=PicPath+DefName+ format('%2.2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-2)*w,4*h,TmpGraphic);
  end;

  for i:=11 to 18 do
  begin
    PicFile:=PicPath+DefName+ format('%2.2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-11)*w,3*h,TmpGraphic);
  end;

  for i:=20 to 27 do
  begin
    PicFile:=PicPath+DefName+ format('%2.2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-20)*w,2*h,TmpGraphic);
  end;
  for i:=29 to 36 do
  begin
    PicFile:=PicPath+DefName+ format('%2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-29)*w,h,TmpGraphic);
  end;

  for i:=38 to 45 do
  begin
    PicFile:=PicPath+DefName+ format('%2d',[i])+'.BMP';
    TmpGraphic.LoadFromFile(PicFile);
    NewGraphic.Canvas.Draw((i-38)*w,0,TmpGraphic);
  end;

  with NewGraphic do
  begin
    for I := 0 to h- 1 do   // Mir V
    begin
      OldLine:=NewGraphic.ScanLine[3*h+I];
      NewLine:=NewGraphic.ScanLine[5*h+I];
      for J := 0 to (Width - 2) do
      begin
        NewLine[J]:= OldLine[Width-2-J];
      end;

      OldLine:=NewGraphic.ScanLine[2*h+I];
      NewLine:=NewGraphic.ScanLine[6*h+I];
      for J := 0 to (Width - 2) do
      begin
        NewLine[J]:= OldLine[Width-2-J];
      end;

      OldLine:=NewGraphic.ScanLine[1*h+I];
      NewLine:=NewGraphic.ScanLine[7*h+I];
      for J := 0 to (Width - 2) do
      begin
        NewLine[J]:= OldLine[Width-2-J];
      end;
    end;
  end;
  TmpGraphic.Free;
  NewGraphic.SaveToFile(Folder.Img+ DefName+ '_.bmp');
  NewGraphic.Free;
  PicList.free;
end;

begin
  result:=DxImageList.Items.IndexOf('AVXMyboat');
  if result=-1 then
  begin
    PicPath:= Folder.Sprite+DefName+'\';
    if Not(FileExists(Folder.Img+ DefName+ '.bmp'))
    then LoadBoatToCache;

    with TPictureCollectionItem.Create(DxImageList.Items) do
    begin
      Picture.LoadFromFile(Folder.Img+ DefName+ '_.bmp');
      Name:='AVXMyboat';
      PatternHeight:=64;
      PatternWidth:=96;
      SkipHeight:=1;
      SkipWidth:=1;
      Transparent:=True;
      TransparentColor:=ClAqua;
      SystemMemory:=true; //opMemory
      Restore;
    end;
  end;
end;
{----------------------------------------------------------------------------}
function LoadFog(var DXImageList : TDXImageList; Defname: string;h,w:integer):integer;
begin
  result:=LoadBmp(DXImageList,'tshrc');
  with DXImageList.Items[result] do
  begin
    PatternHeight:=h;
    PatternWidth:=w;
    TransparentColor:=clwhite;
    systemMemory:=true; //opMemory
    Restore;
  end;
end;
{----------------------------------------------------------------------------}
function LoadPath(var DXImageList : TDXImageList; Defname: string;h,w:integer):integer;
begin
  result:=LoadBmp(DXImageList,'tshrc');
  with DXImageList.Items[result] do
  begin
    PatternHeight:=h;
    PatternWidth:=w;
    TransparentColor:=clwhite;
    systemMemory:=true; //opMemory
    Restore;
  end;
end;

end.
