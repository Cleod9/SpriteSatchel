package com.mcleodgaming.spritesatchel.core 
{
	import com.adobe.images.PNGEncoder;
	import com.mcleodgaming.spritesatchel.controllers.MenuController;
	import com.mcleodgaming.spritesatchel.events.SpriteSheetEvent;
	import com.mcleodgaming.spritesatchel.Main;
	import com.mcleodgaming.spritesatchel.util.Utils;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class SpriteSheet extends EventDispatcher
	{
		public static const TRANS_COLOR:uint = 0x00113366;
		public static const HEADER_SIZE:int = 80;
		public static const MAX_DIMENSIONS:int = 4096;
		
		protected var _name:String;
		protected var _frames:int;
		protected var _padding:int;
		protected var _bitmapData:BitmapData;
		protected var _animations:Vector.<Animation>;
		
		protected var _currentPoint:Point;
		protected var _currentMaxHeight:int;
		protected var _previousWidth:int;
		protected var _rowStart:Boolean;
		protected var _timer:Timer;
		
		public function SpriteSheet(name:String) 
		{
			super(null);
			_name = name;
			_frames = 0;
			_padding = 60;
			_bitmapData = null;
			_animations = new Vector.<Animation>();
			_currentPoint = new Point();
			_currentMaxHeight = 0;
			_previousWidth = 0;
			_rowStart = true; //For the first MC of any row, we assume we don't need to check for space in the spritesheet
			_timer = new Timer(20, 1);
		}	
		public function get Name():String
		{
			return _name;
		}
		public function importMovieClip(mc:MovieClip, forceXScale:Number = 1, forceYScale:Number = 1):void
		{
			_currentPoint = new Point();
			_currentMaxHeight = 0;
			_previousWidth = 0;
			_rowStart = true;
			if (_bitmapData)
				_bitmapData.dispose();
			_bitmapData = new BitmapData(128, 128, true, SpriteSheet.TRANS_COLOR);
			
			var i:int = 0;
			_timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void { 
				if (i > mc.totalFrames) {
					mc.gotoAndStop(1);
					dispatchEvent(new SpriteSheetEvent(SpriteSheetEvent.IMPORT_COMPLETE, "Import job completed."));
					return;
				}
				var frameLabel:String = (mc.currentLabel) ? mc.currentLabel : "animation" + (mc.currentFrame - 1);
				mc.gotoAndStop(i + 1);
				dispatchEvent(new SpriteSheetEvent(SpriteSheetEvent.STATUS, "Processing " + frameLabel + "..."));
				for (var j:int = 0; j < mc.numChildren; j++)
				{
					if (mc.getChildAt(j) is MovieClip)
					{
						Utils.removeActionScript(mc.getChildAt(j) as MovieClip);
						importAnimation((mc.currentLabel) ? mc.currentLabel : "animation" + (mc.currentFrame - 1), mc.getChildAt(j) as MovieClip);
						break; //To next animation
					}
				}
				e.updateAfterEvent();
				i++;
				_timer.reset();
				_timer.start();
			});
			_timer.start();
		}
		public function importAnimation(name:String, mc:MovieClip, forceXScale:Number = 1, forceYScale:Number = 1):void
		{
			var animation:Animation = new Animation(name); 
			_animations.push(animation);
			
			var frameNum:int = 1;
			var scaleX:Number = 1;
			var scaleY:Number = 1;
			var origScaleX:Number = 1;
			var origScaleY:Number = 1;
			var prevSprite:SpriteObject = null;
			
			//This will track the scale of the MC
			//The graphics are captured in origScaleX/origScaleY size and we treat this as scaleX/scaleY of 1
			origScaleX = (forceXScale == 1) ? mc.scaleX : forceXScale;
			origScaleY = (forceYScale == 1) ? mc.scaleY : forceYScale;
			scaleX = origScaleX;
			scaleY = origScaleY;
			
			//For each frame in the movie clip we are importing
			for (var i:int = 1; i <= mc.totalFrames; i++, frameNum++)
			{
				//Force MC to gotoAndStop() on next frame
				if(mc.currentFrame + 1 == i)
					mc.nextFrame(); //Use standard next frame method
				else if (mc.currentFrame != i)
					mc.gotoAndStop(i); //If frame is otherwise different, force gotoAndStop()
					
				Utils.recursiveMovieClipPlay(mc, true);
				if (frameNum != mc.currentFrame)
				{
					//In this case, the MC had AS in it which caused it not to stop, so we'll use whatever the previous frame contained
					animation.sprites.push((prevSprite != null) ? prevSprite.clone() : null);
				} else
				{
					//Ready to capture Bitmap of this frame
					var boundsRect:Rectangle = mc.getBounds(mc);
					var optimalDimensions:Rectangle = Utils.getVisibleBounds(mc, null); //Only capture visible area
					var registrationRect:Rectangle = mc.getBounds(mc.parent); //Get registration point based on parent
					
					/*boundsRect.x += optimalDimensions.x;
					boundsRect.y += optimalDimensions.y;
					boundsRect.width = optimalDimensions.width;
					boundsRect.height = optimalDimensions.height;
					
					registrationRect.x += optimalDimensions.x;
					registrationRect.y += optimalDimensions.y;*/
					
					//Add optimal dimension offset to bounds rect
					boundsRect.x += optimalDimensions.x - _padding;
					boundsRect.y += optimalDimensions.y - _padding;
					
					//Override width with optimized width
					boundsRect.width = Math.ceil(optimalDimensions.width + _padding * 2);
					boundsRect.height = Math.ceil(optimalDimensions.height + _padding * 2);
					
					//Fix registration point from the slicing
					registrationRect.x += optimalDimensions.x - _padding;
					registrationRect.y += optimalDimensions.y - _padding;
					
					
					//Round everything
					boundsRect.x = Math.floor(boundsRect.x);
					boundsRect.y = Math.floor(boundsRect.y);
					registrationRect.x = Math.round(registrationRect.x);
					registrationRect.y = Math.round(registrationRect.y);
					
					
					if (boundsRect.width == 0)
					{
						//The MC didn't contain any graphics, so we'll just make a blank pixel here
						boundsRect.width = 1;
						boundsRect.height = 1;
					} else
					{
						//Add an extra 2 pixel buffer due to clipping issue with getBounds()
						boundsRect.width += 2;
						boundsRect.height += 2;
					}
					
					//Create the blank bitmap for the frame and get transform info
					var currentFrameBitmap:BitmapData = new BitmapData(int(boundsRect.width * scaleX + 0.5), int(boundsRect.height * scaleY + 0.5), true, SpriteSheet.TRANS_COLOR);
					
					//Get offset information (prevOffset refers to the position of the top left of the graphic within the MC bounds)
					var prevOffset:Point = new Point();
					prevOffset.x = boundsRect.x;
					prevOffset.y = boundsRect.y;
					var offset:Matrix = new Matrix();
					offset.tx = -prevOffset.x;
					offset.ty = -prevOffset.y;
					offset.scale(scaleX, scaleY);
					if (mc.transform.matrix.a < 0 || mc.transform.matrix.d < 0)
					{
						//This MC is flipped horizontally or vertically so we need to deal with it
						var flipMat:Matrix = new Matrix();
						flipMat.a = (mc.transform.matrix.a < 0) ? -1 : 1; //Horizontal flip
						flipMat.d = (mc.transform.matrix.d < 0) ? -1 : 1; //Vertical flip
						flipMat.translate((flipMat.a < 0) ? boundsRect.width : 0, (flipMat.d < 0) ? boundsRect.height : 0); //Readjust the offset (flips over and repositions)
						offset.concat(flipMat); //Combine with the current matrix
					}
					
					//On the off chance we have a sprite that has the EXACT same pixels as this one, we want to save memory by referring back to that sprite instead
					//Basically what we're doing here is making the "location" of the current sprite on the sprite sheet the same as a pre-existing one
					var skipSheet:Boolean = false;
					var upcomingBMPDat:BitmapData = new BitmapData(int(boundsRect.width * scaleX + 0.5), int(boundsRect.height * scaleY + 0.5), true, SpriteSheet.TRANS_COLOR);
					upcomingBMPDat.draw(mc, offset, mc.transform.colorTransform, null, null, true);
					for (var j:int = 0; j < _frames; j++)
					{
						var currentSprite:SpriteObject = findByImageIndex(j);
						if (!currentSprite)
							continue;
						var tmpBMPDat:BitmapData = new BitmapData(currentSprite.rect.width, currentSprite.rect.height, true, SpriteSheet.TRANS_COLOR);
						tmpBMPDat.copyPixels(_bitmapData,currentSprite.rect, new Point(), null, null, true);
						if (tmpBMPDat.compare(upcomingBMPDat) == 0)
						{
							//Match found, reference the old data
							animation.sprites.push(new SpriteObject(currentSprite.imageIndex, currentSprite.rect.clone(), currentSprite.registration.clone()));
							skipSheet = true;
							break;
						}
					}
					upcomingBMPDat.dispose();
					if (skipSheet)
						continue; //We're just going to use an already existing sprite
					
					//Before we draw the bitmap into our sprite sheet, we need to place it in a specific location
					if(!_rowStart)
						_currentPoint.x += _previousWidth + 1;
					if (_currentPoint.x + currentFrameBitmap.width > SpriteSheet.MAX_DIMENSIONS)
					{
						if (_rowStart)
							dispatchEvent(new SpriteSheetEvent(SpriteSheetEvent.STATUS, "Error, the first sprite of the sheet exceed maximum BitmapData dimensions"));
						//Advance to the next spot on our sprite sheet (with 1 pixel buffer)
						//Out of sheet width, next row of sprites begins
						_currentPoint.x = 0;
						_currentPoint.y += _currentMaxHeight + 1;
						_currentMaxHeight = 0;
					}
					
					//No longer on the first sprite i nthe row
					_rowStart = false;
					
					//Save the previous width for when we move the point on the sheet later
					_previousWidth = currentFrameBitmap.width;
					
					//Store the current max height since we may need to resize our sheet (we also want to track where the next row will be)
					_currentMaxHeight = Math.max(currentFrameBitmap.height, _currentMaxHeight);
					
					//At this point we have the location that the sprite is being put on the sprite sheet, so let's save this info in a Rectangle object
					
					//Save this as our "previous" sprite and add it to our animation frames 
					prevSprite = new SpriteObject(_frames++, new Rectangle(_currentPoint.x, _currentPoint.y, currentFrameBitmap.width, currentFrameBitmap.height), new Point(registrationRect.x, registrationRect.y));
					animation.sprites.push(prevSprite);
					
					//Before we draw, let's make sure we can actually fit the sprite on our sheet
					var resizedSheet:BitmapData = null;
					while (_currentPoint.x + currentFrameBitmap.width >= _bitmapData.width && _currentPoint.x + currentFrameBitmap.width < SpriteSheet.MAX_DIMENSIONS)
					{
						//Increase width 100 pixels at a time until we have enough width or we reach the max sheet width
						resizedSheet = new BitmapData(_bitmapData.width * 2, _bitmapData.height, true, SpriteSheet.TRANS_COLOR);
						resizedSheet.copyPixels(_bitmapData, _bitmapData.rect, new Point(), null, null, true);
						_bitmapData.dispose();
						_bitmapData = resizedSheet;
					}
					while (_currentPoint.y + currentFrameBitmap.height > _bitmapData.height && _currentPoint.y + currentFrameBitmap.height < SpriteSheet.MAX_DIMENSIONS)
					{
						//Increase height 100 pixels at a time until we have enough height or we reach max sheet height
						resizedSheet = new BitmapData(_bitmapData.width, _bitmapData.height * 2, true, SpriteSheet.TRANS_COLOR);
						resizedSheet.copyPixels(_bitmapData, _bitmapData.rect, new Point(), null, null, true);
						_bitmapData.dispose();
						_bitmapData = resizedSheet;
					}
					
					//Now we can draw the new bitmap onto our spritesheet after we get the snapshot from the MC
					currentFrameBitmap.draw(mc, offset, mc.transform.colorTransform, null, null, true);
					_bitmapData.copyPixels(currentFrameBitmap, currentFrameBitmap.rect, _currentPoint, null, null, true);
				}
			}
		}
		public function findByImageIndex(imageIndex:int):SpriteObject
		{
			var result:SpriteObject = null;
			for (var i:int = 0; i < _animations.length; i++)
			{
				result = _animations[i].findByImageIndex(imageIndex);
				if (result)
					return result;
			}
			return null;
		}
		public function saveSpriteSheet():void 
		{
			var headerMC:MovieClip = new MovieClip();
			var headerText:TextField = new TextField();
			var headerBMP:BitmapData = new BitmapData(_bitmapData.width, HEADER_SIZE, true, SpriteSheet.TRANS_COLOR);
			headerText.multiline = true;
			headerText.width = _bitmapData.width;
			headerText.height = HEADER_SIZE;
			headerText.text = _name + "\nSheet Size [" + _bitmapData.width + "x" + (_bitmapData.height) + "]\nThis spritesheet was generated by SpriteSatchel\n(c) 2013 Greg McLeod. http://www.mcleodgaming.com";
			headerText.setTextFormat(new TextFormat("Courier New", 12, 0x000000));
			headerMC.addChild(headerText);
			headerMC.graphics.lineStyle(1);
			headerMC.graphics.moveTo(0, 0);
			headerMC.graphics.lineTo(_bitmapData.width, 0);
			headerBMP.draw(headerMC, null, null, null, null, false);
			
			var fullsheet:BitmapData = new BitmapData(_bitmapData.width, _bitmapData.height + HEADER_SIZE, true, SpriteSheet.TRANS_COLOR);
			fullsheet.copyPixels(_bitmapData, _bitmapData.rect, new Point(), null, null, true);
			fullsheet.copyPixels(headerBMP, headerBMP.rect, new Point(0, fullsheet.height - HEADER_SIZE), null, null, true);
			
			var imgByteArray:ByteArray = PNGEncoder.encode(fullsheet);
			var	fileRef:FileReference = new FileReference();
			fileRef.addEventListener(Event.SELECT, function(e:Event):void {} ); 
			fileRef.addEventListener(IOErrorEvent.IO_ERROR,  function(e:IOErrorEvent):void {
				dispatchEvent(new SpriteSheetEvent(SpriteSheetEvent.EXPORT_COMPLETE, "Export job completed with IOError.")); 
			}); 
			fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
				dispatchEvent(new SpriteSheetEvent(SpriteSheetEvent.EXPORT_COMPLETE, "Export job completed with SecurityError.")); 
			}); 
			fileRef.addEventListener(ProgressEvent.PROGRESS, function(e:Event):void {}); 
			fileRef.addEventListener(Event.COMPLETE, function(e:Event):void { 
				saveJSON();  
			});
			fileRef.save(imgByteArray, _name + ".png"); 
		}
		public function saveJSON():void
		{
			var tabs:String = "";
			var jsonData:String = "{" + Main.NEWLINE;
			tabs += "\t";
			
			jsonData += tabs + "\"frames\": [" + Main.NEWLINE;
			tabs += "\t";
			
			for (var frameNum:int = 0; frameNum < _frames; frameNum++)
			{
				var singleFrame:SpriteObject = findByImageIndex(frameNum);
				jsonData += tabs + "[" + singleFrame.rect.x + ", " + singleFrame.rect.y + ", " + singleFrame.rect.width + ", " + singleFrame.rect.height + ", " + 0 + ", " + -singleFrame.registration.x + ", " + -singleFrame.registration.y + "]," + Main.NEWLINE;
			}
			jsonData = jsonData.substr(0, jsonData.lastIndexOf(",")) + jsonData.substr(jsonData.lastIndexOf("," + 1));
			tabs = tabs.substr(1);
			
			jsonData += tabs + "]," + Main.NEWLINE;
			
			jsonData += tabs + "\"images\": [\"" + _name + ".png\"]," + Main.NEWLINE;
			
			jsonData += tabs + "\"animations\": {";
			
			var animations:Array = new Array();
			for (var animationNum:int = 0; animationNum < _animations.length; animationNum++)
			{
				jsonData += "\"" + _animations[animationNum].id + "\": {";
				var framesList:Array = new Array();
				for (var i:int = 0; i < _animations[animationNum].sprites.length; i++)
				{
					framesList.push(_animations[animationNum].sprites[i].imageIndex);
				}
				jsonData += "\"frames\": [" + framesList.join(", ") + "]";
				jsonData += "}, ";
			}
			jsonData = jsonData.substr(0, jsonData.lastIndexOf(",")) + "}" + Main.NEWLINE;
			
			tabs = tabs.substr(1);
			
			jsonData += tabs + "}";
			
			var bArr:ByteArray = new ByteArray();
			bArr.writeUTFBytes(jsonData);
			
			var fileReference:FileReference = new FileReference();
			fileReference.addEventListener(Event.SELECT, function(e:Event):void {} ); 
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				dispatchEvent(new SpriteSheetEvent(SpriteSheetEvent.EXPORT_COMPLETE, "Export job completed with IOError.")); 
			}); 
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
				dispatchEvent(new SpriteSheetEvent(SpriteSheetEvent.EXPORT_COMPLETE, "Export job completed with SecurityError.")); 
			}); 
			fileReference.addEventListener(ProgressEvent.PROGRESS,  function(e:ProgressEvent):void {}); 
			fileReference.addEventListener(Event.COMPLETE, function(e:Event):void { 
				dispatchEvent(new SpriteSheetEvent(SpriteSheetEvent.EXPORT_COMPLETE, "Export job completed.")); 
			});
			
			fileReference.save(bArr, _name + ".json");
		}
	}
}