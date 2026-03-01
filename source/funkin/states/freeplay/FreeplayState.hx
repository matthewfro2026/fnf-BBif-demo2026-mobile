package funkin.states.freeplay;

import flixel.group.FlxContainer;
import flixel.system.FlxBGSprite;

import funkin.shaders.ChalkShader;

import extensions.flixel.FlxUniformSprite;

import flixel.util.FlxDestroyUtil;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.graphics.tile.FlxGraphicsShader;

import openfl.media.Sound;
import openfl.Assets;

import flixel.util.FlxStringUtil;
import flixel.util.FlxBitmapDataUtil;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.math.FlxRect;

import funkin.game.Story;

import extensions.flixel.FlxSkewedText;

import funkin.shaders.DitherShader;
import funkin.backend.Song;
import funkin.backend.Highscore;
import funkin.backend.WeekData;
import funkin.backend.MusicBeatUIState;
import funkin.objects.OffsetSprite;
import funkin.states.freeplay.LessonPopUp;
import funkin.states.freeplay.PaldoPopUp;

@:access(flixel.FlxCamera)
@:access(flixel.text)
class FreeplayState extends MusicBeatUIState
{
	static var initialized:Bool = false;
	
	static var curSel:Int = 0;
	
	static var lastDifficulty:String = Difficulty.getDefault();
	
	var curDifficulty:Int = -1;
	
	var selectedMusic:Int = -1;
	
	var canInteract:Bool = true;
	
	var songMetas:FlxTypedGroup<BaldiSongData>;
	var jukeBox:Jukebox;
	
	var noiseShader:WhiteNoiseShader;
	
	var skewedText:FlxSkewedText;
	
	var scoreUnderlay:FlxSprite;
	var scoreText:BaldiText;
	
	var ditherShader:DitherShader;
	var ditherTween:FlxTween = null;
	
	var monitor:Monitor;
	
	var camHUD:FlxCamera;
	
	final gradeFormat:FlxTextFormat = new FlxTextFormat(0xFFFFFFFF, false, false, 0x0);
	
	override function create()
	{
		persistentUpdate = true;
		to1080P = true;
		
		FlxG.camera.zoom += 0.025;
		
		FlxG.camera.antialiasing = true;
		
		camHUD = new FlxCamera();
		camHUD.bgColor = 0x0;
		FlxG.cameras.add(camHUD, false);
		MusicBeatUIState.setCamTo1080(camHUD);
		
		Difficulty.resetList();
		WeekData.reloadWeekFiles(false);
		
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the freeplay", null, null, 'freeplay');
		#end
		
		var bg = new FlxSprite(Paths.image('menus/freeplay/backrooms'));
		add(bg);
		
		FlxG.camera.setScrollBounds(bg.x, bg.width, bg.y, bg.height);
		
		noiseShader = new WhiteNoiseShader();
		
		jukeBox = new Jukebox(863, 719);
		add(jukeBox);
		
		monitor = new Monitor();
		add(monitor);
		
		songMetas = new FlxTypedGroup<BaldiSongData>();
		monitor.songsDrawLayer.add(songMetas);
		
		for (i in 0...WeekData.weeksList.length)
		{
			var curWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			
			WeekData.setDirectoryFromWeek(curWeek);
			
			for (song in curWeek.songs)
			{
				songMetas.add(new BaldiSongData(song[0], song[1], FlxColor.fromRGB(song[2][0], song[2][1], song[2][2])));
			}
		}
		
		skewedText = new FlxSkewedText(0, 0, jukeBox.width - 50, 'penis', 60);
		skewedText.font = Paths.font('comic.ttf');
		add(skewedText);
		skewedText.skew.set(-22.5, 14);
		skewedText.alignment = CENTER;
		skewedText.borderStyle = SHADOW;
		skewedText.borderColor = 0xFF5C5C5C;
		skewedText.setBorderStyle(SHADOW_XY(4, 4));
		
		scoreUnderlay = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		scoreUnderlay.alpha = 0.6;
		add(scoreUnderlay);
		scoreUnderlay.cameras = [camHUD];
		
		scoreText = new BaldiText(0, 25, RIGHT);
		add(scoreText);
		scoreText.addFormat(gradeFormat);
		scoreText.cameras = [camHUD];
		
		ditherShader = new DitherShader();
		ditherShader.transparency = -1;
		jukeBox.diffText.shader = skewedText.shader = scoreUnderlay.shader = scoreText.shader = ditherShader;
		
		if (initialized)
		{
			changeSel();
			FlxTween.tween(ditherShader, {transparency: 1}, 0.25, {startDelay: 0.5});
		}
		else
		{
			playIntro();
			var diffColour = getDiffColour(lastDifficulty.toLowerCase());
			diffColour.saturation *= 0.8;
			jukeBox.diffText.color = diffColour;
			jukeBox.diffUp.color = jukeBox.diffText.color;
			jukeBox.diffDown.color = jukeBox.diffText.color;
		}
		
		curDifficulty = FlxMath.maxInt(0, Difficulty.defaultList.indexOf(lastDifficulty));
		
		super.create();
	}
	
