package
{

    import loom.gameframework.LoomComponent;

	public class ProjectileMover extends LoomComponent
	{
		public var x:Number = 0;
		public var y:Number = 0;

		public var vX:Number = 0;
		public var vY:Number = 0;

		public var speed:Number = 0;

		public function ProjectileMover(x:Number, y:Number, vX:Number, vY:Number, speed:Number)
		{
			this.x = x;
			this.y = y;

			this.vX = vX;
			this.vY = vY;
			
			this.speed = speed;

			var l:Number = Math.sqrt(vX * vX + vY * vY);
			this.vX /= l;
			this.vY /= l;
		}

		public function move(dt:Number):void
    	{
    		x += vX * (dt / 1000) * speed;
            y += vY * (dt / 1000) * speed;
    	}
	}
}