package ;
import flixel.addons.ui.U;
import flixel.util.FlxPoint;
import haxe.xml.Fast;

/**
 * ...
 * @author 
 */
class SpawnData
{
	public var name:String = "";			//what we're spawning
	public var chance:Float = 0;			//what % chance, 0-1
	public var countRange:FlxPoint;			//how many to spawn
	
	public function new(xml:Fast) 
	{
		name = U.xml_str(xml.x, "value", true);
		chance = U.xml_f(xml.x, "chance", 0);
		if (chance < 0) { chance = 0; }
		if (chance > 1) { chance = 1; }
		countRange = new FlxPoint();
		var countStr:String = U.xml_str(xml.x, "count", true);
		if (countStr != "") {
			if(countStr.indexOf("-") != -1){
				var arr:Array<String> = countStr.split("-");
				countRange.x = Std.parseInt(arr[0]);
				countRange.y = Std.parseInt(arr[1]);
			}else {
				countRange.x = Std.parseInt(countStr);
				countRange.y = countRange.x;
			}
		}
	}
	
}