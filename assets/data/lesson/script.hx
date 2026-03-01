import funkin.Constants;

import flixel.addons.transition.FlxTransitionableState;

import funkin.states.PlayState;
import funkin.backend.ClientPrefs;

import flixel.sound.FlxSound;
import flixel.FlxG;

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
import funkin.utils.RandomUtil;

import flixel.FlxSprite;

var bfAtlas:FlxAnimate;

function onCreate()
{
	Story.mathMisses = 0;
	
	initScript('scripts/thinkpad/script.hx');
	
	bfAtlas = getVar('thinkpad_spawnBf')();
	
	bfAtlas.visible = false;
}

function onCreatePost()
{
	getVar('thinkpad_baldiAtlas').atlas.anim.onFinish.removeAll();
	
	getVar('thinkpad_baldiAtlas').atlas.anim.onFinish.add((anim) -> getVar('thinkpad_baldiAtlas').playAnim('idle-mad'));
	
	if (PlayState.isStoryMode)
	{
		Paths.voices('expulsion');
		Paths.inst('expulsion');
	}
}

function onEndSong()
{
	Story.mathMisses = 0;
	
	if (PlayState.isStoryMode)
	{
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
	}
	
	return Constants.SCRIPT_CONTINUE;
}

function onEvent(ev, v1, v2, time)
{
	// trace(ev + ', ' + v1 + ', ' + v2);
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
		case '':
			switch (v1)
			{
				case "makeAngry":
					getVar('setBaldiAnim')('-mad');
					getVar('thinkpad_baldiAtlas').playAnim('failed');
					getVar('thinkpad_baldiAtlas').atlas.anim.onFinish.removeAll();
					getVar('thinkpad_baldiAtlas').visible = true;
					bfAtlas.visible = false;
				case 'fakeCheckMath':
					getVar('thinkpad_mathResolver').input = -10;
					getVar('thinkpad_mathResolver').resolveMath();
					
					getVar('thinkpad_thinkPadText').text = StringTools.replace(getVar('thinkpad_thinkPadText').text, '= ' + getVar('thinkpad_mathResolver').intendedValue, '');
					
					getVar('thinkpad_typedText').text = getBfAnswer();
			}
	}
}

function getBfAnswer()
{
	return RandomUtil.getObject(['31718', '90621', '94150', '0', '12', '42', '37.569']);
}
