package assets.shared.stages;

import funkin.backend.ClientPrefs;
import funkin.Constants;
import funkin.shaders.DitherShader;

import flixel.util.FlxTimer;

import funkin.utils.MathUtil;
import funkin.utils.CoolUtil;

import flixel.FlxG;
import flixel.tweens.FlxTween;

import funkin.objects.OffsetSprite;
import funkin.states.PlayState;

import flixel.FlxSprite;
import flixel.util.FlxGradient;
import flixel.math.FlxMath;

import funkin.objects.Character;
import funkin.shaders.DropShadowShader;
import funkin.objects.FunkinVideoSprite;
import funkin.shaders.ColorSwap;
import funkin.game.VideoCutscene;

import debug.FPSCounter;

import flixel.system.FlxBGSprite;

var floor:FlxSprite;
var meteors:Array<FlxSprite> = [];
var path:String = 'stages/firewall/';
var scale = 3;

//
var rimLight:DropShadowShader;
var colorSwap:ColorSwap = new ColorSwap();
var animSuffix:String = '';

//
var intro:FunkinVideoSprite;
var introReady:Bool = false;
var skipIntro:Bool = false;
var ditherSprite:FlxSprite;

//
var bsod:FlxSprite;
var whiteOverlay:FlxBGSprite;
var popUps:Array<FlxSprite> = [];
var glitchShader = PlayState.instance.createRuntimeShader('meltGlitch');
var glitchIntendedValue:Float = 0;
var currentGlitchValue:Float = 0;
var advideBlue:FlxSprite;

