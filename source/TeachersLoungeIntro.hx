package;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

import funkin.objects.BaldiText;
import funkin.backend.MusicBeatState;

class TeachersLoungeIntro extends MusicBeatState
{
	var theLounge:FlxSprite;
	var warning:FlxSprite;
	
	var allowControl:Bool = false;
	var buzz:FlxSound;
	
	override function create()
	{
		super.create();
		
		buzz = FlxG.sound.load(Paths.sound('splashscreen/buzz'), true);
		
		theLounge = new FlxSprite().loadSparrowFrames('menus/title/theLounge');
		theLounge.animation.addByPrefix('i', 'i', 30, false);
		theLounge.scale.scale(2);
		theLounge.updateHitbox();
		add(theLounge);
		theLounge.shader = BaldiText.polyShader;
		
		warning = new FlxSprite(Paths.image('menus/title/warning'));
		add(warning);
		
		for (spr in [theLounge, warning])
		{
			spr.antialiasing = false;
			spr.screenCenter();
			spr.visible = false;
		}
		
		FlxTimer.wait(0.7, clicked);
		
		FlxTimer.wait(1.4, clicked);
	}
	
	inline function goToMain() FlxG.switchState(() -> Type.createInstance(Main.game.initialState, []));
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (allowControl && (controls.ACCEPT || FlxG.mouse.justPressed))
		{
			allowControl = false;
			clicked();
		}
	}
	
	var _counter:Int = 0;
	
	function clicked()
	{
		switch (_counter)
		{
			case 0:
				buzz.play();
			case 1:
				theLounge.visible = true;
				
				theLounge.animation.play('i');
				FlxG.sound.play(Paths.sound('splashscreen/teacherslounge'));
				FlxG.camera.zoom = 1.8;
				FlxTween.tween(FlxG.camera, {zoom: 1.2}, 1, {ease: FlxEase.circOut});
				
				theLounge.animation.onFinish.addOnce((n:String) -> {
					if (FlxG.save.data.seenWarning == null)
					{
						FlxTimer.wait(0.7, () -> {
							theLounge.visible = false;
							
							FlxTimer.wait(0.7, () -> {
								FlxG.camera.zoom = 0.8;
								warning.visible = true;
								allowControl = true;
							});
						});
					}
					else
					{
						FlxTimer.wait(0.7, clicked);
					}
				});
				
			case 2:
				warning.visible = false;
				theLounge.visible = false;
				FlxG.sound.play(Paths.sound('splashscreen/menuClick'));
				buzz.stop();
				
				FlxG.save.data.seenWarning = true;
				FlxG.save.flush();
				
				FlxTimer.wait(0.6, goToMain);
		}
		
		_counter++;
	}
}
