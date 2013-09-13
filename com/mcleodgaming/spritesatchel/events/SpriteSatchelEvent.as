package com.mcleodgaming.spritesatchel.events 
{
	import flash.events.Event;
	
	public class SpriteSatchelEvent extends Event
	{
		public static const STATUS:String = "status";
		public static const IMPORT_COMPLETE:String = "importComplete";
		public static const EXPORT_COMPLETE:String = "exportComplete";
		public static const FILE_CHANGED:String = "fileChanged";
		
		public var message:String;
		
		public function SpriteSatchelEvent(type:String, message:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			super(type, bubbles, cancelable);
			
			this.message = message;
		}
		
	}

}