package funkin.states.stages;

import funkin.shaders.DitherShader;

import extensions.flixel.FlxUniformSprite;

import openfl.geom.Vector3D;

import away3d.cameras.Camera3D;
import away3d.library.assets.IAsset;

import debug.FPSCounter;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.FlxSprite;
import flixel.system.FlxBGSprite;

import funkin.backend.Conductor;
import funkin.objects.Character3D;
import funkin.objects.Note;
import funkin.utils.CoolUtil;
import funkin.shaders.Mosaic;
import funkin.backend.ClientPrefs;
import funkin.backend.Paths;
import funkin.shaders.GlitchShader;
import funkin.states.PlayState;
import funkin.objects.Character;
import funkin.objects.StrumNote;
import funkin.utils.MathUtil;
import funkin.game.VideoCutscene;
import funkin.backend.RenderCache;

using StringTools;

var whiteOverlay:FlxBGSprite;
var nullCharacter:Character;
var nullCamera:Null<FlxCamera> = null;
var screenCrackCamera:Null<FlxCamera> = null;
var isNullSection:Bool = false;
var nullStaticBg:FlxSprite;
var screenCrack:FlxSprite;
var isUsingModChartMode:Bool = false;
var autoGlitchShaderBreakup:Bool = false;
var glitchShader:GlitchShader = new GlitchShader();
var glitchShader2:GlitchShader = new GlitchShader();

// horrible variable names forgive me
var glitchIndex:Int = 0;
var canAlternateGlitch:Bool = false;

// camera shit
var camRootPos = new Vector3D();
var additivePos = new FlxPoint();
var camRotation = 0;

// 3d
var loaded3d:Bool = false;
var boyfriend3D:Character3D = null;
var dad3D:Character3D = null;
var gf3D:Character3D = null;
var caughtMeshes = [];
var ditherSprite:FlxSprite;

function onCreate()
{
	PlayState.instance.skipCountdown = true;
	
	startHScriptsNamed('stages/classroom.hx'); // wapow
	
	variables.get('stage_noteBook').visible = false;
	
	Paths.sound('glashSmash');
}

