package com.mcleodgaming.spritesatchel.menu
{
	import com.adobe.utils.StringUtil;
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
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class MainMenu extends Menu
	{
		private var _registrationPoint:MovieClip;
		private var _currentSourceFile:SatchelSource;
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
			
			_currentSourceFile = null;
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
			_jsonExportPathText.width = 250;
			_jsonExportPathText.height = 20;
			
			_jsonExportPathButton = new PushButton(_container, 275, 270, "JSON Output Path");
			_jsonExportPathButton.width = 100;
					
			_pngExportPathText = new Text(_container, 20, 300, Main.Config.PNGExportPath);
			_pngExportPathText.enabled = false;
			_pngExportPathText.textField.multiline = false;
			_pngExportPathText.width = 250;
			_pngExportPathText.height = 20;
			
			_pngExportPathButton = new PushButton(_container, 275, 300, "PNG Output Path");
			_pngExportPathButton.width = 100;
			
			_manifestLabel = new Label(_container, 680, 10, "Manifiest:");
			
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
			
			_sourcesList.addEventListener(Event.SELECT, fileSource_CLICK);
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
			
			_sourcesList.removeEventListener(Event.SELECT, fileSource_CLICK);
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
			_animationDropdown.defaultLabel = _animationDropdown.defaultLabel;
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
			_animationDropdown.defaultLabel = _animationDropdown.defaultLabel;
			_exportCheckbox.selected = false;
		}
		public function println(str:String):void
		{
			_outputText.appendText(" > " + str + Main.NEWLINE);
			_outputText.scrollV = _outputText.bottomScrollV;
			Main.Root.stage.invalidate();
		}
		public function loadProjectJSON(json:String):void
		{
			var i:int = 0;
			var data:Object;
			try
			{
				data = JSON.parse(json);
			} catch (e:*) {
				
			}
			if (data)
			{
				resetAll();
				addClickBlocker();
				_spriteSourceDropdown.removeAll();
				_spriteSourceDropdown.defaultLabel = _spriteSourceDropdown.defaultLabel;
				removeSourceClip();
				setOptionsEnabled(false);
				if (data.name)
					Main.Config.ProjectName = data.name;
				if (data.config)
				{
					if (data.config.exportMode)
						Main.Config.ExportMode = data.config.exportMode;
					if (data.config.jsonExportPath)
						Main.Config.JSONExportPath = data.config.jsonExportPath;
					if (data.config.pngExportPath)
						Main.Config.PNGExportPath = data.config.pngExportPath;
					if (data.config.maxWidth)
						Main.Config.MaxWidth = data.config.maxWidth;
					if (data.config.maxHeight)
						Main.Config.MaxHeight = data.config.maxHeight;
				}
				if (data.sources)
				{
					for ( i = 0; i < data.sources.length; i++ )
					{
						importSWF(new File(data.sources[i].file), { 
							export: (data.sources[i].export !== undefined) ? data.sources[i].export : true,
							exclude: (data.sources[i].exclude !== undefined) ? data.sources[i].exclude : []
						});
					}
				}
				//Update options
				_jsonExportPathText.text = Main.Config.JSONExportPath;
				_pngExportPathText.text = Main.Config.PNGExportPath;
				
				println("Successfully opened project \"" + Main.Config.ProjectName  + "\".");
				removeClickBlocker();
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
			var loadExcludeSettingsFromSWF:Boolean = (!settings);
			if (!settings)
				settings = { export: true, exclude: null };
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void { println("[IOError] There was a problem loading the file."); } );
			urlLoader.addEventListener(Event.INIT,  function(e:Event):void { /*println("Loader initialized.");*/ });
			urlLoader.addEventListener(Event.COMPLETE,  function(e:Event):void { 
				var loader:Loader = new Loader();
				var loaderContext:LoaderContext = new LoaderContext();
				var i:int = 0;
				loaderContext.allowCodeImport = true;
				loaderContext.allowLoadBytesCodeExecution = true;
				loaderContext.applicationDomain = new ApplicationDomain(Main.Root.loaderInfo.applicationDomain);
			
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void { println("[IOError] There was a problem loading the file."); } );
				loader.contentLoaderInfo.addEventListener(Event.INIT,  function(e:Event):void { /*println("Loader initialized.");*/ });
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,  function(e:Event):void { 
					var source:SatchelSource = new SatchelSource((loader.content as MovieClip) ? loader.content as MovieClip : null, file.nativePath);
					if (settings.export !== undefined)
						source.Export = settings.export;
						
					//For SWFs opened directly, load the manifest individual exclude settings
					if (loadExcludeSettingsFromSWF && source.SourceClip.manifest)
					{
						for (i = 0; i < source.SourceClip.manifest.length; i++)
						{
							if (!(source.SourceClip.manifest[i].exclude == undefined || !source.SourceClip.manifest[i].exclude))
								source.ExcludeList.push(source.SourceClip.manifest[i].linkage);
						}
					} else if(settings.exclude)
					{
						//Grab data passed in from save data
						var excludeList:Array = settings.exclude;
						for (i = 0; i < source.SourceClip.manifest.length; i++)
						{
							if (settings.exclude.indexOf(source.SourceClip.manifest[i].linkage) >= 0)
								source.ExcludeList.push(source.SourceClip.manifest[i].linkage);
						}
					}
					Main.Config.Sources.push(source);
					_sourcesList.addItem( { label: source.Path, source: source} );
					
					println("Load complete."); 
					println("\"" + file.nativePath + "\" has been added to sources list."); 
					EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.FILE_CHANGED, "Project has been modified."));
				});
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,  function(e:ProgressEvent):void { /*println("Loader progressing...");*/ });
				
				loader.loadBytes(urlLoader.data as ByteArray, loaderContext);
			});
			urlLoader.load(new URLRequest(file.url));
		}
		public function processSource(source:SatchelSource):void
		{
			if(source.SourceClip == null)
			{
				println("[Error] Invalid SWF");
			} else {
				if (!source.SourceClip.manifest)
				{
					println("[Error] \"" + source.Path + "\". is missing manifest Array.");
				} else
				{
					_spriteSourceDropdown.removeAll();
					_spriteSourceDropdown.defaultLabel = _spriteSourceDropdown.defaultLabel;
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
			var readyToProcessManifest:Boolean = true;
			addClickBlocker();
			var manifestProcessor:Function = function(e:TimerEvent):void {
				if (!readyToProcessManifest)
					return;
				if (index > Main.Config.Sources.length - 1)
				{
					processTimer.removeEventListener(TimerEvent.TIMER, manifestProcessor);
					processTimer.stop();
					removeClickBlocker();
					println("Publish Complete!");
					return;
				}
				readyToProcessManifest = false;
				
				var source:SatchelSource = Main.Config.Sources[index];
				
				println("Processing manifest for \"" + source.Path + "\"...");
				if (!source.SourceClip.manifest)
				{
					println("[Error] \"" + source.Path + "\". is missing manifest Array.");
				} else if (!source.Export)
				{
					readyToProcessManifest = true;
					index++;
					return;
				} else
				{
					//Asynchronously for each resource in the manifiest
					var i:int = 0;
					var readyToProcessClip:Boolean = true;
					var clipProcessor:Function = function(e:TimerEvent):void {
						if (!readyToProcessClip)
							return;
						if (i >= source.SourceClip.manifest.length)
						{
							exportTimer.removeEventListener(TimerEvent.TIMER, clipProcessor);
							exportTimer.stop();
							println("Export Complete.");
							if (index > Main.Config.Sources.length - 1)
							{
								processTimer.removeEventListener(TimerEvent.TIMER, manifestProcessor);
								processTimer.stop();
								removeClickBlocker();
								println("Publish Complete!");
							}
							return;
						} else if (source.ExcludeList.indexOf(source.SourceClip.manifest[i].linkage) >= 0)
						{
							i++;
							return;
						}
						readyToProcessClip = false;
						
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
							readyToProcessClip = true;
							readyToProcessManifest = true;
						};
						//Initiate conversion process
						
						e.updateAfterEvent();
						i++;
						
						EventManager.dispatcher.addEventListener(SpriteSatchelEvent.STATUS, statusFunc);
						EventManager.dispatcher.addEventListener(SpriteSatchelEvent.IMPORT_COMPLETE, importCompleteFunc);
						EventManager.dispatcher.addEventListener(SpriteSatchelEvent.EXPORT_COMPLETE, exportCompleteFunc);
						
						spritesheet.importMovieClip(importedMC);
					}
					//Start the process
					exportTimer.addEventListener(TimerEvent.TIMER, clipProcessor);
					exportTimer.start();
				}
				e.updateAfterEvent();
				index++
			}
			processTimer.addEventListener(TimerEvent.TIMER, manifestProcessor);
			processTimer.start();
		}
		private function removeSourceClip():void
		{
			if (_currentSourceClip)
				if (_currentSourceClip.parent)
					_currentSourceClip.parent.removeChild(_currentSourceClip);
			_currentSourceClip = null;
		}
		private function fileSource_CLICK(e:Event):void
		{
			if (!_sourcesList.selectedItem)
				return;
			var item:Object = _sourcesList.selectedItem;
			var source:SatchelSource = item.source as SatchelSource;
			if (_currentSourceFile != source)
			{
				removeSourceClip();
				_currentSourceFile = source;
				processSource(_currentSourceFile);
				setOptionsEnabled(true);
			}
		}
		private function spriteSource_CLICK(e:Event):void
		{
			if (!_spriteSourceDropdown.selectedItem)
				return;
			var item:Object = _spriteSourceDropdown.selectedItem;
			var source:SatchelSource = item.source as SatchelSource;
			
			//Remove old clip if there was one
			removeSourceClip();
			//From the source, determine the MovieClip we will be attaching to the stage
			_currentSourceClip = new (Utils.getLibraryItem([source.SourceClip], item.linkage))() as MovieClip;
			_currentSourceClip.x = _registrationPoint.x;
			_currentSourceClip.y = _registrationPoint.y
			_container.addChildAt(_currentSourceClip, 0);
			Utils.removeChildActionScript(_currentSourceClip);
			
			//Enable animation list and add available animations to the list
			loadOptions(source);
			loadAnimationList(_currentSourceClip);
			_exportCheckbox.selected = (source.ExcludeList.indexOf(item.linkage) < 0);
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
				var source:SatchelSource = (item.source as SatchelSource);
				var index:int = source.ExcludeList.indexOf(item.linkage);
				if (!_exportCheckbox.selected)
				{
					if (index < 0)
						source.ExcludeList.push(item.linkage);
				} else
				{
					if (index >= 0)
						source.ExcludeList.splice(index, 1);
				}
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
				importSWF(file);
				removeClickBlocker();
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
							_animationDropdown.defaultLabel = _animationDropdown.defaultLabel;
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
				} else
				{
					Main.Config.JSONExportPath = Utils.toRelativePath(Main.Config.FilePath.substr(0, Main.Config.FilePath.lastIndexOf(File.separator)), file.nativePath);
				}
				_jsonExportPathText.text = Main.Config.JSONExportPath;
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
				} else
				{
					Main.Config.PNGExportPath = Utils.toRelativePath(Main.Config.FilePath.substr(0, Main.Config.FilePath.lastIndexOf(File.separator)), file.nativePath);
				}
				_pngExportPathText.text = Main.Config.PNGExportPath;
				EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.FILE_CHANGED, "Project has been modified."));
			});
			openDialog.addEventListener(Event.CANCEL, function(e:Event):void { } );
			openDialog.browseForDirectory("Choose a directory for PNG Export");
		}
	}
}