package ;
import flixel.addons.ui.U;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
//import haxe.Constraints.Function; // DOesn't seem to exists with Haxe/Haxeflixel releases
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
		solid = true;
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
		
		width *= 0.9;
		height *= 0.9;
		offset.x = (frameWidth - width) / 2;
		offset.y = (frameHeight - height) / 2;
	}
	
	public override function update():Void {
		super.update();
		if (behavior != null) {
			behavior();
		}
	}
	
	public function takeHit(b:Bullet):Void {
		stats.hp -= b.damage;
		if (stats.hp <= 0) {
			kill();
			onDeath();
		}
	}
	
	public function onDeath():Void {
		
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
			b.velocity.x = sx * weapon.speed * Stats.SPEED_CONST;
			b.velocity.y = sy * weapon.speed * Stats.SPEED_CONST;
		}
	}
	
	/*******BEHAVIORS*********/
	
	
	
}