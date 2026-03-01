package funkin.states.freeplay;

import extensions.flixel.FlxUniformSprite;

class PaldoPopUp extends MusicBeatSubstate
{
	var canInteract:Bool = false;
	var asset:FlxUniformSprite;
	var vignette:FlxUniformSprite;
	var bg:FlxUniformSprite;
	
	override function create()
	{
		super.create();
		
		bg = new FlxUniformSprite();
		bg.makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		vignette = new FlxUniformSprite(Paths.image('menus/freeplay/vignette'));
		vignette.scale.scale(0.67);
		vignette.updateHitbox();
		add(vignette);
		
		asset = new FlxUniformSprite(Paths.image('menus/freeplay/firewall'));
		// asset.scale.scale(0.67);
		// asset.updateHitbox();
		add(asset);
		asset.y = FlxG.height / 4;
		asset.antialiasing = false;
		
		asset.alpha = 0;
		vignette.alpha = 0;
		bg.alpha = 0;
		
		FlxTween.tween(bg, {alpha: 0.6}, 0.7);
		FlxTween.tween(vignette, {alpha: 1}, 0.7);
		FlxTween.tween(asset, {alpha: 1, y: 0}, 0.4, {startDelay: 0.1, ease: FlxEase.cubeOut, framerate: 24});
		
		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		
		FlxTimer.wait(0.4, () -> canInteract = true);
		
		FlxG.sound.play(Paths.sound('freeplay/attack'));
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canInteract)
		{
			if (controls.ACCEPT || FlxG.mouse.justPressed)
			{
				canInteract = false;
				
				@:privateAccess
				(cast FlxG.state : FreeplayState).loadSong('firewall', false);
				
				CoolUtil.playUISound('freeplay/ding goodiebag rizz at the wawa');
				
				FlxG.sound.music.fadeOut(1.2);
				
				@:privateAccess
				{
					FlxTween.tween((cast FlxG.state : FreeplayState).ditherShader, {transparency: -1}, 0.4);
					
					camera._fxFadeColor = FlxColor.BLACK;
					FlxTween.tween(camera, {_fxFadeAlpha: 1}, 0.9,
						{
							startDelay: 0.2,
							onComplete: Void -> CoolUtil.switchStateAndStopMusic(() -> new PlayState())
						});
				}
			}
			else if (controls.BACK || FlxG.mouse.justPressedRight)
			{
				canInteract = false;
				
				FlxTween.tween(bg, {alpha: 0}, 0.4, {startDelay: 0.2});
				FlxTween.tween(vignette, {alpha: 0}, 0.2, {startDelay: 0.2});
				
				FlxTween.tween(asset, {alpha: 0, y: FlxG.height / 4}, 0.4, {ease: FlxEase.cubeIn, framerate: 24});
				
				FlxTimer.wait(0.6, () -> {
					@:privateAccess
					(cast FlxG.state : FreeplayState).canInteract = true;
					close();
				});
			}
		}
	}
}
