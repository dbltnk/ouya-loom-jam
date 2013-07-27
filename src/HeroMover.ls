package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;

    import system.platform.Gamepad;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;

    public class HeroMover extends LoomComponent
    {
    	public var x:Number = 0;
    	public var y:Number = 0;

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
    	}
    }
}