//
function onCreate()
{
	PlayState.instance.showCredits = () -> {};
	
	intro = new FunkinVideoSprite();
	intro.load(Paths.video('firewallIntro'), [FunkinVideoSprite.muted]);
	intro.onFormat(() -> {
		intro.setGraphicSize(FlxG.width, FlxG.height);
		intro.updateHitbox();
		intro.cameras = [camHUD];
		
		intro.visible = false;
		intro.pause();
		introReady = true;
		startCountdown();
	});
	intro.tiedToGame = false;
	// insert(0, intro);
	
	intro.delayAndStart();
	
	bg = new OffsetSprite().loadGraphic(Paths.image(path + 'mainbg'));
	bg.scale.set(scale, scale);
	bg.updateHitbox();
	bg.scrollFactor.set(0.2, 0.2);
	addBehindDad(bg);
	
	bg2 = new FlxSprite(-300, -150).loadGraphic(Paths.image(path + 'mainbg'));
	bg2.scrollFactor.set(0.2, 0.2);
	bg2.scale.set(scale, scale);
	bg2.alpha = 0.3;
	// bg2.alpha = 0.;
	addBehindDad(bg2);
	
	FlxTween.tween(bg2.scale, {x: scale * 1.1, y: scale * 1.1}, 2, {type: 4, ease: FlxEase.sineInOut});
	
	bgGradient = new FlxSprite(bg.x, bg.y).loadGraphic(Paths.image(path + 'gradient_back'));
	bgGradient.scale.set(scale, scale);
	bgGradient.updateHitbox();
	
	bgGradient.scrollFactor.set(0.2, 0.2);
	addBehindDad(bgGradient);
	
	cloudsBehind = new OffsetSprite(bg.x + (53 * scale), bg.y + 0).loadGraphic(Paths.image(path + 'cloudsbehindschool'));
	cloudsBehind.scale.set(scale, scale);
	cloudsBehind.updateHitbox();
	cloudsBehind.scrollFactor.set(0.5, 0.5);
	
	addBehindDad(cloudsBehind);
	
	skyGraphic = new OffsetSprite(bg.x + 297 * scale, bg.y + 26 * scale).loadGraphic(Paths.image(path + 'school'));
	skyGraphic.scrollFactor.set(0.6, 0.6);
	skyGraphic.scale.set(scale, scale);
	skyGraphic.updateHitbox();
	addBehindDad(skyGraphic);
	
	bluescreen = new OffsetSprite(bg.x + 297 * scale + 300, bg.y + 26 * scale + -200).loadGraphic(Paths.image(path + 'bluescreen'));
	bluescreen.scrollFactor.set(0.6, 0.6);
	bluescreen.scale.set(scale, scale);
	bluescreen.updateHitbox();
	addBehindDad(bluescreen);
	bluescreen.visible = false;
	
	clouds = new OffsetSprite(bg.x + 393 * scale, bg.y + 24 * scale).loadGraphic(Paths.image(path + 'clouds'));
	clouds.scrollFactor.set(0.7, 0.7);
	clouds.scale.set(scale, scale);
	clouds.updateHitbox();
	addBehindDad(clouds);
	
	tree = new OffsetSprite(bg.x + 1274 * scale, bg.y + 227 * scale).loadGraphic(Paths.image(path + 'tree'));
	tree.scrollFactor.set(0.8, 0.8);
	tree.scale.set(scale, scale);
	tree.updateHitbox();
	addBehindDad(tree);
	
	treeLeaves = new OffsetSprite(bg.x + 1235 * scale, bg.y + 155 * scale).setFrames(Paths.getAtlas(path + 'treeleaves'), false);
	treeLeaves.animation.addByPrefix('i', 'leaf anim', 24);
	treeLeaves.animation.play('i');
	treeLeaves.scale.set(scale, scale);
	treeLeaves.updateHitbox();
	treeLeaves.scrollFactor.set(0.8, 0.8);
	addBehindDad(treeLeaves);
	
	rock = new OffsetSprite(bg.x + 279 * scale, bg.y + 407 * scale).loadGraphic(Paths.image(path + 'randomrock'));
	rock.scrollFactor.set(0.85, 0.85);
	rock.scale.set(scale, scale);
	rock.updateHitbox();
	// rock.x *= rock.scrollFact
	addBehindDad(rock);
	
	stones = new OffsetSprite(bg.x + 851 * scale, bg.y + 407 * scale).loadGraphic(Paths.image(path + 'stepping_stones'));
	stones.scrollFactor.set(0.9, 0.9);
	stones.scale.set(scale, scale);
	stones.updateHitbox();
	addBehindDad(stones);
	
	floor = new OffsetSprite(bg.x + 391 * scale, bg.y + 528 * scale).loadGraphic(Paths.image(path + 'platform'));
	// bg.scrollFactor.set(0.2, 0.2);
	floor.scale.set(scale, scale);
	floor.updateHitbox();
	addBehindDad(floor);
	
	chains = new OffsetSprite(bg.x + 165 * scale, bg.y + 423 * scale).loadGraphic(Paths.image(path + 'chain_left'));
	// bg.scrollFactor.set(0.2, 0.2);
	chains.scale.set(scale, scale);
	chains.updateHitbox();
	add(chains);
	
	chainsRight = new OffsetSprite(bg.x + (165 + 1108) * scale, bg.y + (423 + 55) * scale).loadGraphic(Paths.image(path + 'chain_right'));
	// bg.scrollFactor.set(0.2, 0.2);
	chainsRight.scale.set(scale, scale);
	chainsRight.updateHitbox();
	add(chainsRight);
	
	fgL = new OffsetSprite(bg.x + 200, bg.y + 105 * scale).loadGraphic(Paths.image(path + 'foreground_stonesLeft'));
	fgL.scrollFactor.set(1.1, 1.1);
	fgL.scale.set(scale, scale);
	fgL.updateHitbox();
	add(fgL);
	
	fgR = new OffsetSprite(bg.x + 200 + (1587 * scale), bg.y + 105 * scale + (23 * scale)).loadGraphic(Paths.image(path + 'foreground_stonesRight'));
	fgR.scrollFactor.set(1.1, 1.1);
	fgR.scale.set(scale, scale);
	fgR.updateHitbox();
	add(fgR);
	
	gradient = FlxGradient.createGradientFlxSprite(1, bg.frameHeight * scale, [0x0, 0xFFff001e]);
	gradient.scale.x = bg.width;
	gradient.updateHitbox();
	add(gradient);
	gradient.alpha = 0.2;
	gradient.scrollFactor.set(1.1, 1.1);
	
	bg.x -= bg.width / 4;
	bg.y -= bg.height / 4;
	
	bgGradient.x = bg.x;
	bgGradient.y = bg.y;
	
	gradient.setPosition(bg.x + 1600, bg.y + 500);
	
	skyGraphic.x -= 900;
	skyGraphic.y -= 400;
	
	clouds.x -= 600;
	clouds.y -= 400;
	
	tree.x -= 200;
	treeLeaves.x -= 200;
	
	rock.x -= 300;
	rock.y -= 300;
	
	for (i in 0...3)
	{
		var meteor = new FlxSprite().loadSparrowFrames('stages/firewall/meteor');
		meteor.animation.addByPrefix('i', 'meteor', 24);
		meteor.animation.play('i');
		meteor.flipX = true;
		
		meteor.scale.set(0.8, 0.8);
		
		meteor.scrollFactor.set(0.2, 0.2);
		
		meteor.velocity.set(1800, 1800);
		
		insert(members.indexOf(bgGradient) + 1, meteor);
		meteor.shader = colorSwap.shader;
		
		meteors.push(meteor);
	}
	
	for (i in [bg, cloudsBehind, skyGraphic, clouds, tree, treeLeaves, rock, stones, floor, chains, chainsRight, fgL, fgR])
	{
		i.shader = colorSwap.shader;
	}
	gradient.shader = colorSwap.shader;
	// colorSwap.hue = 0.6;
	
	setVar('firewall_colourSwap', colorSwap);
}

