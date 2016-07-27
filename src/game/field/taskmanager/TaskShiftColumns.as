/**
 * Created by drummer on 22.06.16.
 */
package game.field.taskmanager
{
	import flash.geom.Point;
	import flash.utils.setTimeout;

	import game.field.FieldCell;
	import game.field.FieldItem;
	import game.field.GameField;

	import starling.animation.Tween;

	import starling.animation.Tween;
	import starling.core.Starling;

	public class TaskShiftColumns extends TaskBase
	{
		private var tweens:Vector.<Tween>;

		public function TaskShiftColumns(gameField:GameField)
		{
			super(gameField);
		}

		override public function execute():void
		{
			super.execute();
			shiftColumns();
		}

		private function shiftColumns():void
		{
			tweens = new Vector.<Tween>();
			var wasShiftedAnyColumn:Boolean;
			var emptyColumnIndex:int = getEmptyColumnIndex();
			var distance:int = 1;
			if (emptyColumnIndex != -1 && hasItemsToMoveToColumn(emptyColumnIndex))
			{
				for (var i:int=emptyColumnIndex+1;i<gameField.fieldWidth;i++)
				{
					if (!gameField.getCellAt(i, gameField.fieldHeight - 1).item)
					{
						if (wasShiftedAnyColumn)
						{
							break;
						}
						else
						{
							distance ++;
							continue;
						}
					}
					for (var j:int=0;j<gameField.fieldHeight;j++)
					{
						var cell:FieldCell = gameField.getCellAt(i, j);
						if (cell)
						{
							var item:FieldItem = cell.item;
							if (item)
							{
								wasShiftedAnyColumn = true;

								var p:Point = gameField.itemsFallLayer.globalToLocal(item.parent.localToGlobal(new Point(item.x, item.y)));
								cell.detachItem();
								gameField.itemsFallLayer.addChild(item);
								item.x = p.x;
								item.y = p.y;
								var tween:Tween = new Tween(item, 0.05);
								tween.moveTo(item.x - distance * FieldCell.SIZE, item.y);
								tween.onComplete = onTweenComplete;
								tween.onCompleteArgs = [tween, item, gameField.getCellAt(i - distance, j)];
								Starling.juggler.add(tween);
								tweens.push(tween);
							}
						}
					}
				}
			}
			else
			{
				complete();
			}
		}

		private function getEmptyColumnIndex():int
		{
			var index:int = -1;
			for (var i:int=0;i<gameField.fieldWidth;i++)
			{
				if (!gameField.getCellAt(i, gameField.fieldHeight - 1).item)
				{
					index = i;
					break;
				}
			}
			return index;
		}

		private function hasItemsToMoveToColumn(index:int):Boolean
		{
			for (var i:int=index+1;i<gameField.fieldWidth;i++)
			{
				if (gameField.getCellAt(i, gameField.fieldHeight - 1).item)
				{
					return true;
				}
			}
			return false;
		}

		private function onTweenComplete(tween:Tween, item:FieldItem, cell:FieldCell):void
		{
			tweens.splice(tweens.indexOf(tween), 1);
			Starling.juggler.remove(tween);
			cell.attachItem(item);
			if (!tweens.length)
			{
				setTimeout(shiftColumns, 100);
			}
		}

	}
}
