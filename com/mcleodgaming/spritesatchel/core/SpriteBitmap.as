package com.mcleodgaming.spritesatchel.core 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class SpriteBitmap 
	{
		public var bitmapData:BitmapData;
		public var currentPoint:Point;
		public var currentMaxHeight:int;
		public var previousWidth:int;
		public var rowStart:Boolean; //For the first MC of any row, we assume we don't need to check for space in the spritesheet
		
		public function SpriteBitmap() 
		{
			bitmapData = new BitmapData(128, 128, true, SpriteSheet.TRANS_COLOR);
			currentPoint = new Point();
			currentMaxHeight = 0;
			previousWidth = 0;
			rowStart = true;
		}
		
		public function dispose():void
		{
			if (bitmapData)
			{
				bitmapData.dispose();
				bitmapData = null;
			}
		}
		
	}

}