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
		
		public function findByFrameIndex(frameIndex:int):SpriteObject
		{
			for (var i:int = 0; i < sprites.length; i++)
			{
				if (sprites[i].frameIndex == frameIndex)
					return sprites[i];
			}
			return null;
		}
	}
}