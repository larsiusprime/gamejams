package ;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

/**
 * ...
 * @author 
 */
class World extends FlxGroup
{
	public var dude:Creature;
	public var controls:Controls;
	
	public var dungeon:DungeonData;
	
	public var tilemap:FlxTilemap;
	
	public var group_terrain:FlxGroup;
	public var group_creatures:FlxGroup;
	public var group_bullets:FlxGroup;
	
	public static var instance:World;
	
	public var MAX_WORLD_WIDTH:Int = 1000;
	public var MAX_WORLD_HEIGHT:Int = 1000;
	
	public static inline var TILE_SIZE:Int = 32;
	
	public static inline var ROOM_GUTTER:Int = 5;
	
	public static inline var TILE_EMPTY:Int = 0;
	public static inline var TILE_FLOOR:Int = 1;
	public static inline var TILE_WALL:Int = 2;
	public static inline var TILE_STAIRS_DOWN:Int = 3;
	public static inline var TILE_STAIRS_UP:Int = 4;
	public static inline var TILE_DOOR:Int = 5;
	
	public var progress:Progress;
	
	public function new() 
	{
		super();
		
		progress = new Progress();
		
		instance = this;
		
		dungeon = new DungeonData(progress.level);
		while (dungeon.error) {
			dungeon = new DungeonData(progress.level);
		}
		
		group_terrain = new FlxGroup();
		group_creatures = new FlxGroup();
		group_bullets = new FlxGroup();
		
		add(group_terrain);
		add(group_creatures);
		add(group_bullets);
		
		dude = new Creature("dude");
		
		makeTerrain();
		
		group_creatures.add(dude);
		
		var arr:Array<FlxPoint> = tilemap.getTileCoords(TILE_STAIRS_UP);
		
		//Start on the stairs!
		if (arr != null && arr.length >= 1)
		{
			dude.x = arr[0].x + (-dude.width)  / 2;
			dude.y = arr[0].y + (-dude.height) / 2;
		}
		
		controls = new Controls();
		
		
		FlxG.camera.follow(dude, FlxCamera.STYLE_TOPDOWN);
	}
	
	public override function update():Void {
		checkControls();
		super.update();
		collisions();
	}
	
	private function collisions():Void {
		FlxG.collide(group_terrain, group_creatures);
		FlxG.collide(group_creatures, group_creatures);
		FlxG.collide(group_terrain, group_bullets, onCollideTerrainBullet);
		FlxG.overlap(group_creatures, group_bullets, onOverlapCreatureBullet);
	}
	
	private function onCollideDoorCreature(t:FlxObject, c:FlxObject):Void {
		var tile:FlxTile = cast t;
		var creature:Creature = cast c;
		if (creature == dude) {
			tile.tilemap.setTileByIndex(tile.mapIndex, TILE_FLOOR, true);
		}
	}
	
	private function onOverlapCreatureBullet(c:Creature, b:Bullet):Void {
		if(c != b.owner){
			c.takeHit(b);
			b.kill();
		}
	}
	
	private function onCollideTerrainBullet(t:FlxTilemap, b:Bullet):Void {
		b.kill();
	}
	
	/*************PRIVATE*************/
	
