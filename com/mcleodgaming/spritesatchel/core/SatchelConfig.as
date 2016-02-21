package com.mcleodgaming.spritesatchel.core 
{
	import com.adobe.utils.StringUtil;
	import com.mcleodgaming.spritesatchel.util.Utils;
	import flash.display.MovieClip;
	import flash.filesystem.File;
	public class SatchelConfig 
	{
		public static const VERSION:String = "0.5.11";
		
		private var _date:Date;
		private var _filePath:String;
		private var _projectName:String;
		private var _timestamp:Date;
		private var _exportMode:String;
		private var _jsonExportPath:String;
		private var _pngExportPath:String;
		private var _sources:Vector.<SatchelSource>
		
		public function SatchelConfig():void
		{
			_date = new Date();
			_filePath = null;
			_projectName = "Untitled";
			_timestamp = new Date();
			_exportMode = "createjs";
			_jsonExportPath = File.desktopDirectory.nativePath + File.separator + ["assets", "json"].join(File.separator);
			_pngExportPath = File.desktopDirectory.nativePath + File.separator + ["assets", "images"].join(File.separator);
			_sources = new Vector.<SatchelSource>();
		}
		
		public function get ModifiedDate():Date
		{
			return _date;
		}
		public function set ModifiedDate(value:Date):void
		{
			_date = value;
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
			_jsonExportPath = StringUtil.trim(value);
		}
		public function get PNGExportPath():String
		{
			return _pngExportPath;
		}
		public function set PNGExportPath(value:String):void
		{
			_pngExportPath = StringUtil.trim(value);
		}
		public function get Sources():Vector.<SatchelSource>
		{
			return _sources;
		}
		
		public function reset():void
		{
			_filePath = null;
			_projectName = "";
			_timestamp = null;
			_timestamp = new Date();
			_exportMode = "createjs";
			_jsonExportPath = "";
			_pngExportPath = "";
			_sources = null;
			_sources = new Vector.<SatchelSource>();
		}
		public function export():String
		{
			_date = new Date();
			
			var spritesatchel:Object = { };
			spritesatchel.version = SatchelConfig.VERSION;
			
			spritesatchel.name = _projectName;
			spritesatchel.timestamp = _date.toUTCString();
			
			spritesatchel.config = { };
			spritesatchel.config.exportMode = _exportMode;
			spritesatchel.config.jsonExportPath = _jsonExportPath;
			spritesatchel.config.pngExportPath = _pngExportPath;
			
			spritesatchel.sources = [];
			
			for (var i:int = 0; i < _sources.length; i++)
			{
				spritesatchel.sources.push({
					file: new File(_sources[i].Path).nativePath,
					export: _sources[i].Export,
					exclude: Utils.toArray(_sources[i].ExcludeList)
				});
			}
			
			return JSON.stringify(spritesatchel, null, 2);
		}
	}

}