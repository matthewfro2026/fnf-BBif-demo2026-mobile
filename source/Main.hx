package;

import flixel.util.FlxColor;
import flixel.system.FlxAssets;

import haxe.Json;
import haxe.io.Path;

import lime.app.Application;
#if linux
import lime.graphics.Image;
#end

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;

import debug.FPSCounter;

import flixel.FlxG;

import funkin.utils.MacroUtil;

import flixel.system.frontEnds.SoundFrontEnd;
import flixel.system.ui.FlxSoundTray;

import openfl.display.BitmapData;
import openfl.display.Bitmap;

import flixel.FlxGame;
import flixel.FlxState;

import funkin.backend.ClientPrefs;

// crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;

import haxe.CallStack;
import haxe.io.Path;

import sys.Http;
#end

class Main extends Sprite
{
	public static final game =
		{
			width: 1280, // WINDOW width
			height: 720, // WINDOW height
			initialState: funkin.states.MainMenuState, // initial game state
			framerate: 60, // default framerate
			skipSplash: true, // if the default flixel splash screen should be skipped
			startFullscreen: false // if the game should start at fullscreen mode
		};
		
	public static function main():Void
	{
		Lib.current.addChild(new Main());
        #if cpp
        cpp.NativeGc.enable(true);
        cpp.NativeGc.run(true);
        #end // limpeza no cache 
	}
	
	public function new()
	{
		super();
		
		#if (windows && !debug)
		funkin.backend.system.Windows.setDpiAware();
		#end

		ClientPrefs.tryBindingSave('funkin');
		addChild(new FNFGame(game.width, game.height, InitState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
	
		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
		
		#if DISCORD_ALLOWED DiscordClient.prepare(); #end
	}
	
	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();
		
		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");
		
		path = "./crash/" + "PsychEngine_" + dateNow + ".txt";
		
		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}
		
		errMsg += "\nUncaught Error: " + e.error;
		
		if (!FileSystem.exists("./crash/")) FileSystem.createDirectory("./crash/");
		
		File.saveContent(path, errMsg + "\n");
		
		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));
		
		Application.current.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}

class FNFGame extends FlxGame
{
	override function create(_:Event)
	{
        #if windows
		_customSoundTray = CustomSoundTray; // NÃO funciona no mobile ass: juse gst-
		FlxG.sound.soundTray.volumeDownSound = 'assets/sounds/soundTrayMinus';
		FlxG.sound.soundTray.volumeUpSound = 'assets/sounds/soundTrayPlus';
		#end

        super.create(_);

		// // KILL EVERYONE
		// // atleast we arent shadowing flixel classes yahoo!
		// #if FLX_SOUND_SYSTEM
		// untyped FlxG.sound = new BaldiSoundFrontEnd();
		// #end
	}
}

class CustomSoundTray extends FlxSoundTray
{
	public var volumeMaxSound:String = 'assets/sounds/SoundTrayMax';
	
	var _barsDithered:Array<Bitmap>;
	
	public function new()
	{
		super();
		
		removeChildren();
		
		_defaultScale = 0.35;
		
		_bars = [];
		_barsDithered = [];
		
		final PADDING:Int = 5;
		var x:Float = 10;
		for (i in 0...10)
		{
			var tmp = new Bitmap(BitmapData.fromFile('assets/images/ui/volumeFill.png'));
			tmp.x = x;
			tmp.y = 10;
			
			addChild(tmp);
			_bars.push(tmp);
			
			x += tmp.width + PADDING;
		}
		
		var bg = new Bitmap(new BitmapData(1, 1, true, FlxColor.BLACK));
		bg.alpha = 0.25;
		addChildAt(bg, 0);
		
		bg.width = Std.int(_bars[0].x + _bars[_bars.length - 1].x + _bars[_bars.length - 1].width);
		bg.height = _bars[0].height + 20;
		
		_minWidth = Std.int(bg.width);
		
		y = 15;
	}
	
	override function update(MS:Float)
	{
		// Animate sound tray thing
		if (_timer > 0)
		{
			_timer -= (MS / 1000);
		}
		else if (alpha > 0)
		{
			alpha -= (MS / 1000) * 2;
			
			if (alpha <= 0)
			{
				visible = false;
				active = false;
				
				#if FLX_SAVE
				// Save sound preferences
				if (FlxG.save.isBound)
				{
					FlxG.save.data.mute = FlxG.sound.muted;
					FlxG.save.data.volume = FlxG.sound.volume;
					FlxG.save.flush();
				}
				#end
			}
		}
	}
	
	override function screenCenter()
	{
		final scale = _defaultScale * FlxG.scaleMode.scale.x;
		scaleX = scale;
		scaleY = scale;
		
		x = (0.5 * (Lib.current.stage.stageWidth - _minWidth * scale) - FlxG.game.x);
	}
	
	override function updateSize()
	{
		screenCenter();
	}
	
	override function showAnim(volume:Float, ?sound:FlxSoundAsset, duration:Float = 1.0, label:String = "VOLUME")
	{
		alpha = 1;
		super.showAnim(volume, sound, duration, label);
	}
	
	override function showIncrement()
	{
		final volume = FlxG.sound.muted ? 0 : FlxG.sound.volume;
		showAnim(volume, silent ? null : volume == 1 ? volumeMaxSound : volumeUpSound);
	}
}
