#pragma header

uniform float meltPresence;
uniform float mosaic;

#define SIN01(a) (sin(a)*0.5 + 0.5)


vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}


void main()
{
    //pixelate
    vec2 size = openfl_TextureSize.xy / mosaic;
    vec2 uv = floor(openfl_TextureCoordv.xy * size) / size;

    // uv = fract(uv);
    //warp
    
    vec3 hsv = rgb2hsv(flixel_texture2D(bitmap, uv).rgb);
    
    float angle = hsv.x + atan(uv.y, uv.x) + meltPresence * 0.1;
    
    mat2 RotationMatrix = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));

    vec4 col = flixel_texture2D(bitmap, fract(uv + RotationMatrix * vec2(log(meltPresence * 0.2 + 1.0), 0.0) * hsv.y));

    
	gl_FragColor = col;
}