/**
 * Created by drummer on 15.06.16.
 */
package game.field
{
	import game.field.FieldCellPosition;
	import game.field.GameField;
	
	public class FieldCellPosition
	{
		public var x:int;
		public var y:int;

		public function FieldCellPosition(x:int, y:int)
		{
			this.x = x;
			this.y = y;
		}

		public static function getCellsAround(gameField:GameField, cellPosition:FieldCellPosition, padding:int = 1, full:Boolean = false):Vector.<FieldCell>
		{
			var cells:Vector.<FieldCell> = new Vector.<FieldCell>();
			var cell:FieldCell;

			if (full && padding)
			{
				var i:int;

				for (i = 0; i < padding * 2 + 1; i ++)
				{
					cell = gameField.getCellAt(cellPosition.x - padding + i, cellPosition.y - padding);
					if (cell && cells.indexOf(cell) == -1)
					{
						cells.push(cell);
					}
					cell = gameField.getCellAt(cellPosition.x + padding, cellPosition.y - padding + i);
					if (cell && cells.indexOf(cell) == -1)
					{
						cells.push(cell);
					}
					cell = gameField.getCellAt(cellPosition.x - padding + i, cellPosition.y + padding);
					if (cell && cells.indexOf(cell) == -1)
					{
						cells.push(cell);
					}
					cell = gameField.getCellAt(cellPosition.x - padding, cellPosition.y - padding + i);
					if (cell && cells.indexOf(cell) == -1)
					{
						cells.push(cell);
					}
				}
			}
			else
			{
				cell = gameField.getCellAt(cellPosition.x, cellPosition.y - padding);
				if (cell)
				{
					cells.push(cell);
				}
				cell = gameField.getCellAt(cellPosition.x + padding, cellPosition.y);
				if (cell && cells.indexOf(cell) == -1)
				{
					cells.push(cell);
				}
				cell = gameField.getCellAt(cellPosition.x, cellPosition.y + padding);
				if (cell && cells.indexOf(cell) == -1)
				{
					cells.push(cell);
				}
				cell = gameField.getCellAt(cellPosition.x - padding, cellPosition.y);
				if (cell && cells.indexOf(cell) == -1)
				{
					cells.push(cell);
				}
			}

			return cells;
		}

		public function toString():String
		{
			return '[' + x + ', ' + y + ']';
		}
		
	}
}
