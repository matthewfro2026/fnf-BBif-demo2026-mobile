package funkin.backend;

import openfl.filters.ShaderFilter;

import funkin.shaders.DitherShader;

import flixel.system.FlxBGSprite;

import extensions.flixel.FlxUniformSprite;

// rewrite this
class DitherTransitionSubstate extends MusicBeatSubstate
{
	public static var finishCallback:Null<Void->Void> = null;
	
	public static var ditherTweener:Null<FlxTweenManager> = null;
	
	static function initManager()
	{
		if (ditherTweener == null) FlxG.plugins.addPlugin(ditherTweener = new FlxTweenManager());
		
		ditherTweener.forEach(tween -> tween.cancel());
	}
	
	var ditherShader:DitherShader = null;
	final transBlack:FlxSprite;
	final isTransIn:Bool;
	
	public function new(duration:Float, isTransIn:Bool)
	{
		initManager();
		super();
		this.isTransIn = isTransIn;
		
		camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		
		ditherShader = new DitherShader();
		ditherShader.color = FlxColor.BLACK;
		
		transBlack = new FlxUniformSprite().makeScaledGraphic(FlxG.width + 1, FlxG.height + 1, FlxColor.TRANSPARENT);
		transBlack.scrollFactor.set();
		add(transBlack);
		
		transBlack.shader = ditherShader;
		
		ditherShader.transparency = isTransIn ? 0 : 1;
		
		ditherTweener.tween(ditherShader, {transparency: isTransIn ? 1 : 0}, duration, {onComplete: Void -> onFinish()});
	}
	
	function onFinish()
	{
		ditherShader = null;
		
		if (finishCallback != null) finishCallback();
		finishCallback = null;
		FlxTimer.wait(0, close);
	}
}
