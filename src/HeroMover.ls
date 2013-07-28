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
    	public var radius:Number = 16;

		public var lastDamageTime:Number = 0;
		public var damageTimeout:Number = 1000;
		
		public var damage:Number = 10;
		
    	public var vX:Number = 0;
    	public var vY:Number = 0;

    	public var speed:Number = Config.HERO_SPEED;
    	public var target:String = "";

    	public function move(dt:Number):void
    	{
			
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

			if (target == "forge" && x >= OUYAJam.instance.map.forgeX) {
				target = "heal"
			}

			//~ trace(vX,vY);
			var l = Math.sqrt(vX*vX+vY*vY);
			vX /= l;
			vY /= l;
			
			var dev = Math.min(Math.max(0.1,Math.random()),0.9)	
    		x += vX * (dt / 1000) * speed * dev;
            y += vY * (dt / 1000) * speed * dev;
            
            for (var i:int = 0; i < OUYAJam.instance.buildings.length; ++i)
            {
				var b = OUYAJam.instance.getBuildingMover(i);
				if (b.isSolid() && Geometry.doSpheresOverap(x,y,radius, b.x,b.y,b.radius))
				{
					var p = Geometry.resolveAOverlapB(x,y,radius, b.x,b.y,b.radius);
					x += p.x;
					y += p.y;
					
					if (Platform.getTime() - lastDamageTime > damageTimeout)
					{
						b.hp -= damage;
						lastDamageTime = Platform.getTime();	
					}					
				}
			}
    	}
    }
}
