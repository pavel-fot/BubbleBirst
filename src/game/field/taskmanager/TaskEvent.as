/**
 * Created by drummer on 15.06.16.
 */
package game.field.taskmanager
{
	import starling.events.Event;

	public class TaskEvent extends Event
	{
		public static const COMPLETE:String = 'complete';

		public function TaskEvent(type:String, bubbles:Boolean=false, data:Object=null)
		{
			super(type, bubbles, data)
		}
	}
}