	function playIntro()
	{
		monitor.offset2.y = -monitor.height;
		jukeBox.offset2.x = FlxG.width;
		
		CoolUtil.playUISound('freeplay/jukebox-funkypop', 0.4);
		FlxTween.tween(jukeBox, {'offset2.x': 0}, 0.6, {ease: FlxEase.cubeOut, framerate: 24});
		
		FlxTimer.wait(0.8, () -> {
			CoolUtil.playUISound('freeplay/screenComeDown-funkypop');
			
			function onFinish(?_)
			{
				noiseShader.ratio = 1;
				initialized = true;
				changeSel();
				
				FlxTween.tween(ditherShader, {transparency: 1}, 0.25, {startDelay: 0.5});
			}
			
			FlxTween.tween(monitor, {'offset2.y': 40}, 0.8,
				{
					framerate: 24,
					onComplete: Void -> {
						FlxTween.tween(monitor, {'offset2.y': 0}, 0.3, {ease: FlxEase.backOut, framerate: 24, onComplete: onFinish});
					}
				});
				
			// FlxTween.tween(monitor, {'scale.x': 1.05, 'scale.y': 1.05}, 0.3, {ease: FlxEase.cubeInOut, startDelay: 0.4});
		});
	}
	
	function cameraMovement(e:Float)
	{
		final baseX = (1920 - FlxG.width) / 2;
		final baseY = (1080 - FlxG.height) / 2;
		
		final desX = baseX + ((FlxG.mouse.viewX - (FlxG.width / 2)) / 30);
		final desY = baseY + ((FlxG.mouse.viewY - (FlxG.height / 2)) / 30);
		
		final lerpRate = FlxMath.getElapsedLerp(0.06, e);
		
		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, desX, lerpRate);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, desY, lerpRate);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		cameraMovement(elapsed);
		
		if (FlxG.sound.music != null
			&& selectedMusic == -1
			&& FlxG.sound.music.volume < Constants.MAX_MUSIC_VOLUME) FlxG.sound.music.volume += 0.125 * elapsed;
			
		noiseShader.ratio = MathUtil.decayLerp(noiseShader.ratio, 0, 4, elapsed);
		noiseShader.update(elapsed);
		
		if (initialized && canInteract)
		{
			// ur hovering the fucking thign or ehwtevver
			final lerpValue = (FlxG.mouse.x > 172 && FlxG.mouse.x < 841 && FlxG.mouse.y > 360 && FlxG.mouse.y < 970) ? 0.035 : 0.025;
			FlxG.camera.zoom = MathUtil.decayLerp(FlxG.camera.zoom, (1280 / 1920) + lerpValue, 3, elapsed);
			
			if (FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(jukeBox.diffDown))
				{
					changeDiff(1);
					jukeBox.diffDown.scale.set(1.05, 1.05);
				}
				if (FlxG.mouse.overlaps(jukeBox.diffUp))
				{
					changeDiff(-1);
					jukeBox.diffUp.scale.set(1.05, 1.05);
				}
				else if (FlxG.mouse.overlaps(monitor.leftButton))
				{
					monitor.leftButton.animation.play('click');
					changeSel(-1);
				}
				else if (FlxG.mouse.overlaps(monitor.rightButton))
				{
					monitor.rightButton.animation.play('click');
					changeSel(1);
				}
				else if (FlxG.mouse.overlaps(monitor.centerButton))
				{
					monitor.animateAccept();
					pressedAccept();
				}
			}
			else if (FlxG.mouse.justReleased)
			{
				monitor.leftButton.animation.play('idle');
				monitor.rightButton.animation.play('idle');
				
				jukeBox.diffUp.scale.set(1, 1);
				jukeBox.diffDown.scale.set(1, 1);
			}
			
			if (controls.BACK)
			{
				CoolUtil.playUISound('cancelMenu');
				canInteract = false;
				FlxG.switchState(() -> new PlayMenuState());
			}
			else if (FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new funkin.substates.GameplayChangersSubstate());
			}
			else if (FlxG.keys.justPressed.SPACE
				|| (FlxG.mouse.overlaps(jukeBox) && FlxG.mouse.justPressed) #if !debug && !songMetas.members[curSel].isHidden #end)
			{
				if (selectedMusic != curSel) loadMusic();
				else pauseMusic();
			}
			else if (controls.ACCEPT)
			{
				monitor.animateAccept();
				
				pressedAccept();
			}
			
			if (controls.UI_LEFT_P)
			{
				monitor.leftButton.animation.play('click');
				
				changeSel(-1);
			}
			else if (controls.UI_LEFT_R)
			{
				monitor.leftButton.animation.play('idle');
			}
			
			if (controls.UI_RIGHT_P)
			{
				monitor.rightButton.animation.play('click');
				changeSel(1);
			}
			else if (controls.UI_RIGHT_R)
			{
				monitor.rightButton.animation.play('idle');
			}
			
			if (controls.UI_DOWN_P)
			{
				changeDiff(1);
				jukeBox.diffDown.scale.set(1.05, 1.05);
			}
			else if (controls.UI_DOWN_R)
			{
				jukeBox.diffDown.scale.set(1, 1);
			}
			
			if (controls.UI_UP_P)
			{
				changeDiff(-1);
				jukeBox.diffUp.scale.set(1.05, 1.05);
			}
			else if (controls.UI_UP_R)
			{
				jukeBox.diffUp.scale.set(1, 1);
			}
		}
		
		updatePos();
	}
	
	inline function updatePos()
	{
		skewedText.x = jukeBox.x;
		skewedText.y = jukeBox.y + 220;
		skewedText.alpha = initialized ? 1 : 0; // make it dither in
		
		scoreText.x = 1920 - 50 - scoreText.width;
		
		scoreUnderlay.scale.x = scoreText.width + 30;
		scoreUnderlay.x = scoreText.x - 15;
		scoreUnderlay.scale.y = scoreText.height + 30;
		scoreUnderlay.y = scoreText.y - 15;
		scoreUnderlay.updateHitbox();
	}
	
	function loadMusic()
	{
		var path = Paths.getPath('songs/' + Paths.formatToSongPath(songMetas.members[curSel].songName), MUSIC);
		
		#if debug
		path = path.replace(Paths.core, 'assets');
		#end
		
		if (FlxG.sound.music.playing) FlxG.sound.music.fadeTween?.cancel();
		
		try
		{
			var inst = Assets.getMusic(path + '/Inst.ogg');
			FlxG.sound.playMusic(inst, 1, false);
		}
		catch (e)
		{
			trace(e);
			return;
		}
		
		FlxG.sound.music.onComplete = pauseMusic;
		
		jukeBox.animation.play('resume');
		
		selectedMusic = curSel;
	}
	
	function pauseMusic()
	{
		selectedMusic = -1;
		jukeBox.animation.play('paused');
		
		FlxG.sound.playMusic(Paths.music(Constants.MENU_MUSIC), 0);
		FlxG.sound.music.fadeIn(1, 0, 0.7);
	}
	
	function changeSel(diff:Int = 0)
	{
		if (diff != 0)
		{
			CoolUtil.playUISound('freeplay/change-funkypop');
			CoolUtil.playUISound('freeplay/staticSfx', 0.6);
		}
		
		skewedText.shader = ditherShader;
		noiseShader.ratio = 1;
		
		getTarget().alpha = 0; // hide the last
		
		curSel = FlxMath.wrap(curSel + diff, 0, songMetas.length - 1);
		
		var curMeta = getTarget();
		
		curMeta.shader = noiseShader;
		
		curMeta.alpha = 1;
		curMeta.animation.play(curMeta.songName, true);
		
		//
		Mods.currentModDirectory = curMeta.folder;
		PlayState.storyWeek = curMeta.week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = curMeta.lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficulty);
		
		if (savedDiff != null
			&& !Difficulty.list.contains(savedDiff)
			&& Difficulty.list.contains(savedDiff)) curDifficulty = FlxMath.maxInt(0, Difficulty.list.indexOf(savedDiff));
		else if (lastDiff > -1) curDifficulty = lastDiff;
		else if (Difficulty.list.contains(Difficulty.getDefault())) curDifficulty = FlxMath.maxInt(0, Difficulty.defaultList.indexOf(Difficulty.getDefault()));
		else curDifficulty = 0;
		
		changeDiff();
		//
		
		monitor.updateFcSticker(curMeta, curDifficulty);
		//
		
		skewedText.text = curMeta.getSongName();
		
		refreshSongFormat();
		
		// trace('score: '
		// 	+ Highscore.getScore(curMeta.songName, curDifficulty)
		// 	+ ' rating: '
		// 	+ Highscore.getRating(curMeta.songName, curDifficulty));
		
		updateScoreText();
		
		#if debug
		trace(FlxStringUtil.formatBytes(FlxBitmapDataUtil.getMemorySize(curMeta.graphic.bitmap)));
		#end
	}
	
	public function changeDiff(diff:Int = 0)
	{
		if (diff != 0)
		{
			CoolUtil.playUISound('freeplay/change-funkypop');
		}
		
		curDifficulty = FlxMath.wrap(curDifficulty + diff, 0, Difficulty.list.length - 1);
		lastDifficulty = Difficulty.getString(curDifficulty);
		
		jukeBox.diffText.text = lastDifficulty.toLowerCase();
		
		var diffColour = getDiffColour(lastDifficulty.toLowerCase());
		diffColour.saturation *= 0.8;
		jukeBox.diffText.color = diffColour;
		jukeBox.diffUp.color = jukeBox.diffText.color;
		jukeBox.diffDown.color = jukeBox.diffText.color;
		
		monitor.updateFcSticker(getTarget(), curDifficulty);
		
		updateScoreText();
	}
	
	function updateScoreText()
	{
		if (getTarget().songName == 'Lesson')
		{
			// scoreText.text = "YSP's: " + '?' + '\nGRADE: ' + '?';
			scoreText.text = 'Press ACCEPT to see\nyour score\'s!';
			
			scoreText._formatRanges[0].range.start = 5;
			
			scoreText._formatRanges[0].range.end = 12;
			
			gradeFormat.format.color = FlxColor.LIME;
			
			return;
		}
		final grade = getGrade(Highscore.getRating(getTarget().songName, curDifficulty));
		
		scoreText.text = "YSP's: " + getScore(getTarget().songName) + '\nGRADE: ' + grade;
		
		gradeFormat.format.color = getGradeColour(grade);
		
		scoreText._formatRanges[0].range.start = scoreText.text.length - grade.length;
		
		scoreText._formatRanges[0].range.end = scoreText.text.length;
	}
	
	function refreshSongFormat()
	{
		skewedText.color = getTarget().textColour;
		
		skewedText.clearFormats();
		
		var colour = skewedText.color;
		colour.brightness *= 0.5;
		skewedText.borderColor = colour;
	}
	
	function pressedAccept()
	{
		final songName:String = getTarget().songName;
		
		if (songName == 'Lesson')
		{
			canInteract = false;
			openSubState(new LessonPopUp());
			return;
		}
		if (songName == 'Firewall')
		{
			canInteract = false;
			openSubState(new PaldoPopUp());
			return;
		}
		loadSong(songName);
	}
	
	function loadSong(songName:String, autoload:Bool = true)
	{
		var curSong:String = Paths.formatToSongPath(songName);
		var curSongPrev = curSong;
		
		var json:String = Highscore.formatSong(curSong, curDifficulty);
		
		try
		{
			PlayState.SONG = Song.loadFromJson(json, curSongPrev);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
		}
		catch (e)
		{
			var errorStr:String = e.toString();
			if (errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length - 1);
			
			lime.app.Application.current.window.alert(errorStr, 'ERROR LOADING CHART');
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}
		
		canInteract = false;
		
		// if (ClientPrefs.data.multithreading) MTCacher.loadsongMetas(curSong, true);
		
		if (autoload) exitIntoSong();
	}
	
	function exitIntoSong()
	{
		CoolUtil.playUISound('freeplay/ding goodiebag rizz at the wawa');
		
		FlxG.sound.music.fadeOut(1.2);
		
		FlxTween.tween(ditherShader, {transparency: -1}, 0.4);
		
		final options:TweenOptions = {startDelay: 0.2, ease: FlxEase.sineIn, framerate: 24};
		
		FlxTween.tween(monitor, {'offset2.y': -monitor.height}, 1.2, options);
		FlxTween.tween(getTarget(), {'offset2.y': -monitor.height}, 1.2, options);
		
		FlxTween.tween(jukeBox, {'offset2.x': FlxG.width}, 0.8, {startDelay: 0.5, framerate: 24});
		
		FlxTimer.wait(0.6, () -> {
			FlxG.camera._fxFadeColor = FlxColor.BLACK;
			FlxTween.tween(FlxG.camera, {_fxFadeAlpha: 1}, 0.9,
				{
					onComplete: Void -> CoolUtil.switchStateAndStopMusic(() -> new PlayState())
				});
		});
	}
	
	override function startOutro(onOutroComplete:() -> Void)
	{
		FlxG.sound.music.onComplete = null;
		
		super.startOutro(onOutroComplete);
	}
	
	inline function getDiffColour(diff:String):FlxColor
	{
		return switch (diff)
		{
			case 'hard': FlxColor.RED;
			
			case 'normal': FlxColor.YELLOW;
			
			default: FlxColor.LIME;
		}
	}
	
	inline function getGradeColour(rate:String):FlxColor
	{
		return switch (rate)
		{
			case 'A++' | 'A+' | 'A' | 'B+' | 'B': FlxColor.LIME;
			case 'C+' | 'C': FlxColor.YELLOW;
			case 'D+' | 'D': FlxColor.ORANGE;
			case 'F': FlxColor.RED;
			default: FlxColor.WHITE;
		}
	}
	
	inline function getGrade(rating:Float):String
	{
		if (rating == 0.0) return '?';
		
		var ratingName = PlayState.ratingStuff[PlayState.ratingStuff.length - 1][0]; // Uses last string
		if (rating < 1)
		{
			for (i in 0...PlayState.ratingStuff.length - 1)
			{
				if (rating < PlayState.ratingStuff[i][1])
				{
					ratingName = PlayState.ratingStuff[i][0];
					break;
				}
			}
		}
		
		return ratingName;
	}
	
	inline function getScore(songName:String):String
	{
		final score = Highscore.getScore(songName, curDifficulty);
		if (score == 0.0) return '?';
		
		return FlxStringUtil.formatMoney(score, false);
	}
	
	inline function getTarget():BaldiSongData return songMetas.members[curSel];
}

