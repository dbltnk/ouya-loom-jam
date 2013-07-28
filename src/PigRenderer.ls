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

	public class PigRenderer extends AnimatedComponent
	{
		protected var animName:String;

		protected var anim:MovieClip;
		
		public function PigRenderer(animName:String)
		{
			if (!animName)
			{
				return;
			}
			this.animName = animName;
		}

		/**
         * Built in setter to propagate x position value changes for data binding as a component.
         *
         * @param   value:Number    The value to set.
         */
        public function set x(value:Number):void
        {
            if(anim)
                anim.x = value;
        }

        /**
         * Built in setter to propagate y position value changes for data binding as a component.
         *
         * @param   value:Number    The value to set.
         */
        public function set y(value:Number):void
        {
            if(anim)
                anim.y = value;
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

            anim = OUYAJam.instance.getAnimation( animName );
            anim.x = -1000;
            anim.y = -1000; 
            Loom2D.juggler.add(anim);
            Loom2D.stage.addChild(anim);

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