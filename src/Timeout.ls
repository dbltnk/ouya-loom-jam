package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;

    import system.platform.Gamepad;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;
    import system.platform.Platform;

    public class Timeout
    {
		public var lastUsedTime:Number = -100000;
		public var timeout:Number = 1000;
		
		public function tryToActivate():Boolean
		{
			if (Platform.getTime() - lastUsedTime > timeout)
			{
				lastUsedTime = Platform.getTime();
				return true;
			}
			else
			{
				return false;
			}
		}
    }
}