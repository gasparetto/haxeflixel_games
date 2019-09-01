package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.FlxState;

class GameOverState extends FlxState {
	var score1:Int;
	var score2:Int;

	public function new(?score1:Int=0, ?score2:Int=0) {
		super();
		this.score1 = score1;
		this.score2 = score2;
	}

	override public function create():Void {
		super.create();

		add(createText(64, 16, itos(score1)));
		
		add(createText(224, 16, itos(score2)));
		
		var gameover = createText(0, 96, "GAME OVER", FlxTextAlign.RIGHT);
		gameover.screenCenter(FlxAxes.X);
		add(gameover);
		FlxFlicker.flicker(gameover, 0, 0.2);
		
		var pushstart = createText(0, 160, "PUSH START");
		pushstart.screenCenter(FlxAxes.X);
		add(pushstart);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.keys.anyJustPressed([FlxKey.ENTER])) {
			FlxG.switchState(new StoryState());
		}
	}

	private function createText(X:Float = 0, Y:Float = 0, ?Text:String, ?TextAlign:FlxTextAlign = FlxTextAlign.LEFT):FlxText {
		var text = new FlxText(X, Y, 0, Text, 8);
		text.setFormat(AssetPaths.PressStart2P__ttf, 8, FlxColor.WHITE, TextAlign);
		return text;
	}

	private function itos(i:Int):String {
		if (i < 0)
			return "0";
		if (i < 10)
			return "0" + Std.string(i);
		return Std.string(i);
	}
}
