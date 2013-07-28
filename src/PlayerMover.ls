package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;
	import loom2d.math.Point;
	
	import loom.gameframework.LoomGameObject;

    import system.platform.Gamepad;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;


    enum PlayerState {
        STAND = 0,
        WALK
    }
    enum PlayerDirection {
        RIGHT = 0,
        LEFT
    }

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
        public var attackDamage:Number = 0;
    	public var attackRange:Number = 0;
    	public var useRange:Number = 0;

    	public var speed:Number = 0;
        public var state:int = 0;
        public var direction:int = 0;
    	
    	public var harvestTimeout:Timeout;

        protected var coolTime:Number = 0;


    	public function PlayerMover(speed:Number,
                                    attackDamage:Number,
	    							attackRange:Number,
                                    attackCoolDown:Number,
	    							useRange:Number)
    	{
    		this.speed = speed;
            this.attackDamage = attackDamage;
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

            state = (vX == 0 && vY == 0) ? PlayerState.STAND : PlayerState.WALK;
            direction = (vX < 0) ? PlayerDirection.LEFT : PlayerDirection.RIGHT;



			// collision?
            OUYAJam.instance.grid.visitObjects(x-2*radius,y-radius,4*radius,4*radius, _owner, function (o:LoomGameObject):void{
				var b:BuildingMover = o.lookupComponentByName("mover") as BuildingMover;
				if (b && b.isSolid() && Geometry.doSpheresOverap(x,y,radius, b.x,b.y,b.radius))
				{
					var p = Geometry.resolveAOverlapB(x,y,radius, b.x,b.y,b.radius);
					x += p.x;
					y += p.y;
				}
			});
			
            if (!hasCooledDown())
                coolTime -= dt;
                
            executeAttack();
            executeUse();
            
            OUYAJam.instance.grid.updateObject(_owner, x, y);
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

		protected function executeUse():void
		{
			if (use > 0.5)
			{
				trace("use");
				var b = OUYAJam.instance.findBuildingInRange(x,y,radius);
				if (b)
				if (harvestTimeout.tryToActivate())
				{
					trace("use found");
					var a = Math.min(b.resources, Config.PLAYER_HARVEST_AMOUNT);
					if (a > 0) { b.resources -= a; OUYAJam.instance.village.resources += a; }
					a = Math.min(b.food, Config.PLAYER_HARVEST_AMOUNT);
					if (a > 0) { b.food -= a; OUYAJam.instance.village.food += a; }
					trace("VILLAGE", "food", OUYAJam.instance.village.food, "resources", OUYAJam.instance.village.resources);
				}
			}
		}

        protected function executeAttack():void
        {
            if (attack > 0.5 && hasCooledDown())
            {
				OUYAJam.instance.playEffect("char_action_hit_");
				
                coolTime = attackCoolDown;
                // if player does not look into a specific direction, attack in direction of walking
                if (lookX == 0 && lookY == 0)
                    OUYAJam.instance.spawnProjectile(this, x + radius, y + radius, vX, vY, attackDamage, attackRange);
                else
                    OUYAJam.instance.spawnProjectile(this, x + radius, y + radius, lookX, lookY, attackDamage, attackRange);
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