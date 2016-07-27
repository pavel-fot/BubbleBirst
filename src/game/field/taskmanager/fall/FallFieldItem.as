/**
 * Created by drummer on 01.07.16.
 */
package game.field.taskmanager.fall
{
	public class FallFieldItem
	{
		private var _startIndexX:int;
		private var _startIndexY:int;

		public function FallFieldItem(startIndexX:int, startIndexY:int)
		{
			_startIndexX = startIndexX;
			_startIndexY = startIndexY;
		}

		public function clone():FallFieldItem
		{
			return new FallFieldItem(startIndexX, startIndexY);
		}

		public function get startIndexX():int
		{
			return _startIndexX;
		}

		public function get startIndexY():int
		{
			return _startIndexY;
		}
	}
}
