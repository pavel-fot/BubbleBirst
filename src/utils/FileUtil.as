package utils
{
import com.adobe.utils.Base64;
import com.junkbyte.console.Cc;

import flash.events.Event;
import flash.utils.ByteArray;
import flash.utils.CompressionAlgorithm;
import flash.utils.Dictionary;

/**
 * FileUtil.
 *
 */
public class FileUtil
{

	// Class constants

	public static const LOG:String = "framework.utils.file";

	public static const APP_STORAGE_URL_PREFIX:String = "app-storage:/";

	// Class variables

	private static var callbackByWriteFileStreamLookup:Dictionary = new Dictionary();
	private static var fileNamesToEncodeArray:Array = [];
	private static var prevSpaceAvailable:Number = 0;

	// Class methods

	public static function uncompressJson(bytes:ByteArray, alg:String = CompressionAlgorithm.LZMA):Object
	{
		try
		{
			bytes.uncompress(alg);
			var data:String = bytes.readUTFBytes(bytes.length);
			return JSON.parse(data);
		}
		catch (e:Error)
		{
			Cc.error(LOG, "uncompressJson " + alg + " " + e.message);
		}

		return null;
	}

	public static function compressString(string:String, alg:String = CompressionAlgorithm.LZMA):ByteArray
	{
		var bytes:ByteArray;
		try
		{
			bytes = new ByteArray();
			bytes.writeUTFBytes(string);
			bytes.compress(alg);
			return bytes;
		}
		catch (e:Error)
		{
			Cc.error(LOG, "compressString " + alg + " " + e.message);
		}

		return null;
	}

	public static function treatAppStorageURL(path:String):String
	{
		if (!path)
		{
			return path;
		}

		var index:int = path.indexOf(APP_STORAGE_URL_PREFIX);
		return index == -1 ? APP_STORAGE_URL_PREFIX + path : path;
	}

	public static function checkExists(filePath:String, fromAppDirectory:Boolean = false):Boolean
	{
		return false;
	}

	public static function checkIfFileIsEncodable(filePath:String, withOutExtension:Boolean = false):Boolean
	{
		if (withOutExtension)
		{
			var extensions:Array = [".json", ".txt"];
			for each (var extension:String in extensions)
			{
				if (checkIfFileIsEncodable(filePath + extension, false))
				{
					return true;
				}
			}
		}
		filePath = filePath.toLowerCase().replace(/\\/g, "/");
		for each (var fileNameToEncode:String in fileNamesToEncodeArray)
		{
			if (filePath.indexOf(fileNameToEncode) != -1)
			{
				return true;
			}
		}
		return false;
	}

	public static function addFileNamesToEncode(...fileNames):void
	{
		for each (var fileName:String in fileNames)
		{
			fileNamesToEncodeArray.push(fileName.toLowerCase().replace(/\\/g, "/"));
		}
	}

	public static function read(filePath:String, isPossiblyEncoded:Boolean = true, fromAppDirectory:Boolean = false):ByteArray//, onComplete:Function = null
	{
		//if (onComplete != null)
		//{
		//	onComplete(byteArray);
		//}
		return null;
	}

	public static function write(filePath:String, byteArray:ByteArray, isAsync:Boolean = true, onComplete:Function = null, isPossiblyEncoded:Boolean = true):Boolean
	{
		if (onComplete != null)
		{
			onComplete(byteArray);
		}

		return false;
	}

	private static function writeFileStream_closeHandler(event:Event):void
	{
	}

	public static function deleteFiles(removeFilePathArray:Array):void
	{
	}

	public static function encodeBase64(byteArray:ByteArray):ByteArray
	{
		var encoded:String = Base64.encode(byteArray);
		byteArray = new ByteArray();
		byteArray.writeUTFBytes(encoded);
		byteArray.position = 0;
		return byteArray;
	}

	public static function decodeBase64(byteArray:ByteArray):ByteArray
	{
		byteArray = Base64.decode(byteArray.readUTFBytes(byteArray.bytesAvailable));
		byteArray.position = 0;
		return byteArray;
	}


	private static function airAlert(message:String, title:String = "error"):void
	{
	}

	private static const LOG_PREFIX:String = "[FileUtil] ";

}
}