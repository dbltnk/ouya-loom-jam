package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;

    import system.platform.Gamepad;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;
    import loom2d.math.Point;

    public class HeroMover extends LoomComponent
    {
    	public var x:Number = 0;
    	public var y:Number = 0;
    	public var radius:Number = 16;

    	public var vX:Number = 0;
    	public var vY:Number = 0;

    	public var speed:Number = Config.HERO_SPEED;

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
            
            for (var i:int = 0; i < OUYAJam.instance.buildings.length; ++i)
            {
				var b = OUYAJam.instance.getBuildingMover(i);
				if (b.isSolid())
				{
					var p = Geometry.resolveAOverlapB(x,y,radius, b.x,b.y,b.radius);
					x += p.x;
					y += p.y;
				}
			}
    	}
    }
}