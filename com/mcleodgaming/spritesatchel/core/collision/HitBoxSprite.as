package com.mcleodgaming.spritesatchel.core.collision 
{
	import com.adobe.serialization.json.JSON;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	
	public class HitBoxSprite 
	{
		private var m_name:String;
		private var m_type:String;
		private var m_rectangle:Rectangle;
		private var m_flippedRectangle:Rectangle; //For time saving purposes
		private var m_rotation:Number;
		private var m_transform:Matrix;
		private var m_regPoint:Point;
		private var m_scale:Point;
		private var m_depth:int;
		private var m_customData:Object;
		
		public function HitBoxSprite(type:String, rectangle:Rectangle, customData:Object = null, regPoint:Point = null, scale:Point = null, rotation:Number = 0, transform:Matrix = null, depth:int = 0) 
		{
			m_name = null;
			m_type = type;
			m_rectangle = rectangle;
			m_customData = customData;
			m_flippedRectangle = new Rectangle( -rectangle.x - rectangle.width, rectangle.y, rectangle.width, rectangle.height); //Flipped over X-axis
			m_rotation = rotation;
			m_regPoint = (regPoint) ? regPoint : new Point(rectangle.x, rectangle.y);
			m_scale = (scale) ? scale : new Point(1, 1);
			m_transform = (transform) ? transform : new Matrix();
			m_depth = depth;
		}
		
		public function get x():Number
		{
			return m_rectangle.x;
		}
		public function get y():Number
		{
			return m_rectangle.y;
		}
		public function get xreg():Number
		{
			return m_regPoint.x;
		}
		public function get yreg():Number
		{
			return m_regPoint.y;
		}
		public function get width():Number
		{
			return m_rectangle.width;
		}
		public function get height():Number
		{
			return m_rectangle.height;
		}
		public function get scaleX():Number
		{
			return m_scale.x
		}
		public function get scaleY():Number
		{
			return m_scale.y;
		}
		public function get rotation():Number
		{
			return m_rotation;
		}
		public function get transform():Matrix
		{
			return m_transform;
		}
		public function get depth():int
		{
			return m_depth;
		}
		public function get centerx():Number
		{
			return m_rectangle.x + m_rectangle.width / 2;
		}
		public function get centery():Number
		{
			return m_rectangle.y + m_rectangle.height / 2;
		}
		public function get Name():String
		{
			return m_name;
		}
		public function set Name(value:String):void
		{
			m_name = value;
		}
		public function get Type():String
		{
			return m_type;
		}
		public function get BoundingBox():Rectangle
		{
			return m_rectangle;
		}
		public function get FlippedBoundingBox():Rectangle
		{
			return m_flippedRectangle;
		}
		public function get CustomData():Object
		{
			return m_customData;
		}
		public function set CustomData(value:Object):void
		{
			m_customData = value;
		}
		
		public function equals(hitBox:HitBoxSprite):Boolean
		{
			return (m_type == hitBox.Type && m_rectangle.equals(hitBox.BoundingBox) && m_regPoint.equals(hitBox.m_regPoint) && m_scale.equals(hitBox.m_scale) && m_rotation == hitBox.rotation && m_transform.a == hitBox.transform.a && m_transform.b == hitBox.transform.b && m_transform.c == hitBox.transform.c && m_transform.d == hitBox.transform.d && m_transform.tx == hitBox.transform.tx && m_transform.ty == hitBox.transform.ty && m_depth == hitBox.depth);
		}
		public function export(frame:int):String
		{
			var obj:Object = { };
			obj.name = m_name;
			obj.type = m_type;
			obj.rect = { x: m_rectangle.x, y: m_rectangle.y, width: m_rectangle.width, height: m_rectangle.height };
			obj.transform = { a: m_transform.a, b: m_transform.b, c: m_transform.c, d: m_transform.d, tx: m_transform.tx, ty: m_transform.ty };
			obj.reg = { x: m_regPoint.x, y: m_regPoint.y };
			obj.scale = { x: scaleX, y: scaleY };
			obj.depth = m_depth;
			obj.rotation = m_rotation;
			obj.customData = null;
			obj.frame = frame;
			
			return com.adobe.serialization.json.JSON.encode(obj);
		}
	}
}