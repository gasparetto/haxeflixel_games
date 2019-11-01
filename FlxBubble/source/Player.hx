package;

import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import flixel.addons.util.FlxFSM;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class Player extends FlxSprite {
	public static inline var SPEED:Float = 55.0;
	public static inline var DRAG:Float = 20.0;
	public static inline var GRAVITY:Float = 50.0;
	public static inline var JUMP_SPEED_X:Float = 30.0;
	public static inline var JUMP_SPEED_Y:Float = 140.0;
	public static inline var JUMP_TIME:Float = 0.6;
	public static inline var SHOT_TIME:Float = 0.5;

	public var fsm:FlxFSM<Player>;
	public var shooting = false;
	public var bubbleStartSignal = new FlxTypedSignal<Bubble->Void>();
	public var bubbleEndSignal = new FlxTypedSignal<Void->Void>();
	public var respawnSignal = new FlxTypedSignal<Void->Void>();

	public function new(?X:Float = 0, ?Y:Float = 0) {
		super(X, Y);

		// FlxG.debugger.visible = true;
		// FlxG.watch.add(this, "velocity");
		// FlxG.watch.add(this, "touching");

		loadGraphic(AssetPaths.player__png, true, 16, 16);
		offset.set(0, -1);

		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

		animation.add("wait", [0, 1], 3);
		animation.add("run", [0, 2, 3, 1], 6);
		animation.add("jump", [4, 5], 6);
		animation.add("fall", [6, 7], 6);
		animation.add("shot", [8]);
		animation.add("die", [12, 13, 14, 15, 12, 13, 14, 15, 10, 10, 11, 11], 6, false);

		fsm = new FlxFSM<Player>(this);
		fsm.transitions.add(PlayerStateFall, PlayerStateIdle, PlayerStateConditions.grounded);
		fsm.transitions.add(PlayerStateRun, PlayerStateIdle, PlayerStateConditions.idle);
		fsm.transitions.add(PlayerStateRun, PlayerStateFall, PlayerStateConditions.fall);
		fsm.transitions.add(PlayerStateRun, PlayerStateJump, PlayerStateConditions.jump);
		fsm.transitions.add(PlayerStateIdle, PlayerStateRun, PlayerStateConditions.run);
		fsm.transitions.add(PlayerStateIdle, PlayerStateJump, PlayerStateConditions.jump);
		fsm.transitions.start(PlayerStateFall);
	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.justPressed.S && !shooting) {
			shot();
		}
		fsm.update(elapsed);
		super.update(elapsed);
	}

	override function kill() {
		alive = false;
		exists = true;
		fsm.state = new PlayerStateDie();
	}

	public function shot() {
		shooting = true;
		bubbleStartSignal.dispatch(new Bubble(x, y, facing));
		new FlxTimer().start(SHOT_TIME, function (timer:FlxTimer) {
			shooting = false;
			bubbleEndSignal.dispatch();
		});
	}
}

class PlayerStateConditions {
	public static function idle(owner:Player):Bool {
		return !FlxG.keys.pressed.LEFT && !FlxG.keys.pressed.RIGHT;
	}

	public static function fall(owner:Player):Bool {
		return !owner.isTouching(FlxObject.DOWN);
	}

	public static function grounded(owner:Player):Bool {
		return owner.isTouching(FlxObject.DOWN);
	}

	public static function run(owner:Player):Bool {
		return FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT;
	}

	public static function jump(owner:Player):Bool {
		return FlxG.keys.pressed.UP || FlxG.keys.pressed.A;
	}
}

class PlayerStateIdle extends FlxFSMState<Player> {
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void {
		owner.animation.play(owner.shooting ? "shot" : "wait");
		
		owner.velocity.x = 0;
		owner.velocity.y = Player.GRAVITY;
	}
}

class PlayerStateRun extends FlxFSMState<Player> {
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void {
		owner.animation.play(owner.shooting ? "shot" : "run");
		
		var _left:Bool = FlxG.keys.pressed.LEFT;
		var _right:Bool = FlxG.keys.pressed.RIGHT;
		if (_left || _right) {
			owner.facing = _right ? FlxObject.RIGHT : FlxObject.LEFT;
			owner.velocity.x = _right ? Player.SPEED : -Player.SPEED;
		} else {
			owner.velocity.x = 0;
		}
		owner.velocity.y = Player.GRAVITY;
	}
}

class PlayerStateFall extends FlxFSMState<Player> {
	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void {
		owner.animation.play(owner.shooting ? "shot" : "fall");
		
		var _left:Bool = FlxG.keys.pressed.LEFT;
		var _right:Bool = FlxG.keys.pressed.RIGHT;
		if (_left || _right) {
			owner.facing = _right ? FlxObject.RIGHT : FlxObject.LEFT;
			owner.velocity.x = _right ? Player.DRAG : -Player.DRAG;
		} else {
			owner.velocity.x = 0;
		}
		owner.velocity.y = Player.GRAVITY;
	}
}

class PlayerStateJump extends FlxFSMState<Player> {
	var tweenUp:FlxTween;
	var tweenDown:FlxTween;
	var facing:Int = FlxObject.NONE;

	override public function enter(owner:Player, fsm:FlxFSM<Player>):Void {
		owner.velocity.y = -Player.JUMP_SPEED_Y;
		tweenUp = FlxTween.tween(owner.velocity, {y: 0}, Player.JUMP_TIME);
		tweenDown = FlxTween.tween(owner.velocity, {y: Player.JUMP_SPEED_Y}, Player.JUMP_TIME, {
			onComplete: function(tween:FlxTween) {
				fsm.state = new PlayerStateIdle();
			}
		});
		tweenUp = tweenUp.then(tweenDown);

		var _left:Bool = FlxG.keys.pressed.LEFT;
		var _right:Bool = FlxG.keys.pressed.RIGHT;
		if (_left || _right) {
			facing = _right ? FlxObject.RIGHT : FlxObject.LEFT;
			owner.facing = facing;
		}
	}

	override public function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void {
		owner.animation.play(owner.shooting ? "shot" : (owner.velocity.y < 0 ? "jump" : "fall"));

		if (owner.isTouching(FlxObject.DOWN)) {
			// tweenUp.cancelChain(); //<= doesn't work
			tweenUp.cancel();
			tweenDown.cancel();
			fsm.state = new PlayerStateIdle();
		}

		if (facing != FlxObject.NONE) {
			owner.velocity.x = facing == FlxObject.RIGHT ? Player.JUMP_SPEED_X : -Player.JUMP_SPEED_X;
		} else {
			owner.velocity.x = 0;
		}
		
		var _left:Bool = FlxG.keys.pressed.LEFT;
		var _right:Bool = FlxG.keys.pressed.RIGHT;
		if (_left || _right) {
			owner.facing = _right ? FlxObject.RIGHT : FlxObject.LEFT;
			owner.velocity.x += _right ? Player.DRAG : -Player.DRAG;
		}
	}
}

class PlayerStateDie extends FlxFSMState<Player> {
	override public function enter(owner:Player, fsm:FlxFSM<Player>):Void {
		owner.velocity.x = 0;
		owner.velocity.y = 0;
		owner.animation.play("die");
		owner.animation.finishCallback = function(name:String) {
			fsm.state = new PlayerStateIdle();
			owner.respawnSignal.dispatch();
		};
	}
	override function exit(owner:Player) {
		owner.animation.finishCallback = null;
	}
}
