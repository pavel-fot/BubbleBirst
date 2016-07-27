/**
 * Created by drummer on 01.07.16.
 */
package game.field.taskmanager.fall
{
	import flash.geom.Point;

	import game.field.FieldCell;
	import game.field.FieldCell;
	import game.field.FieldItem;
	import game.field.GameField;
	import game.field.taskmanager.TaskBase;
	import game.field.taskmanager.TaskUnfreezeField;

	import starling.animation.Transitions;

	import starling.animation.Tween;
	import starling.core.Starling;

	public class TaskFall2 extends TaskBase
	{
		private var steps:Array;
		private var tweens:Array;
		
		public function TaskFall2(gameField:GameField)
		{
			super(gameField);
			steps = [];
		}

		override public function execute():void
		{
			super.execute();
			fillFieldModel();
			calculateFallStep();
		}

		private function fillFieldModel():void
		{
			var fieldModel:Array = [];
			for (var i:int=0;i<gameField.fieldWidth;i++)
			{
				fieldModel[i] = [];
				for (var j:int=0;j<gameField.fieldHeight;j++)
				{
					var cell:FieldCell = gameField.getCellAt(i, j);
					if (cell && cell.item)
					{
						var fallItem:FallFieldItem = new FallFieldItem(i, j);
						fieldModel[i][j] = fallItem;
					}
					else
					{
						fieldModel[i][j] = null;
					}
				}
			}
			steps.push(fieldModel);
		}

		private function calculateFallStep():void
		{
			// fill new field model from previous
			var i:int;
			var j:int;
			var fieldModel:Array = [];
			var prevFieldModel:Array = steps[steps.length - 1];

			for (i=0;i<gameField.fieldWidth;i++)
			{
				fieldModel[i] = [];
				for (j = 0; j < gameField.fieldHeight; j++)
				{
					var prevFallItem:FallFieldItem = prevFieldModel[i][j];
					var fallItem:FallFieldItem = prevFallItem == null ? null : prevFallItem.clone();
					fieldModel[i][j] = fallItem;
				}
			}

			// calculate fall step in new field model
			var hasMoves:Boolean;

			for (i=0;i<gameField.fieldWidth;i++)
			{
				for (j=gameField.fieldHeight-1;j>=0;j--)
				{
					var cell:FieldCell = gameField.getCellAt(i, j);
					var nextCell:FieldCell = gameField.getCellAt(i, j + 1);

					if (cell && nextCell && cell.canFall && nextCell.canContainItem && fieldModel[i][j] && !fieldModel[i][j + 1])
					{
						fieldModel[i][j + 1] = fieldModel[i][j];
						fieldModel[i][j] = null;
						hasMoves = true;
					}
				}
			}

			steps.push(fieldModel);
			if (hasMoves)
			{
				calculateFallStep();
			}
			else
			{
				steps.pop();
				if (steps.length > 1)
				{
					calculateAllFalls();
				}
				else
				{
					onFinishFalling();
				}
			}
		}

		private function calculateAllFalls():void
		{
			var fallingItems:Array = new Array();

			for (var n:int=1;n<steps.length;n++)
			{
				var fieldModel:Array = steps[n];
				var prevFieldModel:Array = steps[n - 1];
				
				for (var i:int=0;i<fieldModel.length;i++)
				{
					for (var j:int=1;j<fieldModel[i].length;j++) // we don't need to check top items, cause they don't falling if they are on the top
					{
						var fallingItem:FallFieldItem = fieldModel[i][j];
						var prevFallingItem:FallFieldItem = prevFieldModel[i][j - 1];
						if (fallingItem && prevFallingItem && fallingItem.startIndexY == prevFallingItem.startIndexY)
						{
							var item:FieldItem = gameField.getCellAt(i, j - n).item;
							if (fallingItems.indexOf(item) == -1)
							{
								fallingItems.push(item);
								item.fallData = new FallItemData(i, j - n);
							}
							item.fallData.endPosition.y ++;
						}
					}
				}
			}

			fall(fallingItems);
		}

		private function fall(items:Array):void
		{
			var currX:int = -1;
			var delay:int = 0;

			for (var i:int=items.length-1;i>=0;i--)
			{
				var item:FieldItem = items[i];
				var cell:FieldCell = gameField.getCellAt(item.fallData.startPosition.x, item.fallData.startPosition.y);
				var p:Point = gameField.itemsFallLayer.globalToLocal(item.parent.localToGlobal(new Point(item.x, item.y)));
				cell.detachItem();
				gameField.itemsFallLayer.addChild(item);
				item.x = p.x;
				item.y = p.y;
				var fallToY:Number = (item.fallData.endPosition.y - item.fallData.startPosition.y) * FieldCell.SIZE + item.y;
				var tween:Tween = new Tween(item, (item.fallData.endPosition.y - item.fallData.startPosition.y) * 0.1, Transitions.EASE_IN);
				tween.moveTo(item.x, fallToY);
				tween.onComplete = onFallTweenComplete;
				tween.onCompleteArgs = [tween, item, items];
				if (currX == -1)
				{
					currX = item.fallData.startPosition.x;
				}
				if (item.fallData.startPosition.x != currX)
				{
					currX = item.fallData.startPosition.x;
					delay = 0;
				}
				else
				{
					delay ++;
				}
				tween.delay = delay * 0.03;
				Starling.juggler.add(tween);
				if (!tweens)
				{
					tweens = [];
				}
				tweens.push(tween);
			}

			function print():void
			{
				for (var i:int=0;i<items.length;i++)
				{
					var item:FieldItem = items[i];
					trace(item.fallData.startPosition);
				}
				trace('----------------------');
			}
		}

		private function onFallTweenComplete(tween:Tween, item:FieldItem, items:Array):void
		{
			if (tween)
			{
				Starling.juggler.remove(tween);
				tweens.splice(tweens.indexOf(tween), 1);
			}

			var destCell:FieldCell = gameField.getCellAt(item.fallData.endPosition.x, item.fallData.endPosition.y);
			if (destCell)
			{
				destCell.attachItem(item);
			}

			if (!tweens.length)
			{
				tweens = null;
				fallComplete(items);
			}
		}

		private function fallComplete(items:Array):void
		{
			for (var i:int=0;i<items.length;i++)
			{
				var item:FieldItem = items[i];
				item.fallData = null;
			}

			onFinishFalling();
		}

		protected function onFinishFalling():void
		{
			steps = null;

			var taskUnfreezeField:TaskUnfreezeField = new TaskUnfreezeField(gameField);
			gameField.taskManager.addTask(taskUnfreezeField);

			complete();
		}

	}
}
