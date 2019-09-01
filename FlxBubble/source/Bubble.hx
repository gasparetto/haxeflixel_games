package;

import flixel.util.FlxTimer;
import flixel.addons.util.FlxFSM;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class Bubble extends FlxSprite {
	public static inline var SHOT_SPEED:Float = 100.0;
	public static inline var FLOAT_SPEED:Float = 10.0;
	public static inline var DURATION:Float = 0.5;
	public static inline var TOP:Int = 40;

	public var fsm:FlxFSM<Bubble>;
	public var age:Float = 0.0;

	public function new(?X:Float = 0, ?Y:Float = 0, ?Facing:Int = FlxObject.RIGHT) {
		super(X, Y);
		facing = Facing;

		loadGraphic(AssetPaths.bubble__png, true, 16, 16);

		animation.add("shot", [0, 1, 2, 3], 8, false);
		animation.add("red", [4], 1);
		animation.add("flash", [3, 4], 10);
		animation.add("pon", [5, 6], 4, false);

		fsm = new FlxFSM<Bubble>(this);
		// fsm.transitions.add(Fall, Idle, Conditions.touching);
		fsm.transitions.start(BubbleShotFSMState);
	}

	override public function update(elapsed:Float):Void {
		age += elapsed;
		if (age > 25) {
			animation.play("pon");
			fsm.state = new BubblePonFSMState();
		} else if (age > 20) {
			animation.play("flash");
		} else if (age > 15) {
			animation.play("red");
		}
		fsm.update(elapsed);
		super.update(elapsed);
	}
}

class BubbleShotFSMState extends FlxFSMState<Bubble> {
	var age:Float = 0.0;

	override public function update(elapsed:Float, owner:Bubble, fsm:FlxFSM<Bubble>):Void {
		owner.animation.play("shot");

		owner.velocity.x = owner.facing == FlxObject.RIGHT ? Bubble.SHOT_SPEED : -Bubble.SHOT_SPEED;
		owner.velocity.y = 0;

		age += elapsed;
		if (age > 0.5) {
			owner.fsm.state = new BubbleFloatFSMState();
		}
	}
}

class BubbleFloatFSMState extends FlxFSMState<Bubble> {
	override public function update(elapsed:Float, owner:Bubble, fsm:FlxFSM<Bubble>):Void {
		owner.velocity.x = 0;
		owner.velocity.y = 0;
		if (owner.y > Bubble.TOP) {
			owner.velocity.y = -Bubble.FLOAT_SPEED; // move to top
		} else {
			owner.fsm.state = new BubbleGroupFSMState();
		}
	}
}

class BubbleGroupFSMState extends FlxFSMState<Bubble> {
	private var timer:FlxTimer;

	override function enter(owner:Bubble, fsm:FlxFSM<Bubble>) {
		timer = new FlxTimer().start(0.25, function (timer:FlxTimer) {}, 0);
	}

	override function exit(owner:Bubble) {
		timer.cancel();
	}

	override public function update(elapsed:Float, owner:Bubble, fsm:FlxFSM<Bubble>):Void {
		owner.velocity.x = 0;
		owner.velocity.y = 0;
		var d = (FlxG.width / 2) - owner.x; // distance to center
  		if (d < -4.0 || d > 4.0) {
    		owner.velocity.x = owner.velocity.x + (d > 0 ? 3 : -3); // move to center
  		}
		if (owner.y > Bubble.TOP) {
			owner.velocity.y = -Bubble.FLOAT_SPEED; // move to top
		}
	}
}

class BubblePonFSMState extends FlxFSMState<Bubble> {
	var age:Float = 0.0;

	override public function update(elapsed:Float, owner:Bubble, fsm:FlxFSM<Bubble>):Void {
		owner.velocity.x = 0;
		owner.velocity.y = 0;

		age += elapsed;
		if (age > 0.5) {
			owner.kill();
		}
	}
}
