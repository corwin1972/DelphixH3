unit UPL;

interface

Uses SysUtils, UType,
     UCT, UHE, UFile, UAI, UOB,Math;

// Player operation
  procedure Cmd_PL_InitPlayer;
  procedure Cmd_PL_InitHero;
  procedure Cmd_PL_AddRes(PL,RES,n: integer);
  procedure Cmd_PL_BuyHero(PL,slot: integer; Pos:TPos);
  procedure Cmd_PL_Income(PL: integer);
  procedure Cmd_PL_EndTurn;
  procedure Cmd_PL_ApplyEvent(PL,EV: integer);
  procedure Cmd_PL_ApplycEvent(PL,EV: integer);
  procedure Cmd_PL_StartTurn(PL: integer);
  procedure Cmd_PL_NewDay(PL:integer);
  function  Cmd_PL_CheckWINLOS(PL: integer): integer;
  function  Cmd_PL_SameTeam(PL1,PL2: integer) : boolean;
// Date operaton
  procedure Cmd_DT_Newday;
  function Cmd_PL_CountCT(PL,level: integer): string;
// Mine Operation
  procedure Cmd_PL_AddMine(PL, MN: integer);
  procedure Cmd_PL_CountMine(PL: integer);
// CT opération
  function Cmd_PL_Market(PL: integer): integer;

implementation

uses USnGame;
{----------------------------------------------------------------------------}
function  Cmd_PL_SameTeam(PL1,PL2: integer) : boolean;
begin
  result:=(mPlayers[PL1].team = mPlayers[PL2].team);
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_InitPlayer;
var
  i,t, PL:integer;
  resbonus: integer;
const
  isday1 : boolean = true;
begin
  for PL:=0 to MAX_PLAYER-1 do
  begin
    with mPlayers[PL] do
    begin
      //active hero
      ActiveHero:=lstHero[0];
      ActiveCity:=-1;
      // compute first ressource available and income
      for i:=0 to MAX_RES-1 do
        Res[i]:=START_RESDIF[mHeader.dfc,i];
      case  mHeader.dfc of
        0: resbonus:=5;
        else  resbonus:=3;
      end;
      //tavern hero, 1 hero from native CT ???
      if nCity > 0
      then t:=(mCitys[mPlayers[PL].LstCity[0]].t )
      else t:=-1;
      TavHero[0]:=Cmd_HE_NewHero(t,isday1);
      TavHero[1]:=Cmd_HE_NewHero(-1,isday1);
      case mHeader.Joueurs[PL].bonus of
        0: begin Res[0]:=Res[0]+resbonus; Res[2]:=Res[2]+resbonus; end;  //bois pierre
        1: begin Res[4]:=Res[4]+resbonus; end;                    //cristal
        2: begin Res[5]:=Res[5]+resbonus; end;                    //gemme
        3: begin Res[1]:=Res[1]+resbonus; end;                    //mercure
        4: begin Res[0]:=Res[0]+resbonus; Res[2]:=Res[2]+resbonus; end;  //bois pierre
        5: begin Res[3]:=Res[3]+resbonus; end;                    //soufre
        6: begin Res[0]:=Res[0]+resbonus; Res[2]:=Res[2]+resbonus; end;  //bois pierre
        7: begin Res[0]:=Res[0]+resbonus; Res[2]:=Res[2]+resbonus; end;  //bois pierreRes[mHeader.Joueurs[i].bonus]:=Res[mHeader.Joueurs[i].bonus]+5;
        8: Res[6]:=Res[6] + 500 + 100* Random(10);
        9: Cmd_He_SetART(ActiveHero,random(100),-1);
       10: Res[6]:=Res[6];// + 1000; //'Random' = OR.. both let say nothing given
     end;
   end;
  end;

  mData.rumor:=random(TxtRandTVRN.Count);
  mPL:=-1;
end;

{----------------------------------------------------------------------------}
procedure Cmd_PL_InitHero;
var
  CT,PL,HE:integer;
const
  isDay1: boolean = true;
