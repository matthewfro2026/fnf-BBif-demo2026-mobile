#if !macro
// Psych
#if LUA_ALLOWED
import llua.*;

import llua.Lua;
#end

#if ACHIEVEMENTS_ALLOWED
import funkin.backend.Achievements;
#end
import funkin.backend.MTCacher;
import funkin.backend.Controls;
import funkin.backend.MusicBeatState;
import funkin.backend.MusicBeatSubstate;
import funkin.backend.ClientPrefs;
import funkin.backend.Conductor;
import funkin.backend.BaseStage;
import funkin.backend.Difficulty;
import funkin.backend.Mods;
import funkin.objects.Alphabet;
import funkin.objects.BGSprite;
import funkin.states.PlayState;
import funkin.objects.BaldiText;
import funkin.utils.CoolUtil;
import funkin.utils.MathUtil;
import funkin.backend.FunkinCache;
import funkin.FunkinAssets;
import funkin.Constants;

#if flixel_animate
import animate.FlxAnimate;
#end

#if VIDEOS_ALLOWED
import hxvlc.flixel.*;
import hxvlc.openfl.*;
#end

import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxShader;
#end