package assets.data.expulsion;

import extensions.flixel.FlxUniformSprite;

import flixel.tweens.FlxTween;

import funkin.backend.Controls;

import flixel.FlxSprite;
import flixel.FlxG;

import funkin.Constants;
import funkin.states.PlayState;
import funkin.states.StoryMenu;
import funkin.states.freeplay.FreeplayState;
import funkin.backend.DiscordClient;

import flixel.util.FlxTimer;

// gameover vars
var popUp:FlxSprite = null;
var whiteUnderlay:FlxSprite = null;
var canInteract:Bool = true;
var preventGameover:Bool = false;

function onCreatePost()
{
	getVar('setBaldiAnim')('-mad');
	
	if (PlayState.isStoryMode)
	{
		camFollow.x = PlayState.prevCamFollowX;
		camFollow.y = PlayState.prevCamFollowY;
		FlxG.camera.snapToTarget();
	}
}

function onEvent(ev, v1, v2, time)
{
	switch (ev)
	{
		case 'Set Property':
			if (v1 == 'camGame.alpha')
			{
				camGame.alpha = 1;
				
				camGame._fxFadeColor = FlxColor.BLACK;
				
				camGame._fxFadeAlpha = 1 - v2;
			}
			
			if (v1 == 'camHUD.alpha')
			{
				camHUD.alpha = 1;
				
				camHUD._fxFadeColor = FlxColor.BLACK;
				
				camHUD._fxFadeAlpha = 1 - v2;
			}
	}
}

function onUpdate(e)
{
	if (preventGameover)
	{
		if (canInteract)
		{
			if (Controls.instance.ACCEPT)
			{
				canInteract = false;
				if (popUp != null)
				{
					popUp.scale.set(1.05, 1.05);
					FlxTween.tween(popUp, {'scale.x': 1, 'scale.y': 1}, 0.05, {ease: FlxEase.cubeInOut, onComplete: Void -> popUp.visible = false});
					
					FlxTimer.wait(0.05, () -> {
						FlxG.resetState();
					});
				}
			}
			if (Controls.instance.BACK)
			{
				DiscordClient.resetClientID();
				FlxG.sound.music.stop();
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				PlayState.chartingMode = false;
				
				FlxG.animationTimeScale = 1;
				FlxTween.timeScale = 1;
				FlxTimer.timeScale = 1;
				
				if (PlayState.isStoryMode) FlxG.switchState(() -> new StoryMenu());
				else FlxG.switchState(() -> new FreeplayState());
				
				FlxG.sound.playMusic(Paths.music(Constants.MENU_MUSIC));
			}
		}
	}
}

function onGameOver()
{
	//
	if (preventGameover) return Constants.SCRIPT_STOP;
	
	if (!FlxG.camera.visible || (hasVar('expulsion_isNullSection') && getVar('expulsion_isNullSection') == true))
	{
		preventGameover = true;
		
		PlayState.instance.paused = true;
		
		PlayState.instance.cameraSpeed = 0;
		
		PlayState.instance.canReset = false;
		PlayState.instance.canPause = false;
		
		FlxG.animationTimeScale = 0;
		
		PlayState.deathCounter += 1;
		
		vocals.stop();
		FlxG.sound.music.stop();
		
		FlxG.sound.music.volume = 0;
		
		// half baked fix
		finishTimer = new FlxTimer();
		
		//
		
		boyfriend.playAnim('dead');
		boyfriend.debugMode = true;
		
		dad.debugMode = true;
		
		if (hasVar('expulsion_null'))
		{
			getVar('expulsion_null').debugMode = true;
		}
		
		//
		FlxG.sound.play(Paths.sound('windowsDing'));
		
		whiteUnderlay = new FlxUniformSprite().makeScaledGraphic(FlxG.width, FlxG.height);
		
		add(whiteUnderlay);
		whiteUnderlay.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		whiteUnderlay.alpha = 0;
		
		FlxTween.tween(whiteUnderlay, {alpha: 0.4}, 0.4);
		
		popUp = new FlxUniformSprite(0, 0, Paths.image('stages/firewall/popup'));
		add(popUp);
		popUp.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		
		popUp.screenCenter();
		popUp.scale.set(0.95, 0.95);
		
		popUp.antialiasing = false;
		
		FlxTween.tween(popUp, {'scale.x': 1, 'scale.y': 1}, 0.05, {ease: FlxEase.cubeInOut});
		
		return Constants.SCRIPT_STOP;
	}
	
	return Constants.SCRIPT_CONTINUE;
}