	private function makeTerrain():Void 
	{
		tilemap = new FlxTilemap();
		
		var ROOM_MAXW:Int = Std.int(dungeon.roomWidthRange.x);
		var ROOM_MAXH:Int = Std.int(dungeon.roomHeightRange.y);
		
		MAX_WORLD_WIDTH = (ROOM_MAXW * dungeon.width) + (ROOM_GUTTER * (dungeon.width+1));
		MAX_WORLD_HEIGHT = (ROOM_MAXH * dungeon.height) + (ROOM_GUTTER * (dungeon.height+1));
		
		tilemap.widthInTiles = MAX_WORLD_WIDTH;
		tilemap.heightInTiles = MAX_WORLD_HEIGHT;
		
		var arr:Array<Int> = [];
		var length:Int = MAX_WORLD_HEIGHT * MAX_WORLD_WIDTH;
		
		for (i in 0...length) {
			arr.push(0);
		}
		
		var drawx:Int = 0;
		var drawy:Int = 0;
		var value:Int = TILE_EMPTY;
		var destx:Int = 0;
		var desty:Int = 0;
		var dx:Int = 0;
		var dy:Int = 0;
		
		//Draw the rooms!
		
		for (xx in 0...dungeon.width) {
			for (yy in 0...dungeon.height) {
				
				var room_w:Int = dungeon.grid[xx][yy].width;
				var room_h:Int = dungeon.grid[xx][yy].height;
				
				var room_off_x:Int = Std.int((ROOM_MAXW - room_w)/2);			//if max width is 10, but this room is 8, diff is 2, offset is 1
				var room_off_y:Int = Std.int((ROOM_MAXH - room_h)/2);			//if max width is 10, but this room is 7, diff is 3, offset is 1
				
				drawx = ROOM_GUTTER + (ROOM_MAXW * xx) + (ROOM_GUTTER * xx) + room_off_x;
				drawy = ROOM_GUTTER + (ROOM_MAXH * yy) + (ROOM_GUTTER * yy) + room_off_y;
				
				//Spawn monsters!
				var spawn:SpawnData;
				for (spawn in dungeon.spawns) {
					if (FlxRandom.float() < spawn.chance) {
						spawnCreatures(spawn, drawx+1, drawy+1, drawx+room_w-1, drawy+room_h-1);
					}
				}
				
				for (jx in 0...room_w) {
					for (jy in 0...room_h) {
						value = TILE_FLOOR;
						if ((jx == 0 || jx == room_w-1) || jy == 0 || jy == room_h-1) {
							value = TILE_WALL;
						}
						dx = drawx + jx;
						dy = drawy + jy;
						arr[(dy * MAX_WORLD_WIDTH) + dx] = value;
					}
				}
			}
		}
		
		//Draw the corridors
		
		for (xx in 0...dungeon.width) {
			for (yy in 0...dungeon.height) {
				var room:RoomData = dungeon.grid[xx][yy];
				
				if (room.isConnected())
				{
					drawx = ROOM_GUTTER + (ROOM_MAXW * room.x) + (ROOM_GUTTER * room.x);
					drawy = ROOM_GUTTER + (ROOM_MAXH * room.y) + (ROOM_GUTTER * room.y);
					
					drawx += Std.int(ROOM_MAXW/2);
					drawy += Std.int(ROOM_MAXH/2);
					
					var dx:Int = drawx;
					var dy:Int = drawy;
					
					if (room.type == RoomData.ROOM_EXIT) 
					{
						trace("Room Exit = (" + room.x + "," + room.y + ")");
						writeToArr(arr, (dy * MAX_WORLD_WIDTH) + dx, TILE_STAIRS_DOWN, TILE_FLOOR);
					}
					else if (room.type == RoomData.ROOM_START) 
					{
						trace("Room Start = (" + room.x + "," + room.y + ")");
						writeToArr(arr, (dy * MAX_WORLD_WIDTH) + dx, TILE_STAIRS_UP, TILE_FLOOR);
					}
					
					var ip:IntPt;
					for (ip in room.connections) {
						
						destx = ROOM_GUTTER + (ROOM_MAXW * ip.x) + (ROOM_GUTTER * ip.x);
						desty = ROOM_GUTTER + (ROOM_MAXH * ip.y) + (ROOM_GUTTER * ip.y);
						
						destx += Std.int(ROOM_MAXW/2);
						desty += Std.int(ROOM_MAXH/2);
						
						if (destx == drawx) {
							for (i in drawy...desty + 1) {
								dy = i;
								dx = drawx;
								
								var index:Int = (dy * MAX_WORLD_WIDTH) + dx;
								
								if (arr[index] == TILE_WALL) {
									arr[index] = TILE_DOOR;
								}else if(arr[index] != TILE_STAIRS_UP && arr[index] != TILE_STAIRS_DOWN){
									arr[index] = TILE_FLOOR;
								}
								
								writeToArr(arr, (dy * MAX_WORLD_WIDTH) + dx - 1, TILE_WALL, 0);
								writeToArr(arr, (dy * MAX_WORLD_WIDTH) + dx + 1, TILE_WALL, 0);
							}
						}
						else if (desty == drawy) {
							for (i in drawx...destx + 1) {
								dx = i;
								dy = drawy;
								
								var index:Int = (dy * MAX_WORLD_WIDTH) + dx;
								
								if (arr[index] == TILE_WALL) {
									arr[index] = TILE_DOOR;
								}else if(arr[index] != TILE_STAIRS_UP && arr[index] != TILE_STAIRS_DOWN){
									arr[index] = TILE_FLOOR;
								}
								
								writeToArr(arr, ((dy-1) * MAX_WORLD_WIDTH) + dx, TILE_WALL, 0);
								writeToArr(arr, ((dy+1) * MAX_WORLD_WIDTH) + dx, TILE_WALL, 0);
							}
						}
					}
				}
			}
		}
		
		tilemap.solid = true;
		tilemap.loadMap(arr, "assets/images/tileset.png", TILE_SIZE, TILE_SIZE);
		for (i in 0...10) {
			if(i == TILE_EMPTY || i == TILE_FLOOR || i == TILE_STAIRS_UP || i == TILE_STAIRS_DOWN){
				tilemap.setTileProperties(i, FlxObject.NONE);
			}else if (i == TILE_DOOR) {
				tilemap.setTileProperties(i, FlxObject.ANY, onCollideDoorCreature, Creature);
			}
			else {
				tilemap.setTileProperties(i, FlxObject.ANY);
			}
		}
		
		group_terrain.add(tilemap);
		FlxG.worldBounds.set(0, 0, tilemap.width, tilemap.height);
	}
	
