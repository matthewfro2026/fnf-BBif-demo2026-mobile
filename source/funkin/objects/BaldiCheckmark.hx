package funkin.objects;

class BaldiCheckmark extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	
	public function new(x:Float = 0, y:Float = 0, ?checked = false)
	{
		super(x, y);
		
		loadGraphic(Paths.image('mechanics/thinkpad/Check'), true);
		
		// scale.set(2, 2);
		// updateHitbox();
		
		daValue = checked;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (sprTracker != null)
		{
			x = sprTracker.x + sprTracker.width + offsetX;
			this.centerOnObject(sprTracker, Y);
			
			y += offsetY;
			if (copyAlpha)
			{
				alpha = sprTracker.alpha;
			}
		}
	}
	
	private function set_daValue(check:Bool):Bool
	{
		if (check)
		{
			loadGraphic(Paths.image('mechanics/thinkpad/Check'));
		}
		else
		{
			loadGraphic(Paths.image('mechanics/thinkpad/X'));
		}
		return daValue = check;
	}
}