class BaldiSongData extends OffsetSprite
{
	static final missing:String = 'unknown';
	
	public var textColour:FlxColor = FlxColor.WHITE;
	
	public var songName:String = "";
	public var week:Int = 0;
	public var folder:String = "";
	public var lastDifficulty:String = null;
	
	public var isHidden(get, never):Bool;
	
	function get_isHidden():Bool
	{
		#if debug return false; #end
		
		if (songName == 'Lesson') // u r hell
		{
			if (Highscore.getScore(songName + '-good', 0) != 0) return false;
			if (Highscore.getScore(songName + '-good', 1) != 0) return false;
			// if (Highscore.getScore(songName + '-good', 2) != 0) return false;
		}
		
		if (Highscore.getScore(songName, 0) != 0) return false;
		if (Highscore.getScore(songName, 1) != 0) return false;
		// if (Highscore.getScore(songName, 2) != 0) return false;
		
		return true;
	}
	
	public function new(song:String, week:Int, color:FlxColor = FlxColor.WHITE)
	{
		this.textColour = color;
		this.songName = song;
		this.week = week;
		this.folder = Mods.currentModDirectory ?? '';
		
		super(208, 410);
		alpha = 0.00001;
		var filePath = 'menus/freeplay/songs/${songName.toLowerCase()}';
		if (!Paths.fileExists('images/$filePath.png', TEXT)) filePath = 'menus/freeplay/songs/$missing';
		if (isHidden) filePath = 'menus/freeplay/songs/$missing';
		
		frames = Paths.getSparrowAtlas(filePath);
		animation.addByPrefix(songName, filePath.contains(songName.toLowerCase()) ? songName.toLowerCase() : missing, isHidden ? 20 : 24);
		animation.play(songName);
		
		if (width < 620) // rescaled
		{
			setGraphicSize(628, 472);
			updateHitbox();
		}
	}
	
