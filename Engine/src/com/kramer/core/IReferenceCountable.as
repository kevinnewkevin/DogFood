package com.kramer.core
{
	public interface IReferenceCountable
	{
		function set referenceCount(value:int):void;
		function get referenceCount():int;
	}
}