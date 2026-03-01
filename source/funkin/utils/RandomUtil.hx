package funkin.utils;

class RandomUtil
{
	public static function shuffle<T>(array:Array<T>)
	{
		var maxValidIndex = array.length - 1;
		for (i in 0...maxValidIndex)
		{
			var j = FlxG.random.int(i, maxValidIndex);
			var tmp = array[i];
			array[i] = array[j];
			array[j] = tmp;
		}
	}
	
	public static function getObject<T>(objects:Array<T>, ?weightsArray:Array<Float>, startIndex:Int = 0, ?endIndex:Null<Int>)
	{
		var selected:Null<T> = null;
		
		if (objects.length != 0)
		{
			weightsArray ??= [for (i in 0...objects.length) 1];
			
			endIndex ??= objects.length - 1;
			
			startIndex = Std.int(FlxMath.bound(startIndex, 0, objects.length - 1));
			endIndex = Std.int(FlxMath.bound(endIndex, 0, objects.length - 1));
			
			// Swap values if reversed
			if (endIndex < startIndex)
			{
				startIndex = startIndex + endIndex;
				endIndex = startIndex - endIndex;
				startIndex = startIndex - endIndex;
			}
			
			if (endIndex > weightsArray.length - 1)
			{
				endIndex = weightsArray.length - 1;
			}
			
			final arrayHelper = [for (i in startIndex...endIndex + 1) weightsArray[i]];
			
			selected = objects[startIndex + FlxG.random.weightedPick(arrayHelper)];
		}
		
		return selected;
	}
}
