package funkin.substates;

import flixel.util.FlxDestroyUtil;
import flixel.math.FlxRect;

import funkin.shaders.ChalkShader;

import flixel.input.mouse.FlxMouseEvent;

import funkin.shaders.DitherShader;
import funkin.backend.WeekData;
import funkin.backend.Highscore;
import funkin.backend.Song;

import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxStringUtil;

import funkin.states.StoryMenuState;
import funkin.options.OptionsState;

class PauseSubState extends MusicBeatSubstate
{
	public static var songName:Null<String> = null;
	
	var grpMenuShit:FlxTypedGroup<FlxText>;
	
	final menuItemsOG:Array<String> = ['resume', 'restart', 'change difficulty', 'options', 'exit'];
	
	var menuItems:Array<String> = [];
	var difficultyChoices:Array<String> = [];
	var curSelected:Int = 0;
	
	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:FlxText;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	
	var missingText:FlxText;
	var underline:FlxSprite;
	
	var ditherShader:DitherShader;
	
	override function create()
	{
		super.create();
		
		// for the time being we dont have other difficulties so we are forcing this
		if (Difficulty.list.length < 2) menuItemsOG.remove('change difficulty');
		
		if (PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'leave charting mode');
			
			var num:Int = 0;
			if (!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'skip time');
			}
			menuItemsOG.insert(3 + num, 'end song');
			menuItemsOG.insert(4 + num, 'toggle practice mode');
			menuItemsOG.insert(5 + num, 'toggle botplay');
		}
		menuItems = menuItemsOG;
		
		for (i in 0...Difficulty.list.length)
		{
			var diff:String = Difficulty.getString(i);
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');
		
		pauseMusic = new FlxSound();
		
		if (songName == null || songName.toLowerCase() != 'none')
		{
			if (songName == null)
			{
				if (ClientPrefs.data.pauseMusic) pauseMusic.loadEmbedded(Paths.music(Constants.PAUSE_MUSIC), true, true);
			}
			else pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		}
		
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		
		FlxG.sound.list.add(pauseMusic);
		
		cameras = [PlayState.SONG.song.toLowerCase() == 'expulsion' ? PlayState.instance.camOther : FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		
		var white = new FlxSprite().makeScaledGraphic(camera.width, camera.height);
		add(white);
		
		var bg = new FlxSprite(Paths.image('menus/wall'));
		bg.scale.scale(0.8);
		bg.updateHitbox();
		
		var board = new FlxSprite(Paths.image('menus/play/board'));
		board.scale.scale(0.6);
		board.updateHitbox();
		board.screenCenter();
		board.x += 20;
		
		var nubmers = new FlxSprite(Paths.image('menus/pause/numbers'));
		nubmers.scale.scale(0.6);
		nubmers.updateHitbox();
		nubmers.screenCenter();
		nubmers.x -= 28 - 20;
		nubmers.y -= 12;
		
		var currentSong = new BaldiText(0, 0, 0, CoolUtil.formatSongName(PlayState.instance.displaySongName));
		currentSong.screenCenter();
		currentSong.y = nubmers.y + 85;
		currentSong.shader = new ChalkShader();
		
		for (i in [bg, board, nubmers, currentSong])
		{
			add(i);
		}
		
		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);
		
		underline = new FlxSprite(Paths.image('menus/pause/line'));
		underline.scale.scale(0.6);
		underline.updateHitbox();
		add(underline);
		
		regenMenu();
		
		forEachOfType(FlxSprite, spr -> spr.scrollFactor.set());
		
		ditherShader = new DitherShader();
		ditherShader.transparency = 0;
		
		CoolUtil.addShader(ditherShader, camera);
		FlxTween.tween(ditherShader, {transparency: 1}, 0.25);
	}
	
	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5) pauseMusic.volume += 0.01 * elapsed;
		
		super.update(elapsed);
		
		if (controls.BACK)
		{
			close();
			return;
		}
		
		updateSkipTextStuff();
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}
		
		switch (menuItems[curSelected])
		{
			case 'skip time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}
				
				if (controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if (holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}
					
					if (curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if (curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}
		
		if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode))
		{
			pressedAOption();
		}
		
		if (PlayState.instance != null)
		{
			PlayState.instance.callOnScripts('onPauseUpdate', [elapsed]);
		}
	}
	
	function pressedAOption()
	{
		if (menuItems == difficultyChoices)
		{
			try
			{
				if (menuItems.length - 1 != curSelected && difficultyChoices.contains(menuItems[curSelected]))
				{
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					FlxG.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}
			}
			catch (e)
			{
				trace('ERROR! $e');
				
				return;
			}
			
			menuItems = menuItemsOG;
			regenMenu();
			
			return;
		}
		
		switch (menuItems[curSelected])
		{
			case "resume":
				FlxTween.cancelTweensOf(this);
				FlxTween.tween(ditherShader, {transparency: 0}, 0.25, {onComplete: Void -> close()});
				
			case 'change difficulty':
				menuItems = difficultyChoices;
				deleteSkipTimeText();
				regenMenu();
			case 'toggle practice mode':
				PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
				PlayState.changedDifficulty = true;
			case "restart":
				restartSong();
			case "leave charting mode":
				restartSong();
				PlayState.chartingMode = false;
			case 'skip time':
				if (curTime < Conductor.songPosition)
				{
					PlayState.startOnTime = curTime;
					restartSong(true);
				}
				else
				{
					if (curTime != Conductor.songPosition)
					{
						PlayState.instance.clearNotesBefore(curTime);
						PlayState.instance.setSongTime(curTime);
					}
					close();
				}
			case 'end song':
				close();
				
				PlayState.instance.killNotes();
				
				PlayState.instance.finishSong(true);
			case 'toggle botplay':
				PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
				PlayState.changedDifficulty = true;
				PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
				PlayState.instance.botplayTxt.alpha = 1;
				PlayState.instance.botplaySine = 0;
			case 'options':
				PlayState.instance.paused = true; // For lua
				PlayState.instance.vocals.volume = 0;
				FlxG.switchState(OptionsState.new);
				if (ClientPrefs.data.pauseMusic)
				{
					FlxG.sound.playMusic(Paths.music(Constants.PAUSE_MUSIC), pauseMusic.volume);
					FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
					FlxG.sound.music.time = pauseMusic.time;
				}
				OptionsState.onPlayState = true;
			case "exit":
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				
				Mods.loadTopMod();
				if (PlayState.isStoryMode) FlxG.switchState(funkin.states.StoryMenu.new);
				else FlxG.switchState(funkin.states.freeplay.FreeplayState.new);
				
				PlayState.cancelMusicFadeTween();
				FlxG.sound.playMusic(Paths.music(Constants.MENU_MUSIC));
				PlayState.changedDifficulty = false;
				PlayState.chartingMode = false;
				FlxG.camera.followLerp = 0;
		}
	}
	
	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;
		
		if (noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		FlxG.resetState();
	}
	
	override function destroy()
	{
		pauseMusic.destroy();
		CoolUtil.removeShader(ditherShader, this.camera);
		ditherShader = null;
		
		super.destroy();
	}
	
	var underlineTwn:Null<FlxTween> = null;
	
	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		
		for (item in grpMenuShit.members)
		{
			if (item.ID == curSelected)
			{
				underline.setGraphicSize(item.width, 8);
				underline.updateHitbox();
				underline.setPosition(item.x, item.y + item.height);
				
				if (item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
		
		underline.clipRect ??= new FlxRect(0, 0, underline.frameWidth, underline.frameHeight);
		
		underlineTwn?.cancel();
		
		underline.clipRect.width = 0;
		underline.clipRect = underline.clipRect;
		underlineTwn = FlxTween.tween(underline.clipRect, {width: underline.frameWidth}, 0.1, {onUpdate: Void -> underline.clipRect = underline.clipRect, onComplete: Void -> underline.clipRect = underline.clipRect});
	}
	
	function regenMenu():Void
	{
		for (i in 0...grpMenuShit.members.length)
		{
			var obj = grpMenuShit.members[0];
			
			grpMenuShit.remove(obj, true);
			
			obj = FlxDestroyUtil.destroy(obj);
		}
		
		var spacing = menuItems.length * 10;
		for (i in 0...menuItems.length)
		{
			var item = new BaldiText(0, 0, 0, menuItems[i], 40);
			item.screenCenter();
			item.y += ((100 - (spacing / 2)) * (i - (menuItems.length / 2))) + spacing;
			item.ID = i;
			grpMenuShit.add(item);
			
			item.shader = new ChalkShader();
			
			if (menuItems[i] == 'skip time')
			{
				skipTimeText = new BaldiText(0, 0, 0, '', 40);
				skipTimeText.scrollFactor.set();
				skipTimeTracker = item;
				add(skipTimeText);
				
				updateSkipTextStuff();
				updateSkipTimeText();
			}
		}
		
		curSelected = 0;
		changeSelection();
	}
	
	inline function updateSkipTextStuff()
	{
		if (skipTimeText == null || skipTimeTracker == null) return;
		
		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}
	
	inline function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false)
			+ ' / '
			+ FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
	
	inline function deleteSkipTimeText()
	{
		remove(skipTimeText, true);
		
		skipTimeText = FlxDestroyUtil.destroy(skipTimeText);
		
		skipTimeText = null;
		skipTimeTracker = null;
	}
}
