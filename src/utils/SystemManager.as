/**
 * Created by drummer on 14.06.16.
 */
package utils
{
import com.junkbyte.console.Cc;

public class SystemManager
    {
        private static var _resourceManager:ResourceManager;

        public function SystemManager()
        {
        }

        public static function set resourceManager(value:ResourceManager):void
        {
            if (_resourceManager)
            {
                Cc.error('resourceManager already set');
                return;
            }
            _resourceManager = value;
        }

        public static function get resourceManager():ResourceManager
        {
            return _resourceManager;
        }
    }
}
