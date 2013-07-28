package
{
	import loom2d.display.Image;
	import loom2d.textures.Texture;
    import loom.gameframework.AnimatedComponent;

	public class ProjectileRenderer extends AnimatedComponent
	{
		protected var image:Image;

		public function ProjectileRenderer()
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

        protected function onAdd():Boolean
        {
            if(!super.onAdd())
                return false;

            image = new Image(Texture.fromAsset())
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