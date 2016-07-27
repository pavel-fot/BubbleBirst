package utils
{
	import flash.geom.Point;

	import starling.utils.deg2rad;

	/**
	 * MathUtil.
	 * 
	 */
	public class MathUtil
	{
		
		// Class constants
		
		// Class variables
		
		// Class methods

		/**
		 * Quadratic Bézier curves
		 * http://en.wikipedia.org/wiki/Bezier_curve
		 * @param	p0
		 * @param	p1
		 * @param	p2
		 * @param	step
		 * @return
		 */
		[Inline]
		public static function getBezierQuadraticPoints(x0:Number, y0:Number, x1:Number, y1:Number, x2:Number, y2:Number, step:Number = 1 / 100):Vector.<Point>
		{
			var vec:Vector.<Point> = new Vector.<Point>();
			var _x:Number, _y:Number;

			for (var t:Number = 0; t <= 1; t += step)
			{
				_x = ((1 - t)*(1 - t)) * x0 + 2 * t * (1 - t) * x1 + (t*t) * x2;
				_y = ((1 - t)*(1 - t)) * y0 + 2 * t * (1 - t) * y1 + (t*t) * y2;
				vec.push(new Point(_x, _y));
			}

			return vec;
		}

		[Inline]
		public static function square(value:Number):Number
		{
			return value * value;
		}

		/**
		 * Случайное дробное число в диапозоне
		 * @param minNum минимальное значение
		 * @param maxNum максимальное значение
		 * @return Случайное дробное число в диапозоне
		 */
		[Inline]
		public static function randomRangeNumber(min:Number, max:Number):Number
		{
			return (min + Math.random() * (max - min));
		}

		/**
		 * Случайное целое число в диапозоне
		 * @param minNum минимальное значение
		 * @param maxNum максимальное значение
		 * @return Случайное целое число в диапозоне
		 */
		[Inline]
		public static function randomRangeInt(minNum:Number, maxNum:Number):Number
		{
			return (minNum + Math.floor(Math.random() * (maxNum - minNum + 1)));
		}
		
		/**
		 * Возвращает случайный индекс, без повторов
		 * @param	oldIndex - предидущий индекс
		 * @param	length - длина для рандома
		 * @return
		 */
		public static function getNextRandomIndex(oldIndex:int,length:int):int
		{
			return (oldIndex + 1 + int(Math.random() * (length - 1) )) % length;
		}
		/**
		 * Вернёт угол между двумя точками (по дефолту в градусах)
		 * @param sourcePt - исходная точка
		 * @param targetPt - конечная точка
		 * @param inRad - в градусах или радианах
		 * @return
		 */
		[Inline]
		public static function getAngleBetweenPoints(sourcePt:Point, targetPt:Point, inRad:Boolean = false):Number
		{
			var angle:Number = Math.atan2(targetPt.y - sourcePt.y, targetPt.x - sourcePt.x);

			if (inRad)
			{
				angle = deg2rad(angle);
			}

			return angle;
		}
	}
}