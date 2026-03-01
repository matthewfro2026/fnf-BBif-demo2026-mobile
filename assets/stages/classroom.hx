import funkin.states.PlayState;

import flixel.FlxG;

import funkin.backend.Paths;
import funkin.scripting.HScript;

import flixel.sound.FlxSound;

import funkin.utils.RandomUtil;

import sys.FileSystem;

using StringTools;

function onCreate()
{
	var using2ndBg = songName != 'basics';
	
	var bgGraphic = using2ndBg ? Paths.image('stages/classroom/bg2') : Paths.image('stages/classroom/bg');
	
	bg = new FlxSprite(-900, -450, bgGraphic);
	addBehindGF(bg);
	
	var pickedBoard = '0';
	
	if (PlayState.isStoryMode)
	{
		//
		switch (PlayState.instance.displaySongName)
		{
			case 'basics':
				pickedBoard = '4';
			default:
				pickedBoard = '10';
		}
	}
	else
	{
		var chalkboards:Array<String> = FileSystem.readDirectory(Paths.getPath('images/stages/classroom/chalkboards'));
		
		pickedBoard = RandomUtil.getObject(chalkboards).split('.')[0];
	}
	
	chalkboard = new FlxSprite(-400, 203, Paths.image('stages/classroom/chalkboards/' + pickedBoard));
	addBehindGF(chalkboard);
	chalkboard.scale.set(0.75, 0.75);
	chalkboard.updateHitbox();
	
	var chairGraphic = using2ndBg ? Paths.image('stages/classroom/chairs2') : Paths.image('stages/classroom/chairs');
	
	var chairOffset = using2ndBg ? [1736, 881] : [1701, 883];
	
	chairs = new FlxSprite(-860 + chairOffset[0], -450 + chairOffset[1], chairGraphic);
	addBehindGF(chairs);
	
	fgTable = new FlxSprite(-1000 + 545, -500 + 1502, Paths.image('stages/classroom/table'));
	add(fgTable);
	fgTable.scrollFactor.set(1.3, 1.3);
	fgTable.updateHitbox();
	
	var noteBookGraphic = using2ndBg ? Paths.image('stages/classroom/red_notebook') : Paths.image('stages/classroom/blue_notebook');
	
	noteBook = new FlxSprite(250, 1000, noteBookGraphic);
	add(noteBook);
	noteBook.scrollFactor.set(1.3, 1.3);
	// noteBook.scale.set(3.5, 3.5);
	
	// FlxTween.tween(noteBook, {y: noteBook.y + 30}, 3, {ease: FlxEase.sineInOut, type: 4});
	
	variables.set('stage_bg', bg);
	variables.set('stage_chalkboard', chalkboard);
	variables.set('stage_chairs', chairs);
	variables.set('stage_fgTable', fgTable);
	variables.set('stage_noteBook', noteBook);
}

function onUpdatePost(e) {}
