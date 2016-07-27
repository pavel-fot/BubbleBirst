/**
 * Created by drummer on 14.06.16.
 */
package ui.com
{
    import starling.display.Sprite;

    import utils.AssetManagerExt;
    import utils.ResourceManager;
    import utils.SystemManager;

    public class DisplayComponent extends Sprite
    {
        protected var textures:Array = [];
        protected var postLoadTextures:Array = [];
        public var assetManager:AssetManagerExt;

        public function DisplayComponent()
        {

        }

        public function init():void
        {
            loadAssets();
        }

        private function loadAssets():void
        {
            if (textures.length)
            {
                var resourceManager:ResourceManager = SystemManager.resourceManager;
                assetManager = resourceManager.getAssetManagerByPackName(textures[0]);
                assetManager.load(onLoadComplete);

                function onLoadComplete():void
                {
                    onCreate();
                }
            }
            else
            {
                onCreate();
            }
        }

        protected function onCreate():void
        {

        }

        override public function dispose():void
        {
            if (textures.length)
            {
                for (var i:int=0;i<textures.length;i++)
                {
                    SystemManager.resourceManager.disposeAssetManagerByPackName(textures[i]);
                }
            }
            super.dispose();
        }

    }
}
