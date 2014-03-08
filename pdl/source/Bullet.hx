package ;
import flixel.FlxSprite;

/**
 * ...
 * @author 
 */
class Bullet extends FlxSprite
{
	public var damage:Float = 0;
	public var owner:Creature = null;
	
	public function new() 
	{
		super();
	}
	
	public override function update():Void {
		super.update();
		if (!isOnScreen()) {
			kill();
		}
	}
}