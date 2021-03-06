package
{
    import loom.Application;
    import loom2d.display.StageScaleMode;
    import loom2d.display.Image;
    import loom2d.textures.TextureAtlas;
    import loom2d.textures.Texture;
    import loom2d.ui.SimpleLabel;
    import loom2d.math.Point;

    import loom2d.events.Event;
    import loom2d.events.ResizeEvent;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;
    import loom.gameframework.LoomComponent;
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
		
		public var grid:Grid;
		
		public var background:Image;
		
        public var label:SimpleLabel;
        //public var middleground:Image;
        public var sprite:Image;
        var happyList:Vector.<String>;
        var sadList:Vector.<String>;
        var suspenseList:Vector.<String>;
        var happyAtmoList:Vector.<String>;
        var sadAtmoList:Vector.<String>;
        var suspenseAtmoList:Vector.<String>;
        var effectSounds:Vector.<String>;
        var mood:String;


        var lastTimeWePlayedAnatmoSound:int;
        
    
        private var gamepadsConnected:Boolean = false;

        public var players:Vector.<LoomGameObject>;
        public var projectiles:Vector.<LoomGameObject>;
        public var heroes:Vector.<LoomGameObject>;
        public var cities:Vector.<LoomGameObject>;
        public var buildings:Vector.<LoomGameObject>;
        public var pigs:Vector.<LoomGameObject>;
        public var lastFrame:Number;
        private var playing:Boolean = false; 
        public var village:Village;

		public var map:Map;

		protected var atlas:TextureAtlas;
        protected var textures:Dictionary;
        protected var animations:Dictionary;
		
        override public function run():void
        {
			instance = this;
			
			grid = new Grid();
			
			// seed random value
			var ts:int = Platform.getEpochTime() - 1374942470;
			for (var i:int = 0; i < ts % 47; ++i) Math.random();
			
			// load large game texture
            loadGameTextures();

            // setup object lists
            heroes = new Vector.<LoomGameObject>();
            cities = new Vector.<LoomGameObject>();
            players = new Vector.<LoomGameObject>();
            projectiles = new Vector.<LoomGameObject>();
            buildings = new Vector.<LoomGameObject>();
            pigs = new Vector.<LoomGameObject>();
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
			mapImgDict[Map.TYPE_HEALPOINT] = "healpoint";
			mapImgDict[Map.TYPE_VILLAGE_HOUSE] = "village_house";
			mapImgDict[Map.TYPE_STORAGE_PLACE] = "storage_place";
			mapImgDict[Map.TYPE_WALL] = "wall";
			mapImgDict[Map.TYPE_HERO_CITY] = "hero_city";
			mapImgDict[Map.TYPE_FOOD_PLACE] = "food_place";
			mapImgDict[Map.TYPE_RES_PLACE] = "res_place";
			mapImgDict[Map.TYPE_ITEMFORGE] = "itemforge";
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
					else if (idx == Map.TYPE_FOOD_PLACE)
					{
						var food = spawnBuilding(idx, tx,ty, "food_place", "food_place_broken", false);
						var foodMover = food.lookupComponentByName("mover") as BuildingMover;
						foodMover.breakOnEmptyFood = true;
						foodMover.food = Config.FOOD_AMOUNT;
					}
					else if (idx == Map.TYPE_RES_PLACE)
					{
						var res = spawnBuilding(idx, tx,ty, "res_place", "res_place_broken", false);
						var resMover = res.lookupComponentByName("mover") as BuildingMover;
						resMover.breakOnEmptyResources = true;
						resMover.resources = Config.RESOURCE_AMOUNT;
					}
					else if (idx == Map.TYPE_ITEMFORGE)
					{
						map.forgeX = tx;
						map.forgeY = ty;
						
						var forge = spawnBuilding(idx, tx,ty, "itemforge", "itemforge_broken", true);
						var forgeMover = forge.lookupComponentByName("mover") as BuildingMover;
						forgeMover.heroDamage = Config.FORGE_HERO_DAMAGE;
						forgeMover.damageTimeout = Config.FORGE_DAMAGE_TIMEOUT;
					}
					else if (idx == Map.TYPE_HEALPOINT)
					{
						map.healX = tx;
						map.healY = ty;
						
						var heal = spawnBuilding(idx, tx,ty, "healpoint", "healpoint_broken", true);
						var healMover = heal.lookupComponentByName("mover") as BuildingMover;
						healMover.heroDamage = Config.HEALPOINT_HERO_DAMAGE;
						healMover.damageTimeout = Config.HEALPOINT_DAMAGE_TIMEOUT;
					}
					else if (idx == Map.TYPE_VILLAGE_HOUSE)
					{
						spawnBuilding(idx, tx,ty, "village_house", "village_house_broken", true);
						
						spawnPig(tx,ty, Config.PIG_SPEED, Config.PIG_RANGE, "schwein");
						spawnPig(tx,ty, Config.PIG_SPEED, Config.PIG_RANGE, "schwein");
					}										
					else if (idx == Map.TYPE_STORAGE_PLACE)
					{
						map.storageX = tx;
						map.storageY = ty;
						
						var storage = spawnBuilding(idx, tx,ty, "storage_place", "storage_place_broken", true);
						var storageMover = storage.lookupComponentByName("mover") as BuildingMover;
						storageMover.heroDamage = Config.STORAGE_HERO_DAMAGE;
						storageMover.damageTimeout = Config.STORAGE_DAMAGE_TIMEOUT;

						spawnPig(tx,ty, Config.CHICKEN_SPEED, Config.CHICKEN_SPEED, "huhn");
						spawnPig(tx,ty, Config.CHICKEN_SPEED, Config.CHICKEN_SPEED, "huhn");
					}										
					else if (idx == Map.TYPE_WALL)
					{
						spawnBuilding(idx, tx,ty, "wall", "wall_broken", true);
					}
					else
					{
						var t = getImage(String(mapImgDict[idx]));//new Image(Texture.fromAsset(String(mapImgDict[idx])));
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
                                     "mage");
                
                mover = getPlayerMover(i);
                if (mover)
                    mover.bindToPad(pads[i]);

                trace("Added player " + i);
            }

            if (players.length <= 0)
            {
                trace("defaulting to key controls");
                player = spawnPlayer(Config.PLAYER_SPEED,
                                     Config.PLAYER_ATTACK_RANGE,
                                     Config.PLAYER_ATTACK_DAMAGE,
                                     Config.PLAYER_ATTACK_COOL_DOWN,
                                     Config.PLAYER_USE_RANGE,
                                     "mage");
                mover = getPlayerMover(0);
                if (mover)
                    mover.bindToKeys(LoomKey.W, LoomKey.A, LoomKey.S, LoomKey.D,
						LoomKey.R, LoomKey.T);
			}
            
			if (players.length <= 1)
            {
                player = spawnPlayer(Config.PLAYER_SPEED,
                                     Config.PLAYER_ATTACK_RANGE,
                                     Config.PLAYER_ATTACK_DAMAGE,
                                     Config.PLAYER_ATTACK_COOL_DOWN,
                                     Config.PLAYER_USE_RANGE,
                                     "mage");
                mover = getPlayerMover(1);
                if (mover)
                    mover.bindToKeys(LoomKey.UP_ARROW, LoomKey.LEFT_ARROW, LoomKey.DOWN_ARROW, LoomKey.RIGHT_ARROW,
						LoomKey.N, LoomKey.M);
            }

            playing = true;

			//~ SimpleAudioEngine.sharedEngine().playBackgroundMusic("assets/audio/music/happy/happy_fast_1.mp3"); 
			// make a list of all our BG songs
            happyList = listHappySongs();
            sadList = listSadSongs();
            suspenseList = listSuspenseSongs();
            happyAtmoList = listHappyAtmoSounds();
            sadAtmoList = listSadAtmoSounds();
            suspenseAtmoList = listSuspenseAtmoSounds();
            mood = "happy";
            playMyBGSong();   
			SimpleAudioEngine.sharedEngine().setEffectsVolume(Config.VOLUME_SFX);
			
			// preload effects
			preloadEffects();
        }

		public function preloadEffect(path:String)
		{
			SimpleAudioEngine.sharedEngine().preloadEffect(path);
			effectSounds.push(path);
		}

		public function preloadEffects():void
		{
			effectSounds = new Vector.<String>();
			
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_bird_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_bird_2.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_bird_3.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_bird_4.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_bird_5.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_bird_6.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_bird_7.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_chicken_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_pig_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_pig_2.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_pig_3.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_wind_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_happy_wind_2.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_bird_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_bird_2.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_bird_3.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_bird_4.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_bird_5.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_bird_6.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_pig_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_thunder_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_thunder_2.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_wind_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_wind_2.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_sad_wind_3.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_bird_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_bird_2.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_bird_3.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_bird_4.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_bird_5.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_pig_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_pig_2.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_thunder_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_thunder_2.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_wind_1.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_wind_2.wav");
			preloadEffect("assets/audio/sfx/atmo/atmo_suspense_wind_3.wav");
			preloadEffect("assets/audio/sfx/char_action_build_1.wav");
			preloadEffect("assets/audio/sfx/char_action_build_ready.wav");
			preloadEffect("assets/audio/sfx/char_action_hit_1.wav");
			preloadEffect("assets/audio/sfx/char_action_hit_2.wav");
			preloadEffect("assets/audio/sfx/char_action_hit_3.wav");
			preloadEffect("assets/audio/sfx/char_action_hit_4.wav");
			preloadEffect("assets/audio/sfx/char_action_pumpkin_1.wav");
			preloadEffect("assets/audio/sfx/char_action_walk_1.wav");
			preloadEffect("assets/audio/sfx/char_action_wood_1.wav");
			preloadEffect("assets/audio/sfx/char_action_wood_2.wav");
			preloadEffect("assets/audio/sfx/char_action_wood_3.wav");
			preloadEffect("assets/audio/sfx/char_event_block_1.wav");
			preloadEffect("assets/audio/sfx/char_event_block_2.wav");
			preloadEffect("assets/audio/sfx/char_event_block_3.wav");
			preloadEffect("assets/audio/sfx/char_event_death_1.wav");
			preloadEffect("assets/audio/sfx/char_event_death_2.wav");
			preloadEffect("assets/audio/sfx/char_event_death_3.wav");
			preloadEffect("assets/audio/sfx/char_event_death_4.wav");
			preloadEffect("assets/audio/sfx/char_event_death_5.wav");
			preloadEffect("assets/audio/sfx/char_event_heal_1.wav");
			preloadEffect("assets/audio/sfx/char_event_hit_1.wav");
			preloadEffect("assets/audio/sfx/char_event_hit_2.wav");
			preloadEffect("assets/audio/sfx/char_event_hit_3.wav");
			preloadEffect("assets/audio/sfx/char_event_respawn_1.wav");
			preloadEffect("assets/audio/sfx/enemy_action_attack_1.wav");
			preloadEffect("assets/audio/sfx/enemy_action_spawn_1.wav");
			preloadEffect("assets/audio/sfx/enemy_action_walk_1.wav");
			preloadEffect("assets/audio/sfx/enemy_event_death_1.wav");
			preloadEffect("assets/audio/sfx/enemy_event_death_2.wav");
			preloadEffect("assets/audio/sfx/enemy_event_death_3.wav");
			preloadEffect("assets/audio/sfx/enemy_event_death_4.wav");
			preloadEffect("assets/audio/sfx/enemy_event_death_5.wav");
			preloadEffect("assets/audio/sfx/enemy_event_death_6.wav");
			preloadEffect("assets/audio/sfx/enemy_event_death_7.wav");
			preloadEffect("assets/audio/sfx/enemy_event_hit_1.wav");
			preloadEffect("assets/audio/sfx/enemy_event_hit_2.wav");
			preloadEffect("assets/audio/sfx/enemy_event_hit_3.wav");
			preloadEffect("assets/audio/sfx/enemy_event_hit_4.wav");
			preloadEffect("assets/audio/sfx/enemy_event_hit_5.wav");
			preloadEffect("assets/audio/sfx/enemy_event_hit_6.wav");
			preloadEffect("assets/audio/sfx/enemy_event_hit_7.wav");
			preloadEffect("assets/audio/sfx/enemy_event_hit_8.wav");
			preloadEffect("assets/audio/sfx/enemy_event_killChar_1.wav");
			preloadEffect("assets/audio/sfx/enemy_event_towndown_1.wav");
			preloadEffect("assets/audio/sfx/interaction_gate_close_long.wav");
			preloadEffect("assets/audio/sfx/interaction_gate_open_long.wav");
			preloadEffect("assets/audio/sfx/interaction_respumpkin_empty.wav");
			preloadEffect("assets/audio/sfx/interaction_restree_empty.wav");
			preloadEffect("assets/audio/sfx/tower_burn_1.wav");
			preloadEffect("assets/audio/sfx/tower_destroyed_1.wav");
			preloadEffect("assets/audio/sfx/tower_hit_1.wav");
			preloadEffect("assets/audio/sfx/tower_hit_2.wav");
			preloadEffect("assets/audio/sfx/tower_hit_3.wav");
			preloadEffect("assets/audio/sfx/tower_hit_4.wav");
			preloadEffect("assets/audio/sfx/tower_select_1.wav");
			preloadEffect("assets/audio/sfx/tower_shoot_1.wav");
			preloadEffect("assets/audio/sfx/tower_shoot_2.wav");
			preloadEffect("assets/audio/sfx/wall_destroyed_1.wav");
			preloadEffect("assets/audio/sfx/wall_hit_1.wav");
			preloadEffect("assets/audio/sfx/wall_hit_2.wav");
			preloadEffect("assets/audio/sfx/wall_hit_3.wav");
			preloadEffect("assets/audio/sfx/wall_hit_4.wav");
			preloadEffect("assets/audio/sfx/wall_hit_5.wav");
		}
		
		public function playEffect(prefix:String):void
		{
			var count:int = 0;
			
			for(var i:int = 0; i < effectSounds.length; ++i)
			{
				if (effectSounds[i].indexOf(prefix) >= 0) {
					++count;
				}
			}
			
			//~ trace("COUNT", count);
			if (count == 0) return;
			
			var skip:int = int(Math.floor(Math.random() * (count)));
			//~ trace("skip", skip);
			
			for(i = 0; i < effectSounds.length; ++i)
			{
				if (effectSounds[i].indexOf(prefix) >= 0) {
					if (skip == 0) {
						trace("SOUND", effectSounds[i]);
						SimpleAudioEngine.sharedEngine().playEffect(effectSounds[i], false);
						return;
					} else {
						--skip;
					}
				}
			}			
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
			
            for (i=0; i < pigs.length; i++)
            {
				var pi = getPigMover(i);
				if (pi) pi.move(dt);
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
					grid.removeObj(killable._owner);
					killable._owner.destroy();
					--i;
				}
			}
            for (i=0; i < projectiles.length; i++)
            {
                killable = projectiles[i].lookupComponentByName("killable") as Killable;
                if (killable && killable.dead)
                {
                    trace("remove projectile");
                    projectiles.splice(i, 1);
                    grid.removeObj(killable._owner);
                    killable._owner.destroy();
                    --i;
                }
            }
			for (i=0; i < pigs.length; i++)
			{
				killable = pigs[i].lookupComponentByName("killable") as Killable;
				if (killable && killable.dead)
				{
					trace("remove pig");
					pigs.splice(i, 1);
					grid.removeObj(killable._owner);
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
					grid.removeObj(killable._owner);
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
					grid.removeObj(killable._owner);
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
					grid.removeObj(killable._owner);
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
            playRandomAtmo();
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
        
        protected function listHappyAtmoSounds():Vector.<String>
        {
			var musicFiles = new Vector.<String>(); 
			//~ Path.walkFiles("assets/audio/music/suspense",function(track:String) { musicFiles.push(track) }, null); 
			musicFiles.push("assets/audio/sfx/atmo/atmo_happy_bird_1.wav")
			musicFiles.push("assets/audio/sfx/atmo/atmo_happy_bird_2.wav")
			musicFiles.push("assets/audio/sfx/atmo/atmo_happy_bird_3.wav")
			musicFiles.push("assets/audio/sfx/atmo/atmo_happy_bird_4.wav")
			musicFiles.push("assets/audio/sfx/atmo/atmo_happy_bird_5.wav")
			musicFiles.push("assets/audio/sfx/atmo/atmo_happy_bird_6.wav")
			musicFiles.push("assets/audio/sfx/atmo/atmo_happy_bird_7.wav")			
			return musicFiles;
        }
        
        protected function listSadAtmoSounds():Vector.<String>
        {
			var musicFiles = new Vector.<String>(); 
			//~ Path.walkFiles("assets/audio/music/suspense",function(track:String) { musicFiles.push(track) }, null); 
			musicFiles.push("assets/audio/sfx/atmo/atmo_sad_bird_1.wav")
			musicFiles.push("assets/audio/sfx/atmo/atmo_sad_bird_2.wav")
			musicFiles.push("assets/audio/sfx/atmo/atmo_sad_bird_3.wav")
			musicFiles.push("assets/audio/sfx/atmo/atmo_sad_bird_4.wav")
			musicFiles.push("assets/audio/sfx/atmo/atmo_sad_bird_5.wav")
			return musicFiles;
        }
        
        protected function listSuspenseAtmoSounds():Vector.<String>
        {
			var musicFiles = new Vector.<String>(); 
			//~ Path.walkFiles("assets/audio/music/suspense",function(track:String) { musicFiles.push(track) }, null); 
			musicFiles.push("assets/audio/sfx/atmo/atmo_suspense_pig_1.wav")			
			musicFiles.push("assets/audio/sfx/atmo/atmo_suspense_bird_1.wav")			
			musicFiles.push("assets/audio/sfx/atmo/atmo_suspense_thunder_1.wav")			
			musicFiles.push("assets/audio/sfx/atmo/atmo_suspense_thunder_2.wav")			
			return musicFiles;
        }
            
         protected function playRandomAtmo():void
        {
             // pick an appropriate song and play it as the background music           
            if (Math.random() <= 0.05 && Platform.getEpochTime() - lastTimeWePlayedAnatmoSound >=12 ) {
				if (mood == "happy") {
					var randomNumber1:Number = Math.random();
					var pickedSound1:int = Math.floor(randomNumber1 * happyAtmoList.length);
					var sound1:String = happyAtmoList[pickedSound1];
					//~ trace("done",randomNumber1,pickedSound1,happyAtmoList.length,sound1,SimpleAudioEngine.sharedEngine().getEffectsVolume())
					SimpleAudioEngine.sharedEngine().playEffect(sound1, false); 
					lastTimeWePlayedAnatmoSound = Platform.getEpochTime();
				}
				else if (mood == "sad") {
					var randomNumber2:Number = Math.random();
					var pickedSound2:int = Math.floor(randomNumber2 * sadAtmoList.length);
					var sound2:String = sadAtmoList[pickedSound2];
					//~ trace("done",randomNumber2,pickedSound2,sadAtmoList.length,sound2,SimpleAudioEngine.sharedEngine().getEffectsVolume())
					SimpleAudioEngine.sharedEngine().playEffect(sound2, false); 
					lastTimeWePlayedAnatmoSound = Platform.getEpochTime();
				}
				else if (mood == "suspense") {
					var randomNumber3:Number = Math.random();
					var pickedSound3:int = Math.floor(randomNumber3 * suspenseAtmoList.length);
					var sound3:String = suspenseAtmoList[pickedSound3];
					//~ trace("done",randomNumber3,pickedSound3,suspenseAtmoList.length,sound3,SimpleAudioEngine.sharedEngine().getEffectsVolume())
					SimpleAudioEngine.sharedEngine().playEffect(sound3, false); 
					lastTimeWePlayedAnatmoSound = Platform.getEpochTime();
				}    
				else
					return;  	
			}
			else
				return;  
        }        
        
        
        
        protected function spawnPlayer(speed:Number,
                                       attackRange:Number,
                                       attackDamage:Number,
                                       attackCoolDown:Number,
                                       useRange:Number,
                                       aniName:String):LoomGameObject 
        {
            var gameObject = new LoomGameObject();
            gameObject.owningGroup = group;
            // create a new mover and bind it to the pad
            var mover:PlayerMover = new PlayerMover(speed, attackDamage, attackRange, attackCoolDown, useRange);
            //mover.bindToPad(pad);
            gameObject.addComponent(mover, "mover");
            // create a new player renderer, bind it to the mover and save in component gameObject
            var renderer:PlayerRenderer = new PlayerRenderer(aniName);
            renderer.addBinding("x", "@mover.x");
            renderer.addBinding("y", "@mover.y");
            renderer.addBinding("state", "@mover.state");
            renderer.addBinding("direction", "@mover.direction");
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
                damage,
                range
            );
            // TODO range
            projectile.addComponent(mover, "mover");

            var renderer:ProjectileRenderer = new ProjectileRenderer();
            renderer.addBinding("x", "@mover.x");
            renderer.addBinding("y", "@mover.y");
            projectile.addComponent(renderer, "renderer");
            projectile.addComponent(new Killable(), "killable");
            projectile.initialize();

            projectiles.pushSingle(projectile);
        }
        
        public function spawnHero(x:Number, y:Number, target:String):LoomGameObject 
        {
			OUYAJam.instance.playEffect("enemy_action_spawn_");
			
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
            //~ renderer.addBinding("isAttacking", "@mover.isAttacking");
            
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
        
        public function spawnPig(x:Number, y:Number, speed:Number, range:Number, animName:String):LoomGameObject 
        {
            var gameObject = new LoomGameObject();
            gameObject.owningGroup = group;
            var mover = new PigMover(x,y,speed,range);

			gameObject.addComponent(new Killable(), "killable");

            gameObject.addComponent(mover, "mover");
            // create a new player renderer, bind it to the mover and save in component gameObject
            var renderer = new PigRenderer(animName);
            renderer.addBinding("x", "@mover.x");
            renderer.addBinding("y", "@mover.y");
            
            gameObject.addComponent(renderer, "renderer");
            gameObject.initialize();

			pigs.pushSingle(gameObject);

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
            renderer.imageFile = "hero_city";
            renderer.imageFileBroken = "hero_city_broken";
            
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
        
        public function getPigMover(index:int):PigMover
        {
            if (index < 0 || index >= pigs.length)
                return null;

            return pigs[index].lookupComponentByName("mover") as PigMover;
        }
        
        public function findBuildingInRange(x:Number, y:Number, r:Number):BuildingMover
        {
			for (var i:int = 0; i < buildings.length; ++i)
            {
				var b = getBuildingMover(i);
				if (Geometry.doSpheresOverap(x,y,r, b.x,b.y,b.radius))
				{
					return b;
				}
			}
			
			return null;
		}

        public function killObject(object:LoomComponent):void
        {
            if (object && object._owner)
            {
                var k:Killable = object._owner.lookupComponentByName("killable") as Killable;
                if (k) k.dead = true;
            }
        }

        public function loadGameTextures():void
        {

            // load texture atlas
            var atlasName:String = Config.PATH_ASSETS+"game-elements";
            // get atlas data
            var xml:XMLDocument = new XMLDocument();
            if (xml.loadFile(atlasName + ".xml") != 0)
            {
            	trace("failed to load atlas data file for atlas " + atlasName );
            	return;
            }

            atlas = new TextureAtlas(Texture.fromAsset(atlasName + ".png"), xml.rootElement());
            textures = new Dictionary();
            animations = new Dictionary();
        }

        public function getImage(name:String):Image
        {
        	//trace("Getting image '" + name + "'");

        	if (!textures[name])
        	{
        		trace("Extracting image '"+name+"' from atlas...");
        		textures[name] = atlas.getTexture( name );
        	}
        	
        	if (!textures[name])
        	{
        		trace("Failed to extract texture '"+name+"' from atlas.");
        		return null;
        	}

        	return new Image(textures[name] as Texture);
        }

        public function getAnimation(name:String):MovieClip
        {
        	//trace("Getting animation '" + name + "'");

        	if (!animations[name])
        	{
        		trace("Extracting animation '"+name+"' from atlas...");
        		animations[name] = atlas.getTextures( name );
        	}
        	
        	if (!animations[name])
        	{
        		trace("Failed to extract animation '"+name+"' from atlas.");
        		return null;
        	}

        	return new MovieClip(animations[ name ] as Vector.<Texture>, Config.ANIMATION_FRAME_RATE);
        }
    }
}
