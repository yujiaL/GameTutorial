package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxSpriteUtil;
import flixel.addons.weapon.FlxWeapon;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;

class Player extends FlxSprite
{
	public var speed:Float = 200;
	
	private var _sword:Sword;
	private var _health:Int;
	
	public function new(?X:Float=0, ?Y:Float=0, sword:Sword) 
	{
		super(X, Y);
		
		// Make the actual size of the player smaller.
		setSize(8, 14);
		offset.set(0, 2);
		
		// Load animation for the player.
		loadGraphic(AssetPaths.player__png, true, 16, 16);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("lr", [3, 4, 3, 5], 6, false);
		animation.add("u", [6, 7, 6, 8], 6, false);
		animation.add("d", [0, 1, 0, 2], 6, false);
		
		// Add weapon.
		_sword = sword;
		facing = FlxObject.DOWN;
		_sword.holdSword(this.x + 16, this.y, facing);
		_sword.set_visible(true);
		
		// Health.
		_health = 5;
		
		// Drag force to stop player from keeping walking.
		drag.x = drag.y = 1600;
	}
	
	public function getsHit(damage:Int):Void
	{
		if (!FlxSpriteUtil.isFlickering(this))
		{
			_health -= damage;
			FlxSpriteUtil.flicker(this);
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		if (_health <= 0)
			FlxG.switchState(new MenuState());
			
		switch (facing)
		{
			case FlxObject.LEFT:
				_sword.holdSword(this.x - 16, this.y, facing);
			case FlxObject.RIGHT :
				_sword.holdSword(this.x + 16, this.y, facing);
			case FlxObject.UP:
				_sword.holdSword(this.x, this.y - 16, facing);
			case FlxObject.DOWN:
				_sword.holdSword(this.x, this.y + 16, facing);
		}
		
		movement();
		super.update(elapsed);
	}
	
	private function movement():Void
	{
		var _up:Bool = false;
		var _down:Bool = false;
		var _left:Bool = false;
		var _right:Bool = false;
		
		_up = FlxG.keys.anyPressed([UP, W]);
		_down = FlxG.keys.anyPressed([DOWN, S]);
		_left = FlxG.keys.anyPressed([LEFT, A]);
		_right = FlxG.keys.anyPressed([RIGHT, D]);
		
		if (_up || _down || _left || _right)
		{
			if (_up && _down)
				_up = _down = false;
			if (_left && _right)
				_left = _right = false;
			
			var mA:Float = 0;
			if (_up)
			{
				mA = -90;
				if (_left)
					mA -= 45;
				else if (_right)
					mA += 45;
				facing = FlxObject.UP;
			}
			else if (_down)
			{
				mA = 90;
				if (_left)
					mA += 45;
				else if (_right)
					mA -= 45;
				facing = FlxObject.DOWN;
			}
			else if (_left)
			{
				mA = 180;
				facing = FlxObject.LEFT;
			}
			else if (_right)
			{
				mA = 0;
				facing = FlxObject.RIGHT;
			}
			
			velocity.set(speed, 0);
			velocity.rotate(FlxPoint.weak(0, 0), mA);
			
			// Player the right animation for each direction.
			if ((velocity.x != 0 || velocity.y != 0) && touching == FlxObject.NONE) 
			{
				switch (facing)
				{
					case FlxObject.LEFT:
						animation.play("lr");
					case FlxObject.RIGHT :
						animation.play("lr");
					case FlxObject.UP:
						animation.play("u");
					case FlxObject.DOWN:
						animation.play("d");
				}
			}
		}
	}
	
	public function attack(enemies:FlxTypedGroup<Enemy>)
	{
		_sword.attack(this, enemies);
	}
}