package mobile.backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import openfl.utils.Assets;

#if mobile
import flixel.input.touch.FlxTouch;
#end

/*
 * Originally made by: Dechis
 * 
 * Improved by: StarNova (Cream.BR)
 */
 
class PauseButton
{
    private static var instance:PauseButton;
    private var pauseButton:FlxSprite;
    private var isVisible:Bool = false;
    private var onClickCallback:Void->Void;
    
    public static function getInstance():PauseButton 
    {
        if (instance == null) 
            instance = new PauseButton();
        return instance;
    }
    
    private function new() {}
    
    public static function showPauseButtonOnCamera(camera:FlxCamera, ?parent:FlxGroup, ?onClick:Void->Void):Void 
    {
        #if mobile
        var manager = getInstance();
        
        manager.pauseButton = new FlxSprite().loadGraphic(Assets.getPath("assets/mobile/pauseButton.png"));
        manager.pauseButton.antialiasing = true;
        manager.pauseButton.scrollFactor.set();
        manager.pauseButton.alpha = 0.7;
        manager.pauseButton.scale.set(0.8, 0.8);
        manager.pauseButton.updateHitbox();
        
        manager.pauseButton.x = FlxG.width - manager.pauseButton.width - 25;
        manager.pauseButton.y = 25;
        
        manager.pauseButton.cameras = [camera];
        manager.onClickCallback = onClick;
        
        if (parent != null) 
            parent.add(manager.pauseButton);
        else 
            FlxG.state.add(manager.pauseButton);
        
        manager.isVisible = true;
        #else
        trace("Button for mobile only.");
        #end
    }
    
    public static function hidePauseButton():Void 
    {
        #if mobile
        var manager = getInstance();
        if (manager.pauseButton != null && manager.isVisible) 
        {
            manager.pauseButton.destroy();
            manager.pauseButton = null;
            manager.onClickCallback = null;
            manager.isVisible = false;
        }
        #end
    }

    public static function update():Void 
    {
        #if mobile
        var manager = getInstance();
        
        if (manager.pauseButton == null || !manager.isVisible) return;

        for (touch in FlxG.touches.list)
        {
            if (touch.justPressed)
            {
                if (touch.overlaps(manager.pauseButton, manager.pauseButton.cameras[0]))
                {
                    if (manager.onClickCallback != null) 
                        manager.onClickCallback();
                }
            }
        }
        #end
    }

    public static function updatePosition():Void 
    {
        #if mobile
        var manager = getInstance();
        if (manager.pauseButton != null && manager.isVisible) 
        {
            manager.pauseButton.x = FlxG.width - manager.pauseButton.width - 25;
            manager.pauseButton.y = 25;
        }
        #end
    }
}