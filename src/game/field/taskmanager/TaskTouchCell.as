/**
 * Created by drummer on 15.06.16.
 */
package game.field.taskmanager
{
	import game.field.FieldCell;
	import game.field.FieldCellPosition;
	import game.field.GameField;
	import game.field.taskmanager.fall.TaskFall2;
	import game.field.taskmanager.fall.TaskFallAndShift;

	public class TaskTouchCell extends TaskBase
	{
		public var cell:FieldCell;
		private var removePadding:int;
		private var originalType:int;
		private var originalPosition:FieldCellPosition;
		private var removedCells:Vector.<FieldCell> = new Vector.<FieldCell>();
		private var removeItemTask:TaskRemoveItem;
		
		public function TaskTouchCell(gameField:GameField)
		{
			super(gameField);
		}

		override public function execute():void
		{
			super.execute();
			if (!cell || !cell.item)
			{
				complete();
				return;
			}

			var taskFreezeField:TaskFreezeField = new TaskFreezeField(gameField);
			gameField.taskManager.addTask(taskFreezeField);

			originalType = cell.item.type;
			originalPosition = new FieldCellPosition(cell.position.x, cell.position.y);
			removeItems(getCellsToRemove());

			complete();
		}

		private function getCellsToRemove():Vector.<FieldCell>
		{
			var cells:Vector.<FieldCell> = new Vector.<FieldCell>();

			if (!removedCells.length)
			{
				removedCells.push(cell);
				cells.push(cell);
			}
			else
			{
				var aroundCells:Vector.<FieldCell> = FieldCellPosition.getCellsAround(gameField, cell.position, removePadding, true);
				var cellsByItemType:Vector.<FieldCell> = new Vector.<FieldCell>();
				for (var i:int=0;i<aroundCells.length;i++)
				{
					if (aroundCells[i].item && aroundCells[i].item.type == originalType)
					{
						cellsByItemType.push(aroundCells[i]);
					}
				}

				var hasCellToRemoveItem:Boolean = true;
				while (hasCellToRemoveItem)
				{
					hasCellToRemoveItem = false;
					for (i=0;i<cellsByItemType.length;i++)
					{
						var aroundCellsToCheckRemoved:Vector.<FieldCell> = FieldCellPosition.getCellsAround(gameField, cellsByItemType[i].position);
						for (var j:int=0;j<aroundCellsToCheckRemoved.length;j++)
						{
							if (cells.indexOf(cellsByItemType[i]) == -1 && removedCells.indexOf(aroundCellsToCheckRemoved[j]) != -1)
							{
								removedCells.push(cellsByItemType[i]);
								cells.push(cellsByItemType[i]);
								hasCellToRemoveItem = true;
								break;
							}
						}
					}
				}
			}

			return cells;
		}

		private function removeItems(cells:Vector.<FieldCell>):void
		{
			for (var i:int=0;i<cells.length;i++)
			{
				removeItemTask = new TaskRemoveItem(gameField);
				removeItemTask.cellPosition = cells[i].position;
				gameField.taskManager.addTask(removeItemTask);
			}

			var delay:TaskDelay = new TaskDelay(gameField);
			delay.delayMS = 50;
			gameField.taskManager.addTask(delay);
			delay.addEventListener(TaskEvent.COMPLETE, onRemoveItemsComplete);
		}

		private function onRemoveItemsComplete(event:TaskEvent):void
		{
			event.target.removeEventListener(TaskEvent.COMPLETE, onRemoveItemsComplete);

			removePadding ++;
			var cells:Vector.<FieldCell> = getCellsToRemove();
			if (cells.length)
			{
				removeItems(cells);
			}
			else
			{
				finish();
			}
		}
		
		private function finish():void
		{
			var task:TaskFallAndShift = new TaskFallAndShift(gameField);
			//var task:TaskFallAndFill = new TaskFallAndFill(gameField);
			//var task:TaskFall2 = new TaskFall2(gameField);
			gameField.taskManager.addTask(task);

			complete();
		}

	}
}
