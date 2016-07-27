/**
 * Created by drummer on 15.06.16.
 */
package game.field.taskmanager
{
	import game.field.GameField;

	import starling.events.EventDispatcher;
	
	public class TaskBase extends EventDispatcher
	{
		protected var gameField:GameField;
		private var _isComplete:Boolean;

		public function TaskBase(gameField:GameField)
		{
			this.gameField = gameField;
		}

		public function execute():void
		{

		}

		public function complete():void
		{
			_isComplete = true;
			dispatchEvent(new TaskEvent(TaskEvent.COMPLETE));
		}

		public function get isComplete():Boolean
		{
			return _isComplete;
		}
	}
}
