package funkin.plugins;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxBasic;

/**
 * Press F1 to reset the state and clear cached memory.
 */
class HotReloadPlugin extends FlxBasic
{
	public static var instance:Null<HotReloadPlugin> = null;
	
	public static function init()
	{
		if (instance == null) FlxG.plugins.addPlugin(instance = new HotReloadPlugin());
	}
	
	public function new()
	{
		super();
		this.visible = false;
	}
	
	override function update(e:Float)
	{
		if (FlxG.keys.justPressed.F5)
		{
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else if (FlxG.keys.justPressed.F6)
		{
			FlxG.signals.preStateCreate.addOnce((state) -> {
				FunkinAssets.cache.clearStoredMemory();
				FunkinAssets.cache.clearUnusedMemory();
			});
			
			FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
	}
}
