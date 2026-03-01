package funkin;

class Constants
{
	/**
	 * Hardcoded list of built in note types.
	 */
	public static final CHART_NOTETYPES:Array<String> = [
		'',
		'Alt Animation',
		'Hey!',
		'Hurt Note',
		'GF Sing',
		'BF Sing',
		'Both Sing',
		'No Animation',
		'Invisible Note',
		"Auto Note" // 'BaldiWindow-Sing'
	];
	
	/**
	 * Hardcoded list of built in events.
	 */
	public static final CHART_EVENTS:Array<Array<String>> = [
		['', "Nothing. Yep, that's right."],
		['Set Focus', "Value1: character (dad,boyfriend,gf)\nleave empty to reset"],
		['Set Camera Speed', "Value1: speed\nleave empty to reset"],
		['switchNoteskin', 'val1: Noteskin name'],
		['spawnCredits', ''],
		["Subtitles", "val 1 split: [subtitle, time, color], leave val2 empty to not scream, put something in for the opposite"],
		['Hey!', "Plays the \"Hey!\" animation from Bopeebo,\nValue 1: BF = Only Boyfriend, GF = Only Girlfriend,\nSomething else = Both.\nValue 2: Custom animation duration,\nleave it blank for 0.6s"],
		['Set GF Speed', "Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"],
		['Philly Glow', "Exclusive to Week 3\nValue 1: 0/1/2 = OFF/ON/Reset Gradient\n \nNo, i won't add it to other weeks."],
		['Kill Henchmen', "For Mom's songs, don't use this please, i love them :("],
		['Add Camera Zoom', "Used on MILF on that one \"hard\" part\nValue 1: Camera zoom add (Default: 0.015)\nValue 2: UI zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."],
		['BG Freaks Expression', "Should be used only in \"school\" Stage!"],
		['Trigger BG Ghouls', "Should be used only in \"schoolEvil\" Stage!"],
		['Play Animation', "Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"],
		['Camera Follow Pos', "Value 1: X\nValue 2: Y\n\nThe camera won't change the follow point\nafter using this, for getting it back\nto normal, leave both values blank."],
		['Alt Idle Animation', "Sets a specified suffix after the idle animation name.\nYou can use this to trigger 'idle-alt' if you set\nValue 2 to -alt\n\nValue 1: Character to set (Dad, BF or GF)\nValue 2: New suffix (Leave it blank to disable)"],
		['Screen Shake', "Value 1: Camera shake\nValue 2: HUD shake\n\nEvery value works as the following example: \"1, 0.05\".\nThe first number (1) is the duration.\nThe second number (0.05) is the intensity."],
		['Change Character', "Value 1: Character to change (Dad, BF, GF)\nValue 2: New character's name"],
		['Change Scroll Speed', "Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."],
		['Set Property', "Value 1: Variable name\nValue 2: New value"],
		['Play Sound', "Value 1: Sound file name\nValue 2: Volume (Default: 1), ranges from 0 to 1"],
		['Camera Flash', '', ''],
		['Camera Tween Zoom', 'Value 1: desired Zoom,Speed\nValue 2: tweenEase'],
		['setZoom', '', '']
	];
	
	/**
	 * The max volume music should be.
	 */
	public static final MAX_MUSIC_VOLUME:Float = 0.7;
	
	public static final PAUSE_MUSIC:String = 'Downtime';
	
	public static final MENU_MUSIC:String = 'Attendance';
	
	public static final SCRIPT_STOP:String = "##psychlua_FUNCTIONSTOP";
	public static final SCRIPT_CONTINUE:String = "##psychlua_FUNCTIONCONTINUE";
	public static final FUNCTION_HALT:String = "##psychlua_FUNCTIONSTOPALL";
}
