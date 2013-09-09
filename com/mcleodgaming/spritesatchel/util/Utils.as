package  com.mcleodgaming.spritesatchel.util
{
   import com.mcleodgaming.spritesatchel.core.SpriteSheet;
   import flash.display.DisplayObject;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import flash.geom.Matrix;
   
	public class Utils
	{
		public static function getLibraryItem(contexts:Array, linkage:String):Class
		{
			for (var i:int = 0; i < contexts.length; i++)
				if (contexts[i].loaderInfo.applicationDomain.hasDefinition(linkage))
					return contexts[i].loaderInfo.applicationDomain.getDefinition(linkage) as Class;
			return null;
		}
		public static function removeActionScript(target:MovieClip):void
		{
			for (var i:int = 0; i < target.totalFrames; i++)
			{
				target.addFrameScript(i, null);
			}
		}
		public static function getVisibleBounds(source:DisplayObject, targetCoordinateSpace:DisplayObject):Rectangle
		{ 
			//var a:Rectangle = source.getBounds(targetCoordinateSpace);
			//a.x = 0;
			//a.y = 0;
				//return a;
			//Based on: http://snipplr.com/view/63449/
			var matrix:Matrix = new Matrix()
			matrix.tx = -source.getBounds(targetCoordinateSpace).x;
			matrix.ty = -source.getBounds(targetCoordinateSpace).y;
			
			if (source.width == 0 || source.height == 0)
				return source.getBounds(targetCoordinateSpace);
			 
			var data:BitmapData = new BitmapData(source.width, source.height, true, SpriteSheet.TRANS_COLOR);
			//data.fillRect(data.rect, 0xFFFFFF);
			data.draw(source, matrix);
			//var bounds : Rectangle = data.getColorBoundsRect(0xFFFFFF, SpriteSheet.TRANS_COLOR, false);
			var bounds : Rectangle = data.getColorBoundsRect(0xFFFFFFFF, SpriteSheet.TRANS_COLOR, false);
			data.dispose();
			
			return bounds;
		}
		public static function recursiveMovieClipPlay(mc:MovieClip, shouldPlay:Boolean, pMode:Boolean = false):void
		{
			for (var e:int = 0; mc != null && e < mc.numChildren; e++ )
			{
				if (mc.getChildAt(e) is MovieClip)
				{
					recursiveMovieClipPlayChildren(MovieClip(mc.getChildAt(e)), shouldPlay, pMode);
				}
			}
		}
		private static function recursiveMovieClipPlayChildren(mc:MovieClip, shouldPlay:Boolean, pMode:Boolean = false):void
		{
			if (!shouldPlay)
			{
				mc.stop();
			} else
			{
				if (pMode)
				{
					mc.play();
				} else
				{
					if (mc.currentFrame == mc.totalFrames)
					{
						mc.gotoAndStop(1);
					} else
					{
						mc.nextFrame();
					}
				}
			}
			for (var e:int = 0; e < mc.numChildren; e++ )
			{
				if (mc.getChildAt(e) is MovieClip)
				{
					recursiveMovieClipPlayChildren(MovieClip(mc.getChildAt(e)), shouldPlay, pMode);
				}
			}
		}
		public static function findXMLNodeByName(xml:XML, nodeName:String):XML
		{
			var xmlNodes:XMLList =  xml.children();
			for each (var item:XML in xmlNodes)
				if (item.name() == nodeName)
					return item;
			return null;
		}
	}
}