function onCreatePost()
{
	glitchShader.squareAmount = 0.1;
	glitchShader.glitchSpeedMult = 3;
	
	whiteOverlay = new FlxBGSprite();
	whiteOverlay.color = FlxColor.WHITE;
	whiteOverlay.alpha = 0;
	whiteOverlay.cameras = [camOther];
	add(whiteOverlay);
	
	screenCrackCamera = new FlxCamera();
	screenCrackCamera.bgColor = 0x0;
	FlxG.cameras.add(screenCrackCamera, false);
	
	nullCamera = new FlxCamera();
	nullCamera.bgColor = 0x0;
	FlxG.cameras.add(nullCamera, false);
	
	nullStaticBg = new FlxSprite();
	nullStaticBg.frames = Paths.getSparrowAtlas('stages/classroom/null/static');
	nullStaticBg.animation.addByPrefix('i', 'null_bg_bro_', ClientPrefs.data.flashing ? 16 : 4);
	nullStaticBg.scale.set(1.5, 1.5);
	nullStaticBg.updateHitbox();
	nullStaticBg.animation.play('i');
	nullStaticBg.screenCenter();
	nullStaticBg.x -= 400;
	nullStaticBg.y -= 25;
	add(nullStaticBg);
	nullStaticBg.alpha = 0;
	
	if (!ClientPrefs.data.flashing) nullStaticBg.color = 0xFF8F8F8F;
	
	nullGlitchBg = new FlxSprite();
	nullGlitchBg.frames = Paths.getSparrowAtlas('stages/classroom/null/glitch2');
	
	var glitchRate = ClientPrefs.data.flashing ? 1 : 0.5;
	nullGlitchBg.animation.addByPrefix('i', 'i', 8 * glitchRate);
	nullGlitchBg.animation.addByIndices('0', 'i', [0, 1, 2, 3], '', 12 * glitchRate, false);
	nullGlitchBg.animation.addByIndices('1', 'i', [4, 5, 6, 77], '', 12 * glitchRate, false);
	nullGlitchBg.animation.addByIndices('2', 'i', [8, 9, 10, 11], '', 12 * glitchRate, false);
	nullGlitchBg.animation.onFinish.add((anim) -> canAlternateGlitch = true);
	nullGlitchBg.scale.set(1.5, 1.5);
	nullGlitchBg.updateHitbox();
	nullGlitchBg.animation.play('i');
	nullGlitchBg.screenCenter();
	nullGlitchBg.x -= 400;
	nullGlitchBg.y -= 25;
	add(nullGlitchBg);
	nullGlitchBg.alpha = 0;
	
	screenCrack = new FlxSprite();
	screenCrack.frames = Paths.getSparrowAtlas('stages/classroom/null/crack2');
	screenCrack.animation.addByPrefix('i', 'crack', ClientPrefs.data.flashing ? 8 : 4);
	screenCrack.animation.play('i');
	screenCrack.screenCenter();
	add(screenCrack);
	screenCrack.y += 50;
	screenCrack.alpha = 0;
	screenCrack.cameras = [screenCrackCamera];
	
	nullCharacter = new Character(0, 0, 'null-expul');
	add(nullCharacter);
	startCharacterPos(nullCharacter);
	nullCharacter.cameras = [nullCamera];
	nullCharacter.alpha = 0;
	
	ditherSprite = new FlxUniformSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	// insert(0, ditherSprite);
	add(ditherSprite);
	ditherSprite.cameras = [camHUD];
	
	ditherSprite.shader = new DitherShader();
	ditherSprite.shader.color = FlxColor.TRANSPARENT;
	ditherSprite.shader.transparency = 0;
	ditherSprite.visible = false;
	
	setVar('expulsion_null', nullCharacter);
	
	// precache some dummys
	
	var renderCacher = new RenderCache();
	
	add(renderCacher);
	renderCacher.push(nullStaticBg);
	renderCacher.push(nullGlitchBg);
	renderCacher.push(screenCrack);
	renderCacher.push(nullCharacter);
	
	renderCacher.render();
	
	return Constants.SCRIPT_CONTINUE;
}

var glitchShaderUpdates:Bool = true;

function onUpdate(elapsed:Float)
{
	if (loaded3d && view != null && view.camera != null)
	{
		view.camera.x = MathUtil.decayLerp(view.camera.x, camRootPos.x + additivePos.x, 2.4 * cameraSpeed * playbackRate, elapsed);
		view.camera.y = MathUtil.decayLerp(view.camera.y, camRootPos.y + additivePos.y, 2.4 * cameraSpeed * playbackRate, elapsed);
		view.camera.z = camRootPos.z + ((FlxG.camera.zoom - defaultCamZoom) * 300); // 300 feels like a really stupid number and it is but its alright
		
		view.camera.rotationY = MathUtil.decayLerp(view.camera.rotationY, camRotation, 2.4 * cameraSpeed * playbackRate, elapsed);
		
		if (boyfriend3D != null)
		{
			boyfriend3D.rotationY = view.camera.rotationY;
		}
		
		if (dad3D != null)
		{
			dad3D.rotationY = view.camera.rotationY;
		}
		
		if (gf3D != null)
		{
			gf3D.rotationY = view.camera.rotationY;
		}
	}
	
	// EXPULSION
	glitchShader.update(elapsed);
	glitchShader2.update(elapsed);
	
	if (autoGlitchShaderBreakup)
	{
		glitchShader.squareAmount += elapsed;
		glitchShader.glitchSpeedMult += elapsed / 5;
		
		glitchShader2.squareAmount += elapsed;
		glitchShader2.glitchSpeedMult += elapsed / 5;
	}
	
	nullCamera.zoom = 0.85 + (FlxG.camera.zoom - defaultCamZoom);
	
	if (isUsingModChartMode)
	{
		var x = -278;
		var y = (ClientPrefs.data.downScroll ? FlxG.height - 150 : 50);
		var offset = ClientPrefs.data.downScroll ? -40 : 40;
		for (i in playerStrums)
		{
			var newX = x + i.getPostPos(1);
			i.x = MathUtil.decayLerp(i.x, newX, 36, elapsed);
			
			var newAngle = Math.sin((Conductor.songPosition / 300 + (i.ID / 1.5)) * Math.PI / 8) * 5;
			i.angle = MathUtil.decayLerp(i.angle, newAngle, 36, elapsed);
			
			var newY = y + offset + (Math.sin((Conductor.songPosition / 300 + (i.ID * 4)) * Math.PI / 16) * 50);
			i.y = MathUtil.decayLerp(i.y, newY, 36, elapsed);
		}
	}
}

