/**
 * Created by drummer on 26.07.16.
 */
package ui.toppanel
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.filters.DropShadowFilter;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import starling.utils.Align;

	import ui.Button;

	import ui.com.DisplayComponent;

	import utils.TextFieldFactory;

	public class TopPanelNum extends DisplayComponent
	{
		protected var plate:Sprite;
		private var plateBg:Image;
		private var addBtn:Button;
		private var _showAddButton:Boolean;
		protected var tf:TextField;

		public function TopPanelNum()
		{

		}

		override protected function onCreate():void
		{
			plate = new Sprite();
			addChildAt(plate, 0);
			plateBg = assetManager.getImage('topPlateNum');
			plate.addChild(plateBg);

			tf = TextFieldFactory.create(TextFieldFactory.SKRANJI_BOLD, '0', 25, 0xffffff, TextFieldAutoSize.VERTICAL, Align.RIGHT);
			tf.width = 110;
			tf.x = 43;
			tf.y = plate.height / 2 - tf.height / 2 + 1;
			tf.filter = new DropShadowFilter(2, 0.785, 0x0, 0.8, 0);
			plate.addChild(tf);

			showAddButton = _showAddButton;
		}
		
		public function get showAddButton():Boolean
		{
			return _showAddButton;
		}

		public function set showAddButton(value:Boolean):void
		{
			_showAddButton = value;
			if (value)
			{
				if (!assetManager)
				{
					return;
				}
				if (!addBtn)
				{
					addBtn = new Button(assetManager.getTexture('plusBtn'));
					addBtn.x = plate.width - addBtn.width - 9;
					addBtn.y = plate.height / 2 - addBtn.height / 2;
				}
				plate.addChild(addBtn);
			}
			else if (addBtn && addBtn.parent)
			{
				addBtn.removeFromParent();
			}
		}

	}
}
