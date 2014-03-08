package ;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.tile.FlxTilemap;

/**
 * ...
 * @author 
 */
class World extends FlxGroup
{
	public var dude:Creature;
	public var controls:Controls;
	
	public var dungeon:DungeonData;
	
	public var group_terrain:FlxGroup;
	public var group_creatures:FlxGroup;
	public var group_bullets:FlxGroup;
	
	public static var instance:World;
	
	public var MAX_WORLD_WIDTH:Int = 1000;
	public var MAX_WORLD_HEIGHT:Int = 1000;
	public static inline var TILE_SIZE:Int = 32;
	
	public static inline var ROOM_SIZE:Int = 11;
	public static inline var ROOM_GUTTER:Int = 5;
	
	
	public function new() 
	{
		super();
		
		dungeon = new DungeonData();
		while (dungeon.error) {
			dungeon = new DungeonData();
		}
		
		group_terrain = new FlxGroup();
		group_creatures = new FlxGroup();
		group_bullets = new FlxGroup();
		
		makeTerrain();
		
		add(group_terrain);
		add(group_creatures);
		add(group_bullets);
		
		dude = new Creature("dude");
		group_creatures.add(dude);
		
		var creature = new Creature("eye");
		group_creatures.add(creature);
		
		dude.x = TILE_SIZE * MAX_WORLD_WIDTH / 2;
		dude.y = TILE_SIZE * MAX_WORLD_HEIGHT / 2;
		
		creature.x = dude.x + 100;
		creature.y = dude.y + 100;
		
		controls = new Controls();
		
		instance = this;
		
		FlxG.camera.follow(dude, FlxCamera.STYLE_TOPDOWN);
	}
	
	public override function update():Void {
		checkControls();
		super.update();
		collisions();
	}
	
	private function collisions():Void {
		FlxG.collide(group_terrain, group_creatures);
		FlxG.collide(group_terrain, group_bullets, onCollideTerrainBullet);
		FlxG.overlap(group_creatures, group_bullets, onOverlapCreatureBullet);
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
		var t:FlxTilemap = new FlxTilemap();
		
		MAX_WORLD_WIDTH = (ROOM_SIZE * dungeon.width) + (ROOM_GUTTER * (dungeon.width+1));
		MAX_WORLD_HEIGHT = (ROOM_SIZE * dungeon.height) + (ROOM_GUTTER * (dungeon.height+1));
		
		t.widthInTiles = MAX_WORLD_WIDTH;
		t.heightInTiles = MAX_WORLD_HEIGHT;
		
		var arr:Array<Int> = [];
		var length:Int = MAX_WORLD_HEIGHT * MAX_WORLD_WIDTH;
		
		for (i in 0...length) {
			arr.push(0);
		}
		
		var drawx:Int = 0;
		var drawy:Int = 0;
		var value:Int = 0;
		var destx:Int = 0;
		var desty:Int = 0;
		var dx:Int = 0;
		var dy:Int = 0;
		
		for (xx in 0...dungeon.width) {
			for (yy in 0...dungeon.height) {
				
				drawx = ROOM_GUTTER + (ROOM_SIZE * xx) + (ROOM_GUTTER * xx);
				drawy = ROOM_GUTTER + (ROOM_SIZE * yy) + (ROOM_GUTTER * yy);
				
				for (jx in 0...ROOM_SIZE) {
					for (jy in 0...ROOM_SIZE) {
						value = 1;
						if ((jx == 0 || jx == ROOM_SIZE-1) || jy == 0 || jy == ROOM_SIZE-1) {
							value = 2;
						}
						dx = drawx + jx;
						dy = drawy + jy;
						arr[(dy * MAX_WORLD_WIDTH) + dx] = value;
					}
				}
			}
		}
		
		for (xx in 0...dungeon.width) {
			for (yy in 0...dungeon.height) {
				var room:RoomData = dungeon.grid[xx][yy];
				
				if (room.isConnected())
				{
					drawx = ROOM_GUTTER + (ROOM_SIZE * room.x) + (ROOM_GUTTER * room.x);
					drawy = ROOM_GUTTER + (ROOM_SIZE * room.y) + (ROOM_GUTTER * room.y);
					
					var half:Int = Std.int(ROOM_SIZE / 2);
					
					drawx += half;
					drawy += half;
					
					var ip:IntPt;
					for (ip in room.connections) {
						
						destx = ROOM_GUTTER + (ROOM_SIZE * ip.x) + (ROOM_GUTTER * ip.x);
						desty = ROOM_GUTTER + (ROOM_SIZE * ip.y) + (ROOM_GUTTER * ip.y);
						
						destx += half;
						desty += half;
						
						if (destx == drawx) {
							for (i in drawy...desty + 1) {
								dy = i;
								dx = drawx;
								arr[(dy * MAX_WORLD_WIDTH) + dx] = 1;
								//add borders
								writeToArr(arr, (dy * MAX_WORLD_WIDTH) + dx - 1, 2, 0);
								writeToArr(arr, (dy * MAX_WORLD_WIDTH) + dx + 1, 2, 0);
							}
						}
						else if (desty == drawy) {
							for (i in drawx...destx + 1) {
								dx = i;
								dy = drawy;
								arr[(dy * MAX_WORLD_WIDTH) + dx] = 1;
								
								writeToArr(arr, ((dy-1) * MAX_WORLD_WIDTH) + dx, 2, 0);
								writeToArr(arr, ((dy+1) * MAX_WORLD_WIDTH) + dx, 2, 0);
							}
						}
					}
					
					
				}
				
				
				
			}
		}
		
		t.solid = true;
		t.loadMap(arr, "assets/images/tileset.png", TILE_SIZE, TILE_SIZE);
		for (i in 0...5) {
			if(i == 1 || i == 0){
				t.setTileProperties(i, FlxObject.NONE);
			}else {
				t.setTileProperties(i, FlxObject.ANY);
			}
		}
		
		group_terrain.add(t);
		FlxG.worldBounds.set(0, 0, t.width, t.height);
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
		}
		return null;
	}
}