function onUpdatePost(e)
{
	if (isNullSection)
	{
		nullCameraFollow();
	}
}

function nullCameraFollow()
{
	var newPos = nullStaticBg.getMidpoint();
	var additive = getDisplacePoint(nullCharacter);
	newPos.x += additive.x;
	newPos.y += additive.y;
	
	camFollow.setPosition(newPos.x, newPos.y);
}

function onStartCountdown()
{
	return loaded3d ? Function_Continue : Function_Stop;
}

function onCountdownStarted()
{
	var oppAlpha = ClientPrefs.data.opponentStrums ? ClientPrefs.data.middleScroll ? 0.35 : 1 : 0;
	for (i in opponentStrums)
	{
		i.fadeIn(oppAlpha);
	}
	for (i in playerStrums)
	{
		i.fadeIn(1);
	}
}

function opponentNoteHit(note:Note)
{
	if (!note.noAnimation)
	{
		if (nullCharacter != null && nullCharacter.alpha >= 0.1)
		{
			var animToPlay:String = game.singAnimations[Std.int(Math.abs(Math.min(game.singAnimations.length - 1, note.noteData)))];
			
			nullCharacter.playAnim(animToPlay, true);
			nullCharacter.holdTimer = 0;
		}
	}
}

function onBeatHit()
{
	if (nullCharacter != null)
	{
		if (curBeat % nullCharacter.danceEveryNumBeats == 0
			&& !nullCharacter.getAnimationName().startsWith('sing')
			&& !nullCharacter.stunned) nullCharacter.dance();
	}
	
	if (canAlternateGlitch)
	{
		glitchIndex = FlxMath.wrap(glitchIndex + 1, 0, 2);
		canAlternateGlitch = false;
		
		nullGlitchBg.animation.play(Std.string(glitchIndex));
	}
}

