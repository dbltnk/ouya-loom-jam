package 
{

    import loom.gameframework.AnimatedComponent;

    import loom2d.Loom2D;
    import loom2d.display.Sprite;
    import loom2d.display.Image;
    import loom2d.display.MovieClip;
    import loom2d.textures.Texture;
    import loom2d.textures.TextureAtlas;
    import system.xml.XMLDocument;

	public class PlayerRenderer extends AnimatedComponent
	{
		protected var path:String;
		protected var atlasName:String;
		protected var aniName:String;

		protected var anim:MovieClip;
		
        protected var image:Image;
        protected var lookDirectionIndicator:Sprite;

		public function PlayerRenderer(path:String, atlasName:String, aniName:String)
		{
			if (!path || !atlasName || !aniName)
			{
				return;
			}

			this.path = path;
			this.atlasName = atlasName;
			this.aniName = aniName;
		}

		/**
         * Built in setter to propagate x position value changes for data binding as a component.
         *
         * @param   value:Number    The value to set.
         */
        public function set x(value:Number):void
        {
            if(image)
                image.x = value;

            if (lookDirectionIndicator)
                lookDirectionIndicator.x = value + (image.width / 2);
        }

        /**
         * Built in setter to propagate y position value changes for data binding as a component.
         *
         * @param   value:Number    The value to set.
         */
        public function set y(value:Number):void
        {
            if(image)
                image.y = value;

            if (lookDirectionIndicator)
                lookDirectionIndicator.y = value + (image.height / 2);
        }

        public function set lookAngle(value:Number):void
        {
            if (!lookDirectionIndicator)
                return;
            // hide if value is invalid
            if (value < 0)
            {
                lookDirectionIndicator.visible = false;
            }
            else
            {
                lookDirectionIndicator.rotation = value;
                if (!lookDirectionIndicator.visible)
                    lookDirectionIndicator.visible = true;
            }
        }

		/**
         * Executed when this renderer is added. It create a sprites and sets the correct texture for it.
         *
         * @return  Boolean Returns true if the sprite was successfully added to the sprite batch.
         */
        protected function onAdd():Boolean
        {
            if(!super.onAdd())
                return false;

            var img:Image = new Image(Texture.fromAsset("assets/player/look-direction.png"));
            lookDirectionIndicator = new Sprite();
            lookDirectionIndicator.addChild(img);
            lookDirectionIndicator.center();
            lookDirectionIndicator.visible = false;
            Loom2D.stage.addChild(lookDirectionIndicator);


            image = new Image(Texture.fromAsset("assets/player.png"));
            image.x = -1000;
            image.y = -1000;
            Loom2D.stage.addChild(image);

            // var xml:XMLDocument = new XMLDocument();
            // if (xml.loadFile(path + atlasName + ".xml") != 0)
            // {
            // 	trace("failed to load atlas data file for atlas " + atlasName );
            // 	return false;
            // }

            // trace(xml.print())

            // var atlas:TextureAtlas = new TextureAtlas(Texture.fromAsset(path + atlasName + ".png"), xml.firstChild());
            
            // anim = new MovieClip(atlas.getTextures(aniName), 24);
            // anim.x = Loom2D.stage.stageWidth / 2; 
            // anim.y = Loom2D.stage.stageHeight / 2;
            // anim.play();
            // Loom2D.stage.addChild(anim);

            return true;
        }
        /**
         * This is meant to remove the sprite from the main layer.
         */
        protected function onRemove():void
        {
            Loom2D.stage.removeChild(anim);

            super.onRemove();
        } 
	}
}