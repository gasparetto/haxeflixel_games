package;

import flixel.input.keyboard.FlxKey;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.addons.util.FlxFSM;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class IntroState extends FlxState {
	private var fsm:FlxFSM<IntroState>;

	public var stars:StarField;
	public var starsLeft:StarField;
	public var starsRight:StarField;

	override public function create():Void {
		super.create();

		stars = new StarField(0, 0);
		add(stars);
		starsLeft = new StarField(0, 0, FlxObject.LEFT);
		add(starsLeft);
		starsRight = new StarField(0, 0, FlxObject.RIGHT);
		add(starsRight);

		fsm = new FlxFSM<IntroState>(this, new IntroFSMState1());
	}

	override function update(elapsed:Float) {
		fsm.update(elapsed);
		super.update(elapsed);
	}
}

class IntroFSMState1 extends FlxFSMState<IntroState> {
	override public function enter(owner:IntroState, fsm:FlxFSM<IntroState>):Void {
		var logo = new FlxSprite(AssetPaths.logo__png);
		logo.screenCenter(FlxAxes.X);
		logo.y = -FlxG.width;
		owner.add(logo);

		FlxTween.tween(logo, {y: 20}, 4, {
			onComplete: function(tween:FlxTween) {
				fsm.state = new IntroFSMState2();
			}
		});
	}

	override function update(elapsed:Float, owner:IntroState, fsm:FlxFSM<IntroState>) {
		owner.stars.updateY();
		owner.starsLeft.updateY();
		owner.starsRight.updateY();
		super.update(elapsed, owner, fsm);
	}
}

class IntroFSMState2 extends FlxFSMState<IntroState> {
	override public function enter(owner:IntroState, fsm:FlxFSM<IntroState>):Void {
		var taitoLogo = new FlxSprite(AssetPaths.taito__png);
		taitoLogo.screenCenter(FlxAxes.X);
		taitoLogo.y = 135;
		owner.add(taitoLogo);

		owner.add(createText(0, 170, "© 1990 TAITO CORPORATION"));
		owner.add(createText(0, 190, "LICENSED BY NINTENDO"));
	}

	override function update(elapsed:Float, owner:IntroState, fsm:FlxFSM<IntroState>) {
		owner.stars.updateXY();
		owner.starsLeft.updateXY();
		owner.starsRight.updateXY();

		if (FlxG.keys.anyJustPressed([FlxKey.ENTER])) {
			FlxG.switchState(new StoryState());
		}

		super.update(elapsed, owner, fsm);
	}

	private function createText(X:Float = 0, Y:Float = 0, ?Text:String):FlxText {
		var text = new FlxText(X, Y, 0, Text, 8);
		text.setFormat(AssetPaths.PressStart2P__ttf, 8, 0xffffffff);
		text.screenCenter(FlxAxes.X);
		return text;
	}
}