	public function getSongName():String return isHidden ? '???' : songName;
}

private class WhiteNoiseShader extends FlxGraphicsShader
{
	public var ratio(default, set):Float = 0;
	
	function set_ratio(value:Float):Float
	{
		return ratio = this.u_ratio.value[0] = value;
	}
	
	@:glFragmentSource('
	#pragma header

	uniform float iTime;
	uniform float u_ratio;

	float noise2d(vec2 co)
    {
	  return fract(sin(dot(co.xy, vec2(1.0, 73.0))) * 43758.5453);
	}
	
	void main()
	{
		vec2 uv = openfl_TextureCoordv;

        vec2 size = openfl_TextureSize.xy / 4.0;

        uv = floor(uv * size) / size;

		uv *= sin(iTime);

		vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);

        vec3 noise = vec3(noise2d(uv), noise2d(uv * 1.1), noise2d(uv * 0.9));

        tex.rgb = mix(tex.rgb, vec3(-0.5) + noise, u_ratio * tex.a);


		gl_FragColor = tex;
		
	}

	')
	public function new(ratio:Float = 0)
	{
		super();
		
		this.iTime.value = [0, 0];
		
		this.u_ratio.value = [ratio];
		this.ratio = ratio;
	}
	
	public function update(elapsed:Float)
	{
		this.iTime.value[0] += elapsed;
	}
}

