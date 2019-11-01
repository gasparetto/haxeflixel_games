package;

import flixel.effects.FlxFlicker;
import flixel.addons.tile.FlxRayCastTilemap;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;

class PlayState extends FlxState {
	var tileLayersGroup:FlxGroup;
	var tileLayerWalls = new FlxRayCastTilemap();
	var tileLayerFloors = new FlxRayCastTilemap();
	var player:Player;
	var enemies = new FlxTypedGroup<Enemy>();
	var bubble:Bubble;
	var bubbles = new FlxTypedGroup<Bubble>();
	var levelText:FlxText;
	var livesText:FlxText;
	var score1Text:FlxText;
	var score2Text:FlxText;
	var level = 1;
	var lives = 2;
	var score1 = 0;
	var score2 = 0;
	var invincible = false;

	override public function create():Void {
		super.create();

		// FlxG.debugger.visible = true;

		tileLayersGroup = initTilemap();

		add(levelText = createText(119, 15, itos(level)));
		add(livesText = createText(7, 207, '$lives'));
		add(score1Text = createText(50, 6, itos(score1), FlxTextAlign.RIGHT));
		add(score2Text = createText(220, 6, itos(score2), FlxTextAlign.RIGHT));

		add(player = new Player(30, 180));
		player.bubbleStartSignal.add(function(bubble:Bubble) {
			this.bubble = bubble;
			add(bubble);
			bubbles.add(bubble);
		});
		player.bubbleEndSignal.add(function() {
			if (bubble != null) {
				bubble.floatToTop();
				bubble = null;
			}
		});
		player.respawnSignal.add(function() {
			lives--;
			if (lives >= 0) {
				livesText.text = '$lives';
				player.reset(30, 180);
				invincible = true;
				FlxFlicker.flicker(player, 4, 0.05, true, true, function(flicker:FlxFlicker) {
					invincible = false;
				});
			} else {
				FlxG.switchState(new GameOverState(score1, score2));
			}
		});

		enemies.add(new Enemy(tileLayerFloors, 120, -20));
		enemies.add(new Enemy(tileLayerFloors, 120, 0));
		enemies.add(new Enemy(tileLayerFloors, 120, 20));
		add(enemies);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FlxG.collide(tileLayersGroup, player);
		FlxG.collide(tileLayersGroup, enemies);
		FlxG.collide(tileLayerWalls, bubbles);
		if (!invincible)
			FlxG.overlap(player, enemies, function(ob1:FlxObject, ob2:FlxObject) {
				ob1.hurt(1.0);
			});
		if (bubble != null)
			FlxG.overlap(bubble, enemies, function(ob1:FlxObject, ob2:FlxObject) {
				if (bubble != null) {
					ob2.hurt(1.0);
					bubble.grabEnemy();
					bubble.floatToTop();
					bubble = null;
				}
			});
	}

	private function initTilemap():FlxGroup {
		var map = new TiledMap(AssetPaths.map__tmx);
		tileLayerWalls.loadMapFromArray(cast(map.getLayer("Tile Layer 1"), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tileset__png,
			map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		add(tileLayerWalls);
		tileLayerFloors.loadMapFromArray(cast(map.getLayer("Tile Layer 2"), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tileset__png,
			map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		add(tileLayerFloors);
		tileLayerFloors.setTileProperties(1, FlxObject.UP);
		var group = new FlxGroup();
		group.add(tileLayerWalls);
		group.add(tileLayerFloors);
		return group;
	}

	private function createText(X:Float = 0, Y:Float = 0, ?Text:String, ?TextAlign:FlxTextAlign = FlxTextAlign.LEFT):FlxText {
		var text = new FlxText(X, Y, 0, Text, 8);
		text.setFormat(AssetPaths.PressStart2P__ttf, 8, 0xfffcc2fc, TextAlign);
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