begin
  //recruit hero for map with city and random or player selection hero in city
  for PL:=0 to MAX_PLAYER-1 do
  begin
    with mHeader.Joueurs[PL] do begin
      if isAlive then
      if hasMainCT then
      if hasNewHeroCT then
      begin
        CT:=mObjs[mTiles[PosCT.x,PosCT.y,PosCT.l].obX.oid].v;
        HE:=ActiveHero;
        mPL:=PL;
        if HE = -1 then
          HE:=Cmd_HE_NewHero(mCitys[CT].t,isDay1);
        with mHeros[HE] do
        begin
          pos:=mCitys[CT].pos;
          pos.x:=mHeros[HE].pos.x-2;
          pid:=mPL;
          obX:=mTiles[pos.x,pos.y,pos.l].obX;
          mTiles[pos.x,pos.y,pos.l].obX.t:=OB34_Hero;
          mTiles[pos.x,pos.y,pos.l].obX.u:=HE;
          mTiles[pos.x,pos.y,pos.l].obX.oid:=oid;
        end;
        //mPlayers[i].res[6]:=mPlayers[PL].res[6]-2500;
        Cmd_HE_Add(HE);
        Cmd_HE_VisitCity(HE,CT);
        SnGame.AddHero(HE);
      end;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_ApplyEvent(PL,EV: integer);
var
  i : integer;
//TODO: all EV effect: starting with RES effect
begin
  for i:=0 to MAX_RES-1 do
  begin
  //TODO: should check if EV apply to Player
    mPlayers[PL].Res[i]:=mPlayers[PL].Res[i]+mEvents[EV].giveRes[i];
    mPlayers[PL].Res[i]:=mPlayers[PL].Res[i]-mEvents[EV].takeRes[i];
    //remove NEG RES.... result and put 0
    mPlayers[PL].Res[i]:=Max(0,mPlayers[PL].Res[i]);
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_ApplycEvent(PL,EV: integer);
var
  i : integer;
  //TODO: all EV effect: starting with RES effect
begin
  for i:=0 to MAX_RES-1 do
  begin
  //TODO: should check if EV apply to Player
    mPlayers[PL].Res[i]:=mPlayers[PL].Res[i]+mcEvents[EV].giveRes[i];
    mPlayers[PL].Res[i]:=mPlayers[PL].Res[i]-mcEvents[EV].takeRes[i];
    //remove NEG RES.... result and put 0
    mPlayers[PL].Res[i]:=Max(0,mPlayers[PL].Res[i]);
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_AddRes(PL,RES,n: integer);
begin
  mPlayers[PL].Res[RES]:=mPlayers[PL].Res[RES]+n;
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_EndTurn;
begin
  repeat
    mPL:=(mPL+1);
    if mPL=MAX_PLAYER  then cmd_DT_Newday;
  until mPlayers[mPL].isAlive= true;
  Cmd_PL_StartTurn(mPL);
end;
{----------------------------------------------------------------------------}
function Cmd_PL_Market(PL: integer): integer;
var
  i,CT:integer;
begin
  result:=0;
  for i:=0 to mPlayers[PL].nCity-1 do
  begin
    CT:=mPlayers[PL].Lstcity[i];
    if mCitys[CT].cons[Cons8_Market]  then inc(result);
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_Income(PL: integer);
var
  i, CT,HE: integer;
