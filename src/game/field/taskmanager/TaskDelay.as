/**
 * Created by drummer on 16.06.16.
 */
package game.field.taskmanager
{
	import flash.utils.setTimeout;

	import game.field.GameField;

	public class TaskDelay extends TaskBase
	{
		public var delayMS:int;

		public function TaskDelay(gameField:GameField)
		{
			super(gameField);
		}

		override public function execute():void
		{
			if (delayMS < 50)
			{
				complete();
				return;
			}

			setTimeout(complete, delayMS);
		}

	}
}
