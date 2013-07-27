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
    	
    	public var radius:Number = 8;
    	
    	public var food:Number = 0;
    	public var resources:Number = 0;
    	public var hp:Number = Config.BUILDING_HP;
    	public var hpMax:Number = Config.BUILDING_HP;    	
    	
    	public function update(dt:Number):void
    	{
			broken = hp <= 0;
    	}
    	
    	public function isSolid():Boolean
    	{
			return solid && !broken;
		}
    }
}