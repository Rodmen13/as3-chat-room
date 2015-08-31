package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	[SWF(width=210, height=130, frameRate=24)]
	/**
	 * ...
	 * @author WLDragon
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private var rt:RichTextField;
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			var emojis:Array = [QQEmoji1, QQEmoji2, QQEmoji3, QQEmoji4, QQEmoji5];
			
			rt = new RichTextField(200, 90);
			//rt.editable = false;
			rt.x = rt.y = 5;
			for (var i:int = 0; i < 5; i++) {
				rt.registerImage(i, emojis[i]);
			}
			addChild(rt);
			
			var clearButton:TextField = new TextField();
			clearButton.text = "clear";
			clearButton.autoSize = TextFieldAutoSize.LEFT;
			clearButton.border = true;
			clearButton.borderColor = 0x0;
			clearButton.addEventListener(MouseEvent.CLICK, onClick);
			clearButton.x = 170;
			clearButton.y = 102;
			clearButton.selectable = false;
			addChild(clearButton);
			
			for (i = 0; i < 5; i++) {
				var mc:MovieClip = new emojis[i]() as MovieClip;
				mc.addEventListener(MouseEvent.CLICK, insertEmoji);
				mc.name = i.toString();
				mc.buttonMode = true;
				mc.x = 10 + i * 30;
				mc.y = 100;
				addChild(mc);
			}
		}
		
		private function onClick(e:MouseEvent):void 
		{
			rt.clear();
		}
		
		private function insertEmoji(e:MouseEvent):void
		{
			rt.insertImage(int(e.target.name));
		}
	}
	
}