package ;
import flixel.addons.ui.U;
import haxe.xml.Fast;

/**
 * ...
 * @author 
 */
class Stats
{
	public var hp:Float = 1;
	public var speed:Float = 1;
	
	public static inline var SPEED_CONST:Float = 100;
	
	public function new(xml:Fast = null) 
	{
		if (xml != null) {
			fromXML(xml);
		}
	}
	
	public function fromXML(xml:Fast):Void {
		hp = U.xml_f(xml.x, "hp", 1);
		speed = U.xml_i(xml.x, "speed", 1);
	}
	
}