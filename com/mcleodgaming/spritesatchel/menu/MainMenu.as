package com.mcleodgaming.spritesatchel.menu
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.TextArea;
	import com.mcleodgaming.spritesatchel.core.SpriteSheet;
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
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	
	public class MainMenu extends Menu
	{
		private var _outputText:TextField;
		
		public function MainMenu() 
		{
			super();
			
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
					spritesheet.importMovieClip(importedMC);
					spritesheet.saveSpriteSheet();
					println("Import and Save complete.");
				}
			}
		}
	}
}