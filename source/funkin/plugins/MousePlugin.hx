package funkin.plugins;

/**
 * Helper class to handle mouse visibility.
 */
@:access(openfl.display.Stage)
@:nullSafety(Strict)
class MousePlugin extends flixel.FlxBasic
{
	public static var instance:Null<MousePlugin> = null;
	
	public static function init()
	{
		if (instance == null) FlxG.plugins.addPlugin(funkin.plugins.MousePlugin.instance = new funkin.plugins.MousePlugin());
	}
	
	public var autoHide:Bool = true;
	
	var _prevX:Float = 0;
	var _prevY:Float = 0;
	
	public function new()
	{
		super();
		visible = false;
		FlxG.signals.preStateSwitch.add(reset);
	}
	
	var timeout:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		// #if debug
		// FlxG.watch.addQuick('mouse has moved? ', hasMoved());
		// #end
		
		if (hasMoved() || FlxG.mouse.pressed || FlxG.mouse.pressedRight || FlxG.mouse.wheel != 0)
		{
			timeout = 1;
			FlxG.mouse.visible = true;
		}
		else if (timeout > 0)
		{
			timeout -= elapsed;
		}
		else if (FlxG.mouse.visible && autoHide)
		{
			FlxG.mouse.visible = false;
		}
		
		_prevX = getStageX();
		_prevY = getStageY();
	}
	
	public function getRawPosition(?point:FlxPoint)
	{
		point ??= FlxPoint.get();
		point.x = getStageX();
		point.y = getStageY();
		return point;
	}
	
	public function getLastRawPosition(?point:FlxPoint)
	{
		point ??= FlxPoint.get();
		point.x = _prevX;
		point.y = _prevY;
		return point;
	}
	
	inline function getStageX() return FlxG.stage?.__mouseX ?? 0.0;
	
	inline function getStageY() return FlxG.stage?.__mouseY ?? 0.0;
	
	// flixel .
	inline public function hasMoved() return (getStageX() != _prevX || getStageY() != _prevY);
	
	public function reset() autoHide = true;
}
