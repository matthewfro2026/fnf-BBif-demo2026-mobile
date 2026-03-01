package funkin.states;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;

import openfl.system.System;

import funkin.backend.DitherTransitionSubstate;

import flixel.util.typeLimit.OneOfTwo;

import funkin.options.OptionsState;

import flixel.util.typeLimit.NextState;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxContainer.FlxTypedContainer;

import funkin.backend.MusicBeatUIState;
import funkin.objects.OffsetSprite;

class MainMenuState extends MusicBeatUIState
{
	static var curSel:Int = 0;
	
	static var seenIntro:Bool = false;
	
	var starsBg:OffsetSprite;
	var logo:OffsetSprite;
	
	var chalkboard:OffsetSprite;
	
	var floaters:FlxTypedContainer<OffsetSprite>;
	
	var buttons:FlxTypedContainer<MenuItem>;
	var links:FlxTypedContainer<Link>;
	
	var pointer:OffsetSprite;
	
	var canSelect:Bool = true;
	
	var baldiAtlas:OffsetAnimate;
	var baldiIntroSfx:FlxSound;
	var baldiCanBop:Bool = true;
	
	var pointerAutoHide:Bool = true;
	
	override function create()
	{
		#if DISCORD_ALLOWED DiscordClient.changePresence("In the Menus", null); #end
		
		FunkinAssets.cache.clearStoredMemory();
		
		FlxG.mouse.visible = true;
		
		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.music(Constants.MENU_MUSIC), 0);
			FlxG.sound.music.fadeIn(2, 0, 0.7);
		}
		
		Conductor.bpm = 105;
		persistentUpdate = true;
		
		to1080P = true;
		super.create();
		
		FlxG.camera.bgColor = FlxColor.WHITE;
		
		starsBg = new OffsetSprite(Paths.image('menus/main/stars'));
		starsBg.x = FlxG.camera.viewRight - starsBg.width;
		add(starsBg);
		
		logo = new OffsetSprite(163, 63, Paths.image('menus/main/demo logo'));
		add(logo);
		
		chalkboard = new OffsetSprite(708, 720, Paths.image('menus/main/chalkboard'));
		add(chalkboard);
		chalkboard.x -= chalkboard.width / 2;
		chalkboard.y -= chalkboard.height / 2;
		
		floaters = new FlxTypedContainer();
		add(floaters);
		
		inline function makeFloater(x:Float = 0, y:Float = 0, anim:String)
		{
			var spr:OffsetSprite = cast new OffsetSprite(x, y).setFrames(Paths.getSparrowAtlas('menus/main/floaters'));
			spr.animation.addByPrefix('i', anim, 24);
			spr.animation.play('i');
			
			return floaters.add(spr);
		}
		
		var singing = makeFloater(793, 369, 'singing what');
		
		var wow = makeFloater(307, 422, 'wow');
		
		var history = makeFloater(452, 595, 'historicality');
		
		var numbers = makeFloater(340, 659, 'numbers');
		
		var minus = makeFloater(628, 492, 'minus');
		
		var plus = makeFloater(873, 499, 'plus');
		
		var equals = makeFloater(634, 758, 'equals');
		
		//
		
		buttons = new FlxTypedContainer();
		add(buttons);
		
		var play = new MenuItem(1486, 356, 'play', () -> FlxG.switchState(PlayMenuState.new));
		buttons.add(play);
		play.button.offset.set(132, 18);
		play.animOffsets.set('hovered', [2, -1]);
		
		var settings = new MenuItem(1471, 494, 'settings', () -> {
			OptionsState.onPlayState = false;
			if (PlayState.SONG != null)
			{
				PlayState.SONG.arrowSkin = null;
				PlayState.SONG.splashSkin = null;
				PlayState.stageUI = 'normal';
			}
			FlxG.switchState(OptionsState.new);
		});
		buttons.add(settings);
		settings.button.offset.set(153, 0);
		settings.animOffsets.set('hovered', [0.5, 0.5]);
		
		var credits = new MenuItem(1454, 656, 'cred', () -> FlxG.switchState(CreditsState.new));
		buttons.add(credits);
		credits.button.offset.set(135, 38);
		credits.animOffsets.set('hovered', [1, 0.25]);
		
		var web = new MenuItem(1401, 781, 'web', () -> {
			CoolUtil.browserLoad('https://www.the-teachers-lounge.org');
			canSelect = true;
		});
		buttons.add(web);
		web.button.offset.set(147, 43);
		web.scale.scale(0.87);
		web.updateHitbox();
		// die advide.
		web.animOffsets.set('hovered', [(19 * 0.87) + (-0.5 * (web.width - web.frameWidth)), -1 + (-0.5 * (web.height - web.frameHeight))]);
		web.animOffsets.set('idle', [(-0.5 * (web.width - web.frameWidth)), (-0.5 * (web.height - web.frameHeight))]);
		web.angle = -4;
		
		//
		
		pointer = new OffsetSprite(Paths.image('menus/main/pointer'));
		add(pointer);
		pointer.visible = false;
		
		//
		
		links = new FlxTypedContainer();
		add(links);
		
		var exit = new Link('exit');
		
		var twitter = new Link('twitter');
		
		var discord = new Link('discord');
		
		var youtube = new Link('youtube');
		
		for (idx => obj in [exit, twitter, discord, youtube])
		{
			obj.x = FlxG.camera.viewRight - obj.width - 15 - (obj.width * 1.1 * idx);
			obj.y = 15;
			links.add(obj);
		}
		
		//
		
		final bottomText = new FlxText(0, 0, FlxG.camera.viewWidth - 25, "2026 - The Teachers' Lounge - Dedicated to the Popular Game!", 32);
		bottomText.setFormat(Paths.font('comic.ttf'), 32, FlxColor.BLACK, RIGHT);
		add(bottomText);
		bottomText.y = FlxG.camera.viewBottom - bottomText.height;
		
		final bottomText2 = new FlxText(0, 0, FlxG.camera.viewWidth - 25, "Demo Hotfix #2", 32);
		bottomText2.setFormat(Paths.font('comic.ttf'), 32, FlxColor.BLACK, RIGHT);
		add(bottomText2);
		bottomText2.y = FlxG.camera.viewBottom - bottomText2.height - 36;
		
		baldiAtlas = new OffsetAnimate(0, 175);
		Paths.loadAnimateAtlas(baldiAtlas, 'menus/main/baldimenu');
		baldiAtlas.applyStageMatrix = true;
		add(baldiAtlas);
		
		baldiAtlas.anim.addBySymbol('intro', 'baldi/welcome (THX DREOUPY)', 30, false);
		baldiAtlas.anim.addBySymbol('left', 'baldi/BopLeft', 30, false);
		baldiAtlas.anim.addBySymbol('right', 'baldi/BopRight', 30, false);
		
		if (!seenIntro)
		{
			seenIntro = true;
			baldiIntro();
			
			// from the right
			for (i in [starsBg])
			{
				i.offset2.x = FlxG.camera.viewWidth;
				
				FlxTween.tween(i, {'offset2.x': 0}, 0.3, {ease: FlxEase.cubeOut});
			}
			
			// from above
			for (idx => obj in buttons.members)
			{
				obj.offset2.y = -300;
				obj.alpha = 0;
				
				FlxTween.tween(obj, {'offset2.y': 0}, 0.2, {ease: FlxEase.cubeOut, startDelay: idx * 0.025});
				
				FlxTween.tween(obj, {alpha: 1}, 0.3, {startDelay: idx * 0.025});
			}
			
			// from below
			
			for (idx => obj in [logo, chalkboard, baldiAtlas])
			{
				// not adding casts idc
				CoolUtil.setProperty(obj, 'offset2.y', FlxG.camera.viewHeight);
				// obj.offset2.y = FlxG.camera.viewHeight;
				
				FlxTween.tween(obj, {'offset2.y': 0}, 0.2, {ease: FlxEase.cubeOut, startDelay: 0.1 + idx * 0.01});
			}
			
			// floaters in specific
			for (idx => obj in floaters.members)
			{
				obj.offset2.y = FlxG.camera.viewWidth;
				
				FlxTween.tween(obj, {'offset2.y': 0}, 0.2,
					{
						ease: FlxEase.cubeOut,
						startDelay: 0.15 + idx * 0.025,
						onComplete: Void -> {}
					});
			}
		}
		else
		{
			baldiAtlas.anim.play('left');
			baldiAtlas.animation.finish();
		}
		
		for (idx => obj in [singing, wow, history, numbers])
		{
			FlxTween.tween(obj, {'offset.y': -5}, 1.2, {ease: FlxEase.sineInOut, type: 4, startDelay: idx * 0.2});
		}
		
		// specifically we want some inverted
		for (idx => obj in [minus, plus, equals])
		{
			FlxTween.tween(obj, {'offset.y': 5}, 1.2, {ease: FlxEase.sineInOut, type: 4, startDelay: idx * 0.2});
		}
		
		changeSel();
	}
	
	function baldiIntro()
	{
		baldiCanBop = false;
		if (baldiIntroSfx == null)
		{
			baldiIntroSfx = FlxG.sound.load(Paths.sound('bbifarintro'));
			FlxG.sound.list.add(baldiIntroSfx);
		}
		baldiIntroSfx.play(true);
		
		baldiAtlas.anim.play('intro');
		baldiAtlas.anim.onFinish.addOnce(anim -> {
			if (anim == 'intro')
			{
				baldiCanBop = true;
			}
		});
	}
	
	override function destroy()
	{
		baldiIntroSfx = FlxDestroyUtil.destroy(baldiIntroSfx);
		super.destroy();
	}
	
	var _prevLinkSfxIdx:Int = -1;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canSelect)
		{
			if (FlxG.mouse.justMoved)
			{
				pointerAutoHide = true;
				buttons.members[curSel].isSelected = false;
			}
			
			if (baldiAtlas.anim.curAnim != null
				&& baldiAtlas.anim.curAnim.name != 'intro'
				&& FlxG.mouse.justPressed
				&& (FlxG.mouse.x < 380 && FlxG.mouse.y > 430))
			{
				baldiIntro();
			}
			
			var foundSelected:Bool = false;
			
			for (idx => obj in buttons)
			{
				if (FlxG.mouse.overlaps(obj))
				{
					buttons.members[curSel].isSelected = true;
					
					foundSelected = true;
					if (_prevLinkSfxIdx != idx)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						_prevLinkSfxIdx = idx;
					}
					
					if (FlxG.mouse.justMoved && idx != curSel)
					{
						changeSel(idx - curSel);
						break;
					}
				}
			}
			
			pointer.visible = !pointerAutoHide || foundSelected;
			
			for (idx => obj in links)
			{
				if (obj.isSelected)
				{
					foundSelected = true;
					if (_prevLinkSfxIdx != idx)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						_prevLinkSfxIdx = idx;
					}
					
					if (FlxG.mouse.justPressed)
					{
						switch (obj.type)
						{
							case 'youtube':
								CoolUtil.browserLoad("https://www.youtube.com/@BaldisBasicsInFunkin");
								
							case 'discord':
								CoolUtil.browserLoad("https://discord.gg/mpq6sVbmXb");
								
							case 'exit':
								canSelect = false;
								
								FlxG.mouse.visible = false;
								FlxG.sound.music.fadeOut(1);
								DitherTransitionSubstate.finishCallback = () -> {
									for (i in FlxG.cameras.list)
										i.visible = false;
									FlxTimer.wait(0.1, () -> System.exit(0));
								}
								openSubState(new DitherTransitionSubstate(1, false));
								
							case 'twitter':
								CoolUtil.browserLoad('https://x.com/BaldiFunkin');
						}
						return;
					}
				}
			}
			
			if (!foundSelected) _prevLinkSfxIdx = -1;
			
			if (controls.UI_DOWN_P || controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				
				changeSel(controls.UI_DOWN_P ? 1 : -1);
			}
			
			if ((FlxG.mouse.justPressed && buttons.members[curSel].isSelected) || controls.ACCEPT)
			{
				canSelect = false;
				
				CoolUtil.playUISound('confirmMenu');
				
				var button = buttons.members[curSel];
				
				button.func();
			}
		}
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		if (baldiCanBop)
		{
			baldiAtlas.anim.play(curBeat % 2 == 0 ? 'left' : 'right');
		}
	}
	
	function changeSel(diff:Int = 0)
	{
		// if (diff != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		
		pointerAutoHide = false;
		
		buttons.members[curSel].isSelected = false;
		
		curSel = FlxMath.wrap(curSel + diff, 0, buttons.length - 1);
		
		buttons.members[curSel].isSelected = true;
		
		// hardcoded values from the fla.
		switch (curSel)
		{
			case 0:
				pointer.x = 1232;
				pointer.y = 349;
				pointer.angle = -15;
			case 1:
				pointer.x = 1192;
				pointer.y = 472;
				pointer.angle = -8.7;
			case 2:
				pointer.x = 1202;
				pointer.y = 586;
				pointer.angle = 0;
			case 3:
				pointer.x = 1154;
				pointer.y = 683;
				pointer.angle = 6.5;
		}
	}
}