function onStartCountdown()
{
	if (!introReady) return Constants.SCRIPT_STOP;
	
	return Constants.SCRIPT_CONTINUE;
}

function onCreatePost()
{
	rimLight = new DropShadowShader();
	
	rimLight.baseHue = 20;
	boyfriend.color = 0xFFFFA2A2;
	
	boyfriend.shader = rimLight;
	rimLight.attachedSprite = boyfriend.atlas;
	
	rimLight.baseBrightness = -10;
	// rimLight.baseHue = -5;
	
	rimLight.color = FlxColor.RED;
	rimLight.angle = 140;
	rimLight.threshold = 0.1;
	rimLight.distance = 25;
	
	var bf:Character = boyfriend;
	boyfriend.atlas.animation.onFrameChange.add((anmim, num, idx) -> {
		rimLight.updateFrameInfo(bf.atlas.frame);
	});
	
	// if (!skipIntro) camOther.bgColor = FlxColor.BLACK;
	
	advideBlue = new FlxSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
	advideBlue.color = 0xFF2020F6;
	add(advideBlue);
	advideBlue.cameras = [camOther];
	advideBlue.visible = false;
	
	bsod = new FlxSprite(0, 0, Paths.image('stages/firewall/bluescreenFull'));
	add(bsod);
	bsod.cameras = [camOther];
	
	bsod.visible = false;
	
	whiteOverlay = new FlxBGSprite();
	whiteOverlay.color = FlxColor.WHITE;
	whiteOverlay.alpha = 0;
	whiteOverlay.cameras = [camOther];
	add(whiteOverlay);
	
	Paths.image('stages/firewall/popup');
	
	glitchShader.setFloat('meltPresence', 0);
	glitchShader.setFloat('mosaic', 0.01);
	
	if (ClientPrefs.data.shaders) CoolUtil.addShader(glitchShader);
	
	ditherSprite = new FlxSprite().makeScaledGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	
	ditherSprite.shader = new DitherShader();
	
	ditherSprite.cameras = [camHUD];
	
	ditherSprite.shader.color = FlxColor.TRANSPARENT;
	ditherSprite.shader.transparency = 1;
	add(ditherSprite);
	add(intro);
	
	return Constants.SCRIPT_CONTINUE;
}

function onSongStart()
{
	if (!skipIntro)
	{
		intro.resume();
		intro.bitmap.time = 0;
		intro.tiedToGame = true;
		intro.visible = true;
	}
}

var canUpdateFloaters:Bool = true;
var sinVal:Float = 0;