	private function writeToArr(arr:Array<Int>, i:Int, Value:Int, ValueCheck:Int = -1, MatchTrue:Bool=true):Void {
		if (ValueCheck == -1) {
			arr[i] = Value;
		}else {
			if ((arr[i] == ValueCheck) == MatchTrue) {
				arr[i] = Value;
			}
		}
	}
	
	private function spawnCreatures(spawn:SpawnData, ulx:Int, uly:Int, lrx:Int, lry:Int):Void {
		var count:Int = Std.int(FlxRandom.floatRanged(spawn.countRange.x, spawn.countRange.y));
		trace("Spawning " + count + "x of creature type\"" + spawn.name + "\"");
		
		var xx:Int = Std.int((ulx + lrx) / 2);
		var yy:Int = Std.int((lrx + lry) / 2);
		var existLocs:Array<String> = [xx+","+yy];		//no spawning in middle square
		
		for (i in 0...count) {
			var failsafe:Int = 0;
			while (existLocs.indexOf(xx + "," + yy) != -1 && failsafe < 99) {
				xx = FlxRandom.intRanged(ulx, lrx);
				yy = FlxRandom.intRanged(uly, lry);
				failsafe++;
			}
			if (failsafe < 99) {
				existLocs.push(xx + "," + yy);
				var c:Creature = new Creature(spawn.name);
				c.x = xx * TILE_SIZE;
				c.y = yy * TILE_SIZE;
				group_creatures.add(c);
				trace("spawned 1 @ (" + c.x + "," + c.y + ")");
			}
		}
	}
	
	private function checkControls():Void {
		if (FlxG.keys.checkStatus(controls.RESET, FlxKey.PRESSED)) {
			FlxG.switchState(new PlayState());
		}
		
		var dx:Float = 0;
		var dy:Float = 0;
		
		if (FlxG.keys.checkStatus(controls.LEFT, FlxKey.PRESSED)) {
			dx = -1;
		}else if (FlxG.keys.checkStatus(controls.RIGHT, FlxKey.PRESSED)) {
			dx = 1;
		}
		if (FlxG.keys.checkStatus(controls.UP, FlxKey.PRESSED)) {
			dy = -1;
		}else if(FlxG.keys.checkStatus(controls.DOWN, FlxKey.PRESSED)){
			dy = 1;
		}
		
		var sx:Float = 0;
		var sy:Float = 0;
		
		if (FlxG.keys.checkStatus(controls.SHOOT_LEFT, FlxKey.PRESSED)) {
			sx = -1;
		}else if (FlxG.keys.checkStatus(controls.SHOOT_RIGHT, FlxKey.PRESSED)) {
			sx = 1;
		}
		if (FlxG.keys.checkStatus(controls.SHOOT_UP, FlxKey.PRESSED)) {
			sy = -1;
		}else if(FlxG.keys.checkStatus(controls.SHOOT_DOWN, FlxKey.PRESSED)){
			sy = 1;
		}
		
		if (dx != 0 && dy != 0) {	//diagonal movement
			dx /= 1.414;
			dy /= 1.414;
		}
		
		if (sx != 0 && sy != 0 ) {	//diagonal shooting
			sx /= 1.414;
			sy /= 1.414;
		}
		
		dude.doMove(dx, dy);
		
		if(sx != 0 || sy != 0){
			dude.doShoot(sx, sy);
		}
	}
	
	public static function event(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic> = null):Void {
		
	}
	
	public static function request(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>=null):Dynamic {
		switch(name) 
		{
			case "bullet":
				var b:FlxSprite = cast instance.group_bullets.getFirstDead();
				if (b != null)
				{
					b.reset(0, 0);
				}
				else 
				{
					b = new Bullet();
					instance.group_bullets.add(b);
				}
				return b;
			case "dude":
				return instance.dude;
		}
		return null;
	}
}