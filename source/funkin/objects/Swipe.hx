package funkin.objects;

import flixel.util.FlxGradient;

class Swipe extends FlxTypedGroup<FlxSprite> // this is afunny class used for one thing but it works! aha right? hello ? wait what why am i gettging aired? what what. #5
{
	var gradTop:FlxSprite;
	var gradBottom:FlxSprite;
	var block:FlxSprite;
	var tween:FlxTween;
	
	public function new()
	{
		super();
		
		final width:Int = Std.int(FlxG.width);
		final height:Int = Std.int(FlxG.height);
		
		gradTop = FlxGradient.createGradientFlxSprite(1, height, ([0x0, FlxColor.BLACK]));
		gradTop.scale.x = width;
		gradTop.updateHitbox();
		gradTop.scrollFactor.set();
		add(gradTop);
		
		gradTop.active = false;
		
		gradBottom = FlxGradient.createGradientFlxSprite(1, height, ([FlxColor.BLACK, 0x0]));
		gradBottom.scale.x = width;
		gradBottom.updateHitbox();
		gradBottom.scrollFactor.set();
		add(gradBottom);
		gradBottom.active = false;
		
		block = new FlxSprite().makeScaledGraphic(width, height, FlxColor.BLACK);
		block.updateHitbox();
		block.scrollFactor.set();
		add(block);
		block.active = false;
	}
	
	public function play(time:Float = 0.6, goingUp:Bool = false)
	{
		tween?.cancel();
		
		if (goingUp)
		{
			block.y = FlxG.height * 2;
			
			tween = FlxTween.tween(block, {y: -FlxG.height * 2}, time);
		}
		else
		{
			block.y = -FlxG.height * 2;
			
			tween = FlxTween.tween(block, {y: FlxG.height * 2}, time);
		}
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		gradBottom.y = block.y + block.height;
		gradTop.y = block.y - gradTop.height;
	}
}
