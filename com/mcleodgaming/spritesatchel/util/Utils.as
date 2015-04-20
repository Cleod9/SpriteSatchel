package  com.mcleodgaming.spritesatchel.util
{
   import com.mcleodgaming.spritesatchel.core.SpriteSheet;
   import flash.display.DisplayObject;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.filesystem.File;
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
		public static function removeChildActionScript(target:MovieClip):void
		{
			for (var i:int = 0; i < target.numChildren; i++)
			{
				if (target.getChildAt(i) is MovieClip)
				{
					Utils.removeActionScript(target.getChildAt(i) as MovieClip);
				}
			}
		}
		public static function getVisibleBounds(source:DisplayObject, targetCoordinateSpace:DisplayObject):Rectangle
		{ 
			//Based on: http://snipplr.com/view/63449/
			var rect:Rectangle = source.getBounds(targetCoordinateSpace);
			var matrix:Matrix = new Matrix()
			matrix.tx = -rect.x;
			matrix.ty = -rect.y;
			
			if (source.width == 0 || source.height == 0)
				return rect;
			 
			var data:BitmapData = new BitmapData(source.width, source.height, true, SpriteSheet.TRANS_COLOR);
			data.draw(source, matrix);
			var bounds : Rectangle = data.getColorBoundsRect(0xFFFFFFFF, SpriteSheet.TRANS_COLOR, false);
			data.dispose();
			
			bounds.x += rect.x;
			bounds.y += rect.y;
			
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
		public static function toRelativePath(currentDirectory:String, targetDirectory:String):String
		{
			var index:int = targetDirectory.indexOf(currentDirectory);
			if (currentDirectory && targetDirectory && targetDirectory.indexOf(currentDirectory) == 0)
				targetDirectory = "." + File.separator + targetDirectory.substr(currentDirectory.length + File.separator.length);
			return targetDirectory;
		}
		public static function toArray(vec:*):Array
		{
			var arr:Array = [];
			for (var i:int = 0; i < vec.length; i++)
			{
				arr.push(vec[i]);
			}
			return arr;
		}
	}
}