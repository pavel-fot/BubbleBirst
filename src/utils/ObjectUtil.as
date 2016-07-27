package utils
{
import com.junkbyte.console.Cc; 

	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	/**
	 * ObjectUtil.
	 * 
	 */
	public class ObjectUtil
	{
		
		// Class constants
		public static const LOG:String = "objectutil";
		
		// Class variables
		
		// Class methods

		// Process classes
		
		public static function treatClassName(object:*, isStringOrClassOnly:Boolean = false):String
		{
			var result:String = object as String;
			if (result)
			{
				return result;
			}
			
			if (isStringOrClassOnly)
			{
				object = object as Class;
			}
			result = object ? getQualifiedClassName(object).split("::")[1] : null;
			return result;
		}

//		/**
//		 * Created as "object ? getQualifiedClassName(object) : null" is oftenly used in logs, 
//		 * and "ObjectUtil.fullClassName(object)" looks much better.
//		 * 
//		 * @param object
//		 * @return
//		 */
//		public static function fullClassName(object:Object):String
//		{
//			return object ? getQualifiedClassName(object) : null;
//		}
		
		// Process properties
		
		// Use for Dictionary
		public static function deleteByValue(object:Object, valueToDelete:*, isStrict:Boolean = true):void
		{
			for (var key:String in object)
			{
				var valueItem:* = object[key];
				if (valueItem == valueToDelete)
				{
					if (isStrict && valueItem !== valueToDelete)
					{
						continue;
					}

					object[key] = undefined;
					delete object[key];
				}
			}
		}

		public static function copyObject(object:Object):Object
		{
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeObject(object);
			byteArray.position = 0;
			return byteArray.readObject();
		}

		public static function getPropertyNameArray(data:Object):Array
		{
			if (!data)
			{
				return [];
			}

			var result:Array = [];
			for (var propertyName:String in data)
			{
				result[result.length] = propertyName;
			}
			
			return result;
		}

		public static function objectToArray(data:Object):Array
		{
			if (!data)
			{
				return [];
			}

			var result:Array = [];
			for each (var item:Object in data)
			{
				result[result.length] = item;
			}
			
			return result;
		}

		public static function empty(variable:*):Boolean
		{
			if (variable == null)
			{
				return true;
			}
			else if (variable is String)
			{
				return variable == "";
			}
			else if (variable is Array)
			{
				return variable.length == 0;
			}
			else if (variable is Object)
			{
				return JSON.stringify(variable).length == 2;
			}
			return false;
		}

//?		public static function concat(value1:Object, value2:Object):Object
//		{
//			var object:Object = copyObject(value1);
//			for (var propertyName:String in value2)
//			{
//				object[propertyName] = value2[propertyName];
//			}
//			return object
//		}

		// target = {} || new Dictionary();
		public static function pushToPropertyArray(target:Object, propertyName:*, item:*, isUnique:Boolean = false):void
		{
			if (!target)
			{
				return;
			}
			
			if (!target[propertyName])
			{
				target[propertyName] = [];
			}
			
			var array:Array = target[propertyName];
			if (isUnique && array.indexOf(item) != -1)
			{
				return;
			}
			array[array.length] = item;
		}
		
		// target = {} || new Dictionary();
		public static function removeFromPropertyArray(target:Object, propertyName:*, item:*):void
		{
			if (!target)
			{
				return;
			}
			
			if (!target[propertyName])
			{
				return;
			}
			
			var array:Array = target[propertyName];
			var index:int = array.indexOf(item);
			if (index != -1)
			{
				array.splice(index, 1);
			}
		}

		// Use for logs
		public static function stringify(object:Object, maxDebugLength:int = -1):String
		{
			try
			{
				var string:String = JSON.stringify(object);
				if (maxDebugLength > -1)
				{
					string = StringUtil.limitDebugString(string, maxDebugLength);
				}
				return string;
			}
			catch (error:Error)
			{
				Cc.error(LOG, "Error while stringifying json in ObjectUtil.stringify()", error);
			}
			return String(object);
		}

		public static function getValueByKeys(object:Object, ...args):Object
		{
			var objectCopy:Object = copyObject(object);

			for each (var key:String in args)
			{
				if (objectCopy)
				{
					objectCopy = objectCopy[key];
				}
				else
				{
					break;
				}
			}

			return objectCopy;
		}
	}
}