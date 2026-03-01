package extensions.flixel;

import flixel.FlxBasic;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.math.FlxPoint;

/**
 * A utility sprite for making a sprite that ignores any and all camera transforms.
 */
class FlxUniformSprite extends FlxSprite
{
	/**
	 * If enabled its nebaled and it is and
	 */
	public var ignoreCulling:Bool = true;
	
	override function draw()
	{
		checkEmptyFrame();
		
		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY) return;
		
		if (dirty) // rarely
			calcFrame(useFramePixels);
			
		for (camera in getCamerasLegacy())
		{
			if (!camera.visible || !camera.exists || (!ignoreCulling && !isOnScreen(camera))) continue;
			
			if (isSimpleRender(camera)) drawSimple(camera);
			else drawComplex(camera);
			
			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
		
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug) drawDebug();
		#end
	}
	
	@:privateAccess override function drawComplex(camera:FlxCamera):Void
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
		
		_point.subtract(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);
		
		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}
		
		// actually cne has a more proper way to handle this ! so i borrowed it
		var _rect = FlxRect.get()
			.set(camera.width * 0.5, camera.height * 0.5, (camera.scaleX > 0 ? Math.max : Math.min)(0, 1 / camera.scaleX), (camera.scaleY > 0 ? Math.max : Math.min)(0, 1 / camera.scaleY));
		_matrix.setTo(_matrix.a * _rect.width, _matrix.b * _rect.height, _matrix.c * _rect.width, _matrix.d * _rect.height, (_matrix.tx - _rect.x) * _rect.width
			+ _rect.x, (_matrix.ty - _rect.y) * _rect.height
			+ _rect.y,);
			
		_rect.put();
		
		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}
}

class FlxUniformText extends FlxText
{
	/**
	 * If enabled its nebaled and it is and
	 */
	public var ignoreCulling:Bool = true;
	
	override function draw()
	{
		regenGraphic();
		
		checkEmptyFrame();
		
		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY) return;
		
		if (dirty) // rarely
			calcFrame(useFramePixels);
			
		for (camera in getCamerasLegacy())
		{
			if (!camera.visible || !camera.exists || (!ignoreCulling && !isOnScreen(camera))) continue;
			
			if (isSimpleRender(camera)) drawSimple(camera);
			else drawComplex(camera);
			
			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
		
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug) drawDebug();
		#end
	}
	
	override function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);
		
		if (bakedRotationAngle <= 0)
		{
			updateTrig();
			
			if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		
		_point ??= FlxPoint.get();
		_point.set(x, y).subtract(_graphicOffset);
		
		if (pixelPerfectPosition) _point.floor();
		
		_point.subtract(offset);
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
}
