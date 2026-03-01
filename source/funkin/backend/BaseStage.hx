package funkin.backend;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import funkin.backend.MusicBeatState;
import funkin.objects.Note.EventNote;
import funkin.objects.Note;
import funkin.objects.Character;

enum Countdown
{
	THREE;
	TWO;
	ONE;
	GO;
	START;
}

class BaseStage extends FlxBasic
{
	private var game(default, set):Dynamic = PlayState.instance;
	
	public var onPlayState:Bool = false;
	
	// some variables for convenience
	public var paused(get, never):Bool;
	public var songName(get, never):String;
	public var isStoryMode(get, never):Bool;
	public var seenCutscene(get, never):Bool;
	public var inCutscene(get, set):Bool;
	public var canPause(get, set):Bool;
	public var members(get, never):Dynamic;
	public var stageMembers:Array<FlxBasic> = []; // do this later ro smth
	public var mustHitSection(get, never):Bool;
	
	public var boyfriend(get, never):Character;
	public var dad(get, never):Character;
	public var gf(get, never):Character;
	public var boyfriendGroup(get, never):FlxSpriteGroup;
	public var dadGroup(get, never):FlxSpriteGroup;
	public var gfGroup(get, never):FlxSpriteGroup;
	
	public var camGame(get, never):FlxCamera;
	public var camHUD(get, never):FlxCamera;
	public var camOther(get, never):FlxCamera;
	
	public var defaultCamZoom(get, set):Float;
	public var camFollow(get, never):FlxObject;
	public var camOffset(get, set):Float;
	
	public var globalAntialiasing:Bool = ClientPrefs.data.antialiasing;
	
	public function new()
	{
		this.game = MusicBeatState.getState();
		if (this.game == null)
		{
			FlxG.log.warn('Invalid state for the stage added!');
			destroy();
		}
		else
		{
			this.game.stages.push(this);
			super();
			create();
		}
	}
	
	// main callbacks
	public function create() {}
	
	public function createPost() {}
	
	public function updatePost(elapsed:Float) {}
	
	public function countdownTick(count:Countdown, num:Int) {}
	
	public function opponentNoteHit(note:Note) {}
	
	public function goodNoteHit(note:Note) {}
	
	public function onSongStart() {}
	
	// FNF steps, beats and sections
	public var curBeat:Int = 0;
	public var curDecBeat:Float = 0;
	public var curStep:Int = 0;
	public var curDecStep:Float = 0;
	public var curSection:Int = 0;
	
	public function beatHit() {}
	
	public function stepHit() {}
	
	public function sectionHit() {}
	
	// Substate close/open, for pausing Tweens/Timers
	public function closeSubState() {}
	
	public function openSubState(SubState:FlxSubState) {}
	
	public function onDestroy() {}
	
	// Events
	public function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {}
	
	public function eventPushed(event:EventNote) {}
	
	public function eventPushedUnique(event:EventNote) {}
	
	// Things to replace FlxGroup stuff and inject sprites directly into the state
	function add(object:FlxBasic)
	{
		stageMembers.push(object);
		game.add(object);
	}
	
	function remove(object:FlxBasic)
	{
		stageMembers.remove(object);
		game.remove(object);
	}
	
	function insert(position:Int, object:FlxBasic)
	{
		stageMembers.insert(position, object);
		game.insert(position, object);
	}
	
	public function addBehindGF(obj:FlxBasic) insert(members.indexOf(game.gfGroup), obj);
	
	public function addBehindBF(obj:FlxBasic) insert(members.indexOf(game.boyfriendGroup), obj);
	
	public function addBehindDad(obj:FlxBasic) insert(members.indexOf(game.dadGroup), obj);
	
	public function setDefaultGF(name:String) // Fix for the Chart Editor on Base Game stages
	{
		var gfVersion:String = PlayState.SONG.gfVersion;
		if (gfVersion == null || gfVersion.length < 1)
		{
			gfVersion = name;
			PlayState.SONG.gfVersion = gfVersion;
		}
	}
	
	// start/end callback functions
	public function setStartCallback(myfn:Void->Void)
	{
		if (!onPlayState) return;
		PlayState.instance.startCallback = myfn;
	}
	
	public function setEndCallback(myfn:Void->Void)
	{
		if (!onPlayState) return;
		PlayState.instance.endCallback = myfn;
	}
	
	// precache functions // simplified this cuz og setup is really dumb
	public function precacheImage(key:String) Paths.image(key);
	
	public function precacheSound(key:String) Paths.sound(key);
	
	public function precacheMusic(key:String) Paths.music(key);
	
	// overrides
	function startCountdown() if (onPlayState) return PlayState.instance.startCountdown();
	else return false;
	
	function endSong() if (onPlayState) return PlayState.instance.endSong();
	else return false;
	
	function moveCameraSection() if (onPlayState) moveCameraSection();
	
	function moveCamera(isDad:Bool) if (onPlayState) moveCamera(isDad); // these are fucked
	
	@:noCompletion inline private function get_mustHitSection():Bool return PlayState.SONG.notes[@:privateAccess PlayState.instance.curSection].mustHitSection;
	
	@:noCompletion inline private function get_paused() return game.paused;
	
	@:noCompletion inline private function get_songName() return game.songName;
	
	@:noCompletion inline private function get_isStoryMode() return PlayState.isStoryMode;
	
	@:noCompletion inline private function get_seenCutscene() return PlayState.seenCutscene;
	
	@:noCompletion inline private function get_inCutscene() return game.inCutscene;
	
	@:noCompletion inline private function set_inCutscene(value:Bool)
	{
		game.inCutscene = value;
		return value;
	}
	
	@:noCompletion inline private function get_canPause() return game.canPause;
	
	@:noCompletion inline private function set_canPause(value:Bool)
	{
		game.canPause = value;
		return value;
	}
	
	@:noCompletion inline private function get_members() return game.members;
	
	@:noCompletion inline private function set_game(value:MusicBeatState)
	{
		onPlayState = (Std.isOfType(value, funkin.states.PlayState));
		game = value;
		return value;
	}
	
	@:noCompletion inline private function get_boyfriend():Character return game.boyfriend;
	
	@:noCompletion inline private function get_dad():Character return game.dad;
	
	@:noCompletion inline private function get_gf():Character return game.gf;
	
	@:noCompletion inline private function get_boyfriendGroup():FlxSpriteGroup return game.boyfriendGroup;
	
	@:noCompletion inline private function get_dadGroup():FlxSpriteGroup return game.dadGroup;
	
	@:noCompletion inline private function get_gfGroup():FlxSpriteGroup return game.gfGroup;
	
	@:noCompletion inline private function get_camGame():FlxCamera return game.camGame;
	
	@:noCompletion inline private function get_camHUD():FlxCamera return game.camHUD;
	
	@:noCompletion inline private function get_camOther():FlxCamera return game.camOther;
	
	@:noCompletion inline private function get_camOffset() return game.camOffset;
	
	@:noCompletion inline private function set_camOffset(v:Float)
	{
		game.camOffset = v;
		return game.camOffset;
	}
	
	@:noCompletion inline private function get_defaultCamZoom():Float return game.defaultCamZoom;
	
	@:noCompletion inline private function set_defaultCamZoom(value:Float):Float
	{
		game.defaultCamZoom = value;
		return game.defaultCamZoom;
	}
	
	@:noCompletion inline private function get_camFollow():FlxObject return game.camFollow;
}
