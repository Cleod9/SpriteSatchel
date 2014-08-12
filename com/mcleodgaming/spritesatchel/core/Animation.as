package com.mcleodgaming.spritesatchel.core 
{
	import com.mcleodgaming.spritesatchel.core.collision.HitBoxAnimation;
	public class Animation 
	{
		public var id:String;
		public var sprites:Vector.<SpriteObject>;
		public var hitboxes:HitBoxAnimation;
		
		public function Animation(id:String) 
		{
			this.id = id;
			sprites = new Vector.<SpriteObject>();
			hitboxes = null;
		}
		
		public function findByImageIndex(imageIndex:int):SpriteObject
		{
			for (var i:int = 0; i < sprites.length; i++)
			{
				if (sprites[i].imageIndex == imageIndex)
					return sprites[i];
			}
			return null;
		}
	}
}