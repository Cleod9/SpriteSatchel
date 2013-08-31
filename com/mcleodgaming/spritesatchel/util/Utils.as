package  com.mcleodgaming.spritesatchel.util
{
	import flash.display.MovieClip;
	
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
	}
}