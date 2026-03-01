package funkin.scripting;

import flixel.addons.display.FlxTiledSprite;
import flixel.ui.FlxBar.FlxBarFillDirection;

import funkin.utils.MacroUtil;

import flixel.FlxBasic;

import funkin.objects.Character;
import funkin.scripting.LuaUtils;
import funkin.scripting.CustomSubstate;

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import crowplexus.hscript.*;

import extensions.hscript.Sharables;
import extensions.hscript.IrisEx;

class HScript extends IrisEx
{
	// is there another way for this i don't know yet? Ig i could have just made a static but NO
	public static var globals:Dynamic = {};
	
	public static function initLogs()
	{
		Iris.warn = (x, ?pos) -> {
			PlayState.instance?.addTextToDebug('[${pos.fileName}]: WARN: ${pos.lineNumber} -> $x', FlxColor.YELLOW);
			
			Iris.logLevel(ERROR, x, pos);
		}
		
		Iris.fatal = (x, ?pos) -> {
			trace('fatalerr');
		}
		
		Iris.error = (x, ?pos) -> {
			PlayState.instance?.addTextToDebug('[${pos.fileName}]: ERROR: ${pos.lineNumber} -> $x', FlxColor.RED);
			
			Iris.logLevel(ERROR, x, pos);
		}
		
		Iris.print = (x, ?pos) -> {
			PlayState.instance?.addTextToDebug('[${pos.fileName}]: TRACE: ${pos.lineNumber} -> $x', FlxColor.WHITE);
			
			Iris.logLevel(NONE, x, pos);
		}
	}
	
	override function execute():Dynamic
	{
		var ret:Dynamic = null;
		try
		{
			ret = super.execute();
		}
		catch (e)
		{
			PlayState.instance?.addTextToDebug('PARSING ERROR: ${Std.string(e)}', FlxColor.RED);
			this.destroy();
		}
		return ret;
	}
	
	public var filePath:String;
	public var modFolder:String;
	
	public var origin:String;
	
