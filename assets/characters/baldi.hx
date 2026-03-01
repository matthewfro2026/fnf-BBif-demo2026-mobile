package assets.characters;

var lastAnim = '';

function changeAnims(anim:String)
{
	lastAnim = anim;
	
	for (char in PlayState.instance.dadGroup.members)
	{
		if (char.curCharacter == 'baldi')
		{
			char.animationSuffix = anim;
		}
	}
	
	if (PlayState.instance.dad.curCharacter == 'baldi')
	{
		PlayState.instance.dad.animationSuffix = anim;
		PlayState.instance.dad.dance();
		switchIcon();
	}
}

function onEvent(ev, v1, v2)
{
	if (ev == 'Change Character' && v2 == 'baldi' && v1.toLowerCase() == 'dad')
	{
		PlayState.instance.dad.animationSuffix = lastAnim;
		switchIcon();
	}
}

function switchIcon()
{
	switch (PlayState.instance.dad.animationSuffix)
	{
		case '-mad':
			PlayState.instance.iconP2.changeIcon('baldimad');
		case '-annoyed':
			PlayState.instance.iconP2.changeIcon('baldimid');
		default:
			PlayState.instance.iconP2.changeIcon('baldi');
	}
}

function onCreate()
{
	setVar('setBaldiAnim', changeAnims);
}
