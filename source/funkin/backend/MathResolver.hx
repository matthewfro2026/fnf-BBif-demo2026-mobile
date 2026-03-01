package funkin.backend;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.FlxBasic;

class MathResolver extends FlxBasic // to be added to the state and be more self dependent ok. //not done will be replacing math stuff later
{
	public var onResolved:FlxTypedSignal<Bool->Void> = new FlxTypedSignal();
	
	public var onKeyPress:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	
	public var isInMath:Bool = false;
	
	public var lockInputs:Bool = false;
	
	public var intendedValue:Int = 0;
	public var value1:Int = 1;
	public var value2:Int = 1;
	public var isAddition:Bool = true;
	
	public var input = "";
	
	var numLength:Int = 0;
	
	public function new()
	{
		super();
		this.visible = false;
	}
	
	public function start(value1:Int, value2:Int, isAddition:Bool = true)
	{
		if (this.isInMath)
		{
			// u already were in math so we can assume u failed
			resolveMath();
		}
		
		this.value1 = value1;
		this.value2 = value2;
		this.isAddition = isAddition;
		this.lockInputs = false;
		this.input = "";
		
		this.intendedValue = this.isAddition ? (this.value1 + this.value2) : (this.value1 - this.value2);
		
		numLength = Std.string(intendedValue).length;
		
		trace(numLength);
		
		this.isInMath = true;
		
		disableKeys();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (isInMath && lockInputs == false)
		{
			var keyPress:FlxKey = FlxG.keys.firstJustPressed();
			
			if (keyPress != NONE)
			{
				var numToType:String = '';
				switch (keyPress)
				{
					case ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE:
						numToType = Std.string((cast keyPress : Int) - 48);
						
					case NUMPADZERO, NUMPADONE, NUMPADTWO, NUMPADTHREE, NUMPADFOUR, NUMPADFIVE, NUMPADSIX, NUMPADSEVEN, NUMPADEIGHT, NUMPADNINE:
						numToType = Std.string((cast keyPress : Int) - 96);
						
					case MINUS, NUMPADMINUS:
						numToType = '-';
						
					default:
						return;
				}
				// // NUMPAD
				// if (keyPress >= 96 && keyPress < 106) keyPress = keyPress - 96;
				
				// // NUMBERS ABOVE LETTERS IDK HOW ITS CALLED
				// else if (keyPress >= 48 && keyPress < 58) keyPress = keyPress - 48;
				
				input += numToType;
				
				onKeyPress.dispatch(keyPress);
				
				if (input.length >= numLength) resolveMath();
			}
		}
	}
	
	public function resolveMath()
	{
		if (!isInMath)
		{
			return;
		}
		isInMath = false;
		
		trace(Std.parseInt(input) == intendedValue);
		onResolved.dispatch(Std.parseInt(input) == intendedValue);
	}
	
	@:access(funkin.states.PlayState)
	public function disableKeys(val:Bool = true)
	{
		if (PlayState.instance != null)
		{
			PlayState.instance.allowDebugKeys = !val;
			PlayState.instance.canReset = !val;
		}
		FlxG.sound.muteKeys = val ? [] : InitState.muteKeys;
		FlxG.sound.volumeDownKeys = val ? [] : InitState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = val ? [] : InitState.volumeUpKeys;
	}
	
	override function destroy()
	{
		disableKeys(false);
		
		onResolved.removeAll();
		onKeyPress.removeAll();
		super.destroy();
	}
}