private class Monitor extends OffsetSprite
{
	public var songsDrawLayer:FlxContainer;
	
	public var leftButton:OffsetSprite;
	
	public var rightButton:OffsetSprite;
	
	public var centerButton:OffsetSprite;
	
	public var fcSticker:OffsetSprite;
	
	public var lastMeta:Null<BaldiSongData> = null;
	
	var lastRank:FcRank = SDCB;
	
	public function new()
	{
		super();
		
		frames = Paths.getSparrowAtlas('menus/freeplay/yctp');
		animation.addByPrefix('i', 'YCTP', 24);
		animation.play('i');
		
		leftButton = new OffsetSprite();
		leftButton.frames = Paths.getSparrowAtlas('menus/freeplay/prev');
		leftButton.animation.addByPrefix('idle', 'prev0', 24);
		leftButton.animation.addByPrefix('click', 'prevclick', 24);
		
		rightButton = new OffsetSprite();
		rightButton.frames = Paths.getSparrowAtlas('menus/freeplay/next');
		rightButton.animation.addByPrefix('idle', 'next0', 24);
		rightButton.animation.addByPrefix('click', 'nextclick', 24);
		
		centerButton = new OffsetSprite(Paths.image('menus/freeplay/powerLight'));
		centerButton.alpha = 0;
		
		fcSticker = new OffsetSprite();
		fcSticker.frames = Paths.getSparrowAtlas('menus/freeplay/sticker');
		fcSticker.animation.addByIndices('fc', 'fc0', [0, 0, 0, 1, 2, 3, 3, 4, 4, 4, 5], '', 20, false);
		fcSticker.animation.addByIndices('pfc', 'pfc0', [0, 0, 0, 1, 2, 3, 3, 4, 4, 4, 5], '', 20, false);
		fcSticker.animation.addByIndices('removefc', 'fcOff', [0, 1, 2, 3, 4, 4, 4], '', 20, false);
		fcSticker.animation.addByIndices('removepfc', 'pfcOff', [0, 1, 2, 3, 4, 4, 4], '', 20, false);
		
		fcSticker.animation.onFinish.add(anim -> {
			if (anim.contains('remove')) fcSticker.visible = false;
		});
		
		songsDrawLayer = new FlxContainer();
	}
	
