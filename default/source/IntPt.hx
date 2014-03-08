package ;

/**
 * ...
 * @author 
 */
class IntPt
{
	public var x:Int = 0;
	public var y:Int = 0;

	public function new(X:Int=0,Y:Int=0) 
	{
		x = X;
		y = Y;
	}
	
	public function copy():IntPt {
		return new IntPt();
	}
	
	public function equals(?other:IntPt,?X:Int=0,?Y:Int=0):Bool {
		if(other != null){
			return (x == other.x && y == other.y);
		}else {
			return (x == X && y == Y);
		}
		return false;
	}
	
}