package funkin.shaders;

import flixel.system.FlxAssets.FlxShader;

class Mosaic extends FlxShader
{
	@:isVar
	public var pixelSize(get, set):Float = 1;
	
	function get_pixelSize()
	{
		return (pixel.value[0] + pixel.value[1]) / 2;
	}
	
	function set_pixelSize(v:Float)
	{
		pixel.value = [v, v];
		return v;
	}
	
	@:glFragmentSource('
        #pragma header

        uniform vec2 pixel;
		void main()
		{
            vec2 size = openfl_TextureSize.xy / pixel;
            gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv.xy * size) / size);
        }
    ')
	public function new()
	{
		super();
		pixel.value = [1, 1];
	}
}
