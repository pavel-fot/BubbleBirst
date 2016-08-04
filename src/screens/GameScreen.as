/**
 * Created by drummer on 14.06.16.
 */
package screens
{
    import game.field.GameField;

import starling.display.Image;

import starling.display.Sprite;

    import ui.com.DisplayComponent;
import ui.toppanel.TopPanel;

    public class GameScreen extends DisplayComponent
    {
        private var topPanel:TopPanel;
        private var gameField:GameField;
        private var bg:Image;

        public function GameScreen()
        {
            textures = ['level'];
        }

        override protected function onCreate():void
        {
            bg = assetManager.getImage('levelBg');
            addChild(bg);

            gameField = new GameField();
            gameField.init();
            addChild(gameField);
            gameField.x = 190;
            gameField.y = 140;

            topPanel = new TopPanel();
            addChild(topPanel);
            topPanel.init();
        }
    }
}
