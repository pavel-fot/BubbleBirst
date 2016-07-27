/**
 * Created by drummer on 14.06.16.
 */
package game.field
{
    import flash.geom.Point;

    import game.field.GameField;

    import starling.animation.Tween;
    import starling.core.Starling;
import starling.display.Image;

import starling.display.Quad;
    import starling.display.Sprite;
    import starling.text.TextField;
    import starling.text.TextFieldAutoSize;

    import ui.com.DisplayComponent;

    public class FieldCell extends DisplayComponent
    {
        public static const SIZE:int = 22;

        public var willFill:Boolean;

        private var _position:FieldCellPosition;
        private var _item:FieldItem;
        private var gameField:GameField;

        public function FieldCell(gameField:GameField, position:FieldCellPosition)
        {
            this.gameField = gameField;
            _position = position;

            touchGroup = true;
        }

        public function get position():FieldCellPosition
        {
            return _position;
        }

        public function attachItem(item:FieldItem):void
        {
            if (_item && _item.parent == this)
            {
                _item.removeFromParent(true);
            }
            _item = item;
            addChild(item);
            item.alignPivot();
            item.width = SIZE - 4;
            item.scaleY = item.scaleX;
            item.x = SIZE / 2;
            item.y = SIZE / 2;
        }

        public function detachItem():void
        {
            if (item.parent == this)
            {
                item.removeFromParent();
            }
            _item = null;
        }

        public function removeItem(animationCallback:Function = null):void
        {
            if (item.parent != this)
            {
                if (animationCallback != null)
                {
                    animationCallback();
                }
                return;
            }
            var itemToRemove:FieldItem = item;
            _item = null;
            var p:Point = gameField.itemsBurstLayer.globalToLocal(localToGlobal(new Point(itemToRemove.x, itemToRemove.y)));
            gameField.itemsBurstLayer.addChild(itemToRemove);
            itemToRemove.x = p.x;
            itemToRemove.y = p.y;
            
            var tween:Tween = new Tween(itemToRemove, 0.2);
            tween.scaleTo(0.6);
            tween.fadeTo(0);
            tween.onComplete = onTweenComplete;
            Starling.juggler.add(tween);

            function onTweenComplete():void
            {
                Starling.juggler.remove(tween);
                if (itemToRemove)
                {
                    itemToRemove.removeFromParent(true);
                    itemToRemove = null;
                    if (animationCallback != null)
                    {
                        animationCallback();
                    }
                }
            }
        }

        public function get item():FieldItem
        {
            return _item;
        }

        public function get canContainItem():Boolean
        {
            return true;
        }

        public function get canFall():Boolean
        {
            return true;
        }

    }
}
