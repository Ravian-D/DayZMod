_isAir = vehicle player iskindof "Air";
_inVehicle = (vehicle player != player);
_fastRun = _this select 0;
_dateNow = (DateToNumber date);
_maxZombies = dayz_maxLocalZombies;
if (_inVehicle) then {
	_maxZombies = 8;
};

_age = -1;

// If they just got out of a vehicle, boost their per-player zombie limit by 5 in hopes of allowing insta-spawn zombies
if (dayz_inVehicle and !_inVehicle) then {
    dayz_spawnWait = -300;
    //_maxZombies = _maxZombies + 2;
};

dayz_inVehicle = _inVehicle;

//if (((time - dayz_spawnWait) < dayz_spawnDelay) or ((time - dayz_lootWait) < dayz_lootDelay)) exitWith {diag_log("Skipping Check since neither loot or zombies are ready");};
//if (((time - dayz_spawnWait) < dayz_spawnDelay) and ((time - dayz_lootWait) < dayz_lootDelay)) exitWith {};

//diag_log("SPAWN CHECKING: Starting");

//if (!_inVehicle) then {
    _position = getPosATL player;
    //waitUntil{_position nearObjectsReady 160};
	_nearby = _position nearObjects ["building",160];
	_tooManyZs = {alive _x} count (_position nearEntities ["zZombie_Base",60]) > _maxZombies;
	//diag_log("Too Many Zeds: " +str(_tooManyZs));
    //diag_log(format["SPAWN CHECK: Building count is %1", count _nearby]);
    {
        //diag_log("SPAWN CHECK: Start of Loop");
        _type = typeOf _x;
        _config =       configFile >> "CfgBuildingLoot" >> _type;
        _canZombie = isClass (_config);
        _canLoot = ((count (getArray (_config >> "lootPos"))) > 0);
        _dis = _x distance player;

		if ((!_inVehicle) and (_canLoot)) then {    
			//diag_log("SPAWN LOOT: " + _type + " Building is lootable");
			//dayz_serverSpawnLoot = [_dis, _x];
			//publicVariableServer "dayz_serverSpawnLoot";
			_keepAwayDist = ((sizeOf _type)+5);
			_isNoone =  {isPlayer _x} count (_x nearEntities ["CAManBase",_keepAwayDist]) == 0;

			//diag_log(format["SPAWN LOOT: isNoone: %1 | keepAwayDist %2 | %3", str(_isNoone), _keepAwayDist, _type]);
			if (_isNoone) then {
				_looted = (_x getVariable ["looted",-0.1]);
				_cleared = (_x getVariable ["cleared",true]);
				_dateNow = (DateToNumber date);
				_age = (_dateNow - _looted) * 525948;
				//diag_log ("SPAWN LOOT: " + _type + " Building is " + str(_age) + " old" );

				if (_age > 8) then {
					//diag_log("SPAWN LOOT: Spawning loot");
					//Register
					_x setVariable ["looted",_dateNow,true];
					//cleanup
					//_nearByObj = (getPosATL _x) nearObjects ["ReammoBox",((sizeOf _type)+5)];
					//{deleteVehicle _x} forEach _nearByObj;
					dayz_lootWait = time;
					_handle = [_x,_fastRun] spawn building_spawnLoot;
					waitUntil{scriptDone _handle};
				};
			};
		};

		//if ((time - dayz_spawnWait) > dayz_spawnDelay) then {
			if (dayz_spawnZombies < _maxZombies) then {
				if (!_tooManyZs) then {
					private["_zombied"];
					_zombied = (_x getVariable ["zombieSpawn",-0.1]);
					_dateNow = (DateToNumber date);
					_age = (_dateNow - _zombied) * 525948;
					//diag_log(format["Date: %1 | ZombieSpawn: %2 | age: %3 | building: %4 (%5)", _dateNow, _zombied, _age, str(_x), _dis]);
					if (_age > 1) then {
						_bPos = getPosATL _x;
						_zombiesNum = count (_bPos nearEntities ["zZombie_Base",(((sizeOf _type) * 2) + 10)]);	
						if (_zombiesNum == 0) then {
							//Randomize Zombies
							_x setVariable ["zombieSpawn",_dateNow,true];
							_handle = [_x,_fastRun] spawn building_spawnZombies;
							waitUntil{scriptDone _handle};
						};
					};
				};
			//} else {
				//dayz_spawnWait = time;
				//dayz_spawnZombies = 0;
			};
		//};
		if (!_fastRun) then {
			  sleep 0.1;
		};
	} forEach _nearby;
//};