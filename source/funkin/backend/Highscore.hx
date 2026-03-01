package funkin.backend;

enum abstract FcRank(Int) to Int
{
	var SDCB = 0;
	var FC = 1;
	var PFC = 2;
	
	public function toInt():Int
	{
		return cast this;
	}
	
	public function toString():String
	{
		return switch (this)
		{
			case FC: 'fc';
			case PFC: 'pfc';
			default: 'sdcb';
		}
	}
}

class Highscore
{
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map();
	public static var songRating:Map<String, Float> = new Map();
	public static var songFcs:Map<String, FcRank> = new Map();
	
	public static function resetSong(song:String, diff:Int = 0):Void
	{
		final daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setRating(daSong, 0);
		setRank(daSong, SDCB);
	}
	
	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		final daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
	}
	
	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1, rank:FcRank = SDCB):Void
	{
		final daSong:String = formatSong(song, diff);
		
		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
			{
				setScore(daSong, score);
				if (rating >= 0) setRating(daSong, rating);
				if (rank.toInt() > SDCB.toInt()) setRank(daSong, rank);
			}
			
			#if debug
			if (rank.toInt() > SDCB.toInt()) setRank(daSong, rank);
			#end
		}
		else
		{
			setScore(daSong, score);
			if (rating >= 0) setRating(daSong, rating);
			if (rank.toInt() > SDCB.toInt()) setRank(daSong, rank);
		}
	}
	
	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
	{
		final daWeek:String = formatSong(week, diff);
		
		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score) setWeekScore(daWeek, score);
		}
		else setWeekScore(daWeek, score);
	}
	
	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}
	
	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}
	
	static function setRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRating.set(song, rating);
		FlxG.save.data.songRating = songRating;
		FlxG.save.flush();
	}
	
	static function setRank(song:String, rank:FcRank):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songFcs.set(song, rank);
		FlxG.save.data.songFcs = songFcs;
		FlxG.save.flush();
	}
	
	public static function formatSong(song:String, diff:Int):String
	{
		return Paths.formatToSongPath(song) + Difficulty.getFilePath(diff);
	}
	
	public static function getScore(song:String, diff:Int):Int
	{
		final daSong:String = formatSong(song, diff);
		if (!songScores.exists(daSong)) setScore(daSong, 0);
		
		return songScores.get(daSong);
	}
	
	public static function getRating(song:String, diff:Int):Float
	{
		final daSong:String = formatSong(song, diff);
		if (!songRating.exists(daSong)) setRating(daSong, 0);
		
		return songRating.get(daSong);
	}
	
	public static function getRank(song:String, diff:Int):FcRank
	{
		final daSong:String = formatSong(song, diff);
		if (!songFcs.exists(daSong)) setRank(daSong, SDCB);
		
		return songFcs.get(daSong);
	}
	
	public static function getWeekScore(week:String, diff:Int):Int
	{
		final daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek)) setWeekScore(daWeek, 0);
		
		return weekScores.get(daWeek);
	}
	
	public static function calculateFC(misses:Int = 0, rating:Float = 0):FcRank
	{
		if (misses == 0)
		{
			if (rating == 1.0) return PFC;
			return FC;
		}
		return SDCB;
	}
	
	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
		{
			weekScores = FlxG.save.data.weekScores;
		}
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songRating != null)
		{
			songRating = FlxG.save.data.songRating;
		}
		
		if (FlxG.save.data.songFcs != null)
		{
			songFcs = FlxG.save.data.songFcs;
		}
	}
}
