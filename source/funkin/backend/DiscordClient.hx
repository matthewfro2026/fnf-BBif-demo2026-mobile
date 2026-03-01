package funkin.backend;

import Sys.sleep;

import lime.app.Application;

#if DISCORD_ALLOWED
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;

class DiscordClient
{
	public static var clientUsername:String = '';
	public static var isInitialized:Bool = false;
	@:unreflective
	private static final _defaultID:String = "1475048247687909486";
	
	public static var clientID(default, set):String = _defaultID;
	private static var presence:DiscordRichPresence = #if (hxdiscord_rpc < "1.3.0") DiscordRichPresence.create() #else new DiscordRichPresence() #end;
	
	public static function check()
	{
		if (ClientPrefs.data.discordRPC) initialize();
		else if (isInitialized) shutdown();
	}
	
	public static function prepare()
	{
		if (!isInitialized && ClientPrefs.data.discordRPC) initialize();
		
		Application.current.window.onClose.add(function() {
			if (isInitialized) shutdown();
		});
	}
	
	public static function shutdown()
	{
		Discord.Shutdown();
		isInitialized = false;
	}
	
	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		var requestPtr:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;
		
		if (Std.parseInt(cast(requestPtr.discriminator, String)) != 0) // New Discord IDs/Discriminator system
			trace('(Discord) Connected to User (${cast (requestPtr.username, String)}#${cast (requestPtr.discriminator, String)})');
		else // Old discriminators
			trace('(Discord) Connected to User (${cast (requestPtr.username, String)})');
			
		clientUsername = cast(requestPtr.username, String);
		
		changePresence();
	}
	
	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Error ($errorCode: ${cast (message, String)})');
	}
	
	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Disconnected ($errorCode: ${cast (message, String)})');
	}
	
	public static function initialize()
	{
		var discordHandlers:DiscordEventHandlers = #if (hxdiscord_rpc < "1.3.0") DiscordEventHandlers.create() #else new DiscordEventHandlers() #end;
		discordHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		discordHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		discordHandlers.errored = cpp.Function.fromStaticFunction(onError);
		
		Discord.Initialize(clientID, cpp.RawPointer.addressOf(discordHandlers), #if (hxdiscord_rpc < "1.3.0") 1 #else false #end, null);
		
		if (!isInitialized)
		{
			trace("Discord Client initialized");
			
			var button = #if (hxdiscord_rpc < "1.3.0") DiscordButton.create() #else new DiscordButton() #end;
			button.label = 'Check out the mod!';
			button.url = 'https://www.the-teachers-lounge.org/downloads/26demo.html';
			presence.buttons[0] = button;
		}
		
		sys.thread.Thread.create(() -> {
			var localID:String = clientID;
			while (localID == clientID)
			{
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();
				
				// Wait 2 seconds until the next loop...
				Sys.sleep(2);
			}
		});
		isInitialized = true;
	}
	
	public static function changePresence(details:String = 'In the Menus', ?state:String, ?smallImageKey:String, ?largeImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		var startTimestamp:Float = 0;
		if (hasStartTimestamp) startTimestamp = Date.now().getTime();
		if (endTimestamp > 0) endTimestamp = startTimestamp + endTimestamp;
		
		presence.details = details;
		presence.state = state;
		presence.largeImageKey = largeImageKey ?? 'icon';
		presence.largeImageText = "Baldi's Basics in Funkin': 2026 Demo";
		presence.smallImageKey = smallImageKey;
		// Obtained times are in milliseconds so they are divided so Discord can use it
		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);
		updatePresence();
		
		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
	
	public static function updatePresence() Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
	
	public static function resetClientID() clientID = _defaultID;
	
	private static function set_clientID(newID:String)
	{
		var change:Bool = (clientID != newID);
		clientID = newID;
		
		if (change && isInitialized)
		{
			shutdown();
			initialize();
			updatePresence();
		}
		return newID;
	}
}
#else
class DiscordClient
{
	public static var clientUsername:String = '';
	public static var isInitialized:Bool = false;
	@:unreflective
	private static final _defaultID:String = "1475048247687909486";
	
	public static var clientID:String = _defaultID;
	
	public static function check() {}
	
	public static function prepare() {}
	
	public static function shutdown()
	{
		isInitialized = false;
	}
	
	private static function onReady(request):Void {}
	
	public static function initialize() {}
	
	public static function changePresence(details:String = 'In the Menus', ?state:String, ?smallImageKey:String, ?largeImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {}
	
	public static function updatePresence() {}
	
	public static function resetClientID() clientID = _defaultID;
}
#end
