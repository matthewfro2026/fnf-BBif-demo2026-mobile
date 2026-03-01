package extensions.flixel.ui;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.addons.ui.FlxUISlider;

/**
 * Modified `FlxUISlider` to work correctly on different cameras
 */
class FlxUISliderEx extends FlxUISlider
{
	inline function ogUpdate(elapsed:Float)
	{
		group.update(elapsed);
		
		if (path != null && path.active) path.update(elapsed);
		
		if (moves) updateMotion(elapsed);
	}
	
	override function update(elapsed:Float)
	{
		// Clicking and sound logic
		final tempView = FlxG.mouse.getViewPosition(getDefaultCamera());
		
		if (FlxMath.pointInFlxRect(tempView.x, tempView.y, _bounds))
		{
			if (hoverAlpha != 1)
			{
				alpha = hoverAlpha;
			}
			
			#if FLX_SOUND_SYSTEM
			if (hoverSound != null && !_justHovered)
			{
				FlxG.sound.play(hoverSound);
			}
			#end
			
			_justHovered = true;
			
			if (FlxG.mouse.pressed)
			{
				handle.x = tempView.x;
				updateValue();
				
				#if FLX_SOUND_SYSTEM
				if (clickSound != null && !_justClicked)
				{
					FlxG.sound.play(clickSound);
					_justClicked = true;
				}
				#end
			}
			if (!FlxG.mouse.pressed)
			{
				_justClicked = false;
			}
		}
		else
		{
			if (hoverAlpha != 1)
			{
				alpha = 1;
			}
			
			_justHovered = false;
		}
		
		// Update the target value whenever the slider is being used
		if ((FlxG.mouse.pressed) && FlxMath.pointInFlxRect(tempView.x, tempView.y, _bounds))
		{
			updateValue();
		}
		
		// Update the value variable
		if ((varString != null) && (Reflect.getProperty(_object, varString) != null))
		{
			value = Reflect.getProperty(_object, varString);
		}
		
		// Changes to value from outside update the handle pos
		if (handle.x != expectedPos)
		{
			handle.x = expectedPos;
		}
		
		// Finally, update the valueLabel
		valueLabel.text = Std.string(FlxMath.roundDecimal(value, decimals));
		
		tempView.put();
		
		ogUpdate(elapsed);
	}
}
