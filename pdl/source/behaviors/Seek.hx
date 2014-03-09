package behaviors;
import flixel.util.FlxVector;

/**
 * ...
 * @author 
 */
class Seek implements IBehavior
{
	public var target:Creature;
	
	private var vector:FlxVector;
	
	public function new(Target:Creature) 
	{
		target = Target;
		vector = new FlxVector();
	}
	
	public function apply(actor:Creature):Void {
		vector.set(target.x-actor.x,target.y-actor.y);
		vector.normalize();
		actor.doMove(vector.x, vector.y);
	}
}