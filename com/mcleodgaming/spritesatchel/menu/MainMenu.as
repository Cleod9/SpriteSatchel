package com.mcleodgaming.spritesatchel.menu
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.TextArea;
	import com.mcleodgaming.spritesatchel.core.SatchelConfig;
	import com.mcleodgaming.spritesatchel.core.SatchelSource;
	import com.mcleodgaming.spritesatchel.core.SpriteSheet;
	import com.mcleodgaming.spritesatchel.events.SpriteSheetEvent;
	import com.mcleodgaming.spritesatchel.Main;
	import com.mcleodgaming.spritesatchel.util.Utils;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	
	public class MainMenu extends Menu
	{
		private var _config:SatchelConfig;
		private var _outputText:TextField;
		
		public function MainMenu() 
		{
			super();
			
			_config = new SatchelConfig();
			
			_outputText = new TextField();
			_outputText.x = 10;
			_outputText.y = 400
			_outputText.width = Main.Width - 20;
			_outputText.height = 175;
			_outputText.border = true;
			_outputText.borderColor = 0xAAAAAA;
			
			_container.addChild(_outputText);
			
		}
		public override function makeEvents():void
		{
			//Add Event listeners
			super.makeEvents();
			
			println("SpriteSatchel has been initialized.");
		}
		public override function killEvents():void
		{
			//Kill event listeners
			super.killEvents();
		}
		public function println(str:String):void
		{
			_outputText.appendText(" > " + str + Main.NEWLINE);
			_outputText.scrollV = _outputText.bottomScrollV;
			Main.Root.stage.invalidate();
		}
		public function openProject():void
		{
			println("Awaiting Project to open...");
			var textTypeFilter:FileFilter = new FileFilter("Sprite Satchel Project File | *.xml", "*.xml"); 
            var fs:FileStream = new FileStream();
            var openDialog:File = new File();
			openDialog.addEventListener(Event.SELECT, function():void {
				fs.open(openDialog, FileMode.READ);
				var input:String = fs.readUTFBytes(fs.bytesAvailable);
				fs.close();
				processXML(XML(input));
				_config.FilePath = openDialog.nativePath;
				Main.setTitle(Main.TITLE + " - " + _config.ProjectName);
			});
			openDialog.addEventListener(Event.CANCEL, function():void { println("Action cancelled"); } );
			openDialog.browseForOpen("Choose a file to open", [textTypeFilter]);
		}
		public function processXML(xmlData:XML):void
		{
			var i:int = 0;
			var node:XML = null;
			var project:XML = null;
			var config:XML = null;
			var sources:XML = null;
			if (xmlData.name() == "spritesatchel")
			{
				if ((project = Utils.findXMLNodeByName(xmlData, "project")) != null)
				{
					_config.dispose();
					_config = null;
					_config = new SatchelConfig();
					if (project.@name)
						_config.ProjectName = project.@name;
					if ((config = Utils.findXMLNodeByName(project, "config")) != null)
					{
						if (config.child("exportMode"))
							_config.ExportMode = config.child("exportMode");
						if (config.child("jsonExportPath"))
							_config.JSONExportPath = config.child("jsonExportPath");
						if (config.child("pngExportPath"))
							_config.PNGExportPath = config.child("pngExportPath");
					}
					if ((sources = Utils.findXMLNodeByName(project, "sources")) != null)
					{
						for each(node in sources.children())
						{
							var source:SatchelSource = new SatchelSource(node);
							if (node.@export)
								source.Export = (node.@export == "false") ? false : true;
							_config.Sources.push(source);
						}
					}
					println("Successfully opened project \"" + _config.ProjectName  + "\".");
				} else
				{
					println("Error, missing Project node.");
				}
			} else
			{
				println("Error, invalid Sprite Satchel Project file");
			}
		}
		public function importSWF():void
		{
			println("Awaiting SWF to import...");
			var textTypeFilter:FileFilter = new FileFilter("Flash SWF File | *.swf", "*.swf"); 
            var openDialog:File = new File();
			openDialog.addEventListener(Event.SELECT, function():void { 
				var loader:Loader = new Loader();
				var loaderContext:LoaderContext = new LoaderContext();
				loaderContext.allowCodeImport = true;
				loaderContext.allowLoadBytesCodeExecution = true;
				loaderContext.applicationDomain = new ApplicationDomain(Main.Root.loaderInfo.applicationDomain);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void { println("[IOError] There was a problem loading the file."); } );
				loader.contentLoaderInfo.addEventListener(Event.INIT,  function(e:Event):void { /*println("Loader initialized.");*/ });
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,  function(e:Event):void { println("Load complete.."); processSWF(loader);  } );
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,  function(e:ProgressEvent):void { /*println("Loader progressing...");*/ });
				
				loader.load(new URLRequest(new File(openDialog.nativePath).url));
			});
			openDialog.addEventListener(Event.CANCEL, function():void { println("Action cancelled"); } );
			openDialog.browseForOpen("Choose a file to open", [textTypeFilter]);
		}
		public function processSWF(loader:Loader):void
		{
			var mc:MovieClip = null;
			try
			{
				mc = MovieClip(loader.content);
			} catch (e:*)
			{
				println("[Error] Invalid SWF");
			}
			println("Processing SWF manifest...");
			if (!mc.manifest)
			{
				println("[Error] SWF is missing manifest Array.");
			} else
			{
				for (var i:* in mc.manifest)
				{
					println("Now processing \"" + mc.manifest[i].linkage + "\"...");
					var importedMC:MovieClip = new (Utils.getLibraryItem([mc], mc.manifest[i].linkage))() as MovieClip;
					importedMC.x = 100;
					importedMC.y = 300;
					Main.Root.addChild(importedMC);
					var spritesheet:SpriteSheet = new SpriteSheet(mc.manifest[i].linkage);
					spritesheet.addEventListener(SpriteSheetEvent.STATUS, function(e:SpriteSheetEvent):void { 
						println(e.message);
					});
					spritesheet.addEventListener(SpriteSheetEvent.IMPORT_COMPLETE, function(e:SpriteSheetEvent):void { 
						println(e.message);
						println("Saving Spritesheet...");
						spritesheet.saveSpriteSheet() 
						println("Import and Save complete.");
					});
					spritesheet.addEventListener(SpriteSheetEvent.EXPORT_COMPLETE, function(e:SpriteSheetEvent):void { 
						println(e.message);
						println("Import and Save complete.");
					});
					spritesheet.importMovieClip(importedMC);
				}
			}
		}
	}
}