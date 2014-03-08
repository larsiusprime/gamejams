package;

import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		var start = new FlxUIButton(0, 0, "Start", onStart);
		start.x = (FlxG.width - start.width) / 2;
		start.y = (FlxG.height - start.height) / 2;
		start.broadcastToFlxUI = false;
		add(start);
		
		var title = new FlxText(0, 0, FlxG.width, "Procedural Death Larsrynth", 8);
		title.alignment = "center";
		title.x = (FlxG.width - title.width) / 2;
		title.y = ((start.y - start.height) - title.height) / 2;
		add(title);
		
		var instructions = new FlxText(0, 0, FlxG.width, "WASD to move, ARROWS to shoot, R to restart");
		instructions.alignment = "center";
		instructions.y = title.y + title.height * 2;
		instructions.color = 0xFFFF00;
		add(instructions);
		
		var credit = new FlxText(0, 0, FlxG.width, "by Lars A. Doucet, #ProceduralDeathJam No. 1", 8);
		credit.alignment = "center";
		credit.y = FlxG.height - credit.height * 4;
		add(credit);
	}
	
	private function onStart():Void {
		FlxG.switchState(new PlayState());
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