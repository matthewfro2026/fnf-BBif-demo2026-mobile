package funkin.shaders;

import flixel.system.FlxAssets.FlxShader;

class DitherShader extends FlxShader
{
	@:isVar public var color(get, set):FlxColor;
	
	function set_color(value:FlxColor):FlxColor
	{
		this.uColor.value = [value.red / 255, value.green / 255, value.blue / 255, value.alpha / 255];
		return value;
	}
	
	function get_color():FlxColor
	{
		return color;
	}
	
	@:isVar
	public var transparency(get, set):Float = 0;
	
	function set_transparency(v:Float):Float
	{
		this.opacity.value = [v, v];
		return v;
	}
	
	function get_transparency():Float
	{
		return this.opacity.value[0];
	}
	
	@:glFragmentSource('
    #pragma header

    uniform float opacity;
    uniform vec4 uColor;

    uniform vec2 gameSize;

    vec2 modu(vec2 x, float y) {
        return x - y * floor(x/y);
    }

    void main() {
        vec2 pos = openfl_TextureCoordv * gameSize / 4.0;
        pos = floor(modu(pos, 4.0));
    
        float ratio = 16.0;
        if (pos.x == 0.0 && pos.y == 0.0) ratio = 0.0;
        else if (pos.x == 2.0 && pos.y == 0.0) ratio = 1.0;
        else if (pos.x == 2.0 && pos.y == 2.0) ratio = 2.0;
        else if (pos.x == 0.0 && pos.y == 2.0) ratio = 3.0;
        else if (pos.x == 1.0 && pos.y == 1.0) ratio = 4.0;
        else if (pos.x == 3.0 && pos.y == 1.0) ratio = 5.0;
        else if (pos.x == 3.0 && pos.y == 3.0) ratio = 6.0;
        else if (pos.x == 1.0 && pos.y == 3.0) ratio = 7.0;
    
        else if (pos.x == 1.0 && pos.y == 0.0) ratio = 8.0;
        else if (pos.x == 3.0 && pos.y == 0.0) ratio = 9.0;
        else if (pos.x == 3.0 && pos.y == 2.0) ratio = 10.0;
        else if (pos.x == 1.0 && pos.y == 2.0) ratio = 11.0;
        else if (pos.x == 0.0 && pos.y == 1.0) ratio = 12.0;
        else if (pos.x == 2.0 && pos.y == 1.0) ratio = 13.0;
        else if (pos.x == 2.0 && pos.y == 3.0) ratio = 14.0;
        else if (pos.x == 0.0 && pos.y == 3.0) ratio = 15.0;
        ratio /= 16.0;
        
        if (opacity <= ratio)
            gl_FragColor = uColor;
        else
            gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
    }
    ')
	public function new()
	{
		super();
		this.opacity.value = [0, 0];
		this.color = FlxColor.TRANSPARENT;
		this.gameSize.value = [1920, 1080];
	}
}
