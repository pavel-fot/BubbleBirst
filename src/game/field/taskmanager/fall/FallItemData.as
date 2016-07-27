/**
 * Created by drummer on 07.07.16.
 */
package game.field.taskmanager.fall
{
	import flash.geom.Point;

	public class FallItemData
	{
		public var startPosition:Point;
		public var endPosition:Point;

		public function FallItemData(indexX:int, indexY:int)
		{
			startPosition = new Point(indexX, indexY);
			endPosition = new Point(indexX, indexY);
		}
	}
}
