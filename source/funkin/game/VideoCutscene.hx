package funkin.game;

import funkin.backend.InputFormatter;
import funkin.backend.DitherTransitionSubstate;

import flixel.addons.display.FlxPieDial;

import debug.FPSCounter;

import flixel.FlxBasic;
import flixel.util.FlxDestroyUtil;

import funkin.shaders.DitherShader;
import funkin.objects.FunkinVideoSprite;

using flixel.util.FlxArrayUtil;

#if !hxvlc
class VideoCutscene extends FlxBasic
{
	static var finishCallback:Null<Void->Void> = null;
	
	public static function load(filePath:String, ?finishCallback:Void->Void)
	{
		VideoCutscene.finishCallback = finishCallback;
		
		return true;
	}
	
	public static function playVideo(ditherOnFinish:Bool = false)
	{
		if (finishCallback != null) finishCallback();
		finishCallback = null;
		
		return true;
	}
}
#else
// unfinished
class VideoCutscene extends FlxBasic
{
	static var instance:Null<VideoCutscene> = null;
	
	public static function instantiate()
	{
		if (instance != null)
		{
			FlxG.state.remove(instance, true);
			
			instance = FlxDestroyUtil.destroy(instance);
		}
		
		instance = new VideoCutscene();
	}
	
	public static function load(filePath:String, ?finishCallback:Void->Void)
	{
		instantiate();
		
		instance.filePath = filePath;
		
		if (finishCallback != null) instance.finishCallback = finishCallback;
		
		instance.isLoaded = instance.videoPlayer.load(Paths.video(filePath));
		
		return instance.isLoaded;
	}
	
	public static function playVideo(ditherOnFinish:Bool = false):Bool
	{
		if (instance == null) return false;
		
		if (!instance.isLoaded) return false;
		
		instance.ditherOnFinish = ditherOnFinish;
		
		instance.play();
		if (FlxG.state.members.indexOf(instance) == -1) FlxG.state.add(instance);
		instance.cameras = [FlxG.cameras.list.last()];
		
		return true;
	}
	
	//
	var finishCallback:Null<Void->Void> = null;
	
	var filePath:String = '';
	
	var isLoaded:Bool = false;
	
	var ditherOnFinish:Bool = false;
	
	public var videoPlayer(default, null):FunkinVideoSprite;
	
	var ditherShader(default, null):DitherShader;
	
	var skipDial(default, null):FlxPieDial;
	
	var bg(default, null):FlxSprite;
	
	var textUnder(default, null):FlxSprite;
	
	var text(default, null):FlxText;
	
	public function new()
	{
		super();
		skipDial = new FlxPieDial(0, 0, 40, FlxColor.WHITE, 48, null, true, 20);
		
		skipDial.x = FlxG.width - skipDial.width - 20;
		skipDial.y = FlxG.height - skipDial.height - 20;
		
		ditherShader = new DitherShader();
		ditherShader.color = FlxColor.BLACK;
		ditherShader.transparency = 1;
		
		bg = new FlxSprite().makeScaledGraphic(FlxG.width + 5, FlxG.height + 5, FlxColor.BLACK);
		
		videoPlayer = new FunkinVideoSprite(0, 0, false);
		videoPlayer.visible = false;
		
		if (!videoPlayer.bitmap.onFormatSetup.has(onStart)) videoPlayer.bitmap.onFormatSetup.add(onStart);
		
		videoPlayer.onEnd(finished, true);
		
		textUnder = new FlxSprite().makeScaledGraphic(FlxG.width + 5, 40, FlxColor.BLACK);
		textUnder.y = FlxG.height - textUnder.height;
		
		var skipKeys = ['Enter'].concat([for (i in ClientPrefs.keyBinds.get('accept')) InputFormatter.getKeyName(i)]).join(' | ');
		text = new FlxText(0, 0, FlxG.width, 'Hold $skipKeys to Skip', 32);
		text.y = FlxG.height - text.height;
		
		text.alignment = CENTER;
		text.font = Paths.font('comic.ttf');
	}
	
	function onStart()
	{
		FPSCounter.instance.visible = false;
		videoPlayer.setGraphicSize(0, FlxG.height);
		videoPlayer.updateHitbox();
		videoPlayer.screenCenter();
		
		// videoPlayer.shader = ditherShader;
	}
	
	var canExit:Bool = true;
	var holdTimer:Float = 0;
	
	var interactedTimer:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (!canExit) return;
		
		handleSkipInput(elapsed);
		
		skipDial.amount = holdTimer;
		
		if (holdTimer == 1)
		{
			canExit = false;
			skip();
		}
	}
	
	function handleSkipInput(elapsed:Float)
	{
		if (FlxG.keys.pressed.ENTER || Controls.instance.pressed('accept') || FlxG.mouse.pressed)
		{
			holdTimer += elapsed;
		}
		else
		{
			holdTimer -= elapsed;
		}
		
		holdTimer = Math.max(0, Math.min(1, holdTimer));
		
		var key = FlxG.keys.firstJustPressed();
		var button = FlxG.gamepads.getFirstActiveGamepad()?.firstJustPressedID() ?? -1;
		
		if (InitState.volumeDownKeys.contains(key) || InitState.volumeUpKeys.contains(key)) key = -1;
		
		if (key != -1 || FlxG.mouse.justPressed || button != -1) interactedTimer = 2;
		
		interactedTimer -= elapsed;
		
		interactedTimer = Math.max(0, interactedTimer);
		
		textUnder.alpha = interactedTimer;
		textUnder.alpha *= 0.3;
		
		text.alpha = interactedTimer;
	}
	
	public function skip()
	{
		videoPlayer.stop();
		finished();
	}
	
	public function play()
	{
		if (isLoaded) videoPlayer.delayAndStart();
		else finished();
	}
	
	public function finished()
	{
		// kill();
		
		FPSCounter.instance.visible = ClientPrefs.data.showFPS;
		
		if (ditherOnFinish)
		{
			ditherShader.color = FlxColor.TRANSPARENT;
			
			CoolUtil.addShader(ditherShader, camera);
			
			DitherTransitionSubstate.ditherTweener.tween(ditherShader, {transparency: 0}, 1, {onComplete: Void -> triggerFinishCallback()});
		}
		else
		{
			triggerFinishCallback();
		}
	}
	
	function triggerFinishCallback()
	{
		if (finishCallback != null) finishCallback();
		finishCallback = null;
		
		CoolUtil.removeShader(ditherShader, camera);
		
		instance = FlxDestroyUtil.destroy(instance);
	}
	
	override function draw()
	{
		if (!visible) return;
		
		bg.cameras = getCameras();
		videoPlayer.cameras = getCameras();
		skipDial.cameras = getCameras();
		textUnder.cameras = getCameras();
		text.cameras = getCameras();
		
		bg.draw();
		videoPlayer.draw();
		
		textUnder.draw();
		text.draw();
		skipDial.draw();
		
		super.draw();
	}
	
	override function destroy()
	{
		FPSCounter.instance.visible = ClientPrefs.data.showFPS;
		
		bg = FlxDestroyUtil.destroy(bg);
		videoPlayer.stop();
		videoPlayer = FlxDestroyUtil.destroy(videoPlayer);
		skipDial = FlxDestroyUtil.destroy(skipDial);
		textUnder = FlxDestroyUtil.destroy(textUnder);
		text = FlxDestroyUtil.destroy(text);
		finishCallback = null;
		
		ditherShader = null;
		super.destroy();
	}
}
#end
