package funkin.states.freeplay;

import funkin.backend.Highscore;
import funkin.plugins.MousePlugin;

import flixel.math.FlxRect;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import flixel.system.FlxBGSprite;

import extensions.flixel.FlxUniformSprite;

import flixel.FlxSubState;
import flixel.graphics.tile.FlxGraphicsShader;

class LessonPopUp extends MusicBeatSubstate
{
	var bg:FlxBGSprite;
	var ruler:Offset2Uniform;
	var glow:Offset2Uniform;
	var goodMix:Offset2Uniform;
	var badMix:Offset2Uniform;
	
	var curSel:Int = -1;
	
	var canInteract:Bool = false;
	
	override function create()
	{
		super.create();
		
		inline function to720(spr:FlxSprite)
		{
			spr.x *= 0.67;
			spr.y *= 0.67;
			spr.scale.scale(0.67);
			spr.updateHitbox();
		}
		
		bg = new FlxBGSprite();
		bg.color = FlxColor.BLACK;
		bg.alpha = 0.6;
		add(bg);
		
		glow = new Offset2Uniform(423, 31, Paths.image('menus/freeplay/gradient'));
		to720(glow);
		add(glow);
		
		ruler = new Offset2Uniform(608, 263, Paths.image('menus/freeplay/ruler'));
		to720(ruler);
		add(ruler);
		
		goodMix = new Text(483, 251, Paths.image('menus/freeplay/goodMath'));
		to720(goodMix);
		add(goodMix);
		
		goodMix.width *= 0.8;
		
		badMix = new Text(928, 536, Paths.image('menus/freeplay/badMath'));
		to720(badMix);
		add(badMix);
		
		goodMix.shader = new OutlineShader();
		badMix.shader = new OutlineShader();
		
		bg.alpha = 0;
		glow.alpha = 0;
		badMix.alpha = 0;
		goodMix.alpha = 0;
		
		ruler.angle = 360;
		ruler.offset2.y = FlxG.height;
		
		#if mobile
		addVirtualPad(NONE, A_B);
		addVirtualPadCamera();
		#end
		
		FlxG.sound.play(Paths.sound('freeplay/ruler ok'));
		
		FlxTween.tween(bg, {alpha: 0.6}, 0.7);
		FlxTween.tween(ruler, {angle: 0, 'offset2.y': 0}, 0.7, {ease: FlxEase.cubeOut, framerate: 24});
		
		FlxTween.tween(glow, {alpha: 1}, 0.2, {startDelay: 0.6, framerate: 24});
		
		FlxTween.tween(goodMix, {alpha: 1}, 0.3, {startDelay: 0.6, framerate: 24});
		FlxTween.tween(badMix, {alpha: 1}, 0.3, {startDelay: 0.6, framerate: 24});
		
		FlxTimer.wait(0.8, () -> canInteract = true);
	}
	
	function transitionOut()
	{
		FlxG.sound.play(Paths.sound('freeplay/ruler back'));
		
		removeVirtualPad();
		
		FlxTween.tween(glow, {alpha: 0}, 0.2, {framerate: 24});
		FlxTween.tween(goodMix, {alpha: 0}, 0.3, {framerate: 24});
		FlxTween.tween(badMix, {alpha: 0}, 0.3, {framerate: 24});
		
		FlxTween.tween(ruler, {angle: -360, 'offset2.y': FlxG.height}, 0.7, {ease: FlxEase.cubeIn, framerate: 24});
		
		FlxTween.tween(bg, {alpha: 0}, 0.4, {startDelay: 0.5, framerate: 24});
		
		FlxTimer.wait(1.2, () -> {
			@:privateAccess
			(cast FlxG.state : FreeplayState).canInteract = true;
			close();
		});
	}
	
