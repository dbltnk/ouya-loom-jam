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
				var randomNumber = Math.random();
				//~ trace(randomNumber);
				if (randomNumber <= 0.33) {
					//~ OUYAJam.instance.spawnHeroGroup(x, y, "heal", 5 * Math.random());
					OUYAJam.instance.spawnHero(x, y, "heal");														
				}
				else if (randomNumber <= 0.66) {
					//~ OUYAJam.instance.spawnHeroGroup(x, y, "storage", 5 * Math.random());					
					OUYAJam.instance.spawnHero(x, y, "storage");														
				}
				else if (randomNumber <= 1) {
					//~ OUYAJam.instance.spawnHeroGroup(x, y, "forge", 5 * Math.random());	
					OUYAJam.instance.spawnHero(x, y, "forge");																												
				}

				--spawnCount;
			}
    	}
    }
}
