package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;

    import system.platform.Gamepad;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;
    import system.platform.Platform;
    
    public class HeroCity extends LoomComponent
    {
    	public var x:Number = 0;
    	public var y:Number = 0;
    	public var broken:Boolean = false;
    	public var lastSpawnTime:Number = 0;
    	public var spawnTimeout:Number = Config.CITY_SPAWN_TIMEOUT;
    	public var spawnCount:int = 100;
		
    	public function update(dt:Number):void
    	{
			if (Platform.getTime() - lastSpawnTime > spawnTimeout && spawnCount > 0)
			{
				lastSpawnTime = Platform.getTime();
				OUYAJam.instance.spawnHero(x,y);
				--spawnCount;
			}
    	}
    }
}