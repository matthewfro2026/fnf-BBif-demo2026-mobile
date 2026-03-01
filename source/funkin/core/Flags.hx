package funkin.core;

class Flags
{
	//
	public static var defines(get, never):Map<String, Dynamic>;
	
	static function get_defines():Map<String, Dynamic>
	{
		return _getDefines();
	}
	
	static macro function _getDefines()
	{
		return macro $v{haxe.macro.Context.getDefines()};
	}
}