	override function destroy()
	{
		super.destroy();
		
		songsDrawLayer = FlxDestroyUtil.destroy(songsDrawLayer);
		leftButton = FlxDestroyUtil.destroy(leftButton);
		rightButton = FlxDestroyUtil.destroy(rightButton);
		centerButton = FlxDestroyUtil.destroy(centerButton);
		fcSticker = FlxDestroyUtil.destroy(fcSticker);
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		leftButton.update(elapsed);
		rightButton.update(elapsed);
		centerButton.update(elapsed);
		fcSticker.update(elapsed);
		songsDrawLayer.update(elapsed);
		
		centerButton.alpha = MathUtil.decayLerp(centerButton.alpha, 0, 12, elapsed);
		
		updateStickerState();
	}
	
	override function draw()
	{
		super.draw();
		
		leftButton.scale.copyFrom(scale);
		rightButton.scale.copyFrom(scale);
		centerButton.scale.copyFrom(scale);
		fcSticker.scale.copyFrom(scale);
		
		leftButton.updateHitbox();
		rightButton.updateHitbox();
		centerButton.updateHitbox();
		fcSticker.updateHitbox();
		
		leftButton.offset2.copyFrom(offset2);
		rightButton.offset2.copyFrom(offset2);
		centerButton.offset2.copyFrom(offset2);
		fcSticker.offset2.copyFrom(offset2);
		
		leftButton.x = x + (387 * scale.x);
		leftButton.y = y + (894 * scale.y);
		
		rightButton.x = x + (591 * scale.x);
		rightButton.y = y + (894 * scale.y);
		
		centerButton.x = x + (531 * scale.x);
		centerButton.y = y + (902 * scale.y);
		
		fcSticker.x = x;
		fcSticker.y = y;
		
		leftButton.draw();
		rightButton.draw();
		
		centerButton.draw();
		
		songsDrawLayer.draw();
		
		if (fcSticker.visible) fcSticker.draw();
	}
	
