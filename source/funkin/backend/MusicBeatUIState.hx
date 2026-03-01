package funkin.backend;

class MusicBeatUIState extends MusicBeatState
{
	public var to1080P(default, set):Bool = false;
	
	override function create()
	{
		super.create();
		FlxG.mouse.visible = true;
	}
	
	@:noCompletion private function set_to1080P(value:Bool):Bool
	{
		if (value)
		{
			if (!_psychCameraInitialized) initPsychCamera();
			// _psychCameraInitialized = true;
			FlxG.camera.zoom = 1280 / 1920;
			FlxG.camera.scroll.x = (1920 - 1280) / 2;
			FlxG.camera.scroll.y = (1080 - 720) / 2;
		}
		else
		{
			FlxG.camera.zoom = 1;
			FlxG.camera.scroll.x = 0;
			FlxG.camera.scroll.y = 0;
		}
		
		return value;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Conductor.songPosition = (FlxG.sound.music != null ? FlxG.sound.music.time : 0);
	}
	
	public static function setCamTo1080(cam:FlxCamera)
	{
		cam.zoom = 1280 / 1920;
		cam.scroll.x = (1920 - 1280) / 2;
		cam.scroll.y = (1080 - 720) / 2;
	}
}
