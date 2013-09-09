package com.mcleodgaming.spritesatchel
{
	import com.mcleodgaming.spritesatchel.controllers.*;
	import flash.desktop.NativeApplication;
	import flash.display.InteractiveObject;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.events.Event;
	
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
		
		//Private properties
		private static var ROOT:Main;//More specifically, so now we can access things a bit more proper
		
		//Toolbar menu items
		private var m_menu:NativeMenu;
		
		private var m_fileMenu:NativeMenu;
		private var m_fileMenuItems:Vector.<NativeMenuItem>;
		
		private var m_helpMenu:NativeMenu;
		private var m_helpMenuItems:Vector.<NativeMenuItem>;
		
		private var m_openProject:NativeMenuItem;
		private var m_saveProject:NativeMenuItem;
		private var m_saveProjectAs:NativeMenuItem;
		private var m_importSWF:NativeMenuItem;
		private var m_exit:NativeMenuItem;
		
		private var m_about:NativeMenuItem;
		
		public function Main():void 
		{
			ROOT = this;
			
			MenuController.init();
			
			//Create menus
			m_menu = new NativeMenu();
			m_fileMenu = new NativeMenu();
			m_helpMenu = new NativeMenu();
			
			//Create menu items
			m_openProject = new NativeMenuItem("Open Project");
			m_saveProject = new NativeMenuItem("Save Project");
			m_saveProjectAs = new NativeMenuItem("Save Project As...");
			m_importSWF = new NativeMenuItem("Import SWF");
			m_exit = new NativeMenuItem("Exit");
			m_about = new NativeMenuItem("About");
			
			//Add menu items to menus
			m_fileMenu.addItem(m_openProject);
			m_fileMenu.addItem(m_saveProject);
			m_fileMenu.addItem(m_saveProjectAs);
			m_fileMenu.addItem(m_importSWF);
			m_fileMenu.addItem(m_exit);
			m_helpMenu.addItem(m_about);
			
			//Add menu to master menu
			m_menu.addSubmenu(m_fileMenu, "File");
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
			m_openProject.addEventListener(Event.SELECT, openProject_CLICK);
			m_importSWF.addEventListener(Event.SELECT, importSWF_CLICK);
			m_exit.addEventListener(Event.SELECT, exit_CLICK);
			
			//Fix title
			setTitle(TITLE);
			
			MenuController.showMainMenu();
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
		 * Initiates Project XML import
		 * @param	e Event argument.
		 */
		private function openProject_CLICK(e:Event):void
		{
			MenuController.mainMenu.openProject();
		}
		
		/**
		 * Initiates SWF import
		 * @param	e Event argument.
		 */
		private function importSWF_CLICK(e:Event):void
		{
			MenuController.mainMenu.importSWF();
		}
		/**
		 * Exits the program.
		 * @param	e Event argument.
		 */
		private function exit_CLICK(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}