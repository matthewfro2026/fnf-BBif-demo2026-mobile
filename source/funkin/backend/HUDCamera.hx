package funkin.backend;

import openfl.filters.ShaderFilter;

/**
 * FlxCamera modified for improved alpha changing via filter
 * 
 * maybe die idk if its too laggy for people?
 */
class HUDCamera extends FlxCamera
{
	public var alphaShader:AlphaShader;
	
	public function new(x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, zoom:Float = 0)
	{
		super(x, y, width, height, zoom);
		filters = [new ShaderFilter(alphaShader = new AlphaShader())];
	}
	
	override function set_alpha(Alpha:Float):Float
	{
		alpha = FlxMath.bound(Alpha, 0, 1);
		
		alphaShader.alphaVal.value = [alpha, alpha];
		
		return Alpha;
	}
}

class AlphaShader extends flixel.system.FlxAssets.FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform float alphaVal;

		void main()
		{
			gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv) * alphaVal;
		}')
	public function new()
	{
		super();
		this.alphaVal.value = [1, 1];
	}
}
