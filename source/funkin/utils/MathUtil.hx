package funkin.utils;

class MathUtil
{
	/**
		crude version of FlxMath.wrap. supports floats though
	**/
	public static function wrap(value:Float, min:Float, max:Float):Float
	{
		if (value < min) return max;
		else if (value > max) return min;
		else return value;
	}
	
	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if (decimals < 1) return Math.floor(value);
		
		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;
			
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}
	
	inline public static function numberArray(?min:Int, max:Int):Array<Int>
	{
		if (min == null) min = 0;
		return [for (i in min...max) i];
	}
	
	public static function intClamp(input:Int, min:Int, max:Int):Int
	{
		if (input < min) input = min;
		if (input > max) input = max;
		return input;
	}
	
	// swap to this later
	public static function decayLerp(a:Float = 0, b:Float = 0, decay:Float = 1, elapsed:Float):Float
	{
		if (Math.abs(a - b) <= FlxMath.EPSILON) return b;
		return b + (a - b) * Math.exp(-decay * elapsed);
	}
}
