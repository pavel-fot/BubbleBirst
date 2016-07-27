/**
 * Created by drummer on 27.07.16.
 */
package utils
{
	import starling.text.TextField;
	import starling.text.TextFormat;

	public class TextFieldFactory
	{
		public static const SKRANJI_BOLD:String = 'SkranjiBold';

		[Embed(source="../../fonts/Skranji-Bold.ttf", fontName = "SkranjiBold", mimeType = "application/x-font", advancedAntiAliasing="true", embedAsCFF="false")]
		private var myEmbeddedFont:Class;

		public function TextFieldFactory()
		{
		}

		public static function create(fontName:String = 'Verdana', text:String = '', size:int = 14, color:uint = 0x0, autoSize:String = 'bothDirections',
										horizontalAlign:String = 'center', verticalAlign:String = 'center'):TextField
		{
			var tf = new TextField(100, 100);
			tf.autoSize = autoSize;
			tf.text = text;
			var tFormat:TextFormat = new TextFormat(fontName, size, color, horizontalAlign, verticalAlign);
			tf.format = tFormat;
			tf.touchable = false;
			return tf;
		}

	}
}
