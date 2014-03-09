package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var world:World;
	private var progress:Progress;
	
	public function new(level:LevelData = null):Void {
		super();
	}
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		init();
	}
	
	private function init():Void {
		progress = new Progress();
		progress.level = 0;
		nextLevel();
	}
	
	public function nextLevel():Void {
		destroyTheWorld();
		
		progress.level++;
		if (progress.level > progress.maxLevel) {
			FlxG.switchState(new WinState());
		}else {
			world = new World(progress, this);
			add(world);
		}
	}
	
	public function gameOver():Void {
		destroyTheWorld();
		
		FlxG.switchState(new LoseState());
	}
	
	private function destroyTheWorld():Void {
		if (world != null) {
			remove(world, true);
			world.destroy();
			world = null;
		}
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}