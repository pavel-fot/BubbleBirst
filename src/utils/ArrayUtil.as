package utils
{
	/**
	 * ArrayUtil.
	 * 
	 */
	public class ArrayUtil
	{
		
		// Class constants
		
		// Class variables
		
		// Class methods

		public static function getNearestNullIndex(array:Array, startIndex:int = 0):int
		{
			if (!array)
			{
				return -1;
			}

			if (startIndex < 0)
			{
				startIndex = 0;
			}

			var length:int = array.length;

			for (var i:int = startIndex, j:int = i; i < length || j >= 0; i++, j--)
			{
				if (i < length && array[i] == null)
				{
					return i;
				}
				else if (j >= 0 && array[j] == null)
				{
					return j;
				}
			}

			return -1;
		}

		/**
		 * @param source (Array|Vector)
		 */
		public static function getSubArrayByProperty(source:*, propertyName:String):Array
		{
			if (!source || !propertyName)
			{
				return [];
			}

			var result:Array = [];

			for (var i:int = 0; i < source.length; i++)
			{
				var object:Object = source[i];
				result[result.length] = object && object.hasOwnProperty(propertyName) ? object[propertyName] : null;
			}
			return result;
		}

		// getItemByProperty[{a: 2, b: 1}, {a: 3, b: 5}], "a", 2) => {a: 2, b: 1}
		// getItemByProperty[{a: 2, b: 1}, {a: 3, b: 5}], "a", 4) => null
		public static function getItemByProperty(array:Array, propertyName:String, propertyValue:*):*
		{
			if (!array || !propertyName)
			{
				return [];
			}

			for (var i:int = 0; i < array.length; i++)
			{
				var object:Object = array[i];
				if (object && object.hasOwnProperty(propertyName) && object[propertyName] == propertyValue)
				{
					return object;
				}
			}
			return null;
		}

		public static function nonNullCount(array:Array):int
		{
			if (!array)
			{
				return 0;
			}

			var result:int = 0;

			for (var i:int = 0; i < array.length; i++)
			{
				if (array[i] != null)
				{
					result++;
				}
			}

			return result;
		}

//		public static function getIndexByProperty(array:Array, propertyName:String, value:*, isStrict:Boolean = false):int
//		{
//			if (!array || !propertyName)
//			{
//				return -1;
//			}
//
//			for (var i:int = 0; i < array.length; i++)
//			{
//				var data:Object = array[i];
//
//				if (!data || !data.hasOwnProperty(propertyName))
//				{
//					continue;
//				}
//
//				var property:* = data[propertyName];
//
//				if ((!isStrict && property == value) || (isStrict && property === value))
//				{
//					return i;
//				}
//			}
//
//			return -1;
//		}

		public static function removeItemByProperty(array:Array, propertyName:String, value:*, isStrict:Boolean = false):*
		{
			if (!array || !propertyName)
			{
				return null;
			}

			for (var i:int = array.length - 1; i >= 0; i--)
			{
				var data:Object = array[i];

				if (!data || !data.hasOwnProperty(propertyName))
				{
					continue;
				}

				var property:* = data[propertyName];

				if ((!isStrict && property == value) || (isStrict && property === value))
				{
					var result:* = array[i];
					array.splice(i, 1);
					return result;
				}
			}

			return null;
		}
		
		public static function removeItem(array:Array, item:*):int
		{
			if (!array)
			{
				return -1;
			}

			var index:int = array.indexOf(item);
			if (index != -1)
			{
				array.splice(index, 1);
			}
			return index;
		}
		
		public static function shuffled(array:Array, iterationCount:int = 1):void
		{
			const length:int = array.length;
			var index1:int;
			var index2:int;
			var temp:*;
			for (var i:int = 0; i < iterationCount; i++)
			{
				for (var j:int = 0; j < array.length; j++)
				{
					index1= Math.random() * length;
					index2 = Math.random() * length;
					temp = array[index1];
					array[index1] = array[index2];
					array[index2] = temp;
				}
			}
		}
		
		/**
		 * Перемешивает элементы массива в случайном порядке
		 */		
		public static function randomize( array : Array ):void
		{
			array.sort( randomizeFunction );
		}
		
		private static function randomizeFunction ( a : *, b : * ) : int 
		{
			return ( Math.random() > .5 ) ? 1 : -1;
		}

		public static function skipNulls(array:Array):Array
		{
			if (!array)
			{
				return array;
			}

			var result:Array = [];

			for (var i:int = 0; i < array.length; i++)
			{
				if (array[i] != null)
				{
					result[result.length] = array[i];
				}
			}

			return result;
		}

		public static function toArray(object:Object):Array
		{
			if (!object)
			{
				return null;
			}

			if (object is Array)
			{
				return object as Array;
			}

			var result:Array = [];

			for each (var item:* in object)
			{
				result[result.length] = item;
			}

			return result;
		}

		public static function pushUnique(array:Array, item:*):void
		{
			if (!array)
			{
				return;
			}
			
			var index:int = array.indexOf(item);
			if (index == -1)
			{
				array[array.length] = item;
			}
		}
		
	}
}