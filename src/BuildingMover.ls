package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;

    import system.platform.Gamepad;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;

    public class BuildingMover extends LoomComponent
    {
		public var type:int = 0;
    	public var x:Number = 0;
    	public var y:Number = 0;
    	public var broken:Boolean = false;
    	public var solid:Boolean = false;
    	
    	public var radius:Number = Config.BUILDING_RADIUS;
    	
    	public var food:Number = 0;
    	public var resources:Number = 0;
    	public var hp:Number = Config.BUILDING_HP;
    	public var hpMax:Number = Config.BUILDING_HP;
  
		public var lastDamageTime:Number = -100000;
		public var damageTimeout:Number = 0;
    	public var heroDamage:Number = 0;
    	public var playerDamage:Number = 0;
    	
    	public function update(dt:Number):void
    	{
			broken = hp <= 0;
			
			var overlap:Number = 5;
			
			// attack possible?
			if (Platform.getTime() - lastDamageTime > damageTimeout)
			{
				// hero damage
				if (heroDamage > 0)
				{
					for (var i:int = 0; i < OUYAJam.instance.heroes.length; ++i)
					{
						var h = OUYAJam.instance.getHeroMover(i);
						if (Geometry.doSpheresOverap(x,y,radius+overlap, h.x,h.y,h.radius))
						{
							h.health -= heroDamage;
							lastDamageTime = Platform.getTime();
							trace("building -> hero damage");
							break;
						}
					}
				}
			}
			// attack possible?
			if (Platform.getTime() - lastDamageTime > damageTimeout)
			{
				// player damage
				if (playerDamage > 0)
				{
					for (i = 0; i < OUYAJam.instance.players.length; ++i)
					{
						var p = OUYAJam.instance.getPlayerMover(i);
						if (Geometry.doSpheresOverap(x,y,radius+overlap, p.x,p.y,p.radius))
						{
							p.health -= heroDamage;
							lastDamageTime = Platform.getTime();
							trace("building -> player damage");
							break;
						}
					}
				}
			}
    	}
    	
    	public function isSolid():Boolean
    	{
			return solid && !broken;
		}
    }
}