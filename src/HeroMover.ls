package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;
    import loom.gameframework.LoomGameObject;

    import system.platform.Gamepad;
    import loom2d.math.Point;

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
    	public var target:String = "";
    	public var lastDevTime:Number = 0;
    	public var dev:Number = 0;    	

		public function isDead():Boolean
		{
			return health <= 0;
		}

    	public function move(dt:Number):void
    	{
			//~ trace(target);
			if (target == "forge") {
				vX = OUYAJam.instance.map.forgeX - x;
				vY = OUYAJam.instance.map.forgeY - y;								
			}
			else if (target == "heal") {
				vX = OUYAJam.instance.map.healX - x;
				vY = OUYAJam.instance.map.healY - y;				
			}
			else {
				vX = OUYAJam.instance.map.storageX - x;
				vY = OUYAJam.instance.map.storageY - y;								
			}

			//~ if (target == "forge" && x >= OUYAJam.instance.map.forgeX) {
				//~ target = "heal"
			//~ }

			//~ trace(vX,vY);
			var l = Math.sqrt(vX*vX+vY*vY);
			vX /= l;
			vY /= l;
			
			if (lastDevTime == 0 || Platform.getEpochTime() - lastDevTime > 0.2)
			{
				dev = Math.min(Math.max(0.3,Math.random()),0.9)	
				lastDevTime = Platform.getEpochTime();
				//~ trace(lastDevTime, dev);
			}
    		x += vX * (dt / 1000) * speed * dev;
            y += vY * (dt / 1000) * speed * dev;
            
            // collision?
            OUYAJam.instance.grid.visitObjects(x-2*radius,y-radius,4*radius,4*radius, _owner, function (o:LoomGameObject):void{
				var b:BuildingMover = o.lookupComponentByName("mover") as BuildingMover;
				if (b && b.isSolid() && Geometry.doSpheresOverap(x,y,radius, b.x,b.y,b.radius))
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
			});
			
			if (isDead())
			{
				trace("omg im dead");
				var killable = _owner.lookupComponentByName("killable") as Killable;
				killable.dead = true;
			}
			
			OUYAJam.instance.grid.updateObject(_owner, x, y);
    	}

    	public function hitTestSphere(p:Point, radius:Number):Boolean
    	{
    		if (Geometry.doSpheresOverap(x, y, this.radius, p.x, p.y, radius))
			{
    			trace("hit:", x, y, this.radius, p.x, p.y, radius);
				return true;
			}
    		return false;
    	}
    }
}
