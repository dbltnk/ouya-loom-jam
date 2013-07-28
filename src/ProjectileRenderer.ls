package
{
    import loom2d.Loom2D;
	import loom2d.display.Image;
    import loom.gameframework.AnimatedComponent;

	public class ProjectileRenderer extends AnimatedComponent
	{
		protected var image:Image;
		protected var hW:Number;
		protected var hH:Number;

		/**
         * Built in setter to propagate x position value changes for data binding as a component.
         *
         * @param   value:Number    The value to set.
         */
        public function set x(value:Number):void
        {
            if(image)
                image.x = value - hW;
        }

        /**
         * Built in setter to propagate y position value changes for data binding as a component.
         *
         * @param   value:Number    The value to set.
         */
        public function set y(value:Number):void
        {
            if(image)
                image.y = value - hH;
        }

        protected function onAdd():Boolean
        {
            if(!super.onAdd())
                return false;

            image = OUYAJam.instance.getImage("projectile");
            image.x = -1000;
            image.y = -1000;
            Loom2D.stage.addChild(image);

            hH = image.height / 2;
            hW = image.width / 2;
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