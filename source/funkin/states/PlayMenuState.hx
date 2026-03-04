package funkin.states;

import funkin.plugins.MousePlugin;

import flixel.graphics.tile.FlxGraphicsShader;

import funkin.shaders.ChalkShader;
class PlayMenuState extends MusicBeatState
{
	static var curSelected:Int = 0;
	
	var bg:FlxSprite;
	var wall:FlxSprite;
	var chalkboard:FlxSprite;
	
	var menuItems:FlxTypedGroup<FlxSprite>;
	
	var descriptionTxt:FlxText;
	
	final descs:Array<String> = ["Meet Baldi and his friends as you explore the schoolhouse and collect all notebooks!", "Replay any song of your choice from Story Style, alongside many new extras!"];
	
	override function create()
	{
		persistentUpdate = true;
		FlxG.mouse.visible = true;
		super.create();
		
		add(bg = new FlxSprite(0, 0).makeScaledGraphic(FlxG.width * 1.5, FlxG.height * 1.5));
		bg.screenCenter();
		
		wall = new FlxSprite().loadGraphic(Paths.image('menus/wall'));
		wall.scale.scale(0.8);
		wall.updateHitbox();
		wall.screenCenter();
		add(wall);
		
		chalkboard = new FlxSprite().loadGraphic(Paths.image('menus/play/board'));
		chalkboard.scale.scale(0.67);
		chalkboard.updateHitbox();
		chalkboard.screenCenter();
		add(chalkboard);
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		
		final yOffset = 0;
		var story = addMenuOption(chalkboard.x + 75, chalkboard.y + 50 + yOffset, "story");
		
		var freeplay = addMenuOption(chalkboard.x + chalkboard.width - 50 + 25, chalkboard.y + 75 + yOffset, "free");
		freeplay.x -= freeplay.width + 150;
		freeplay.y += 10;
		// jank
		freeplay.animation.onFrameChange.add((anim, _, _) -> freeplay.offset.y = anim == 'idle' ? 66.33 : 91.8);
		freeplay.animation.finish();
		
		descriptionTxt = new FlxText(0, 0, 1000 * 0.67, 'hello', 24);
		descriptionTxt.setFormat(Paths.font('comic.ttf'), 24, 0xffffffff, CENTER);
		add(descriptionTxt);
		
		descriptionTxt.x = chalkboard.x + (81 * 0.67) + (1281 * 0.67 - descriptionTxt.fieldWidth) / 2;
		
		descriptionTxt.shader = new ChalkShader();
		
		changeSel();
	}
	
	var selectedSomething:Bool = false;
	
	var lastMousePos:FlxPoint = FlxPoint.get();
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7) FlxG.sound.music.volume += 0.125 * elapsed;
		super.update(elapsed);
		
		if (!selectedSomething)
		{
			var curMousePos = MousePlugin.instance.getRawPosition();
			
			if (curMousePos.x != lastMousePos.x || curMousePos.y != lastMousePos.y)
			{
				for (k => item in menuItems.members)
				{
					if (curSelected != k && FlxG.mouse.overlaps(item))
					{
						changeSel(k - curSelected);
						break;
					}
				}
			}
			
			curMousePos.put();
			
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) changeSel(controls.UI_LEFT_P ? -1 : 1);
			
			if ((FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuItems.members[curSelected])) || controls.ACCEPT)
			{
				CoolUtil.playUISound('confirmMenu', 0.6);
				
				selectedSomething = true;
				FlxG.mouse.visible = false;
				
				switch (curSelected)
				{
					case 0:
						FlxG.switchState(() -> new StoryMenu());
					case 1:
						FlxG.switchState(() -> new funkin.states.freeplay.FreeplayState());
				}
			}
			else if (FlxG.mouse.justPressedRight || controls.BACK)
			{
				selectedSomething = true;
				
				FlxG.mouse.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
				FlxG.switchState(() -> new MainMenuState());
			}
		}
		
		final rate = 1 - Math.exp(-elapsed);
		
		final x = FlxG.mouse.x - (FlxG.camera.viewWidth) / 2;
		final y = FlxG.mouse.y - (FlxG.camera.viewHeight) / 2;
		
		FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, x * 0.01, rate);
		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, y * 0.01, rate);
		
		MousePlugin.instance.getRawPosition(lastMousePos);
	}
	
	public function changeSel(sel:Int = 0)
	{
		if (sel != 0) FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		
		curSelected = FlxMath.wrap(curSelected + sel, 0, menuItems.length - 1);
		
		for (k => e in menuItems.members)
		{
			var anim = curSelected == k ? 'hover' : 'idle';
			if (e.animation.curAnim.name != anim)
			{
				e.animation.play(anim);
			}
		}
		
		descriptionTxt.text = descs[curSelected];
		
		descriptionTxt.y = chalkboard.y + (964 * 0.67) - (37 * 0.67) - descriptionTxt.height - 10;
	}
	
	public function addMenuOption(x:Float, y:Float, anim:String)
	{
		var spr = new FlxSprite(x, y);
		spr.frames = Paths.getSparrowAtlas('menus/play/styleMenu');
		spr.animation.addByPrefix('idle', anim + "0", 24, false);
		spr.animation.addByPrefix('hover', '$anim-hover', 24, false);
		spr.animation.play('idle');
		spr.scale.set(0.67, 0.67);
		spr.updateHitbox();
		spr.screenCenter(Y);
		
		return menuItems.add(spr);
	}
}