function onUpdatePost(e)
{
	if (canUpdateFloaters) sinVal = (sinVal + e) % (1 / 0.4);
	
	var sinMovement = 8.2 * FlxMath.fastSin(Math.PI * sinVal * 0.8);
	var cosMovement = 8.2 * FlxMath.fastCos(Math.PI * sinVal * 0.8);
	
	floor.offset2.x = cosMovement;
	floor.offset2.y = sinMovement;
	
	chains.offset2.x = cosMovement;
	chains.offset2.y = sinMovement;
	
	chainsRight.offset2.x = cosMovement;
	chainsRight.offset2.y = sinMovement;
	
	dad.offset2.x = floor.offset2.x;
	dad.offset2.y = floor.offset2.y;
	
	boyfriend.offset2.x = floor.offset2.x;
	boyfriend.offset2.y = floor.offset2.y;
	
	stones.offset2.x = cosMovement * 0.5;
	stones.offset2.y = sinMovement * 0.5;
	
	rock.offset2.x = cosMovement * 0.3;
	rock.offset2.y = sinMovement * 0.3;
	rock.angle = cosMovement * 0.05;
	
	tree.offset2.x = -cosMovement;
	tree.offset2.y = sinMovement;
	
	treeLeaves.offset2.x = tree.offset2.x;
	treeLeaves.offset2.y = tree.offset2.y;
	
	skyGraphic.offset2.y = sinMovement * 0.5;
	bluescreen.offset2.y = sinMovement * 0.5;
	
	clouds.angle = cosMovement * 0.01;
	
	if (canUpdateFloaters)
	{
		var setVal = MathUtil.decayLerp(currentGlitchValue, glitchIntendedValue, 8, e);
		// trace(glitchShader.getFloat('meltPresence'));
		currentGlitchValue = setVal;
		glitchShader.setFloat('meltPresence', setVal);
		
		// since we know its 3 this will run better
		meteors[0].x = FlxMath.wrap(meteors[0].x, bg.x, bg.x + bg.width - (meteors[0].frameWidth * meteors[0].scale.x));
		meteors[0].y = FlxMath.wrap(meteors[0].y, bg.y, bg.y + bg.height - (meteors[0].frameHeight * meteors[0].scale.y));
		
		meteors[1].x = FlxMath.wrap(meteors[1].x, bg.x, bg.x + bg.width - (meteors[1].frameWidth * meteors[1].scale.x));
		meteors[1].y = FlxMath.wrap(meteors[1].y, bg.y, bg.y + bg.height - (meteors[1].frameHeight * meteors[1].scale.y));
		
		meteors[2].x = FlxMath.wrap(meteors[2].x, bg.x, bg.x + bg.width - (meteors[2].frameWidth * meteors[2].scale.x));
		meteors[2].y = FlxMath.wrap(meteors[2].y, bg.y, bg.y + bg.height - (meteors[2].frameHeight * meteors[2].scale.y));
	}
}

function onSectionHit()
{
	gradient.alpha = 0.3;
	
	FlxTween.tween(gradient, {alpha: 0.2}, (Conductor.stepCrochet / 1000) * 2);
}

var canBumpGlitch = false;

function onBeatHit()
{
	if (canBumpGlitch && !mustHitSection && curBeat % 1 == 0)
	{
		currentGlitchValue += 0.05;
	}
}

function onEvent(ev, v1, v2, time)
{
	if (ev == '')
	{
		if (v1 == 'bumpGlitch')
		{
			canBumpGlitch = !canBumpGlitch;
			if (canBumpGlitch)
			{
				currentGlitchValue += 0.05;
			}
		}
		if (v1 == 'glitch')
		{
			// defaultCamZoom = 0.5;
			new FlxTimer().start(0.05, tmr -> {
				dad.playAnim('singRIGHT-blue', true);
				// dad.
			}, 0);
			canUpdateFloaters = false;
			
			for (i in meteors)
			{
				i.velocity.set(0, 0);
			}
			FlxTween.num(defaultCamZoom, defaultCamZoom + 0.2, 1.5, {ease: FlxEase.sineIn}, (f) -> {
				defaultCamZoom = f;
			});
			
			FlxTween.num(0, 0.7, 1.5, {ease: FlxEase.sineIn}, (f) -> {
				glitchShader.setFloat('meltPresence', f);
			});
		}
		if (v1 == 'freeze')
		{
			fakeFreeze(true);
		}
		if (v1 == 'unfreeze')
		{
			for (popUp in popUps)
				popUp.visible = false;
			fakeFreeze(false);
		}
		if (v1 == 'popup')
		{
			var popUp = new FlxSprite(0, 0, Paths.image('stages/firewall/popup'));
			add(popUp);
			popUp.cameras = [camOther];
			popUp.screenCenter();
			popUp.scale.set(0.95, 0.95);
			
			popUp.antialiasing = false;
			
			FlxTween.tween(popUp, {'scale.x': 1, 'scale.y': 1}, 0.05, {ease: FlxEase.cubeInOut});
			
			if (popUps.length != 0)
			{
				popUp.x = FlxG.random.int(0, FlxG.width - popUp.width);
				popUp.y = FlxG.random.int(0, FlxG.height - popUp.height);
				// popUp.x += FlxG.random.int(-popUp.width, popUp.width);
				// popUp.y += FlxG.random.int(-popUp.height, popUp.height);
			}
			
			popUps.push(popUp);
		}
		if (v1 == 'bsod')
		{
			bsod.visible = !bsod.visible;
			advideBlue.visible = bsod.visible;
		}
		if (v1 == 'bsodTransition')
		{
			FlxTween.tween(bsod, {alpha: 0}, 1.7);
		}
		if (v1 == 'showHUD')
		{
			// camOther.bgColor = 0x0;
			// camHUD.flash();
			
			FlxTween.tween(ditherSprite.shader, {transparency: 0}, 0.3,
				{
					onComplete: Void -> {
						ditherSprite.visible = false;
					}
				});
				
			// camHUD.zoom = 20; // temp
			// camHUD.alpha = 1;
		}
		if (v1 == '3d')
		{
			setMode(2);
		}
		else if (v1 == 'waterfall')
		{
			setMode(1);
		}
		else if (v1 == 'normal')
		{
			setMode(0);
		}
	}
	
	return Constants.SCRIPT_CONTINUE;
}

