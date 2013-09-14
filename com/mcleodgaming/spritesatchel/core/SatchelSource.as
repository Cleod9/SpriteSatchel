package com.mcleodgaming.spritesatchel.core 
{
	import flash.display.MovieClip;
	public class SatchelSource 
	{
		private var _sourceClip:MovieClip;
		private var _path:String;
		private var _export:Boolean;
		private var _excludeList:Vector.<String>;
		
		public function SatchelSource(sourceClip:MovieClip, path:String) 
		{
			_sourceClip = sourceClip;
			_path = path;
			_export = true;
			_excludeList = new Vector.<String>();
		}
		
		public function get SourceClip():MovieClip
		{
			return _sourceClip;
		}
		public function set SourceClip(value:MovieClip):void
		{
			_sourceClip = value;
		}
		public function get Export():Boolean
		{
			return _export;
		}
		public function set Export(value:Boolean):void
		{
			_export = value;
		}
		public function get Path():String
		{
			return _path;
		}
		public function set Path(value:String):void
		{
			_path = value;
		}
		public function get ExcludeList():Vector.<String>
		{
			return _excludeList;
		}
		
		
	}
}