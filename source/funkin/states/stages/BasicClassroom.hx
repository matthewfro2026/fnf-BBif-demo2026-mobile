package funkin.states.stages;

class BasicClassroom extends BaseStage
{
	override function create()
	{
		var bg = new FlxSprite(-900, -450, Paths.image('stages/classroom/bg'));
		insert(0, bg);
		
		var chalkboard = new FlxSprite(-400, 203, Paths.image('stages/classroom/chalkboards/5'));
		insert(1, chalkboard);
		chalkboard.scale.set(0.75, 0.75);
		chalkboard.updateHitbox();
		
		var chairs = new FlxSprite(-860 + 1701, -450 + 883, Paths.image('stages/classroom/chairs'));
		insert(2, chairs);
		
		var fgTable = new FlxSprite(-1000 + 545, -500 + 1502, Paths.image('stages/classroom/table'));
		add(fgTable);
		fgTable.scrollFactor.set(1.3, 1.3);
		fgTable.updateHitbox();
		
		var noteBook = new FlxSprite(250, 1000, Paths.image('stages/classroom/blue_notebook'));
		add(noteBook);
		noteBook.scrollFactor.set(1.3, 1.3);
	}
}
