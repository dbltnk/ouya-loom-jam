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
		
		public var upKey:int;
		public var leftKey:int;
		public var downKey:int;
		public var rightKey:int;
		public var useKey:int;
		public var attackKey:int;
		
    	public var health:Number = Config.PLAYER_HP;
    	public var healthMax:Number = Config.PLAYER_HP;		

		public var radius:Number = Config.PLAYER_RADIUS;

    	public var x:Number = 0;
    	public var y:Number = 0;

    	public var vX:Number = 0;
    	public var vY:Number = 0;

    	public var lookX:Number = 0;
    	public var lookY:Number = 0;
    	public var lookAngle:Number = 0;

    	public var use:Number = 0;
    	public var attack:Number = 0;

        public var attackCoolDown:Number = 0;
    	public var attackRange:Number = 0;
    	public var useRange:Number = 0;

    	public var speed:Number = 0;
    	
    	public var harvestTimeout:Timeout;

        protected var coolTime:Number = 0;

    	public function PlayerMover(speed:Number,
	    							attackRange:Number,
                                    attackCoolDown:Number,
	    							useRange:Number)
    	{
    		this.speed = speed;
    		this.attackRange = attackRange;
            this.attackCoolDown = attackCoolDown;
    		this.useRange = useRange;
    		
    		harvestTimeout = new Timeout();
    		harvestTimeout.timeout = Config.PLAYER_HARVEST_TIMEOUT;
    	}

    	public function move(dt:Number):void
    	{
    		x += vX * (dt / 1000) * speed;
            y += vY * (dt / 1000) * speed;

            if (!hasCooledDown())
                coolTime -= dt;
                
            executeAttack();
    	}

        public function hasCooledDown():Boolean
        {
            if (coolTime < 0)
                return true;
            return false;
        }

    	public function bindToPad(pad:Gamepad):void
    	{
    		if (this.pad)
    		{
    			unbindPad();
    		}
    		this.pad = pad;
    		// init pad
    		pad.axisEvent += onAxisChange;
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
	           		updateLookAngle();
	           	break;

	           	case 3:
	           		lookY = state;
	           		updateLookAngle();
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

        protected function updateLookAngle():void
        {
        	lookAngle = (lookX == 0 && lookY == 0) ? -1 : Math.atan2(lookY, lookX);
        }

        protected function executeAttack():void
        {
            if (attack > 0.5 && hasCooledDown())
            {
                coolTime = attackCoolDown;
                // if player does not look into a specific direction, attack in direction of walking
                if (lookX == 0 && lookY == 0)
                    OUYAJam.instance.spawnProjectile(this, x, y, vX, vY);
                else
                    OUYAJam.instance.spawnProjectile(this, x, y, lookX, lookY);
            }
        }

    	public function bindToKeys(up:int, left:int, down:int, right:int, attack:int, use:int):void
    	{
			upKey = up;
			leftKey = left;
			downKey = down;
			rightKey = right;
			attackKey = attack;
			useKey = use;
			
    		Loom2D.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
    		Loom2D.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
    	}

    	protected function keyDownHandler(event:KeyboardEvent):void
        {   
            var keycode = event.keyCode;
            if(keycode == upKey)
            	vY = -1;
            if(keycode == downKey)
                vY = 1;
            if(keycode == leftKey)
                vX = -1;
            if(keycode == rightKey)
                vX = 1;
            if(keycode == useKey)
                use = 1;
            if(keycode == attackKey)
                attack = 1;
        }

        protected function keyUpHandler(event:KeyboardEvent):void
        {
        	var keycode = event.keyCode;
        	if(keycode == upKey)
            	vY = 0;
            if(keycode == downKey)
                vY = 0;
            if(keycode == leftKey)
                vX = 0;
            if(keycode == rightKey)
                vX = 0;
            if(keycode == useKey)
                use = 0;
            if(keycode == attackKey)
                attack = 0;
        }
    }
}