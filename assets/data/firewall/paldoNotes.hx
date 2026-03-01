package assets.data.firewall;

import funkin.Constants;
import funkin.backend.ClientPrefs;
import funkin.objects.StrumNote;
import funkin.objects.Note;

using StringTools;

function onCountdownStarted()
{
	var idx = 0;
	for (strum in opponentStrums.members)
	{
		switch (idx)
		{
			case 0:
				strum.addOffset('confirm', 55 + -10 + -10, 70 + 30);
			case 1:
				strum.addOffset('confirm', 55 + -10, 70 + 30);
			case 2:
				strum.addOffset('confirm', 55 + -10, 70 + 30);
			case 3:
				strum.addOffset('confirm', 55 + -10 + 10, 70 + 30);
		}
		
		strum.addOffset('static', 55, 70);
		
		strum.texture = 'noteSkins/paldo';
		
		idx += 1;
	}
}

function onCreatePost()
{
	for (note in unspawnNotes)
	{
		if (!note.mustPress)
		{
			note.texture = 'noteSkins/paldo';
			
			if (!note.isSustainNote)
			{
				note.centerOffsets();
				note.offset.x += 45;
				
				if (ClientPrefs.data.downScroll)
				{
					//
					note.flipY = true;
					
					note.offset.y += 120;
					
					if (note.noteData == 1 || note.noteData == 2)
					{
						var idx = note.noteData == 1 ? 2 : 1;
						
						note.animation.addByPrefix(Note.colArray[idx] + 'Scroll', Note.colNoteArray[idx] + '0');
						note.animation.play(Note.colArray[idx % Note.colArray.length] + 'Scroll');
						
						if (note.noteData == 1) note.offset.x += 25;
						if (note.noteData == 2) note.offset.x += -25;
					}
				}
			}
			
			if (note.animation.curAnim != null && note.animation.curAnim.name.endsWith('end'))
			{
				note.animation.addByPrefix(Note.colArray[note.noteData] + 'holdend', Note.colNoteArray[note.noteData] + ' hold piece', 24, true);
				note.animation.play(Note.colArray[note] + 'holdend');
			}
			
			note.shader = getVar('firewall_colourSwap').shader;
		}
	}
}

var shaderRef = null;

function onUpdatePost(e)
{
	if (shaderRef == null && hasVar('firewall_colourSwap'))
	{
		shaderRef = getVar('firewall_colourSwap').shader;
	}
	
	if (startedCountdown)
	{
		var strum1 = opponentStrums.members[0];
		var strum2 = opponentStrums.members[1];
		var strum3 = opponentStrums.members[2];
		var strum4 = opponentStrums.members[3];
		
		if (strum1.shader != null && strum1.animation.curAnim.name == 'static')
		{
			strum1.shader = null;
		}
		
		if (strum2.shader != null && strum2.animation.curAnim.name == 'static')
		{
			strum2.shader = null;
		}
		
		if (strum3.shader != null && strum3.animation.curAnim.name == 'static')
		{
			strum3.shader = null;
		}
		
		if (strum4.shader != null && strum4.animation.curAnim.name == 'static')
		{
			strum4.shader = null;
		}
	}
}

function opponentNoteHit(note)
{
	if (shaderRef != null)
	{
		opponentStrums.members[note.noteData].shader = shaderRef;
	}
	
	return Constants.SCRIPT_CONTINUE;
}
