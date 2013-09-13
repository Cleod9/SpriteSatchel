package com.mcleodgaming.spritesatchel.events 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class EventManager
	{
		public static var dispatcher:EventManager = new EventManager();
		
		private var _eventDispatcher:EventDispatcher;
		
		private var _eventList:Vector.<String>;
		private var _functionList:Vector.<Function>;
		private var _useCaptureList:Vector.<Boolean>;

		public function EventManager()
		{
			_eventDispatcher = new EventDispatcher();
			
			_eventList = new Vector.<String>();
			_functionList = new Vector.<Function>();
			_useCaptureList = new Vector.<Boolean>();
		}
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			//Keep track of added events (We don't care how many, this is just for record-keeping purposes
			_eventList.push(type);
			_functionList.push(listener);
			_useCaptureList.push(useCapture);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			for (var i:int = 0; i < _eventList.length; i++)
			{
				if (type == _eventList[i] && listener == _functionList[i] && hasEvent(type, listener))
				{
					_eventList.splice(i, 1);
					_functionList.splice(i, 1);
					_useCaptureList.splice(i, 1);
					_eventDispatcher.removeEventListener(type, listener, useCapture);
					i--;
				}
			}
			
			//Remove added events? (Technically not necessary, but cannot be implemented until we know how events are stacked in Flash)
		}
		public function dispatchEvent(event:Event):void
		{
			_eventDispatcher.dispatchEvent(event);
		}
		public function hasEvent(type:String, listener:Function):Boolean
		{
			for (var i:int = 0; i < _eventList.length; i++)
				if (type == _eventList[i] && listener == _functionList[i])
					return true;
					
			return false;
		}
		public function removeAllEvents():void
		{
			//Remove all events
			while (Count > 0)
			{
				removeEventListener(_eventList[0], _functionList[0], _useCaptureList[0]);
				_eventList.splice(0, 1);
				_functionList.splice(0, 1);
				_useCaptureList.splice(0, 1);
			}
		}
		
		public function get Count():int
		{
			return _eventList.length;
		}
	}

}