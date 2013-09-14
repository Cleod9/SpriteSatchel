package com.mcleodgaming.spritesatchel.core 
{
	import com.adobe.utils.StringUtil;
	import flash.display.MovieClip;
	import flash.filesystem.File;
	public class SatchelConfig 
	{
		public static const VERSION:String = "0.4.1";
		
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
		public function exportXML():XML
		{
			_date = new Date();
			
			var spritesatchel:XML = new XML("<spritesatchel />");
			spritesatchel.@version = SatchelConfig.VERSION;
			
			var project:XML = new XML("<project />");
			project.@name = _projectName;
			project.@timestamp = _date.toUTCString();
			
			var config:XML = new XML("<config />");
			config.appendChild(new XML("<exportMode>" + _exportMode + "</exportMode>"));
			
			config.appendChild(new XML("<jsonExportPath>" + _jsonExportPath + "</jsonExportPath>"));
			config.appendChild(new XML("<pngExportPath>" + _pngExportPath + "</pngExportPath>"));
			
			var sources:XML = new XML("<sources />");
			for (var i:int = 0; i < _sources.length; i++)
			{
				var file:XML = new XML("<file />");
				if(!_sources[i].Export)
					file.@export = "false";
				if (_sources[i].ExcludeList.length > 0)
					file.@exclude = _sources[i].ExcludeList.join(",");
				file.appendChild(new File(_sources[i].Path).nativePath);
				sources.appendChild(file);
			}
			
			spritesatchel.appendChild(project);
			project.appendChild(config);
			project.appendChild(sources);
			
			return spritesatchel;
		}
	}

}