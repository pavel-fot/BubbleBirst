/**
 * Created by drummer on 17.06.16.
 */
package game.field.taskmanager.fall
{
import game.field.taskmanager.*;
	import game.field.GameField;

	public class TaskFallAndShift extends TaskFall2
	{
		public function TaskFallAndShift(gameField:GameField)
		{
			super(gameField)
		}

		override protected function onFinishFalling():void
		{
			var taskShiftColumns:TaskShiftColumns = new TaskShiftColumns(gameField);
			gameField.taskManager.addTask(taskShiftColumns);

			var taskUnfreezeField:TaskUnfreezeField = new TaskUnfreezeField(gameField);
			gameField.taskManager.addTask(taskUnfreezeField);

			complete();
		}

	}
}
