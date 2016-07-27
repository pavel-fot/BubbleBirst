/**
 * Created by drummer on 22.06.16.
 */
package game.field.taskmanager
{
	import game.field.GameField;

	public class TaskUnfreezeField extends TaskBase
	{
		public function TaskUnfreezeField(gameField:GameField)
		{
			super(gameField);
		}

		override public function execute():void
		{
			super.execute();

			gameField.unfreeze();
			complete();
		}

	}
}
