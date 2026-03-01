package funkin.states;

import flixel.addons.transition.FlxTransitionableState;

import funkin.game.VideoCutscene;
import funkin.backend.MusicBeatUIState;
import funkin.backend.WeekData;

class StoryMenu extends MusicBeatUIState
{
	static var firstTime:Bool = true;
	static var lastDifficultyName:String = '';
	
	var curDifficulty:Int = 1;
	
	var select:FlxSprite;
	
	var selectHB:FlxSprite;
	var canSelect:Bool = true;
	
	var playingIntro:Bool = true;
	
	var sign:FlxSprite;
	
	var difficultySpr:FlxSprite;
	
	override function create()
	{
		WeekData.reloadWeekFiles(true);
		
		to1080P = true;
		
		final direct:String = 'menus/story/';
		
		var sky = new FlxSprite(Paths.image('${direct}sky'));
		add(sky);
		
		var clouds = new FlxSprite(Paths.image('${direct}clouds'));
		add(clouds);
		clouds.scale.set(1.05, 1.05);
		
		var school = new FlxSprite(Paths.image('${direct}school'));
		add(school);
		
		select = new FlxSprite().loadSparrowFrames('${direct}start');
		select.animation.addByPrefix('i', 'i');
		select.animation.addByPrefix('p', 'p');
		select.animation.play('i');
		add(select);
		
		selectHB = new FlxSprite(713, 892).makeScaledGraphic(524, 117);
		selectHB.visible = false;
		
		sign = new FlxSprite(1345, 505, Paths.image(direct + 'sign'));
		add(sign);
		
		difficultySpr = new FlxSprite();
		add(difficultySpr);
		
		final videoCamera = new FlxCamera();
		videoCamera.bgColor = 0x0;
		FlxG.cameras.add(videoCamera, false);
		
		super.create();
		
		Difficulty.resetList();
		if (lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefault();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		changeDiff();
		
		// intro anim below
		if (firstTime)
		{
			firstTime = false;
			sky.scale.set(3, 3);
			clouds.scale.set(2, 2);
			
			sign.y += camera.viewHeight;
			select.y += camera.viewHeight;
			school.y += camera.viewHeight;
			
			FlxG.camera.fade(FlxColor.BLACK, 6, true);
			
			FlxTween.tween(clouds.scale, {x: 1.05, y: 1.05}, 6, {ease: FlxEase.smoothStepOut});
			FlxTween.tween(sky.scale, {x: 1, y: 1}, 6,
				{
					ease: FlxEase.smoothStepOut,
					onUpdate: Void -> {
						sky.updateHitbox();
					}
				});
				
			FlxTween.tween(sign, {y: 505}, 6, {ease: FlxEase.smoothStepOut});
			
			FlxTween.tween(school, {y: 0}, 6, {ease: FlxEase.smoothStepOut});
			FlxTween.tween(select, {y: 0}, 6,
				{
					ease: FlxEase.smoothStepOut,
					onComplete: Void -> {
						playingIntro = false;
					}
				});
		}
		else
		{
			playingIntro = false;
		}
	}
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume > 0) FlxG.sound.music.volume -= 0.125 * elapsed;
		if (canSelect)
		{
			if (!playingIntro)
			{
				if (controls.ACCEPT) selected();
				else if (FlxG.mouse.overlaps(selectHB) && FlxG.mouse.visible)
				{
					if (select.animation.curAnim.name != 'p' && canSelect) FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					select.animation.play('p');
					
					if (FlxG.mouse.justPressed) selected();
				}
				else
				{
					select.animation.play('i');
				}
			}
			
			if (controls.BACK || FlxG.mouse.justPressedRight)
			{
				canSelect = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.switchState(() -> new PlayMenuState());
			}
			
			if (controls.UI_DOWN_P || controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeDiff(controls.UI_DOWN_P ? 1 : -1);
			}
			else if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeDiff(-FlxG.mouse.wheel);
			}
			// direct changes here.
			else if (FlxG.mouse.justMoved)
			{
				if (curDifficulty != 0 && FlxG.mouse.x > (sign.x + 27) && FlxG.mouse.y > (sign.y + 54) && FlxG.mouse.x < (sign.x + 27 + 237) && FlxG.mouse.y < (sign.y + 54 + 101))
				{
					// easy
					curDifficulty = 0;
					changeDiff();
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				}
				else if (curDifficulty != 1 && FlxG.mouse.x > (sign.x + 19) && FlxG.mouse.y > (sign.y + 184) && FlxG.mouse.x < (sign.x + 19 + 230) && FlxG.mouse.y < (sign.y + 184 + 76))
				{
					// normal
					curDifficulty = 1;
					changeDiff();
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				}
				// else if (curDifficulty != 2 && FlxG.mouse.x > (sign.x + 10) && FlxG.mouse.y > (sign.y + 293) && FlxG.mouse.x < (sign.x + 10 + 210) && FlxG.mouse.y < (sign.y + 293 + 96))
				// {
				// 	// hard
				// 	curDifficulty = 2;
				// 	changeDiff();
				// 	FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				// }
			}
		}
		
		switch (curDifficulty) // hacky.
		{
			case 0:
				difficultySpr.x = sign.x + 13;
				difficultySpr.y = sign.y + 42;
				
			case 1:
				difficultySpr.x = sign.x + 11;
				difficultySpr.y = sign.y + 159;
				
			case 2:
				difficultySpr.x = sign.x + 9;
				difficultySpr.y = sign.y + 254;
		}
		
		super.update(elapsed);
	}
	
	function selected()
	{
		canSelect = false;
		
		VideoCutscene.load('basics', () -> {
			FlxTransitionableState.skipNextTransIn = true;
			loadIntoSong();
		});
		FlxTween.tween(FlxG.camera, {zoom: 3, "scroll.y": FlxG.camera.scroll.y + 50}, 0.6,
			{
				ease: FlxEase.expoIn,
				onComplete: Void -> {
					FlxG.camera.visible = false;
					FlxG.mouse.visible = false;
					//
					
					FlxG.sound.music.stop();
					if (!VideoCutscene.playVideo(true))
					{
						loadIntoSong();
					}
				}
			});
	}
	
	function loadIntoSong()
	{
		var weekData = WeekData.weeksLoaded.get(WeekData.weeksList[0]);
		
		var playlist:Array<String> = [for (i in weekData.songs) i[0]];
		
		try
		{
			final songLowercase:String = Paths.formatToSongPath(playlist[0]);
			final poop:String = funkin.backend.Highscore.formatSong(songLowercase, curDifficulty);
			
			PlayState.storyPlaylist = playlist;
			PlayState.SONG = funkin.backend.Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = true;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = 0;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			FlxG.sound.music.volume = 0;
			
			FlxTimer.wait(0.1, () -> {
				CoolUtil.switchStateAndStopMusic(() -> new PlayState(), true);
			});
		}
		catch (e)
		{
			trace(e);
		}
	}
	
	function changeDiff(diff:Int = 0)
	{
		curDifficulty = FlxMath.wrap(curDifficulty + diff, 0, Difficulty.list.length - 1);
		
		lastDifficultyName = Difficulty.getString(curDifficulty);
		
		difficultySpr.loadGraphic(Paths.image('menus/story/${lastDifficultyName.toLowerCase()}'));
	}
}
