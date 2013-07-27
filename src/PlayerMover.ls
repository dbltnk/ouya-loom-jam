package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;

    import system.platform.Gamepad;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;

    public class PlayerMover extends LoomComponent
    {

		protected var pad:Gamepad;

    	public var x:Number = 0;
    	public var y:Number = 0;

    	public var vX:Number = 0;
    	public var vY:Number = 0;

    	public var lookX:Number = 0;
    	public var lookY:Number = 0;

    	public var attack:Number = 0;
    	public var use:Number = 0;

    	public var attackRange:Number = 0;
    	public var useRange:Number = 0;

    	public var speed:Number = 0;

    	public function PlayerMover(speed:Number,
	    							attackRange:Number,
	    							useRange:Number)
    	{
    		this.speed = speed;
    		this.attackRange = attackRange;
    		this.useRange = useRange;
    	}

    	public function bindToPad(pad:Gamepad):void
    	{
    		if (this.pad)
    		{
    			unbindPad();
    		}
    		this.pad = pad;
    		trace(pad);
    		pad.axisEvent += onAxisChange;
    	}

    	public function move(dt:Number):void
    	{
    		x += vX * (dt / 1000) * speed;
            y += vY * (dt / 1000) * speed;
    	}

    	protected function unbindPad():void
    	{
    		if (pad)
    			pad.axisEvent -= onAxisChange;
    		pad = null;
    	}
    	protected function onAxisChange(axis:int, state:float):void {
			//trace("onAxisChange: " + axis + " state: " + state);
			switch( axis )
            {
	           	case 0:
	           		vX = state;
	           	break;

	           	case 1:
	           		vY = state;
	           	break;

	           	case 2:
	           		lookX = state;
	           	break;

	           	case 3:
	           		lookY = state;
	           	break;

	           	case 4:
	           		use = state;
	           	break;

	           	case 5:
	           		attack = state;
	           	break;

	           	default:
	           		trace("unknown axis " + axis);
	           	break;
	        }                   
        }

    	public function bindToKeys():void
    	{
    		Loom2D.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
    		Loom2D.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
    	}

    	protected function keyDownHandler(event:KeyboardEvent):void
        {   
            var keycode = event.keyCode;
            if(keycode == LoomKey.W)
            	vY = -1;
            if(keycode == LoomKey.S)
                vY = 1;
            if(keycode == LoomKey.A)
                vX = -1;
            if(keycode == LoomKey.D)
                vX = 1;

        }

        protected function keyUpHandler(event:KeyboardEvent):void
        {
        	var keycode = event.keyCode;
        	if(keycode == LoomKey.W)
            	vY = 0;
            if(keycode == LoomKey.S)
                vY = 0;
            if(keycode == LoomKey.A)
                vX = 0;
            if(keycode == LoomKey.D)
                vX = 0;
        }
    }
}