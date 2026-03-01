package funkin.backend;

import funkin.objects.Note;
import funkin.backend.StageData;
import funkin.backend.Song.SwagSong;

import flixel.util.FlxArrayUtil;

import openfl.display.BitmapData;

import sys.thread.Thread;
import sys.thread.Mutex;

import openfl.utils.Assets as OpenFlAssets;

// really bad but works sigh
class MTCacher
{
	private static var mutex:Mutex = new Mutex();
	private static var assetsLoadingLength:Int = 0;
	private static var finishedJobs:Int = 0;
	private static var succesfulJobs:Int = 0;
	
	private static var soundsToCache:Array<String> = [];
	private static var musicToCache:Array<String> = [];
	private static var imagesToCache:Array<String> = [];
	private static var songsToCache:Array<String> = [];
	
	public static var onCompleteCallback:Void->Void = null;
	
	public static function addToList(list:CacheList, asset:Array<String>)
	{
		switch (list)
		{
			case 'image':
				imagesToCache = imagesToCache.concat(asset);
			case 'music':
				musicToCache = musicToCache.concat(asset);
			case 'sound':
				soundsToCache = soundsToCache.concat(asset);
			case 'song':
				songsToCache = songsToCache.concat(asset);
		}
	}
	
	public static function initCacher()
	{
		assetsLoadingLength = soundsToCache.length + musicToCache.length + imagesToCache.length + songsToCache.length;
		
		for (i in songsToCache)
			initJob(() ->
				{
					// Paths.returnSound('songs/$i');
				});
		for (i in soundsToCache)
			initJob(() -> {
				Paths.sound(i);
			});
		for (i in musicToCache)
			initJob(() -> {
				Paths.music(i);
			});
		for (i in imagesToCache)
			initJob(() -> {
				var bitmap:BitmapData;
				var file:String = null;
				
				file = Paths.getPath('images/$i.png', IMAGE);
				if (FunkinAssets.cache.currentTrackedGraphics.exists(file)) return;
				else if (FunkinAssets.exists(file)) bitmap = FunkinAssets.getBitmapData(file);
			});
	}
	
	public static function loadSongData(songName:String, initiateOnCompletion:Bool = false)
	{
		var song = Paths.formatToSongPath(songName);
		addToList(SONG, ['$song/Inst']);
		addToList(SONG, ['$song/Voices']);
		// in the case we go back to cached uncomment //fix for chart editor sigh
		
		doMTJob(() -> {
			var songData:SwagSong = Song.loadFromJson(Highscore.formatSong(song.toLowerCase(), 1), song);
			var stageData:StageFile = StageData.getStageFile(songData.stage);
			if (stageData == null) stageData = StageData.dummy();
			
			var noteSkin:String = Note.defaultNoteSkin;
			if (songData.arrowSkin != null && songData.arrowSkin.length > 1) noteSkin = songData.arrowSkin;
			
			var customSkin:String = noteSkin + Note.getNoteSkinPostfix();
			if (Paths.fileExists('images/$customSkin.png', IMAGE)) noteSkin = customSkin;
			addToList(IMAGE, [noteSkin]);
			
			loadChar(songData.player1);
			loadChar(songData.player2);
			if (!stageData.hide_girlfriend) loadChar(songData.gfVersion);
			
			if (stageData.cache_directory != null && stageData.cache_directory != '') loadDirectory(Paths.getPath(stageData.cache_directory));
			if (stageData.assets_to_cache != null)
			{
				for (i in stageData.assets_to_cache)
				{
					var asset:String = cast i;
					resolveAndAdd(asset);
				}
			}
			
			// get the change char events and preload the char
			doMTJob(() -> {
				for (event in songData.events)
				{
					for (i in 0...event[1].length)
					{
						if (event[1][i][0] == 'Change Character')
						{
							trace(event[1][i][2]);
							loadChar(event[1][i][2], false);
						}
					}
				}
			});
			
			if (initiateOnCompletion) initCacher();
		});
	}
	
	static function resolveAndAdd(asset:String)
	{
		var ext = asset.substr(asset.length - 4, 4);
		switch (ext)
		{
			case '.png':
				addToList(IMAGE, [asset.substr(0, asset.length - 4)]);
			case '.ogg':
				for (i in [MUSIC, SOUND])
				{
					if (FunkinAssets.exists('assets/${i}/${asset}', openfl.utils.AssetType.SOUND))
					{
						addToList(i, [asset]);
						break;
					}
				}
		}
	}
	
	static function initJob(job:Void->Void, counted:Bool = true)
	{
		Thread.create(() -> {
			mutex.acquire();
			try
			{
				job();
				mutex.release();
				if (counted)
				{
					finishedJobs++;
					succesfulJobs++;
				}
			}
			catch (e)
			{
				mutex.release();
				trace('cachingFailed! kms. $e');
				if (counted) finishedJobs++;
			}
			
			if (counted) checkLoad();
		});
	}
	
	private static function checkLoad()
	{
		if (finishedJobs == assetsLoadingLength) onComplete();
	}
	
	private static function onComplete()
	{
		// okay so far this is actually like a little lie lol with the way it works but sh ig
		trace('cachingComplete. total jobs: ' + finishedJobs + ' successful jobs: ' + succesfulJobs);
		assetsLoadingLength = 0;
		finishedJobs = 0;
		succesfulJobs = 0;
		clear();
		
		if (onCompleteCallback != null) onCompleteCallback();
		onCompleteCallback = null;
	}
	
	private static function clear()
	{
		for (i in [songsToCache, musicToCache, imagesToCache, soundsToCache])
			FlxArrayUtil.clearArray(i);
	}
	
	// shortcut to initJob with out counting
	public static function doMTJob(func:Void->Void = null)
	{
		initJob(() -> {
			func();
		}, false);
	}
	
	public static function loadDirectory(directory:String, recursive:Bool = true)
	{
		if (!FileSystem.isDirectory(directory)) throw new haxe.Exception('$directory is not a real directory!');
		
		for (i in FileSystem.readDirectory(directory))
		{
			var path = haxe.io.Path.join([directory, i]);
			if (!FileSystem.isDirectory(path))
			{
				if (path.endsWith('.png'))
				{
					var imageToCache = path.substr(0, path.length - 4).replace('assets/images/', '');
					addToList(IMAGE, [imageToCache]);
					// trace('IMAGE FOUND: ' + imageToCache);
				}
				else if (path.endsWith('.ogg')) {}
			}
			else
			{
				if (FileSystem.isDirectory(path))
				{
					if (recursive)
					{
						trace('DIRECTORY: ' + path);
						loadDirectory(path);
					}
				}
			}
		}
	}
	
	public static function loadChar(char:String, addToLists:Bool = true)
	{
		doMTJob(() -> {
			var path:String = Paths.getPath('characters/$char.json', TEXT, null, true);
			var char = haxe.Json.parse(FunkinAssets.getContent(path));
			if (addToLists) addToList(IMAGE, [char.image]);
			// might remove this tbh
			else
			{
				var bitmap:BitmapData;
				var file:String = null;
				
				file = Paths.getPath('images/${char.image}.png', IMAGE);
				if (FunkinAssets.cache.currentTrackedGraphics.exists(file)) return;
				else if (FunkinAssets.exists(file)) bitmap = FunkinAssets.getBitmapData(file);
			}
		});
	}
}

enum abstract CacheList(String) to String from String
{
	public var IMAGE:String = 'image';
	public var MUSIC:String = 'music';
	public var SOUND:String = 'sound';
	public var SONG:String = 'song';
}
