package ;

/**
 * ...
 * @author 
 */
class RoomData
{
	public var x:Int = 0;
	public var y:Int = 0;
	
	public var width:Int = 0;
	public var height:Int = 0;
	
	public var connections:Array<IntPt>;
	
	public var type:Int = 0;
	
	public static inline var ROOM_EMPTY:Int = 0;
	public static inline var ROOM_START:Int = 1;
	public static inline var ROOM_EXIT:Int = 2;
	
	public function new(X:Int,Y:Int,W:Int,H:Int) 
	{
		x = X;
		y = Y;
		width = W;
		height = H;
		connections = new Array<IntPt>(); // Avoids a initilisation error compiling time.
	}
	
	public function isConnected():Bool
	{ 
		return connections != null && connections.length > 0; 
	}
	
	public function hasConnection(other:RoomData):Bool {
		var exists:Bool = false;
		var ip:IntPt;
		for (ip in connections) {
			if (ip.equals(other.x, other.y)) {
				exists = true;
				break;
			}
		}
		return exists;
	}
	
	public function connect(other:RoomData):Void {
		if(!hasConnection(other)){
			connections.push(new IntPt(other.x, other.y));
		}
	}
}