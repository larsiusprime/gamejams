package ;
import flixel.addons.ui.U;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import haxe.Constraints.Function;
import haxe.xml.Fast;

/**
 * ...
 * @author 
 */
class Creature extends FlxSprite
{
	public var name:String;
	public var stats:Stats;
	public var behavior:Void->Void = null;
	public var weapon:Weapon;
	
	public function new(Name:String) 
	{
		super();
		name = Name;
		var xml:Fast = U.xml(name, "xml", true, "assets/data/creatures/");
		fromXML(xml);
	}
	
	public function fromXML(xml:Fast):Void {
		var image:String = U.xml_str(xml.node.image.x, "value", true);
		loadGraphic("assets/images/" + image);
		
		stats = new Stats(xml);
		weapon = new Weapon(xml);
		
		var behavior:String = U.xml_str(xml.node.behavior.x, "value", true);
		switch(behavior) {
			case "seek":
			case "player":
		}
	}
	
	public override function update():Void {
		super.update();
		if (behavior != null) {
			behavior();
		}
	}
	
	public function doMove(dx:Float, dy:Float):Void {
		velocity.x = dx * stats.speed * Stats.SPEED_CONST;
		velocity.y = dy * stats.speed * Stats.SPEED_CONST;
	}
	
	public function doShoot(sx:Float, sy:Float):Void {
		if (weapon.available) {
			var b:Bullet = weapon.getBullet();
			b.owner = this;
			b.x = x + width / 2;
			b.y = y + height / 2;
			b.velocity.x = velocity.x + sx * stats.speed * Stats.SPEED_CONST;
			b.velocity.y = velocity.y + sy * stats.speed * Stats.SPEED_CONST;
		}
	}
	
	/*******BEHAVIORS*********/
	
	
	
}