begin
{
cons 0 city      +500
cons 1 town      +1000
cons 2 capital   +2000
cons 9 silo bonus
1 bois et 1 pierre pour le Château - Castle
1 soufre pour le Donjon - Dungeon
1 bois et 1 pierre pour la Forteresse - Fortress
1 mercure pour l'Hades - Inferno
1 bois et 1 pierre pour la Nécropole - Necropolis
1 cristal pour le Rempart -Rampart
1 bois et 1 pierre pour le Bastion - Stronghold
1 gemme pour la Tour - Tower}

  Cmd_PL_CountMine(PL);
  with mPlayers[PL] do
  begin
    // Get income from mine
    Income[0]:=2*Mine[0];
    Income[1]:=Mine[1];
    Income[2]:=2*Mine[2];
    Income[3]:=Mine[3];
    Income[4]:=Mine[4];
    Income[5]:=Mine[5];
    Income[6]:=1000*Mine[6];

    // Get income from city
    for i:=0 to nCity-1 do
    begin
      CT:=mPlayers[PL].Lstcity[i];
      Income[6]:=Income[6]+cmd_CT_income(CT);
      if mcitys[CT].cons[9] then    //consSILO
      case mcitys[CT].t of
        0: begin Income[0]:=Income[0]+1; Income[2]:=Income[2]+1; end;  //bois pierre
        1: begin Income[4]:=Income[4]+1; end;                          //cristal
        2: begin Income[5]:=Income[5]+1; end;                          //gemme
        3: begin Income[1]:=Income[1]+1; end;                          //mercure
        4: begin Income[0]:=Income[0]+1; Income[2]:=Income[2]+1; end;  //bois pierre
        5: begin Income[3]:=Income[3]+1; end;                          //soufre
        6: begin Income[0]:=Income[0]+1; Income[2]:=Income[2]+1; end;  //bois pierre
        7: begin Income[0]:=Income[0]+1; Income[2]:=Income[2]+1; end;  //bois pierre
     end;
    end;

    // Get Income from Hero  spec and art
    for i:=0 to nHero-1 do
    begin
      HE:=mPlayers[PL].LstHero[i];
      //ART
      Income[4]:=Income[4]+Cmd_He_FindARt(HE,AR109_EverflowingCrystalCloak);
      Income[5]:=Income[5]+Cmd_He_FindARt(HE,AR110_RingofInfiniteGems);
      Income[1]:=Income[1]+Cmd_He_FindARt(HE,AR111_EverpouringVialofMercury);
      Income[2]:=Income[2]+Cmd_He_FindARt(HE,AR112_InexhaustibleCartofOre);
      Income[3]:=Income[3]+Cmd_He_FindARt(HE,AR113_EversmokingRingofSulfur);
      Income[0]:=Income[0]+Cmd_He_FindARt(HE,AR114_InexhaustibleCartofLumber);
      Income[6]:=Income[6]+1000*Cmd_He_FindARt(HE,AR115_EndlessSackofGold);
      Income[6]:=Income[6]+ 750*Cmd_He_FindARt(HE,AR116_EndlessBagofGold);
      Income[6]:=Income[6]+ 500*Cmd_He_FindARt(HE,AR117_EndlessPurseofGold);
      //SKILL
      case mHeros[HE].SSK[SK13_Estates] of
        1: Income[6]:=Income[6]+350;
        2: Income[6]:=Income[6]+500;
        3: Income[6]:=Income[6]+1000;
      end;
      //SPECIALITY
      if (mHeros[HE].specSK=SS02_Ressource) then
      case mHeros[HE].specSKP of
        0: Income[0]:=Income[0]+1;
        1: Income[1]:=Income[1]+1;
        2: Income[2]:=Income[2]+1;
        3: Income[3]:=Income[3]+1;
        4: Income[4]:=Income[4]+1;
        5: Income[5]:=Income[5]+1;
        6: Income[6]:=Income[6]+350;
      end;
    end;
  end;
end;
{----------------------------------------------------------------------------}
function Cmd_PL_CountCT(PL,level: integer): string;
var
  i, n, CT: integer;
begin
  n:=0;
  with mPlayers[PL] do
  begin
    for i:=0 to nCity-1 do
    begin
      CT:=mPlayers[PL].LstCity[i];
      if Cmd_CT_CityLevel(CT)=level then inc(n);
    end;
  end;
  if n=0 then result:='' else result:=inttostr(n);
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_BuyHero(PL,slot: integer; Pos:TPos);
var
  HE: integer;
begin
  HE:=mPlayers[PL].TavHero[slot];
  mHeros[HE].pos:=pos;
  with mHeros[HE] do
  begin
    pos.x:=mHeros[HE].pos.x-1;
    pid:=PL;
  end;
  mHeros[HE].obX:=mTiles[pos.x,pos.y,pos.l].obX;
  mTiles[pos.x,pos.y,pos.l].obX.t:=OB34_Hero;
  mTiles[pos.x,pos.y,pos.l].obX.u:=mHeros[HE].id;
  mTiles[pos.x,pos.y,pos.l].obX.oid:=mHeros[HE].oid;
  mPlayers[PL].res[6]:=mPlayers[PL].res[6]-2500;
  Cmd_He_Add(HE);
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_StartTurn(PL: integer);
begin
  LogP.InsertRedStr('Start Turn of', mPlayers[PL].name);
  Cmd_PL_NewDay(PL);
  if mPlayers[PL].isCPU then
     Cmd_AI_ImproveCity(PL);
