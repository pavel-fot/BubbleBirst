/**
 * Created by drummer on 16.06.16.
 */
package ui.toppanel
{
	import starling.display.Image;
import starling.text.TextFormat;
import starling.utils.Align;

import ui.com.DisplayComponent;

	public class TopPanelLife extends TopPanelNum
	{
		private var lifeIcon:Image;

		public function TopPanelLife()
		{
			showAddButton = true;
		}

		override protected function onCreate():void
		{
			super.onCreate();
			lifeIcon = assetManager.getImage('heart');
			addChild(lifeIcon);

			plate.x = lifeIcon.width / 2 - 9;
			plate.y = lifeIcon.height / 2 - plate.height / 2 + 3;

			var tFormat:TextFormat = tf.format;
			tFormat.horizontalAlign = Align.CENTER;
			tf.format = tFormat;
			tf.text = '5';
		}
	}
}
