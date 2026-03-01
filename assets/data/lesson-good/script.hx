import animate.FlxAnimate;

import funkin.utils.RandomUtil;

import flixel.addons.transition.FlxTransitionableState;

var bfAtlas:FlxAnimate;

function onCreate()
{
	initScript('scripts/thinkpad/script.hx');
	
	bfAtlas = getVar('thinkpad_spawnBf')();
	
	bfAtlas.visible = false;
}

function onCreatePost()
{
	if (PlayState.isStoryMode)
	{
		Paths.voices('expulsion');
		Paths.inst('expulsion');
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

function onEndSong()
{
	if (PlayState.isStoryMode)
	{
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
	}
	
	return Constants.SCRIPT_CONTINUE;
}
