package funkin.states;

import animate.FlxAnimateFrames;

import funkin.backend.InputFormatter;
import funkin.shaders.PolyTextShader;

import flixel.group.FlxContainer.FlxTypedContainer;

using flixel.util.FlxArrayUtil;

class CreditsState extends MusicBeatState
{
	var credits:FlxTypedContainer<BaldiText>;
	var loungeIcon:FlxSprite;
	
	var canInteract:Bool = true;
	
	override function create()
	{
		super.create();
		
		final creditsList:Array<String> = [
		
			"Advide - Director, Artist, Cutscene Animator",
			"Fidy50 - Director, Charter",
			"headdzo - Director, Composer, Animator",
			
			"",
			
			"data5 - Main Programmer",
			"SilverSpringing - Programmer",
			"Smokey5 - Programmer",
			"Wizardmantis441 - Programmer",
			
			'',
			
			"blackberri - Composer",
			"xyy - Composer",
			"Anthony Hampton - Composer",
			"greggreg - Composer",
			"weednose - Composer",
			"vladosikos17 - Composer, Cutscene Sound Design",
			"Z Sharp Studios - Cutscene Sound Design",
			
			"",
			
			"benniebo0 - Artist, Cutscene Animator",
			"CheatEXP - Artist",
			"BatteryBozo - Artist",
			"jayythunder - Animator",
			"graceusama - Animator",
			"l_higeki - Artist, Cutscene Animator",
			"laekogah - Cutscene Animator",
			"DaH.buzz - Cutscene Animator",
			"Eyeben - Cutscene Animator",
			"junejunejune - Freeplay Artist",
			"micro - Artist",
			"popular_deman - Options menu artist",
			"kiwiquest - Designed Girlfriend",
			"Chilltin - Designed Boyfriend",
			
			"",
			
			"Saintza4 - 3D Artist",
			"HaDerpo - 3D Aritst, Animator",
			"salesman - 3D Artist, Animator",
			"Gorbini - 3D Artist, Animator",
			"N_CGI - 3D Animator",
			"mistermulch - 3d Artist",
			
			"",
			
			"Mystman12 - Voice Actor, Creator of Baldi's Basics",
			
			"",
			
			"And the rest of The Teachers Lounge!",
		];
		
		credits = new FlxTypedContainer();
		add(credits);
		
		for (idx => credit in creditsList)
		{
			makeCredit(FlxG.height * 0.35 + (idx * 36), credit);
		}
		
		var baldiLogo = new FlxSprite(0, 50, Paths.image('menus/logo'));
		add(baldiLogo);
		baldiLogo.scale.set(0.5, 0.5);
		baldiLogo.updateHitbox();
		baldiLogo.screenCenter(X);
		baldiLogo.antialiasing = true;
		
		loungeIcon = new FlxSprite(0, credits.members.last().y + 72).setFrames(Paths.getSparrowAtlas('menus/title/theLounge'));
		loungeIcon.animation.addByPrefix('i', 'i', 24, false);
		loungeIcon.animation.play('i');
		loungeIcon.animation.finish();
		loungeIcon.scale.scale(2);
		loungeIcon.updateHitbox();
		loungeIcon.shader = new PolyTextShader();
		loungeIcon.antialiasing = false;
		add(loungeIcon);
		
		loungeIcon.screenCenter(X);
		
		var keyString = [for (i in ClientPrefs.keyBinds.get('accept').concat(ClientPrefs.keyBinds.get('back'))) InputFormatter.getKeyName(i)].join(', ');
		
		makeCredit(loungeIcon.y + loungeIcon.height + 32, 'Press $keyString to exit');
	}
	
	function makeCredit(y:Float = 0, text:String)
	{
		final textObject = new BaldiText(0, y, FlxG.width, text, 32);
		textObject.usesShader = false;
		textObject.alignment = CENTER;
		credits.add(textObject);
	}
	
	var intendedScroll:Float = 0;
	
	var delay:Float = 2;
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (canInteract)
		{
			if (controls.ACCEPT || controls.BACK)
			{
				canInteract = false;
				
				FlxG.sound.play(Paths.sound('cancelMenu'));
				
				FlxG.switchState(() -> new MainMenuState());
			}
			
			if (controls.UI_UP || controls.UI_DOWN || FlxG.mouse.wheel != 0)
			{
				delay = 1;
				
				var rate = 120 * elapsed;
				if (FlxG.keys.pressed.SHIFT) rate *= 2;
				
				if (controls.UI_UP)
				{
					intendedScroll -= rate;
				}
				else if (controls.UI_DOWN)
				{
					intendedScroll += rate;
				}
				
				intendedScroll += -FlxG.mouse.wheel * 30;
			}
			
			if (delay <= 0)
			{
				intendedScroll += 30 * elapsed;
			}
			else
			{
				delay -= elapsed;
			}
		}
		
		final maxBounds = (((credits.length + 1) * 34) + (FlxG.height / 2) - (34 * 2));
		
		intendedScroll = FlxMath.bound(intendedScroll, 0, maxBounds);
		
		FlxG.camera.scroll.y = MathUtil.decayLerp(FlxG.camera.scroll.y, intendedScroll, 12, elapsed);
	}
}
