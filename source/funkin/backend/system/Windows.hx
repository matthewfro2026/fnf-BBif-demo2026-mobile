package funkin.backend.system;

#if windows
@:buildXml('
<target id="haxe">
	<lib name="wininet.lib" if="windows" />
	<lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
#include <windows.h>
#include <winuser.h>
#pragma comment(lib, "Shell32.lib")
extern "C" HRESULT WINAPI SetCurrentProcessExplicitAppUserModelID(PCWSTR AppID);
')
#end
class Windows
{
	/**
	 * DPI Scaling fix for windows
	 * 
	 * When Display scale is not set to 100%, The window is not scaled properly making it blurry
	 * 
	 * Thanks to YoshiCrafter29 & the CNE Crew for this fix
	 */
	public static function setDpiAware()
	{
		#if (windows && cpp)
		untyped __cpp__("SetProcessDPIAware();");
		#end
		
		final window = lime.app.Application.current.window;
		
		if (window == null) return;
		
		final dpiScale = (lime.system.System.getDisplay(0)?.dpi / 96) ?? 1.0;
		
		@:privateAccess
		{
			window.width = Std.int(Main.game.width * dpiScale);
			window.height = Std.int(Main.game.height * dpiScale);
		}
		
		window.x = Std.int((window.display.bounds.width - window.width) / 2);
		window.y = Std.int((window.display.bounds.height - window.height) / 2);
	}
}
