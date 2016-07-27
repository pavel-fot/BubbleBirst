package utils
{
	/**
	 * StringUtil.
	 * 
	 */
	public class StringUtil
	{
		
		// Class constants
		
		// Class variables
		
		// Class methods

		public static function fitToMinLength(string:String, minLength:int = 30):String
		{
			while (string && string.length < minLength)
			{
				string += " ";
			}
			return string;
		}
		
		//сокращает длинные слова, добавляет "..." (оченьдлинноеслово>оченьдли...)
		public static function limitStringLength(string:String, limitLength:int):String
		{
			if (string.length > limitLength)
			{
				string = string.substr(0, limitLength - 3) + "...";
				// "-3" is for "..."
			}
			return string;
		}
		
		public static function limitDebugString(string:String, maxLength:int):String
		{
			if (!string)
			{
				return string;
			}

			var length:int = string.length;
			if (length > maxLength)
			{
				var countAfter:int = 100;
				var countBefore:int = Math.max(countAfter, maxLength - 100 - countAfter);
				var countSliced:int = length - countBefore - countAfter;
				string = string.substr(0, countBefore) + " ..(" + countSliced + ").. " + string.substr(length - countAfter, countAfter);
			}
			return string;
		}

		/**
		 * StringUtil.substitute("{0}+{1}={2}", 5, 7, 12);// "5+7=12"
		 */
		public static function substitute(string:String, replaces:Array):String
		{
			if (!string || !replaces || !replaces.length)
			{
				return string;
			}
			
			if (replaces[0] is Array)
			{
				replaces = replaces[0];
			}
			// Replace all of the parameters in the msg string.
			
			for (var i:int = 0; i < replaces.length; i++)
			{
				string = string.replace(new RegExp("\\{" + i + "\\}", "g"), replaces[i]);
			}

			return string;
		}

		public static function substituteCustom(string:String, replacesLookup:Object):String
		{
			if (!string || !replacesLookup || string.indexOf("{") == -1)
			{
				return string;
			}

			// Replace all of the parameters in the msg string.
			for (var key:String in replacesLookup)
			{
				while (string.indexOf("{" + key + "}") != -1)
				{
					string = string.replace("{" + key + "}", replacesLookup[key]);
				}
			}

			return string;
		}

	}
}