function onEvent(eventName:String, value1:String, value2:String, strumTime:Float)
{
	switch (eventName)
	{
		case "toggle 3d":
			toggle3D(value1 == 'on');
			
		case 'nullIntro': // screencrack
			fakeFreeze(true);
			
			nullCharacter.alpha = 1;
			nullCharacter.playAnim('in');
			nullCharacter.specialAnim = true;
			
			camOther.flash(FlxColor.WHITE, 0.2);
			
			for (camera in FlxG.cameras.list)
				camera.shake(0.0075 * (ClientPrefs.data.flashing ? 1 : 0.5), 0.2);
				
			screenCrack.alpha = 0.6;
			
			FlxG.sound.play(Paths.sound('glashSmash'));
			
		case 'freezeGame':
			fakeFreeze(value1 == 'true');
			
		case 'switchUI':
			switchUI(value1 == 'true');
			
		case "removeStrumNote":
			var whichNote = Std.parseInt(value1);
			var target = value2 == "" ? playerStrums : opponentStrums;
			
			FlxTween.tween(target.members[whichNote], {alpha: 0.0}, (Conductor.crochet * 4) / 1000 + 0.1, {ease: FlxEase.sineIn});
		case 'shiftNotesRandom':
			isUsingModChartMode = false;
			for (i in playerStrums.members)
			{
				i.x = FlxG.random.int(100, FlxG.width - i.width - 100);
				i.y = FlxG.random.int(100, FlxG.height - i.height - 100);
				i.angle = FlxG.random.int(0, 360);
				
				var directionX = FlxMath.signOf(i.x - (FlxG.width / 2));
				var directionY = FlxMath.signOf(i.y - (FlxG.height / 2));
				
				i.velocity.x = FlxG.random.int(10, 30) * directionX * 8;
				i.velocity.y = FlxG.random.int(10, 30) * directionX * 8;
				
				i.drag.x = Math.abs(i.velocity.x) * 3;
				i.drag.y = Math.abs(i.velocity.y) * 3;
				
				i.angularVelocity = FlxG.random.float() * 40 * directionX;
			}
			
			// also make null shader freak
			nullCharacter.alpha = FlxG.random.float(0.5, 0.8);
			
			if (nullCharacter.shader == null) nullCharacter.shader = glitchShader2; // whatever
			
			glitchShader2.squareAmount = 0.3;
			glitchShader2.glitchSpeedMult = 2;
			
			glitchShader.squareAmount = 0.05;
			glitchShader.glitchSpeedMult = 1;
			
		case '':
			if (value1 == 'realignNotes')
			{
				isUsingModChartMode = true;
				for (i in playerStrums.members)
				{
					i.velocity.set();
					i.angle = 0;
					i.angularVelocity = 0;
				}
			}
			else if (value1 == 'glitchShader')
			{
				if (ClientPrefs.data.shaders && ClientPrefs.data.flashing) CoolUtil.addShader(glitchShader);
			}
			else if (value1 == 'null_error')
			{
				// game.addTextToDebug('[assets/stages/expulsion.hx] NULL REFERENCE EXCEPTION', FlxColor.RED);
				game.addTextToDebug('Exception has occured. Null Object Reference', FlxColor.RED);
				
				var idx = 0;
				luaDebugGroup.forEachAlive(spr -> {
					spr.size = 16;
					spr.updateHitbox();
					spr.y = (spr.height + 2) * idx;
					idx += 1;
				});
			}
			else if (value1 == 'dither')
			{
				// ditherSprite.shader.transparency = 1;
				ditherSprite.visible = true;
				FlxTween.cancelTweensOf(ditherSprite.shader, ['transparency']);
				
				FlxTween.tween(ditherSprite.shader, {transparency: value2}, 0.35);
			}
		case 'fileNameGlitchTrans':
			if (value1 == 'into') // this is after the mini baldi segment
			{
				autoGlitchShaderBreakup = false;
				
				if (ClientPrefs.data.shaders && ClientPrefs.data.flashing)
				{
					CoolUtil.addShader(glitchShader);
					glitchShader.squareAmount = 0.6;
					FlxTween.tween(glitchShader, {squareAmount: 0}, 1,
						{
							onComplete: Void -> {
								CoolUtil.removeShader(glitchShader);
							}
						});
				}
			}
			else // this is entering it
			{
				autoGlitchShaderBreakup = true;
				nullCharacter.shader = glitchShader2;
				
				fakeFreeze(true);
				
				if (ClientPrefs.data.shaders && ClientPrefs.data.flashing)
				{
					var shader = new Mosaic();
					shader.pixelSize = 1;
					CoolUtil.addShader(shader);
					FlxTween.tween(shader, {pixelSize: 5}, 1.35,
						{
							onComplete: Void -> {
								CoolUtil.removeShader(shader);
								shader = null;
							}
						});
				}
			}
			
		case 'spamBop':
			camGame.zoom = 0.9;
			FlxTween.tween(camGame, {zoom: 0.85}, 0.05);
			nullCharacter.stunned = true;
			nullCharacter.playAnim('singRIGHT', true);
			nullCharacter.alpha = FlxG.random.float(0.1, 0.8);
		case 'returnToBaldi':
			fakeFreeze(false);
			
			variables.get('stage_bg').color = 0xFF7C7C7C;
			variables.get('stage_chalkboard').color = 0xFF7C7C7C;
			variables.get('stage_chairs').color = 0xFF7C7C7C;
			variables.get('stage_fgTable').color = 0xFF7C7C7C;
			
			nullCharacter.alpha = value1 == '2nd' ? 0 : 0.005;
			nullStaticBg.alpha = 0;
			nullGlitchBg.alpha = 0;
			
			for (i in [uiGroup])
				i.visible = !ClientPrefs.data.hideHud;
				
			isNullSection = false;
			
			modchartMode(false);
			toggle3D(false);
			
			camGame.visible = true;
			if (nullCharacter != null) nullCharacter.stunned = false;
		case 'enterNullSection':
			luaDebugGroup.forEachAlive(spr -> {
				spr.kill();
			});
			switchUI(false);
			// nullCharacter.shader = null;
			glitchShader2.squareAmount = 0;
			
			for (i in [PlayState.instance.uiGroup])
				i.visible = false;
				
			nullCharacter.alpha = nullStaticBg.alpha = 1;
			nullGlitchBg.alpha = 1;
			nullGlitchBg.animation.play(Std.string(glitchIndex));
			
			nullCameraFollow();
			FlxG.camera.snapToTarget();
			
			isNullSection = true;
			modchartMode(true);
			
			camHUD.visible = camGame.visible = true;
			FlxG.camera.flash(FlxColor.WHITE, 0.7);
			
			if (ClientPrefs.data.shaders && ClientPrefs.data.flashing)
			{
				var shader = new Mosaic();
				shader.pixelSize = 40;
				nullStaticBg.shader = shader;
				FlxTween.tween(shader, {pixelSize: 1}, 1.2, {ease: FlxEase.expoOut});
			}
			
			FlxTween.tween(camGame, {zoom: 0.85}, 0.7,
				{
					ease: FlxEase.expoOut,
					onUpdate: Void -> {
						defaultCamZoom = camGame.zoom;
					}
				});
	}
}

