/**
 * Created by drummer on 16.06.16.
 */
package ui.toppanel
{
	import ui.com.DisplayComponent;

	public class TopPanel extends DisplayComponent
	{
		private var coinsPanel:TopPanelCoins;

		public function TopPanel()
		{
			textures = ['common'];
		}

		override protected function onCreate():void
		{
			coinsPanel = new TopPanelCoins();
			addChild(coinsPanel);
			coinsPanel.assetManager = assetManager;
			coinsPanel.init();
			coinsPanel.x = 20;
			coinsPanel.y = 10;
		}
	}
}
