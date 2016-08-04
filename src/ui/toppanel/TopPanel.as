/**
 * Created by drummer on 16.06.16.
 */
package ui.toppanel
{
	import ui.com.DisplayComponent;

	public class TopPanel extends DisplayComponent
	{
		private var coinsPanel:TopPanelCoins;
		private var lifePanel:TopPanelLife;

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

			lifePanel = new TopPanelLife();
			addChild(lifePanel);
			lifePanel.assetManager = assetManager;
			lifePanel.init();
			lifePanel.x = coinsPanel.x + coinsPanel.width + 20;
			lifePanel.y = 17;
		}
	}
}
