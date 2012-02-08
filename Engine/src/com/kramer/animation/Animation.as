package com.kramer.animation
{
	import com.kramer.core.IDisposable;
	import com.kramer.frameSheet.Frame;
	import com.kramer.frameSheet.FrameLabel;
	import com.kramer.frameSheet.FrameSheet;
	import com.kramer.resource.ResourceManager;
	import com.kramer.resource.events.ResourceEvent;
	import com.kramer.trove.HashMap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	[Event(name="init", type = "flash.events.Event")]
	public class Animation extends Bitmap implements IAnimation, IDisposable
	{
		private var _resourceUrl:String;
		private var _frameSheet:FrameSheet;
		private var _frameLabelMap:HashMap;
		private var _currentFrameNum:int = 1;
		private var _totalFramesNum:int;
		private var _startFrameNum:int;
		private var _endFrameNum:int;
		private var _currentFrame:Frame;
		private var _delay:int;
		private var _lastUpdateTime:int;
		private var _isPlaying:Boolean = false;
		private var _isDirty:Boolean = false;
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		
		public function Animation()
		{
			super(null, "auto", true);
		}
		
		public function set resourceUrl(value:String):void
		{
			_resourceUrl = value;
			ResourceManager.loadFrameSheet(_resourceUrl, onLoaded);
		}
		
		public function get resourceUrl():String
		{
			return _resourceUrl;
		}
		
		private function onLoaded(evt:ResourceEvent):void
		{
			_frameSheet = evt.content as FrameSheet;
			initialize();
			dispatchInitEvent();
		}
		
		private function initialize():void
		{
			_isDirty = true;
			_isPlaying = true;
			_totalFramesNum = _frameSheet.totalFrameNum;
			_frameLabelMap = _frameSheet.frameLabelMap;
			_startFrameNum = 1;
			_endFrameNum = _totalFramesNum;
		}
		
		private function dispatchInitEvent():void
		{
			if(hasEventListener(Event.INIT))
			{
				dispatchEvent(new Event(Event.INIT));
			}
		}
		
		public function get totalFrameNum():int
		{
			return _totalFramesNum;
		}
		
		public function get currentFrameNum():int
		{
			return _currentFrameNum;
		}
		
		public function get currentFrame():Frame
		{
			return _currentFrame = _frameSheet.getFrame(_currentFrameNum);
		}
		
		public function get currentLabel():String
		{
			var frameLabelArr:Array = _frameLabelMap.getValues();
			for each(var frameLabel:FrameLabel in frameLabelArr)
			{
				if(_currentFrameNum >= frameLabel.startNum && _currentFrameNum <= frameLabel.endNum)
				{
					return frameLabel.name;
				}
			}
			return null;
		}
		
		public function get frameLabelMap():HashMap
		{
			return _frameLabelMap;
		}
		
		public function play():void
		{
			_isPlaying = true;
		}
		
		public function stop():void
		{
			_isPlaying = false;
		}
		
		public function gotoAndPlay(frame:Object):void
		{
			if(frame is int)
			{
				validateFrameNum(frame as int);
				_currentFrameNum = frame as int;
			}
			else if(frame is String)
			{
				_currentFrameNum = getFrameNumByLabel(frame as String);
			}
			else
			{
				throw new ArgumentError("frame should be int or string");
			}
			_isPlaying = true;
		}
		
		public function gotoAndStop(frame:Object):void
		{
			if(frame is int)
			{
				validateFrameNum(frame as int);
				_currentFrameNum = frame as int;
			}
			else if(frame is String)
			{
				_currentFrameNum = getFrameNumByLabel(frame as String);
			}
			else
			{
				throw new ArgumentError("frame should be int or string");
			}
			_isPlaying = false;
		}
		
		public function setLoopRange(startNum:int, endNum:int):void
		{
			validateFrameNum(startNum);
			validateFrameNum(endNum);
			_startFrameNum = startNum;
			_endFrameNum = endNum;
		}
		
		private function validateFrameNum(frameNum:int):void
		{
			if(frameNum <= 0 || frameNum > _totalFramesNum)
			{
				throw new ArgumentError("frameNum out of range");
			}
		}
		
		private function getFrameNumByLabel(label:String):int
		{
			var frameLabel:FrameLabel = _frameLabelMap.get(label);
			if(frameLabel != null)
			{
				return frameLabel.startNum;
			}
			return 1;
		}
		
		public function set delay(value:int):void
		{
			_delay = value;
		}
		
		public function get delay():int
		{
			return _delay;
		}
		
		public function step(currentTime:int):void
		{
			if((currentTime - _lastUpdateTime) < _delay)
			{
				return;
			}
			_lastUpdateTime = currentTime;
			if(_isDirty == true)
			{
				_currentFrame = _frameSheet.getFrame(_currentFrameNum);
				if(this.bitmapData != _currentFrame.content)
				{
					this.bitmapData = _currentFrame.content;
					updatePosition();
				}
			}
			if(_isPlaying == true)
			{
				advanceFrameNum();
				_isDirty = true;
			}
		}
		
		private function advanceFrameNum():void
		{
			_currentFrameNum += 1;
			if(_currentFrameNum > _endFrameNum)
			{
				_currentFrameNum = _startFrameNum;
			}
		}
		
		override public function set x(value:Number):void
		{
			_x = value;
		}
		
		override public function get x():Number
		{
			return _x;
		}
		
		override public function set y(value:Number):void
		{
			_y = value;
		}
		
		override public function get y():Number
		{
			return _y;
		}
		
		override public function set scaleX(value:Number):void
		{
			_scaleX = value;
			super.scaleX = _scaleX;
		}
		
		override public function get scaleX():Number
		{
			return _scaleX;
		}
		
		override public function set scaleY(value:Number):void
		{
			_scaleY = value;
			super.scaleY = _scaleY;
		}
		
		override public function get scaleY():Number
		{
			return _scaleY;
		}
		
		private function updatePosition():void
		{
			var anchor:Point = _currentFrame.anchor;
			var frameContentOffset:Point = _currentFrame.contentOffset;
			super.x = _x - (anchor.x - frameContentOffset.x) * _scaleX;
			super.y = _y - (anchor.y - frameContentOffset.y) * _scaleY;
		}
		
		public function dispose():void
		{
			_currentFrame = null;
			_frameLabelMap = null;
			_frameSheet = null;
		}
	}
}