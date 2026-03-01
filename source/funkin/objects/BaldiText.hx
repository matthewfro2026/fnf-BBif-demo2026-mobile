package funkin.objects;

import flixel.util.FlxAxes;
import flixel.util.FlxDestroyUtil;

import funkin.shaders.PolyTextShader;

class BaldiText extends FlxText
{
	public static final polyShader = new PolyTextShader();
	
	public var usesShader(default, set):Bool = true;
	
	public var flooredPos:Bool = false;
	
	public var changeAxis:FlxAxes = Y;
	
	public var isMenuItem:Bool = false;
	public var targetY:Int = 0;
	
	public var distancePerItem:FlxPoint = new FlxPoint(20, 120);
	public var startPosition:FlxPoint = new FlxPoint(0, 0); // for the calculations'
	
	function set_usesShader(v:Bool)
	{
		if (v) shader = polyShader;
		else shader = null;
		return v;
	}
	
	public function new(x:Float = 0, y:Float = 0, fieldWidth:Float = 0, text:String = '', size:Int = 60, alignment:FlxTextAlign = LEFT)
	{
		super(x, y, fieldWidth, text, size);
		this.font = Paths.font('comic.ttf');
		// this.shader = polyShader;
		this.alignment = alignment;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (isMenuItem)
		{
			var lerpVal:Float = Math.exp(-elapsed * 9.6);
			if (changeAxis.x) x = FlxMath.lerp((targetY * distancePerItem.x) + startPosition.x, x, lerpVal);
			if (changeAxis.y) y = FlxMath.lerp((targetY * 1.3 * distancePerItem.y) + startPosition.y, y, lerpVal);
			
			if (flooredPos) // lie
			{
				x = Math.round(x);
				y = Math.round(y);
			}
		}
	}
	
	override function destroy()
	{
		super.destroy();
		
		distancePerItem = FlxDestroyUtil.put(distancePerItem);
		startPosition = FlxDestroyUtil.put(startPosition);
	}
	
	public function snapToPosition()
	{
		if (isMenuItem == false) return;
		
		if (changeAxis.x) x = (targetY * distancePerItem.x) + startPosition.x;
		if (changeAxis.y) y = (targetY * 1.3 * distancePerItem.y) + startPosition.y;
	}
}