	var mousePos:FlxPoint = FlxPoint.get();
	var _e:Float = 0;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canInteract)
		{
			var point = MousePlugin.instance.getRawPosition();
			
			final ret = mousePos.x != point.x || mousePos.y != point.y;
			
			point.put();
			
			if (ret)
			{
				if (curSel != 0 && mouseOver(goodMix))
				{
					playSound(true);
					
					// curSel = 0;
					changeSel(0);
				}
				else if (curSel != 1 && mouseOver(badMix))
				{
					playSound(false);
					changeSel(1);
					
					// curSel = 1;
				}
				if (curSel != -1 && (FlxG.mouse.justPressed && (mouseOver(goodMix) || mouseOver(badMix))))
				{
					canInteract = false;
					@:privateAccess
					(cast FlxG.state : FreeplayState).loadSong('lesson' + (curSel == 0 ? '-good' : ''), false);
					
					CoolUtil.playUISound('freeplay/ding goodiebag rizz at the wawa');
					
					FlxG.sound.music.fadeOut(1.2);
					
					snd?.fadeOut(0.6);
					
					@:privateAccess
					{
						FlxTween.tween((cast FlxG.state : FreeplayState).ditherShader, {transparency: -1}, 0.4);
						
						FlxG.camera._fxFadeColor = FlxColor.BLACK;
						FlxTween.tween(FlxG.camera, {_fxFadeAlpha: 1}, 0.9,
							{
								startDelay: 0.2,
								onComplete: Void -> CoolUtil.switchStateAndStopMusic(() -> new PlayState())
							});
					}
				}
			}
			else if (controls.UI_DOWN_P || controls.UI_UP_P || controls.UI_LEFT_P || controls.UI_RIGHT_P)
			{
				changeSel(curSel + 1);
				
				playSound(curSel == 0);
			}
			else if (curSel != -1 && (controls.ACCEPT || (FlxG.mouse.justPressed && (mouseOver(goodMix) || mouseOver(badMix)))))
			{
				canInteract = false;
				@:privateAccess
				(cast FlxG.state : FreeplayState).loadSong('lesson' + (curSel == 0 ? '-good' : ''), false);
				
				CoolUtil.playUISound('freeplay/ding goodiebag rizz at the wawa');
				
				FlxG.sound.music.fadeOut(1.2);
				
				snd?.fadeOut(0.6);
				
				@:privateAccess
				{
					FlxTween.tween((cast FlxG.state : FreeplayState).ditherShader, {transparency: -1}, 0.4);
					
					FlxG.camera._fxFadeColor = FlxColor.BLACK;
					FlxTween.tween(FlxG.camera, {_fxFadeAlpha: 1}, 0.9,
						{
							startDelay: 0.2,
							onComplete: Void -> CoolUtil.switchStateAndStopMusic(() -> new PlayState())
						});
				}
			}
			else if (controls.BACK #if mobile || virtualPad.buttonA.justPressed #end || FlxG.mouse.justPressedRight)
			{
				canInteract = false;
				transitionOut();
			}
		}
		
		_e += elapsed;
		
		final goalX = FlxMath.fastSin((180 / Math.PI) * _e * 0.05) * 3;
		final goalY = FlxMath.fastCos((180 / Math.PI) * _e * 0.05) * 3;
		
		final lerpRate = 1 - Math.exp(-elapsed * 4);
		
		goodMix.offset2.x = FlxMath.lerp(goodMix.offset2.x, curSel == 0 ? goalX : 0, lerpRate);
		goodMix.offset2.y = FlxMath.lerp(goodMix.offset2.y, curSel == 0 ? goalY : 0, lerpRate);
		
		badMix.offset2.x = FlxMath.lerp(badMix.offset2.x, curSel == 1 ? goalX : 0, lerpRate);
		badMix.offset2.y = FlxMath.lerp(badMix.offset2.y, curSel == 1 ? goalY : 0, lerpRate);
		
		lerpShaders(1 - Math.exp(-elapsed * 8));
		
		mousePos = MousePlugin.instance.getRawPosition(mousePos);
	}
	
	inline function changeSel(newSel:Int)
	{
		curSel = FlxMath.wrap(newSel, 0, 1);
		
		var state:FreeplayState = cast FlxG.state;
		
		@:privateAccess
		{
			state.refreshSongFormat();
			
			var songName = curSel == 0 ? 'Lesson-good' : 'Lesson';
			final grade = state.getGrade(Highscore.getRating(songName, state.curDifficulty));
			
			state.scoreText.text = "YSP's: " + state.getScore(songName) + '\nGRADE: ' + grade;
			
			state.gradeFormat.format.color = state.getGradeColour(grade);
			
			state.scoreText._formatRanges[0].range.start = state.scoreText.text.length - grade.length;
			
			state.scoreText._formatRanges[0].range.end = state.scoreText.text.length;
			
			state.updatePos();
		}
	}
	
	var snd:Null<FlxSound> = null;
	
	function playSound(good:Bool = true)
	{
		snd ??= FlxG.sound.load(Paths.sound('freeplay/good hover'));
		
		snd.stop();
		snd.loadEmbedded(Paths.sound('freeplay/' + (good ? 'good' : 'bad') + ' hover'));
		snd.play();
	}
	
	inline function lerpShaders(rate:Float)
	{
		var goodShader = (cast goodMix.shader : OutlineShader);
		var badShader = (cast badMix.shader : OutlineShader);
		
		final goodGoal = canInteract ? curSel == 0 ? 3 : 0 : 0;
		final badGoal = canInteract ? curSel == 1 ? 3 : 0 : 0;
		
		goodShader.thickness = FlxMath.lerp(goodShader.thickness, goodGoal, rate);
		badShader.thickness = FlxMath.lerp(badShader.thickness, badGoal, rate);
		
		if (Math.abs(goodShader.thickness - goodGoal) <= FlxMath.EPSILON)
		{
			goodShader.thickness = goodGoal;
		}
		
		if (Math.abs(badShader.thickness - badGoal) <= FlxMath.EPSILON)
		{
			badShader.thickness = badGoal;
		}
	}
	
	inline function mouseOver(spr:FlxSprite)
	{
		// flxg.mouse.gameposition or whatever does not work so we are recreating it
		@:privateAccess
		final mouse = FlxPoint.get((FlxG.stage.__mouseX / FlxG.scaleMode.scale.x)
			- (FlxG.game.x / FlxG.scaleMode.scale.x), (FlxG.stage.__mouseY / FlxG.scaleMode.scale.y)
			- (FlxG.game.y / FlxG.scaleMode.scale.y));
			
		final ret = mouse.x >= spr.x && mouse.y >= spr.y && mouse.x <= (spr.x + spr.width) && mouse.y <= (spr.y + spr.height);
		
		mouse.put();
		
		return ret;
	}
}

