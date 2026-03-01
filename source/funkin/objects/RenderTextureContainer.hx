package funkin.objects;

import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;
import flixel.FlxBasic;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.util.FlxDestroyUtil;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxRect;
import flixel.math.FlxMatrix;

import animate.internal.RenderTexture;

import flixel.group.FlxContainer;

// duct taped together test of using flixel animates rendertexture for more general sprites
class RenderTextureContainer extends FlxSprite
{
	public var renderTexture(default, null):RenderTexture;
	
	public var members:Array<FlxSprite> = [];
	
	var _renderMatrix:FlxMatrix = new FlxMatrix();
	
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		
		renderTexture = new RenderTexture(1, 1);
	}
	
	override function draw()
	{
		checkClipRect();
		
		checkEmptyFrame();
		
		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY) return;
		
		if (dirty) // rarely
			calcFrame(useFramePixels);
			
		for (camera in getCamerasLegacy())
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera)) continue;
			
			drawRenderTexture(camera);
			
			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
		
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug) drawDebug();
		#end
	}
	
	public function drawRenderTexture(camera:FlxCamera)
	{
		var matrix = _renderMatrix;
		
		prepareRenderMatrix(matrix, camera);
		
		renderTexture.init(Math.ceil(width), Math.ceil(height));
		renderTexture.drawToCamera((camera, matrix) -> {
			matrix.translate(-width, -height);
			
			for (basic in members)
			{
				if (basic != null && basic.exists && basic.visible)
				{
					basic.drawComplex(camera);
				}
			}
		});
		
		renderTexture.render();
		
		camera.drawPixels(renderTexture.graphic.imageFrame.frame, framePixels, matrix, colorTransform, blend, antialiasing, shader);
	}
	
	public function prepareRenderMatrix(matrix:FlxMatrix, camera:FlxCamera)
	{
		matrix.identity();
		
		if (checkFlipX())
		{
			//
			matrix.scale(-1, 1);
			matrix.translate(width, 0);
		}
		
		if (checkFlipY())
		{
			matrix.scale(1, -1);
			matrix.translate(0, height);
		}
		
		matrix.translate(-origin.x, -origin.y);
		matrix.scale(scale.x, scale.y);
		
		if (angle != 0)
		{
			updateTrig();
			matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		
		getScreenPosition(_point, camera);
		_point.x += origin.x;
		_point.y += origin.y;
		
		_point.x -= offset.x;
		_point.y -= offset.y;
		matrix.translate(_point.x, _point.y);
		
		if (isPixelPerfectRender(camera))
		{
			matrix.tx = Math.floor(matrix.tx);
			matrix.ty = Math.floor(matrix.ty);
		}
	}
	
	override function isOnScreen(?camera:FlxCamera):Bool
	{
		return true;
	}
	
	override function destroy()
	{
		super.destroy();
		renderTexture = FlxDestroyUtil.destroy(renderTexture);
		members = FlxDestroyUtil.destroyArray(members);
		
		_renderMatrix = null;
	}
	
	public function add(basic:Null<FlxSprite>)
	{
		if (basic == null) return;
		if (members.indexOf(basic) != -1) return;
		members.push(basic);
	}
	
	public function remove(basic:Null<FlxSprite>) {}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		for (spr in members)
		{
			if (spr != null && spr.exists && spr.active) spr.update(elapsed);
		}
	}
	
	/**
	 * Returns the left-most position of the left-most member.
	 * If there are no members, x is returned.
	 * 
	 * @since 5.0.0
	 */
	public function findMinX()
	{
		return members.length == 0 ? x : findMinXHelper();
	}
	
	function findMinXHelper()
	{
		var value = Math.POSITIVE_INFINITY;
		for (member in members)
		{
			if (member == null) continue;
			
			var minX:Float;
			if (member.flixelType == SPRITEGROUP) minX = (cast member : FlxSpriteGroup).findMinX();
			else minX = member.x;
			
			if (minX < value) value = minX;
		}
		return value;
	}
	
	public function findMaxX()
	{
		return members.length == 0 ? x : findMaxXHelper();
	}
	
	function findMaxXHelper()
	{
		var value = Math.NEGATIVE_INFINITY;
		for (member in members)
		{
			if (member == null) continue;
			
			var maxX:Float;
			if (member.flixelType == SPRITEGROUP) maxX = (cast member : FlxSpriteGroup).findMaxX();
			else maxX = member.x + member.width;
			
			if (maxX > value) value = maxX;
		}
		return value;
	}
	
	override function get_width():Float
	{
		if (members.length == 0) return 0;
		
		return findMaxXHelper() - findMinXHelper();
	}
	
	override function get_height():Float
	{
		if (members.length == 0) return 0;
		return findMaxYHelper() - findMinYHelper();
	}
	
	public function findMinY()
	{
		return members.length == 0 ? y : findMinYHelper();
	}
	
	function findMinYHelper()
	{
		var value = Math.POSITIVE_INFINITY;
		for (member in members)
		{
			if (member == null) continue;
			
			var minY:Float;
			if (member.flixelType == SPRITEGROUP) minY = (cast member : FlxSpriteGroup).findMinY();
			else minY = member.y;
			
			if (minY < value) value = minY;
		}
		return value;
	}
	
	public function findMaxY()
	{
		return members.length == 0 ? y : findMaxYHelper();
	}
	
	function findMaxYHelper()
	{
		var value = Math.NEGATIVE_INFINITY;
		for (member in members)
		{
			if (member == null) continue;
			
			var maxY:Float;
			if (member.flixelType == SPRITEGROUP) maxY = (cast member : FlxSpriteGroup).findMaxY();
			else maxY = member.y + member.height;
			
			if (maxY > value) value = maxY;
		}
		return value;
	}
}
