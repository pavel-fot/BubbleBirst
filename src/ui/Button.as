/**
 * Created by drummer on 26.07.16.
 */
package ui
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	public class Button extends Sprite
	{
		private var image:Image;

		public function Button(texture:Texture)
		{
			image = new Image(texture);
			addChild(image);
		}

		override public function dispose():void
		{
			image.texture.dispose();
			image.dispose();
			image = null;

			super.dispose();
		}
	}
}