function switchUI(use3D:Bool)
{
	for (i in [
		PlayState.instance.scoreTxt,
		PlayState.instance.healthBar,
		PlayState.instance.iconP1,
		PlayState.instance.iconP2,
		PlayState.instance.clock
	])
	{
		i.antialiasing = (use3D ? false : ClientPrefs.data.antialiasing);
	}
	
	if (use3D)
	{
		PlayState.instance.clock.loadGraphic(Paths.image('ui/clock-real'));
		PlayState.instance.healthBar.bg.loadGraphic(Paths.image('ui/healthBar-real'));
		PlayState.instance.healthBar.leftBar.loadGraphic(Paths.image('ui/healthBar-realBar'));
		PlayState.instance.healthBar.rightBar.loadGraphic(Paths.image('ui/healthBar-realBar'));
	}
	else
	{
		PlayState.instance.clock.loadGraphic(Paths.image('ui/clock'));
		PlayState.instance.healthBar.bg.loadGraphic(Paths.image('ui/healthBar'));
		PlayState.instance.healthBar.leftBar.loadGraphic(Paths.image('ui/healthBarBar'));
		PlayState.instance.healthBar.rightBar.loadGraphic(Paths.image('ui/healthBarBar'));
	}
}

function fakeFreeze(enabled:Bool)
{
	FPSCounter.ALLOW_UPDATES = !enabled;
	
	game.iconsActive = !enabled;
	game.inCutscene = enabled;
	game.clockAllowedToTick = !enabled;
	game.camZooming = !enabled;
	game.canPause = !enabled;
	
	boyfriend.stunned = enabled;
	dad.stunned = enabled;
	gf.stunned = enabled;
	
	boyfriend.holdTimer = enabled ? -10000 : 0;
	dad.holdTimer = enabled ? -10000 : 0;
	gf.holdTimer = enabled ? -10000 : 0;
	
	FlxTween.cancelTweensOf(whiteOverlay, ['alpha']);
	
	if (enabled) FlxTween.tween(whiteOverlay, {alpha: 0.4}, 0.4);
	else whiteOverlay.alpha = 0;
	
	setWindowName();
	if (enabled) FlxG.stage.window.title += " (Not Responding)";
}

