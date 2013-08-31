package com.mcleodgaming.spritesatchel.menu
{
	import com.mcleodgaming.spritesatchel.Main;
	import flash.display.MovieClip;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class Menu
	{
		protected var _eventDispatcher:EventDispatcher;
		protected var _container:MovieClip;
		protected var _subMenu:MovieClip; //Just a quick way to access grouped sub-menus
		protected var _clickBlocker:MovieClip; //To block clicks from behind the menu
		protected var _secondaryClickBlocker:MovieClip; //To block ALL clicks in foreground or other uses
		protected var _bgBlocker:MovieClip;
		
		public function Menu() 
		{
			_container = new MovieClip();
			_clickBlocker = new MovieClip();
			_clickBlocker.graphics.beginFill(0x000000, 0.5);
			_clickBlocker.graphics.drawRect( -2, -2, Main.Width + 4, Main.Height + 4);
			_clickBlocker.graphics.endFill();
			_clickBlocker.buttonMode = true;
			_clickBlocker.useHandCursor = false;
			
			_secondaryClickBlocker = new MovieClip();
			_secondaryClickBlocker.graphics.beginFill(0x000000, 0.5);
			_secondaryClickBlocker.graphics.drawRect( -2, -2, Main.Width + 4, Main.Height + 4);
			_secondaryClickBlocker.graphics.endFill();
			_secondaryClickBlocker.buttonMode = true;
			_secondaryClickBlocker.useHandCursor = false;
			
			_bgBlocker = new MovieClip();
			_bgBlocker.graphics.beginFill(0x000000, 0.3);
			_bgBlocker.graphics.drawRect( -2, -2, Main.Width + 4, Main.Height + 4);
			_bgBlocker.graphics.endFill();
		}
		
		public function get Container():MovieClip
		{
			return _container;
		}
		public function get SubMenu():MovieClip
		{
			return _subMenu;
		}
		public function makeEvents():void
		{
			//Add Event listeners
		}
		public function killEvents():void
		{
			//Kill event listeners
		}
		public function show():void
		{
			Main.Root.addChild(_container);
			makeEvents();
			Main.fixFocus();
		}
		public function removeSelf():void
		{
			//Removes self from container
			killEvents();
			if (_container.parent)
				_container.parent.removeChild(_container);
		}
		public function addClickBlocker():void
		{
			_container.addChild(_clickBlocker);
		}
		public function removeClickBlocker():void
		{
			if (_clickBlocker.parent)
				_clickBlocker.parent.removeChild(_clickBlocker);
		}
		public function addBGBlocker():void
		{
			_container.addChild(_bgBlocker);
		}
		public function removeBGBlocker():void
		{
			if (_bgBlocker.parent)
				_bgBlocker.parent.removeChild(_bgBlocker);
		}
		public function addSecondaryClickBlocker():void
		{
			_container.addChild(_secondaryClickBlocker);
		}
		public function removeSecondaryClickBlocker():void
		{
			if (_secondaryClickBlocker.parent)
				_secondaryClickBlocker.parent.removeChild(_secondaryClickBlocker);
		}
		public function setButtonModes(target:MovieClip, mouseChildrenKill:Boolean = false):void
		{
			//Button mode stuff (lazy version)
			for (var i:int = 0; i < target.numChildren; i++)
			{
				if (target.getChildAt(i) is MovieClip && target.getChildAt(i).name.indexOf("instance") < 0)
				{
					MovieClip(target.getChildAt(i)).buttonMode = true;
					if (mouseChildrenKill)
						MovieClip(target.getChildAt(i)).mouseChildren = false;
				}
			}
		}
	}

}