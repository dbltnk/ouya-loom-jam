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
    import loom2d.display.Sprite;

    import system.platform.Gamepad;

	public class Map
	{
		public var map:TMXTileMap;
		
		public static const TYPE_HEALPOINT = 5;
		public static const TYPE_VILLAGE_HOUSE = 4;
		public static const TYPE_STORAGE_PLACE = 2;
		public static const TYPE_WALL = 3;		
		public static const TYPE_HERO_CITY = 6;		
		public static const TYPE_FOOD_PLACE = 7;		
		public static const TYPE_RES_PLACE = 8;		
		
		public function Map(map:TMXTileMap)
		{
			this.map = map;
		}
		
		public function getPixelX(x:int, y:int):int 
		{ 
			return x * 32; 
		}
		
		public function getPixelY(x:int, y:int):int 
		{ 
			return y * 32; 
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
		public var background:Image;
		
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
			// setup background
			background = new Image(Texture.fromAsset("assets/bg.png"));
            background.x = 0;
            background.y = 0;
            stage.addChild(background);
			
			trace("loading map");
			var map = new TMXTileMap()
			var m = new Map(map);
            map.load("assets/map.tmx");
			trace("num layers", map.numLayers(), "w", map.mapWidth());
            trace("house", m.getTile(0,3,4), m.getPixelX (3,4), m.getPixelY(3,4));
            trace("nop", m.getTile(0,0,0));
            trace("house", m.getTile(0,8,12));
            trace("heal", m.getTile(0,9,4));
            trace("storage", m.getTile(0,4,14));
            trace("wall", m.getTile(0,14,2));
            trace("test", m.getTile(0,1,1));
			            
			var mapImgDict = new Dictionary();
			mapImgDict[Map.TYPE_HEALPOINT] = "assets/healpoint.png";
			mapImgDict[Map.TYPE_VILLAGE_HOUSE] = "assets/village_house.png";
			mapImgDict[Map.TYPE_STORAGE_PLACE] = "assets/storage_place.png";
			mapImgDict[Map.TYPE_WALL] = "assets/wall_tile_0.png";
			mapImgDict[Map.TYPE_HERO_CITY] = "assets/hero_city.png";
			mapImgDict[Map.TYPE_FOOD_PLACE] = "assets/food_place.png";
			mapImgDict[Map.TYPE_RES_PLACE] = "assets/res_place.png";
            var testMapRoot = new Sprite();
            stage.addChild(testMapRoot);
            
            for (var x:int = 0; x <= 40; ++x)
            for (var y:int = 0; y <= 23; ++y)
            {
				var idx:int = m.getTile(0,x,y);
				if (idx && mapImgDict[idx])
				{
					var t = new Image(Texture.fromAsset(String(mapImgDict[idx])));
					t.x = m.getPixelX (x,y);
					t.y = m.getPixelY (x,y);
					testMapRoot.addChild(t);
				}
			}



            Gamepad.initialize();
            // Comment out this line to turn off automatic scaling.
            stage.scaleMode = StageScaleMode.LETTERBOX;

            // Setup anything else, like UI, or game objects.
            /*var bg = new Image(Texture.fromAsset("assets/background.png"));
            stage.addChild(bg);
            
            middleground = new Image(Texture.fromAsset("assets/middleground.png"));
            stage.addChild(middleground);
            */
            //~ sprite = new Image(Texture.fromAsset("assets/sizes.png"));
            //~ sprite.center();
            //~ sprite.x = stage.stageWidth / 2;
            //~ sprite.y = stage.stageHeight / 2 + 50;
            //~ stage.addChild(sprite);


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