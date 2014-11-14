package com.mcleodgaming.spritesatchel.core.collision 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class HitBoxAnimation 
	{
		private static var m_animationsList:Object = new Object(); //For memory re-use
		
		private var m_name:String;
		
		private var m_hitBoxes:Object;
		
		private var m_hitFrames:Object;
		
		public function HitBoxAnimation(name:String) 
		{
			m_name = name;
			m_animationsList[name] = this;
			
			m_hitBoxes = new Object();
			
			m_hitFrames = new Array();
		}
		
		public static function get AnimationsList():Object
		{
			return m_animationsList;
		}
		public static function flushCache():void
		{
			for (var i:* in m_animationsList)
			{
				delete m_animationsList[i];
			}
			m_animationsList = null;
			m_animationsList = new Object();
		}
		public function get HitBoxesMap():Object
		{
			return m_hitBoxes;
		}
		public function get HitFramesMap():Object
		{
			return m_hitFrames;
		}
		public function get Name():String
		{
			return m_name;
		}
		
		public static function createHitBoxAnimation(mc_name:String, mc:MovieClip, coordinateSpace:DisplayObject, customData:Object = null):HitBoxAnimation
		{
			if (m_animationsList[mc_name])
				return m_animationsList[mc_name];
			
			var hitBoxAnim:HitBoxAnimation = new HitBoxAnimation(mc_name);
			
			var i:int = 0;
			var j:int = 0;
			var k:int = 0;
			var name:String = null;
			var child:MovieClip = null;
			var tmpMC:MovieClip = new MovieClip();
			var id:String = null;
			var type:String = null;
			tmpMC.graphics.beginFill(0xFF0000, 0);
			tmpMC.graphics.drawCircle(0, 0, 1);
			tmpMC.graphics.endFill();
			
			//For each frame
			for (i = 0; i < mc.totalFrames; i++)
			{
				mc.gotoAndStop(i + 1);
				//For each hit box
				for (j = 0; j < mc.numChildren; j++)
				{
					if (mc.getChildAt(j) is MovieClip)
					{
						child = MovieClip(mc.getChildAt(j));
						name = child.name;
						id = (child.id) ? child.id : (name && name.match(/^instance/g)) ? name : null;
						if (id)
						{
							//An attack box exists with this name, let's add it to the animation
							type = child.type || id.match(/^[a-zA-Z_]+/g)[0];
							
							//For the registration point, we'll use a temporary 1x1 pixel clip (So we can use getBounds() on it and not mess with child)
							mc.addChild(tmpMC);
							tmpMC.x = child.x;
							tmpMC.y = child.y;
							var regPoint:Rectangle = tmpMC.getRect(coordinateSpace);
							var hbox:HitBoxSprite = new HitBoxSprite(type, child.getBounds(coordinateSpace), (child.circular == true), null, new Point(regPoint.x, regPoint.y), new Point(child.scaleX, child.scaleY), child.rotation, child.transform.matrix.clone(), mc.getChildIndex(child));
							mc.removeChild(tmpMC);
							if (hitBoxAnim.addHitBox(i + 1, hbox))
							{
								hbox.Name = id;
								//trace(mc_name + (i + 1) + ":::" + types[j].name + ":::" + child.getBounds(coordinateSpace));
							}
						}
					}
				}
			}
			
			if (tmpMC.parent)
				tmpMC.parent.removeChild(tmpMC);
			tmpMC.graphics.clear();
			tmpMC = null;
			
			return hitBoxAnim;
		}
		
		public function addHitBox(frame:int, hitBox:HitBoxSprite):Boolean
		{
			//Adds hitbox data
			
			var success:Boolean = true;
			var i:int = 0;
			var index:int = -1;
			
			//See if the hit box exists in our array already
			if (!m_hitBoxes[hitBox.Type])
			{
				m_hitBoxes[hitBox.Type] = new Array();
			}
			
			for (i = 0; i < m_hitBoxes[hitBox.Type].length; i++)
			{
				if (m_hitBoxes[hitBox.Type][i].equals(hitBox))
				{
					index = i;
					success = false;
					break;
				}
			}
			if (index < 0)
			{
				//Doesn't exist, let's add it
				m_hitBoxes[hitBox.Type].push(hitBox);
				index = m_hitBoxes[hitBox.Type].length - 1;
			}
			
			//Now we can update the frame info, if the frame or type doesn't exist yet, make a new array for it
			if (!m_hitFrames[hitBox.Type])
				m_hitFrames[hitBox.Type] = {};
				
			if (!m_hitFrames[hitBox.Type][frame])
				m_hitFrames[hitBox.Type][frame] = new Array();
			//Now, add this hit box to the list of hitboxes for this frame
			m_hitFrames[hitBox.Type][frame].push(m_hitBoxes[hitBox.Type][index]);
			
			return success;
		}
		public function getHitBoxes(frame:int, type:String):Array
		{
			//Returns all hit boxes of a given type that exist on a particular frame
			if (m_hitFrames[type] && m_hitFrames[type][frame])
			{
				return m_hitFrames[type][frame];
			}
			return null;
		}
	}
}