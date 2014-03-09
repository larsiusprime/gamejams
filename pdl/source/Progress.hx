package ;
import flixel.addons.ui.U;
import haxe.xml.Fast;

/**
 * ...
 * @author 
 */
class Progress
{
	public var level:Int = 0;			//what level of the dungeon are you at
	public var maxLevel:Int = 0;		//last level
	
	public function new() 
	{
		var xml:Fast = U.xml("dungeon", "xml", true, "assets/data/");
		if (xml.hasNode.level) {
			for (lNode in xml.nodes.level) {
				var l:Int = U.xml_i(lNode.x, "value");
				if (l > maxLevel) {
					maxLevel = l;
				}
			}
		}
		xml = null;
	}
	
	public function reset():Void {
		level = 0;
	}
	
}