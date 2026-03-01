package funkin.objects;

import funkin.objects.UiSprite.IUiSprite;

using flixel.util.FlxColorTransformUtil;

class HealthIcon extends FlxSprite implements IUiSprite
{
	public var sprTracker:FlxSprite;
	
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	
	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (sprTracker != null) setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}
	
	private var iconOffsets:Array<Float> = [0, 0];
	
	public function changeIcon(char:String, ?allowGPU:Bool = true)
	{
		if (this.char != char)
		{
			var name:String = 'icons/' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; // Older versions of psych engine's support
			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; // Prevents crash from missing icon
			
			var graphic = Paths.image(name, allowGPU);
			loadGraphic(graphic, true, Math.floor(graphic.width / 2), Math.floor(graphic.height));
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (height - 150) / 2;
			updateHitbox();
			
			animation.add(char, [0, 1], 0, false, isPlayer);
			animation.play(char);
			this.char = char;
			
			if (char.endsWith('-pixel')) antialiasing = false;
			else antialiasing = ClientPrefs.data.antialiasing;
		}
	}
	
	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}
	
	public function getCharacter():String
	{
		return char;
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
