package com.mcleodgaming.spritesatchel.controllers 
{
	import com.mcleodgaming.spritesatchel.Main;
	import com.mcleodgaming.spritesatchel.menu.*;
	
	public class MenuController 
	{
		private static var _mainMenu:MainMenu;
		
		public static function init():void
		{
			_mainMenu = new MainMenu();
			
			trace("MenuController class initialized");
		}
		public static function removeAllMenus():void
		{
			_mainMenu.removeSelf();
		}
		
		
		public static function showMainMenu():void
		{
			_mainMenu.show();
		}
		
		public static function get mainMenu():MainMenu
		{
			return _mainMenu;
		}
	}

}