package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;

class Sword extends FlxSprite 
{

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		loadGraphic(AssetPaths.sword__png, true, 16, 16);
		setFacingFlip(FlxObject.UP, false, false);
		setFacingFlip(FlxObject.DOWN, false, true);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		facing = FlxObject.DOWN;
		animation.add("ud", [0, 1, 0], 15, false);
		animation.add("lr", [0, 2, 0], 15, false);
		set_visible(false);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	public function attack(P:Player, Enemies:FlxTypedGroup<Enemy>)
	{
		if (facing == FlxObject.UP || facing == FlxObject.DOWN)
			animation.play("ud");
		if (facing == FlxObject.LEFT || facing == FlxObject.RIGHT)
			animation.play("lr");
		
		// For each enemy, attack it if in range.
		FlxG.overlap(this, Enemies, swordTouchEnemy);
	}
	
	private function swordTouchEnemy(S:Sword, E:Enemy):Void
	{
		if (S.alive && S.exists && E.alive && E.exists)
		{
			E.getsHit(1);
		}
	}
	
	public function holdSword(X:Float, Y:Float, f:Int):Void
	{
		setPosition(X, Y);
		facing = f;
	}
}