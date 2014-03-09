package behaviors;
import flixel.FlxG;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxVector;

/**
 * ...
 * @author 
 */
class Wander implements IBehavior
{
	public var change_time_min:Float;
	public var change_time_max:Float;
	
	public function new(TimeMin:Float,TimeMax:Float) 
	{
		change_time_min = TimeMin;
		change_time_max = TimeMax;
		_vector = new FlxVector();
	}
	
	public function apply(c:Creature):Void {
		_curr_elapse_time += FlxG.elapsed;
		if (_curr_elapse_time > _curr_change_time) {
			_curr_change_time = FlxRandom.floatRanged(change_time_min, change_time_max);
			_curr_elapse_time = 0;
			_vector.x = FlxRandom.floatRanged( -1, 1, [0]);
			_vector.y = FlxRandom.floatRanged( -1, 1, [0]);
			_vector.normalize();
		}
		c.doMove(_vector.x, _vector.y);
	}
	
	private var _curr_change_time:Float = 0;
	private var _curr_elapse_time:Float = 0;
	
	private var _vector:FlxVector;
}