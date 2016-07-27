/**
 * Created by drummer on 14.06.16.
 */
package game.field
{
    import game.field.taskmanager.TaskManager;
    import game.field.taskmanager.TaskTouchCell;

    import starling.display.DisplayObject;

    import starling.display.Quad;
    import starling.display.Sprite;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;
    import starling.text.TextField;
    
    import ui.com.DisplayComponent;
    
    import utils.MathUtil;
    
    public class GameField extends DisplayComponent
    {
        private static const FIELD_WIDTH:int = 10;//25;
        private static const FIELD_HEIGHT:int = 10;//25;
        
        private var field:Array;
        // layers ----------------------------------------------
        public var itemsLayer:Sprite;
        public var itemsFallLayer:Sprite;
        public var itemsBurstLayer:Sprite;
        // -----------------------------------------------------
        private var _taskManager:TaskManager;
        
        public function GameField()
        {
            textures = ['common'];
            
            _taskManager = new TaskManager(this);
        }

        override protected function onCreate():void
        {
            itemsLayer = new Sprite();
            addChild(itemsLayer);
            itemsFallLayer = new Sprite();
            addChild(itemsFallLayer);
            itemsBurstLayer = new Sprite();
            addChild(itemsBurstLayer);

            initField();
            fillFieldRandom();
        }
        
        private function initField():void
        {
            field = [];
            for (var i:int=0;i<FIELD_WIDTH;i++)
            {
                if (field.length < i + 1)
                {
                    field.push([]);
                }
                for (var j:int=0;j<FIELD_HEIGHT;j++)
                {
                    if (field[i].length < j + 1)
                    {
                        field[i].push([]);
                    }
                    var cell:FieldCell = new FieldCell(this, new FieldCellPosition(i, j));
                    field[i][j] = cell;

                    itemsLayer.addChild(cell);
                    cell.x = FieldCell.SIZE * i;
                    cell.y = FieldCell.SIZE * j;
                }
            }
        }

        private function fillFieldRandom():void
        {
            for (var i:int=0;i<field.length;i++)
            {
                for (var j:int=0;j<field[i].length;j++)
                {
                    var item:FieldItem = new FieldItem(FieldItemType.SIMPLE_TYPES[MathUtil.randomRangeInt(0, FieldItemType.SIMPLE_TYPES.length - 4)]);
                    //var item:FieldItem = new FieldItem(1);
                    item.assetManager = assetManager;
                    item.init();
                    var cell:FieldCell = field[i][j];
                    cell.attachItem(item);
                    cell.addEventListener(TouchEvent.TOUCH, onCellTouch);
                }
            }

            // ------------------------------------------------------------
            /*addItem(4, 0, 0);
            addItem(3, 1, 0);
            addItem(4, 1, 0);

            addItem(5, 0, 0);
            addItem(6, 1, 0);
            addItem(5, 1, 0);
            addItem(6, 2, 0);

            addItem(5, 5, 0);
            addItem(5, 6, 0);
            addItem(6, 5, 0);
            addItem(7, 5, 0);
            addItem(7, 6, 0);

            //field[5][1].removeItem();

            function addItem(x:int, y:int, type:int):void
            {
                var item:FieldItem = new FieldItem(type);
                item.assetManager = assetManager;
                item.init();
                field[x][y].attachItem(item);
            }*/
            // ------------------------------------------------------------
        }

        public function getCellAt(indexX:int, indexY:int):FieldCell
        {
            if (!field[indexX] || !field[indexX][indexY])
            {
                return null;
            }
            return field[indexX][indexY];
        }
        
        private function onCellTouch(event:TouchEvent):void
        {
            var touch:Touch = event.getTouch(event.target as DisplayObject, TouchPhase.ENDED);
            if (touch && event.target is FieldCell)
            {
                var task:TaskTouchCell = new TaskTouchCell(this);
                task.cell = event.target as FieldCell;
                taskManager.addTask(task);
            }
        }

        public function get taskManager():TaskManager
        {
            return _taskManager;
        }

        public function freeze():void
        {
            touchGroup = true;
            touchable = false;
        }

        public function unfreeze():void
        {
            touchGroup = false;
            touchable = true;
        }

        public function get fieldWidth():int
        {
            return FIELD_WIDTH;
        }

        public function get fieldHeight():int
        {
            return FIELD_HEIGHT;
        }

    }
}
