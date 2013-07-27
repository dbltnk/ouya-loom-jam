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
    import loom.gameframework.LoomGameObject;
    import loom2d.tmx.TMXTileMap;
    import cocosdenshion.SimpleAudioEngine;
    import loom2d.display.Sprite;

    import system.platform.Gamepad;

    import loom2d.display.MovieClip;
    import loom2d.textures.Texture;
    import loom2d.textures.TextureAtlas;
    import system.xml.XMLDocument;
    import system.xml.XMLError;
    import system.platform.Platform;

	public class Map
	{
		public var map:TMXTileMap;
		
		public static const TYPE_STORAGE_PLACE = 2;
		public static const TYPE_WALL = 3;		
		public static const TYPE_VILLAGE_HOUSE = 4;
		public static const TYPE_HEALPOINT = 5;
		public static const TYPE_HERO_CITY = 6;		
		public static const TYPE_FOOD_PLACE = 7;		
		public static const TYPE_RES_PLACE = 8;		
		public static const TYPE_ITEMFORGE = 9;		
		
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
        var happyList:Vector.<String>;
        var sadList:Vector.<String>;
        var suspenseList:Vector.<String>;
        var mood:String;

        public var startTime:Number;
        
    
        private var gamepadsConnected:Boolean = false;

        private var players:Vector.<LoomGameObject>;
        private var lastFrame:Number;
        private var playing:Boolean = false; 

        override public function run():void
        {
			// seed random value
			var ts:int = Platform.getEpochTime() - 1374942470;
			for (var i:int = 0; i < ts % 47; ++i) Math.random();
			
			// setup background
			background = new Image(Texture.fromAsset("assets/bg.png"));
            background.x = 0;
            background.y = 0;
            stage.addChild(background);
			
			//~ trace("loading map");
			var map = new TMXTileMap()
			var m = new Map(map);
            map.load("assets/map.tmx");
			//~ trace("num layers", map.numLayers(), "w", map.mapWidth());
            //~ trace("house", m.getTile(0,3,4), m.getPixelX (3,4), m.getPixelY(3,4));
            //~ trace("nop", m.getTile(0,0,0));
            //~ trace("house", m.getTile(0,8,12));
            //~ trace("heal", m.getTile(0,9,4));
            //~ trace("storage", m.getTile(0,4,14));
            //~ trace("wall", m.getTile(0,14,2));
            //~ trace("test", m.getTile(0,1,1));
			            
			var mapImgDict = new Dictionary();
			mapImgDict[Map.TYPE_HEALPOINT] = "assets/healpoint.png";
			mapImgDict[Map.TYPE_VILLAGE_HOUSE] = "assets/village_house.png";
			mapImgDict[Map.TYPE_STORAGE_PLACE] = "assets/storage_place.png";
			mapImgDict[Map.TYPE_WALL] = "assets/wall.png";
			mapImgDict[Map.TYPE_HERO_CITY] = "assets/hero_city.png";
			mapImgDict[Map.TYPE_FOOD_PLACE] = "assets/food_place.png";
			mapImgDict[Map.TYPE_RES_PLACE] = "assets/res_place.png";
			mapImgDict[Map.TYPE_ITEMFORGE] = "assets/itemforge.png";
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

            // Comment out this line to turn off automatic scaling.
            stage.scaleMode = StageScaleMode.LETTERBOX;

            // init game pads
            Gamepad.initialize();
            gamepadsConnected = (Gamepad.numGamepads > 0);

            if (!gamepadsConnected) {
                // TODO show label
                trace("no gamepads detected");
                // return;
            }
            // instantiate one player per gamepad
            players = new Vector.<LoomGameObject>();

            var pads:Vector.<Gamepad> = Gamepad.gamepads;
            var player:LoomGameObject;
            var mover:PlayerMover;
            for (i=0; i < pads.length; i++)
            {  
                player = spawnPlayer(1000, 10, 10, "assets/player/", "mage", "mage-front-stand");
                players.pushSingle(player);
                mover = getPlayerMover(i);
                if (mover)
                    mover.bindToPad(pads[i]);

                trace("Added player " + i);
            }

            if (players.length == 0)
            {
                trace("defaulting to key controls");
                player = spawnPlayer(1000, 10, 10, "assets/player/", "mage", "mage-front-stand");
                players.pushSingle(player);
                mover = getPlayerMover(0);
                if (mover)
                    mover.bindToKeys();
            }

            playing = true;

			//~ SimpleAudioEngine.sharedEngine().playBackgroundMusic("assets/audio/music/happy/happy_fast_1.mp3"); 
			// make a list of all our BG songs
            happyList = listHappySongs();
            sadList = listSadSongs();
            suspenseList = listSuspenseSongs();
            mood = "suspense";
            playMyBGSong();   
            
        }

        public function onFrame():void
        {
            Gamepad.update();
            // another way to get a delta (dt) in milliseconds
            var thisFrame:Number = Platform.getTime();
            var dt:Number = thisFrame - lastFrame;
            if (dt <= 0)
                return;
            lastFrame = thisFrame;

            // if the frame rate is too low, stop the game until it becomes playable
            // this could be caused by dragging the window around
            // if it can't be painted, it shouldn't play
            var lowFps = false;
            if (dt > 1000 / 10)
                lowFps = true;

            if (!isPlaying() || lowFps)
                return;
                
            var mover:PlayerMover;
            for (var i=0; i < players.length; i++)
            {
                mover = getPlayerMover(i);
                if (mover)
                    mover.move(dt);
            }
        }

        override public function onTick():void
        {
            maybeChangeBackgroundMusic();
        }
        
        protected function maybeChangeBackgroundMusic():void
        {
			// change the BG music if none is playing
            if(SimpleAudioEngine.sharedEngine().isBackgroundMusicPlaying())
				return;
            else
				playMyBGSong();
        }
        
        protected function listHappySongs():Vector.<String>
        {
			var musicFiles = new Vector.<String>(); 
			//~ Path.walkFiles("assets/audio/music/happy",function(track:String) { musicFiles.push(track) }, null);
			musicFiles.push("assets/audio/music/happy/happy_fast_1.mp3")
			musicFiles.push("assets/audio/music/happy/happy_mid_1.mp3")
			musicFiles.push("assets/audio/music/happy/happy_mid_2.mp3")
			musicFiles.push("assets/audio/music/happy/happy_slow_1.mp3")
			musicFiles.push("assets/audio/music/happy/happy_slow_2.mp3") 
			return musicFiles;
        }
        
        protected function listSadSongs():Vector.<String>
        {
			var musicFiles = new Vector.<String>(); 
			//~ Path.walkFiles("assets/audio/music/sad",function(track:String) { musicFiles.push(track) }, null); 
			musicFiles.push("assets/audio/music/sad/sad_mid_1.mp3")
			musicFiles.push("assets/audio/music/sad/sad_slow_1.mp3")
			musicFiles.push("assets/audio/music/sad/sad_slow_2.mp3") 
			musicFiles.push("assets/audio/music/sad/sad_slow_3.mp3")
			musicFiles.push("assets/audio/music/sad/sad_slow_4.mp3") 			
			return musicFiles;
        }
        
        protected function listSuspenseSongs():Vector.<String>
        {
			var musicFiles = new Vector.<String>(); 
			//~ Path.walkFiles("assets/audio/music/suspense",function(track:String) { musicFiles.push(track) }, null); 
			musicFiles.push("assets/audio/music/suspense/suspense_mid_1.mp3")
			musicFiles.push("assets/audio/music/suspense/suspense_mid_2.mp3")			
			musicFiles.push("assets/audio/music/suspense/suspense_slow_1.mp3")
			musicFiles.push("assets/audio/music/suspense/suspense_slow_2.mp3") 
			musicFiles.push("assets/audio/music/suspense/suspense_slow_3.mp3")
			return musicFiles;
        }
        
        protected function playMyBGSong():void
        {
             // pick an appropriate song and play it as the background music           
            if (mood == "happy") {
				var randomNumber1:Number = Math.random();
				var pickedSong1:int = Math.round(randomNumber1 * happyList.length);
				var song1:String = happyList[pickedSong1];
				SimpleAudioEngine.sharedEngine().playBackgroundMusic(song1, false); 
			}
            else if (mood == "sad") {
				var randomNumber2:Number = Math.random();
				var pickedSong2:int = Math.round(randomNumber2 * sadList.length);
				var song2:String = sadList[pickedSong2];
				SimpleAudioEngine.sharedEngine().playBackgroundMusic(song2, false); 
			}
            else if (mood == "suspense") {
				var randomNumber3:Number = Math.random();
				var pickedSong3:int = Math.round(randomNumber3 * suspenseList.length);
				var song3:String = suspenseList[pickedSong3];
				SimpleAudioEngine.sharedEngine().playBackgroundMusic(song3, false);   
				//~ trace(randomNumber3,pickedSong3,suspenseList.length,song3)
			}    
			else
				return;  
        }        
        
        
        
        protected function spawnPlayer(speed:Number,
                                       attackRange:Number,
                                       useRange:Number,
                                       path:String,
                                       atlasName:String,
                                       aniName:String):LoomGameObject 
        {
            var gameObject = new LoomGameObject();
            gameObject.owningGroup = group;
            // create a new mover and bind it to the pad
            var mover = new PlayerMover(speed, attackRange, useRange);
            //mover.bindToPad(pad);
            gameObject.addComponent(mover, "mover");
            // create a new player renderer, bind it to the mover and save in component gameObject
            var renderer = new PlayerRenderer(path, atlasName, aniName);
            renderer.addBinding("x", "@mover.x");
            renderer.addBinding("y", "@mover.y");
            renderer.addBinding("lookX", "@mover.lookX");
            renderer.addBinding("lookY", "@mover.lookY");
            
            gameObject.addComponent(renderer, "renderer");
            gameObject.initialize();

            return gameObject;
        }
        
        public function isPlaying():Boolean
        {
            return playing;
        }

        public function getPlayerMover(index:int):PlayerMover
        {
            if (index < 0 || index >= players.length)
                return null;

            return players[index].lookupComponentByName("mover") as PlayerMover;
        }
    }
}