	override public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null, ?sharables:Sharables)
	{
		file ??= '';
		
		super(null, {name: file, autoRun: false, autoPreset: false}, sharables);
		(cast interp : extensions.hscript.InterpEx).parent = FlxG.state;
		
		if (parent != null)
		{
			this.origin = parent.scriptName; // this is just name? kill it off or smth
			this.modFolder = parent.modFolder;
		}
		
		filePath = file;
		if (filePath != null && filePath.length > 0)
		{
			this.origin = filePath;
			#if MODS_ALLOWED
			var myFolder:Array<String> = filePath.split('/');
			if (myFolder[0] + '/' == Paths.mods()
				&& (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) // is inside mods folder
				this.modFolder = myFolder[1];
			#end
		}
		
		var scriptThing:String = file;
		if (parent == null && file != null)
		{
			var f:String = file.replace('\\', '/');
			if (f.contains('/') && !f.contains('\n'))
			{
				scriptThing = File.getContent(f);
			}
		}
		this.scriptCode = scriptThing;
		
		preset();
		this.varsToBring = varsToBring;
		
		// execute();
	}
	
	var varsToBring(default, set):Any = null;
	
	override function preset()
	{
		super.preset();
		
		// Some very commonly used classes
		set('FlxG', flixel.FlxG);
		set('FlxMath', flixel.math.FlxMath);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxText', flixel.text.FlxText);
		set('FlxCamera', flixel.FlxCamera);
		set('HUDCamera', funkin.backend.HUDCamera);
		
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxColor', CustomFlxColor);
		set('Countdown', funkin.backend.BaseStage.Countdown);
		set('PlayState', PlayState);
		set('Paths', Paths);
		set('Conductor', Conductor);
		set('ClientPrefs', ClientPrefs);
		#if ACHIEVEMENTS_ALLOWED
		set('Achievements', Achievements);
		#end
		set('Character', Character);
		set('Alphabet', Alphabet);
		set('Note', funkin.objects.Note);
		set('CustomSubstate', CustomSubstate);
		#if (!flash && sys)
		set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		set('ShaderFilter', openfl.filters.ShaderFilter);
		set('StringTools', StringTools);
		#if flixel_animate
		set('FlxAnimate', FlxAnimate);
		#end
		
		set("FlxSpriteGroup", FlxSpriteGroup);
		set("FlxTiledSprite", FlxTiledSprite);
		set("FlxTypedGroup", FlxTypedGroup);
		
		set("FlxTextAlign", MacroUtil.buildAbstract(flixel.text.FlxText.FlxTextAlign));
		set('FlxAxes', MacroUtil.buildAbstract(flixel.util.FlxAxes));
		set('BlendMode', MacroUtil.buildAbstract(openfl.display.BlendMode));
		set("FlxKey", MacroUtil.buildAbstract(flixel.input.keyboard.FlxKey));
		
		set("FlxTextBorderStyle", FlxTextBorderStyle);
		set('FlxBarFillDirection', FlxBarFillDirection);
		set('RenderCache', funkin.backend.RenderCache);
		
		set("FlxTextFormat", FlxTextFormat);
		set("FlxTextFormatMarkerPair", FlxTextFormatMarkerPair);
		
		set("FlxPoint", flixel.math.FlxPoint.FlxBasePoint);
		
		set('Constants', Constants);
		
		set('Swipe', funkin.objects.Swipe);
		
		set('Story', funkin.game.Story);
		
		set('DropShadowShader', funkin.shaders.DropShadowShader);
		// Functions & Variables
		set('setVar', function(name:String, value:Dynamic) {
			if (PlayState.instance == null) return value;
			
			PlayState.instance.variables.set(name, value);
			return value;
		});
		set('getVar', function(name:String) {
			if (PlayState.instance == null) return null;
			return PlayState.instance.variables.get(name);
		});
		set('removeVar', function(name:String) {
			if (PlayState.instance == null) return false;
			
			if (PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
		
		set('hasVar', (v) -> {
			if (PlayState.instance == null) return false;
			
			return PlayState.instance.variables.exists(v);
		});
		
		set('initScript', (scriptName:String) -> PlayState.instance.initHScript(Paths.getPath(scriptName)));
		set('debugPrint', function(text:String, ?color:FlxColor = null) {
			if (color == null) color = FlxColor.WHITE;
			PlayState.instance.addTextToDebug(text, color);
		});
		set('getModSetting', function(saveTag:String, ?modName:String = null) {
			if (modName == null)
			{
				if (this.modFolder == null)
				{
					PlayState.instance.addTextToDebug('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', FlxColor.RED);
					return null;
				}
				modName = this.modFolder;
			}
			return LuaUtils.getModSetting(saveTag, modName);
		});
		
		// Keyboard & Gamepads
		set('keyboardJustPressed', function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
		set('keyboardPressed', function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
		set('keyboardReleased', function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));
		
		set('anyGamepadJustPressed', function(name:String) return FlxG.gamepads.anyJustPressed(name));
		set('anyGamepadPressed', function(name:String) FlxG.gamepads.anyPressed(name));
		set('anyGamepadReleased', function(name:String) return FlxG.gamepads.anyJustReleased(name));
		
		set('gamepadAnalogX', function(id:Int, ?leftStick:Bool = true) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;
			
			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		set('gamepadAnalogY', function(id:Int, ?leftStick:Bool = true) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;
			
			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		set('gamepadJustPressed', function(id:Int, name:String) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;
			
			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		set('gamepadPressed', function(id:Int, name:String) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;
			
			return Reflect.getProperty(controller.pressed, name) == true;
		});
		set('gamepadReleased', function(id:Int, name:String) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;
			
			return Reflect.getProperty(controller.justReleased, name) == true;
		});
		
		set('keyJustPressed', function(name:String = '') {
			name = name.toLowerCase();
			switch (name)
			{
				case 'left':
					return Controls.instance.NOTE_LEFT_P;
				case 'down':
					return Controls.instance.NOTE_DOWN_P;
				case 'up':
					return Controls.instance.NOTE_UP_P;
				case 'right':
					return Controls.instance.NOTE_RIGHT_P;
				default:
					return Controls.instance.justPressed(name);
			}
			return false;
		});
		set('keyPressed', function(name:String = '') {
			name = name.toLowerCase();
			switch (name)
			{
				case 'left':
					return Controls.instance.NOTE_LEFT;
				case 'down':
					return Controls.instance.NOTE_DOWN;
				case 'up':
					return Controls.instance.NOTE_UP;
				case 'right':
					return Controls.instance.NOTE_RIGHT;
				default:
					return Controls.instance.pressed(name);
			}
			return false;
		});
		set('keyReleased', function(name:String = '') {
			name = name.toLowerCase();
			switch (name)
			{
				case 'left':
					return Controls.instance.NOTE_LEFT_R;
				case 'down':
					return Controls.instance.NOTE_DOWN_R;
				case 'up':
					return Controls.instance.NOTE_UP_R;
				case 'right':
					return Controls.instance.NOTE_RIGHT_R;
				default:
					return Controls.instance.justReleased(name);
			}
			return false;
		});
		
		set('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
			try
			{
				var str:String = '';
				if (libPackage.length > 0) str = libPackage + '.';
				
				set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic)
			{
				var msg:String = e.message.substr(0, e.message.indexOf('\n'));
				
				if (PlayState.instance != null) PlayState.instance.addTextToDebug('$origin - $msg', FlxColor.RED);
				else trace('$origin - $msg');
			}
		});
		
		set('this', this);
		set('game', FlxG.state);
		set('controls', Controls.instance);
		
		set('customSubstate', CustomSubstate.instance);
		set('customSubstateName', CustomSubstate.name);
		
		set('Function_Stop', Constants.SCRIPT_STOP);
		set('Function_Continue', Constants.SCRIPT_CONTINUE);
		set('Function_StopAll', Constants.FUNCTION_HALT);
		
		set('add', FlxG.state.add);
		set('insert', FlxG.state.insert);
		set('remove', FlxG.state.remove);
	}
	
	public function executeCode(?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):IrisCall
	{
		if (funcToRun == null) return null;
		
		if (!exists(funcToRun))
		{
			PlayState.instance.addTextToDebug(origin + ' - No function named: $funcToRun', FlxColor.RED);
			
			return null;
		}
		
		try
		{
			final callValue:IrisCall = call(funcToRun, funcArgs);
			return callValue.returnValue;
		}
		catch (e:Dynamic)
		{
			trace('ERROR ${funcToRun}: $e');
		}
		return null;
	}
	
	public function executeFunction(funcToRun:String = null, funcArgs:Array<Dynamic> = null):IrisCall
	{
		if (funcToRun == null || !exists(funcToRun)) return null;
		return call(funcToRun, funcArgs);
	}
	
	override public function destroy()
	{
		origin = null;
		
		super.destroy();
	}
	
	function set_varsToBring(values:Any)
	{
		if (varsToBring != null) for (key in Reflect.fields(varsToBring))
			if (exists(key.trim())) interp.variables.remove(key.trim());
			
		if (values != null)
		{
			for (key in Reflect.fields(values))
			{
				key = key.trim();
				set(key, Reflect.field(values, key));
			}
		}
		
		return varsToBring = values;
	}
}

class CustomFlxColor
{
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;
	
	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;
	
	public static function fromInt(Value:Int):Int
	{
		return cast FlxColor.fromInt(Value);
	}
	
	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
	{
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
	}
	
	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
	{
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
	}
	
	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
	{
		return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	}
	
	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
	{
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
	}
	
	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
	{
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
	}
	
	public static function fromString(str:String):Int
	{
		return cast FlxColor.fromString(str);
	}
}
#end
