/**
 * Created by drummer on 22.06.16.
 */
package game.field.taskmanager
{
	import game.field.GameField;

	public class TaskFreezeField extends TaskBase
	{
		public function TaskFreezeField(gameField:GameField)
		{
			super(gameField);
		}

		override public function execute():void
		{
			super.execute();

			gameField.freeze();
			complete();
		}

	}
}
