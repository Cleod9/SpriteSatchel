package com.mcleodgaming.spritesatchel.menu
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.bit101.components.List;
	import com.bit101.components.PushButton;
	import com.bit101.components.Text;
	import com.bit101.components.TextArea;
	import com.mcleodgaming.spritesatchel.core.SatchelConfig;
	import com.mcleodgaming.spritesatchel.core.SatchelSource;
	import com.mcleodgaming.spritesatchel.core.SpriteSheet;
	import com.mcleodgaming.spritesatchel.events.EventManager;
	import com.mcleodgaming.spritesatchel.events.SpriteSatchelEvent;
	import com.mcleodgaming.spritesatchel.Main;
	import com.mcleodgaming.spritesatchel.util.Utils;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public class MainMenu extends Menu
	{
		private var _registrationPoint:MovieClip;
		private var _currentSourceClip:MovieClip;
		private var _outputText:TextField;
		
		private var _sourcesLabel:Label;
		private var _manifestLabel:Label;
		private var _animationLabel:Label;
		private var _spriteSourceDropdown:ComboBox;
		private var _animationDropdown:ComboBox;
		private var _exportCheckbox:CheckBox;
		private var _sourcesList:List;
		private var _addSourceButton:PushButton;
		private var _removeSourceButton:PushButton;
		private var _jsonExportPathText:Text;
		private var _pngExportPathText:Text;
		private var _jsonExportPathButton:PushButton;
		private var _pngExportPathButton:PushButton;
		
		public function MainMenu() 
		{
			super();
			
			_currentSourceClip = null;
			
			_registrationPoint = new MovieClip();
			_registrationPoint.graphics.lineStyle(1.0, 0x000000);
			_registrationPoint.graphics.moveTo(-5, 0);
			_registrationPoint.graphics.lineTo(5, 0);
			_registrationPoint.graphics.moveTo(0, 5);
			_registrationPoint.graphics.lineTo(0, -5);
			_registrationPoint.x = 700;
			_registrationPoint.y = 300;
			
			
			_outputText = new TextField();
			_outputText.x = 10;
			_outputText.y = 400
			_outputText.width = Main.Width - 20;
			_outputText.height = 175;
			_outputText.border = true;
			_outputText.borderColor = 0xAAAAAA;
			_outputText.background = true;
			
			_sourcesLabel = new Label(_container, 20, 20, "Sources List:");
			_sourcesList = new List(_container, 20, 40);
			_sourcesList.width = 175;
			_sourcesList.height = 150;
			
			_addSourceButton = new PushButton(_container, 20, 200, "Add Source");
			_addSourceButton.width = 75;
			
			_removeSourceButton = new PushButton(_container, 105, 200, "Remove Source");
			_removeSourceButton.width = 90;
			
			_jsonExportPathText = new Text(_container, 20, 270, Main.Config.JSONExportPath);
			_jsonExportPathText.enabled = false;
			_jsonExportPathText.textField.multiline = false;
			_jsonExportPathText.width = 150;
			_jsonExportPathText.height = 20;
			
			_jsonExportPathButton = new PushButton(_container, 175, 270, "JSON Output Path");
			_jsonExportPathButton.width = 100;
					
			_pngExportPathText = new Text(_container, 20, 300, Main.Config.PNGExportPath);
			_pngExportPathText.enabled = false;
			_pngExportPathText.textField.multiline = false;
			_pngExportPathText.width = 150;
			_pngExportPathText.height = 20;
			
			_pngExportPathButton = new PushButton(_container, 175, 300, "PNG Output Path");
			_pngExportPathButton.width = 100;
			
			_manifestLabel = new Label(_container, 680, 10, "Master Manifiest:");
			
			_spriteSourceDropdown = new ComboBox(_container, 680, 30, "<Select a Clip>");
			_spriteSourceDropdown.width = 200;
			
			_exportCheckbox = new CheckBox(_container, 680, 60, "Enable Clip Export");
			
			_animationLabel = new Label(_container, 900, 10, "View Animation:");
			
			_animationDropdown = new ComboBox(_container, 900, 30, "<Select animation>");
			_animationDropdown.width = 125;
			
			
			_container.addChild(_outputText);
			_container.addChild(_registrationPoint);
			
			setOptionsEnabled(false);
		}
		public override function makeEvents():void
		{
			//Add Event listeners
			super.makeEvents();
			
			_spriteSourceDropdown.addEventListener(Event.SELECT, spriteSource_CLICK);
			_animationDropdown.addEventListener(Event.SELECT, animation_CLICK);
			_exportCheckbox.addEventListener(MouseEvent.CLICK, export_CLICK);
			_addSourceButton.addEventListener(MouseEvent.CLICK, addSource_CLICK);
			_removeSourceButton.addEventListener(MouseEvent.CLICK, removeSource_CLICK);
			_jsonExportPathButton.addEventListener(MouseEvent.CLICK, setJSONExportPath_CLICK);
			_pngExportPathButton.addEventListener(MouseEvent.CLICK, setPNGExportPath_CLICK);
			
			println("SpriteSatchel has been initialized.");
		}
		public override function killEvents():void
		{
			//Kill event listeners
			super.killEvents();
			
			_spriteSourceDropdown.removeEventListener(Event.SELECT, spriteSource_CLICK);
			_animationDropdown.removeEventListener(Event.SELECT, animation_CLICK);
			_exportCheckbox.removeEventListener(MouseEvent.CLICK, export_CLICK);
			_addSourceButton.removeEventListener(MouseEvent.CLICK, addSource_CLICK);
			_removeSourceButton.removeEventListener(MouseEvent.CLICK, removeSource_CLICK);
			_jsonExportPathButton.removeEventListener(MouseEvent.CLICK, setJSONExportPath_CLICK);
			_pngExportPathButton.removeEventListener(MouseEvent.CLICK, setPNGExportPath_CLICK);
		}
		public function resetAll():void
		{
			removeSourceClip();
			resetOptions();
			setOptionsEnabled(false);
			_jsonExportPathText.text = Main.Config.JSONExportPath;
			_pngExportPathText.text = Main.Config.PNGExportPath;
			_sourcesList.removeAll();
			println("Empty project has been created.");
		}
		private function loadOptions(source:SatchelSource):void
		{
			resetOptions();
			_exportCheckbox.selected = source.Export;
		}
		private function loadAnimationList(source:MovieClip):void
		{
			_animationDropdown.removeAll();
			var currentFrame:int = 1;
			for (var i:int = 0; i < source.currentLabels.length; i++)
			{
				var label:FrameLabel = source.currentLabels[i];
				//Create dummy labels up to but not including the current frame
				while (currentFrame < label.frame)
					_animationDropdown.addItem( { label: "animation" + (currentFrame - 1), frame: currentFrame++ } );
				//Add the current frame to the list
				_animationDropdown.addItem( { label: label.name, frame: currentFrame++ } );
			}
		}
		private function setOptionsEnabled(value:Boolean):void
		{
			_sourcesLabel.enabled = value;
			_animationLabel.enabled = value;
			_animationDropdown.enabled = value;
			_exportCheckbox.enabled = value;
			_manifestLabel.enabled = value;
			_spriteSourceDropdown.enabled = value;
		}
		private function resetOptions():void
		{
			_animationDropdown.removeAll();
			_exportCheckbox.selected = false;
		}
		public function println(str:String):void
		{
			_outputText.appendText(" > " + str + Main.NEWLINE);
			_outputText.scrollV = _outputText.bottomScrollV;
			Main.Root.stage.invalidate();
		}
		public function loadProjectXML(xmlData:XML):void
		{
			var i:int = 0;
			var node:XML = null;
			var project:XML = null;
			var config:XML = null;
			var sources:XML = null;
			resetAll();
			if (xmlData.name() == "spritesatchel")
			{
				if ((project = Utils.findXMLNodeByName(xmlData, "project")) != null)
				{
					addClickBlocker();
					_spriteSourceDropdown.removeAll();
					removeSourceClip();
					setOptionsEnabled(false);
					if (project.@name)
						Main.Config.ProjectName = project.@name;
					if ((config = Utils.findXMLNodeByName(project, "config")) != null)
					{
						if (config.child("exportMode"))
							Main.Config.ExportMode = config.child("exportMode");
						if (config.child("jsonExportPath"))
							Main.Config.JSONExportPath = config.child("jsonExportPath");
						if (config.child("pngExportPath"))
							Main.Config.PNGExportPath = config.child("pngExportPath");
					}
					if ((sources = Utils.findXMLNodeByName(project, "sources")) != null)
					{
						for each(node in sources.children())
						{
							importSWF(new File(node), { export: (node.@export == "false") ? false : true});
						}
					}
					//Update options
					_jsonExportPathText.text = Main.Config.JSONExportPath;
					_pngExportPathText.text = Main.Config.PNGExportPath;
					
					println("Successfully opened project \"" + Main.Config.ProjectName  + "\".");
					removeClickBlocker();
				} else
				{
					println("Error, missing Project node.");
				}
			} else
			{
				println("Error, invalid Sprite Satchel Project file");
			}
		}
		public function openSWF():void
		{
			println("Awaiting SWF to import...");
			var textTypeFilter:FileFilter = new FileFilter("Flash SWF File | *.swf", "*.swf"); 
            var openDialog:File = new File();
			openDialog.addEventListener(Event.SELECT, function(e:Event):void {
				importSWF(new File(openDialog.nativePath));
			});
			openDialog.addEventListener(Event.CANCEL, function(e:Event):void { println("Action cancelled"); } );
			openDialog.browseForOpen("Choose a file to open", [textTypeFilter]);
		}
		public function importSWF(file:File, settings:Object = null):void
		{
			if (!settings)
				settings = { export: true };
			var loader:Loader = new Loader();
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowCodeImport = true;
			loaderContext.allowLoadBytesCodeExecution = true;
			loaderContext.applicationDomain = new ApplicationDomain(Main.Root.loaderInfo.applicationDomain);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void { println("[IOError] There was a problem loading the file."); } );
			loader.contentLoaderInfo.addEventListener(Event.INIT,  function(e:Event):void { /*println("Loader initialized.");*/ });
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,  function(e:Event):void { 
				println("Load complete."); 
				println("\"" + file.nativePath + "\" has been added to sources list."); 
				var source:SatchelSource = new SatchelSource((loader.content as MovieClip) ? loader.content as MovieClip : null, file.nativePath);
				if (settings.export !== undefined)
					source.Export = settings.export;
				Main.Config.Sources.push(source);
				processSource(source); 
				if(_spriteSourceDropdown.items.length > 0)
					setOptionsEnabled(true); 
				_sourcesList.addItem( { label: source.Path, source: source} );
			});
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,  function(e:ProgressEvent):void { /*println("Loader progressing...");*/ });
			
			loader.load(new URLRequest(file.url));
		}
		public function processSource(source:SatchelSource):void
		{
			if(source.SourceClip == null)
			{
				println("[Error] Invalid SWF");
			} else {
				println("Processing manifest for \"" + source.Path + "\"...");
				if (!source.SourceClip.manifest)
				{
					println("[Error] \"" + source.Path + "\". is missing manifest Array.");
				} else
				{
					//Add items from manifest to the drop down
					for (var i:* in source.SourceClip.manifest)
						if(source.SourceClip.manifest[i].linkage)
							_spriteSourceDropdown.addItem( { label: source.SourceClip.manifest[i].linkage, source: source, linkage: source.SourceClip.manifest[i].linkage } );
				}
			}
		}
		public function export():void
		{
			println("Publish has been initiated.");
			
			var processTimer:Timer = new Timer(20);
			var exportTimer:Timer = new Timer(20);
			var index:int = 0; 
			var readyToProcessClip:Boolean = true;
			addClickBlocker();
			var clipProcessor:Function = function(e:TimerEvent):void {
				if (!readyToProcessClip)
					return;
				if (index > Main.Config.Sources.length - 1)
				{
					processTimer.removeEventListener(TimerEvent.TIMER, clipProcessor);
					processTimer.stop();
					removeClickBlocker();
					println("Publish Complete!");
					return;
				}
				readyToProcessClip = false;
				
				var source:SatchelSource = Main.Config.Sources[index];
				
				println("Processing manifest for \"" + source.Path + "\"...");
				if (!source.SourceClip.manifest)
				{
					println("[Error] \"" + source.Path + "\". is missing manifest Array.");
				} else
				{
					//Asynchronously for each resource in the manifiest
					var i:int = 0;
					var readyToProcessFrame:Boolean = true;
					var frameProcessor:Function = function(e:TimerEvent):void {
						if (!readyToProcessFrame)
							return;
						if (i >= source.SourceClip.manifest.length)
						{
							exportTimer.removeEventListener(TimerEvent.TIMER, frameProcessor);
							exportTimer.stop();
							println("Export Complete.");
							if (index > Main.Config.Sources.length - 1)
							{
								processTimer.removeEventListener(TimerEvent.TIMER, clipProcessor);
								processTimer.stop();
								removeClickBlocker();
								println("Publish Complete!");
							}
							return;
						}
						readyToProcessFrame = false;
						println("Now processing \"" + source.SourceClip.manifest[i].linkage + "\"...");
						var resource:Object = source.SourceClip.manifest[i];
						
						//Place the MovieClip being processed onscreen
						var importedMC:MovieClip = new (Utils.getLibraryItem([source.SourceClip], resource.linkage))() as MovieClip;
						importedMC.x = Main.Width / 2;
						importedMC.y = Main.Height / 2;
						Main.Root.addChild(importedMC);
						
						//Create the new sprite sheet and set up asynchronous events
						addClickBlocker();
						var spritesheet:SpriteSheet = new SpriteSheet(resource.linkage);
						var statusFunc:Function =  function(e:SpriteSatchelEvent):void { 
							println(e.message);
						};
						var importCompleteFunc:Function = function(e:SpriteSatchelEvent):void { 
							println(e.message);
							println("Creating Spritesheet(s)...");
							EventManager.dispatcher.removeEventListener(SpriteSatchelEvent.IMPORT_COMPLETE, importCompleteFunc);
							spritesheet.exportAll(Main.Config.PNGExportPath, Main.Config.JSONExportPath);
						};
						var exportCompleteFunc:Function =  function(e:SpriteSatchelEvent):void { 
							println(e.message);
							if (importedMC.parent)
								importedMC.parent.removeChild(importedMC);
								
							//Remove lcoal events
							EventManager.dispatcher.removeEventListener(SpriteSatchelEvent.STATUS, statusFunc);
							EventManager.dispatcher.removeEventListener(SpriteSatchelEvent.EXPORT_COMPLETE, exportCompleteFunc);
							
							//This will allow the timer to continue
							readyToProcessFrame = true;
							readyToProcessClip = true;
						};
						EventManager.dispatcher.addEventListener(SpriteSatchelEvent.STATUS, statusFunc);
						EventManager.dispatcher.addEventListener(SpriteSatchelEvent.IMPORT_COMPLETE, importCompleteFunc);
						EventManager.dispatcher.addEventListener(SpriteSatchelEvent.EXPORT_COMPLETE, exportCompleteFunc);
						
						//Initiate conversion process
						spritesheet.importMovieClip(importedMC);
						e.updateAfterEvent();
						i++;
					}
					//Start the process
					exportTimer.addEventListener(TimerEvent.TIMER, frameProcessor);
					exportTimer.start();
				}
				e.updateAfterEvent();
				index++
			}
			processTimer.addEventListener(TimerEvent.TIMER, clipProcessor);
			processTimer.start();
		}
		private function removeSourceClip():void
		{
			if (_currentSourceClip)
				if (_currentSourceClip.parent)
					_currentSourceClip.parent.removeChild(_currentSourceClip);
			_currentSourceClip = null;
		}
		private function spriteSource_CLICK(e:Event):void
		{
			var item:Object = _spriteSourceDropdown.selectedItem;
			if (item && item.source as SatchelSource)
			{
				//Remove old clip if there was one
				removeSourceClip();
				//From the source, determine the MovieClip we will be attaching to the stage
				var source:SatchelSource = item.source as SatchelSource;
				_currentSourceClip = new (Utils.getLibraryItem([source.SourceClip], item.linkage))() as MovieClip;
				_currentSourceClip.x = _registrationPoint.x;
				_currentSourceClip.y = _registrationPoint.y
				_container.addChildAt(_currentSourceClip, 0);
				Utils.removeChildActionScript(_currentSourceClip);
				
				//Enable animation list and add available animations to the list
				loadOptions(source);
				loadAnimationList(_currentSourceClip);
				setOptionsEnabled(true);
				_exportCheckbox.selected = source.Export;
			}
		}
		private function animation_CLICK(e:Event):void
		{
			if (_currentSourceClip)
			{
				_currentSourceClip.gotoAndStop(_animationDropdown.selectedItem.frame);
				Utils.removeChildActionScript(_currentSourceClip);
			}
		}
		private function export_CLICK(e:MouseEvent):void
		{
			var item:Object = _spriteSourceDropdown.selectedItem;
			if (item && item.source as SatchelSource)
			{
				(item.source as SatchelSource).Export = _exportCheckbox.selected;
				EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.FILE_CHANGED, "Project has been modified."));
			}
		}
		private function addSource_CLICK(e:MouseEvent):void
		{
			addClickBlocker();
			var openDialog:File = new File();
			openDialog.browseForOpen("Select a .swf", [new FileFilter("SWF Movie (*.swf)", "*.swf")]);
			
			openDialog.addEventListener(Event.CANCEL, function(e:Event):void { 
				removeClickBlocker();
			});
			openDialog.addEventListener(Event.SELECT, function(e:Event):void {
				var file:File = e.target as File;
				var loader:Loader = new Loader();
				var loaderContext:LoaderContext = new LoaderContext();
				loaderContext.allowCodeImport = true;
				loaderContext.allowLoadBytesCodeExecution = true;
				loaderContext.applicationDomain = new ApplicationDomain(Main.Root.loaderInfo.applicationDomain);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
					println("[IOError] There was a problem loading the file."); 
					removeClickBlocker(); 
				});
				loader.contentLoaderInfo.addEventListener(Event.INIT,  function(e:Event):void { 
					/*println("Loader initialized.");*/
					removeClickBlocker(); 
				});
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,  function(e:ProgressEvent):void { 
					/*println("Loader progressing...");*/ 
					removeClickBlocker(); 
				});
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,  function(e:Event):void { 
					var source:SatchelSource = new SatchelSource((loader.content as MovieClip) ? loader.content as MovieClip : null, file.nativePath);
					Main.Config.Sources.push(source);
					processSource(source); 
					_sourcesList.addItem( { label: source.Path, source: source } );
					removeClickBlocker();
					if(_spriteSourceDropdown.items.length > 0)
						setOptionsEnabled(true);
					println("Load complete."); 
					println("\"" + file.nativePath + "\" has been added to sources list."); 
					EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.FILE_CHANGED, "Project has been modified."));
				});
				loader.load(new URLRequest(file.url));
			});
		}
		private function removeSource_CLICK(e:MouseEvent):void
		{
			var item:Object = _sourcesList.selectedItem;
			if (item)
			{
				var source:SatchelSource = item.source;
				//For each item in the manifest
				for (var i:int = 0; i < _spriteSourceDropdown.items.length; i++)
				{
					//If this object belongs to the removed source
					if (_spriteSourceDropdown.items[i].source == source)
					{
						//If this is the currently visible clip, we must remove it
						if (_spriteSourceDropdown.selectedIndex == i && _spriteSourceDropdown.items[i].source == source)
						{
							_animationDropdown.removeAll();
							removeSourceClip();
							resetOptions();
						}
						//Remove this clip from the sources list
						_spriteSourceDropdown.removeItemAt(i);
						i--;
					}
				}
				_sourcesList.removeItemAt(_sourcesList.selectedIndex);
				Main.Config.Sources.splice(Main.Config.Sources.indexOf(source), 1);
				//If no items are remaining, disable options
				if(_spriteSourceDropdown.items.length == 0)
					setOptionsEnabled(false);
				println("Removed source: " + source.Path);
				EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.FILE_CHANGED, "Project has been modified."));
			}
		}
		private function setJSONExportPath_CLICK(e:MouseEvent):void
		{
            var openDialog:File = (Main.Config.FilePath) ? new File(Main.Config.FilePath) : File.desktopDirectory;
			openDialog.addEventListener(Event.SELECT, function(e:Event):void {
				var file:File = (e.target as File);
				if (!Main.Config.FilePath)
				{
					Main.Config.JSONExportPath = file.nativePath;
					_jsonExportPathText.text = Main.Config.JSONExportPath;
				} else
				{
					Main.Config.JSONExportPath = Utils.toRelativePath(Main.Config.FilePath.substr(0, Main.Config.FilePath.lastIndexOf(File.separator)), file.nativePath);
					_jsonExportPathText.text = Main.Config.JSONExportPath;
				}
				EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.FILE_CHANGED, "Project has been modified."));
			});
			openDialog.addEventListener(Event.CANCEL, function(e:Event):void { } );
			openDialog.browseForDirectory("Choose a directory for JSON Export");
		}
		private function setPNGExportPath_CLICK(e:MouseEvent):void
		{
            var openDialog:File = (Main.Config.FilePath) ? new File(Main.Config.FilePath) : File.desktopDirectory;
			openDialog.addEventListener(Event.SELECT, function(e:Event):void {
				var file:File = (e.target as File);
				if (!Main.Config.FilePath)
				{
					Main.Config.PNGExportPath = file.nativePath;
					_pngExportPathText.text = Main.Config.PNGExportPath;
				} else
				{
					Main.Config.PNGExportPath = Utils.toRelativePath(Main.Config.FilePath.substr(0, Main.Config.FilePath.lastIndexOf(File.separator)), file.nativePath);
					_pngExportPathText.text = Main.Config.PNGExportPath;
				}
				EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.FILE_CHANGED, "Project has been modified."));
			});
			openDialog.addEventListener(Event.CANCEL, function(e:Event):void { } );
			openDialog.browseForDirectory("Choose a directory for PNG Export");
		}
	}
}