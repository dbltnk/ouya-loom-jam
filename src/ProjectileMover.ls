package
{
	import loom2d.math.Point;
    import loom.gameframework.LoomComponent;
    import loom.gameframework.LoomGameObject;

	public class ProjectileMover extends LoomComponent
	{
		public var x:Number = 0;
		public var y:Number = 0;
		
		public var source:Point;
		public var range:Number = 0;

		public var vX:Number = 0;
		public var vY:Number = 0;

		public var speed:Number = 0;
		public var damage:Number = 0;

		public var fresh = true;

		public var radius:Number = Config.PROJECTILE_RADIUS;

		public function ProjectileMover(x:Number, y:Number, vX:Number, vY:Number, speed:Number, damage:Number, range:Number)
		{
			this.x = x;
			this.y = y;
			
			this.range = range;
			source = new Point(x,y);

			this.vX = vX;
			this.vY = vY;
			
			this.speed = speed;
			this.damage = damage;
			// norm the vector. vX and vY may not be 0 at the same time. Would cause division by 0.
			var l:Number = Math.sqrt(vX * vX + vY * vY);
			this.vX /= l;
			this.vY /= l;
		}

		public function move(dt:Number):void
    	{
    		x += vX * (dt / 1000) * speed;
            y += vY * (dt / 1000) * speed;

			// don't check against fresh projectiles
			if (fresh) { fresh = false; return; }

			var p = new Point(x, y);
			
			var done = false;

			// collision?
            OUYAJam.instance.grid.visitObjects(x-2*radius,y-radius,4*radius,4*radius, _owner, function (o:LoomGameObject):void{
				var hm:HeroMover = o.lookupComponentByName("mover") as HeroMover;
				if (!done && hm && hm.hitTestSphere(p, radius))
				{
					hm.health -= damage;
					OUYAJam.instance.killObject(this);
					trace("Hero down!");
					done = true;
				}
			});	
			
			// range check
			var dx = x - source.x;
			var dy = y - source.y;
			if (dx*dx+dy*dy >= range*range)
			{
				OUYAJam.instance.killObject(this);
			}
    	}
	}
}