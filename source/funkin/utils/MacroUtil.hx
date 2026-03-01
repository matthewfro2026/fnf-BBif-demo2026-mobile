package funkin.utils;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.Tools;

using Lambda;
#end

// my macro stuff not rlly used rn // i just wanted something specific
class MacroUtil
{
	/**
	 * enforces the use of haxe 4.3 cuz i use alot of its null coalescents lol
	 */
	public macro static function haxeVersionEnforcement()
	{
		#if (haxe_ver < "4.3.4")
		Context.fatalError('use haxe 4.3.4 or newer thx', (macro null).pos);
		#end
		
		return macro $v{0};
	}
	
	/**
	 * returns the current Date as a string during compilation.
	 */
	public static macro function getDate()
	{
		return macro $v{Date.now().toString()};
	}
	
	/**
	 * forces the compiler to include a class even if the dce kills it
	 */
	public static macro function include(path:Expr)
	{
		haxe.macro.Compiler.include(path.toString());
		return macro $v{0};
	}
	
	/**
	 * ONLY USE FOR ABSTRACTED CLASSES THAT ARE JUST VARS does nothing for anything else 
	 * Builds a anon strcture from static uppercase inline variables in an abstract type.
	 * ripped from FlxMacroUtil but modified to fit my needs
	 * https://code.haxe.org/category/macros/combine-objects.html
	 * https://github.com/HaxeFlixel/flixel/blob/master/flixel/system/macros/FlxMacroUtil.hx
	 */
	public static macro function buildAbstract(typePath:Expr, ?exclude:Array<String>)
	{
		var type = Context.getType(typePath.toString());
		var expressions:Array<ObjectField> = [];
		
		if (exclude == null) exclude = ["NONE"];
		
		switch (type.follow())
		{
			case TAbstract(_.get() => ab, _):
				for (f in ab.impl.get().statics.get())
				{
					switch (f.kind)
					{
						case FVar(AccInline, _):
							switch (f.expr().expr)
							{
								case TCast(Context.getTypedExpr(_) => expr, _):
									if (f.name.toUpperCase() == f.name && exclude.indexOf(f.name) == -1) // uppercase?
									{
										expressions.push({field: f.name, expr: expr});
									}
									
								default:
							}
							
						default:
					}
				}
			default:
		}
		
		var finalResult = {expr: EObjectDecl(expressions), pos: Context.currentPos()};
		return macro $b{[macro $finalResult]};
	}
	
	/**
	 * explanatory
	 */
	public static macro function getGitCommitUser()
	{
		#if !display
		var process = new sys.io.Process('git', ['log', '-1', '--pretty=format:"%an"'], false);
		if (process.exitCode() != 0)
		{
			var message = process.stderr.readAll().toString();
			var pos = haxe.macro.Context.currentPos();
			haxe.macro.Context.error("Cannot execute `git rev-parse HEAD`. " + message, pos);
		}
		
		return macro $v{process.stdout.readLine()};
		#else
		return macro $v{"-"} #end
	}
	
	/**
	 * explanatory
	 */
	public static macro function getGitCommitSummary()
	{
		#if !display
		var process = new sys.io.Process('git', ['log', '-1', '--pretty=%B'], false);
		if (process.exitCode() != 0)
		{
			var message = process.stderr.readAll().toString();
			var pos = haxe.macro.Context.currentPos();
			haxe.macro.Context.error("Cannot execute `git rev-parse HEAD`. " + message, pos);
		}
		
		return macro $v{process.stdout.readLine()};
		#else
		return macro $v{"-"} #end
	}
	
	/**
	 * explanatory
	 */
	public static macro function getGitCommitNumber()
	{
		#if !display
		var process = new sys.io.Process('git', ['rev-list', 'HEAD', '--count'], false);
		if (process.exitCode() != 0)
		{
			var message = process.stderr.readAll().toString();
			var pos = haxe.macro.Context.currentPos();
			haxe.macro.Context.error("Cannot execute `git rev-parse HEAD`. " + message, pos);
		}
		
		return macro $v{Std.parseInt(process.stdout.readLine())};
		#else
		return macro $v{0} #end
	}
	
	/**
	 * explanatory
	 */
	public static macro function getGitCommitHash()
	{
		#if !display
		var process = new sys.io.Process('git', ['rev-parse', '--short', 'HEAD'], false);
		if (process.exitCode() != 0)
		{
			var message = process.stderr.readAll().toString();
			haxe.macro.Context.info("Could not obtain current git hash. " + message, haxe.macro.Context.currentPos());
		}
		
		var ret = '';
		try
		{
			ret = process.stdout.readLine();
			process.close();
		}
		catch (e)
		{
			process.close();
		}
		
		return macro $v{ret};
		#else
		return macro $v{""} #end
	}
}
