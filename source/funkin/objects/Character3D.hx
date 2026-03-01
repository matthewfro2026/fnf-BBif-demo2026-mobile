package funkin.objects;

import lime.graphics.Image;
import lime.graphics.ImageBuffer;

import away3d.library.assets.IAsset;
import away3d.containers.ObjectContainer3D;

import openfl.geom.Vector3D;
import openfl.geom.Matrix3D;

import away3d.materials.TextureMaterial;
import away3d.textures.BitmapTexture;
import away3d.entities.Mesh;
import away3d.tools.helpers.SpriteSheetHelper;
import away3d.utils.Cast;
import away3d.materials.SpriteSheetMaterial;

import openfl.display.BitmapData;

import away3d.animators.*;
import away3d.primitives.CubeGeometry;
import away3d.animators.data.SpriteSheetAnimationFrame;

// by smokey5 // anwyay data 5 too now
class Character3D extends ObjectContainer3D
{
	var spriteAnimator:SpriteSheetAnimator;
	var animatorSet:SpriteSheetAnimationSet;
	
	public var texture:BitmapTexture;
	
	var characterGeometry:CubeGeometry;
	
	public var characterMaterial:TextureMaterial;
	
	public var frameMap:Map<String, Array<SpriteSheetAnimationFrame>> = new Map<String, Array<SpriteSheetAnimationFrame>>();
	
	var character:Character;
	
	public var characterMesh:Mesh;
	
	public function new(character:Character)
	{
		super();
		
		this.character = character;
		
		if (character == null)
		{
			throw "character cannot be null.";
		}
		
		var charBitmap = character.graphic.bitmap;
		if (charBitmap == null)
		{
			trace('Couldnt load 3d character texture for ${character.curCharacter}');
			texture = Cast.bitmapTexture(new BitmapData(1, 1));
		}
		else if (charBitmap.image == null)
		{
			fetchBmpFromReadOnly(charBitmap);
			texture = CustomBitmapTexture.bitmapDataToTexture(charBitmap);
		}
		else
		{
			texture = CustomBitmapTexture.bitmapDataToTexture(charBitmap);
		}
		
		characterMaterial = new TextureMaterial(texture, character.antialiasing, true, false, NONE);
		characterMaterial.alphaBlending = true;
		characterMaterial.alphaThreshold = 0.2;
		characterMaterial.alphaPremultiplied = true;
		
		characterGeometry = new CubeGeometry(texture.bitmapData.width, texture.bitmapData.height, 1, 1, 1, 0, false);
		
		characterMesh = new Mesh(characterGeometry, characterMaterial);
		characterMesh.scale(character.jsonScale);
		
		this.addChild(characterMesh);
		
		spriteAnimator = new SpriteSheetAnimator((animatorSet = new SpriteSheetAnimationSet()));
		
		characterMesh.animator = spriteAnimator;
		characterMesh.material = characterMaterial;
		
		setParentedChar(character);
	}
	
	function initCallback()
	{
		if (character == null) return;
		if (!character.animation.onFrameChange.has(updateFrame)) character.animation.onFrameChange.add(updateFrame);
	}
	
	public function setParentedChar(char:Character)
	{
		if (char == null) return false;
		
		initCallback();
		
		if (!hasCachedFrames(char.curCharacter)) cacheFrames(char);
		
		char.alpha = 0.0;
		char.visible = false;
		char.cameras = [];
		
		char.dance();
		
		return true;
	}
	
	function changeFrame(frameIndex:Int)
	{
		if (character == null || !hasCachedFrames(character.curCharacter)) return;
		
		var curFrame = frameMap.get(character.curCharacter)[frameIndex];
		@:privateAccess
		spriteAnimator._frame = curFrame;
		(cast characterMesh.geometry : CubeGeometry).width = character.frames.frames[frameIndex].frame.width;
		(cast characterMesh.geometry : CubeGeometry).height = character.frames.frames[frameIndex].frame.height;
		
		// characterMesh.x = (x - ((character.offset.x -  character.frames.frames[frameIndex].offset.x) * scaleX));
		// characterMesh.y = (y - ((character.offset.y - character.frames.frames[frameIndex].offset.y) * scaleY));
	}
	