end;
{----------------------------------------------------------------------------}
function Cmd_PL_CheckWINLOS(PL: integer): integer;
const
  VICartifact=0;
  VICgatherTroop=1;
  VICgatherResource=2;
  VICbuildCity=3;
  VICbuildGrail=4;
  VICbeatHero=5;
  VICcaptureCity=6;
  VICbeatMonster=7;
  VICtakeDwellings=8;
  VICtakeMines=9;
  VICtransportItem=10;
  VICwinStandard=-1;

  LOSCastle=0;
  LOSHero=1;
  LOStimeExpires=2;
  LOSStandard=-1;
var
  i,j, AR:integer;
begin
  result:=0;
  // standard win , i am the unique player
  if mData.nPlr<=1 then result:=1;
  case mData.vct of
    VICwinStandard:
    begin
      if mData.nPlr<=1 then result:=1;
    end;
    VICartifact:
    begin
      for i:=0 to mPlayers[mPL].nHero -1 do
      begin
        for j:=0 to 21 do
        begin
          AR:=mHeros[mPlayers[mPL].LstHero[i]].Arts[j];
          if AR=mData.vicitem then
          begin
            result:=1;
            break;
          end;
        end;
      end;
    end;
    VICcaptureCity:
    begin
      if mCitys[cmd_CT_find(mData.vicpos)].pid=hPL then result:=1;
    end;
  end;
  case mData.lss of
    LOSStandard:
    begin
      if mPlayers[hPL].isAlive=false then result:=-1;
    end;
  end;
  if result <> 0 then mPL:=hPL;
end;
{----------------------------------------------------------------------------}
procedure Cmd_DT_NewDay;
begin
  mData.weekmsg:='';
  Cmd_CT_NewDay;
  mPL:=0;
  mData.Day:=mData.Day+1;
  if mData.Day=7 then
  begin
    //new week apply bonus
    mData.Week:=mData.Week+1;
    Cmd_CT_NewWeek;
    Cmd_OB_NewWeek;
    mData.Day:=0;
    if mData.Week=4 then
    begin
      mData.Week:=0;
      mData.Month:=mData.Month+1;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_NewDay(PL:integer);
var
  i: integer;
begin
  with mPlayers[PL] do
  begin
    if  nHero = 0 then
    begin
      ActiveCity:=LstCity[0];
      ActiveHero:=-1;
    end;

    for i:=0 to nHero-1 do
      Cmd_HE_NewDay(LstHero[i]);

    Cmd_PL_Income(PL);

    if mData.day=0 then exit;

    for i:=0 to MAX_RES -1 do
      RES[i]:=RES[i]+Income[i];

  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_CountMine(PL: integer);
var
  i: integer;
  r: integer;
begin
  for i:=0 to MAX_RES do
    mPlayers[PL].Mine[i]:=0;
  for i:=0 to nMines-1 do
  begin
    if mMines[i].pid=PL then
    begin
       r:=mMines[i].res;
       mPlayers[PL].Mine[r]:=mPlayers[PL].Mine[r]+1;
    end;
  end;
end;
{----------------------------------------------------------------------------}
procedure Cmd_PL_AddMine(PL: integer; MN: integer);
begin
  mMines[MN].pid:=PL;
end;
{----------------------------------------------------------------------------}

end.


