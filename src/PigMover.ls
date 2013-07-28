package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;
	import loom2d.math.Point;
	
	import loom.gameframework.LoomGameObject;

    import system.platform.Gamepad;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;

    public class PigMover extends LoomComponent
    {
    	public var x:Number = 0;
    	public var y:Number = 0;
    	
    	public var vX:Number = 0;
    	public var vY:Number = 0;

    	public var range:Number = 100;
    	public var source:Point; 
    	public var dest:Point;

    	public var speed:Number = 0;

    	public function PigMover(x:Number, y:Number, speed:Number, range:Number)
    	{
    		this.speed = speed;
    		this.range = range;
    		this.x = x;
    		this.y = y;
    		source = new Point(x,y);
    		
    		calcDest();
    	}

    	public function move(dt:Number):void
    	{
    		x += vX * (dt / 1000) * speed;
            y += vY * (dt / 1000) * speed;
            
            var dx:Number = x-source.x;
            var dy:Number = y-source.y;
            var sql:Number = dx*dx+dy*dy;
            if (sql > range*range) calcDest();
            
            //~ trace("PIG", x,y,vX,vY,source.x,source.y,dest.x,dest.y);
    	}
    	
    	public function calcDest():void
    	{
			dest.x = source.x + range * (2 * Math.random() - 1);
			dest.y = source.y + range * (2 * Math.random() - 1);
			
			vX = dest.x - source.x;
			vY = dest.y - source.y;
			var l:Number = Math.sqrt(vX*vX+vY*vY);
			if (l > 0)
			{
				vX /= l;
				vY /= l;
			}
			else
			{
				calcDest();
			}
		}
    }
}