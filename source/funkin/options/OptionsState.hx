package funkin.options;

import flixel.group.FlxContainer;

import funkin.states.MainMenuState;

import flixel.FlxSubState;

import funkin.options.BaseOptionsMenu.OptionFlxText;
import funkin.backend.StageData;

import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;

class OptionsState extends MusicBeatState
{
	public static var onPlayState:Bool = false;
	
	static var curSel:Int = 0;
	
	final options:Array<String> = ['Controls', 'Adjust Delay', 'Performance', 'Visuals and UI', 'Gameplay'];
	
	var grpOptions:FlxTypedGroup<OptionFlxText>;
	
	var underline:FlxSprite;
	var canSelect:Bool = false;
	
	var frame:FlxSprite;
	
	var gearL:FlxSprite;
	var gearR:FlxSprite;
	
	var door:FlxSprite;
	
	public var substateDrawLayer:FlxContainer;
	
	function openSelectedSubstate(label:String)
	{
		switch (label)
		{
			case 'Controls':
				openSubState(new funkin.options.ControlsSubState());
			case 'Performance':
				openSubState(new funkin.options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new funkin.options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new funkin.options.GameplaySettingsSubState());
			case 'Adjust Delay':
				FlxG.switchState(() -> new funkin.options.NoteOffsetState());
		}
	}
	
	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
		
		FlxG.mouse.visible = true;
		
		persistentUpdate = true;
		
		var bg = new FlxSprite().loadFromSheet('menus/options/assets', 'doorbg');
		bg.scale.scale(0.6725);
		bg.updateHitbox();
		add(bg);
		bg.scrollFactor.set(0.8, 0.8);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<OptionFlxText>();
		add(grpOptions);
		
		door = new FlxSprite((660 - 20) * 0.67).loadFromSheet('menus/options/assets', 'door0');
		door.scale.scale(0.67);
		door.updateHitbox();
		add(door);
		
		frame = new FlxSprite(-20, -6).loadFromSheet('menus/options/assets', 'doorFrame0');
		frame.scale.scale(0.68);
		frame.updateHitbox();
		add(frame);
		
		for (i in 0...options.length)
		{
			var optionText:OptionFlxText = new OptionFlxText(20, 0, options[i], 48);
			optionText.color = FlxColor.WHITE;
			optionText.screenCenter();
			
			optionText.y += ((i - (options.length / 2)) * (64)) + (48 / 2);
			
			grpOptions.add(optionText);
		}
		
		underline = new FlxSprite(20).makeScaledGraphic(1, 5, FlxColor.WHITE);
		add(underline);
		underline.alpha = 0;
		
		substateDrawLayer = new FlxContainer();
		add(substateDrawLayer);
		
		gearL = new FlxSprite(-450, 350).loadFromSheet('menus/options/assets', 'gear');
		gearL.scale.set(2, 2).scale(0.67);
		gearL.updateHitbox();
		add(gearL);
		gearL.scrollFactor.set(1.5, 1.5);
		
		gearR = new FlxSprite(875, 805 * 0.67).loadFromSheet('menus/options/assets', 'gear');
		gearR.scale.set(1.8, 1.8).scale(0.67);
		add(gearR);
		gearR.updateHitbox();
		gearR.scrollFactor.set(1.5, 1.5);
		
		new FlxTimer().start(0.5, (f) -> {
			gearL.angle += 5;
			gearR.angle -= 5;
		}, 0);
		
		var mult = new FlxSprite().loadFromSheet('menus/options/assets', 'multiply');
		add(mult);
		mult.scale.scale(0.675);
		mult.updateHitbox();
		mult.blend = MULTIPLY;
		mult.screenCenter();
		
		ClientPrefs.saveSettings();
		
		openDoor();
		
		super.create();
	}
	
	function openDoor()
	{
		for (i in grpOptions)
		{
			i.scale.set(0.5, 0.5);
		}
		
		FlxTimer.wait(0.75, () -> {
			FlxG.sound.play(Paths.sound('options/door'));
			
			door.x -= door.width / 2;
			door.clipRect = new FlxRect(0, 0, door.frameWidth, door.frameHeight);
			door.clipRect.width /= 2;
			door.clipRect.x = door.clipRect.width;
			door.clipRect = door.clipRect;
			
			FlxTimer.wait(0.25, () -> {
				door.visible = false;
				door.active = false;
				
				remove(grpOptions, true);
				
				insert(members.indexOf(frame) + 1, grpOptions);
				
				for (i in grpOptions)
				{
					FlxTween.tween(i, {'scale.x': 1, 'scale.y': 1}, 0.6, {ease: FlxEase.sineInOut});
				}
				FlxTimer.wait(0.6, () -> {
					canSelect = true;
					changeSel();
				});
			});
		});
	}
	
	override function openSubState(subState:FlxSubState)
	{
		if (subState is BaseOptionsMenu || subState is ControlsSubState)
		{
			grpOptions.visible = underline.visible = canSelect = false;
		}
		
		super.openSubState(subState);
	}
	
	override function closeSubState()
	{
		if (subState is BaseOptionsMenu || subState is ControlsSubState) grpOptions.visible = underline.visible = canSelect = true;
		super.closeSubState();
		ClientPrefs.saveSettings();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canSelect)
		{
			if (FlxG.mouse.overlaps(grpOptions))
			{
				for (idx => obj in grpOptions)
				{
					if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(obj))
					{
						openSelectedSubstate(options[curSel]);
						break;
					}
					if (FlxG.mouse.justMoved && curSel != idx && FlxG.mouse.overlaps(obj))
					{
						changeSel(idx - curSel);
						break;
					}
				}
			}
			
			if (FlxG.mouse.wheel != 0) changeSel(-FlxG.mouse.wheel);
			
			if (controls.UI_UP_P || controls.UI_DOWN_P)
			{
				changeSel(controls.UI_UP_P ? -1 : 1);
			}
			
			if (controls.BACK || FlxG.mouse.justPressedRight)
			{
				canSelect = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				if (onPlayState)
				{
					FlxG.mouse.visible = false;
					StageData.loadDirectory(PlayState.SONG);
					FlxG.switchState(() -> new PlayState());
					FlxG.sound.music.volume = 0;
				}
				else FlxG.switchState(() -> new MainMenuState());
			}
			else if (controls.ACCEPT) openSelectedSubstate(options[curSel]);
		}
		
		final rate = 1 - Math.exp(-elapsed);
		
		final x = FlxG.mouse.x - (FlxG.camera.viewWidth) / 2;
		final y = FlxG.mouse.y - (FlxG.camera.viewHeight) / 2;
		
		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, x * 0.015, rate);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, y * 0.015, rate);
		
		for (idx => obj in grpOptions)
		{
			obj.screenCenter();
			
			obj.y += ((idx - (options.length / 2)) * (72 * obj.scale.x)) + ((48 * obj.scale.x) / 2);
		}
	}
	
	function changeSel(diff:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		curSel = FlxMath.wrap(curSel + diff, 0, options.length - 1);
		
		underline.alpha = 1;
		
		for (idx => item in grpOptions.members)
		{
			item.targetY = idx - curSel;
			
			if (item.targetY == 0)
			{
				underline.scale.x = item.width / underline.frameWidth;
				underline.updateHitbox();
				
				underline.x = item.x;
				underline.y = item.y + item.height - underline.height;
			}
		}
	}
	
	public function clearSubstateLayer()
	{
		while (substateDrawLayer.length > 0)
		{
			var obj = substateDrawLayer.remove(substateDrawLayer.members[0], true);
			obj = FlxDestroyUtil.destroy(obj);
		}
	}
	
	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}
