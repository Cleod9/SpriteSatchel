package com.mcleodgaming.spritesatchel
{
	import adobe.utils.CustomActions;
	import com.mcleodgaming.spritesatchel.controllers.*;
	import com.mcleodgaming.spritesatchel.core.SatchelConfig;
	import com.mcleodgaming.spritesatchel.enums.ExportModeSetting;
	import com.mcleodgaming.spritesatchel.events.EventManager;
	import com.mcleodgaming.spritesatchel.events.SpriteSatchelEvent;
	import flash.desktop.NativeApplication;
	import flash.display.GradientType;
	import flash.display.InteractiveObject;
	import flash.display.InterpolationMethod;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.html.HTMLLoader;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	public class Main extends Sprite 
	{
		//Config
		public static const DEBUG:Boolean = false;
		public static const NEWLINE:String = "\n";
		
		//Public properties
		public static var Width:Number = 1024;
		public static var Height:Number = 600;
		
		//Public constants
		public static const TITLE:String = "SpriteSatchel";
		
		//Private static properties
		private static var ROOT:Main;//More specifically, so now we can access things a bit more proper
		private static var m_fileChanged:Boolean;
		private static var _config:SatchelConfig
		
		//Private properties
		
		//Toolbar menu items
		private var m_menu:NativeMenu;
		
		private var m_fileMenu:NativeMenu;
		
		private var m_settingsMenu:NativeMenu;
		private var m_exportModeMenu:NativeMenu;
		private var m_dimensionsMenu:NativeMenu;
		
		private var m_helpMenu:NativeMenu;
		
		// File
		private var m_newProject:NativeMenuItem;
		private var m_openProject:NativeMenuItem;
		private var m_saveProject:NativeMenuItem;
		private var m_saveProjectAs:NativeMenuItem;
		private var m_importSWF:NativeMenuItem;
		private var m_publish:NativeMenuItem;
		private var m_exit:NativeMenuItem;
		
		// Settings
		private var m_maxWidth2048:NativeMenuItem;
		private var m_maxWidth4096:NativeMenuItem;
		private var m_maxWidth8192:NativeMenuItem;
		
		private var m_maxHeight2048:NativeMenuItem;
		private var m_maxHeight4096:NativeMenuItem;
		private var m_maxHeight8192:NativeMenuItem;
		
		private var m_createJSMode:NativeMenuItem;
		private var m_pngSequenceMode:NativeMenuItem;
		private var m_pngSequenceModeTrimmed:NativeMenuItem;
		
		// Help
		private var m_about:NativeMenuItem;
		
		public function Main():void 
		{
			ROOT = this;
			m_fileChanged = false;
			Main._config = new SatchelConfig();
			
			MenuController.init();
			
			//Draw Background
			var rotmat:Matrix = new Matrix();
			rotmat.createGradientBox(Main.Width + 100, Main.Height + 100, 90 * Math.PI / 180, -50, -50);
			graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xDDDDDD], [1.0, 1.0], [120, 255], rotmat, SpreadMethod.REFLECT, InterpolationMethod.RGB);
			graphics.drawRect(-50, -50, Main.Width + 100, Main.Height + 100);
			graphics.endFill();
			
			//Create menus
			m_menu = new NativeMenu();
			m_fileMenu = new NativeMenu();
			m_settingsMenu = new NativeMenu();
			m_exportModeMenu = new NativeMenu();
			m_dimensionsMenu = new NativeMenu();
			m_helpMenu = new NativeMenu();
			
			//Create File menu items
			m_newProject = new NativeMenuItem("New Project");
			m_openProject = new NativeMenuItem("Open Project");
			m_saveProject = new NativeMenuItem("Save Project");
			m_saveProjectAs = new NativeMenuItem("Save Project As...");
			m_importSWF = new NativeMenuItem("Import SWF");
			m_publish = new NativeMenuItem("Publish");
			m_exit = new NativeMenuItem("Exit");
			
			//Create Settings menu items
			m_maxWidth2048 = new NativeMenuItem("2048px W");
			m_maxWidth4096 = new NativeMenuItem("4096px W");
			m_maxWidth8192 = new NativeMenuItem("8192px W");
			
			m_maxHeight2048 = new NativeMenuItem("2048px H");
			m_maxHeight4096 = new NativeMenuItem("4096px H");
			m_maxHeight8192 = new NativeMenuItem("8192px H");
			
			m_createJSMode = new NativeMenuItem("CreateJS");
			m_pngSequenceMode = new NativeMenuItem("PNG Sequence");
			m_pngSequenceModeTrimmed = new NativeMenuItem("PNG Sequence (Trimmed)");
			
			// Create Help Menu Items
			m_about = new NativeMenuItem("About");
			
			//Keyboard shortcuts
			m_newProject.keyEquivalent = "n";
			m_saveProject.keyEquivalent = "s";
			m_saveProjectAs.keyEquivalent = "S";
			m_openProject.keyEquivalent = "o";
			m_exit.keyEquivalent = "w";
			
			//Add menu items to menus
			m_fileMenu.addItem(m_newProject);
			m_fileMenu.addItem(m_openProject);
			m_fileMenu.addItem(new NativeMenuItem("", true));
			m_fileMenu.addItem(m_saveProject);
			m_fileMenu.addItem(m_saveProjectAs);
			m_fileMenu.addItem(new NativeMenuItem("", true));
			m_fileMenu.addItem(m_importSWF);
			m_fileMenu.addItem(new NativeMenuItem("", true));
			m_fileMenu.addItem(m_publish);
			m_fileMenu.addItem(new NativeMenuItem("", true));
			m_fileMenu.addItem(m_exit);
			
			m_settingsMenu.addSubmenu(m_dimensionsMenu, "Max Dimensons");
			m_settingsMenu.addSubmenu(m_exportModeMenu, "Export Format");
			
			m_dimensionsMenu.addItem(m_maxWidth2048);
			m_dimensionsMenu.addItem(m_maxWidth4096);
			m_dimensionsMenu.addItem(m_maxWidth8192);
			m_dimensionsMenu.addItem(new NativeMenuItem("", true));
			
			m_dimensionsMenu.addItem(m_maxHeight2048);
			m_dimensionsMenu.addItem(m_maxHeight4096);
			m_dimensionsMenu.addItem(m_maxHeight8192);
			
			m_exportModeMenu.addItem(m_createJSMode);
			m_exportModeMenu.addItem(m_pngSequenceMode);
			m_exportModeMenu.addItem(m_pngSequenceModeTrimmed);
			
			m_helpMenu.addItem(m_about);
			
			//Add menu to master menu
			m_menu.addSubmenu(m_fileMenu, "File");
			m_menu.addSubmenu(m_settingsMenu, "Settings");
			m_menu.addSubmenu(m_helpMenu, "Help");
			
			//Make menu
			if (NativeMenu.isSupported)
			{
				if (NativeApplication.supportsMenu)
				{
					NativeApplication.nativeApplication.menu = m_menu;
				} else if (NativeWindow.supportsMenu)
				{
					stage.nativeWindow.menu = m_menu;
				}
			}
			
			//Set up events
			m_newProject.addEventListener(Event.SELECT, newProject_CLICK);
			m_openProject.addEventListener(Event.SELECT, openProject_CLICK);
			m_saveProject.addEventListener(Event.SELECT, saveProject_CLICK);
			m_saveProjectAs.addEventListener(Event.SELECT, saveProjectAs_CLICK);
			m_importSWF.addEventListener(Event.SELECT, importSWF_CLICK);
			m_publish.addEventListener(Event.SELECT, publish_CLICK);
			m_exit.addEventListener(Event.SELECT, exit_CLICK);
			
			
			m_maxWidth2048.addEventListener(Event.SELECT, width_2048_CLICK);
			m_maxWidth4096.addEventListener(Event.SELECT, width_4096_CLICK);
			m_maxWidth8192.addEventListener(Event.SELECT, width_8192_CLICK);
			
			m_maxHeight2048.addEventListener(Event.SELECT, height_2048_CLICK);
			m_maxHeight4096.addEventListener(Event.SELECT, height_4096_CLICK);
			m_maxHeight8192.addEventListener(Event.SELECT, height_8192_CLICK);
			
			m_createJSMode.addEventListener(Event.SELECT, createjs_mode_CLICK);
			m_pngSequenceMode.addEventListener(Event.SELECT, png_mode_CLICK);
			m_pngSequenceModeTrimmed.addEventListener(Event.SELECT, png_mode_trimmed_CLICK);
			
			m_about.addEventListener(Event.SELECT, about_CLICK);
			
			//Fix title
			setTitle(Main.TITLE + " - " + Main.Config.ProjectName);
			
			MenuController.showMainMenu();
			EventManager.dispatcher.addEventListener(SpriteSatchelEvent.FILE_CHANGED, handleFileChanged);
			
			// Default dimensions
			width_2048_CLICK(null);
			height_2048_CLICK(null);
			
			// Default export mode
			createjs_mode_CLICK(null);
		}
		public static function showAlert(msg:String):void
		{
			var alertBox:HTMLLoader = new HTMLLoader();
            alertBox.loadString("<html></html>");
			alertBox.window.alert(msg);
		}
		public static function get Config():SatchelConfig
		{
			return Main._config
		}
		
		/**
		 * Forces the stage focus onto a specified object.
		 * @param	object InteractiveObject to set the focus to.
		 */
		public static function setFocus(object:InteractiveObject):void
		{
			Main.Root.stage.focus = object;
		}
		/**
		 * Forces the focus back to the stage
		 */
		public static function fixFocus():void
		{
			Main.Root.stage.focus = Main.Root.stage;
		}
		/**
		 * Modifies title in app window.
		 * @param	str String for the app title.
		 */
		public static function setTitle(str:String):void
		{
			if (NativeWindow.isSupported)
			{
				ROOT.stage.nativeWindow.title = str;
			}
		}
		/**
		 * Specifies the Main instance itself
		 */
		public static function get Root():Main
		{
			return ROOT;
		}
		
		/**
		 * Starts new Project
		 * @param	e Event argument.
		 */
		private function newProject_CLICK(e:Event):void
		{
			Main.Config.reset();
			MenuController.mainMenu.resetAll();
		}
		
		/**
		 * Initiates Project save data import
		 * @param	e Event argument.
		 */
		private function openProject_CLICK(e:Event):void
		{
			MenuController.mainMenu.println("Awaiting Project to open...");
			var textTypeFilter:FileFilter = new FileFilter("Sprite Satchel Project File | *.satchel", "*.satchel"); 
            var fs:FileStream = new FileStream();
            var openDialog:File = new File();
			openDialog.addEventListener(Event.SELECT, function():void {
				Main.Config.reset();
				Main.Config.FilePath = openDialog.nativePath;
				fs.open(openDialog, FileMode.READ);
				var input:String = fs.readUTFBytes(fs.bytesAvailable);
				fs.close();
				MenuController.mainMenu.loadProjectJSON(input);
				if (_config.MaxWidth === 2048)
				{
					width_2048_CLICK(null);
				} else if (_config.MaxWidth === 4096)
				{
					width_4096_CLICK(null);
				} else if (_config.MaxWidth === 8192)
				{
					width_8192_CLICK(null);
				}
				if (_config.MaxHeight === 2048)
				{
					height_2048_CLICK(null);
				} else if (_config.MaxHeight === 4096)
				{
					height_4096_CLICK(null);
				} else if (_config.MaxHeight === 8192)
				{
					height_8192_CLICK(null);
				}
				if (_config.ExportMode === ExportModeSetting.CREATEJS)
				{
					createjs_mode_CLICK(null);
				} else if (_config.ExportMode === ExportModeSetting.PNG)
				{
					png_mode_CLICK(null);
				} else if (_config.ExportMode === ExportModeSetting.PNG_TRIMMED)
				{
					png_mode_trimmed_CLICK(null);
				}
				Main.setTitle(Main.TITLE + " - " + Main.Config.ProjectName);
			});
			openDialog.addEventListener(Event.CANCEL, function():void { MenuController.mainMenu.println("Action cancelled"); } );
			openDialog.browseForOpen("Choose a file to open", [textTypeFilter]);
		}
		
		/**
		 * Saves Project Data to file as JSON
		 * @param	e Event argument.
		 */
		private function saveProject_CLICK(e:Event):void
		{
			var fs:FileStream = null;
			var file:File = new File(_config.FilePath);
			if (_config.FilePath && file.exists)
			{
				fs = new FileStream();
				fs.open(file, FileMode.WRITE);
				fs.writeUTFBytes(_config.export());
				fs.close();
				MenuController.mainMenu.println("Save complete. (" + _config.ModifiedDate.toUTCString() + ")"); 
				m_fileChanged = false;
				setTitle(Main.TITLE + " - " + Main.Config.ProjectName);
			} else
			{
				saveProjectAs_CLICK(e);
			}
		}
		
		/**
		 * Saves Project JSON to a new location
		 * @param	e Event argument.
		 */
		private function saveProjectAs_CLICK(e:Event):void
		{
			var fs:FileStream = null;
			var file:File = File.desktopDirectory.resolvePath((_config.FilePath == null) ? _config.ProjectName + ".satchel" : new File(_config.FilePath).name);
			file.addEventListener(Event.CANCEL, function(e:Event):void {} ); 
			file.addEventListener(Event.SELECT, function(e:Event):void { 
				var path:String = File(e.target).nativePath;
				if (path.indexOf(".satchel") != path.length - ".satchel".length)
					path += ".satchel";
					
				var tofile:File = new File(path);
				_config.FilePath = tofile.nativePath;
				fs = new FileStream();
				fs.open(tofile, FileMode.WRITE);
				fs.writeUTFBytes(_config.export());
				fs.close();
				MenuController.mainMenu.println("Save complete. (" + _config.ModifiedDate.toUTCString() + ")"); 
				m_fileChanged = false;
				setTitle(Main.TITLE + " - " + Main.Config.ProjectName);
			});
			var bArr:ByteArray = new ByteArray();
			bArr.writeUTFBytes(_config.export());
			
			file.browseForSave("Choose a Save Location");
		}
		private function about_CLICK(e:Event):void
		{
			Main.showAlert("SpriteSatchel Version " + SatchelConfig.VERSION + "\nAuthored by Greg McLeod");
		}
		
		/**
		 * Initiates SWF import
		 * @param	e Event argument.
		 */
		private function importSWF_CLICK(e:Event):void
		{
			MenuController.mainMenu.openSWF();
		}
		
		/**
		 * Initiates Publish
		 * @param	e Event argument.
		 */
		private function publish_CLICK(e:Event):void
		{
			MenuController.mainMenu.export();
		}
		
		/**
		 * Exits the program.
		 * @param	e Event argument.
		 */
		private function exit_CLICK(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		/**
		 * File chage event handler
		 * @param	e Event argument.
		 */
		private function handleFileChanged(e:SpriteSatchelEvent):void
		{
			m_fileChanged = true;
			setTitle("*" + Main.TITLE + " - " + Main.Config.ProjectName);
		}
		
		private function width_2048_CLICK(e:Event):void
		{
			m_maxWidth2048.checked = true;
			m_maxWidth4096.checked = false;
			m_maxWidth8192.checked = false;
			_config.MaxWidth = 2048;
		}
		private function width_4096_CLICK(e:Event):void
		{
			m_maxWidth2048.checked = false;
			m_maxWidth4096.checked = true;
			m_maxWidth8192.checked = false;
			_config.MaxWidth = 4096;
		}
		private function width_8192_CLICK(e:Event):void
		{
			m_maxWidth2048.checked = false;
			m_maxWidth4096.checked = false;
			m_maxWidth8192.checked = true;
			_config.MaxWidth = 8192;
		}
		
		private function height_2048_CLICK(e:Event):void
		{
			m_maxHeight2048.checked = true;
			m_maxHeight4096.checked = false;
			m_maxHeight8192.checked = false;
			_config.MaxHeight = 2048;
		}
		private function height_4096_CLICK(e:Event):void
		{
			m_maxHeight2048.checked = false;
			m_maxHeight4096.checked = true;
			m_maxHeight8192.checked = false;
			_config.MaxHeight = 4096;
		}
		private function height_8192_CLICK(e:Event):void
		{
			m_maxHeight2048.checked = false;
			m_maxHeight4096.checked = false;
			m_maxHeight8192.checked = true;
			_config.MaxHeight = 8192;
		}
		private function createjs_mode_CLICK(e:Event):void
		{
			_config.ExportMode = ExportModeSetting.CREATEJS;
			m_createJSMode.checked = true;
			m_pngSequenceMode.checked = false;
			m_pngSequenceModeTrimmed.checked = false;
		}
		private function png_mode_CLICK(e:Event):void
		{
			_config.ExportMode = ExportModeSetting.PNG;
			m_createJSMode.checked = false;
			m_pngSequenceMode.checked = true;
			m_pngSequenceModeTrimmed.checked = false;
		}
		private function png_mode_trimmed_CLICK(e:Event):void
		{
			_config.ExportMode = ExportModeSetting.PNG_TRIMMED;
			m_createJSMode.checked = false;
			m_pngSequenceMode.checked = false;
			m_pngSequenceModeTrimmed.checked = true;
		}
	}
	
}