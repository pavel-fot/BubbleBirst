/**
 * Created by drummer on 14.06.16.
 */
package screens
{
    import game.field.GameField;

    import starling.display.Sprite;

    import ui.com.DisplayComponent;
import ui.toppanel.TopPanel;

    public class GameScreen extends DisplayComponent
    {
        private var topPanel:TopPanel;
        private var gameField:GameField;

        public function GameScreen()
        {

        }

        override protected function onCreate():void
        {
            gameField = new GameField();
            gameField.init();
            addChild(gameField);
            gameField.x = 300;
            gameField.y = 100;

            topPanel = new TopPanel();
            addChild(topPanel);
            topPanel.init();
        }
    }
}
