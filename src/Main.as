package
{

import com.junkbyte.console.Cc;

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;

import screens.GameScreen;

import starling.core.Starling;
import starling.events.Event;
import starling.utils.ScaleMode;

import utils.ResourceManager;
import utils.SystemManager;

[SWF(width='900', height='800', backgroundColor='#ffffff', frameRate='60')]
    public class Main extends Sprite
    {
        private var _starling:Starling;
        
        public function Main()
        {
            if (stage)
            {
                initStarling();
            }
            else
            {
                addEventListener(flash.events.Event.ADDED_TO_STAGE, initStarling);
            }
        }

        private function initStarling(event:flash.events.Event = null):void
        {
            _starling = new Starling(StarlingRoot, stage);
            _starling.addEventListener(starling.events.Event.ROOT_CREATED, onStarlingRootCreated);
            _starling.start();
            _starling.showStats = true;
        }

        private function onStarlingRootCreated(event:starling.events.Event):void
        {
            var password:String = "`";
            Cc.startOnStage(stage, password);

            Cc.width = 800;
            Cc.config.commandLineAllowed = true;
            Cc.commandLine = true;
            Cc.config.tracing = true;

            var resourceManager:ResourceManager = new ResourceManager();
            resourceManager.loadRootPathURL = 'http://bubbles.4s2.ru/dev/assets/';
            SystemManager.resourceManager = resourceManager;

            var g:GameScreen = new GameScreen();
            _starling.stage.addChild(g);
            g.init();
        }
    }
}
