package;

import funkin.backend.ClientPrefs;

import flixel.FlxSprite;

import funkin.game.VideoCutscene;

import flixel.system.scaleModes.RelativeScaleMode;

import lime.app.Application;

import openfl.display.Sprite;
import openfl.display.BitmapData;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.FlxState;

@:bitmap("art/cursor.png") class Cursor extends BitmapData {}

class InitState extends FlxState
{
	// for everything ud want to boot up before the game starts do in here
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
	
	// move out of init? maybe
	public static var defaultAppTitle(get, never):String;
	
	static function get_defaultAppTitle():String return Application.current.meta['name'];
	
	override function create()
	{
		funkin.backend.Controls.instance = new funkin.backend.Controls();
		funkin.backend.ClientPrefs.loadDefaultKeys();
		
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		
		funkin.backend.ClientPrefs.loadPrefs();
		
		funkin.backend.Highscore.load();
		
		#if LUA_ALLOWED funkin.backend.Mods.pushGlobalMods(); #end
		funkin.backend.Mods.loadTopMod();
		
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
		
		FlxG.signals.postStateSwitch.add(onStateSwitchPost);
		FlxG.signals.gameResized.add(onGameResize);
		
		FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;
		
		funkin.scripting.HScript.initLogs();
		
		// init plugins
		
		#if DEBUG_FEATURES
		funkin.plugins.HotReloadPlugin.init();
		#end
		
		#if hxvlc
		funkin.objects.FunkinVideoSprite.init();
		#end
		
		funkin.plugins.MousePlugin.init();
		
		#if debug
		FlxG.console.registerClass(VideoCutscene);
		#end
		
		#if FEATURE_DEBUG_TRACY
		// Apply a marker to indicate frame end for the Tracy profiler.
		//  Do this only if Tracy is configured to prevent lag.
		openfl.Lib.current.stage.addEventListener(openfl.events.Event.EXIT_FRAME, (e:openfl.events.Event) -> {
			cpp.vm.tracy.TracyProfiler.frameMark();
		});
		
		cpp.vm.tracy.TracyProfiler.setThreadName("main");
		#end
		
		super.create();
		
		FlxG.switchState(() -> #if debug Type.createInstance(Main.game.initialState, []) #else new FlxSplashIntro() #end);
	}
	
	public static function onGameResize(w:Float, h:Float)
	{
		if (FlxG.cameras != null)
		{
			for (cam in FlxG.cameras.list)
				if (cam != null && cam.filters != null) resetSpriteCache(cam.flashSprite);
		}
		if (FlxG.game != null) resetSpriteCache(FlxG.game);
		
		final scale:Float = Math.max(1, Math.min(w / FlxG.width, h / FlxG.height));
		
		if (FlxG.mouse != null && FlxG.mouse.cursor != null) FlxG.mouse.cursor.scaleX = FlxG.mouse.cursor.scaleY = scale;
	}
	
	public static function resetSpriteCache(sprite:Sprite):Void
	{
		@:privateAccess
		{
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
	
	static var _cursor:Cursor = new Cursor(0, 0);
	
	public static function onStateSwitchPost()
	{
		#if debug
		var state = Type.getClassName(Type.getClass(FlxG.state));
		if (state.contains('editor'))
		{
			FlxG.mouse.unload();
		}
		else
		#end
		{
			FlxG.mouse.load(_cursor, 1, -8, 0);
		}
	}
}
