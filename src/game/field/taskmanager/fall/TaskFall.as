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

	public class TaskFall extends TaskBase
	{
		protected var items:Array;
		private var tweens:Array;

		public function TaskFall(gameField:GameField)
		{
			super(gameField)
		}

		override public function execute():void
		{
			items = [];
			calculateFalling();
		}

		protected function calculateFalling():void
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

		protected function canFallToCell(cell:FieldCell):Boolean
		{
			if ((!cell.item || cell.item.willFall) && cell.canContainItem && !cell.willFill)
			{
				return true;
			}
			return false;
		}

		protected function fall():void
		{
			var i:int;

			for (i=items.length-1;i>=0;i--)
			{
				if (!items[i].length)
				{
					items.splice(i, 1);
				}
			}

			if (!items.length)
			{
				fallComplete();
				return;
			}

			for (i=0;i<items.length;i++)
			{
				for (var j:int=0;j<items[i].length;j++)
				{
					var cell:FieldCell = items[i][j].cell;
					var item:FieldItem = cell.item;
					var fallToCell:int = items[i][j].fallTo;
					var p:Point = gameField.itemsFallLayer.globalToLocal(item.parent.localToGlobal(new Point(item.x, item.y)));
					cell.detachItem();
					gameField.itemsFallLayer.addChild(item);
					item.x = p.x;
					item.y = p.y;
					var fallToY:Number = (fallToCell - cell.position.y) * FieldCell.SIZE + item.y;
					var tween:Tween = new Tween(item, (fallToCell - cell.position.y) * 0.1, Transitions.EASE_IN);
					tween.moveTo(item.x, fallToY);
					tween.onComplete = onFallTweenComplete;
					tween.onCompleteArgs = [tween, items[i][j], item];
					tween.delay = j * 0.03;
					Starling.juggler.add(tween);
					if (!tweens)
					{
						tweens = [];
					}
					tweens.push(tween);
				}
			}
		}

		private function onFallTweenComplete(tween:Tween, obj:Object, item:FieldItem):void
		{
			if (tween)
			{
				Starling.juggler.remove(tween);
				tweens.splice(tweens.indexOf(tween), 1);
			}

			var cell:FieldCell = obj.cell;
			if (cell && item)
			{
				var destCell:FieldCell = gameField.getCellAt(cell.position.x, obj.fallTo);
				if (destCell)
				{
					destCell.attachItem(item);
				}
			}

			if (!tweens.length)
			{
				tweens = null;
				fallComplete();
			}
		}

		private function fallComplete():void
		{
			for (var i:int=0;i<gameField.fieldWidth;i++)
			{
				for (var j:int = 0; j < gameField.fieldHeight; j++)
				{
					var cell:FieldCell = gameField.getCellAt(i, j);
					if (cell)
					{
						cell.willFill = false;
						if (cell.item)
						{
							cell.item.willFall = false;
						}
					}
				}
			}

			onFinishFalling();
		}

		protected function onFinishFalling():void
		{
			complete();
		}

	}
}
