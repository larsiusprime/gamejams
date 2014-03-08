package ;

/**
 * ...
 * @author 
 */
class RoomData
{
	public var x:Int = 0;
	public var y:Int = 0;
	public var connections:Array<IntPt> = [];
	
	public function new(X:Int,Y:Int) 
	{
		x = X;
		y = Y;
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