function setMode(type:Int)
{
	rimLight.color = FlxColor.RED;
	
	bluescreen.visible = false;
	if (type == 0)
	{
		//
		colorSwap.hue = 0;
		
		dad.danceIdle = true;
		animSuffix = '';
		dad.idleSuffix = '';
		dad.dance();
	}
	else if (type == 1)
	{
		bluescreen.visible = true;
		
		colorSwap.hue = 0.6;
		
		dad.danceIdle = false;
		animSuffix = '-blue';
		dad.idleSuffix = '-blue';
		dad.dance();
		
		rimLight.baseBrightness = 0;
		boyfriend.color = 0xFF8D8DFF;
		
		rimLight.color = 0xFF8D8DFF;
	}
	else if (type == 2)
	{
		colorSwap.hue = 0;
		
		dad.danceIdle = false;
		animSuffix = '-3d';
		dad.idleSuffix = '-3d';
		
		dad.dance();
	}
}

function opponentNoteHit(note)
{
	note.animSuffix = animSuffix;
}

var seenVideo:Bool = false;

function onEndSong()
{
	//
	if (!seenVideo)
	{
		// var camera = new FlxCamera();
		// // camera.bgColor = 0x0;
		// FlxG.cameras.add(camera, false);
		startVideo('paldoEnding');
		VideoCutscene.instance.bg.alpha = 0;
		VideoCutscene.instance.ditherOnFinish = false;
		
		FlxTimer.wait(1, () -> {
			advideBlue.color = FlxColor.BLACK;
		});
		
		seenVideo = true;
		return Constants.SCRIPT_STOP;
	}
	return Constants.SCRIPT_CONTINUE;
}

function fakeFreeze(enabled:Bool)
{
	FPSCounter.ALLOW_UPDATES = !enabled;
	
	FlxG.animationTimeScale = enabled ? 0 : 1;
	
	game.iconsActive = !enabled;
	game.inCutscene = enabled;
	game.clockAllowedToTick = !enabled;
	game.camZooming = !enabled;
	game.canPause = !enabled;
	
	canUpdateFloaters = !enabled;
	
	boyfriend.stunned = enabled;
	dad.stunned = enabled;
	// gf.stunned = enabled;
	
	boyfriend.holdTimer = enabled ? -10000 : 0;
	dad.holdTimer = enabled ? -10000 : 0;
	// gf.holdTimer = enabled ? -10000 : 0;
	
	FlxTween.cancelTweensOf(whiteOverlay, ['alpha']);
	
	if (enabled) FlxTween.tween(whiteOverlay, {alpha: 0.4}, 0.4);
	else whiteOverlay.alpha = 0;
	
	setWindowName();
	if (enabled) FlxG.stage.window.title += " (Not Responding)";
}
