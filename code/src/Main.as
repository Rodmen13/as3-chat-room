package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	[SWF(width=210, height=160, frameRate=24)]
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
		
		private var rtf:RichTextField = new RichTextField(200, 90);
		private var formatButtons:FormatButtons = new FormatButtons();
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			var emojis:Array = [QQEmoji1, QQEmoji2, QQEmoji3, QQEmoji4, QQEmoji5];
			
			//rt.editable = false;
			rtf.x = rtf.y = 5;
			for (var i:int = 0; i < 5; i++) {
				rtf.registerImage(i, emojis[i]);
			}
			addChild(rtf);
			
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
			
			formatButtons.addEventListener(MouseEvent.CLICK, onFormatClick);
			formatButtons.x = 20;
			formatButtons.y = 132;
			addChild(formatButtons);
		}
		
		private function onFormatClick(e:MouseEvent):void 
		{
			switch (e.target) 
			{
				case formatButtons.left:
					rtf.setNormalFormat(RichTextField.FORMAT_LEFT);
				break;
				case formatButtons.center:
					rtf.setNormalFormat(RichTextField.FORMAT_CENTER);
				break;
				case formatButtons.right:
					rtf.setNormalFormat(RichTextField.FORMAT_RIGHT);
				break;
				case formatButtons.bold:
					rtf.setNormalFormat(RichTextField.FORMAT_BOLD);
				break;
				case formatButtons.italic:
					rtf.setNormalFormat(RichTextField.FORMAT_ITALIC);
				break;
				case formatButtons.underline:
					rtf.setNormalFormat(RichTextField.FORMAT_UNDERLINE);
				break;
				default:
			}
		}
		
		private function onClick(e:MouseEvent):void 
		{
			rtf.clear();
		}
		
		private function insertEmoji(e:MouseEvent):void
		{
			rtf.insertImage(int(e.target.name));
		}
	}
	
}