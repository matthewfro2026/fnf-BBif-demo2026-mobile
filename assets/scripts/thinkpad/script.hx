import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.FlxG;

import funkin.backend.HUDCamera;

import flixel.tweens.FlxTween;

import funkin.backend.ClientPrefs;
import funkin.objects.Character;
import funkin.scripting.HScript;

import flixel.util.FlxTimer;

import funkin.backend.Paths;

import animate.FlxAnimate;

import flixel.graphics.atlas.FlxAtlas;

import funkin.backend.MathResolver;
import funkin.backend.Conductor;
import funkin.utils.CoolUtil;

import flixel.FlxCamera;

import funkin.objects.AttachedSprite;

import flixel.FlxSprite;

var mathResolver:MathResolver = new MathResolver();

//
var markers:Array<FlxSprite> = [];
var markerIdx = 0;

//
var thinkCam:HUDCamera;
var underlay:FlxSprite;
var atlas:Character;
var thinkPad:FlxSprite;
var atlasCover:AttachedSprite; // stupid
var thinkPadText:FlxText;
var typedText:FlxText;
var bfAtlas:FlxAnimate = null;
var garbledTexts:Array<FlxText> = [];

//

function onCreate()
{
	add(mathResolver);
	
	thinkCam = new HUDCamera(0, 0, FlxG.width + 1, FlxG.height + 1);
	FlxG.cameras.insert(thinkCam, 2, false);
	
	underlay = new FlxSprite(0, 0, Paths.image('mechanics/thinkpad/underlay'));
	underlay.scale.set(0.67, 0.67);
	underlay.updateHitbox();
	add(underlay);
	underlay.cameras = [thinkCam];
	
	atlas = new Character(0, 0, 'baldi-mathAtlas');
	atlas.cameras = [thinkCam];
	add(atlas);
	startCharacterPos(atlas, false);
	atlas.visible = false;
	
	atlas.atlas.anim.onFinish.add((anim) -> atlas.playAnim('idle'));
	
	atlasCover = new AttachedSprite();
	atlasCover.makeScaledGraphic(300, 150, FlxColor.BLACK);
	atlasCover.cameras = [thinkCam];
	add(atlasCover);
	
	thinkPad = new FlxSprite(0, 0, Paths.image('mechanics/thinkpad/thinkpad'));
	thinkPad.scale.set(0.67, 0.67);
	thinkPad.updateHitbox();
	thinkPad.screenCenter();
	thinkPad.cameras = [thinkCam];
	add(thinkPad);
	thinkPad.active = false;
	
	underlay.x = thinkPad.x + (221 * 0.67);
	underlay.y = thinkPad.y + (616 * 0.67);
	
	atlasCover.sprTracker = thinkPad;
	atlasCover.yAdd = (838 * 0.67);
	atlasCover.xAdd = (220 * 0.67);
	
	thinkPadText = new FlxText(thinkPad.x + (410 * 0.67), thinkPad.y + (345 * 0.67), 450 * 0.67, "", 24);
	thinkPadText.font = Paths.font("comic.ttf");
	thinkPadText.color = 0xFF000000;
	add(thinkPadText);
	thinkPadText.cameras = [thinkCam];
	
	typedText = new FlxText(thinkPad.x + (547 * 0.67), thinkPad.y + (658 * 0.67), 0, "", 64);
	typedText.font = Paths.font("comic.ttf");
	typedText.color = 0xFF000000;
	add(typedText);
	typedText.cameras = [thinkCam];
	
	for (i in 0...3)
	{
		var mark = new FlxSprite(0, 0, Paths.image('mechanics/thinkpad/Check'));
		mark.scale.set(0.67, 0.67);
		mark.updateHitbox();
		markers.push(mark);
		add(mark);
		
		mark.x = thinkPad.x + (244 * 0.67) + (((126 * 0.67) - mark.width) / 2);
		mark.y = thinkPad.y + (322 * 0.67) + (((82 * 0.67) - mark.height) / 2);
		mark.y += (100 * 0.67) * i;
		mark.cameras = [thinkCam];
		mark.visible = false;
	}
	
	// precache
	
	Paths.image('mechanics/thinkpad/X');
	Paths.sound('basics/correct');
	Paths.sound('basics/wrong');
	
	mathResolver.onKeyPress.add((number) -> {
		typedText.text = mathResolver.input;
	});
	
	mathResolver.onResolved.add((successful) -> {
		typedText.text = mathResolver.input;
		typedText.color = successful ? 0xFF008800 : 0xFF880000;
		thinkPadText.text += ' ' + mathResolver.intendedValue;
		
		FlxG.sound.play(Paths.sound('basics/' + (successful ? 'correct' : 'wrong')));
		
		if (markerIdx > 2) return;
		
		markers[markerIdx].visible = true;
		if (!successful)
		{
			markers[markerIdx].loadGraphic(Paths.image('mechanics/thinkpad/X'));
			
			Story.mathMisses += 1;
		}
		
		markerIdx += 1;
	});
	
	thinkCam.alpha = 0;
	thinkCam.scroll.y = -FlxG.height;
	
	setVar('thinkpad_baldiAtlas', atlas);
	setVar('thinkpad_thinkCam', thinkCam);
	setVar('thinkpad_spawnBf', spawnBfAtlas);
	setVar('thinkpad_thinkPadText', thinkPadText);
	setVar('thinkpad_typedText', typedText);
	setVar('thinkpad_mathResolver', mathResolver);
}

