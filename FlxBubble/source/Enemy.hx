package;

import flixel.FlxG;
import flixel.addons.tile.FlxRayCastTilemap;
import flixel.addons.util.FlxFSM;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.FlxSprite;

class Enemy extends FlxSprite {
	public static inline var SPEED:Float = 55.0;
	public static inline var GRAVITY:Float = 50.0;
	public static inline var JUMP_SPEED_X:Float = 50.0;
	public static inline var JUMP_SPEED_Y:Float = 50.0;
	public static inline var JUMP_SPEED1_Y:Float = 140.0; // jump up
	public static inline var JUMP_TIME:Float = 0.6;

	public var fsm:FlxFSM<Enemy>;
	
	public var holefr = false;
	public var holeup = false;

	var floors:FlxRayCastTilemap;

	public function new(tileLayerFloors:FlxRayCastTilemap, ?X:Float = 0, ?Y:Float = 0) {
		super(X, Y);

		floors = tileLayerFloors;

		FlxG.watch.add(this, "x");
		FlxG.watch.add(this, "y");
		FlxG.watch.add(this, "holefr");
		FlxG.watch.add(this, "holeup");

		loadGraphic(AssetPaths.enemy01__png, true, 16, 16);
		offset = offset.set(0, -1);

		facing = FlxObject.LEFT;
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);

		animation.add("run", [0, 1], 6);
		animation.play("run");

		fsm = new FlxFSM<Enemy>(this);
		fsm.transitions.add(EnemyStateFall, EnemyStateRun, EnemyStateConditions.grounded);
		fsm.transitions.add(EnemyStateRun, EnemyStateFall, EnemyStateConditions.fall);
		fsm.transitions.start(EnemyStateFall);
		// FlxG.watch.add(fsm, "age");
	}

	override public function update(elapsed:Float):Void {
		fsm.update(elapsed);
		super.update(elapsed);
	}

	public function turnAround() {
		facing = facing == FlxObject.LEFT ? FlxObject.RIGHT : FlxObject.LEFT;
	}

	public function isInFrontOfAHole():Bool {
		if ((facing == FlxObject.LEFT && x < 24)
				|| (facing == FlxObject.RIGHT && x > 216)) // left and right borders + 8 pixels
			return false;
		var dx = x + width * 0.5; // sprite x center
		dx += facing == FlxObject.LEFT ? -16 : 16; // 8 half sprite + 8 space
		var dy = y + height; // sprite y bottom
		dy += 4; // tile is h 8, so 4 is 0.5 tiles down
		var tile1 = floors.tileAt(dx, dy);
		dx += facing == FlxObject.LEFT ? -8 : 8; // add another tile
		var tile2 = floors.tileAt(dx, dy);
		return tile1 == 0 && tile2 == 0;
	}

	public function hasAHoleAbove():Bool {
		var dx = x; // sprite x left
		var dy = y; // sprite y top
		dy += -20; // tile is h 8, so -20 is 2.5 tiles up
		var tile1 = floors.tileAt(dx, dy);
		dx += width; // sprite x right
		var tile2 = floors.tileAt(dx, dy);
		return tile1 == 0 && tile2 == 0;
	}
}

class EnemyStateConditions {
	public static function fall(owner:Enemy):Bool {
		return !owner.isTouching(FlxObject.DOWN);
	}

	public static function grounded(owner:Enemy):Bool {
		return owner.isTouching(FlxObject.DOWN);
	}
}

class EnemyStateRun extends FlxFSMState<Enemy> {
	var maxAge:Float;

	override function enter(owner:Enemy, fsm:FlxFSM<Enemy>) {
		maxAge = FlxG.random.float(2, 4);
	}

	override function update(elapsed:Float, owner:Enemy, fsm:FlxFSM<Enemy>):Void {
		aiUpdate(elapsed, owner, fsm);
		// playerUpdate(elapsed, owner, fsm);
	}

