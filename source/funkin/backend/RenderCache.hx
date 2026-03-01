package funkin.backend;

import flixel.util.typeLimit.OneOfTwo;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.FlxGraphic;
import flixel.FlxBasic;

/**
 * Fix for lagspikes when a sprite is first drawn
 * 
 * creates dummys that are essentially invisible to be drawn to upload the graphic to gpu mem
 */
class RenderCache extends FlxBasic
{
	var _sprites:Array<FlxSprite> = [];
	
	var members:Array<FlxGraphic> = [];
	
	var renderTicks:Int = 0;
	
	public function push(obj:OneOfTwo<FlxSprite, FlxGraphic>)
	{
		var graphic:FlxGraphic = cast(obj is FlxSprite) ? (cast obj : FlxSprite).graphic : obj;
		
		if (graphic == null) return;
		
		if (graphic.key != null)
		{
			if (!FunkinAssets.cache.currentTrackedGraphics.exists(graphic.key)) FunkinAssets.cache.currentTrackedGraphics.set(graphic.key, graphic);
		}
		
		members.push(graphic);
	}
	
	public function render()
	{
		for (i in members)
		{
			var spr = new FlxSprite(i);
			spr.alpha = 0.001;
			_sprites.push(spr);
		}
		
		renderTicks = 3;
	}
	
	override function draw()
	{
		if (renderTicks > 0 && _sprites.length > 0)
		{
			renderTicks--;
			
			for (spr in _sprites)
			{
				@:privateAccess
				spr.drawComplex(FlxG.camera);
			}
			
			if (renderTicks == 0) // playing it safe by rendering 3 times over
			{
				cleanUp();
			}
		}
	}
	
	function cleanUp()
	{
		members.resize(0); // safe to do so i believe.
		
		while (_sprites.length > 0)
		{
			var spr = _sprites.pop();
			spr = FlxDestroyUtil.destroy(spr);
		}
	}
	
	override function destroy()
	{
		cleanUp();
		super.destroy();
	}
}
