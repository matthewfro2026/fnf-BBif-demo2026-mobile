package funkin.shaders;

import flixel.system.FlxAssets.FlxShader;

class PolyTextShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header

	float _round(float n) 
    {
		return floor(n + 0.5);
	}

    void main() {
        vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);

        gl_FragColor = vec4(_round(tex.r), _round(tex.g), _round(tex.b), _round(tex.a));
    }
    ')
	public function new()
	{
		super();
	}
}
