# SpriteSatchel #

----------

SpriteSatchel is a tool for converting SWF animations into SpriteSheets for [CreateJS](http://createjs.com/Home). The tool is designed to accomplish the same thing as CreateJS's [Zoë](https://github.com/CreateJS/Zoe), but it's written from the ground up in order to address some of Zoë's problems. I also added a number of additional features that I think Zoë should have had to start. The most notable feature is the ability to export SpriteSheets from MovieClips within the SWF's library instead of using the root timeline. Additional details are listed below.

SpriteSatchel can work on any SWF content Flash 9.0 and above, and it requires [Adobe AIR](https://get.adobe.com/air/) to install the software. Exported SpriteSheets are confirmed to work with the EaselJS package version 0.7.* and above, but is likely to work with earlier versions as well assuming the JSON data format hasn't changed. 

Download version 0.5.9 here:

http://www.mcleodgaming.com/downloads/SpriteSatchel.0.5.9.air

## Features ##

- Converts MovieClip assets from a SWF's library into spritesheet PNGs and JSON files compatible with CreateJS
- **Capable of reading hitboxes** drawn over animations and write them out as JSON (great for anchor points!)
- Save your project's settings to a file so that you can quickly re-export the next time you open
- Add multiple SWF files as sources
- Specify individual sheets to exclude from the export

### Why SpriteSatchel? ###

Zoë (the alternative to SpriteSatchel) claims on its Github page that it's  "best practice to have all your animations on the root timeline". Sure this makes sense for Zoë because that's the only option, but that's one of its biggest limitations since you can only create one spritesheet per SWF. To me this defeats the purpose of Flash as a tool for being able to store many collections of animations in one FLA.

SpriteSatchel takes a different approach by allowing the Flash Library to act as a "home" for all of your spritesheets. To elaborate, in Zoë you create all of your animations on the root timeline (this can be a lot of frames!). But in SpriteSatchel:

- A single MovieClip represents a spritesheet, and consists of one or more animations. 
- A spritesheet is a collection of child animations, each animation living in its own MovieClip
- Frame labels on the spritesheet MovieClip determine the animation names
- Registration points are determined by an animation's "parent" MovieClip (no need to place it manually!)
- Execute the included `create_manifiest.jsfl` script while on the root timeline of your FLA, and it will generate manifest code to tell SpriteSatchel what resources are available by looking for all clips exported for ActionScript in your library.
- Export the SWF and open with SpriteSatchel, and watch the magic at work!

So in a way, SpriteSatchel is able to do what Zoë does but to multiple MovieClips from an FLA. It also has the added benefit of organizing your sprites in such a way that supports keeping animations separate from each other.

Another difference from Zoë is that SpriteSatchel can handle transparencies and filter effects a lot better. I've had times where Zoë would cut off parts of my animations that had subtle transparency effects, which was one of the major factors that prompted me to create this new tool.



## How to Export a Spritesheet ##

(For these examples I'll be going off of the **ninja.fla** under **examples/ninja**, sprites courtesy of [http://www.gameart2d.com](http://www.gameart2d.com)) 

### Structuring Animations ###

SpriteSatchel requires that animations exist in a separate MovieClips, and be distributed across the timeline of a parent MovieClip. In the **ninja.fla** example, you can look inside the "Boy Ninja" MovieClip and discover the following:

![SpriteSatchel UI](http://www.mcleodgaming.com/images/uploads/sprite_satchel_ninja_mc.png)

The Boy Ninja clip is essentially a spritesheet with two animations: idle and run. These animations have been set up inside their own MovieClip and were distributed across these 2 frames. The frame labels tell SpriteSatchel what to name these animations for its output JSON, and the origin point inside this coordinate spaces determines the registration point for the animation.

If you drill down into the Idle animation you'll see the full animation laid out inside. This is also the place to set up hitboxes, which is described later on down below.




### Creating a Manifest ###

Before you can export any spritesheets, you will need to define a special `manifest` object to the root of your FLA. This is extremely quick and painless, since all you have to do is execute the included `create_manifiest.jsfl` script while you have your FLA open in Flash. This script will browse Flash's Library for any MovieClips that are exported for ActionScript and generate the appropriate code on frame 1 of your root timeline. **Be sure to navigate to the root timeline before running the script or it may write the code to the wrong place!**

But if you want to write the manifest yourself you can, just navigate to the root timeline and on frame 1 create the following variable:

```
var manifest:Array = [
	{ linkage: "ExportClass1NameHere" },
	{ linkage: "ExportClass2NameHere" } //etc.
];

```
SpriteSatchel looks for this array in order to determine what clips to load.

## Using SpriteSatchel##

Once you have your animations set up, now's the time to open SpriteSatchel! Details on its  interface are described below. I recommend installing SpriteSatchel and testing with the example `ninja.swf` file.

### The UI ###

![SpriteSatchel UI](http://www.mcleodgaming.com/images/uploads/sprite_satchel_ui.png)

1. FLA source files will be listed here
2. Use "Add" and "Remove Source" to manage FLA source files list
3. Set the output path for JSON and PNG data
4. Console output info displayed here
5. Use this drop down to select one of the clips from your manifest
6. Uncheck "Enable Clip Export" to ignore this MovieClip during publish
7. Use this dropdown to view an invidual animation within this clip
8. The currently selected animation will be displayed here. The + symbol represents its registration point.

#### Menu Options ####

`File->New Project`
Starts a new project (this will reset the state of the application)

`File->Open Project`
Opens a SpriteSatchel project file

`File->Save Project`
Save the current project settings to a SpriteSatchel project file.

`File->Save Project As...`
Save the current project settings to a file with a new name.

`File->Import SWF`
Loads a SWF into SpriteSatchel. You must specify a `manifest` Array at the root of the SWF in order for SpriteSatchel to pull in animations.

`File->Publish`
Writes spritesheet PNGs and JSON data to their specified respective output paths. (By default, this will be `~/Desktop/assets/images` and `~/Desktop/assets/json`)

`File->Exit`
Closes SpriteSatchel.

`Help->About`
Display version information.

## How to Export Hitbox Data ##

The hitbox data feature writes an additional field to each animation object in CreateJS's JSON output called `hitboxes`. This field is an array that contains Objects describing all of the hitbox data for a particular animation, and each of these Objects represents a single hitbox. In order to retrieve this data, you will have to extract it from your CreateJS SpriteSheet object once it is loaded.

Please note that CreateJS does not have a built-in hitbox management/collision system so you will have to write any additional functionality yourself. But this format is generic enough to act as a base for most simple 2D hitbox implementations.

### Creating Hitboxes ###

![SpriteSatchel UI](http://www.mcleodgaming.com/images/uploads/sprite_satchel_ninja_hitbox.png)
(Screenshot taken from example **ninja.fla** file under **examples/ninja)**

Hitboxes are simply rectangular MovieClips you place inside your animations that you can hide during export so they are no longer visible. These are great for fighting games where you need a very precise hand-made collision system. **Just note that SpriteSatchel does not fully support rotated hitbox data!** While you can rotate as much as you want, the bounding box for this rectangle will still be oriented as if it were unrotated and surrounding the full draw area of hit box clip. If you want at least partial rotation support for when the animation as a whole is rotated, that can be done through [rotated rectangular collision](http://stackoverflow.com/questions/10962379/how-to-check-intersection-between-2-rotated-rectangles) calculations using the 4 edges of the unrotated hitbox. 

To configure a hitbox, you can simply place all of your settings as variables directly inside of its MovieClip. These properties will be read upon frame-load when SpriteSatchel scrubs your animation.  

#### Hit Box Properties (Self-Declared) ####

Below is a description of the fields for a single hitbox Object that you can define. Declare these as variables on the first frame of your hitbox MovieClip's timeline.

`id` - (String) Represents the unique name for this hit box. Generally you would name a hitbox with numbers appended to some generic name if you have more than one on the same frame (e.g. `hitbox0`, `hitbox1`, etc.). You'd need to be able to enumerate through these values if hitboxes ever needed ordered priority. Otherwise you can use the same name across all of your frames. **You can alternatively provide an instance name** to the hitbox MovieClip to be used as the `id`, and as long as the MovieClip also contains a `type` property SpriteSatchel will detect it as a hitbox. Setting this value is **required** except when using instance names.

`type` - (String) Represents a "group" name for this hitbox. Useful when you want to differentiate hitboxes of various types (e.g. "handbox", "footbox", etc.) Setting this value is **required**.

`customData` - (Object) You can place any data you want inside this object to be written to the JSON file. Setting this value is **optional**.

`forceVisible` - (Boolean) SpriteSatchel automatically hides hitboxes from the resulting spritesheet, so this value can be used to force render hitboxes. By default this setting is set to `false`. Setting this value is **optional**.

#### Hit Box Properties (Automatically Declared) ####

The remaining properties are automatically calculated and inserted into the JSON object for this hitbox. The final JSON data for a hitbox consists of the values you defined in addition to the ones below:

`frame` - (Integer) This is the frame number that the hitbox exists on for the animation starting from frame 1.

`rect` - (Object) Contains numerical fields `x`, `y`, `scaleX`, and `scaleY` that describe the bounding box for the hitbox MovieClip. These fields are relative to the coordinate space of the animation. This means that the origin point of the animation is the origin for this rectangle's coordinate space.

`rotation` - (Number) Rotation of the hitbox in radians. Note that rotating a hitbox **will completely butcher** the `rect` field's properties, but this can still be useful when the size of your hitbox is not needed.

`depth` - (Integer) The depth index of the hitbox MovieClip starting from the bottom-most layer with a value of 0.

`scale` - (Object) Contains the numerical properties `x` and `y` that represent the respective scaleX and scaleY values of the hitbox.

`transform` - (Object) Contains the numerical fields describing the 2D Matrix transform values of the hitbox. These fields are named `a`, `b`, `c`, `d`, `tx`, and `ty`.

`reg` - (Object) Contains the numerical properties `x` and `y`, which represent the registration point location of the hit box relative to the origin of the animation's parent MovieClip. For hitboxes with centered registration points, this is great for creating anchor points.

## Build Process ##

If you have FlashDevelop and are familiar with AIR development it should be pretty straightforward. Just create a dummy certificate and build the project. But I will add additional information on how to manually build this project soon.

(Details coming soon)

## Future Plans? ##

- Improving the save file functionality
- Customizable sprite sheet dimensions (currently it's automatic)
- Output to additional spritesheet formats besides CreateJS (Possibly)
- Overflow onto multiple spritesheets (for when max sized is reached)
- UI improvements (ideas appreciated!)
- ...Other Suggestions?

## Initialization ##


----------

Copyrighted © 2015 by Greg McLeod

GitHub: [https://github.com/cleod9](https://github.com/cleod9)