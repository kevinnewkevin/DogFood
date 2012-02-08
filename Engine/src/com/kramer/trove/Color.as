package com.kramer.trove
{
	public class Color
	{
		private var _r:uint;
		private var _g:uint;
		private var _b:uint;
		private var _a:uint;
		
		private var _argb:uint;
		private var _rgb:uint;
		
		public function Color(r:uint, g:uint, b:uint, a:uint = 0xFF)
		{
			this.red = r;
			this.green = g;
			this.blue = b;
			this.alpha = a;
		}
		
		public function set red(value:uint):void
		{
			checkParameter(value);
			_r = value;
		}
		
		public function get red():uint
		{
			return _r;
		}
		
		public function set green(value:uint):void
		{
			checkParameter(value);
			_g = value;
		}
		
		public function get green():uint
		{
			return _g;
		}
		
		public function set blue(value:uint):void
		{
			checkParameter(value);
			_b = value;
		}
		
		public function get blue():uint
		{
			return _b;
		}

		public function set alpha(value:uint):void
		{
			checkParameter(value);
			_a = value;
		}
		
		public function get alpha():uint
		{
			return _a;
		}
		
		private function checkParameter(value:uint):void
		{
			if(value < 0 || value > 0xff )
			{
				throw new ArgumentError("颜色的分量值必须为0～255");
			}
		}
		
		public function get argb():uint
		{
			return (_a << 24) | (_r << 16) | (_g << 8) | _b;
		}
		
		public function get rgb():uint
		{
			return (_r << 16) | (_g << 8) | _b;
		}
		
		public function toString():String
		{
			var rStr:String = _r > 0xF ? _r.toString(16) : "0" + _r.toString(16);
			var gStr:String = _g > 0xF ? _g.toString(16) : "0" + _g.toString(16);
			var bStr:String = _b > 0xF ? _b.toString(16) : "0" + _b.toString(16);
			return rStr + gStr + bStr
		}
		
		public function clone():Color
		{
			return new Color(_r, _g, _b, _a);
		}
		
		public static function parseColorFromNumber(value:uint):Color
		{
			var a:uint = value & 0xFF000000;
			a = a > 0 ? a : 0xFF;
			var r:uint = (value & 0x00FF0000) >> 16;
			var g:uint = (value & 0x0000FF00) >> 8;
			var b:uint = value & 0x000000FF;
			return new Color(r, g, b, a);
		}
		
		public static function parseColorFromString(value:String):Color
		{
			if(value.indexOf("#") == 0)
			{
				value = value.substr(1);
			}
			var num:uint = parseInt(value, 16);
			if(isNaN(num) == true)
			{
				throw new ArgumentError("参数不能解析为数字");
			}
			return parseColorFromNumber(num);
		}
	}
}