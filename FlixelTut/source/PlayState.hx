package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	
	private var _player:Player;
	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	private var _grpCoins:FlxTypedGroup<Coin>;
	private var _grpEnemies:FlxTypedGroup<Enemy>;
	
	private var _hud:HUD;
	private var _money:Int = 0;
	private var _health:Int = 3;
	
	private var _inCombat:Bool = false;
	private var _combatHud:CombatHUD;
	
	private var _ending:Bool;
	private var _won:Bool;
	
	override public function create():Void
	{
		// Set up tile.
		_map = new FlxOgmoLoader(AssetPaths.room_001__oel);
		_mWalls = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "walls");
		_mWalls.follow();
		_mWalls.setTileProperties(1, FlxObject.NONE);
		_mWalls.setTileProperties(2, FlxObject.ANY);
		add(_mWalls);
		
		// Set up coins.
		_grpCoins = new FlxTypedGroup<Coin>();
		add(_grpCoins);
		
		// Set up enemy.
		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);
		
		// Set up player.
		_player = new Player();
		_map.loadEntities(placeEntities, "entities");
		add(_player);
		
		// Set camera.
		FlxG.camera.follow(_player, TOPDOWN, 1);
		
		// Set HUD.
		_hud = new HUD();
		add(_hud);
		
		// Set Combat HUD;
		_combatHud = new CombatHUD();
		add(_combatHud);
		
		super.create();
	}
	
	private function placeEntities(entityName:String, entityData:Xml):Void
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "player")
		{
			_player.x = x;
			_player.y = y;
		}
		else if (entityName == "coin")
		{
			_grpCoins.add(new Coin(x + 4, y + 4));
		}
		else if (entityName == "enemy")
		{
			_grpEnemies.add(new Enemy(x + 4, y, Std.parseInt(entityData.get("etype"))));
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (_ending)
		{
			return;
		}
		
		if (!_inCombat)
		{
			// Check for player.
			FlxG.collide(_player, _mWalls);
			FlxG.overlap(_player, _grpCoins, playerTouchCoin);
			
			// Check for enemy.
			FlxG.collide(_grpEnemies, _mWalls);
			_grpEnemies.forEachAlive(checkEnemyVision);
			
			// Fight.
			FlxG.overlap(_player, _grpEnemies, playerTouchEnemy);
		}
		else
		{
			if (!_combatHud.visible) // Come out of fight.
			{
				_health = _combatHud.playerHealth;
				_hud.updateHUD(_health, _money);
				if (_combatHud.outcome == DEFEAT)
				{
					_ending = true;
					FlxG.camera.fade(FlxColor.BLACK, .33, false, doneFadeOut);
				}
				else
				{
					if (_combatHud.outcome == VICTORY)
					{
						_combatHud.e.kill();
						if (_combatHud.e.etype == 1)
						{
							_won = true;
							_ending = true;
							FlxG.camera.fade(FlxColor.BLACK, .33, false, doneFadeOut);
						}
					}
					else
					{
						FlxSpriteUtil.flicker(_combatHud.e);
					}
				}
				_inCombat = false;
				_player.active = true;
				_grpEnemies.active =  true;
			}
		}
		
	}
	
	private function doneFadeOut():Void
	{
		FlxG.switchState(new GameOverState(_won, _money));
	}
	
	private function playerTouchEnemy(P:Player, E:Enemy):Void
	{
		if (P.alive && P.exists && E.alive && E.exists && !FlxSpriteUtil.isFlickering(E))
		{
			startCombat(E);
		}
	}
	
	private function startCombat(E:Enemy):Void
	{
		_inCombat = true;
		_player.active = false;
		_grpEnemies.active = false;
		_combatHud.initCombat(_health, E);
	}
	
	private function checkEnemyVision(e:Enemy):Void
	{
		if (_mWalls.ray(e.getMidpoint(), _player.getMidpoint()))
		{
			e.seesPlayer = true;
			e.playerPos.copyFrom(_player.getMidpoint());
		}
		else
		e.seesPlayer = false;
	}
	
	private function playerTouchCoin(P:Player, C:Coin):Void
	{
		if (P.alive && P.exists && C.alive && C.exists)
		{
			_money++;
			_hud.updateHUD(_health, _money);
			C.kill();
		}
	}
}