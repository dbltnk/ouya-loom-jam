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

    	public var speed:Number = 1000;

    	public function move(dt:Number):void
    	{
    		x += vX * (dt / 1000) * speed;
            y += vY * (dt / 1000) * speed;
    	}
    }
}