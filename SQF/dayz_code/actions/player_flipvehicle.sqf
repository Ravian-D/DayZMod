private["_object","_position"];
_object = _this select 3;

_position = [position _object,0,0,0,0,0,0,position player] call BIS_fnc_findSafePos;

//Standup
//player playMove "amovpercmstpsraswrfldnon_amovpknlmstpslowwrfldnon";
//sleep 1;
//waitUntil { animationState player != "amovpercmstpsraswrfldnon_amovpknlmstpslowwrfldnon"};

//Kneel Down
player playMove "amovpknlmstpslowwrfldnon_amovpercmstpsraswrfldnon";
waitUntil { animationState player != "amovpknlmstpslowwrfldnon_amovpercmstpsraswrfldnon"};
sleep 3;

_object setpos _position;


//Other possibilities
//[_object,0, 0] call bis_fnc_setpitchbank;
//_object setpos [getpos _object select 0, getpos _object select 1, 0];