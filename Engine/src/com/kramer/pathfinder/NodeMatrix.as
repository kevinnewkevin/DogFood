package com.kramer.pathfinder
{
	import com.kramer.debug.Debug;
	import com.kramer.pool.ObjectPool;
	import com.kramer.trove.HashMap;
	
	import flash.geom.Point;

	internal class NodeMatrix
	{
		public static const WLAKABLE:int 	= 0;
		public static const BLOCK:int 		= 1;
		
		private static const STEP_WEIGHT:Array 	= [1, 1, 1, 1];
		private static const MOVE_STEP:Array 	= [[-1, 0], [1, 0], [0, -1], [0, 1]];
		
		private var _data:Vector.<Vector.<int>>;
		private var _width:int;
		private var _height:int;
		
		private var _openedNodeVec:Vector.<Node>;
		private var _nodeMap:HashMap;
		private var _nodePool:ObjectPool;
		
		private var _startNode:Node;
		private var _targetNode:Node;
		private var _heuristic:IHeuristic;
		
		public function NodeMatrix()
		{
			initialize();
		}
		
		private function initialize():void
		{
			_nodeMap = new HashMap();
			_nodePool = new ObjectPool(Node);
		}
		
		public function setData(data:Vector.<Vector.<int>>):void
		{
			_data = data;
			_width = _data[0].length;
			_height = _data.length;
			reset();
		}
		
		public function set start(value:Point):void
		{
			_startNode = getNode(value.x, value.y);
			Debug.assert(_startNode != null, "invalid start point");
			_openedNodeVec.push(_startNode);
		}
		
		public function set target(value:Point):void
		{
			_targetNode = getNode(value.x, value.y);
			Debug.assert(_targetNode != null, "invalid target point");
		}
		
		public function set heuristic(value:IHeuristic):void
		{
			_heuristic = value;
		}
		
		private function getNodeAdjacent(currentNode:Node):Vector.<Node>
		{
			var result:Vector.<Node> = new Vector.<Node>();
			var len:int = MOVE_STEP.length;
			for(var i:int = 0; i < len; i++)
			{
				var u:int = currentNode.u + MOVE_STEP[i][0];
				var v:int = currentNode.v + MOVE_STEP[i][1];
				var node:Node = getNode(u, v);
				if(node == null || node.isVisited == true)
				{
					continue;
				}
				var g:Number = currentNode.g + STEP_WEIGHT[i];
				if(node.g == 0 || node.g > g)
				{
					//remove node if has been added to the openNodeVec
					//then will add it to the head of openNodeVec later
					removeNodeFromOpenVec(node); 
					node.g = g;
					node.h = _heuristic.evaluate(node, _targetNode);
					node.parent = currentNode;
					result.push(node);
				}
			}
			return result;
		}
		
		private function removeNodeFromOpenVec(node:Node):void
		{
			var index:int = _openedNodeVec.indexOf(node);
			if(index > -1)
			{
				_openedNodeVec.splice(index, 1);
			}
		}
		
		private function addNodeToOpenVec(node:Node):void
		{
			_openedNodeVec.push(node);
		}
		
		private function getNode(u:int, v:int):Node
		{
			if(isValid(u, v) == false)
			{
				return null;
			}
			var key:String = u + "_" + v;
			if(_nodeMap.containsKey(key) == false)
			{
				var node:Node = _nodePool.getObject() as Node;
				node.u = u;
				node.v = v;
				_nodeMap.put(key, node);
			}
			return _nodeMap.get(key);
		}
		
		public function isValid(u:int, v:int):Boolean
		{
			if(u < 0 || v < 0 || u > (_width - 1) || v > (_height - 1))
			{
				return false;
			}
			if(_data[v][u] == BLOCK)
			{
				return false;
			}
			return true;
		}
		
		public function findPath():Vector.<Point>
		{
			var result:Vector.<Point> = new Vector.<Point>();
			while(_openedNodeVec.length > 0)
			{
				var node:Node = _openedNodeVec.pop();
				node.isVisited = true;
				if(node == _targetNode)
				{
					result = constructPath(node);
					break;
				}
				var adjacentNodeVec:Vector.<Node> = getNodeAdjacent(node);
				adjacentNodeVec.sort(sortFunction);
				for each(var adjacentNode:Node in adjacentNodeVec)
				{
					addNodeToOpenVec(adjacentNode);
				}
			}
			return result;
		}
		
		private function constructPath(node:Node):Vector.<Point>
		{
			var result:Vector.<Point> = new Vector.<Point>();
			while(node != null)
			{
				var point:Point = new Point(node.u, node.v);
				result.unshift(point);
				node = node.parent;
			}
			return result;
		}
		
		private function sortFunction(a:Node, b:Node):int
		{
			if(a.f < b.f)
			{
				return 1;
			}
			if(a.f > b.f)
			{
				return -1;
			}
			return 0;
		}
		
		private function reset():void
		{
			var nodeArr:Array = _nodeMap.getValues();
			for each(var node:Node in nodeArr)
			{
				_nodePool.recycle(node);
			}
			_nodeMap.clear();
			_openedNodeVec = new Vector.<Node>();
		}
		
	}
}