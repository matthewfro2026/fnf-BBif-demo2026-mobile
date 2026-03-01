package funkin.objects;

using flixel.util.FlxColorTransformUtil;

interface IUiSprite
{
	public var alphaMult(default, set):Float;
	
	public var visibleOverride(default, set):Null<Bool>;
}

class UiSprite extends FlxSprite implements IUiSprite
{
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
