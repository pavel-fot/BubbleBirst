package utils
{
	import com.junkbyte.console.Cc;

	import flash.events.TimerEvent;

	import flash.utils.Dictionary;
	import flash.utils.Timer;

	import starling.events.Event;
	import starling.events.EventDispatcher;

	/**
	 * ResourceManager.
	 * 
	 * Note: All paths in resource.json should be defined from root.
	 * I.e. like this:
	 * 	"CabinetDialogMobile": ["CabinetDialogMobile/CabinetDialogMobile.png", "CabinetDialogMobile/CabinetDialogMobile.xml", 
	 * 	"CabinetDialogMobile/CabinetDialogMobile.json", "CabinetDialogMobile/skeleton.json"]
	 * Any other paths should be omitted. Mention also that resource array 
	 * like in example above will be generated automatically if you just 
	 * call getAssetManagerByPackName("CabinetDialogMobile"); and didn't 
	 * add array for "CabinetDialogMobile" in resource.json.
	 * 
	 * //#? - will be removed later if no need occurred
	 */
	public class ResourceManager extends EventDispatcher
	{
		
		// Class constants
		
		public static const LOG:String = "framework.resource.manager";

		public static const UPDATE_RESOURCES_PROGRESS:String = "updateResourcesProgress";
		public static const PRELOAD_PROGRESS:String = "preloadProgress";
		public static const PRELOAD_COMPLETE:String = "loadComplete";
		public static const START_STEP:String = "startStep";
		public static const LOAD_PROGRESS:String = "loadProgress";
		
		private static const UPDATE_PRELOAD_ASSETS_PROGRESS_INTERVAL:int = 100;
		
		// Class variables
		
		// Class methods
		
		private static function calculateRatioForArray(assetManagerArray:Array):Number
		{
			var ratio:Number = 0;
			if (!assetManagerArray || !assetManagerArray.length)
			{
				ratio = 1;
			}
			else
			{
				var ratioSum:Number = 0;
				for (var i:int = 0; i < assetManagerArray.length; i++)
				{
					var assetManager:AssetManagerExt = assetManagerArray[i] as AssetManagerExt;
					if (assetManager)
					{
						ratioSum += assetManager.loadingRatio;
					}
				}
				ratio = ratioSum / assetManagerArray.length;
			}
			return ratio;
		}
		
		// Variables
		
		// (Set in your overridden Main.initializeManagers())
		// Remote version.json URL
		public var versionURL:String;
		// Local (mobile) version.json URL
		public var mobileVersionPath:String;
		// CDN URL of assets to update mobile assets
		public var updateRootPathURL:String;
		//
		public var loadRootPathURL:String;

		// ["assets1", "assets2", {"assetPackName": "assets3_dialog", "additionalPackNames": ["assets3_item"]}]
		public var preloadAssetPackNameArray:Array = [];
		private var _undisposableAssetPackNames:Dictionary = new Dictionary();
		
		private var _undisposableAssetManagers:Dictionary = new Dictionary();
		
		/**
		 * Добавляет паки ассетов в список невыгружаемых
		 * В дальнейшем попавшие сюда ассет менеджеры не будут повторно создаваться.
		 * Чтоб убрать ассет пак и дать ему возможность выгрузиться необходимо заюзать removeUndisposablePacks
		 * ИСПОЛЬЗОВАТЬ НА СВОЙ СТРАХ И РИСК :D
		 * @param	...args AssetPackName:String
		 */
		public function setUndisposablePacks(...args):void {
			for (var i:int = 0, len:int = args.length; i < len; i++) {
				if(args[i] as String){
					_undisposableAssetPackNames[args[i] as String] = true;
				}
			}
			//Log.warn(LOG, "WARN +1 _undisposableAssetPackNames");
		}
		
		/**
		 * Удаляет паки ассетов из списка невыгружаемых при следующем диспоузе данного пака
		 * Принцип работы можно посмотреть в асдоке setUndisposablePacks()
		 * @param	...args AssetPackName:String
		 */
		public function removeUndisposablePacks(...args):void {
			for (var i:int = 0, len:int = args.length; i < len; i++) {
				if(args[i] as String){
					_undisposableAssetPackNames[args[i] as String] = false;
				}
			}
			//Log.warn(LOG, "WARN -1 _undisposableAssetPackNames");
		}

		// version.json, resource.json
		private var versionJSON:Object;
		private var resourceJSON:Object;
		private var defaultResourceJSON:Object;
		
		// Asset managers
		private var assetManagerByPackNameLookup:Dictionary = new Dictionary();
		//#?private var assetManagerByAdditionalPackNameLookup:Dictionary = new Dictionary();
		private var assetManagerCountByPackNameLookup:Dictionary = new Dictionary();
		
		private var preloadAssetManagerArray:Array = [];
		private var isPreloadStarted:Boolean = false;
		private var preloadCompleteCount:int = 0;
		private var resourceJsonLoadingCount:int = 0;
		
		private var loadingModelClassArray:Array = [];

		//private var resourceJsonLoader:ResourceJSONLoader;
		private var loadingAssetManagerArray:Array = [];
		private var updateProgressTimer:Timer;
		
		// Properties
		
//		private var _loadRootPathURL:String = "";
//		public function get loadRootPathURL():String
//		{
//			return _loadRootPathURL;
//		}
//		public function set loadRootPathURL(value:String):void
//		{
//			if (value == null)
//			{
//				Log.error(LOG, this, "(assetsDirPath) assetsDirPath cannot be null! value:", value);
//			}
//			
//			_loadRootPathURL = value;
//			//_assetsDirPath = URLUtil.endWithSlash(_assetsDirPath);
//		}
		
//
//		private var _zipDirPath:String = "assets/";
//		public function get zipDirPath():String
//		{
//			return _zipDirPath;
//		}
//		public function set zipDirPath(value:String):void
//		{
//			if (value == null)
//			{
//				Log.error(LOG, this, "(zipDirPath) zipDirPath cannot be null! value:", value);
//			}
//
//			_zipDirPath = value;
//			//_zipDirPath = URLUtil.endWithSlash(_zipDirPath);
//		}

		/**
		 * Use to hide preloader only after all models were loaded and ready.
		 */
		public function get loadingModelCount():int
		{
			return loadingModelClassArray.length;
		}
		
//		public function get currentLoadingRatio():Number
//		{
//			//return assetmanagersratio - loadingModelCount;
//			return 0;
//		}
		
		/*private var _isDebugLoad:Boolean = false;
		public function get isDebugLoad():Boolean
		{
			return _isDebugLoad;
		}

		public function set isDebugLoad(value:Boolean):void
		{
			_isDebugLoad = value;
			
			AssetManagerExt.isDebugLoad = value;
		}*/
		
		private var _updateResourcesRatio:Number = 0;
		public function get updateResourcesRatio():Number
		{
			return _updateResourcesRatio;
		}

		private var _preloadingAssetsRatio:Number = 0;
		public function get preloadingAssetsRatio():Number
		{
			return _preloadingAssetsRatio;
		}

		private var _loadingAssetsRatio:Number = 0;
		public function get loadingAssetsRatio():Number
		{
			return _loadingAssetsRatio;
		}
		
		// Constructor
		
		public function ResourceManager()
		{
		}
		
		// Methods
		
		public function initialize():void
		{
		}
		
		public function dispose():void
		{
			/*resourceJsonLoader.dispose();
			resourceJsonLoader = null;*/
			
			for each (var assetManager:AssetManagerExt in assetManagerByPackNameLookup)
			{
				assetManager.purge();
			}

			resourceJSON = null;
			assetManagerByPackNameLookup = new Dictionary();
			//#?assetManagerByAdditionalPackNameLookup = new Dictionary();
			assetManagerCountByPackNameLookup = new Dictionary();
		}

		/**
		 * Если нужно что-то загрузить отдельно по УРЛ можно сделать так http://prntscr.com/672c24
		 * Ссылка сгенерируется на основании version.json, если icons/burse_of_coins.png
		 * находится в одной их этих папок http://prntscr.com/672csp
		 * 
		 * generateFullAssetURL("Map3DPack/all.png");
		 * returns "http://buttons-test.3a-games.com/dev_cdn/0.0.2/WEB_SD/Map3DPack/all.png?ver=1df9173c4b578c864545986aea1dc742a5e1e10f"
		 * 
		 * @param filePath
		 * @param directoryName
		 * @return
		 */
		/*public function generateFullAssetURL(filePath:String, directoryName:String = null):String
		{
			return VersionUtil.generateFullAssetURL(versionJSON, loadRootPathURL, filePath, directoryName);
		}*/

		public function onModelLoadStart(modelClass:Class):void
		{
			if (loadingModelClassArray.indexOf(modelClass) != -1)
			{
				//Log.warn(LOG, this, "Try to add same modelClass as loading model more than one time! modelClass:", modelClass);
				return;
			}

			loadingModelClassArray[loadingModelClassArray.length] = modelClass;
		}

		public function onModelLoadComplete(modelClass:Class):void
		{
			var index:int = loadingModelClassArray.indexOf(modelClass);
			if (index == -1)
			{
				//Log.warn(LOG, this, "Try to remove modelClass which is not in the list of loading models! modelClass:", modelClass);
				return;
			}
			loadingModelClassArray.splice(index, 1);
		}
		
		public function preload():void
		{
			if (isPreloadStarted)
			{
				return;
			}
			isPreloadStarted = true;
			// Start
			//updateAssets();
		}
		
		/*private function updateAssets():void
		{
			//Log.log(LOG, "[START-STEP-8] [Update Assets]");
			dispatchEventWith(START_STEP, false, {step:"START-STEP-8/Update Assets"});

			// Ger version.json and update mobile assets on file system
			assetsUpdater = new AssetsUpdater();
			assetsUpdater.addEventListener(AssetsUpdater.LOADING_STEP, onLoadingStepCompleteHandler);
			assetsUpdater.updateAssets(versionURL, mobileVersionPath, loadResourceJson, assetUpdater_onProgress);
		}*/

		private function onLoadingStepCompleteHandler(event:Event):void
		{
			if (event)
			{
				dispatchEvent(new Event(START_STEP, false, event.data));
			}
		}

		/*private function loadResourceJson(versionJSON:Object):void
		{
			//Log.log(LOG, "[START-STEP-12] Load Resource JSONs");
			dispatchEventWith(START_STEP, false, {step:"START-STEP-12/Load Resource JSONs"});
			assetsUpdater.removeEventListener(AssetsUpdater.LOADING_STEP, onLoadingStepCompleteHandler);

			this.versionJSON = versionJSON;

			if (!versionJSON)//? || versionJSON is Event || versionJSON is Error)//?
			{
//				Log.fatal(LOG, this, "Version JSON wasn't loaded!", "versionJSON:", versionJSON,
//						"versionURL:", versionURL, "loadRootPathURL:", loadRootPathURL,
//						"mobileVersionPath:", mobileVersionPath, "isMobile:", Device.isMobile);
				return;
			}
			
			defaultResourceJSON = versionJSON.defaultResourceJSON;
			// Load all resource JSONs and merge in single object
			var resourceJsonURLArray:Array = versionJSON.resourceJsonURLArray;
			resourceJsonLoadingCount = resourceJsonURLArray.length;
			resourceJsonLoader = new ResourceJSONLoader();
			resourceJsonLoader.loadRootPathURL = loadRootPathURL;
			resourceJsonLoader.versionJSON = versionJSON;
			resourceJsonLoader.load(resourceJsonURLArray, preloadAssets);
		}*/
		private var preloadedAssetManagersByPackName:Dictionary = new Dictionary();
		private function preloadAssets(resourceJSON:Object):void
		{
			this.resourceJSON = resourceJSON;
			//Log.log(LOG, "[START-STEP-13] Preload Asset packs");
			dispatchEventWith(START_STEP, false, {step:"START-STEP-13/Preload Asset packs"});
			if (preloadAssetPackNameArray)
			{
				for each (var assetPack:Object in preloadAssetPackNameArray)
				{
					var assetPackName:String = assetPack as String || (assetPack.hasOwnProperty("assetPackName") ? assetPack.assetPackName : null);
					var additionalPackNames:Array = assetPack.hasOwnProperty("additionalPackNames") ? assetPack.additionalPackNames : null;
					var postLoadAssetName : Array = assetPack.hasOwnProperty("postLoadPackNames") ? assetPack.postLoadPackNames : null;
					if (assetPackName)
					{
						var preloadAssetManager:AssetManagerExt = getAssetManagerByPackName(assetPackName, additionalPackNames, postLoadAssetName);
						preloadedAssetManagersByPackName[assetPackName] = preloadAssetManager;
						preloadAssetManagerArray[preloadAssetManagerArray.length] = preloadAssetManager;
					}
				}

				for each (preloadAssetManager in preloadAssetManagerArray)
				{
					preloadAssetManager.load(preloadAssetManager_onLoadComplete);//, preloadAssetManager_onLoadProgress
				}
			}
			
			// Progress
			updateLoadingAssetsProgress();
			
			checkPreloadComplete();
		}

		private function preloadAssetManager_onLoadComplete(assetManager:AssetManagerExt):void
		{
			preloadCompleteCount++;
			checkPreloadComplete();
		}

		private function checkPreloadComplete():void
		{
			if (preloadCompleteCount >= preloadAssetManagerArray.length)
			{
				updateLoadingAssetsProgress();
				preloadAssetManagerArray.length = 0;

				dispatchEventWith(PRELOAD_COMPLETE);
			}
		}
		
		//private static var index:int = 0;

		/**
		 * Returns assetManager by assetPackName.
		 * Note: ALWAYS call disposeAssetManagerByPackName when you not needed assetManager any more.
		 * @param assetPackName
		 * @param additionalPackNames
		 * @param postLoadPackNames
		 * @return
		 */
		public function getAssetManagerByPackName(assetPackName:String, additionalPackNames:Array = null, 
												  postLoadPackNames:Array = null):AssetManagerExt
		{
			if (!assetPackName)
			{
				return null;
			}

			var useCount:int = assetManagerCountByPackNameLookup[assetPackName] || 0;
			useCount++;
			assetManagerCountByPackNameLookup[assetPackName] = useCount;

			// If we need assetManager for dialog
			var assetManager:AssetManagerExt = assetManagerByPackNameLookup[assetPackName] as AssetManagerExt;

			if (!assetManager)
			{
				assetManager = createAssetManager(assetPackName, additionalPackNames, postLoadPackNames);
				assetManagerByPackNameLookup[assetPackName] = assetManager;
			}
			
			return assetManager;
		}
		
		private function createAssetManager(assetPackName:String, additionalPackNames:Array = null, 
											postLoadPackNames:Array = null):AssetManagerExt
		{
			var assetManager:AssetManagerExt = new AssetManagerExt();
			var undisposableAssetManager:AssetManagerExt;

			// (name - only for logging)
			assetManager.name = assetPackName;// + index++;
			assetManager.verbose = true;//Log.isVerboseAssetManager;
			
			// Listeners
			assetManager.addEventListener(AssetManagerExt.LOAD_START, assetManager_loadStartHandler);
			assetManager.addEventListener(AssetManagerExt.LOAD_COMPLETE, assetManager_loadCompleteHandler);
			assetManager.addEventListener(Event.IO_ERROR, assetManager_ioErrorHandler);
			
			// Set up
			//Есть ли данный ассет в списке невыгружаемых?
			//Если нет - создаем как обычный
			if (_undisposableAssetPackNames[assetPackName])
			{
				undisposableAssetManager = _undisposableAssetManagers[assetPackName];
				if (!undisposableAssetManager)
				{
					undisposableAssetManager = new AssetManagerExt();
					undisposableAssetManager.name = assetPackName;
					undisposableAssetManager.verbose = true;//Log.isVerboseAssetManager;
					setUpAssetManagerByPackName(undisposableAssetManager, assetPackName);
					undisposableAssetManager.load();
					_undisposableAssetManagers[assetPackName] = undisposableAssetManager;
				}
				
				assetManager = undisposableAssetManager;
			}
			else
			{
				setUpAssetManagerByPackName(assetManager, assetPackName);	
			}
			
			var additionalAssetManager:AssetManagerExt;
			if (additionalPackNames)
			{
				for each (var packName:* in additionalPackNames)
				{
					additionalAssetManager = preloadedAssetManagersByPackName[packName] || _undisposableAssetManagers[packName];
					if(additionalAssetManager)
					{
						assetManager.addChildManager(additionalAssetManager);
					}
					else
					{	
						//Если создается для невыгружаемого ассет менеджера,ставим на загрузку и в чайлды добавляем
						if(_undisposableAssetPackNames[assetPackName])
						{
							additionalAssetManager = new AssetManagerExt();
							additionalAssetManager.name = packName;
							additionalAssetManager.verbose = true;//Log.isVerboseAssetManager;
							setUpAssetManagerByPackName(additionalAssetManager, packName);
							additionalAssetManager.load();
							
							assetManager.addChildManager(additionalAssetManager);
							
							//Если надо добавить ассет в неудаляемые - добавляем
							if ( _undisposableAssetPackNames[packName])
							{
								_undisposableAssetManagers[packName] = additionalAssetManager;
							}
						}
						else
						{
							setUpAssetManagerByPackName(assetManager, packName);
						}
					}
				}
			}
			if (postLoadPackNames)
			{
				for each (packName in postLoadPackNames)
				{
					setUpAssetManagerByPackName(assetManager, packName, true);
				}
			}
			return assetManager;
		}				
		
		public function disposeAssetManagerByPackName(assetPackName:String):void
		{
			if (!assetPackName)
			{
				return;
			}
			
			var useCount:int = assetManagerCountByPackNameLookup[assetPackName] || 0;
			useCount--;
			assetManagerCountByPackNameLookup[assetPackName] = Math.max(useCount, 0);
			
			if (useCount <= 0)
			{
				var assetManager:AssetManagerExt = assetManagerByPackNameLookup[assetPackName];
				// Dispose
				//Если ассет менеджер выгружаемый - выгружаем без проблем.Если нет - оставляем в памяти
				if (assetManager && !_undisposableAssetPackNames[assetPackName])
				{
					assetManager.purge();
					// Listeners
					assetManager.removeEventListener(AssetManagerExt.LOAD_START, assetManager_loadStartHandler);
					assetManager.removeEventListener(AssetManagerExt.LOAD_COMPLETE, assetManager_loadCompleteHandler);
					assetManager.removeEventListener(Event.IO_ERROR, assetManager_ioErrorHandler);
				}
				
				//Удаляем из невыгружаемого ассет менеджера выгружаемые дочерние элементы
				if (assetManager && _undisposableAssetPackNames[assetPackName])
				{
					var undisposedAssetManagerChildren:Vector.<AssetManagerExt> = assetManager.children;
					var child:AssetManagerExt;
					for (var i:int = 0; i < undisposedAssetManagerChildren.length; i++)
					{
						child = undisposedAssetManagerChildren[i];
						if (!_undisposableAssetManagers[child])
						{
							assetManager.removeChildManager(child);
						}
					}
				}
				
				
				
				// Unregister
				delete assetManagerByPackNameLookup[assetPackName];
				
				//#?ObjectUtil.deleteByValue(assetManagerByAdditionalPackNameLookup, assetManager);
			}
		}

		public function isAssetPackNameAvailable(assetPackName: String): Boolean
		{
			var resourceArray:Array/* = (resourceJSON && resourceJSON[URLConfig.platformCode] ? resourceJSON[URLConfig.platformCode][assetPackName] : null) ||
				(defaultResourceJSON[URLConfig.platformCode] ? defaultResourceJSON[URLConfig.platformCode][assetPackName] : null);*/

			if (!resourceArray)
			{
				return false;
			}

			return true;
		}
		
		public function setUpAssetManagerByPackName(assetManager:AssetManagerExt, packName:*, isPostLoad:Boolean = false):void
		{
			if (!resourceJSON)
			{
				//Log.warn(LOG, this, "  (setUpAssetManagerByPackName) resourceURL.json wasn't loaded or set. Default resourceURL list will be generated.");
				//-return;
			}
			
			// Pack name
			var assetPackName:String = ObjectUtil.treatClassName(packName);
			
			if (!assetPackName)
			{
				return;
			}
			
			// Get URLs
			var resourceArray:Array/* = (resourceJSON && resourceJSON[URLConfig.platformCode] ? resourceJSON[URLConfig.platformCode][assetPackName] : null) ||
					(defaultResourceJSON[URLConfig.platformCode] ? defaultResourceJSON[URLConfig.platformCode][assetPackName] : null);*/

			resourceArray = new Array();
			resourceArray.push(assetPackName + '/' + assetPackName + '.png');
			resourceArray.push(assetPackName + '/' + assetPackName + '.xml');

			// resourceURL: URL or File of pack directory
			for each (var resourceURL:Object in resourceArray)
			{
				if (resourceURL is String)
				{
					resourceURL = prepareURL(resourceURL as String);
				}

				if (resourceURL)
				{
					if (isPostLoad)
					{
						assetManager.postEnqueue(resourceURL);
					}
					else
					{
						assetManager.enqueue(resourceURL);
					}
				}
			}
		}

		private function prepareURL(sourceURL:String):String
		{
			return loadRootPathURL + sourceURL;//--(Device.isMobile ? mobileVersionPath : loadRootPathURL) + sourceURL;//
		}

		private function startUpdateProgressTimer():void
		{
			if (!updateProgressTimer)
			{
				updateProgressTimer = new Timer(UPDATE_PRELOAD_ASSETS_PROGRESS_INTERVAL);
				// Listeners
				updateProgressTimer.addEventListener(TimerEvent.TIMER, updateProgressTimer_timerHandler);
			}
			updateProgressTimer.start();
		}

		private function stopUpdateProgressTimer():void
		{
			if (updateProgressTimer)
			{
				// Listeners
				updateProgressTimer.removeEventListener(TimerEvent.TIMER, updateProgressTimer_timerHandler);
				updateProgressTimer.stop();
				updateProgressTimer = null;
			}
		}

		private function updateLoadingAssetsProgress():void
		{
			// Preload progress
			if (preloadAssetManagerArray && preloadAssetManagerArray.length)
			{
				var prevPreloadingAssetsRatio:Number = _preloadingAssetsRatio;
				_preloadingAssetsRatio = calculateRatioForArray(preloadAssetManagerArray);

				// Dispatch
				if (prevPreloadingAssetsRatio != _preloadingAssetsRatio)
				{
					dispatchEventWith(PRELOAD_PROGRESS, false, _preloadingAssetsRatio);
				}
			}

			// Load progress
			var prevLoadingAssetsRatio:Number = _loadingAssetsRatio;
			_loadingAssetsRatio = calculateRatioForArray(loadingAssetManagerArray);

			// Dispatch
			if (prevLoadingAssetsRatio != _loadingAssetsRatio)
			{
				dispatchEventWith(LOAD_PROGRESS, false, _loadingAssetsRatio);
			}
		}
		
		// Event handlers
		
		private function assetManager_loadStartHandler(event:Event):void
		{
			var assetManager:AssetManagerExt = event.target as AssetManagerExt;
			if (assetManager)
			{
				ArrayUtil.pushUnique(loadingAssetManagerArray, assetManager);
				startUpdateProgressTimer();
			}
		}

		private function assetManager_loadCompleteHandler(event:Event):void
		{
			var assetManager:AssetManagerExt = event.target as AssetManagerExt;
			if (assetManager)
			{
				ArrayUtil.removeItem(loadingAssetManagerArray, assetManager);
				if (loadingAssetManagerArray.length == 0)
				{
					stopUpdateProgressTimer();
				}
				
				updateLoadingAssetsProgress();
			}
		}

		private function assetManager_ioErrorHandler(event:Event):void
		{
			//InternetChecker.checkInternetConnection();
			Cc.error('Internet problem?')
		}

		private function assetUpdater_onProgress(progressRatio:Number):void
		{
			_updateResourcesRatio = progressRatio;

			// Dispatch
			dispatchEventWith(UPDATE_RESOURCES_PROGRESS, false, progressRatio);
		}
		
		private function updateProgressTimer_timerHandler(timer:TimerEvent):void
		{
			updateLoadingAssetsProgress();
		}
		
	}
}