int CGameState::victoryCheck( ui8 player ) const
{
	const PlayerState *p = getPlayer(player);
	if(map->victoryCondition.condition == winStandard  ||  map->victoryCondition.allowNormalVictory)
		if(player == checkForStandardWin())
			return -1;

	if(p->human || map->victoryCondition.appliesToAI)
	{
 		switch(map->victoryCondition.condition)
		{
		case artifact:
			//check if any hero has winning artifact
			for(size_t i = 0; i < p->heroes.size(); i++)
				if(p->heroes[i]->hasArt(map->victoryCondition.ID))
					return 1;

			break;

		case gatherTroop:
			{
				//check if in players armies there is enough creatures
				int total = 0; //creature counter
				for(size_t i = 0; i < map->objects.size(); i++)
				{
					const CArmedInstance *ai = NULL;
					if(map->objects[i] 
						&& map->objects[i]->tempOwner == player //object controlled by player
						&&  (ai = dynamic_cast<const CArmedInstance*>(map->objects[i]))) //contains army
					{
						for(TSlots::const_iterator i=ai->Slots().begin(); i!=ai->Slots().end(); ++i) //iterate through army
							if(i->second.type->idNumber == map->victoryCondition.ID) //it's searched creature
								total += i->second.count;
					}
				}

				if(total >= map->victoryCondition.count)
					return 1;
			}
			break;

		case gatherResource:
			if(p->resources[map->victoryCondition.ID] >= map->victoryCondition.count)
				return 1;

			break;

		case buildCity:
			{
				const CGTownInstance *t = static_cast<const CGTownInstance *>(map->victoryCondition.obj);
				if(t->tempOwner == player && t->fortLevel()-1 >= map->victoryCondition.ID && t->hallLevel()-1 >= map->victoryCondition.count)
					return 1;
			}
			break;

		case buildGrail:
			BOOST_FOREACH(const CGTownInstance *t, map->towns)
				if((t == map->victoryCondition.obj || !map->victoryCondition.obj)
					&& t->tempOwner == player 
					&& vstd::contains(t->builtBuildings, 26))
					return 1;
			break;

		case beatHero:
			if(map->victoryCondition.obj->tempOwner >= PLAYER_LIMIT) //target hero not present on map
				return 1;
			break;
		case captureCity:
			{
				if(map->victoryCondition.obj->tempOwner == player)
					return 1;
			}
			break;
		case beatMonster:
			if(!map->objects[map->victoryCondition.obj->id]) //target monster not present on map
				return 1;
			break;
		case takeDwellings:
			for(size_t i = 0; i < map->objects.size(); i++)
			{
				if(map->objects[i] && map->objects[i]->tempOwner != player) //check not flagged objs
				{
					switch(map->objects[i]->ID)
					{
					case 17: case 18: case 19: case 20: //dwellings
					case 216: case 217: case 218:
						return 0; //found not flagged dwelling - player not won
					}
				}
			}
			return 1;
			break;
		case takeMines:
			for(size_t i = 0; i < map->objects.size(); i++)
			{
				if(map->objects[i] && map->objects[i]->tempOwner != player) //check not flagged objs
				{
					switch(map->objects[i]->ID)
					{
					case 53: case 220:
						return 0; //found not flagged mine - player not won
					}
				}
			}
			return 1;
			break;
		case transportItem:
			{
				const CGTownInstance *t = static_cast<const CGTownInstance *>(map->victoryCondition.obj);
				if(t->visitingHero && t->visitingHero->hasArt(map->victoryCondition.ID)
					|| t->garrisonHero && t->garrisonHero->hasArt(map->victoryCondition.ID))
				{
					return 1;
				}
			}
			break;
 		}
	}

	return 0;
}

ui8 CGameState::checkForStandardWin() const
{
	//std victory condition is:
	//all enemies lost
	ui8 supposedWinner = 255, winnerTeam = 255;
	for(std::map<ui8,PlayerState>::const_iterator i = players.begin(); i != players.end(); i++)
	{
		if(i->second.status == PlayerState::INGAME && i->first < PLAYER_LIMIT)
		{
			if(supposedWinner == 255)		
			{
				//first player remaining ingame - candidate for victory
				supposedWinner = i->second.color;
				winnerTeam = map->players[supposedWinner].team;
			}
			else if(winnerTeam != map->players[i->second.color].team)
			{
				//current candidate has enemy remaining in game -> no vicotry
				return 255;
			}
		}
	}

	return supposedWinner;
}

bool CGameState::checkForStandardLoss( ui8 player ) const
{
	//std loss condition is: player lost all towns and heroes
	const PlayerState &p = *getPlayer(player);
	return !p.heroes.size() && !p.towns.size();
}
