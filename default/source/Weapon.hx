package ;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.addons.ui.U;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.xml.Fast;

/**
 * ...
 * @author 
 */
class Weapon 
{
	public var damage:Float = 1;
	public var size:String = "small";
	public var cooldown:Float = 0.1;
	public var color:Int = FlxColor.WHITE;
	public var available(default, null):Bool = false;
	
	public function new(xml:Fast) 
	{
		if (xml != null) {
			fromXML(xml);
		}
	}
	
	public function fromXML(xml:Fast):Void {
		if(xml.hasNode.weapon){
			size = U.xml_str(xml.node.weapon.x, "size", true, "small");
			damage = U.xml_f(xml.node.weapon.x, "damage", 0);
			cooldown = U.xml_f(xml.node.weapon.x, "cooldown", 0.1);
			color = U.parseHex(U.xml_str(xml.node.weapon.x, "color", true, "0xFFFFFF"), false, true, 0xFFFFFF);
			available = true;
		}
	}
	
	public function getBullet():Bullet{
		var b:Bullet = World.request("bullet", this, null);
		b.damage = damage;
		b.loadGraphic("assets/images/bullet_" + size + ".png");
		b.color = color;
		FlxTimer.start(cooldown, onCoolDown);
		available = false;
		return b;
	}
	
	public function onCoolDown(f:FlxTimer):Void {
		f.abort();
		available = true;
	}
}