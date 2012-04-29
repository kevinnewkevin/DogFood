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
			return _nodeMatrix.findPath();
		}
		
		public static function setHeuristic(value:IHeuristic):void
		{
			_nodeMatrix.heuristic = value;
		}
	}
}