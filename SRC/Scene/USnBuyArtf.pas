unit USnBuyArtf;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DXClass, DXSprite, DXInput, DXDraws,
  DXSounds, DIB , DxWLoad , DXWControls, DXWScene;

type
  TSnBuyArtf= class (TDxScene)
  private
  public
    constructor Create;
  end;

var
  SnBuyArtf:TSnBuyArtf;

implementation

uses UMain, USnHero, USnSelect, UType;

Constructor TSnBuyArtf.create;
begin
  inherited Create('SnBuyForge');
  Left:=104;
  Top:=30;
  HintY:=Top+485;
  HintX:=Left+85;
  AddBackground('TPMRKABS');;
  AddTitleScene('ARTIFACT MERCHANT' ,16);
  AddLabel('SelBlavl',35,375);
  AddButton('IOK6432',500,491,BtnOK);
  AddButton('ICANCEL',33,491,BtnOK);
  UpdateColor(mPL,1);
  AddScene;
end;

end.