private class Text extends Offset2Uniform
{
	override function draw()
	{
		var lastX = x;
		var lastY = y;
		var lastAlpha = alpha;
		var lastShader = shader;
		
		color = FlxColor.GRAY;
		
		x -= 5;
		y += 5;
		alpha *= 0.6;
		shader = null;
		
		super.draw();
		
		x = lastX;
		y = lastY;
		alpha = lastAlpha;
		shader = lastShader;
		
		color = FlxColor.WHITE;
		super.draw();
	}
}

private class Offset2Uniform extends FlxUniformSprite
{
	public var offset2:FlxPoint;
	
	public function new(x:Float = 0, y:Float = 0, ?graphic:FlxGraphicAsset)
	{
		super(x, y, graphic);
		offset2 = new FlxPoint();
	}
	
	override function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);
		
		if (bakedRotationAngle <= 0)
		{
			updateTrig();
			if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		
		_point ??= FlxPoint.get();
		_point.set(x, y);
		if (pixelPerfectPosition) _point.floor();
		
		_point.subtract(offset).add(offset2);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);
		
		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}
		
		var _rect = FlxRect.get()
			.set(camera.width * 0.5, camera.height * 0.5, (camera.scaleX > 0 ? Math.max : Math.min)(0, 1 / camera.scaleX), (camera.scaleY > 0 ? Math.max : Math.min)(0, 1 / camera.scaleY));
			
		_matrix.setTo(_matrix.a * _rect.width, _matrix.b * _rect.height, _matrix.c * _rect.width, _matrix.d * _rect.height, (_matrix.tx - _rect.x) * _rect.width
			+ _rect.x, (_matrix.ty - _rect.y) * _rect.height
			+ _rect.y,);
			
		_rect.put();
		
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}
	
	override function destroy()
	{
		offset2 = FlxDestroyUtil.put(offset2);
		super.destroy();
	}
}

class OutlineShader extends FlxGraphicsShader
{
	public var thickness(default, set):Float = 0;
	
	@:glFragmentSource("
        #pragma header
        //main part
        //https://www.shadertoy.com/view/csc3W8

        uniform float u_thickness;

        vec2 complexRot(vec2 a,vec2 b)
        {
            return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
        }

        void main()
        {
            vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);

            float otl = 0.0;
            vec2 dir = vec2(1.0, 0.0);
            vec2 roter = vec2(0.866, 0.5);


            for(int i = 0; i < 12; i++)//360/12 degree/times rotation
            {
                dir = complexRot(dir, roter);
                otl += flixel_texture2D(bitmap, ((openfl_TextureCoordv * openfl_TextureSize) + (dir * u_thickness)) / openfl_TextureSize.xy).w;
            }

            otl = min(1.0, otl);
            tex.xyz = mix(vec3(1.0) * otl, tex.xyz, tex.w);

            tex.rgb = mix(flixel_texture2D(bitmap, openfl_TextureCoordv).rgb, tex.rgb, max(0.0, u_thickness / 3.0));

            gl_FragColor = tex;
        }
	")
	public function new()
	{
		super();
		this.u_thickness.value = [0, 0];
	}
	
	function set_thickness(value:Float):Float
	{
		return thickness = this.u_thickness.value[0] = value;
	}
}