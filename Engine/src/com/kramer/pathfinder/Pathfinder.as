package com.kramer.pathfinder
{
	import flash.geom.Point;

	public class Pathfinder
	{
		private static var _nodeMatrix:NodeMatrix;
		
		public function Pathfinder()
		{
		}
		
		initialize();
		
		private static function initialize():void
		{
			_nodeMatrix = new NodeMatrix();
			_nodeMatrix.heuristic = new ManhattanHeuristic();
		}
		
		public static function findPath(map:IPathFindableMap, start:Point, target:Point):Vector.<Point>
		{
			_nodeMatrix.setData(map.getPathData());
			if(_nodeMatrix.isValid(start.x, start.y) == false
				|| _nodeMatrix.isValid(target.x, target.y) == false)
			{
				return new Vector.<Point>();
			}
			_nodeMatrix.start = start;
			_nodeMatrix.target = target;
			return optimizePath(_nodeMatrix.findPath());
		}
		
		private static function optimizePath(path:Vector.<Node>):Vector.<Point>
		{
			var result:Vector.<Point> = new Vector.<Point>();
			var du:int = int.MAX_VALUE;
			var dv:int = int.MAX_VALUE;
			var len:int = path.length;
			for(var i:int = 1; i < len; i++)
			{
				var newDu:int = path[i].u - path[i - 1].u;
				var newDv:int = path[i].v - path[i - 1].v;
				if(newDu != du || newDv != dv)
				{
					du = newDu;
					dv = newDv;
					result.push(new Point(path[i - 1].u, path[i - 1].v));
				}
			}
			result.push(new Point(path[len - 1].u, path[len - 1].v));
			return result;
		}
		
		public static function setHeuristic(value:IHeuristic):void
		{
			_nodeMatrix.heuristic = value;
		}
	}
}