package com.mcleodgaming.spritesatchel.core 
{
	public class SatchelSource 
	{
		private var _path:String;
		private var _export:Boolean;
		
		public function SatchelSource(path:String) 
		{
			_path = path;
			_export = true;
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
		
		
	}
}