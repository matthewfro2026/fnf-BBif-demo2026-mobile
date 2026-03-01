package funkin.states.stages;

import away3d.library.Asset3DLibraryBundle;

import openfl.utils.AssetLibrary;
import openfl.events.Event;

import away3d.core.render.Filter3DRenderer;
import away3d.events.LoaderEvent;
import away3d.loaders.misc.AssetLoaderToken;
import away3d.materials.TextureMaterial;
import away3d.entities.Mesh;
import away3d.containers.ObjectContainer3D;
import away3d.controllers.LookAtController;

import openfl.geom.Vector3D;

import away3d.cameras.Camera3D;
import away3d.containers.Scene3D;
import away3d.library.assets.Asset3DType;

import openfl.net.URLRequest;

import away3d.events.Asset3DEvent;
import away3d.library.Asset3DLibrary;
import away3d.loaders.parsers.AWDParser;

import flixel.addons.transition.FlxTransitionableState;

import away3d.containers.View3D;
import away3d.debug.AwayStats;

import away3d.*;

// some stuff needs hardcoding (maybe)
class Expulsion extends BaseStage
{
	public var view:View3D;
	
	public var scene:Scene3D;
	
	public var loaderToken:AssetLoaderToken;
	
	override function create()
	{
		super.create();
		
		scene = new Scene3D();
		view = new View3D(scene, null, null, false);
		
		view.visible = false;
		FlxG.stage.addChildAt(view, 0);
	}
	
	override function createPost()
	{
		super.createPost();
		
		PlayState.instance.setOnHScript("view", view);
		PlayState.instance.setOnHScript("scene", scene);
		
		Asset3DLibrary.enableParser(AWDParser);
		
		Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
		loaderToken = Asset3DLibrary.load(new URLRequest("assets/models/BaldiRoom.awd"));
		
		loaderToken.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onLoadComplete);
	}
	
	var deltaTime:Float = 0;
	
	@:access(flixel.FlxCamera)
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (view == null) return;
		
		view.x = FlxG.game.x;
		view.y = FlxG.game.y;
		view.width = FlxG.scaleMode.gameSize.x;
		view.height = FlxG.scaleMode.gameSize.y;
		
		// deltaTime += elapsed;
		
		// if (view.visible && deltaTime >= 1 / 30)
		// {
		// deltaTime %= 1 / 30;
		view.render();
		// }
	}
	
	function onLoadComplete(data)
	{
		PlayState.instance.callOnHScript("onLoadComplete");
		trace("3d finished?");
		view.visible = true;
	}
	
	function onAssetComplete(event:Asset3DEvent)
	{
		var asset = event.asset;
		
		var currentObj:Dynamic = asset;
		
		if (currentObj == null || asset.assetType == null) return;
		PlayState.instance.callOnHScript("onAssetLoad", [currentObj, asset.assetType]);
	}
	
	override function onDestroy()
	{
		loaderToken.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onLoadComplete);
		loaderToken = null;
		
		Asset3DLibrary.removeEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetComplete);
		FlxG.stage.removeChild(view);
		
		@:privateAccess {
			for (child in view.scene._sceneGraphRoot._children)
			{
				// #if debug
				// trace(Type.getClass(child));
				// #end
				child.dispose();
				child = null;
			}
			var bundle = Asset3DLibraryBundle.getInstance();
			bundle.stopAllLoadingSessions();
			if (bundle._loadingSessions != null)
			{
				for (load in bundle._loadingSessions)
				{
					load.dispose();
					load = null;
				}
			}
			
			if (view != null)
			{
				view.dispose();
				view = null;
			}
			
			scene = null;
			
			Asset3DLibrary._instances.remove('default');
		}
	}
}
