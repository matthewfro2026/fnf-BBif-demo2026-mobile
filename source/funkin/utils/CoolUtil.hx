package funkin.utils;

import lime.utils.Assets as LimeAssets;

import openfl.filters.ShaderFilter;
import openfl.utils.Assets;

import flixel.util.typeLimit.NextState;
import flixel.util.FlxStringUtil;
import flixel.util.typeLimit.OneOfTwo;
import flixel.util.FlxBitmapDataUtil;
import flixel.system.FlxAssets.FlxShader;

class CoolUtil
{
	inline public static function quantize(f:Float, snap:Float)
	{
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		// trace(snap);
		return (m / snap);
	}
	
	inline public static function capitalize(text:String) return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();
	
	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:Null<String> = null;
		
		try
		{
			if (FileSystem.exists(path)) daList = File.getContent(path);
		}
		catch (e) {}
		
		return daList != null ? listFromString(daList) : [];
	}
	
	inline public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if (color.startsWith('0x')) color = color.substring(color.length - 6);
		
		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}
	
	inline public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');
		
		for (i in 0...daList.length)
			daList[i] = daList[i].trim();
			
		return daList;
	}
	
	inline public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel)) countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687)) countByColor[colorOfThisPixel] = 1;
				}
			}
		}
		
		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}
	
	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
			dumbArray.push(i);
			
		return dumbArray;
	}
	
	inline public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
	
	inline public static function formatSongName(name:String)
	{
		return (FlxStringUtil.toTitleCase(name.replace('-', ' ')));
	}
	
	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}
	
	inline public static function openFolder(folder:String, absolute:Bool = false)
	{
		#if sys
		if (!absolute) folder = Sys.getCwd() + '$folder';
		
		folder = folder.replace('/', '\\');
		if (folder.endsWith('/')) folder.substr(0, folder.length - 1);
		
		#if linux
		var command:String = 'explorer.exe';
		#else
		var command:String = '/usr/bin/xdg-open';
		#end
		Sys.command(command, [folder]);
		trace('$command $folder');
		#else
		FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}
	
	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String
	{
		final company:String = FlxG.stage.application.meta.get('company');
		// #if (flixel < "5.0.0") return company; #else
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
		// #end
	}
	
	public static function setTextBorderFromString(text:FlxText, border:String)
	{
		switch (border.toLowerCase().trim())
		{
			case 'shadow':
				text.borderStyle = SHADOW;
			case 'outline':
				text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;
			default:
				text.borderStyle = NONE;
		}
	}
	
	public static function addShader(shader:OneOfTwo<FlxShader, String>, ?camera:FlxCamera):Void
	{
		var inputShader:Null<FlxShader> = null;
		if (shader is String && PlayState.instance != null)
		{
			var success = PlayState.instance.initLuaShader(shader);
			if (!success) return;
			inputShader = PlayState.instance.createRuntimeShader(shader);
		}
		else if (shader is FlxShader)
		{
			inputShader = cast shader;
		}
		
		if (inputShader == null) return;
		
		final filter = new ShaderFilter(inputShader);
		
		camera ??= FlxG.camera;
		camera.filters ??= [];
		camera.filters.push(filter);
	}
	
	public static function removeShader(shader:OneOfTwo<FlxShader, String>, ?cam:FlxCamera)
	{
		// if (!ClientPrefs.data.shaders) return;
		
		if (cam == null) cam = FlxG.camera;
		if (cam.filters == null) return;
		
		var frag:String = '';
		if (shader is String)
		{
			if (PlayState.instance.runtimeShaders.exists(shader)) frag = PlayState.instance.runtimeShaders.get(shader)[0];
			else return;
		}
		
		for (f in cam.filters)
		{
			if (f is openfl.filters.ShaderFilter)
			{
				var sf = cast(f, openfl.filters.ShaderFilter);
				if (shader is FlxShader)
				{
					if (sf.shader == shader)
					{
						cam.filters.remove(f);
						break;
					}
				}
			}
		}
	}
	
	/**
		essentially it just plays a flxsound but with persisting and autodestroy enabled.
		so itll play through state swaps
	**/
	public static function playUISound(sound:String, volume:Float = 1)
	{
		var sound = FlxG.sound.play(Paths.sound(sound), volume);
		sound.persist = true;
		sound.autoDestroy = true;
		return sound; // if u need it for smth ig
	}
	
	inline static public function switchStateAndStopMusic(target:NextState, stopMusic = false)
	{
		if (stopMusic && FlxG.sound.music != null) FlxG.sound.music.stop();
		
		FlxG.switchState(target);
	}
	
	/**
	 * Identical to `Reflect.setProperty` but allows for nested fields
	 */
	@:inheritDoc(Reflect.setProperty)
	public static function setProperty(obj:Dynamic, field:String, value:Dynamic):Void
	{
		if (!field.contains('.'))
		{
			Reflect.setProperty(obj, field, value);
			return;
		}
		
		final splitFields = field.split('.');
		
		var property:Dynamic = Reflect.getProperty(obj, splitFields.shift());
		
		while (splitFields.length > 1)
		{
			property = Reflect.getProperty(property, splitFields.shift());
		}
		
		Reflect.setProperty(property, splitFields[0], value);
	}
	
	/**
	 * returns a new FlxCamera instance with a width of `FlxG.width + 1` to avoid scaling issues.
	 */
	public static function createPaddedCamera():FlxCamera
	{
		return new FlxCamera(0, 0, FlxG.width + 1, FlxG.height + 1);
	}
}
