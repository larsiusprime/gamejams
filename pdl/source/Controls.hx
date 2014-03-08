package ;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;

/**
 * ...
 * @author 
 */
class Controls
{
	public var LEFT:Int = FlxKey.A;
	public var RIGHT:Int = FlxKey.D;
	public var DOWN:Int = FlxKey.S;
	public var UP:Int = FlxKey.W;
	
	public var SHOOT_LEFT:Int = FlxKey.LEFT;
	public var SHOOT_DOWN:Int = FlxKey.DOWN;
	public var SHOOT_RIGHT:Int = FlxKey.RIGHT;
	public var SHOOT_UP:Int = FlxKey.UP;
	
	public var RESET:Int = FlxKey.R;
	
	public function new() 
	{
		
	}
}