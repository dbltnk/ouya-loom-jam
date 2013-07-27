package
{
	import loom2d.math.Point;
	    
    public class Geometry
    {
    	public static function doSpheresOverap(ax:Number, ay:Number, ar:Number, bx:Number, by:Number, br:Number):Boolean
        {
			var dbax = ax-bx;
			var dbay = ay-by;
			var l = Math.sqrt(dbax*dbax+dbay*dbay);
            var overlap = l - ar - br;
            return overlap < 0;
        }
        
        public static function resolveAOverlapB(ax:Number, ay:Number, ar:Number, bx:Number, by:Number, br:Number):Point
        {
			var dbax = ax-bx;
			var dbay = ay-by;
			var l = Math.sqrt(dbax*dbax+dbay*dbay);
            var overlap = l - ar - br;

            if (overlap >= 0) return new Point(0,0);
            
			overlap *= -0.25;

			return new Point(dbax*overlap, dbay*overlap);
		}
    }
}
