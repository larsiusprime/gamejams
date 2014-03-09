package ;
import flash.Lib;
import flixel.addons.ui.U;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import haxe.xml.Fast;

/**
 * ...
 * @author 
 */
class DungeonData
{
	public var width:Int = 3;
	public var height:Int = 3;
	
	public var roomWidthRange:FlxPoint;
	public var roomHeightRange:FlxPoint;
	
	public var grid:Array<Array<RoomData>> = null;
	
	public var error:Bool = false;
	
	public var level:Int = 0;
	
	public var spawns:Array<SpawnData> = null;
	
	public function new(Level:Int) 
	{
		level = Level;
		spawns = [];
		
		var xml:Fast = U.xml("dungeon", "xml", true, "assets/data/");
		if (xml != null) {
			for (lNode in xml.nodes.level) {
				var l:Int = U.xml_i(lNode.x, "value", 0);
				if (l == level) {
					if (lNode.hasNode.dungeon) {
						var widthString = U.xml_str(lNode.node.dungeon.x, "width", true);
						var heightString = U.xml_str(lNode.node.dungeon.x, "height", true);
						if(widthString != ""){
							var wArr:Array<String> = widthString.split("-");
							width = FlxRandom.intRanged(Std.parseInt(wArr[0]), Std.parseInt(wArr[1]));
						}
						if (heightString != "") {
							var hArr:Array<String> = heightString.split("-");
							height = FlxRandom.intRanged(Std.parseInt(hArr[0]), Std.parseInt(hArr[1]));
						}
						trace("Generating Dungeon @ Level " + level + ", size = (" + width + "," + height + ")");
					}
					if (lNode.hasNode.room) {
						var widthString = U.xml_str(lNode.node.room.x, "width", true);
						var heightString = U.xml_str(lNode.node.room.x, "height", true);
						if(widthString != ""){
							var wArr:Array<String> = widthString.split("-");
							roomWidthRange = new FlxPoint(Std.parseInt(wArr[0]), Std.parseInt(wArr[1]));
						}
						if (heightString != "") {
							var hArr:Array<String> = heightString.split("-");
							roomHeightRange = new FlxPoint(Std.parseInt(hArr[0]), Std.parseInt(hArr[1]));
						}
						trace("--> Room size variance = ( " + roomWidthRange + " , " + roomHeightRange + " )");
					}
					if (lNode.hasNode.spawn) {
						for (sNode in lNode.nodes.spawn) {
							spawns.push(new SpawnData(sNode));
						}
					}
				}
			}
		}
		
		generate();
	}

	
	public function generate():Void {
		grid = new Array<Array<RoomData>>();
		var i:Int = 0;
		for (w in 0...width) {
			grid[w] = new Array<RoomData>();
			for (h in 0...height) {
				grid[w].push(new RoomData(w,h,randRoomWidth(),randRoomHeight()));
				i++;
			}
		}
		
		var X:Int = FlxRandom.intRanged(0, width - 1);
		var Y:Int = FlxRandom.intRanged(0, height - 1);
		
		var currRoom:RoomData = grid[X][Y];
		currRoom.type = RoomData.ROOM_START;
		var result:RoomData;
		
		var failsafe:Int = 0;
		
		while (hasUnconnectedNeighbors(currRoom) && failsafe < 999)
		{
			result = connectToRandomNeighbor(currRoom,0,true);
			if (result != null) {
				currRoom = result;
			}
			failsafe++;
		}
		
		if (failsafe >= 999) {
			error = true;
			return;
		}
		failsafe = 0;
		
		while (!allRoomsConnected() && failsafe < 999) {
			currRoom = getRoom(false);						//get unconnected room
			connectToRandomNeighbor(currRoom, 1, true);		//try to connect it to an unconnected room
			failsafe++;
		}
		
		currRoom.type = RoomData.ROOM_EXIT;
		
		if (failsafe >= 999) {
			error = true;
			return;
		}
		failsafe = 0;
		
		//add extra random connections
		var rand_connections:Int = FlxRandom.intRanged(0, width);
		
		
		var i:Int = 0;
		while(i < rand_connections && failsafe < 999) {
			currRoom = getRandomRoom();
			if (connectToRandomNeighbor(currRoom, 0, true) != null)
			{
				i++;
			}
			failsafe++;
		}
		
		if (failsafe >= 999) {
			error = true;
			return;
		}
		failsafe = 0;
	}
	
	/**************PRIVATE***************/
		
	private function randRoomWidth():Int {
		return Std.int(FlxRandom.floatRanged(roomWidthRange.x, roomWidthRange.y));
	}
	
	private function randRoomHeight():Int {
		return Std.int(FlxRandom.floatRanged(roomHeightRange.x, roomHeightRange.y));
	}
	
	private function connectToRandomNeighbor(room:RoomData, ?ConnectCode=0, ?MustBeOriginalConnection=false):RoomData{
		var rX:Int = -1; 
		var rY:Int = -1; 
		
		var doX:Int = FlxRandom.intRanged(0, 1);
		if (doX == 0) {
			rY = room.y;
			while (rX == -1 || rX >= width) {
				rX = room.x + FlxRandom.intRanged( -1, 1, [0]);
			}
		}else {
			rX = room.x;
			while (rY == -1 || rY >= height) {
				rY = room.y + FlxRandom.intRanged( -1, 1, [0]);
			}
		}
		
		var other:RoomData = grid[rX][rY];
		
		//ConnectCodes:
		// 0 -- don't care
		// 1 -- MUST be connected
		//-1 -- MUST be unconnected
		if (ConnectCode != 0) {
			if(ConnectCode == 1){
				if (other.isConnected() == false) {
					return null;
				}
			}else if (ConnectCode == -1) {
				if (other.isConnected() == true) {
					return null;
				}
			}
		}
		
		if (MustBeOriginalConnection) {
			if (room.hasConnection(other)) 
			{
				return null;
			}
		}
		
		room.connect(other);		//connect A to B
		other.connect(room);		//connect B to A
		
		return other;
	}
	
	private function getRandomRoom():RoomData {
		var rX:Int = FlxRandom.intRanged(0, width - 1);
		var rY:Int = FlxRandom.intRanged(0, height - 1);
		return grid[rX][rY];
	}
	
	private function getRoom(connected:Bool=false):RoomData {
		for (x in 0...width) {
			for (y in 0...height) {
				var room:RoomData = grid[x][y];
				if(connected){
					if (room.isConnected()) {
						return room;
					}
				}else {
					if (room.isConnected() == false) {
						return room;
					}
				}
			}
		}
		return null;
	}
	
	private function allRoomsConnected():Bool{
		for (x in 0...width) {
			for (y in 0...height) {
				var room:RoomData = grid[x][y];
				if (!room.isConnected()) {
					return false;
				}
			}
		}
		return true;
	}
	
	private function hasUnconnectedNeighbors(room:RoomData):Bool {
		for (xi in -1...2) {
			for (yi in -1...2) {
				if ((room.x + xi >= 0) && (room.x + xi <= width-1)) {
					if ((room.y + yi >= 0) && (room.y + yi <= height-1)) {
						var neighbor:RoomData = grid[room.x + xi][room.y + yi];
						if (neighbor.isConnected() == false) {
							return true;
						}
					}
				}
			}
		}
		return false;
	}
	
	
	
	
}