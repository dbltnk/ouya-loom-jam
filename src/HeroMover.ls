package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;

    import system.platform.Gamepad;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;
    import loom2d.math.Point;
    import system.platform.Platform;

    public class HeroMover extends LoomComponent
    {
    	public var x:Number = 0;
    	public var y:Number = 0;
    	public var radius:Number = Config.HERO_RADIUS;

		public var lastDamageTime:Number = -100000;
		public var damageTimeout:Number = 1000;
		
		public var damage:Number = 10;
		
    	public var vX:Number = 0;
    	public var vY:Number = 0;
    	
    	public var health:Number = Config.HERO_HP;
    	public var healthMax:Number = Config.HERO_HP;

    	public var speed:Number = Config.HERO_SPEED;

		public function isDead():Boolean
		{
			return health <= 0;
		}

    	public function move(dt:Number):void
    	{
			vX = OUYAJam.instance.map.forgeX - x;
			vY = OUYAJam.instance.map.forgeY - y;
			//~ trace(vX,vY);
			var l = Math.sqrt(vX*vX+vY*vY);
			vX /= l;
			vY /= l;
			
    		x += vX * (dt / 1000) * speed;
            y += vY * (dt / 1000) * speed;
            
            // collision?
            for (var i:int = 0; i < OUYAJam.instance.buildings.length; ++i)
            {
				var b = OUYAJam.instance.getBuildingMover(i);
				if (b.isSolid() && Geometry.doSpheresOverap(x,y,radius, b.x,b.y,b.radius))
				{
					var p = Geometry.resolveAOverlapB(x,y,radius, b.x,b.y,b.radius);
					x += p.x;
					y += p.y;
					
					// attack?
					if (Platform.getTime() - lastDamageTime > damageTimeout)
					{
						if (b.type == Map.TYPE_WALL)
						{
							b.hp -= damage;
							lastDamageTime = Platform.getTime();
						}
					}					
				}
			}
			
			if (isDead())
			{
				trace("omg im dead");
				var killable = _owner.lookupComponentByName("killable") as Killable;
				killable.dead = true;
			}
    	}
    }
}