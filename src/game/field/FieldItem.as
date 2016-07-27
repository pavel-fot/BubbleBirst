/**
 * Created by drummer on 15.06.16.
 */
package game.field
{
    import game.field.taskmanager.fall.FallItemData;

    import starling.display.Image;
    import starling.textures.TextureSmoothing;

    import ui.com.DisplayComponent;

    public class FieldItem extends DisplayComponent
    {
        public var willFall:Boolean;
        public var fallData:FallItemData;

        private var _type:int = -1;
        private var image:Image;

        public function FieldItem(type:int)
        {
            _type = type;
        }

        public function get type():int
        {
            return _type;
        }

        override protected function onCreate():void
        {
            draw();
        }

        private function draw():void
        {
            image = assetManager.getImage('bubble' + type);
            addChild(image);
            image.textureSmoothing = TextureSmoothing.TRILINEAR;
        }

    }
}
