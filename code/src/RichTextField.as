package  
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	/**
	 * 图文混排组件,支持复制、粘贴、剪切
	 * 注：请使用flash11及以上版本编译
	 * Unicode编码在57344到63743这段范围内的字符表现形式为空白字符
	 * 这里使用这些字符做占位符并记录表情信息
	 * @author WLDragon 2015-08-30
	 */
	public class RichTextField extends Sprite 
	{
		/**文本*/
		private var _content:TextField = new TextField();
		/**默认样式*/
		private var defaultFormat:TextFormat;
		/**图片类定义集*/
		private var imageClasses:Array = [];
		/**图片容器*/
		private var imageContainer:Sprite = new Sprite();
		/**测量占位符用的文本*/
		private var placeHolder:TextField = new TextField();
		/**是否可编辑*/
		private var _editable:Boolean = true;
		
		public function RichTextField(textWidth:Number, textHeight:Number, format:TextFormat = null) 
		{
			if (format == null) {
				defaultFormat = new TextFormat("Microsoft YaHei", 14, 0x0);
				defaultFormat.letterSpacing = 0;	
			}else{
				if (format.letterSpacing == null) format.letterSpacing = 0;
				defaultFormat = format;
			}
			
			addChild(_content);
			_content.border = true;//设置边框
			_content.borderColor = 0x0;
			_content.wordWrap = true;
			_content.multiline = true;
			_content.width = textWidth;
			_content.height = textHeight;
			_content.type = TextFieldType.INPUT;
			_content.defaultTextFormat = defaultFormat;
			_content.addEventListener(Event.CHANGE, onChange);
			_content.addEventListener(Event.SCROLL, onScroll);
			
			//限制显示范围，防止粘贴内容过多时会出现超出文本框的问题
			imageContainer.scrollRect = new Rectangle(1, 1, textWidth - 2, textHeight - 2);
			imageContainer.mouseChildren = false;
			imageContainer.mouseEnabled = false;
			addChild(imageContainer);
		}
		
		private function onScroll(e:Event):void 
		{
			updateImages();
		}
		
		/**
		 * 注册图片类型
		 * @param	id
		 * @param	imageClass
		 */
		public function registerImage(id:int, imageClass:Class):void
		{
			imageClasses[id] = imageClass;
		}

		private function onChange(e:Event):void 
		{
			updateImages();
		}
		
		private function updateImages():void
		{			
			while (imageContainer.numChildren > 0) imageContainer.removeChildAt(0);
			
			var start:int = _content.getLineOffset(_content.scrollV - 1);
			var end:int = _content.getLineOffset(_content.bottomScrollV - 1) + _content.getLineLength(_content.bottomScrollV - 1);
			for (var i:int = start; i < end; i++) {
				createImage(i);
			}
		}
		
		private function createImage(index:int):void
		{
			var d:Number = _content.text.charCodeAt(index);
			if (57344 <= d && d <= 63743) {
				var c:Class = imageClasses[d - 57344] as Class;
				if (c != null) {					
					var dis:DisplayObject = new c() as DisplayObject;
					//设置字符大小，使用simsun字体各浏览器兼容性好，Arial字体可能出现"□"字符的情况，而且字符宽度不一致
					var tf:TextFormat = new TextFormat("simsun", dis.height + 2);
					placeHolder.text = String.fromCharCode(d);
					placeHolder.setTextFormat(tf);
					var m:TextLineMetrics = placeHolder.getLineMetrics(0);
					tf.letterSpacing = dis.width - m.width + 2;
					_content.setTextFormat(tf, index, index + 1);	
					var rect:Rectangle = _content.getCharBoundaries(index);
					if (rect != null) {
						//设置图片位置并添加到显示列表
						dis.x = rect.x + (rect.width - dis.width) * .5;
						dis.y = rect.y + (rect.height - dis.height) * .5;
						imageContainer.addChild(dis);
					}
				}
				else {
					trace("请先使用registerImages方法注册id为" + (d - 57344) + "的图片");
				}
			}
		}
		
		/**
		 * 插入图片（flash的一切可显示对象），需要先使用registerImages注册对象类型
		 * @param	id
		 */
		public function insertImage(id:int):void
		{
			var i:int = _content.caretIndex;//图片插入的位置
			_content.replaceText(i, i, String.fromCharCode(57344 + id));//在光标位置插入占位符
			updateImages();
			stage.focus = _content;//恢复文本框的焦点，让光标在文本框跳动
			//用于添加图片后输入文字时恢复默认样式
			if(!_content.hasEventListener(TextEvent.TEXT_INPUT)) _content.addEventListener(TextEvent.TEXT_INPUT, onInput);
		}
		
		private function onInput(e:TextEvent):void 
		{
			removeEventListener(TextEvent.TEXT_INPUT, onInput);
			_content.defaultTextFormat = defaultFormat;
		}
		
		/**
		 * 是否可编辑
		 */
		public function get editable():Boolean 
		{
			return _editable;
		}
		
		public function set editable(value:Boolean):void 
		{
			if (value) {
				_content.type = TextFieldType.INPUT;
			}
			else {
				_content.type = TextFieldType.DYNAMIC;
			}
			
			_editable = value;
		}
		
		/**
		 * 获取TextField对象
		 */
		public function get content():TextField 
		{
			return _content;
		}
		
		public function clear():void
		{
			while (imageContainer.numChildren > 0) imageContainer.removeChildAt(0);//清除图片
			_content.text = "";
			stage.focus = _content;
		}
		
	}

}