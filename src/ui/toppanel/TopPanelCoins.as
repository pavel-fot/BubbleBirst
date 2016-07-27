/**
 * Created by drummer on 16.06.16.
 */
package ui.toppanel
{
	import starling.display.Image;

	import ui.com.DisplayComponent;

	public class TopPanelCoins extends TopPanelNum
	{
		private var coinIcon:Image;

		public function TopPanelCoins()
		{
			showAddButton = true;
		}

		override protected function onCreate():void
		{
			super.onCreate();
			coinIcon = assetManager.getImage('coin');
			addChild(coinIcon);

			plate.x = coinIcon.width / 2 - 5;
			plate.y = coinIcon.height / 2 - plate.height / 2 + 5;
		}
	}
}