	private function aiUpdate(elapsed:Float, owner:Enemy, fsm:FlxFSM<Enemy>):Void {
		var xgrid8 = (Std.int(owner.x) % 8) != 0; // true only at every 8 x pixels
		if (xgrid8 && owner.isInFrontOfAHole()
				&& FlxG.random.bool(5) // 5% chance to jump
		) {
			fsm.state = new EnemyStateJump(owner.facing);
			return;
		}

		if (owner.isTouching(FlxObject.LEFT | FlxObject.RIGHT)) {
			owner.turnAround();
		}

		owner.velocity.x = owner.facing == FlxObject.LEFT ? -Enemy.SPEED : Enemy.SPEED;
		owner.velocity.y = Enemy.GRAVITY;

		maxAge -= elapsed;
		if (maxAge < 0) {
			// run time is expired, look around and then jump up
			var xgrid16 = (Std.int(owner.x) % 16) != 0; // true only at every 16 x pixels
			if (xgrid16 && !owner.hasAHoleAbove()) {
				fsm.state = new EnemyStateLookAround();
				return;
			}
		}
	}

	/*
	private function playerUpdate(elapsed:Float, owner:Enemy, fsm:FlxFSM<Enemy>):Void {
		owner.holefr = owner.isInFrontOfAHole();
		owner.holeup = owner.hasAHoleAbove();

		var _left:Bool = FlxG.keys.pressed.LEFT;
		var _right:Bool = FlxG.keys.pressed.RIGHT;
		if (_left || _right) {
			owner.facing = _right ? FlxObject.RIGHT : FlxObject.LEFT;
			owner.velocity.x = _right ? Player.SPEED : -Player.SPEED;
		} else {
			owner.velocity.x = 0;
		}
		owner.velocity.y = Enemy.GRAVITY;
		var _jump:Bool = FlxG.keys.pressed.UP || FlxG.keys.pressed.A;
		if (_jump) {
			fsm.state = new EnemyStateJump(FlxObject.NONE);
		}
	}
	*/
}

class EnemyStateFall extends FlxFSMState<Enemy> {
	override function update(elapsed:Float, owner:Enemy, fsm:FlxFSM<Enemy>):Void {
		owner.velocity.x = 0;
		owner.velocity.y = Enemy.GRAVITY;
	}
}

class EnemyStateLookAround extends FlxFSMState<Enemy> {
	var timer:FlxTimer;

	override function enter(owner:Enemy, fsm:FlxFSM<Enemy>) {
		owner.velocity.x = 0;
		owner.velocity.y = 0;

		timer = new FlxTimer().start(0.6, function(timer:FlxTimer) {
			owner.turnAround();
			if (timer.loopsLeft == 0)
				fsm.state = new EnemyStateJump(FlxObject.NONE);
				// runOrJump(owner, fsm);
		}, 2);
	}

	override function exit(owner:Enemy) {
		if (timer != null)
			timer.cancel();
	}
}

class EnemyStateJump extends FlxFSMState<Enemy> {
	var tweenUp:FlxTween;
	var tweenDown:FlxTween;
	var facing:Int = FlxObject.NONE;

	public function new(facing:Int) {
		super();
		this.facing = facing;
	}

	override public function enter(owner:Enemy, fsm:FlxFSM<Enemy>):Void {
		// enemy jump diagonal != vertical
		var jump_speed_y = facing != FlxObject.NONE ? Enemy.JUMP_SPEED_Y : Enemy.JUMP_SPEED1_Y;

		owner.velocity.y = -jump_speed_y;
		tweenUp = FlxTween.tween(owner.velocity, {y: 0}, Enemy.JUMP_TIME);
		tweenDown = FlxTween.tween(owner.velocity, {y: jump_speed_y}, Enemy.JUMP_TIME, {
			onComplete: function(tween:FlxTween) {
				fsm.state = new EnemyStateFall();
			}
		});
		tweenUp = tweenUp.then(tweenDown);
	}

	override public function update(elapsed:Float, owner:Enemy, fsm:FlxFSM<Enemy>):Void {
		if (owner.isTouching(FlxObject.DOWN)) {
			// tweenUp.cancelChain(); <= doesn't work
			tweenUp.cancel();
			tweenDown.cancel();
			if (facing == FlxObject.NONE && !owner.hasAHoleAbove()) {
				runOrJump(owner, fsm);
			} else {
				fsm.state = new EnemyStateRun();
			}
			return;
		}
		if (facing != FlxObject.NONE) {
			owner.velocity.x = facing == FlxObject.RIGHT ? Enemy.JUMP_SPEED_X : -Enemy.JUMP_SPEED_X;
		} else {
			owner.velocity.x = 0;
		}
	}

	function runOrJump(owner:Enemy, fsm:FlxFSM<Enemy>) {
		if (FlxG.random.bool() && !owner.hasAHoleAbove())
			fsm.state = new EnemyStateLookAround();
		else
			fsm.state = new EnemyStateRun();
	}
}
