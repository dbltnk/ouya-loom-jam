package
{
    import loom.Application;
    import loom2d.display.StageScaleMode;
    import loom2d.display.Image;
    import loom2d.textures.Texture;
    import loom2d.ui.SimpleLabel;
    import loom2d.math.Point;

    import loom2d.events.Event;
    import loom2d.events.ResizeEvent;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;
    import loom2d.tmx.TMXTileMap;
    import cocosdenshion.SimpleAudioEngine;


    import system.platform.Gamepad;

	public class Map
	{
		public var map:TMXTileMap;
		
		public static const TYPE_HEALPOINT = 0;
		public static const TYPE_VILLAGE_HOUSE = 1;
		public static const TYPE_STORAGE_PLACE = 2;
		public static const TYPE_WALL = 3;
		
		
		public function Map(map:TMXTileMap)
		{
			this.map = map;
		}
		
		public function getTile(layer:int, x:int, y:int):int
		{
			var w:int = map.mapWidth();
			var idx:int = y * w + x;
			return map.layers()[layer].getData()[idx];
		}
	}

    public class OUYAJam extends Application
    {
        public var label:SimpleLabel;
        //public var middleground:Image;
        public var sprite:Image;
        var list:Vector.<String>;
        
        var hatText:Dictionary.<int, string> = 
        { 
            Gamepad.HAT_CENTERED: "Center",
            Gamepad.HAT_UP: "Up",
            Gamepad.HAT_RIGHT: "Right",
            Gamepad.HAT_LEFT: "Left", 
            Gamepad.HAT_DOWN: "Down",
            Gamepad.HAT_RIGHTUP: "Right & Up",
            Gamepad.HAT_RIGHTDOWN: "Right & Down",
            Gamepad.HAT_LEFTUP: "Left & Up", 
            Gamepad.HAT_LEFTDOWN: "Left & Down" 
        };


        override public function run():void
        {
			trace("loading map");
			var map = new TMXTileMap()
			var m = new Map(map);
            map.load("assets/map.tmx");
			trace("num layers", map.numLayers(), "w", map.mapWidth());
            trace("tile my", m.getTile(0,0,0));
			
            Gamepad.initialize();
            // Comment out this line to turn off automatic scaling.
            stage.scaleMode = StageScaleMode.LETTERBOX;

            // Setup anything else, like UI, or game objects.
            /*var bg = new Image(Texture.fromAsset("assets/background.png"));
            stage.addChild(bg);
            
            middleground = new Image(Texture.fromAsset("assets/middleground.png"));
            stage.addChild(middleground);
            */
            sprite = new Image(Texture.fromAsset("assets/sizes.png"));
            sprite.center();
            sprite.x = stage.stageWidth / 2;
            sprite.y = stage.stageHeight / 2 + 50;
            stage.addChild(sprite);


            // check whether any gamepads were detected
            if (Gamepad.numGamepads)
            {

            }

            /*label = new SimpleLabel("assets/Curse-hd.fnt");
            label.text = "Yellow Doom!";
            label.center();
            label.x = stage.stageWidth / 2;
            label.y = 20;
            stage.addChild(label);
            */

            /*stage.addEventListener( Event.RESIZE, function(e:ResizeEvent) { 

                // display the native side as the ResizeEvent stores 
                // our pre-scaled width/height when using scale modes

                var str = "Size: " + stage.nativeStageWidth + "x" + stage.nativeStageHeight;
                label.text = str;
                label.x = stage.stageWidth/2 - label.size.x/2;
                trace(str);

            } );              
            */
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            
			// make a list of all our BG songs
            list = listSongs();
            
            // pick one of our songs and play it as the background music
            var randomNumber:int = Math.round(Math.random()*list.length) - 1;
			var song:String = list[randomNumber];
			//~ trace(list.length);
			//~ trace(randomNumber);
			//~ trace(song);
            SimpleAudioEngine.sharedEngine().playBackgroundMusic(song, false); 
            
        }

        protected function checkForGamePads():void
        {

        }

        override public function onTick():void
        {
            Gamepad.update();
            maybeChangeBackgroundMusic();
        }
        
        protected function maybeChangeBackgroundMusic():void
        {
			// change the BG music if none is playing
            if(SimpleAudioEngine.sharedEngine().isBackgroundMusicPlaying())
				return;
            else
            // pick one of our songs and play it as the background music
				var randomNumber:int = Math.round(Math.random()*list.length) - 1;
				var song:String = list[randomNumber];
				//~ trace(list.length);
				//~ trace(randomNumber);
				//~ trace(song);
				SimpleAudioEngine.sharedEngine().playBackgroundMusic(song, false); 
        }
        
        protected function listSongs():Vector.<String>
        {
			var musicFiles = new Vector.<String>(); 
			Path.walkFiles("assets/audio/music",function(track:String) { musicFiles.push(track) }, null); 
			return musicFiles;
        }
        
        protected function keyDownHandler(event:KeyboardEvent):void
        {   
            var keycode = event.keyCode;
            if(keycode == LoomKey.W)
                sprite.y -= 10;
            if(keycode == LoomKey.S)
                sprite.y += 10;
            if(keycode == LoomKey.A)
                sprite.x -= 10;
            if(keycode == LoomKey.D)
                sprite.x += 10;
        }
    }
}