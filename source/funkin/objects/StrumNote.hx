package funkin.objects;

import funkin.backend.animation.PsychAnimationController;
import funkin.shaders.RGBPalette;
import funkin.shaders.RGBPalette.RGBShaderReference;

class StrumNote extends FlxSprite
{
	public var rgbShader:RGBShaderReference;
	public var resetAnim:Float = 0;
	
	private var noteData:Int = 0;
	
	public var direction:Float = 90; // plan on doing scroll directions soon -bb
	public var downScroll:Bool = false; // plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	
	private var player:Int;
	
	public var animOffsets:Map<String, Array<Float>> = new Map();
	
	public function addOffset(name:String, x:Float = 0, y:Float = 0) animOffsets[name] = [x, y];
	
	public var texture(default, set):String = null;
	
	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			texture = value;
			reloadNote();
		}
		return value;
	}
	
	public var useRGBShader:Bool = false;
	
	public function new(x:Float, y:Float, leData:Int, player:Int)
	{
		animation = new PsychAnimationController(this);
		
		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(leData));
		rgbShader.enabled = false;
		if (PlayState.SONG != null && PlayState.SONG.disableNoteRGB) useRGBShader = false;
		
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[leData];
		if (PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[leData];
		
		if (leData <= arr.length)
		{
			@:bypassAccessor
			{
				rgbShader.r = arr[0];
				rgbShader.g = arr[1];
				rgbShader.b = arr[2];
			}
		}
		
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);
		
		var skin:String = null;
		if (PlayState.SONG != null && PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;
		else skin = Note.defaultNoteSkin;
		
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if (Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;
		
		texture = skin; // Load texture and anims
		scrollFactor.set();
	}
	
	public function reloadNote()
	{
		var lastAnim:String = null;
		if (animation.curAnim != null) lastAnim = animation.curAnim.name;
		
		if (PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + texture));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + texture), true, Math.floor(width), Math.floor(height));
			
			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			
			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);
			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);
			
			animation.addByPrefix('green', 'up0');
			animation.addByPrefix('blue', 'down0');
			animation.addByPrefix('purple', 'left0');
			animation.addByPrefix('red', 'right0');
			
			antialiasing = ClientPrefs.data.antialiasing;
			setGraphicSize(Std.int(width * 0.7));
			
			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.addByPrefix('static', 'static left');
					animation.addByPrefix('pressed', 'left miss', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					animation.addByPrefix('static', 'static down');
					animation.addByPrefix('pressed', 'down miss', 24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					animation.addByPrefix('static', 'static up');
					animation.addByPrefix('pressed', 'up miss', 24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					animation.addByPrefix('static', 'static right');
					animation.addByPrefix('pressed', 'right miss', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
		}
		updateHitbox();
		
		if (lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}
	
	public function postAddedToGroup()
	{
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
	}
	
	override function update(elapsed:Float)
	{
		if (resetAnim > 0)
		{
			resetAnim -= elapsed;
			if (resetAnim <= 0)
			{
				playAnim('static');
				resetAnim = 0;
			}
		}
		super.update(elapsed);
	}
	
	public function playAnim(anim:String, ?force:Bool = false)
	{
		animation.play(anim, force);
		if (animation.curAnim != null)
		{
			centerOffsets();
			centerOrigin();
			if (animOffsets.exists(anim)) offset.set(offset.x + animOffsets.get(anim)[0], offset.y + animOffsets.get(anim)[1]);
		}
		
		if (useRGBShader) rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != 'static');
	}
	
	public function fadeIn(targetAlpha:Float)
	{
		FlxTween.cancelTweensOf(this, ['alpha', 'angle']);
		alpha = 0;
		FlxTween.tween(this, {alpha: targetAlpha, angle: 360}, Conductor.crochet / 1000,
			{
				ease: FlxEase.circOut,
				startDelay: 0.4 + (Conductor.crochet / 1000 * noteData),
				onComplete: (twn) -> {
					angle = 0;
				}
			});
	}
	
	override function destroy()
	{
		FlxTween.cancelTweensOf(this, ['alpha', 'angle']);
		
		super.destroy();
	}
	
	function getPostPos(player:Int = 0)
	{
		return (Note.swagWidth * this.noteData) + 50 + ((FlxG.width / 2) * player);
	}
	
	public static function positionStrumline(strumLine:FlxTypedGroup<StrumNote>, type:StrumPosType)
	{
		final isCentered = type == CENTERED_OPP || type == CENTERED_PLAYER;
		final strumLineX:Float = isCentered ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X;
		final strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		
		inline function postX(note:StrumNote, player:Int = 0)
		{
			note.x += Note.swagWidth * note.noteData;
			note.x += 50;
			note.x += ((FlxG.width / 2) * player);
		}
		
		for (k => i in strumLine.members)
		{
			i.x = strumLineX;
			i.y = strumLineY;
			
			switch (type)
			{
				case CENTERED_OPP:
					i.x += 310;
					if (k > 1)
					{
						i.x += FlxG.width / 2 + 25;
					}
					postX(i, 0);
					
				case CENTERED_PLAYER:
					postX(i, 1);
					
				case OPP:
					postX(i, 0);
					
				case PLAYER:
					postX(i, 1);
			}
		}
	}
}

enum abstract StrumPosType(Int)
{
	var CENTERED_OPP;
	var CENTERED_PLAYER;
	var OPP;
	var PLAYER;
}
