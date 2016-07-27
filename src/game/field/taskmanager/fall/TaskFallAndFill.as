/**
 * Created by drummer on 17.06.16.
 */
package game.field.taskmanager.fall
{
import game.field.taskmanager.*;
	import flash.geom.Point;
	import flash.geom.Point;

	import game.field.FieldCell;
	import game.field.FieldCellPosition;
	import game.field.FieldItem;
	import game.field.GameField;

	import starling.animation.Transitions;

	import starling.animation.Tween;
	import starling.core.Starling;

	public class TaskFallAndFill extends TaskFall
	{
		public function TaskFallAndFill(gameField:GameField)
		{
			super(gameField)
		}
		
		override protected function calculateFalling():void
		{
			for (var i:int=0;i<gameField.fieldWidth;i++)
			{
				items[i] = [];

				for (var j:int=gameField.fieldHeight-1;j>=0;j--)
				{
					var cell:FieldCell = gameField.getCellAt(i, j);
					if (cell.position.y < gameField.fieldHeight - 1) // not bottom cell
					{
						if (cell.canFall && cell.item)
						{
							var shiftIndex:int = 1;
							var nextCell:FieldCell = gameField.getCellAt(i, j + shiftIndex);
							while (nextCell && canFallToCell(nextCell))
							{
								if (shiftIndex == 1)
								{
									items[i].push({cell:cell, fallTo:0});
									cell.item.willFall = true;
								}

								items[i][items[i].length - 1].fallTo = nextCell.position.y;
								shiftIndex ++;
								nextCell = gameField.getCellAt(i, j + shiftIndex);
							}
							gameField.getCellAt(i, j + shiftIndex - 1).willFill = true;
						}
					}
				}
			}

			fall();
		}
		
	}
}
