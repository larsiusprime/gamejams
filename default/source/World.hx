package ;
import flixel.addons.ui.interfaces.IEventGetter;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;

/**
 * ...
 * @author 
 */
class World extends FlxGroup
{
	public var dude:Creature;
	public var controls:Controls;
	
	public var group_creatures:FlxGroup;
	public var group_bullets:FlxGroup;
	
	public static var instance:World;
	
	public function new() 
	{
		super();
		
		group_creatures = new FlxGroup();
		group_bullets = new FlxGroup();
		
		add(group_creatures);
		add(group_bullets);
		
		dude = new Creature("dude");
		group_creatures.add(dude);
		
		var creature = new Creature("eye");
		group_creatures.add(creature);
		
		creature.x = 100;
		creature.y = 100;
		
		controls = new Controls();
		
		instance = this;
	}
	
	public override function update():Void {
		checkControls();
		super.update();
	}
	
	private function checkControls():Void {
		if (FlxG.keys.checkStatus(controls.RESET, FlxKey.PRESSED)) {
			FlxG.switchState(new PlayState());
		}
		
		var dx:Float = 0;
		var dy:Float = 0;
		
		if (FlxG.keys.checkStatus(controls.LEFT, FlxKey.PRESSED)) {
			dx = -1;
		}else if (FlxG.keys.checkStatus(controls.RIGHT, FlxKey.PRESSED)) {
			dx = 1;
		}
		if (FlxG.keys.checkStatus(controls.UP, FlxKey.PRESSED)) {
			dy = -1;
		}else if(FlxG.keys.checkStatus(controls.DOWN, FlxKey.PRESSED)){
			dy = 1;
		}
		
		var sx:Float = 0;
		var sy:Float = 0;
		
		if (FlxG.keys.checkStatus(controls.SHOOT_LEFT, FlxKey.PRESSED)) {
			sx = -1;
		}else if (FlxG.keys.checkStatus(controls.SHOOT_RIGHT, FlxKey.PRESSED)) {
			sx = 1;
		}
		if (FlxG.keys.checkStatus(controls.SHOOT_UP, FlxKey.PRESSED)) {
			sy = -1;
		}else if(FlxG.keys.checkStatus(controls.SHOOT_DOWN, FlxKey.PRESSED)){
			sy = 1;
		}
		
		if (dx != 0 && dy != 0) {	//diagonal movement
			dx /= 1.414;
			dy /= 1.414;
		}
		
		if (sx != 0 && sy != 0 ) {	//diagonal shooting
			sx /= 1.414;
			sy /= 1.414;
		}
		
		dude.doMove(dx, dy);
		
		if(sx != 0 || sy != 0){
			dude.doShoot(sx, sy);
		}
	}
	
	public static function event(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic> = null):Void {
		
	}
	
	public static function request(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>=null):Dynamic {
		switch(name) 
		{
			case "bullet":
				var b:FlxSprite = cast instance.group_bullets.getFirstDead();
				if (b != null)
				{
					b.reset(0, 0);
				}
				else 
				{
					b = new Bullet();
					instance.group_bullets.add(b);
				}
				return b;
		}
		return null;
	}
}