	function cacheFrames(character:Character):Bool
	{
		if (character == null) return false;
		
		if (hasCachedFrames(character.curCharacter)) return true;
		
		var arr:Array<SpriteSheetAnimationFrame> = [];
		
		for (i in character.frames.frames)
		{
			var frame = new SpriteSheetAnimationFrame(i.frame.x / character.graphic.bitmap.width, i.frame.y / character.graphic.bitmap.height, i.frame.width / character.graphic.bitmap.width, i.frame.height / character.graphic.bitmap.height);
			arr.push(frame);
		}
		
		frameMap.set(character.curCharacter, arr);
		return true;
	}
	
	function updateFrame(name:String, frameNumber:Int, frameIndex:Int)
	{
		changeFrame(frameIndex);
	}
	
	inline function hasCachedFrames(charName:String):Bool return frameMap.exists(charName);
	
	override function dispose()
	{
		this.character = null;
		
		texture = Away3DDisposeUtil.dispose(texture);
		characterMaterial = Away3DDisposeUtil.dispose(characterMaterial);
		characterGeometry = Away3DDisposeUtil.dispose(characterGeometry);
		characterMesh = Away3DDisposeUtil.dispose(characterMesh);
		animatorSet = Away3DDisposeUtil.dispose(animatorSet);
		spriteAnimator = Away3DDisposeUtil.dispose(spriteAnimator);
		
		for (key => frames in frameMap)
		{
			//
			for (frame in frames)
			{
				frame = null;
			}
			frames.resize(0);
			frames = null;
		}
		
		frameMap.clear();
		
		super.dispose();
	}
	
	// https://github.com/openfl/openfl/issues/2835
	public static function fetchBmpFromReadOnly(bmp:BitmapData)
	{
		var data = new lime.utils.UInt8Array(bmp.width * bmp.height * 4);
		
		final gl = FlxG.stage.window.context.webgl;
		@:privateAccess
		final glTexture = bmp.getTexture(FlxG.stage.context3D).__getTexture();
		
		var framebuffer = gl.createFramebuffer();
		gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
		
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, glTexture, 0);
		gl.readPixels(0, 0, bmp.width, bmp.height, gl.RGBA, gl.UNSIGNED_BYTE, data);
		
		gl.bindFramebuffer(gl.FRAMEBUFFER, null);
		gl.deleteFramebuffer(framebuffer);
		
		var buffer = new ImageBuffer(data, bmp.width, bmp.height, 32, RGBA32);
		var image = new Image(buffer);
		@:privateAccess
		image.version = bmp.__textureVersion;
		
		@:privateAccess
		bmp.__fromImage(image);
	}
}

class Away3DDisposeUtil
{
	public static inline function dispose<T:IAsset>(asset:Null<T>):T
	{
		if (asset != null) asset.dispose();
		
		return null;
	}
}

class CustomBitmapTexture extends BitmapTexture
{
	public static function bitmapDataToTexture(bmp:BitmapData):Null<CustomBitmapTexture>
	{
		try
		{
			var bmd:BitmapData = Cast.bitmapData(bmp);
			return new CustomBitmapTexture(bmd);
		}
		catch (e) {}
		
		return null;
	}
	
	override function set_bitmapData(value:BitmapData):BitmapData
	{
		if (value == _bitmapData) return null;
		
		// if (!TextureUtils.isBitmapDataValid(value)) throw new Error("Invalid bitmapData: Width and height must be power of 2 and cannot exceed 2048");
		
		invalidateContent();
		setSize(value.width, value.height);
		
		_bitmapData = value;
		
		if (_generateMipmaps) getMipMapHolder();
		return value;
	}
}
