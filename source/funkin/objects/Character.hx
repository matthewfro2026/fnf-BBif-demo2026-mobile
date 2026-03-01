package funkin.objects;

import funkin.objects.OffsetSprite.OffsetAnimate;
import funkin.backend.animation.PsychAnimationController;

import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;

import openfl.utils.AssetType;
import openfl.utils.Assets;

import haxe.Json;

import funkin.backend.Song;

typedef CharacterFile =
{
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;
	
	var position:Array<Float>;
	var camera_position:Array<Float>;
	
	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	@:optional var _editor_isPlayer:Null<Bool>;
	@:optional var pauseDuringSustains:Null<Bool>;
}

typedef AnimArray =
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends OffsetSprite
{
	/**
	 * In case a character is missing, it will use this on its place
	**/
	public static final DEFAULT_CHARACTER:String = 'baldi-alt';
	
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();
	
	public var isPlayer:Bool = false;
	public var isGF:Bool = false;
	
	public var curCharacter:String = DEFAULT_CHARACTER;
	
	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; // Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; // Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;
	public var skipOffset:Bool = false;
	
	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];
	
	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var healthColorArray:Array<Int> = [255, 0, 0];
	
	public var hasMissAnimations:Bool = false;
	
	// Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var editorIsPlayer:Null<Bool> = null;
	
	public var pauseAnimForSustain:Bool = true;
	public var currentlyHolding:Bool = false;
	
	public var camZoomAdd:Null<Float> = null;
	
	public var animationSuffix:String = '';
	
	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false)
	{
		super(x, y);
		
		animation = new PsychAnimationController(this);
		
		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		switch (curCharacter)
		{
			// case 'your character name in case you want to hardcode them instead':
			
			default:
				var characterPath:String = 'characters/$curCharacter.json';
				
				var path:String = Paths.getPath(characterPath, TEXT, null, true);
				#if MODS_ALLOWED
				if (!FileSystem.exists(path))
				#else
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getSharedPath('characters/' + DEFAULT_CHARACTER + '.json'); // If a character couldn't be found, change him to BF just to prevent a crash
				}
				
				try
				{
					#if MODS_ALLOWED
					loadCharacterFile(Json.parse(File.getContent(path)));
					#else
					loadCharacterFile(Json.parse(Assets.getText(path)));
					#end
				}
				catch (e:Dynamic)
				{
					trace('Error loading character file of "$character": $e');
				}
		}
		
		if (animOffsets.exists('singLEFTmiss') || animOffsets.exists('singDOWNmiss') || animOffsets.exists('singUPmiss') || animOffsets.exists('singRIGHTmiss')) hasMissAnimations = true;
		recalculateDanceIdle();
		dance();
	}
	
	public function loadCharacterFile(json:Dynamic)
	{
		isAnimateAtlas = false;
		
		#if flixel_animate
		var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT, null, true);
		if (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind)) isAnimateAtlas = true;
		#end
		
		scale.set(1, 1);
		updateHitbox();
		
		if (!isAnimateAtlas)
		{
			frames = Paths.getMultiAtlas(json.image.split(','), null, json.allowGPU);
		}
		#if flixel_animate
		else
		{
			atlas = new OffsetAnimate();
			try
			{
				Paths.loadAnimateAtlas(atlas, json.image);
			}
			catch (e)
			{
				FlxG.log.warn('Could not load atlas ${json.image}: $e');
			}
		}
		#end
		
		imageFile = json.image;
		jsonScale = json.scale;
		if (json.scale != 1)
		{
			scale.set(jsonScale, jsonScale);
			updateHitbox();
		}
		
		// positioning
		positionArray = json.position;
		cameraPosition = json.camera_position;
		
		// data
		healthIcon = json.healthicon;
		singDuration = json.sing_duration;
		flipX = (json.flip_x != isPlayer);
		healthColorArray = (json.healthbar_colors != null && json.healthbar_colors.length > 2) ? json.healthbar_colors : [161, 161, 161];
		originalFlipX = (json.flip_x == true);
		editorIsPlayer = json._editor_isPlayer;
		
		// antialiasing
		noAntialiasing = (json.no_antialiasing == true);
		
		antialiasing = noAntialiasing ? false : ClientPrefs.data.antialiasing;
		
		if (json.pauseDuringSustains != null) pauseAnimForSustain = json.pauseDuringSustains;
		
		// animations
		animationsArray = json.animations;
		if (animationsArray != null && animationsArray.length > 0)
		{
			for (anim in animationsArray)
			{
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; // Bruh
				var animIndices:Array<Int> = anim.indices;
				
				if (!isAnimateAtlas)
				{
					if (animIndices != null && animIndices.length > 0) animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
					else animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}
				#if flixel_animate
				else
				{
					if (animIndices != null && animIndices.length > 0) atlas.anim.addBySymbolIndices(animAnim, animName, animIndices, animFps, animLoop);
					else atlas.anim.addBySymbol(animAnim, animName, animFps, animLoop);
				}
				#end
				
				if (anim.offsets != null && anim.offsets.length > 1) addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				else addOffset(anim.anim, 0, 0);
			}
		}
		#if flixel_animate
		if (isAnimateAtlas) copyAtlasValues();
		#end
		// trace('Loaded file to character ' + curCharacter);
	}
	
	override function update(elapsed:Float)
	{
		#if flixel_animate
		if (isAnimateAtlas) atlas.update(elapsed);
		#end
		
		if (debugMode
			|| (!isAnimateAtlas && animation.curAnim == null) #if flixel_animate || (isAnimateAtlas && atlas.anim.curAnim == null) #end)
		{
			super.update(elapsed);
			return;
		}
		
		if (heyTimer > 0)
		{
			var rate:Float = (PlayState.instance != null ? PlayState.instance.playbackRate : 1.0);
			heyTimer -= elapsed * rate;
			if (heyTimer <= 0)
			{
				var anim:String = getAnimationName();
				if (specialAnim && (anim == 'hey' || anim == 'cheer'))
				{
					specialAnim = false;
					dance();
				}
				heyTimer = 0;
			}
		}
		else if (specialAnim && isAnimationFinished())
		{
			specialAnim = false;
			dance();
		}
		else if (getAnimationName().endsWith('miss') && isAnimationFinished())
		{
			dance();
			finishAnimation();
		}
		
		if (getAnimationName().startsWith('sing')) holdTimer += elapsed;
		else if (isPlayer) holdTimer = 0;
		
		if (!isPlayer
			&& holdTimer >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * singDuration)
		{
			dance();
			holdTimer = 0;
		}
		
		var name:String = getAnimationName();
		if (isAnimationFinished() && animOffsets.exists('$name-loop')) playAnim('$name-loop');
		
		super.update(elapsed);
		
		if (!debugMode)
		{
			if (currentlyHolding)
			{
				if (isAnimateAtlas)
				{
					#if flixel_animate
					if (atlas.anim != null) atlas.anim.curAnim.curFrame = 0;
					#end
				}
				else
				{
					if (animation.curAnim != null) animation.curAnim.curFrame = 0;
				}
			}
		}
	}
	
	inline public function isAnimationNull():Bool return !isAnimateAtlas ? (animation.curAnim == null) : (atlas.anim.curAnim == null);
	
	var __prevPlayedAnim:String = '';
	
	inline public function getAnimationName():String
	{
		return __prevPlayedAnim;
	}
	
	public function isAnimationFinished():Bool
	{
		if (isAnimationNull()) return false;
		return !isAnimateAtlas ? animation.curAnim.finished : atlas.animation.curAnim.finished;
	}
	
	public function getCurAnimFrame():Int
	{
		return isAnimationNull() ? 0 : !isAnimateAtlas ? animation.curAnim.curFrame : atlas.animation.curAnim.curFrame;
	}
	
	public function finishAnimation():Void
	{
		if (isAnimationNull()) return;
		
		if (!isAnimateAtlas) animation.curAnim.finish();
		else atlas.anim.curAnim.finish();
	}
	
	public var animPaused(get, set):Bool;
	
	private function get_animPaused():Bool
	{
		if (isAnimationNull()) return false;
		return !isAnimateAtlas ? animation.curAnim.paused : atlas.anim.curAnim.paused;
	}
	
	private function set_animPaused(value:Bool):Bool
	{
		if (isAnimationNull()) return value;
		if (!isAnimateAtlas) animation.curAnim.paused = value;
		else
		{
			atlas.animation.curAnim.paused = value;
		}
		
		return value;
	}
	
	public var danced:Bool = false;
	
	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
		{
			if (danceIdle)
			{
				danced = !danced;
				
				if (danced) playAnim('danceRight' + idleSuffix);
				else playAnim('danceLeft' + idleSuffix);
			}
			else if (animOffsets.exists('idle' + idleSuffix))
			{
				playAnim('idle' + idleSuffix);
			}
		}
	}
	
	/**
	 * Ensures a anim exists before playing
	 * 
	 * If there is no anim but there is a suffix, it will strip the suffix and try again
	 * 
	 * If still fails, `Null` is returned.
	 */
	public function correctAnimationName(animName:String):Null<String> // from base game !
	{
		if (hasAnim(animName)) return animName;
		
		// strip any post fix
		if (animName.lastIndexOf('-') != -1)
		{
			final correctedName = animName.substring(0, animName.lastIndexOf('-'));
			return correctAnimationName(correctedName);
		}
		else
		{
			// trace('missing anim ' + animName);
			return null;
		}
	}
	
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		AnimName += animationSuffix;
		var AnimName:Null<String> = correctAnimationName(AnimName);
		
		if (AnimName == null) return;
		
		specialAnim = false;
		
		if (!isAnimateAtlas)
		{
			animation.play(AnimName, Force, Reversed, Frame);
		}
		else
		{
			#if flixel_animate
			atlas.anim.play(AnimName, Force, Reversed, Frame);
			atlas.update(0);
			#end
		}
		
		__prevPlayedAnim = AnimName;
		
		if (animOffsets.exists(AnimName) && !skipOffset)
		{
			var daOffset = animOffsets.get(AnimName);
			if (curCharacter == "capsule") offset.set(daOffset[0] * this.scale.x, daOffset[1] * this.scale.y);
			else offset.set(daOffset[0], daOffset[1]);
		}
		
		if (curCharacter.startsWith('gf-') || curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT') danced = true;
			else if (AnimName == 'singRIGHT') danced = false;
			
			if (AnimName == 'singUP' || AnimName == 'singDOWN') danced = !danced;
		}
	}
	
	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}
	
	public var danceEveryNumBeats:Int = 2;
	
	private var settingCharacterUp:Bool = true;
	
	public function recalculateDanceIdle()
	{
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animOffsets.exists('danceLeft' + idleSuffix) && animOffsets.exists('danceRight' + idleSuffix));
		
		if (settingCharacterUp)
		{
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		}
		else if (lastDanceIdle != danceIdle)
		{
			var calc:Float = danceEveryNumBeats;
			if (danceIdle) calc /= 2;
			else calc *= 2;
			
			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}
	
	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
	
	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
	
	public inline function hasAnim(anim:String):Bool
	{
		if (atlas != null) return atlas.anim.exists(anim);
		else return animation.exists(anim);
	}
	
	// Atlas support
	// special thanks ne_eo for the references, you're the goat!!
	public var isAnimateAtlas:Bool = false;
	#if flixel_animate
	public var atlas:OffsetAnimate;
	
	public override function draw()
	{
		if (isAnimateAtlas)
		{
			copyAtlasValues();
			atlas.draw();
			return;
		}
		super.draw();
	}
	
	public function copyAtlasValues()
	{
		@:privateAccess
		{
			atlas.cameras = cameras;
			atlas.scrollFactor.copyFrom(scrollFactor);
			atlas.scale.copyFrom(scale);
			atlas.offset.copyFrom(offset);
			atlas.origin.copyFrom(origin);
			atlas.offset2.copyFrom(offset2);
			atlas.x = x;
			atlas.y = y;
			atlas.angle = angle;
			atlas.alpha = alpha;
			atlas.visible = visible;
			atlas.flipX = flipX;
			atlas.flipY = flipY;
			atlas.shader = shader;
			atlas.antialiasing = antialiasing;
			atlas.colorTransform = colorTransform;
			atlas.color = color;
		}
	}
	#end
	
	public override function destroy()
	{
		super.destroy();
		destroyAtlas();
	}
	
	public function destroyAtlas()
	{
		#if flixel_animate
		atlas = FlxDestroyUtil.destroy(atlas);
		#end
	}
}