	public function animateAccept()
	{
		centerButton.alpha = 1;
	}
	
	public function updateFcSticker(context:BaldiSongData, diff:Int)
	{
		var fcRank = SDCB;
		
		final tempRank = Highscore.getRank(context.songName, diff);
		
		if (tempRank.toInt() > fcRank.toInt()) fcRank = tempRank;
		
		lastRank = fcRank;
		lastMeta = context;
	}
	
	function updateStickerState() // use this state machine
	{
		if (lastMeta == null)
		{
			fcSticker.visible = false;
			return;
		}
		
		final currentAnim = fcSticker.animation.curAnim?.name ?? '';
		switch (currentAnim)
		{
			case 'fc':
				if (fcSticker.animation.finished)
				{
					//
					if (lastRank == PFC || lastRank == SDCB)
					{
						fcSticker.animation.play('removefc');
					}
				}
			case 'pfc':
				if (fcSticker.animation.finished)
				{
					if (lastRank == FC || lastRank == SDCB)
					{
						fcSticker.animation.play('removepfc');
					}
				}
			case 'removefc':
				if (fcSticker.animation.finished)
				{
					if (lastRank == SDCB)
					{
						fcSticker.visible = false;
					}
					else
					{
						fcSticker.visible = true;
						
						fcSticker.animation.play(lastRank.toString());
						FlxG.sound.play(Paths.sound('freeplay/sticker'), 0.5);
					}
				}
			case 'removepfc':
				if (fcSticker.animation.finished)
				{
					if (lastRank == SDCB)
					{
						fcSticker.visible = false;
					}
					else
					{
						fcSticker.visible = true;
						
						fcSticker.animation.play(lastRank.toString());
						FlxG.sound.play(Paths.sound('freeplay/sticker'), 0.5);
					}
				}
				
			default:
				if (lastRank == FC || lastRank == PFC)
				{
					fcSticker.visible = true;
					
					fcSticker.animation.play(lastRank.toString());
					FlxG.sound.play(Paths.sound('freeplay/sticker'), 0.5);
				}
		}
	}
}

