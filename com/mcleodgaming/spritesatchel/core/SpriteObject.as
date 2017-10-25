package com.mcleodgaming.spritesatchel.core 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	public class SpriteObject 
	{
		public var rect:Rectangle;
		public var registration:Point;
		public var imageIndex:int;
		public var sheetIndex:int;
		
		public function SpriteObject(imageIndex:int, rect:Rectangle, registration:Point, sheetIndex:int) 
		{
			this.rect = rect;
			this.registration = registration;
			this.imageIndex = imageIndex;
			this.sheetIndex = sheetIndex;
		}
		
		public function clone():SpriteObject
		{
			return new SpriteObject(imageIndex, rect.clone(), registration.clone(), sheetIndex);
		}
	}

}