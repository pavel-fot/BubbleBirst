/**
 * Created by drummer on 15.06.16.
 */
package game.field.taskmanager
{
	import game.field.GameField;

	public class TaskManager
    {
		private var gameField:GameField
		private var queue:Vector.<TaskBase>;
		private var currentTask:TaskBase;

        public function TaskManager(gameField:GameField)
        {
			this.gameField = gameField;
			queue = new Vector.<TaskBase>();
        }
        
        public function addTask(task:TaskBase):void
		{
			queue.push(task);
			if (!currentTask)
			{
				executeQueue();
			}
		}

		private function executeQueue():void
		{
			executeNextTask();
		}

		private function executeNextTask():void
		{
			if (queue.length)
			{
				currentTask = queue.shift();
				//trace('[Task Manager] Task execute', currentTask);
				currentTask.addEventListener(TaskEvent.COMPLETE, onTaskComplete);
				currentTask.execute();
			}
			else
			{
				currentTask = null;
			}
		}

		private function onTaskComplete(event:TaskEvent):void
		{
			//trace('[Task Manager] Task complete', currentTask, '(' + queue.length + ' in queue)');
			currentTask.removeEventListener(TaskEvent.COMPLETE, onTaskComplete);
			executeNextTask();
		}
    }
}
