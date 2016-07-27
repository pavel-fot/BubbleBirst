/**
 * Created by drummer on 15.06.16.
 */
package game.field.taskmanager
{
	import game.field.FieldCell;
import game.field.FieldCell;
	import game.field.FieldCellPosition;
	import game.field.GameField;

	public class TaskRemoveItem extends TaskBase
	{
		public var cellPosition:FieldCellPosition;
		public var removeItemAnimationCallback:Function;

		private var _isRemoveItemAnimationComplete:Boolean;

		public function TaskRemoveItem(gameField:GameField)
		{
			super(gameField);
		}

		override public function execute():void
		{
			super.execute();

			var cell:FieldCell = gameField.getCellAt(cellPosition.x, cellPosition.y);
			if (cell.item)
			{
				cell.removeItem(onRemoveItemAnimationCallback);
			}
			else
			{
				onRemoveItemAnimationCallback();
			}

			complete();
		}

		private function onRemoveItemAnimationCallback():void
		{
			_isRemoveItemAnimationComplete = true;
			if (removeItemAnimationCallback != null)
			{
				removeItemAnimationCallback();
			}
		}

		public function get isRemoveItemAnimationComplete():Boolean
		{
			return _isRemoveItemAnimationComplete;
		}

	}
}
