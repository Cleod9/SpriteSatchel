package com.mcleodgaming.spritesatchel.core 
{
	public class SatchelConfig 
	{
		public static const VERSION:String = "0.1";
		
		private var _filePath:String;
		private var _projectName:String;
		private var _timestamp:Date;
		private var _exportMode:String;
		private var _jsonExportPath:String;
		private var _pngExportPath:String;
		private var _sources:Vector.<SatchelSource>
		
		public function SatchelConfig():void
		{
			_filePath = null;
			_projectName = "";
			_timestamp = new Date();
			_exportMode = "createjs";
			_jsonExportPath = "";
			_pngExportPath = "";
			_sources = new Vector.<SatchelSource>();
		}
		
		public function get FilePath():String
		{
			return _filePath;
		}
		public function set FilePath(value:String):void
		{
			_filePath = value;
		}
		public function get ProjectName():String
		{
			return _projectName;
		}
		public function set ProjectName(value:String):void
		{
			_projectName = value;
		}
		public function get ExportMode():String
		{
			return _exportMode;
		}
		public function set ExportMode(value:String):void
		{
			_exportMode = value;
		}
		public function get JSONExportPath():String
		{
			return _jsonExportPath;
		}
		public function set JSONExportPath(value:String):void
		{
			_jsonExportPath = value;
		}
		public function get PNGExportPath():String
		{
			return _pngExportPath;
		}
		public function set PNGExportPath(value:String):void
		{
			_pngExportPath = value;
		}
		public function get Sources():Vector.<SatchelSource>
		{
			return _sources;
		}
		
		public function addSource(path:String):void
		{
			_sources.push(new SatchelSource(path));
		}
		public function dispose():void
		{
			
		}
	}

}