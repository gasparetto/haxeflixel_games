package;

import flixel.util.FlxColor;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class StoryState extends FlxState {
	private var player:FlxSprite;

	override public function create():Void {
		super.create();

		FlxG.camera.setSize(FlxG.width, FlxG.height * 2);

		add(createText(0, 16, "NOW IT IS THE BEGINNING OF"));
		add(createText(0, 30, "A FANTASTIC STORY! LET US"));
		add(createText(0, 44, "MAKE A JOURNEY TO"));
		add(createText(0, 58, "THE CAVE OF MONSTERS!"));
		add(createText(0, 82, "GOOD LUCK!"));

		createMap();

		player = new FlxSprite(0, 0);
		player.loadGraphic(AssetPaths.storyplayer__png, true, 32, 32);
		player.animation.add("anim", [0, 1], 3);
		player.animation.play("anim");
		add(player);

		FlxTween.circularMotion(player, 60, 90, 30, 0, false, 3)
			.then(FlxTween.circularMotion(player, 60, 90, 30, 0, false, 3))
			.then(FlxTween.circularMotion(player, 60, 90, 30, 0, false, 3, true, {onComplete: scroll}));
	}

	private function scroll(tween:FlxTween) {
		FlxTween.tween(FlxG.camera, {y: FlxG.height}, 3);
		FlxTween.tween(player, {x: 20, y: 40 + FlxG.height}, 2).then(FlxTween.tween(player, {x: 20, y: 180 + FlxG.height}, 1.5, {onComplete: next}));
	}

	private function next(tween:FlxTween) {
		FlxG.switchState(new PlayState());
	}

	private function createMap() {
		var map = new TiledMap(AssetPaths.map__tmx);
		var tileLayer1 = new FlxTilemap();
		tileLayer1.loadMapFromArray(cast(map.getLayer("Tile Layer 1"), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tileset__png,
			map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		add(tileLayer1);
		var tileLayer2 = new FlxTilemap();
		tileLayer2.loadMapFromArray(cast(map.getLayer("Tile Layer 2"), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tileset__png,
			map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		add(tileLayer2);
		tileLayer1.y = FlxG.height;
		tileLayer2.y = FlxG.height;

		var levelText = new FlxText(119, FlxG.height + 15);
		levelText.setFormat(AssetPaths.PressStart2P__ttf, 8, 0xfffcc2fc);
		levelText.text = "01";
		add(levelText);
	}

	private function createText(X:Float = 0, Y:Float = 0, ?Text:String, ?TextAlign:FlxTextAlign = FlxTextAlign.LEFT):FlxText {
		var text = new FlxText(X, Y, 0, Text, 8);
		text.setFormat(AssetPaths.PressStart2P__ttf, 8, FlxColor.WHITE, TextAlign);
		text.screenCenter(FlxAxes.X);
		return text;
	}
}
