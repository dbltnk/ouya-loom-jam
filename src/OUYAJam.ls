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

    import system.platform.Gamepad;

    import loom2d.display.MovieClip;
    import loom2d.textures.Texture;
    import loom2d.textures.TextureAtlas;
    import system.xml.XMLDocument;
    import system.xml.XMLError;
    import system.platform.Platform;

    public class OUYAJam extends Application
    {
        private var gamepadsConnected:Boolean = false;

        private var players:Vector.<LoomGameObject>;
        private var lastFrame:Number;
        private var playing:Boolean = false; 

        override public function run():void
        {
            // Comment out this line to turn off automatic scaling.
            stage.scaleMode = StageScaleMode.LETTERBOX;

            // Setup anything else, like UI, or game objects.
            /*var bg = new Image(Texture.fromAsset("assets/background.png"));
            stage.addChild(bg);
            
            middleground = new Image(Texture.fromAsset("assets/middleground.png"));
            stage.addChild(middleground);
            */

            // var sprite = new Image(Texture.fromAsset("assets/sizes.png"));
            // sprite.center();
            // sprite.x = stage.stageWidth / 2;
            // sprite.y = stage.stageHeight / 2 + 50;
            // stage.addChild(sprite);

            
            // TODO load and apply config
            /*
            var path = "assets/player/";
            var atlasName ="mage";
            var aniName = "mage-front-stand";

            var xml:XMLDocument = new XMLDocument();
            if (xml.loadFile(path + atlasName + ".xml") != XMLError.XML_NO_ERROR)
            {
                trace("failed to load atlas data file for atlas " + atlasName );
                return;
            }

            trace(xml.rootElement().firstChild());

            var atlas:TextureAtlas = new TextureAtlas(Texture.fromAsset(path + atlasName + ".png"), xml.rootElement().firstChild());
            trace("creating animation");
            return;
            var anim = new MovieClip(atlas.getTextures(aniName), 24);
            anim.x =stage.stageWidth / 2; 
            anim.y = stage.stageHeight / 2;
            anim.play();
            stage.addChild(anim);
            return;
            */
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
            for (var i=0; i < pads.length; i++)
            {  
                player = spawnPlayer("assets/player/", "mage", "mage-front-stand");
                players.pushSingle(player);
                mover = getPlayerMover(i);
                if (mover)
                    mover.bindToPad(pads[i]);

                trace("Added player " + i);
            }

            if (players.length == 0)
            {
                trace("defaulting to key controls");
                player = spawnPlayer("assets/player/", "mage", "mage-front-stand");
                players.pushSingle(player);
                mover = getPlayerMover(0);
                if (mover)
                    mover.bindToKeys();
            }

            playing = true;


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
            
            //stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            
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
        /*
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

        }*/

        protected function spawnPlayer(path:String, atlasName:String, aniName:String):LoomGameObject 
        {
            var gameObject = new LoomGameObject();
            gameObject.owningGroup = group;
            // create a new mover and bind it to the pad
            var mover = new PlayerMover();
            //mover.bindToPad(pad);
            gameObject.addComponent(mover, "mover");
            // create a new player renderer, bind it to the mover and save in component gameObject
            var renderer = new PlayerRenderer(path, atlasName, aniName);
            renderer.addBinding("x", "@mover.x");
            renderer.addBinding("y", "@mover.y");
            
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