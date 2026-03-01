package funkin.objects;

import funkin.objects.UiSprite.IUiSprite;

using flixel.util.FlxColorTransformUtil;

class BotplayText extends FlxText implements IUiSprite
{
	public function new(x:Float = 0, y:Float = 0, fw:Float = 0)
	{
		super(x, y, fw, 'botplay', 32);
		
		setFormat(Paths.font("comic"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		borderSize = 2;
	}
	
	var sine:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (visible)
		{
			sine += 180 * elapsed;
			alpha = 1 - Math.sin((Math.PI * sine) / 180);
		}
	}
	
	public var visibleOverride(default, set):Null<Bool> = null;
	
	public var alphaMult(default, set):Float = 1;
	
	function set_alphaMult(value:Float):Float
	{
		alphaMult = FlxMath.bound(value, 0, 1);
		updateColorTransform();
		return alphaMult;
	}
	
	override function updateColorTransform()
	{
		if (colorTransform == null) return;
		
		useColorTransform = alphaMult != 1 || alpha != 1 || color != 0xffffff;
		if (useColorTransform) colorTransform.setMultipliers(color.redFloat, color.greenFloat, color.blueFloat, FlxMath.bound(alpha * alphaMult, 0, 1));
		else colorTransform.setMultipliers(1, 1, 1, 1);
		
		dirty = true;
	}
	
	function set_visibleOverride(value:Null<Bool>):Null<Bool>
	{
		visibleOverride = value;
		
		set_visible(visible);
		return visibleOverride;
	}
	
	override function set_visible(v:Bool):Bool
	{
		if (visibleOverride != null) return visible = visibleOverride;
		return super.set_visible(v);
	}
}
