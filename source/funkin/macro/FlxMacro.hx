package funkin.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

using Lambda;
#end

class FlxMacro
{
	public static macro function injectTimeScaleField():Array<haxe.macro.Expr.Field> // explanatory
	{
		var fields:Array<haxe.macro.Expr.Field> = haxe.macro.Context.getBuildFields();
		
		fields.push(
			{
				name: "timeScale",
				access: [haxe.macro.Expr.Access.APublic, haxe.macro.Expr.Access.AStatic],
				kind: FVar(macro :Float, macro $v{1.0}),
				pos: Context.currentPos(),
			});
			
		#if !display
		for (i in fields)
		{
			switch (i.kind)
			{
				case FFun(f):
					if (i.name != 'update') continue;
					var body:Array<Expr> = null;
					
					switch (f.expr.expr)
					{
						case EBlock(exprs):
							body = exprs;
							
						default:
							body = [f.expr];
					}
					if (body == null) body = [];
					
					body.insert(0, macro
						{
							elapsed *= timeScale;
						});
						
					f.expr = macro $b{body};
					
				default:
			}
		}
		#end
		
		return fields;
	}
	
	public static macro function buildFlxSprite():Array<haxe.macro.Expr.Field>
	{
		var fields:Array<haxe.macro.Expr.Field> = haxe.macro.Context.getBuildFields();
		
		var position = Context.currentPos();
		
		var fieldsToAdd:Array<haxe.macro.Expr.Field> = [];
		
		// adds a loadFrames function to FlxSprites. allows you to essentially load animated sprites in a similar method to loadgraphic
		fieldsToAdd.push(
			{
				doc: "shortcut to loading the frames of a sparrow atlas",
				name: "loadSparrowFrames",
				access: [haxe.macro.Expr.Access.APublic],
				kind: FFun(
					{
						args: [
							{name: 'path', type: (macro :String)},
							{name: 'library', opt: true, type: (macro :String)}
						],
						expr: macro
						{
							this.frames = funkin.backend.Paths.getSparrowAtlas(path, library);
							return this;
						}
					}),
				pos: position,
			});
			
		// adds a makeScaledGraphic function to FlxSprites. allows you to make a 1x1 graphic scaled to the size desired.
		fieldsToAdd.push(
			{
				name: "makeScaledGraphic",
				access: [haxe.macro.Expr.Access.APublic],
				kind: FFun(
					{
						args: [
							{name: 'width', type: (macro :Float)},
							{name: 'height', type: (macro :Float)},
							{name: "color", opt: true, type: (macro :Int)},
							{name: 'unique', opt: true, type: (macro :Bool)},
							{name: 'key', opt: true, type: (macro :String)}
						],
						expr: macro
						{
							this.makeGraphic(1, 1, color, unique, key);
							this.scale.set(width, height);
							this.updateHitbox();
							return this;
						}
					}),
				pos: position,
			});
			
		fieldsToAdd.push(
			{
				name: "centerOnObject",
				access: [haxe.macro.Expr.Access.APublic],
				kind: FFun(
					{
						args: [
							{name: 'object', type: (macro :flixel.FlxObject)},
							{name: 'axes', opt: true, type: (macro :flixel.util.FlxAxes)}
						],
						expr: macro
						{
							axes ??= flixel.util.FlxAxes.XY;
							if (axes.x) this.x = object.x + (object.width - this.width) / 2;
							if (axes.y) this.y = object.y + (object.height - this.height) / 2;
							return this;
						}
					}),
				pos: position,
			});
			
		fieldsToAdd.push(
			{
				name: "loadFromSheet",
				access: [haxe.macro.Expr.Access.APublic],
				kind: FFun(
					{
						args: [
							{name: 'path', type: (macro :String)},
							{name: 'animName', type: (macro :String)},
							{name: 'fps', type: (macro :Int), value: macro $v{24}}
						],
						expr: macro
						{
							this.frames = funkin.backend.Paths.getSparrowAtlas(path);
							this.animation.addByPrefix(animName, animName, fps);
							this.animation.play(animName);
							if (this.animation.curAnim == null || this.animation.curAnim.numFrames == 1)
							{
								this.active = false;
							}
							
							return this;
						}
					}),
				pos: position,
			});
			
		fields = fields.concat(fieldsToAdd);
		
		return fields;
	}
	
	// this is from base game i wanted smth like this since forever
	public static macro function buildFlxBasic():Array<haxe.macro.Expr.Field>
	{
		var fields:Array<haxe.macro.Expr.Field> = haxe.macro.Context.getBuildFields();
		
		fields.push(
			{
				name: "zIndex",
				access: [haxe.macro.Expr.Access.APublic],
				kind: FVar(macro :Int, macro $v{0}),
				pos: Context.currentPos(),
			});
			
		return fields;
	}
}
