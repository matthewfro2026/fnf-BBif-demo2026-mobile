package assets.data.expulsion;

import flixel.FlxSprite;

import funkin.backend.Paths;
import funkin.objects.Note;

var evs = [];
var evIndex = -1;

function onEventPushed(ev, v1, v2, time)
{
	if (ev == 'switchNoteskin')
	{
		var antialiasing = FlxSprite.defaultAntialiasing;
		var scaleMult = 1;
		Paths.image(v1);
		if (v1 == 'noteSkins/notes-3d')
		{
			scaleMult = 0.98;
			antialiasing = false;
		}
		evs.push(
			{
				time: time,
				skin: v1,
				scaleMult: scaleMult,
				antialiasing: antialiasing
			});
	}
}

function onEvent(ev, v1, v2, time)
{
	//
	if (ev == 'switchNoteskin')
	{
		evIndex += 1;
		
		for (note in strumLineNotes.members)
		{
			note.texture = evs[evIndex].skin;
			note.antialiasing = evs[evIndex].antialiasing;
		}
		
		for (note in notes)
		{
			if (evIndex < 0) return Constants.SCRIPT_CONTINUE;
			
			applyEvToNote(note);
		}
	}
}

function onSpawnNote(note:Note)
{
	if (evIndex == -1) return Constants.SCRIPT_CONTINUE;
	
	applyEvToNote(note);
}

function applyEvToNote(note:Note)
{
	if (note.strumTime >= evs[evIndex].time)
	{
		note.reloadNote(evs[evIndex].skin);
		
		note.antialiasing = evs[evIndex].antialiasing;
		
		if (note.isSustainNote)
		{
			note.correctionOffset = note.parent.height / 2;
			
			if (note.prevNote.isSustainNote)
			{
				note.prevNote.scale.set(0.7, 1);
				
				note.prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				note.prevNote.scale.y *= songSpeed;
				note.prevNote.scale.y *= Note.SUSTAIN_SIZE / note.prevNote.frameHeight;
				note.prevNote.scale.y /= playbackRate;
				
				note.prevNote.scale.y *= evs[evIndex].scaleMult;
				
				note.prevNote.updateHitbox();
			}
			
			if (ClientPrefs.data.downScroll) note.correctionOffset = 0;
		}
	}
}
