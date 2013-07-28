package 
{

    import loom.gameframework.AnimatedComponent;

    import loom2d.Loom2D;
    import loom2d.display.Image;
    import loom2d.display.MovieClip;
    
    import loom2d.math.Point;

    import loom2d.textures.Texture;
    import loom2d.textures.TextureAtlas;
    import system.xml.XMLDocument;

	public class HeroRenderer extends AnimatedComponent
	{
		protected var image:Image;

		public function HeroRenderer()
		{
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
        }

        public function hitTest(p:Point):Boolean
        {
            if (image && image.hitTest(p))
                return true;
            return false;
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

            image = new Image(Texture.fromAsset("assets/hero.png"));
            image.x = -1000;
            image.y = -1000;
            Loom2D.stage.addChild(image);

            return true;
        }
        /**
         * This is meant to remove the sprite from the main layer.
         */
        protected function onRemove():void
        {
            Loom2D.stage.removeChild(image);

            super.onRemove();
        } 
	}
}