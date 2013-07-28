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
    import loom2d.math.Point;
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
		
		public var forgeX:Number = 0;
		public var forgeY:Number = 0;
		public var healX:Number = 0;
		public var healY:Number = 0;
		public var storageX:Number = 0;
		public var storageY:Number = 0;
				
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
		public static var instance:OUYAJam;
		
		public var background:Image;
		
        public var label:SimpleLabel;
        //public var middleground:Image;
        public var sprite:Image;
        var happyList:Vector.<String>;
        var sadList:Vector.<String>;
        var suspenseList:Vector.<String>;
        var athmoList:Vector.<String>;
        var mood:String;

        var lastTimeWePlayedAnAthmoSound:int;
        
    
        private var gamepadsConnected:Boolean = false;

        public var players:Vector.<LoomGameObject>;
        public var projectiles:Vector.<LoomGameObject>;
        public var heroes:Vector.<LoomGameObject>;
        public var cities:Vector.<LoomGameObject>;
        public var buildings:Vector.<LoomGameObject>;
        public var lastFrame:Number;
        private var playing:Boolean = false; 
        public var village:Village;

		public var map:Map;
		
        override public function run():void
        {
			instance = this;
			
			// seed random value
			var ts:int = Platform.getEpochTime() - 1374942470;
			for (var i:int = 0; i < ts % 47; ++i) Math.random();
			
            // setup object lists
            heroes = new Vector.<LoomGameObject>();
            cities = new Vector.<LoomGameObject>();
            players = new Vector.<LoomGameObject>();
            projectiles = new Vector.<LoomGameObject>();
            buildings = new Vector.<LoomGameObject>();
            village = new Village();

			// setup background
			background = new Image(Texture.fromAsset("assets/bg.png"));
            background.x = 0;
            background.y = 0;
            stage.addChild(background);
			
			//~ trace("loading map");
			var tileMap = new TMXTileMap()
			map = new Map(tileMap);
            tileMap.load("assets/map.tmx");
			//~ trace("num layers", map.numLayers(), "w", map.mapWidth());
            //~ trace("house", map.getTile(0,3,4), map.getPixelX (3,4), map.getPixelY(3,4));
            //~ trace("nop", map.getTile(0,0,0));
            //~ trace("house", map.getTile(0,8,12));
            //~ trace("heal", map.getTile(0,9,4));
            //~ trace("storage", map.getTile(0,4,14));
            //~ trace("wall", map.getTile(0,14,2));
            //~ trace("test", map.getTile(0,1,1));
			            
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
				var idx:int = map.getTile(0,x,y);
				if (idx && mapImgDict[idx])
				{
					var tx = map.getPixelX (x,y);
					var ty = map.getPixelY (x,y);
					
					if (idx == Map.TYPE_HERO_CITY)
					{
						trace("SPAWN CITY");
						
						spawnCity(tx, ty);
					}
					else if (idx == Map.TYPE_ITEMFORGE)
					{
						map.forgeX = tx;
						map.forgeY = ty;
						
						var forge = spawnBuilding(idx, tx,ty, "assets/itemforge.png", "assets/itemforge_broken.png", true);
						var forgeMover = forge.lookupComponentByName("mover") as BuildingMover;
						forgeMover.heroDamage = Config.FORGE_HERO_DAMAGE;
						forgeMover.damageTimeout = Config.FORGE_DAMAGE_TIMEOUT;
					}
					else if (idx == Map.TYPE_HEALPOINT)
					{
						map.healX = tx;
						map.healY = ty;
						
						spawnBuilding(idx, tx,ty, "assets/healpoint.png", "assets/healpoint_broken.png", true);
					}
					else if (idx == Map.TYPE_STORAGE_PLACE)
					{
						map.storageX = tx;
						map.storageY = ty;
						
						spawnBuilding(idx, tx,ty, "assets/storage_place.png", "assets/storage_place_broken.png", true);
					}										
					else if (idx == Map.TYPE_WALL)
					{
						spawnBuilding(idx, tx,ty, "assets/wall.png", "assets/wall_broken.png", true);
					}
					else
					{
						var t = new Image(Texture.fromAsset(String(mapImgDict[idx])));
						t.x = tx;
						t.y = ty;
						testMapRoot.addChild(t);
					}
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

            var pads:Vector.<Gamepad> = Gamepad.gamepads;
            var player:LoomGameObject;
            var mover:PlayerMover;

            for (i=0; i < pads.length; i++)
            {  
                player = spawnPlayer(Config.PLAYER_SPEED,
                                     Config.PLAYER_ATTACK_RANGE,
                                     Config.PLAYER_ATTACK_DAMAGE,
                                     Config.PLAYER_ATTACK_COOL_DOWN,
                                     Config.PLAYER_USE_RANGE,
                                     "assets/player/", "mage", "mage-front-stand");
                
                mover = getPlayerMover(i);
                if (mover)
                    mover.bindToPad(pads[i]);

                trace("Added player " + i);
            }

            if (players.length == 0)
            {
                trace("defaulting to key controls");
                player = spawnPlayer(Config.PLAYER_SPEED,
                                     Config.PLAYER_ATTACK_RANGE,
                                     Config.PLAYER_ATTACK_DAMAGE,
                                     Config.PLAYER_ATTACK_COOL_DOWN,
                                     Config.PLAYER_USE_RANGE,
                                     "assets/player/", "mage", "mage-front-stand");
                mover = getPlayerMover(0);
                if (mover)
                    mover.bindToKeys(LoomKey.W, LoomKey.A, LoomKey.S, LoomKey.D);
                    
                player = spawnPlayer(Config.PLAYER_SPEED,
                                     Config.PLAYER_ATTACK_RANGE,
                                     Config.PLAYER_ATTACK_DAMAGE,
                                     Config.PLAYER_ATTACK_COOL_DOWN,
                                     Config.PLAYER_USE_RANGE,
                                     "assets/player/", "mage", "mage-front-stand");
                mover = getPlayerMover(1);
                if (mover)
                    mover.bindToKeys(LoomKey.UP_ARROW, LoomKey.LEFT_ARROW, LoomKey.DOWN_ARROW, LoomKey.RIGHT_ARROW);
            }

            playing = true;

			//~ SimpleAudioEngine.sharedEngine().playBackgroundMusic("assets/audio/music/happy/happy_fast_1.mp3"); 
			// make a list of all our BG songs
            happyList = listHappySongs();
            sadList = listSadSongs();
            suspenseList = listSuspenseSongs();
            athmoList = listAthmoSounds();
			mood = "happy";
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
                
            var n:int = players.length;
            var i:int;
            var j:int;
            var mover:PlayerMover;
            var pm:ProjectileMover;
            var p:Point;
            var hm:HeroMover;

            for (i=0; i < n; i++)
            {
                mover = getPlayerMover(i);
                if (mover)
                    mover.move(dt);
            }

            n = projectiles.length;
            for (i = 0; i < n; i ++)
            {
                pm = getProjectileMover(i);
                if (pm)
                {
                    pm.move(dt);
                    p = new Point(pm.x, pm.y);

                    for (j=0; j < heroes.length; j++)
                    {
                        hm = getHeroMover(j);
                        if (hm && hm.hitTestSphere(p, pm.radius));
                        {
                            // TODO kill hero
                            // TODO kill projectile
                            trace("Hero down!");
                            break;
                        }   
                    }
                }
            }
            
            for (i=0; i < heroes.length; i++)
            {
                hm = getHeroMover(i);
                if (hm)
                    hm.move(dt);
            }
            
            for (i=0; i < cities.length; i++)
            {
				var c = getHeroCity(i);
				if (c) c.update(dt);
			}
			
            for (i=0; i < buildings.length; i++)
            {
				var b = getBuildingMover(i);
				if (b) b.update(dt);
			}

			village.update(dt);
			
			// remove dead objects
			var killable : Killable = null;
			for (i=0; i < players.length; i++)
			{
				killable = players[i].lookupComponentByName("killable") as Killable;
				if (killable && killable.dead)
				{
					trace("remove player");
					players.splice(i, 1);
					killable._owner.destroy();
					--i;
				}
			}
			for (i=0; i < cities.length; i++)
			{
				killable = cities[i].lookupComponentByName("killable") as Killable;
				if (killable && killable.dead)
				{
					trace("remove city");
					cities.splice(i, 1);
					killable._owner.destroy();
					--i;
				}
			}
			for (i=0; i < buildings.length; i++)
			{
				killable = buildings[i].lookupComponentByName("killable") as Killable;
				if (killable && killable.dead)
				{
					trace("remove building");
					buildings.splice(i, 1);
					killable._owner.destroy();
					--i;
				}
			}
			for (i=0; i < heroes.length; i++)
			{
				killable = heroes[i].lookupComponentByName("killable") as Killable;
				if (killable && killable.dead)
				{
					trace("remove hero");
					heroes.splice(i, 1);
					killable._owner.destroy();
					--i;
				}
			}
        }

        override public function onTick():void
        {
            if (heroes.length > 1000) {
				mood = "sad";
				//~ SimpleAudioEngine.sharedEngine().stopBackgroundMusic(false);
				//~ maybeChangeBackgroundMusic();
				//~ SimpleAudioEngine.sharedEngine().resumeBackgroundMusic();
				//~ trace(mood,heroes.length);
			}
			else if (heroes.length > 500) {
				mood = "suspense";
				//~ SimpleAudioEngine.sharedEngine().stopBackgroundMusic(false);		
				//~ maybeChangeBackgroundMusic();					
				//~ SimpleAudioEngine.sharedEngine().resumeBackgroundMusic();	
				//~ trace(mood,heroes.length);
			}
			else {
				//~ trace(mood,heroes.length);
			}
            maybeChangeBackgroundMusic();
            playRandomAthmo();
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
				var pickedSong1:int = Math.floor(randomNumber1 * happyList.length);
				var song1:String = happyList[pickedSong1];
				SimpleAudioEngine.sharedEngine().playBackgroundMusic(song1, false); 
			}
            else if (mood == "sad") {
				var randomNumber2:Number = Math.random();
				var pickedSong2:int = Math.floor(randomNumber2 * sadList.length);
				var song2:String = sadList[pickedSong2];
				SimpleAudioEngine.sharedEngine().playBackgroundMusic(song2, false); 
			}
            else if (mood == "suspense") {
				var randomNumber3:Number = Math.random();
				var pickedSong3:int = Math.floor(randomNumber3 * suspenseList.length);
				var song3:String = suspenseList[pickedSong3];
				SimpleAudioEngine.sharedEngine().playBackgroundMusic(song3, false);   
				//~ trace(randomNumber3,pickedSong3,suspenseList.length,song3)
			}    
			else
				return;  
        }    
        
        protected function listAthmoSounds():Vector.<String>
        {
			var musicFiles = new Vector.<String>(); 
			//~ Path.walkFiles("assets/audio/music/suspense",function(track:String) { musicFiles.push(track) }, null); 
			musicFiles.push("assets/audio/sfx/athmo/athmo_bird_1.wav")
			musicFiles.push("assets/audio/sfx/athmo/athmo_bird_2.wav")
			musicFiles.push("assets/audio/sfx/athmo/athmo_bird_3.wav")
			musicFiles.push("assets/audio/sfx/athmo/athmo_bird_4.wav")
			//~ musicFiles.push("assets/audio/sfx/athmo/athmo_wind_1.wav")
			return musicFiles;
        }
            
         protected function playRandomAthmo():void
        {
             // pick an appropriate song and play it as the background music           
            if (Math.random() <= 0.05 && Platform.getEpochTime() - lastTimeWePlayedAnAthmoSound >=8 ) {
				var randomNumber:Number = Math.random();
				var pickedSound:int = Math.floor(randomNumber * athmoList.length);
				var sound:String = athmoList[pickedSound];
				//~ trace("SOUND",sound);
				//~ trace("done",randomNumber,pickedSound,athmoList.length,sound,SimpleAudioEngine.sharedEngine().getEffectsVolume())
				SimpleAudioEngine.sharedEngine().playEffect(sound, false); 
				lastTimeWePlayedAnAthmoSound = Platform.getEpochTime();
			}
			else
				return;  
        }        
        
        
        
        protected function spawnPlayer(speed:Number,
                                       attackRange:Number,
                                       attackDamage:Number,
                                       attackCoolDown:Number,
                                       useRange:Number,
                                       path:String,
                                       atlasName:String,
                                       aniName:String):LoomGameObject 
        {
            var gameObject = new LoomGameObject();
            gameObject.owningGroup = group;
            // create a new mover and bind it to the pad
            var mover:PlayerMover = new PlayerMover(speed, attackRange, attackDamage, attackCoolDown, useRange);
            //mover.bindToPad(pad);
            gameObject.addComponent(mover, "mover");
            // create a new player renderer, bind it to the mover and save in component gameObject
            var renderer:PlayerRenderer = new PlayerRenderer(path, atlasName, aniName);
            renderer.addBinding("x", "@mover.x");
            renderer.addBinding("y", "@mover.y");
            renderer.addBinding("lookAngle", "@mover.lookAngle");
            
			gameObject.addComponent(new Killable(), "killable");

            gameObject.addComponent(renderer, "renderer");
            gameObject.initialize();

			players.pushSingle(gameObject);

            return gameObject;
        }

        public function spawnProjectile(playerMover:PlayerMover,
                                        posX:Number, posY:Number,
                                        directionX:Number, directionY:Number,
                                        damage:Number, range:Number):void
        {
            var projectile:LoomGameObject = new LoomGameObject();
            projectile.owningGroup = group;

            var mover:ProjectileMover = new ProjectileMover(
                posX,
                posY,
                directionX,
                directionY,
                Config.PROJECTILE_SPEED,
                damage
            );
            // TODO range
            projectile.addComponent(mover, "mover");

            var renderer:ProjectileRenderer = new ProjectileRenderer();
            renderer.addBinding("x", "@mover.x");
            renderer.addBinding("y", "@mover.y");
            projectile.addComponent(renderer, "renderer");
            projectile.initialize();

            projectiles.pushSingle(projectile);
        }
        
        public function spawnHero(x:Number, y:Number, target:String):LoomGameObject 
        {
            var gameObject = new LoomGameObject();
            gameObject.owningGroup = group;
            //~ create a new mover and bind it to the pad
            var mover = new HeroMover();
            mover.x = x+30;
            mover.y = y+80;
            mover.target = target;

			gameObject.addComponent(new Killable(), "killable");

            //mover.bindToPad(pad);
            gameObject.addComponent(mover, "mover");
            // create a new player renderer, bind it to the mover and save in component gameObject
            var renderer = new HeroRenderer();
            renderer.addBinding("x", "@mover.x");
            renderer.addBinding("y", "@mover.y");
            
            gameObject.addComponent(renderer, "renderer");
            gameObject.initialize();

			heroes.pushSingle(gameObject);

            return gameObject;
        }
        
        public function spawnHeroGroup(x:Number, y:Number, target:String, amount:Number):void 
        {
			for (var i=0; i < amount; i++)
            {
				OUYAJam.instance.spawnHero(x, y, target);
            } 
		}
        
        public function spawnBuilding(type:int, x:Number, y:Number, normalImage:String, brokenImage:String, solid:Boolean):LoomGameObject 
        {
            var gameObject = new LoomGameObject();
            gameObject.owningGroup = group;
            //~ create a new mover and bind it to the pad
            var mover = new BuildingMover();
            mover.x = x;
            mover.y = y;
            mover.type = type;
            mover.solid = solid;
            //~ mover.broken = true;

			gameObject.addComponent(new Killable(), "killable");

            gameObject.addComponent(mover, "mover");
            // create a new player renderer, bind it to the mover and save in component gameObject
            var renderer = new BuildingRenderer();
            renderer.addBinding("x", "@mover.x");
            renderer.addBinding("y", "@mover.y");
            renderer.addBinding("broken", "@mover.broken");
            renderer.imageFile = normalImage;
            renderer.imageFileBroken = brokenImage;
            
            gameObject.addComponent(renderer, "renderer");
            gameObject.initialize();

			buildings.pushSingle(gameObject);

            return gameObject;
        }
        
        public function spawnCity(x:Number, y:Number):LoomGameObject 
        {
            var gameObject = new LoomGameObject();
            gameObject.owningGroup = group;
            var city = new HeroCity();
            city.x = x;
            city.y = y;
            gameObject.addComponent(city, "city");
            gameObject.initialize();

			gameObject.addComponent(new Killable(), "killable");

            var renderer = new BuildingRenderer();
            renderer.addBinding("x", "@city.x");
            renderer.addBinding("y", "@city.y");
            renderer.addBinding("broken", "@city.broken");
            renderer.imageFile = "assets/hero_city.png";
            renderer.imageFileBroken = "assets/hero_city_broken.png";
            
            gameObject.addComponent(renderer, "renderer");
            gameObject.initialize();

			cities.pushSingle(gameObject);

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
        public function getProjectileMover(index:int):ProjectileMover
        {
            if (index < 0 || index >= projectiles.length)
                return null;

            return projectiles[index].lookupComponentByName("mover") as ProjectileMover;
        }
        public function getHeroMover(index:int):HeroMover
        {
            if (index < 0 || index >= heroes.length)
                return null;

            return heroes[index].lookupComponentByName("mover") as HeroMover;
        }
        
        public function getHeroCity(index:int):HeroCity
        {
            if (index < 0 || index >= cities.length)
                return null;

            return cities[index].lookupComponentByName("city") as HeroCity;
        }
        
        public function getBuildingMover(index:int):BuildingMover
        {
            if (index < 0 || index >= buildings.length)
                return null;

            return buildings[index].lookupComponentByName("mover") as BuildingMover;
        }
    }
}
