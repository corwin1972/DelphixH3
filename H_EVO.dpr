program H_EVO;

{$APPTYPE CONSOLE}
// SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_RED OR BACKGROUND_BLUE);

{%ToDo 'H_EVO.todo'}

uses
  UFile in 'SRC\Tools\UFile.pas',
  Forms,
  UMain in 'UMain.pas' {DXMain},
  UText in 'SRC\Tools\UText.pas' {TextFrm},
  DXWGameSprite in 'SRC\Dx\DXWGameSprite.pas',
  DXWListBox in 'SRC\Dx\DXWListBox.pas',
  DXWLoad in 'SRC\Dx\DXWLoad.pas',
  DXWNavigator in 'SRC\Dx\DXWNavigator.pas',
  DXWScene in 'SRC\Dx\DXWScene.pas',
  DXWScroll in 'SRC\Dx\DXWScroll.pas',
  DXWControls in 'SRC\Dx\DXWControls.pas',
  UType in 'SRC\Hero\UType.pas',
  UPathHexa in 'SRC\Hero\UPathHexa.pas',
  UPathRect in 'SRC\Hero\UPathRect.pas',
  USnBattleField in 'SRC\Scene\USnBattleField.pas',
  USnBook in 'SRC\Scene\USnBook.pas',
  USnBuyArtf in 'SRC\Scene\USnBuyArtf.pas',
  USnBuyBuild in 'SRC\Scene\USnBuyBuild.pas',
  USnBuyCrea in 'SRC\Scene\USnBuyCrea.pas',
  USnBuyForge in 'SRC\Scene\USnBuyForge.pas',
  USnBuyHero in 'SRC\Scene\USnBuyHero.pas',
  USnBuyRes in 'SRC\Scene\USnBuyRes.pas',
  USnBuyShip in 'SRC\Scene\USnBuyShip.pas',
  USnCstl in 'SRC\Scene\USnCstl.pas',
  USnDialog in 'SRC\Scene\USnDialog.pas',
  USnGarnison in 'SRC\Scene\USnGarnison.pas',
  USnHall in 'SRC\Scene\USnHall.pas',
  USnHero in 'SRC\Scene\USnHero.pas',
  USnHillFort in 'SRC\Scene\USnHillFort.pas',
  USnInfoBHero in 'SRC\Scene\USnInfoBHero.pas',
  USnInfoCrea in 'SRC\Scene\USnInfoCrea.pas',
  USnInfoDay in 'SRC\Scene\USnInfoDay.pas',
  USnInfoFlag in 'SRC\Scene\USnInfoFlag.pas',
  USnInfoGar in 'SRC\Scene\USnInfoGar.pas',
  USnInfoHero in 'SRC\Scene\USnInfoHero.pas',
  USnInfoPlayer in 'SRC\Scene\USnInfoPlayer.pas',
  USnInfoRes in 'SRC\Scene\USnInfoRes.pas',
  USnInfoTown in 'SRC\Scene\USnInfoTown.pas',
  USnInfoUnit in 'SRC\Scene\USnInfoUnit.pas',
  USnLevelUp in 'SRC\Scene\USnLevelUp.pas',
  USnMage in 'SRC\Scene\USnMage.pas',
  USnGame in 'SRC\Scene\USnGame.pas',
  USnMenu in 'SRC\Scene\USnMenu.pas',
  USnMeet in 'SRC\Scene\USnMeet.pas',
  USnOption in 'SRC\Scene\USnOption.pas',
  USnOverView in 'SRC\Scene\USnOverView.pas',
  USnPlayers in 'SRC\Scene\USnPlayers.pas',
  USnPuzzle in 'SRC\Scene\USnPuzzle.pas',
  USnBattleResult in 'SRC\Scene\USnBattleResult.pas',
  USnScenario in 'SRC\Scene\USnScenario.pas',
  USnSelect in 'SRC\Scene\USnSelect.pas',
  USnSepCrea in 'SRC\Scene\USnSepCrea.pas',
  USnLoadingMap in 'SRC\Scene\USnLoadingMap.pas',
  USnTown in 'SRC\Scene\USnTown.pas',
  UHeader in 'SRC\Hero\UHeader.pas',
  UMap in 'SRC\Hero\UMap.pas',
  UParse in 'SRC\Hero\UParse.pas',
  UPL in 'SRC\Hero\UPL.pas',
  UAI in 'SRC\Hero\UAI.pas',
  UBattle in 'SRC\Hero\UBattle.pas',
  UConst in 'SRC\Tools\UConst.pas',
  UCSV in 'SRC\Tools\UCSV.pas',
  UCT in 'SRC\Hero\UCT.pas',
  UDef in 'SRC\Hero\UDef.pas',
  UOB in 'SRC\Hero\UOB.pas',
  UEnter in 'SRC\Hero\UEnter.pas',
  UHero in 'SRC\Hero\UHero.pas',
  UHE in 'SRC\Hero\UHE.pas',
  ULoad in 'SRC\Hero\ULoad.pas',
  USnBattleOption in 'SRC\Scene\USnBattleOption.pas',
  Windows,
  UArmy in 'SRC\Hero\UArmy.pas',
  USnBuyAmmo in 'SRC\Scene\USnBuyAmmo.pas',
  UMessage in 'SRC\Hero\UMessage.pas',
  USnTownBuild in 'SRC\Scene\USnTownBuild.pas',
  USnInfoMsg in 'SRC\Scene\USnInfoMsg.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDXMain, DXMain);
  Application.CreateForm(TTextFrm, TextFrm);
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),FOREGROUND_GREEN);
  writeln('Hello, World!');

  Application.Run;
end.
