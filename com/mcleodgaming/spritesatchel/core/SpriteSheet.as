package com.mcleodgaming.spritesatchel.core 
{
	import com.adobe.images.PNGEncoder;
	import com.mcleodgaming.spritesatchel.controllers.MenuController;
	import com.mcleodgaming.spritesatchel.core.collision.HitBoxAnimation;
	import com.mcleodgaming.spritesatchel.core.collision.HitBoxSprite;
	import com.mcleodgaming.spritesatchel.events.EventManager;
	import com.mcleodgaming.spritesatchel.events.SpriteSatchelEvent;
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
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class SpriteSheet
	{
		public static const TRANS_COLOR:uint = 0x00113366;
		
		protected var _name:String;
		protected var _frames:int;
		protected var _padding:int;
		protected var _spriteBitmaps:Vector.<SpriteBitmap>;
		protected var _animations:Vector.<Animation>;
		
		public function SpriteSheet(name:String) 
		{
			_name = name;
			_frames = 0;
			_padding = 0;
			_spriteBitmaps = new Vector.<SpriteBitmap>();
			_animations = new Vector.<Animation>();
		}	
		public function get Name():String
		{
			return _name;
		}
		public function importMovieClip(mc:MovieClip, forceXScale:Number = 1, forceYScale:Number = 1):void
		{
			var timer:Timer = new Timer(20, 1);
			while (_spriteBitmaps.length)
			{
				_spriteBitmaps[0].dispose();
				_spriteBitmaps.splice(0, 1);
			}
			_spriteBitmaps.push(new SpriteBitmap());
			
			var i:int = 0;
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void { 
				if (i >= mc.totalFrames) {
					timer.stop();
					mc.gotoAndStop(1);
					EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.IMPORT_COMPLETE, "Import job completed. Generating PNG..."));
					return;
				}
				mc.gotoAndStop(i + 1);
				var frameLabel:String = (mc.currentLabel) ? mc.currentLabel : "animation" + (mc.currentFrame - 1);
				EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.STATUS, "Processing " + frameLabel + "..."));
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
				timer.reset();
				timer.start();
			});
			timer.start();
		}
		public function importAnimation(name:String, mc:MovieClip, forceXScale:Number = 1, forceYScale:Number = 1, startingFrame:int = 1, targetSpriteBitmap:SpriteBitmap = null):void
		{
			var animation:Animation = new Animation(name); 
			_animations.push(animation);
			
			var frameNum:int = startingFrame;
			var scaleX:Number = 1;
			var scaleY:Number = 1;
			var origScaleX:Number = 1;
			var origScaleY:Number = 1;
			var prevSprite:SpriteObject = null;
			var tmpMC:MovieClip;
			var k:int;
			var targetSheet:SpriteBitmap = targetSpriteBitmap || _spriteBitmaps[0];
			var targetSheetIndex:int = _spriteBitmaps.indexOf(targetSheet);
			
			//This will track the scale of the MC
			//The graphics are captured in origScaleX/origScaleY size and we treat this as scaleX/scaleY of 1
			origScaleX = (forceXScale == 1) ? mc.scaleX : forceXScale;
			origScaleY = (forceYScale == 1) ? mc.scaleY : forceYScale;
			scaleX = origScaleX;
			scaleY = origScaleY;
			
			animation.hitboxes = HitBoxAnimation.createHitBoxAnimation(_name + "_" + name, mc, mc.parent, null);
			
			//For each frame in the movie clip we are importing
			mc.gotoAndStop(frameNum);
			for (var i:int = frameNum; i <= mc.totalFrames; i++, frameNum++)
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
					for (var hindex:int = 0; hindex < mc.numChildren; hindex++)
					{
						if (mc.getChildAt(hindex) is MovieClip)
						{
							tmpMC = MovieClip(mc.getChildAt(hindex));
							
							if (((tmpMC.id) || (tmpMC.name && !tmpMC.name.match(/^instance/g))) && !MovieClip(mc.getChildAt(hindex)).forceVisible)
							{
								mc.getChildAt(hindex).visible = false;
							}
						}
					}
					//Ready to capture Bitmap of this frame
					//TODO: Fix bug where in optimize-mode we can't have MC scaling, falls back to getBounds()
					var optimize:Boolean = true;
					var boundsRect:Rectangle = (optimize && (scaleX == 1 && scaleY == 1)) ?  Utils.getVisibleBounds(mc, mc) : mc.getBounds(mc);
					var registrationPoint:Point = new Point();
			
					//Padding (Always add additional 2 pixels due to getBounds() clipping issue)
					boundsRect.offset( -_padding, -_padding);
					boundsRect.width += _padding * 2 + 2;
					boundsRect.height += _padding * 2 + 2;
					
					//Round down the bounds to prevent jitter
					boundsRect.x = Math.floor(boundsRect.x);
					boundsRect.y = Math.floor(boundsRect.y);
					
					//Registration point relative to parent clip
					registrationPoint.x = Math.round((boundsRect.x * scaleX) + mc.x);
					registrationPoint.y = Math.round((boundsRect.y * scaleY) + mc.y);
					
					if (boundsRect.width == 0)
					{
						//The MC didn't contain any graphics, so we'll just make a blank pixel here
						boundsRect.width = 1;
						boundsRect.height = 1;
					}
					
					//Create the blank bitmap for the frame and get transform info
					var currentFrameBitmap:BitmapData = new BitmapData(Math.ceil(boundsRect.width * scaleX), Math.ceil(boundsRect.height * scaleY), true, SpriteSheet.TRANS_COLOR);
					
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
					var upcomingBMPDat:BitmapData = new BitmapData(Math.ceil(boundsRect.width * scaleX), Math.ceil(boundsRect.height * scaleY), true, SpriteSheet.TRANS_COLOR);
					upcomingBMPDat.draw(mc, offset, mc.transform.colorTransform, null, null, true);
					
					// Note: If targetSpriteBitmap was defined we already checked for dupes
					for (k = 0; k < _spriteBitmaps.length && !skipSheet && !targetSpriteBitmap; k++)
					{
						var currentSheet:BitmapData = _spriteBitmaps[k].bitmapData;
						for (var j:int = 0; j < _frames && !skipSheet; j++)
						{
							var currentSprite:SpriteObject = findByImageIndex(j);
							//Fail if sprite doesn't exist, the registration point doesn't match, or the rectangle is not the same height/width
							if (!currentSprite || !(currentFrameBitmap.rect.width === currentSprite.rect.width && currentFrameBitmap.rect.height === currentSprite.rect.height))
								continue;
							var tmpBMPDat:BitmapData = new BitmapData(currentSprite.rect.width, currentSprite.rect.height, true, SpriteSheet.TRANS_COLOR);
							tmpBMPDat.copyPixels(currentSheet, currentSprite.rect, new Point(), null, null, true);
							if (tmpBMPDat.compare(upcomingBMPDat) == 0)
							{
								//Store the new sprite object
								if (currentSprite.registration.equals(registrationPoint))
								{
									//Same registration point, we can re-use this slot on the sheet
									animation.sprites.push(new SpriteObject(currentSprite.imageIndex, currentSprite.rect.clone(), currentSprite.registration.clone(), targetSheetIndex));
								} else
								{
									//Differing registration point, we'll have to insert a new frame index
									animation.sprites.push(new SpriteObject(_frames++, currentSprite.rect.clone(), registrationPoint.clone(), targetSheetIndex));
								}
								skipSheet = true;
							}
							tmpBMPDat.dispose();
						}
					}
					
					//Dispose and skip next if we are on a duplicate frame
					upcomingBMPDat.dispose();
					if (skipSheet)
						continue; //We're just going to use an already existing sprite
					
					//Before we draw the bitmap into our sprite sheet, we need to place it in a specific location
					if(!targetSheet.rowStart)
						targetSheet.currentPoint.x += targetSheet.previousWidth + 1;
					if (targetSheet.currentPoint.x + currentFrameBitmap.width > Main.Config.MaxWidth)
					{
						if (targetSheet.rowStart)
							EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.STATUS, "Error, the first sprite of the sheet exceed maximum BitmapData dimensions"));
						//Advance to the next spot on our sprite sheet (with 1 pixel buffer)
						//Out of sheet width, next row of sprites begins
						targetSheet.currentPoint.x = 0;
						targetSheet.currentPoint.y += targetSheet.currentMaxHeight + 1;
						targetSheet.currentMaxHeight = 0;
					}
					
					//No longer on the first sprite in the row
					targetSheet.rowStart = false;
					
					//Save the previous width for when we move the point on the sheet later
					targetSheet.previousWidth = currentFrameBitmap.width;
					
					//Store the current max height since we may need to resize our sheet (we also want to track where the next row will be)
					targetSheet.currentMaxHeight = Math.max(currentFrameBitmap.height, targetSheet.currentMaxHeight);
					
					//At this point we have the location that the sprite is being put on the sprite sheet, so let's save this info in a Rectangle object
					
					//Save this as our "previous" sprite for next loop and add it to our animation frames 
					prevSprite = new SpriteObject(_frames++, new Rectangle(targetSheet.currentPoint.x, targetSheet.currentPoint.y, currentFrameBitmap.width, currentFrameBitmap.height),registrationPoint.clone(), targetSheetIndex);
					animation.sprites.push(prevSprite);
					
					//Before we draw, let's make sure we can actually fit the sprite on our sheet
					var resizedSheet:BitmapData = null;
					while (targetSheet.currentPoint.x + currentFrameBitmap.width >= targetSheet.bitmapData.width && targetSheet.currentPoint.x + currentFrameBitmap.width < Main.Config.MaxWidth)
					{
						// Double width we have enough width or we reach the max sheet width
						resizedSheet = new BitmapData(targetSheet.bitmapData.width * 2, targetSheet.bitmapData.height, true, SpriteSheet.TRANS_COLOR);
						resizedSheet.copyPixels(targetSheet.bitmapData, targetSheet.bitmapData.rect, new Point(), null, null, true);
						targetSheet.dispose();
						targetSheet.bitmapData = resizedSheet;
					}
					while (targetSheet.currentPoint.y + currentFrameBitmap.height >= targetSheet.bitmapData.height && targetSheet.currentPoint.y + currentFrameBitmap.height < Main.Config.MaxHeight)
					{
						// Double height until we have enough height or we reach max sheet height
						resizedSheet = new BitmapData(targetSheet.bitmapData.width, targetSheet.bitmapData.height * 2, true, SpriteSheet.TRANS_COLOR);
						resizedSheet.copyPixels(targetSheet.bitmapData, targetSheet.bitmapData.rect, new Point(), null, null, true);
						targetSheet.dispose();
						targetSheet.bitmapData = resizedSheet;
					}
					
					if (targetSheet.currentPoint.x + currentFrameBitmap.width > targetSheet.bitmapData.width || targetSheet.currentPoint.y + currentFrameBitmap.height > targetSheet.bitmapData.height)
					{
						// Image did not fit on sheet, bail this function and check the next sheet
						if (targetSheetIndex + 1 >= _spriteBitmaps.length)
						{
							// Need to make a new bitmap first before doing
							_spriteBitmaps.push(new SpriteBitmap());
						}
						importAnimation(name, mc, forceXScale, forceYScale, frameNum, _spriteBitmaps[_spriteBitmaps.length - 1]);
						return;
					}
					
					//Now we can draw the new bitmap onto our spritesheet after we get the snapshot from the MC
					currentFrameBitmap.draw(mc, offset, mc.transform.colorTransform, null, null, true);
					targetSheet.bitmapData.copyPixels(currentFrameBitmap, currentFrameBitmap.rect, targetSheet.currentPoint, null, null, true);
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
		public function exportAll(pngPath:String, jsonPath:String):void 
		{
			saveSpriteSheet(pngPath);
			saveJSON(jsonPath);
			EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.EXPORT_COMPLETE, "Export job completed.")); 
			HitBoxAnimation.flushCache();
		}
		public function saveSpriteSheet(pngPath:String):void
		{
			var targetPath:String;
			for (var i:int = 0; i < _spriteBitmaps.length; i++)
			{
				targetPath = pngPath;
				//First fix path
				var prefix:String = "";
				if (targetPath.indexOf(".") == 0)
				{
					//Relative to absolute
					if (!Main.Config.FilePath)
					{
						EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.STATUS, "Warning, cannot export " + _name + ".png to relative File path before saving Project.")); 
						return;
					} else
					{
						prefix = Main.Config.FilePath.substr(0, Main.Config.FilePath.lastIndexOf(File.separator)) + File.separator + targetPath + File.separator;
					}
				} else
				{
					//Already absolute
					prefix = targetPath + File.separator;
				}
				// Append # to the name if there's more than one sheet
				targetPath = (_spriteBitmaps.length > 1) ? prefix + _name + i + ".png" : prefix + _name + ".png";
				var directory:File = new File(prefix);
				if (!directory.exists)
					directory.createDirectory();
				
				var fullsheet:BitmapData = _spriteBitmaps[i].bitmapData;
				var imgByteArray:ByteArray = PNGEncoder.encode(fullsheet);
				
				var	fs:FileStream = new FileStream();
				fs.open(new File(targetPath), FileMode.WRITE);
				fs.addEventListener(Event.SELECT, function(e:Event):void {} ); 
				fs.addEventListener(IOErrorEvent.IO_ERROR,  function(e:IOErrorEvent):void {
					//EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.EXPORT_COMPLETE, "Export job completed with IOError.")); 
				}); 
				fs.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
					//EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.EXPORT_COMPLETE, "Export job completed with SecurityError.")); 
				}); 
				fs.addEventListener(ProgressEvent.PROGRESS, function(e:Event):void {}); 
				fs.addEventListener(Event.COMPLETE, function(e:Event):void { 
				});
				fs.writeBytes(imgByteArray);
				fs.close();
			}
		}
		public function saveJSON(jsonPath:String):void
		{
			var i:int = 0;
			//First fix path
			var prefix:String = "";
			var imageStrings:Array = new Array();
			if (_spriteBitmaps.length > 1)
			{
				// Append # to the name if there's more than one sheet
				for (i = 0; i < _spriteBitmaps.length; i++)
				{
					imageStrings.push('"' + Main.Config.PNGExportPath + File.separator + _name + i + '.png"');
				}
			} else
			{
				imageStrings.push('"' + Main.Config.PNGExportPath + File.separator + _name + '.png"');
			}
			
			if (jsonPath.indexOf(".") == 0)
			{
				//Relative to absolute
				if (!Main.Config.FilePath)
				{
					EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.STATUS, "Warning, cannot export " + _name + ".json to relative File path before saving Project.")); 
					return;
				} else
				{
					prefix = Main.Config.FilePath.substr(0, Main.Config.FilePath.lastIndexOf(File.separator)) + File.separator + jsonPath + File.separator;
				}
			} else
			{
				//Already absolute
				prefix = jsonPath + File.separator;
			}
			jsonPath = prefix + _name + ".json";
			var directory:File = new File(prefix);
			if (!directory.exists)
				directory.createDirectory();
			
			var tabs:String = "";
			var jsonData:String = "{" + Main.NEWLINE;
			tabs += "\t";
			
			jsonData += tabs + "\"frames\": [" + Main.NEWLINE;
			tabs += "\t";
			
			for (var frameNum:int = 0; frameNum < _frames; frameNum++)
			{
				var singleFrame:SpriteObject = findByImageIndex(frameNum);
				jsonData += tabs + "[" + singleFrame.rect.x + ", " + singleFrame.rect.y + ", " + singleFrame.rect.width + ", " + singleFrame.rect.height + ", " + singleFrame.sheetIndex + ", " + -singleFrame.registration.x + ", " + -singleFrame.registration.y + "]," + Main.NEWLINE;
			}
			jsonData = jsonData.substr(0, jsonData.lastIndexOf(",")) + jsonData.substr(jsonData.lastIndexOf("," + 1));
			tabs = tabs.substr(1);
			
			jsonData += tabs + "]," + Main.NEWLINE;
			
			jsonData += tabs + ("\"images\": [" + imageStrings.join(', ') + "]," + Main.NEWLINE).split(File.separator).join("/");
			
			jsonData += tabs + "\"animations\": {";
			
			var animations:Array = new Array();
			for (var animationNum:int = 0; animationNum < _animations.length; animationNum++)
			{
				jsonData += "\"" + _animations[animationNum].id + "\": {";
				var framesList:Array = new Array();
				for (i = 0; i < _animations[animationNum].sprites.length; i++)
				{
					framesList.push(_animations[animationNum].sprites[i].imageIndex);
				}
				jsonData += "\"frames\": [" + framesList.join(", ") + "]";
				
				var hitboxAnimation:HitBoxAnimation = _animations[animationNum].hitboxes || null;
				var combinedBoxes:Array = new Array();
				var combinedFrames:Array = new Array();
				if (hitboxAnimation)
				{
					for (var type:* in hitboxAnimation.HitFramesMap)
					{
						for (var frame:* in hitboxAnimation.HitFramesMap[type])
						{
							for (var box:* in hitboxAnimation.HitFramesMap[type][frame])
							{
								combinedBoxes.push(HitBoxSprite(hitboxAnimation.HitFramesMap[type][frame][box]).export(parseInt(frame)));
							}
						}
					}
				}
				
				if (combinedBoxes.length)
				{
					jsonData += ",\"hitboxes\":[";
					jsonData += combinedBoxes.join(",") + "]"
				}
				
				jsonData += "}, ";
			}
			jsonData = jsonData.substr(0, jsonData.lastIndexOf(",")) + "}" + Main.NEWLINE;
			
			tabs = tabs.substr(1);
			
			jsonData += tabs + "}";
			
			var	fs:FileStream = new FileStream();
			fs.open(new File(jsonPath), FileMode.WRITE);
			fs.addEventListener(Event.SELECT, function(e:Event):void {} ); 
			fs.addEventListener(IOErrorEvent.IO_ERROR,  function(e:IOErrorEvent):void {
				//EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.EXPORT_COMPLETE, "Export job completed with IOError.")); 
			}); 
			fs.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
				//EventManager.dispatcher.dispatchEvent(new SpriteSatchelEvent(SpriteSatchelEvent.EXPORT_COMPLETE, "Export job completed with SecurityError.")); 
			}); 
			fs.addEventListener(ProgressEvent.PROGRESS, function(e:Event):void {}); 
			fs.addEventListener(Event.COMPLETE, function(e:Event):void { 
			});
			fs.writeUTFBytes(jsonData);
			fs.close();
			
			var bArr:ByteArray = new ByteArray();
			bArr.writeUTFBytes(jsonData);
		}
	}
}