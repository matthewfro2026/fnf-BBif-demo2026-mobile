package;

import funkin.objects.FunkinVideoSprite;
import funkin.backend.MusicBeatState;

import flixel.FlxG;
import flixel.util.FlxTimer;

class FlxSplashIntro extends MusicBeatState
{
	#if cpp
	var videoInstance:hxvlc.flixel.FlxVideo;
	#end
	
	override function create()
	{
		super.create();
		
		#if cpp
		videoInstance = new hxvlc.flixel.FlxVideo();
		
		FlxG.game.addChild(videoInstance);
		
		if (videoInstance.load(Paths.video('intro')))
		{
			videoInstance.onEndReached.add(exitState, true);
			
			FlxTimer.wait(0.001, () -> {
				videoInstance.play();
			});
		}
		else
		#end
		{
			exitState();
		}
	}
	
	function exitState()
	{
		#if cpp
		FlxG.game.removeChild(videoInstance);
		videoInstance?.dispose();
		videoInstance = null;
		#end
		
		FlxG.switchState(() -> #if debug Type.createInstance(Main.game.initialState, []) #else new TeachersLoungeIntro() #end);
	}
}