private class Jukebox extends OffsetSprite
{
	public var diffBox:OffsetSprite;
	public var diffDown:OffsetSprite;
	public var diffUp:OffsetSprite;
	public var diffText:OffsetText;
	
	// public var diffOffset:FlxPoint = FlxPoint.get(75, 50);
	
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadSparrowFrames('menus/freeplay/player');
		animation.addByPrefix('resume', 'nowplaying', 24);
		animation.addByPrefix('paused', 'notplaying', 24);
		animation.play('paused');
		
		// theres a global callback and finish callback
		// why isnt there shit like startCallback
		// i do not care that u could do the shit as u play the animation
		// thats fuckign stupid
		animation.onFrameChange.add((name, frameNumber, frameIndex) -> {
			if (frameNumber == 0)
			{
				centerOffsets();
				if (name == 'resume') offset.y += 0.5;
			}
		});
		
		diffBox = new OffsetSprite(Paths.image('menus/freeplay/diffbox'));
		
		diffDown = new OffsetSprite(Paths.image('menus/freeplay/diff-down'));
		
		diffUp = new OffsetSprite(Paths.image('menus/freeplay/diff-up'));
		
		diffText = new OffsetText(0, 0, 286, '', 52);
		diffText.angle = 4;
		diffText.font = Paths.font('comic.ttf');
		diffText.alignment = CENTER;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		diffBox.update(elapsed);
		diffDown.update(elapsed);
		diffUp.update(elapsed);
		diffText.update(elapsed);
	}
	
	override function draw()
	{
		diffBox.offset2.copyFrom(offset2);
		diffDown.offset2.copyFrom(offset2);
		diffUp.offset2.copyFrom(offset2);
		diffText.offset2.copyFrom(offset2);
		
		diffBox.x = x + 570;
		diffBox.y = y + -152;
		
		diffDown.x = diffBox.x + 72;
		diffDown.y = diffBox.y + 108;
		
		diffUp.x = diffBox.x + 91;
		diffUp.y = diffBox.y + 0;
		
		diffText.x = diffBox.x + 46;
		diffText.y = diffBox.y + 45;
		
		diffBox.draw();
		diffDown.draw();
		diffUp.draw();
		diffText.draw();
		
		super.draw();
	}
	
	override function destroy()
	{
		super.destroy();
		
		diffBox = FlxDestroyUtil.destroy(diffBox);
		diffDown = FlxDestroyUtil.destroy(diffDown);
		diffUp = FlxDestroyUtil.destroy(diffUp);
		diffText = FlxDestroyUtil.destroy(diffText);
	}
}
