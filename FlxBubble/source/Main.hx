package;

import flixel.FlxState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	var gameWidth:Int = 256; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
    var gameHeight:Int = 224; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
    // var initialState:Class<FlxState> = IntroState; // The FlxState the game starts with.
    var initialState:Class<FlxState> = PlayState; // The FlxState the game starts with.
    var zoom:Float = -1.0; // If -1, zoom is automatically calculated to fit the window dimensions.
    var updateFramerate:Int = 60; // How many frames per second the game should run at.
    var drawFramerate:Int = 60; // How many frames per second the game should run at.
    var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
    var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public function new()
	{
		super();
        //FlxG.mouse.visible = false;
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, updateFramerate, drawFramerate, skipSplash, startFullscreen));
	}
}
