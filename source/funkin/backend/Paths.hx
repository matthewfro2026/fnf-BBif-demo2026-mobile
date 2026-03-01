package funkin.backend;

import animate.FlxAnimateFrames.SpritemapInput;

import sys.Http;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

import openfl.utils.AssetType;
import openfl.media.Sound;

#if MODS_ALLOWED
import funkin.backend.Mods;
#end

using StringTools;

using haxe.io.Path;

class Paths
{
	/**
	 * The core directory of the assets
	 * 
	 * defined for redirecting purpoeses.
	 */
	public static inline final core:String = #if ASSET_REDIRECT '../../../../assets' #else 'assets' #end;
	
	@:allow(funkin.backend.FunkinCache)
	static var tempAtlasFramesCache:Map<String, FlxAtlasFrames> = []; // maybe instead of this make a txt cache ?
	
	public static function getPath(file:String, ?type:AssetType = TEXT, ?parentFolder:String, modsAllowed:Bool = false):String
	{
		if (parentFolder != null) file = '$parentFolder/$file';
		
		#if MODS_ALLOWED
		if (modsAllowed)
		{
			var modded:String = modFolders(file);
			if (FileSystem.exists(modded)) return modded;
		}
		#end
		
		return getSharedPath(file);
	}
	
	inline public static function getSharedPath(file:String = '')
	{
		return '$core/$file';
	}
	
	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}
	
	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}
	
	inline static public function json(key:String, ?library:String, checkMods:Bool = true)
	{
		return getPath('data/$key.json', TEXT, library, checkMods);
	}
	
	inline static public function config(key:String, song:String, ?library:String)
	{
		return getPath('data/$song/$key', TEXT, library);
	}
	
	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
	
	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}
	
	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}
	
	inline static public function obj(key:String, ?library:String)
	{
		return getPath('models/$key.obj', TEXT, library);
	}
	
	static public function video(key:String, checkMods:Bool = true):String
	{
		return findFileWithExts('videos/$key', ['mp4', 'mov'], null, checkMods);
	}
	
	public static function findFileWithExts(file:String, exts:Array<String>, ?parentFolder:String, checkMods:Bool = true):String
	{
		for (ext in exts)
		{
			final joined = getPath('$file.$ext', TEXT, parentFolder, checkMods);
			if (FunkinAssets.exists(joined)) return joined;
		}
		
		return getPath(file, TEXT, parentFolder, checkMods); // assuming u mightve added a ext already
	}
	
	static public function sound(key:String, ?parentFolder:String, checkMods:Bool = true):Sound
	{
		final key = findFileWithExts('sounds/$key', ['ogg', 'wav'], parentFolder, checkMods);
		
		return FunkinAssets.getSound(key);
	}
	
	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}
	
	public static inline function music(key:String, ?parentFolder:String, checkMods:Bool = true):Sound
	{
		final key = findFileWithExts('music/$key', ['ogg', 'wav'], parentFolder, checkMods);
		
		return FunkinAssets.getSound(key);
	}
	
	public static inline function voices(song:String, ?postFix:String, checkMods:Bool = true):Null<Sound>
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		if (postFix != null) songKey += '-$postFix';
		
		songKey = findFileWithExts('songs/$songKey', ['ogg', 'wav'], null, checkMods);
		
		return FunkinAssets.getSoundUnsafe(songKey);
	}
	
	public static inline function inst(song:String, ?postFix:String, checkMods:Bool = true):Null<Sound>
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		if (postFix != null) songKey += '-$postFix';
		
		songKey = findFileWithExts('songs/$songKey', ['ogg', 'wav'], null, checkMods);
		
		return FunkinAssets.getSoundUnsafe(songKey);
	}
	
	/**
	 * Returns a FlxGraphic from the given Path.
	 */
	public static inline function image(key:String, ?parentFolder:String, allowGPU:Bool = true, checkMods:Bool = true):FlxGraphic
	{
		final key = getPath('images/$key.png', IMAGE, parentFolder, checkMods);
		
		return FunkinAssets.getGraphic(key, true, allowGPU) ?? FlxG.bitmap.add('flixel/images/logo/default.png');
	}
	
	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):Null<String>
	{
		key = Paths.getPath(key, TEXT, null, !ignoreMods);
		
		return FunkinAssets.exists(key) ? FunkinAssets.getContent(key) : null;
	}
	
	public static inline function font(key:String, checkMods:Bool = true):String
	{
		return findFileWithExts('fonts/$key', ['ttf', 'otf'], null, checkMods);
	}
	
	public static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String = null)
	{
		#if MODS_ALLOWED
		if (!ignoreMods)
		{
			for (mod in Mods.getGlobalMods())
				if (FileSystem.exists(mods('$mod/$key'))) return true;
				
			if (FileSystem.exists(mods(Mods.currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) return true;
			
			if (FileSystem.exists(mods('$key'))) return true;
		}
		#end
		
		return FunkinAssets.exists(getPath(key, type, library, false));
	}
	
	/**
	 * Retrieves atlas frames from either `Sparrow` or `Packer` 
	 * 
	 * `Packer` has priority.
	 */
	public static inline function getAtlas(key:String, ?parentFolder:String, allowGPU:Bool = true, checkMods:Bool = true):FlxAtlasFrames
	{
		final directPath = getPath('images/$key.png', parentFolder, checkMods).withoutExtension();
		
		final tempFrames = tempAtlasFramesCache.get(directPath);
		if (tempFrames != null)
		{
			return tempFrames;
		}
		
		final xmlPath = getPath('images/$key.xml', TEXT, parentFolder, checkMods);
		final txtPath = getPath('images/$key.txt', TEXT, parentFolder, checkMods);
		
		final graphic = image(key, parentFolder, allowGPU, checkMods);
		
		// sparrow
		if (FunkinAssets.exists(xmlPath))
		{
			// until flixel does null safety
			@:nullSafety(Off)
			{
				final frames = FlxAtlasFrames.fromSparrow(graphic, FunkinAssets.exists(xmlPath) ? FunkinAssets.getContent(xmlPath) : null);
				if (frames != null) tempAtlasFramesCache.set(directPath, frames);
				return frames;
			}
		}
		
		@:nullSafety(Off) // until flixel does null safety
		{
			final frames = FlxAtlasFrames.fromSpriteSheetPacker(graphic, FunkinAssets.exists(txtPath) ? FunkinAssets.getContent(txtPath) : null);
			if (frames != null) tempAtlasFramesCache.set(directPath, frames);
			return frames;
		}
	}
	
	static public function getMultiAtlas(keys:Array<String>, ?parentFolder:String = null, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		// wow
		var parentFrames:FlxAtlasFrames = Paths.getAtlas(keys[0], allowGPU);
		
		if (parentFrames == null) return null;
		if (keys.length > 1)
		{
			var original:FlxAtlasFrames = parentFrames;
			parentFrames = new FlxAtlasFrames(parentFrames.parent);
			parentFrames.addAtlas(original, true);
			for (i in 1...keys.length)
			{
				var extraFrames:FlxAtlasFrames = Paths.getAtlas(keys[i], parentFolder, allowGPU);
				
				if (extraFrames != null) parentFrames.addAtlas(extraFrames, true);
			}
		}
		
		return parentFrames;
	}
	
	public static inline function getSparrowAtlas(key:String, ?parentFolder:String, ?allowGPU:Bool = true, checkMods:Bool = true):FlxAtlasFrames
	{
		final directPath = getPath('images/$key.png', parentFolder, checkMods).withoutExtension();
		final tempFrames = tempAtlasFramesCache.get(directPath);
		if (tempFrames != null)
		{
			return tempFrames;
		}
		
		final xmlPath = getPath('images/$key.xml', parentFolder, checkMods);
		@:nullSafety(Off) // until flixel does null safety
		{
			final frames = FlxAtlasFrames.fromSparrow(image(key, parentFolder, allowGPU, checkMods), FunkinAssets.exists(xmlPath) ? FunkinAssets.getContent(xmlPath) : null);
			if (frames != null) tempAtlasFramesCache.set(directPath, frames);
			return frames;
		}
	}
	
	public static inline function getPackerAtlas(key:String, ?parentFolder:String, ?allowGPU:Bool = true, checkMods:Bool = true)
	{
		final directPath = getPath('images/$key.png', parentFolder, checkMods).withoutExtension();
		final tempFrames = tempAtlasFramesCache.get(directPath);
		if (tempFrames != null)
		{
			return tempFrames;
		}
		
		final txtPath = getPath('images/$key.txt', parentFolder, checkMods);
		@:nullSafety(Off) // until flixel does null safety
		{
			final frames = FlxAtlasFrames.fromSpriteSheetPacker(image(key, parentFolder, allowGPU, checkMods), FunkinAssets.exists(txtPath) ? FunkinAssets.getContent(txtPath) : null);
			if (frames != null) tempAtlasFramesCache.set(directPath, frames);
			return frames;
		}
	}
	
	inline static public function formatToSongPath(path:String)
	{
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;
		
		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}
	
	#if MODS_ALLOWED
	inline static public function mods(key:String = '')
	{
		return 'mods/' + key;
	}
	
	static public function modFolders(key:String)
	{
		if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
		{
			var fileToCheck:String = mods(Mods.currentModDirectory + '/' + key);
			if (FileSystem.exists(fileToCheck))
			{
				return fileToCheck;
			}
		}
		
		for (mod in Mods.getGlobalMods())
		{
			var fileToCheck:String = mods(mod + '/' + key);
			if (FileSystem.exists(fileToCheck)) return fileToCheck;
		}
		return 'mods/' + key;
	}
	#end
	
	#if flixel_animate
	public static function loadAnimateAtlas(spr:FlxAnimate, folder:String)
	{
		final path = Paths.getPath('images/$folder', null, true);
		
		// needs some more work for this to matter todo later
		var spriteFrames:Array<SpritemapInput> = null;
		// if (FileSystem.exists(path))
		// {
		// 	for (i in 1...11)
		// 	{
		// 		var spriteMapPath = '$path/spritemap$i';
		// 		if (FileSystem.exists(spriteMapPath + '.png'))
		// 		{
		// 			spriteFrames ??= [];
		// 			spriteFrames.push(
		// 				{
		// 					source: Paths.image(spriteMapPath),
		// 					json: File.getContent(spriteMapPath + '.json')
		// 				});
		// 		}
		// 	}
		// }
		
		spr.frames = animate.FlxAnimateFrames.fromAnimate(Paths.getPath('images/$folder', null, true), spriteFrames, null, null, false, {cacheOnLoad: true});
	}
	#end
}
