package 
{

    import loom.gameframework.AnimatedComponent;

    import loom2d.Loom2D;
    import loom2d.display.Sprite;
    import loom2d.display.Image;
    import loom2d.display.MovieClip;
    import system.xml.XMLDocument;

	public class PlayerRenderer extends AnimatedComponent
	{
        protected var anims:Dictionary;

		protected var currentAnim:MovieClip;
        protected var currentState:int = PlayerState.STAND;
        protected var currentDirection:int = PlayerDirection.RIGHT;

		
        protected var lookDirectionIndicator:Sprite;

        protected var aniName:String;

		public function PlayerRenderer(aniName:String)
		{
			if (!aniName)
                return;

            this.aniName = aniName;
		}

		/**
         * Built in setter to propagate x position value changes for data binding as a component.
         *
         * @param   value:Number    The value to set.
         */
        public function set x(value:Number):void
        {
            if (!currentAnim)
                return;

            currentAnim.x = value;

            if (lookDirectionIndicator)
                lookDirectionIndicator.x = value + (currentAnim.width / 2);
        }

        /**
         * Built in setter to propagate y position value changes for data binding as a component.
         *
         * @param   value:Number    The value to set.
         */
        public function set y(value:Number):void
        {
            if(!currentAnim)
                return;

            currentAnim.y = value;

            if (lookDirectionIndicator)
                lookDirectionIndicator.y = value + (currentAnim.height / 2);
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

        public function set state(value:int):void
        {
            if (value != currentState)
                setAnimation(value, currentDirection);
        }
        public function set direction(value:int):void
        {   
            if (value != currentDirection)
                setAnimation(currentState, value);
        }

        protected function setAnimation(state:int, direction:int):void
        {
            var str:String = aniName;
            switch (direction)
            {
                case PlayerDirection.LEFT:
                    str += "-left"
                    break;
                case PlayerDirection.RIGHT:
                    str += "-right"
                    break;
            }
            switch (state)
            {
                case PlayerState.STAND:
                    str += "-stand"
                    break;
                case PlayerState.WALK:
                    str += "-walk"
                    break;
            }
            // set new animation
            if (anims && anims[str])
            {
                var anim:MovieClip = anims[str] as MovieClip;
                
                if (anim == currentAnim)
                    return;

                if (currentAnim)
                {
                    anim.x = currentAnim.x;
                    anim.y = currentAnim.y;
                    currentAnim.visible = false;
                    currentAnim.stop();
                }
                trace("set new anim: " + str);
                anim.play();
                anim.visible = true;
                currentAnim = anim;

                currentState = state;
                currentDirection = direction;
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

            var img:Image = OUYAJam.instance.getImage( "look-direction" );
            if (img)
            {
                lookDirectionIndicator = new Sprite();
                lookDirectionIndicator.addChild(img);
                lookDirectionIndicator.center();
                lookDirectionIndicator.visible = false;
                Loom2D.stage.addChild(lookDirectionIndicator);
            }

            anims = new Dictionary();
            
            addAnim(aniName + "-right-stand");
            addAnim(aniName + "-right-walk");
            addAnim(aniName + "-left-stand");
            addAnim(aniName + "-left-walk");

            setAnimation(currentState, currentDirection);

            return true;
        }
        
        protected function addAnim(name:String):void
        {
            
            var anim:MovieClip = OUYAJam.instance.getAnimation( name );
            if (anim)
            {
                anims[name] = anim;
                anim.x = -1000;
                anim.y = -1000; 
                anim.visible = false;
                anim.stop();
                Loom2D.juggler.add(anim);
                Loom2D.stage.addChild(anim);
            }
        }
        /**
         * This is meant to remove the sprite from the main layer.
         */
        protected function onRemove():void
        {
            currentAnim = null;

            var anim:MovieClip;
            for (var i in anims)
            {
                anim = anims[i] as MovieClip;
                if (anim)
                {
                    Loom2D.stage.removeChild(anim);
                    Loom2D.juggler.remove(anim);
                    anim.stop();
                }
                anims[i] = null;
            }

            Loom2D.stage.removeChild(lookDirectionIndicator);

            super.onRemove();
        } 
	}
}