private class Link extends FlxSprite
{
	public var type:String = '';
	
	public var isSelected(default, null):Bool = false;
	
	public function new(x:Float = 0, y:Float = 0, type:String)
	{
		super(x, y);
		frames = Paths.getSparrowAtlas('menus/main/links');
		animation.addByPrefix('i', type);
		animation.play('i');
		this.type = type;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		isSelected = FlxG.mouse.overlaps(this);
		
		scale.x = isSelected ? 1.2 : 1;
		scale.y = scale.x;
	}
}

private class MenuItem extends OffsetSprite
{
	public var button:FlxSprite;
	
	public var isSelected:Bool = false;
	
	public var func:Void->Void;
	
	public var animOffsets:Map<String, Array<Float>> = [];
	
	public function new(x:Float = 0, y:Float = 0, id:String, func:Void->Void)
	{
		super(x, y);
		
		this.func = func;
		
		frames = Paths.getSparrowAtlas('menus/main/$id');
		animation.addByPrefix('idle', id + '0', 17);
		animation.addByPrefix('hovered', id + 'hovered', 17);
		animation.play('idle');
		
		button = new FlxSprite().setFrames(Paths.getSparrowAtlas('menus/main/icons'));
		button.animation.addByPrefix('i', id + 'Icon', 24, true);
		button.animation.play('i');
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		button.update(elapsed);
		
		// isSelected = FlxG.mouse.overlaps(this);
		
		if (isSelected)
		{
			if (button.animation.paused) button.animation.resume();
			animation.play('hovered');
			
			final offsets = animOffsets.get('hovered');
			if (offsets != null)
			{
				offset.x = offsets[0];
				offset.y = offsets[1];
			}
			else
			{
				offset.x = 0;
				offset.y = 0;
			}
		}
		else
		{
			if (!button.animation.paused)
			{
				button.animation.pause();
				button.animation.curAnim.curFrame = 0;
			}
			
			animation.play('idle');
			
			final offsets = animOffsets.get('idle');
			if (offsets != null)
			{
				offset.x = offsets[0];
				offset.y = offsets[1];
			}
			else
			{
				offset.x = 0;
				offset.y = 0;
			}
		}
	}
	
	override function draw()
	{
		button.x = x + offset2.x;
		button.y = y + offset2.y;
		button.draw();
		
		super.draw();
	}
	
	override function destroy()
	{
		super.destroy();
		button = FlxDestroyUtil.destroy(button);
		func = null;
	}
}
