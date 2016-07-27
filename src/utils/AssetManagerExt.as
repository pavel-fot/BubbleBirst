package utils
{
    import com.junkbyte.console.Cc;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import flash.system.ImageDecodingPolicy;
    import flash.system.LoaderContext;
    import starling.utils.SystemUtil;

    import flash.media.Sound;
    import flash.utils.Dictionary;

    import starling.events.Event;

    import flash.utils.ByteArray;
    import flash.utils.setTimeout;

    import starling.display.Image;
    import starling.display.MovieClip;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    import starling.utils.AssetManager;

    /**
     * AssetManager.
     *
     * In in-game preloader (e.g. gate dialog before game screen)
     * you can get assetManager in ResourceManager and check
     * loadingRatio property on ENTER_FRAME event.
     *
     * We save post loaded assets to add all at a time, because it's needed
     * for loading hight-quality assets in post loading to update low graphics on first launch.
     */
    public class AssetManagerExt extends AssetManager
    {

        // Class constants

        public static const LOG:String = "framework.resource.assetmanager";
        private static const HTTP_RESPONSE_STATUS:String = "httpResponseStatus";

        // Class variables

        internal static var isDebugLoad:Boolean = false;
        internal static var debugLoadLatencyMsec:int = 2000;

        public static const LOAD_START:String = "loadStart";
        public static const LOAD_COMPLETE:String = "loadComplete";
        public static const POST_LOAD_START:String = "postLoadStart";
        public static const POST_LOAD_COMPLETE:String = "postLoadComplete";

        // Class methods

        // Variables

        // Use for logging only
        public var name:String;
        public var preDisposedName:String;
        public var parentName:String;

        private var onLoadingProgress:Function;
        private var onLoadComplete:Array = [];

        private var enqueueArray:Array = [];
        private var postEnqueueArray:Array = [];
        private var zipFilePathArray:Array = [];
        private var packUnzipCheckedCount:int = 0;

        // Save post loaded assets to add all at a time
        // (We ommit sound post loading because it doesn't matter for sound)
        private var postLoadedTextureLookup:Object = {};
        private var postLoadedTextureAtlasLookup:Object = {};
        private var postLoadedObjectLookup:Object = {};
        private var postLoadedXMLLookup:Object = {};
        private var postLoadedByteArrayLookup:Object = {};

        private var _children:Vector.<AssetManagerExt>;

        private var _cachedTextures:Dictionary = new Dictionary();
        private var _cachedTextureNames:Vector.<String> = new <String>[];

        // Properties

        private var _isPostLoading:Boolean = false;
        public function get isPostLoading():Boolean
        {
            return _isPostLoading;
        }

        private var _isLoading:Boolean = false;
    //needed for Starling 1.5.1
    //		public function get isLoading():Boolean
    //		{
    //			return _isLoading;
    //		}

        private var _isLoaded:Boolean = false;
        public function get isLoaded():Boolean
        {
            return _isLoaded;
        }

        private var _loadingRatio:Number = 0;
        public function get loadingRatio():Number
        {
            return _loadingRatio;
        }

        public function get children():Vector.<AssetManagerExt>
        {
            return _children;
        }

        /**
         * Проверка на загруженность всех составляющих ассет менеджера
         * @return Boolean
         */
        public function isAllChildrenLoaded():Boolean
        {
            var isLoaded:Boolean = true;
            //Если дети есть - проверяем каждого
            if (_children.length > 0)
            {
                //Если хоть один незагружен - возвращаем false
                for (var i:int = 0; i < _children.length; i++)
                {
                    if ( !_children[i].isLoaded )
                    {
                        isLoaded = false;
                    }
                }
            }
            return isLoaded;
        }

        // Constructor

        public function AssetManagerExt()
        {
            useMipMaps = false;
            keepAtlasXmls = true;
            //keepFontXmls = true;
            _children = new <AssetManagerExt>[];
        }

        // Methods

        public function addChildManager(assetManager:AssetManagerExt):void {
            for (var i:int = 0, len:int = _children.length; i < len; i++) {
                if(_children[i] == assetManager){
                    return;
                }
            }
            _children[_children.length] = assetManager;
            assetManager.parentName = this.name;
            assetManager.addEventListener(LOAD_COMPLETE, childManager_loadCompleteHandler);
        }

        public function removeChildManager(assetManager:AssetManagerExt):void {
            for (var i:int = 0; i < _children.length; i++) {
                if(_children[i] == assetManager){
                    _children.splice(i, 1);
                }
            }
        }

        private function childManager_loadCompleteHandler(event:Event):void {
            tryLoadComplete();
        }

        override public function getTexture(name:String):Texture
        {
            var retVal: Texture;
            var isFromCache: Boolean;

            if (!_cachedTextures || !_children)
            {
                Cc.warn(LOG, "AssetManagerExt :: getTexture :: invalid asset manager, name: " + (this.name || this.preDisposedName) +
                        ", texture name: " + name + ", parentName: " + parentName +
                        ", _cachedTextures = " + String(_cachedTextures) + ", _children = " + String(_children) );
            }

            if (_cachedTextures && _cachedTextures[name] as Texture)
            {
                retVal = _cachedTextures[name] as Texture;
                isFromCache = true;
            }
            else
            {
                var texture:Texture = super.getTexture(name);
                if (texture)
                {
                    if (_cachedTextures) {
                        _cachedTextures[name] = texture;
                    }
                    retVal = texture;
                }
                else if (_children)
                {
                    for (var i:int = 0, len:int = _children.length; i < len; i++)
                    {
                        texture = _children[i].getTexture(name);
                        if (texture)
                        {
                            if (_cachedTextures) {
                                _cachedTextures[name] = texture;
                            }
                            retVal = texture;
                            break;
                        }
                    }
                }
            }

            return retVal;
        }

    //		override public function getTextures(prefix:String = "", result:Vector.<Texture> = null):Vector.<starling.textures.Texture> {
    //			result = super.getTextures(prefix, result);
    //			for (var i:int = 0, len:int = _children.length; i < len; i++) {
    //				result = _children[i].getTextures(prefix, result);
    //			}
    //			return result;
    //		}

    //		public function getTexturesNoSort(prefix:String="", result:Vector.<Texture>=null):Vector.<Texture>
    //		{
    //			if (result == null) result = new <Texture>[];
    //
    //			for each (var name:String in getTextureNamesNoSort(prefix, sNames))
    //				result[result.length] = getTexture(name); // avoid 'push'
    //
    //			sNames.length = 0;
    //			return result;
    //		}

    //		/** Returns all texture names that start with a certain string, sorted alphabetically. */
    //		public function getTextureNamesNoSort(prefix:String="", result:Vector.<String>=null):Vector.<String>
    //		{
    //			result = getDictionaryKeys(mTextures, prefix, result);
    //
    //			for each (var atlas:TextureAtlas in mAtlases)
    //				atlas.getNames(prefix, result);
    //
    //			result.sort(Array.CASEINSENSITIVE);
    //			return result;
    //		}
        private function updateCachedTextureNames():void {
            _cachedTextureNames.length = 0;
            _cachedTextureNames = super.getTextureNames("", _cachedTextureNames);

            for (var i:int = 0, len:int = _children.length; i < len; i++) {
                _cachedTextureNames = _children[i].getTextureNames("", _cachedTextureNames);
            }
        }

        override public function getTextureNames(prefix:String = "", result:Vector.<String> = null):Vector.<String>
        {
            if (!_cachedTextures || !_children)
            {
                Cc.warn(LOG, "AssetManagerExt :: getTextureNames :: invalid asset manager, name: " + (this.name || this.preDisposedName) +
                        ", texture name: " + name + ", parentName: " + parentName +
                        ", _cachedTextures = " + String(_cachedTextures) + ", _children = " + String(_children) );
            }

            if (_cachedTextureNames && _cachedTextureNames.length == 0){
                updateCachedTextureNames();
            }
            if (result == null) {
                result = new <String>[];
            }
            var j:int = result.length;
            if (_cachedTextureNames)
            {
                for (var i:int = 0, len:int = _cachedTextureNames.length; i < len; i++ ) {
                    if(_cachedTextureNames[i].indexOf(prefix) == 0){
                        result[j] = _cachedTextureNames[i];
                        j++;
                    }
                }
            }

            return result;
        }

        override public function getTextureAtlas(name:String):TextureAtlas {
            var atlas:TextureAtlas = super.getTextureAtlas(name);
            if(atlas){
                return atlas;
            }
            for (var i:int = 0, len:int = _children.length; i < len; i++) {
                atlas = _children[i].getTextureAtlas(name);
                if(atlas){
                    return atlas;
                }
            }
            return null;

        }

        override public function getSound(name:String):Sound {
            var sound:Sound = super.getSound(name);
            if(sound){
                return sound;
            }
            for (var i:int = 0, len:int = _children.length; i < len; i++) {
                sound = _children[i].getSound(name);
                if(sound){
                    return sound;
                }
            }
            return null;
        }

        override public function getSoundNames(prefix:String = "", result:Vector.<String> = null):Vector.<String> {
            result =  super.getSoundNames(prefix, result);
            for (var i:int = 0, len:int = _children.length; i < len; i++) {
                result = _children[i].getSoundNames(prefix, result);
            }
            return result;
        }

        override public function getXml(name:String):XML {
            return super.getXml(name);
        }

        override public function getXmlNames(prefix:String = "", result:Vector.<String> = null):Vector.<String> {
            return super.getXmlNames(prefix, result);
        }

        override public function getObjectNames(prefix:String = "", result:Vector.<String> = null):Vector.<String> {
            return super.getObjectNames(prefix, result);
        }

        override public function getByteArray(name:String):ByteArray {
            var by:ByteArray = super.getByteArray(name);
            if(by){
                return by;
            }
            for (var i:int = 0, len:int = _children.length; i < len; i++) {
                by = _children[i].getByteArray(name);
                if(by){
                    return by;
                }
            }
            return null;
        }


        override public function getObject(name:String):Object
        {
            if (name.indexOf(".") > 0)
            {
                var parts:Array = name.split(".");
                var parent:String = parts[0];
                var child:String = parts[1];
                var parentObj:Object = super.getObject(parent);
                if (parentObj && parentObj.c)
                {
                    for each (var childObj:* in parentObj.c)
                    {
                        if (childObj.name == child)
                        {
                            return childObj;
                        }
                    }
                }
                else
                {
                    for (var i:int = 0, len:int = _children.length; i < len; i++) {
                        obj = _children[i].getObject(name);
                        if(obj && checkObjectHasProperties(obj)){
                            return obj;
                        }
                    }

                    return {};
                }
            }
            var obj:Object = super.getObject(name);
            if(obj){
                return obj;
            }
            for (i = 0, len = _children.length; i < len; i++) {
                obj = _children[i].getObject(name);
                if(obj){
                    return obj;
                }
            }
            return null;
        }

        private function checkObjectHasProperties(obj:Object):Boolean {
            for each (var property:* in obj){
                return true;
            }
            return false;
        }

        override protected function getName(rawAsset:Object):String {
            return super.getName(rawAsset);
        }
    //---
        override protected function getBasenameFromUrl(url:String):String {
            return super.getBasenameFromUrl(url);
        }

        public function toString():String
        {
            return "[AssetManagerExt name:" + name + (_isPostLoading ? " post" : (_isLoading ? " load" : "")) + "]";
        }

        override public function dispose():void
        {
            Cc.log(LOG, this, "(dispose)");

            for (var i:int = 0, len:int = _children.length; i < len; i++) {
                _children[i].removeEventListener(LOAD_COMPLETE, childManager_loadCompleteHandler);
            }

            _children.length = 0;

            onLoadingProgress = null;
            onLoadComplete = null;

            enqueueArray.length = 0;
            postEnqueueArray.length = 0;
            //?
            zipFilePathArray = [];
            packUnzipCheckedCount = 0;

            _isPostLoading = false;
            _isLoading = false;
            _isLoaded = false;
            _loadingRatio = 0;
            preDisposedName = name;
            name = null;

            _cachedTextureNames = null;
            _cachedTextures = null;

    //			addPostLoadedData();
    //			�� ������ ��� ��� , �� ���� �� ������, ������� ������� ���� ������
            postLoadedTextureLookup = {};
            postLoadedTextureAtlasLookup = {};
            postLoadedObjectLookup = {};
            postLoadedXMLLookup = {};
            postLoadedByteArrayLookup = {};

            super.dispose();
        }


        override protected function log(message:String):void
        {
            //super.log(message);

            //if (message && (message.indexOf("error") != -1 || message.indexOf("Error") != -1))
            //{
            //Log.error(LOG, this, "", message);
            //}
            //else if (message && (message.indexOf("warning") != -1 || message.indexOf("Warning") != -1))
            //{
            //Log.warn(LOG, this, "", message);
            //}
            //else
            if (verbose)
            {
                if (message.indexOf("fail") > -1 || message.indexOf("error") > -1)
                {
                    Cc.error(LOG, this, "", message);
                }
                else
                {
                    Cc.info(LOG, this, "", message);
                }

            }
        }

        override public function addTexture(name:String, texture:Texture):void
        {
            // (getTexture(name) needed to save in postLoadedTextureLookup only existing textures to avoid their disposing)
            if (_isPostLoading && getTexture(name))
            {
                log("Add to post load buffer. (addTexture) name: " + name);
                postLoadedTextureLookup[name] = texture;
                return;
            }
            if (_cachedTextures)
            {
                _cachedTextures[name] = texture;
            }
            super.addTexture(name, texture);
        }

        override public function addTextureAtlas(name:String, atlas:TextureAtlas):void
        {
            if (_isPostLoading)
            {
                log("Add to post load buffer. (addTextureAtlas) name: " + name);
                postLoadedTextureAtlasLookup[name] = atlas;
                return;
            }

            super.addTextureAtlas(name, atlas);
            var atlasTextureNames:Vector.<String> = atlas.getNames();
            for (var i:int = 0, len:int = atlasTextureNames.length; i < len; i++) {
                _cachedTextures[atlasTextureNames[i]] = atlas.getTexture(atlasTextureNames[i]);
            }
        }

        override public function addObject(name:String, object:Object):void
        {
            if (_isPostLoading)
            {
                log("Add to post load buffer. (addObject) name: " + name);
                postLoadedObjectLookup[name] = object;
                return;
            }

            super.addObject(name, object);
        }

        override public function addXml(name:String, xml:XML):void
        {
            if (_isPostLoading)
            {
                log("Add to post load buffer. (addXml) name: " + name);
                postLoadedXMLLookup[name] = xml;
                return;
            }

            super.addXml(name, xml);
        }

        override public function addByteArray(name:String, byteArray:ByteArray):void
        {
            if (FileUtil.checkIfFileIsEncodable(name, true))
            {
                byteArray = FileUtil.decodeBase64(byteArray);
                var object: Object;
                try { object = JSON.parse(byteArray.readUTFBytes(byteArray.length)); }
                catch (e:Error)
                {
                    log("Could not parse JSON: " + e.message);
                    dispatchEventWith(Event.PARSE_ERROR, false, name);
                }
                if (object)
                {
                    addObject(name, object);
                    return;
                }
            }
            if (_isPostLoading)
            {
                log("Add to post load buffer. (addByteArray) name: " + name);
                postLoadedByteArrayLookup[name] = byteArray;
                return;
            }

            super.addByteArray(name, byteArray);
        }

        override public function enqueue(...rawAssets):void
        {
            var resourceURL:Object = rawAssets[0];
            if (resourceURL is String || resourceURL is Class)
            {
                if (enqueueArray.indexOf(resourceURL) != -1)
                {
                    return;
                }

                enqueueArray[enqueueArray.length] = resourceURL;
            }

            //???_isLoaded = false;

            super.enqueue.apply(this, rawAssets);
        }

        public function postEnqueue(resourceURL:Object):void
        {
            log("(postEnqueue) resourceURL: " + resourceURL);

            if (postEnqueueArray.indexOf(resourceURL) == -1)
            {
                postEnqueueArray[postEnqueueArray.length] = resourceURL;
            }
        }

        public function postLoad(onLoadComplete:Function = null, onLoadingProgress:Function = null):void
        {
            if (!postEnqueueArray || !postEnqueueArray.length)
            {
                return;
            }

            // Set post loading
            _isPostLoading = true;

            Cc.info(LOG, this, "(postLoad)", "postEnqueueArray:", postEnqueueArray, "onLoadComplete:", onLoadComplete, "onLoadingProgress:", onLoadingProgress);

            // Enqueue
            for each (var resourceURL:Object in postEnqueueArray)
            {
                enqueue(resourceURL);
            }
            postEnqueueArray.length = 0;

            // Load
            load(onLoadComplete, onLoadingProgress);
        }

        /**
         * Note: All resource URLs were enqueued in ResourceManager by using data from resource.json.
         * Here we can only load that queue.
         *
         * @param onLoadComplete
         * @param onLoadingProgress
         */
        public function load(onLoadComplete:Function = null, onLoadingProgress:Function = null):void
        {
            Cc.info(LOG, this, "(load) isLoaded:", _isLoaded, "isPostLoading:", _isPostLoading, "isLoading:", _isLoading, "onLoadComplete:",
                    onLoadComplete,"onLoadingProgress:", onLoadingProgress);

            if (_isLoaded && isAllChildrenLoaded() && !_isPostLoading)
            {
                if (onLoadComplete != null)
                {
                    var args:Array = [this];
                    args.length = onLoadComplete.length;
                    onLoadComplete.apply(null, args);
                }
                return;
            }

            this.onLoadComplete.push(onLoadComplete);
            this.onLoadingProgress = onLoadingProgress;

            _isLoading = true;
            _loadingRatio = 0;

            if (_isPostLoading)
            {
                // Dispatch
                dispatchEventWith(POST_LOAD_START, false, this);
            }
            else
            {
                // Dispatch
                dispatchEventWith(LOAD_START, false, this);
            }

            Cc.info(LOG, this, " (load) <loadQueue>");
            loadQueue(onProgress);
        }

        private function onPackUnzipChecked(isOnZipLoaded:Boolean = true):void
        {
            if (isOnZipLoaded)
            {
                packUnzipCheckedCount++;
            }
            Cc.info(LOG, this, " (onPackUnzipChecked) isOnZipLoaded:", isOnZipLoaded,"packUnzipCheckedCount:",
                    packUnzipCheckedCount, ">=? zipFilePathArray.length:", zipFilePathArray.length);
            if (packUnzipCheckedCount >= zipFilePathArray.length)
            {
                Cc.info(LOG, this, "  (onPackUnzipChecked) <loadQueue> >= OK");
                loadQueue(onProgress);
            }
        }

        private function onProgress(ratio:Number):void
        {
            //Log.info(LOG, this, " (onProgress) loading... ratio:",ratio.toFixed(3), "prev-loadingRatio:", _loadingRatio.toFixed(3));
            const isDebugPostLoadHighGraph:Boolean = false
            if (isDebugPostLoadHighGraph && ratio == 1 && _isPostLoading && _loadingRatio < 1)
            {
                // Call loading complete with 5 sec delay
                setTimeout(onProgress, 5000, ratio);
                _loadingRatio = ratio;
                return;
            }

            _loadingRatio = ratio;

            if (onLoadingProgress != null)
            {
                onLoadingProgress(ratio);
            }
            if (ratio == 1)
            {
                Cc.info(LOG, this, "  (onProgress) <onLoadComplete> Loaded! ratio:",ratio, "prev-isLoaded:", _isLoaded,
                        "prev-isPostLoading:", _isPostLoading, "onLoadComplete:", onLoadComplete);

                _isLoading = false;
                _isLoaded = true;

                if (_isPostLoading)
                {
                    _isPostLoading = false;

                    addPostLoadedData();

                    Cc.info(LOG, this, "   (onProgress) <dispatch-POST_LOAD_COMPLETE>");
                    // Dispatch
                    dispatchEventWith(POST_LOAD_COMPLETE, false, this);
                    if (onLoadComplete != null)
                    {
                        for (var i:int=0;i<onLoadComplete.length;i++)
                        {
                            if (onLoadComplete[i] != null)
                            {
                                var args:Array = [this];
                                args.length = onLoadComplete[i].length;
                                if (isDebugLoad)
                                {
                                    setTimeout(onLoadComplete[i].apply, debugLoadLatencyMsec, null, args)
                                }
                                else
                                {
                                    //trace(this,"     (onProgress) onLoadComplete:",onLoadComplete, "args:", args);
                                    onLoadComplete[i].apply(null, args);
                                }
                            }
                        }
                    }
                }
                else
                {
                    tryLoadComplete();
                }


            }
        }

        private function tryLoadComplete():void {
            if(isLoading)
                return;
            var i:int;
            var len:int;
            for (i = 0, len = _children.length; i < len; i++) {
                if(_children[i].isLoading){
                    return;
                }
            }
            Cc.info(LOG, this, "   (onProgress) <dispatch-LOAD_COMPLETE>");

            updateCachedTextureNames();

            // Dispatch
            dispatchEventWith(LOAD_COMPLETE, false, this);

            if (onLoadComplete != null)
            {
                for (i=0;i<onLoadComplete.length;i++)
                {
                    if (onLoadComplete[i] != null)
                    {
                        var args:Array = [this];
                        args.length = onLoadComplete[i].length;
                        if (isDebugLoad)
                        {
                            setTimeout(onLoadComplete[i].apply, debugLoadLatencyMsec, null, args)
                        }
                        else
                        {
                            //trace(this,"     (onProgress) onLoadComplete:",onLoadComplete, "args:", args);
                            onLoadComplete[i].apply(null, args);
                        }
                    }
                }
            }
        }

        private function addPostLoadedData():void
        {
            Cc.info(LOG, this, "(addPostLoadedData) postLoadedLookup-names (Texture|TextureAtlas|Object|XML|ByteArray):",
                    ObjectUtil.getPropertyNameArray(postLoadedTextureLookup), "|",
                    ObjectUtil.getPropertyNameArray(postLoadedTextureAtlasLookup), "|",
                    ObjectUtil.getPropertyNameArray(postLoadedObjectLookup), "|",
                    ObjectUtil.getPropertyNameArray(postLoadedXMLLookup), "|",
                    ObjectUtil.getPropertyNameArray(postLoadedByteArrayLookup));

            var name:String;
            for (name in postLoadedTextureLookup)
            {
                addTexture(name, postLoadedTextureLookup[name]);
            }
            for (name in postLoadedObjectLookup)
            {
                addObject(name, postLoadedObjectLookup[name]);
            }
            for (name in postLoadedXMLLookup)
            {
                addXml(name, postLoadedXMLLookup[name]);
            }
            for (name in postLoadedByteArrayLookup)
            {
                addByteArray(name, postLoadedByteArrayLookup[name]);
            }
            for (name in postLoadedTextureAtlasLookup)
            {
                if (getTextureAtlas(name))
                {
                    // Texture atlases from postLoadedTextureAtlasLookup were created with previous
                    // texture which could be disposed if post loading overwrites some textures (for example,
                    // load low quality graph in first load, and hight-quality in post load),
                    // so we need to recreate atlas wit
                    // lasXmls=true
                    var textureAtlas:TextureAtlas = new TextureAtlas(getTexture(name), getXml(name));

                    addTextureAtlas(name, textureAtlas);
                }
                else
                {
                    addTextureAtlas(name, postLoadedTextureAtlasLookup[name]);
                }
            }
            updateCachedTextureNames();

            postLoadedTextureLookup = {};
            postLoadedTextureAtlasLookup = {};
            postLoadedObjectLookup = {};
            postLoadedXMLLookup = {};
            postLoadedByteArrayLookup = {};
        }

        public function getMovieClip(prefix:String = "", fps:Number = 12):MovieClip
        {
            var textureVec:Vector.<Texture> = getTextures(prefix);
            if (textureVec && textureVec.length > 0)
            {
                return new MovieClip(textureVec, fps);
            }
            else
            {
                Cc.error(LOG, this, "(getMovieClip) Error to create MovieClip prefix:", prefix/*, Log.getStack()*/);
            }

            return null;
        }

        public function getImage(name:String):Image
        {
            var texture:Texture = getTexture(name);
            if (texture)
            {
                return new Image(texture);
            }
            else
            {
                Cc.error(LOG, this, "(getImage) Error to create Image name:", name/*, Log.getStack()*/);
            }

            return null;
        }

        override protected function loadRawAsset(rawAsset:Object, onProgress:Function, onComplete:Function):void
        {
            var extension:String = null;
            var loaderInfo:LoaderInfo = null;
            var urlLoader:URLLoader = null;
            var urlRequest:URLRequest = null;
            var url:String = null;
            var is1stError: Boolean = false;

            if (rawAsset is Class)
            {
                setTimeout(complete, 1, new rawAsset());
            }
            else if (rawAsset is String || rawAsset is URLRequest)
            {
                urlRequest = rawAsset as URLRequest || new URLRequest(rawAsset as String);
                url = urlRequest.url;
                extension = getExtensionFromUrl(url);

                urlLoader = new URLLoader();
                urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
                urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
                urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                urlLoader.addEventListener(HTTP_RESPONSE_STATUS, onHttpResponseStatus);
                urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
                urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
                urlLoader.load(urlRequest);
            }

            function onIoError(event:IOErrorEvent):void
            {
                var errInfo: String = "";
                log("IO error: " + event.text + " (" + urlRequest.url + ") " + errInfo);
                setTimeout( urlLoader.load, 2000, urlRequest );
            }

            function onSecurityError(event:SecurityErrorEvent):void
            {
                log("security error: " + event.text);
                setTimeout( urlLoader.load, 2000, urlRequest );

                dispatchEventWith(Event.SECURITY_ERROR, false, url);
                complete(null);
            }

            function onHttpResponseStatus(event:HTTPStatusEvent):void
            {
                if (extension == null)
                {
                    var headers:Array = event["responseHeaders"];
                    var contentType:String = getHttpHeader(headers, "Content-Type");

                    if (contentType && /(audio|image)\//.exec(contentType))
                        extension = contentType.split("/").pop();
                }
            }

            function onLoadProgress(event:ProgressEvent):void
            {
                if (onProgress != null && event.bytesTotal > 0)
                    onProgress(event.bytesLoaded / event.bytesTotal);
            }

            function onUrlLoaderComplete(event:Object):void
            {
                var bytes:ByteArray = transformData(urlLoader.data as ByteArray, url);
                var sound:Sound;

                if (bytes == null)
                {
                    complete(null);
                    return;
                }

                if (extension)
                    extension = extension.toLowerCase();

                switch (extension)
                {
                    case "mpeg":
                    case "mp3":
                        sound = new Sound();
                        sound.loadCompressedDataFromByteArray(bytes, bytes.length);
                        bytes.clear();
                        complete(sound);
                        break;
                    case "jpg":
                    case "jpeg":
                    case "png":
                    case "gif":
                        var loaderContext:LoaderContext = new LoaderContext(checkPolicyFile);
                        var loader:Loader = new Loader();
                        loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
                        loaderInfo = loader.contentLoaderInfo;
                        loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
                        loaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
                        loader.loadBytes(bytes, loaderContext);
                        break;
                    default: // any XML / JSON / binary data
                        complete(bytes);
                        break;
                }
            }

            function onLoaderComplete(event:Object):void
            {
                urlLoader.data.clear();
                complete(event.target.content);
            }

            function complete(asset:Object):void
            {
                // clean up event listeners

                if (urlLoader)
                {
                    urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
                    urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                    urlLoader.removeEventListener(HTTP_RESPONSE_STATUS, onHttpResponseStatus);
                    urlLoader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
                    urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
                }

                if (loaderInfo)
                {
                    loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
                    loaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
                }

                // On mobile, it is not allowed / endorsed to make stage3D calls while the app
                // is in the background. Thus, we pause queue processing if that's the case.

                if (SystemUtil.isDesktop)
                    onComplete(asset);
                else
                    SystemUtil.executeWhenApplicationIsActive(onComplete, asset);
            }
        }

        private function getHttpHeader(headers:Array, headerName:String):String
        {
            if (headers)
            {
                for each (var header:Object in headers)
                    if (header.name == headerName) return header.value;
            }
            return null;
        }

        private var _isAppStoreFilesTraced: Boolean;

        // Event handlers

    }
}