package debug;

import flixel.util.FlxColor;

import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System;

import flixel.FlxG;

import funkin.backend.ClientPrefs;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends Sprite
{
	public static var instance:Null<FPSCounter> = null;
	
	/**
	 * Creates a DebugDisplay instance
	 * 
	 * Use after your FlxGame is initiated.
	 */
	public static function init()
	{
		if (FlxG.game?.parent == null || instance != null) return;
		
		instance = new FPSCounter(5, 3, 0xFFFFFF);
		instance.visible = ClientPrefs.data.showFPS;
		
		FlxG.game.parent.addChild(instance);
	}
	
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;
	
	public static var ALLOW_UPDATES:Bool = true;
	
	/**
		The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;
	
	@:noCompletion private var times:Array<Float>;
	
	var textDisplay:TextField;
	var underlay:Bitmap;
	
	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();
		this.x = x;
		this.y = y;
		this.currentFPS = 0;
		this.times = [];
		
		underlay = new Bitmap();
		underlay.bitmapData = new BitmapData(1, 1, true, 0x6D000000);
		addChild(underlay);
		underlay.y = 3;
		
		textDisplay = new TextField();
		textDisplay.defaultTextFormat = new TextFormat(Paths.font("comic.ttf"), 14, color);
		textDisplay.text = "FPS: ";
		textDisplay.selectable = false;
		textDisplay.mouseEnabled = false;
		textDisplay.autoSize = LEFT;
		textDisplay.multiline = true;
		addChild(textDisplay);
		
		// FlxG.game
	}
	
	var deltaTimeout:Float = 0.0;
	
	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		@:privateAccess
		if (FlxG.game._lostFocus) return;
		
		if (!ALLOW_UPDATES) return;
		
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();
			
		// textDisplay.textColor = FlxColor.fromHSB((cast textDisplay.textColor : FlxColor).hue + deltaTime * 0.5, 1, 1, 1);
		
		// prevents the overlay from updating every frame, why would you need to anyways @crowplexus
		if (deltaTimeout < 100)
		{
			deltaTimeout += deltaTime;
			return;
		}
		
		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		updateText();
		
		deltaTimeout = 0.0;
		
		if (underlay.alpha == 0) return;
		
		underlay.width = textDisplay.width + 5;
		underlay.height = textDisplay.height - 5;
	}
	
	inline function updateText():Void
	{
		final tex = 'FPS: ${currentFPS} • Memory: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';
		if (textDisplay.text != tex) textDisplay.text = tex;
	}
	
	inline function get_memoryMegas():Float
	{
		#if cpp
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
		#else
		return (cast System.totalMemory : UInt);
		#end
	}
}
