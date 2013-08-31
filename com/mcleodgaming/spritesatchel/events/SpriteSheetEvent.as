package com.mcleodgaming.spritesatchel.events 
{
	import flash.events.Event;
	
	public class SpriteSheetEvent extends Event
	{
		public static const STATUS:String = "status";
		public static const IMPORT_COMPLETE:String = "importComplete";
		public static const EXPORT_COMPLETE:String = "exportComplete";
		
		public var message:String;
		
		public function SpriteSheetEvent(type:String, message:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
			
			this.message = message;
		}
		
	}

}