function onEvent(ev, v1, v2, time)
{
	switch (ev)
	{
		case 'mathText': // sets the text so be shown in the thinkpad.
			thinkPadText.text = v1;
			thinkPadText.size = v2 == "" ? 24 : 36;
			
			for (text in garbledTexts)
				text.visible = false;
				
		case 'mathAnims': // plays baldi math atlas anims
			atlas.visible = true;
			atlas.playAnim(v1);
			vocals.volume = 1;
			
		case 'revealThinkpad':
			vocals.volume = 1;
			
			moveThinkpad(true);
			
		case 'exitThinkpad':
			moveThinkpad(false);
			
			// its safe to say if there is a notebook var it should be gone
			if (hasVar('stage_noteBook')) getVar('stage_noteBook').visible = false;
			
		case 'startMathEquation': // used to be math
			mathResolver.start(Std.parseInt(v1.split(',')[0]), Std.parseInt(v1.split(',')[1]), v2 == 'true');
			
			typedText.text = '';
			typedText.color = 0xFF000000;
			
		case 'mathCpuCheck': // if u have botplay lets just auto answer it
			if (cpuControlled)
			{
				//
				mathResolver.input = mathResolver.intendedValue;
				mathResolver.resolveMath();
			}
			
		case 'checkMathAnswer': // this is needed if u didnt answer
		
			mathResolver.resolveMath();
			
			// lets also reset it
			typedText.text = '';
			typedText.color = 0xFF000000;
			
		case 'bfAnim':
			if (bfAtlas != null)
			{
				bfAtlas.visible = true;
				bfAtlas.animation.play('aha');
				atlas.visible = false;
			}
		case 'disableMathInput':
			mathResolver.lockInputs = true;
			
		case 'garbledMathText':
			thinkPadText.size = v2 == "" ? 24 : 36;
			
			if (garbledTexts.length == 0)
			{
				for (idx in 0...2)
				{
					// var copy = thinkPadText.clone(); //flxtext clone doesnt properly work
					
					var copy = new FlxText();
					copy.size = thinkPadText.size;
					copy.font = thinkPadText.font;
					copy.cameras = thinkPadText.cameras;
					copy.fieldWidth = thinkPadText.fieldWidth;
					copy.x = thinkPadText.x;
					copy.y = thinkPadText.y;
					copy.color = thinkPadText.color;
					
					insert(members.indexOf(thinkPadText) + 1, copy);
					garbledTexts.push(copy);
				}
			}
			
			var garbledFirst = Std.string(FlxG.random.int(-9000, 9000));
			var garbledSecond = Std.string(FlxG.random.int(-9000, 9000));
			
			thinkPadText.text = StringTools.replace(StringTools.replace(v1, 'GARBLED1', garbledFirst), 'GARBLED2', garbledSecond);
			
			for (text in garbledTexts)
			{
				var garbledFirst = Std.string(FlxG.random.int(-9000, 9000));
				var garbledSecond = Std.string(FlxG.random.int(-9000, 9000));
				
				text.visible = true;
				
				text.text = StringTools.replace(StringTools.replace(v1, 'GARBLED1', garbledFirst), 'GARBLED2', garbledSecond);
				text.text = StringTools.replace(text.text, 'Solve Math Q3:', '');
			}
	}
}

function moveThinkpad(appear)
{
	var time = Conductor.crochet / 1000;
	var ease = FlxEase.quadOut;
	
	FlxTween.cancelTweensOf(thinkCam, ['scroll.y', 'alpha']);
	if (appear)
	{
		atlas.revive();
		thinkPad.revive();
		atlasCover.revive();
		
		FlxTween.tween(thinkCam.scroll, {y: 0}, time * 2, {ease: ease});
		FlxTween.tween(thinkCam, {alpha: 1}, time * 2, {ease: ease});
	}
	else
	{
		FlxTween.tween(thinkCam.scroll, {y: -FlxG.height}, time * 2, {ease: ease});
		FlxTween.tween(thinkCam, {alpha: 0}, time * 2,
			{
				ease: ease,
				onComplete: Void -> {
					atlas.kill();
					thinkPad.kill();
					atlasCover.kill();
					// unlock keys after because people keep pressing r while readjusting themself
					mathResolver.disableKeys(false);
				}
			});
	}
}

function spawnBfAtlas()
{
	bfAtlas = new FlxAnimate();
	Paths.loadAnimateAtlas(bfAtlas, "mechanics/thinkpad/mathBf");
	bfAtlas.anim.addBySymbol('aha', 'aha', 24, false);
	bfAtlas.cameras = [thinkCam];
	bfAtlas.scale.set(0.3, 0.3);
	bfAtlas.updateHitbox();
	bfAtlas.setPosition(330, 460);
	
	insert(members.indexOf(atlas), bfAtlas);
	
	return bfAtlas;
}

var boxSize = 89 * 0.67;
var point = new FlxPoint();

function onUpdatePost(e)
{
	//
	
	if (mathResolver.isInMath && !mathResolver.lockInputs)
	{
		if (FlxG.mouse.justPressed)
		{
			for (i in 0...11)
			{
				var x = thinkPad.x + (1112 * 0.67) + (boxSize * (i + 1)) % (3 * boxSize);
				var y = thinkPad.y + (292 * 0.67) + (boxSize * Math.floor((10 - i) / 3));
				
				var mouseOver = over(x, y);
				if (mouseOver)
				{
					var idx = Std.string(i);
					if (i > 1)
					{
						idx = Std.string(i - 1);
					}
					else if (i == 1)
					{
						idx = '-';
					}
					mathResolver.input += idx;
					
					mathResolver.onKeyPress.dispatch(i);
					
					if (mathResolver.input.length >= mathResolver.numLength) mathResolver.resolveMath();
				}
			}
		}
	}
}

function over(x:Float, y:Float)
{
	FlxG.mouse.getWorldPosition(thinkCam, point);
	return point.x > x && point.y > y && point.x < (x + boxSize) && point.y < (y + boxSize);
}