function modchartMode(active:Bool):Void
{
	isUsingModChartMode = active;
	
	setVar('expulsion_isNullSection', isUsingModChartMode);
	if (active)
	{
		StrumNote.positionStrumline(playerStrums, 1);
		for (i in opponentStrums)
		{
			i.x = -2000;
		}
		for (i in playerStrums)
		{
			// i.alpha = 0.9;
			i.blend = BlendMode.ADD;
		}
	}
	else
	{
		StrumNote.positionStrumline(opponentStrums, ClientPrefs.data.middleScroll ? 0 : 2);
		StrumNote.positionStrumline(playerStrums, ClientPrefs.data.middleScroll ? 1 : 3);
		
		for (i in playerStrums)
		{
			// i.alpha = 0.9;
			i.blend = BlendMode.NORMAL;
		}
	}
}

function onLoadComplete()
{
	boyfriend3D = new Character3D(boyfriendMap.get('bf-3d'));
	dad3D = new Character3D(dadMap.get('baldi-3d'));
	gf3D = new Character3D(gfMap.get('gf-3d'));
	
	view.scene.addChild(gf3D);
	gf3D.x = -20;
	gf3D.y = 55;
	gf3D.z = 206;
	
	view.scene.addChild(boyfriend3D);
	boyfriend3D.x = 120;
	boyfriend3D.y = 90;
	boyfriend3D.z = 150;
	
	view.scene.addChild(dad3D);
	dad3D.x = -105;
	dad3D.y = 85;
	dad3D.z = 166;
	
	loaded3d = true;
	
	game.startCountdown();
	
	// cpuControlled = true;
	// PlayState.startOnTime = 235000;
}

function toggle3D(active:Bool)
{
	view.visible = active;
	FlxG.camera.visible = !view.visible;
	
	if (!active) camHUD.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0xFF828282); // i think this i sok to do?
}

function onAssetLoad(asset:IAsset, type:String)
{
	if (asset == null) return;
	
	caughtMeshes.push(asset);
	
	switch (type)
	{
		case "container":
			view.scene.addChild(asset);
		case "mesh":
			view.scene.addChild(asset);
		case "camera":
			switch (asset.extra.name)
			{
				case "MainCamera":
					asset.lens.far = 10000;
					view.camera = asset;
					
					camRootPos.setTo(view.camera.x, view.camera.y, view.camera.z);
			}
	}
}

function onDestroy()
{
	for (mesh in caughtMeshes)
	{
		if (mesh != null && mesh.dispose != null)
		{
			mesh.dispose();
			mesh = null;
		}
	}
	caughtMeshes.resize(0);
	
	if (boyfriend3D != null) boyfriend3D.dispose();
	if (gf3D != null) gf3D.dispose();
	if (dad3D != null) dad3D.dispose();
}

function onMoveCamera(char)
{
	if (!loaded3d) return;
	
	additivePos.set();
	
	var mult = 0.1;
	
	switch (char)
	{
		case "dad":
			var displace = getDisplacePoint(dad);
			additivePos.x += -25 + (displace.x * mult);
			additivePos.y -= displace.y * mult;
			
			camRotation = -5;
			
		case "boyfriend":
			var displace = getDisplacePoint(boyfriend);
			additivePos.x += 25 + (displace.x * mult);
			additivePos.y -= displace.y * mult;
			
			camRotation = 5;
	}
}

var seenVideo:Bool = false;

function onEndSong()
{
	//
	if (PlayState.isStoryMode && !seenVideo)
	{
		var camera = new FlxCamera();
		// camera.bgColor = 0x0;
		FlxG.cameras.add(camera, false);
		startVideo('post-expulsion');
		VideoCutscene.instance.ditherOnFinish = false;
		
		seenVideo = true;
		return Constants.SCRIPT_STOP;
	}
	return Constants.SCRIPT_CONTINUE;
}
