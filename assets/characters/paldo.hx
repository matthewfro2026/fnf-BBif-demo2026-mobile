package assets.characters;

import funkin.states.PlayState;
import funkin.backend.Paths;

var suffix:String = '';
var isTransitioning:Bool = false;

// there was a reason for this behavior but we will never know wwwwww
var oldUpdate = PlayState.instance.updateIconAnimations;

function onCreatePost()
{
	iconP2.frames = Paths.getSparrowAtlas('icons/paldo');
	iconP2.animation.addByPrefix('idle', 'idle0', 24, false);
	iconP2.animation.addByPrefix('lose', 'lose0', 24, false);
	
	iconP2.animation.play('idle');
	iconP2.updateHitbox();
	
	iconP2.iconOffsets[0] = (iconP2.width - 150) / 2;
	iconP2.iconOffsets[1] = (iconP2.height - 150) / 2;
	
	PlayState.instance.updateIconAnimations = updateIconAnims;
}

function updateIconAnims()
{
	iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0; // If health is under 20%, change player icon to frame 1 (losing icon), otherwise, frame 0 (normal)
	
	if (!isTransitioning) iconP2.animation.play((healthBar.percent > 80 ? 'lose' : 'idle') + suffix);
}

function onEvent(ev, v1, v2, time)
{
	if (ev == '' && v1 == 'waterfall')
	{
		// suffix = '-blue';
		PlayState.instance.updateIconAnimations = oldUpdate;
		
		iconP2.changeIcon('paldo-blue');
		
		PlayState.instance.updateIconAnimations();
		
		// updateIconAnims();
	}
}
