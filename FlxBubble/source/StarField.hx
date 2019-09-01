package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class StarField extends FlxSpriteGroup {
	public static inline var STARS:Int = 15;
	public static inline var SPEED_X:Float = 0.3;
	public static inline var SPEED_Y:Float = 0.2;

	public function new(X:Float = 0, Y:Float = 0, Facing:Int = FlxObject.NONE) {
		super(X, Y, STARS);
		facing = Facing;

		for (_ in 0...STARS)
			add(createStar());
	}

	public function updateY() {
		for (star in group) {
			star.y -= SPEED_Y;
			if (star.y < 0) {
				star.y += FlxG.height;
			}
		}
	}

	public function updateXY() {
		for (star in group) {
			if (facing == FlxObject.LEFT) {
				star.x -= SPEED_X;
				if (star.x < 0) {
					star.x += FlxG.width;
				}
			} else if (facing == FlxObject.RIGHT) {
				star.x += SPEED_X;
				if (star.x > FlxG.width) {
					star.x -= FlxG.width;
				}
			}
			star.y -= SPEED_Y;
			if (star.y < 0) {
				star.y += FlxG.height;
			}
		}
	}

	private function createStar():FlxSprite {
		var x = Std.random(FlxG.width);
		var y = Std.random(FlxG.height);
		var frameRate = 3 + Std.random(3);

		var star = new FlxSprite(x, y);
		star.loadGraphic(AssetPaths.star__png, true, 8, 8);
		star.animation.add("blink", [0, 1, 2, 3], frameRate);
		star.animation.play("blink", false, false, -1);

		return star;
	}
}
