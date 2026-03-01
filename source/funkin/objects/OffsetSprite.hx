package funkin.objects;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.util.FlxDestroyUtil;

// helper classes
// adds a 2nd offset var that can be used without disrupting offset

class OffsetSprite extends FlxSprite
{
	public var offset2:FlxPoint = FlxPoint.get();
	
	override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
	{
		return super.getScreenPosition(result, camera).add(offset2);
	}
	
	override function destroy()
	{
		super.destroy();
		offset2 = FlxDestroyUtil.put(offset2);
	}
}

class OffsetText extends FlxText
{
	public var offset2:FlxPoint = FlxPoint.get();
	
	override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
	{
		return super.getScreenPosition(result, camera).subtract(_graphicOffset).add(offset2);
	}
	
	override function destroy()
	{
		super.destroy();
		
		offset2 = FlxDestroyUtil.put(offset2);
	}
}

class OffsetAnimate extends FlxAnimate
{
	public var offset2:FlxPoint = FlxPoint.get();
	
	override function getScreenPosition(?result:FlxPoint, ?camera:FlxCamera):FlxPoint
	{
		return super.getScreenPosition(result, camera).add(offset2);
	}
	
	override function destroy()
	{
		super.destroy();
		offset2 = FlxDestroyUtil.put(offset2);
	}
}
