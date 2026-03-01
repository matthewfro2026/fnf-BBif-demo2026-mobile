package funkin.options;

import funkin.objects.Character;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; // for Discord Rich Presence
		
		// I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		// var option:Option = new Option('Low Quality', // Name
		// 	'If checked, disables some background details,\ndecreases loading times and improves performance.', // Description
		// 	'lowQuality', // Save data variable name
		// 	'bool'); // Variable type
		// addOption(option);
		
		var option:Option = new Option('Anti-Aliasing', 'If unchecked, disables anti-aliasing, improves performance\nat the cost of sharper visuals.', 'antialiasing', 'bool');
		option.onChange = onChangeAntiAliasing; // Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		
		var option:Option = new Option('Shaders', // Name
			"If unchecked, shaders considered non essential will be disabled. Improves performance on lower end hardware.", // Description
			'shaders', 'bool');
		addOption(option);
		
		var option:Option = new Option('GPU Caching', // Name
			"If checked, Clears the images RAM buffer improving memory usage.", // Description
			'cacheOnGPU', 'bool');
		addOption(option);
		
		// var option:Option = new Option('Multi-Threading', // Name
		// 	"If checked, allows for multithreaded loading, improving general load times.\nMay not work on some PCs.", // Description
		// 	'multithreading', 'bool');
		// addOption(option);
		
		#if !html5 // Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate', "self explanatory.", 'framerate', 'int');
		addOption(option);
		
		final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
		option.minValue = 60;
		option.maxValue = 240;
		option.defaultValue = Std.int(FlxMath.bound(refreshRate, option.minValue, option.maxValue));
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end
		
		super();
	}
	
	function onChangeAntiAliasing()
	{
		FlxG.state.forEachOfType(FlxSprite, spr -> {
			if (spr != null)
			{
				spr.antialiasing = ClientPrefs.data.antialiasing;
			}
		}, true);
		
		forEachOfType(FlxSprite, spr -> {
			if (spr != null)
			{
				spr.antialiasing = ClientPrefs.data.antialiasing;
			}
		}, true);
		
		FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;
	}
	
	function onChangeFramerate()
	{
		if (ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}
	
	override function changeSelection(change:Int = 0, directSelection:Bool = false)
	{
		super.changeSelection(change);
	}
}
