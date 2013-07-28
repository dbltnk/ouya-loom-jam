package
{
    import loom2d.Loom2D;
    import cocosdenshion.SimpleAudioEngine;
    import loom.gameframework.LoomComponent;
    import loom.gameframework.LoomGameObject;
    import loom2d.math.Point;

    import system.platform.Gamepad;

    import loom2d.events.KeyboardEvent;
    import loom.platform.LoomKey;
    import system.platform.Platform;

    public class Grid
    {
		private var mapObjKey = new Dictionary();
		private var mapKeyObjs = new Dictionary();
		private var cell:Number = 64;
		
		public function Grid():void
		{
			
		}
		
		protected function visitAreaKeys(x:Number, y:Number, w:Number, h:Number, callback:Function):void
		{
			var dx:int = Math.floor(w/cell);
			var dy:int = Math.floor(h/cell);
			
			for (var ix:int = 0; ix <= dx; ++ix)
			for (var iy:int = 0; iy <= dy; ++iy)
			{
				var k = key(x + cell * ix, y + cell * iy);
				callback(k);
			}
		}
		
		public function visitObjects(x:Number, y:Number, w:Number, h:Number, ignore:LoomGameObject, callback:Function)
		{
			visitAreaKeys(x,y,w,h, function(k:int) {
				if (mapKeyObjs[k])
				{
					var l:Vector.<LoomGameObject> = (mapKeyObjs[k] as Vector.<LoomGameObject>);
					for (var i:int = 0; i <= l.length; ++i)
					{
						var o = l[i];
						if (o && o != ignore) callback(o);
					}
				}
			});
		}
		
		protected function key(x:Number, y:Number):int
		{
			return int(Math.floor(x/cell + 10000 + y/cell));
		}
		
		public function removeObj(o:LoomGameObject):void
		{
			var k = mapObjKey[o];
			if (k)
			{
				if ( mapKeyObjs[k] ) {
					var l:Vector.<LoomGameObject> = mapKeyObjs[k] as Vector.<LoomGameObject>;
					var i = l.indexOf(o);
					if (i >= 0) l.splice(i, 1);
				}
			}
			mapObjKey[o] = null;
		}
		
		public function updateObject(o:LoomGameObject, x:Number, y:Number):void
		{
			removeObj(o);
			addObj(o, key(x,y));
		}
		
		protected function addObj(o:LoomGameObject, k:int)
		{
			if (!mapKeyObjs[k]) mapKeyObjs[k] = new Vector.<LoomGameObject>();
			(mapKeyObjs[k] as Vector.<LoomGameObject>).push(o);
			mapObjKey[o] = k;
		}
    }
}