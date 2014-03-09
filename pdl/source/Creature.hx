package ;
import behaviors.IBehavior;
import behaviors.Player;
import behaviors.Seek;
import behaviors.Wander;
import flixel.addons.ui.U;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import haxe.xml.Fast;

/**
 * ...
 * @author 
 */
class Creature extends FlxSprite
{
	public var name:String;
	public var stats:Stats;
	public var behaviors:Array<IBehavior>;
	public var weapon:Weapon;
	public var type:String;
	
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
		
		setupBehaviors(xml);
		
		width *= 0.9;
		height *= 0.9;
		offset.x = (frameWidth - width) / 2;
		offset.y = (frameHeight - height) / 2;
	}
	
	public override function update():Void {
		super.update();
		behave();
	}
	
	public function behave():Void {
		for (b in behaviors) {
			b.apply(this);
		}
	}
	
	public function takeHit(?b:Bullet, ?w:Weapon):Void {
		if(b != null){
			stats.hp -= b.damage;
		}
		if (w != null) {
			stats.hp -= w.damage;
		}
		if (stats.hp <= 0) {
			kill();
			onDeath();
		}
	}
	
	public function onTouch(other:Creature):Void {
		if (other.weapon != null && other.weapon.type == Weapon.TYPE_TOUCH) {
			if (other.weapon.only_vs == "" || other.weapon.only_vs == name) {	//if the other creature's touch affects everything OR just me
				takeHit(other.weapon);
			}
		}
	}
	
	public function onDeath():Void {
		World.event("creature_killed", this, name);
	}
	
	public function doMove(dx:Float, dy:Float):Void {
		velocity.x = dx * stats.speed * Stats.SPEED_CONST;
		velocity.y = dy * stats.speed * Stats.SPEED_CONST;
	}
	
	public function doShoot(sx:Float, sy:Float):Void {
		if (weapon.available && weapon.type == Weapon.TYPE_PROJECTILE) 
		{
			var b:Bullet = weapon.getBullet();
			b.owner = this;
			b.x = x + width / 2;
			b.y = y + height / 2;
			b.velocity.x = sx * weapon.speed * Stats.SPEED_CONST;
			b.velocity.y = sy * weapon.speed * Stats.SPEED_CONST;
		}
	}
	
	/*******BEHAVIORS*********/
	
	private function setupBehaviors(xml:Fast):Void {
		behaviors = [];
		
		if(xml.hasNode.behavior){		
			for (bNode in xml.nodes.behavior) {
				var behavior:String = U.xml_str(bNode.x, "value", true);
				switch(behavior) {
					case "player":
						var player:Player = new Player();
						behaviors.push(player);
					case "seek":
						var dude:Creature = cast World.request("dude", this, null);
						var seek:Seek = new Seek(dude);
						behaviors.push(seek);
					case "wander":
						var timeMin:Float = U.xml_f(bNode.x, "timeMin", 1);
						var timeMax:Float = U.xml_f(bNode.x, "timeMax", 1);
						var wander:Wander = new Wander(timeMin, timeMax);
						behaviors.push(wander);
				}
			}
		}
	}
	
}