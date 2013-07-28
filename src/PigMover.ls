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

    	public var range:Number = 0;
    	public var source:Point; 
    	public var dest:Point;

    	public var speed:Number = 0;

    	public function PigMover(x:Number, y:Number, speed:Number)
    	{
    		this.speed = speed;
    		this.x = x;
    		this.y = y;
    		source = new Point(x,y);
    		
    		calcDest();
    	}

    	public function move(dt:Number):void
    	{
    		x += vX * (dt / 1000) * speed;
            y += vY * (dt / 1000) * speed;
    	}
    	
    	public function calcDest():void
    	{
			dest.x = source.x + range * (1 - 2 * Math.random());
			dest.y = source.y + range * (1 - 2 * Math.random());
			
			vX = dest.x - source.x;
			vY = dest.y - source.y;
			var l:Number = Math.sqrt(vX*vX+vY*vY);
			vX /= l;
			vY /= l;
		}
    }
}