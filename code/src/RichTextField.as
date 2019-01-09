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
	 * 圖文混牌組件,支持複製、貼上、剪下
	 * 注意：請使用flash11及以上版本編譯
	 * Unicode編碼在57344到63743這段範圍內的字符表現為空白字元
	 * 這裡使用這些字符做占位符並記錄表情信息
	 * @author WLDragon 2015-08-30
	 */
	public class RichTextField extends Sprite 
	{
		/**左對齊*/
		public static const FORMAT_LEFT:String = "left";
		/**中隊齊*/
		public static const FORMAT_CENTER:String = "center";
		/**右對齊*/
		public static const FORMAT_RIGHT:String = "right";
		/**加粗*/
		public static const FORMAT_BOLD:String = "bold";
		/**斜體*/
		public static const FORMAT_ITALIC:String = "italic";
		/**底線*/
		public static const FORMAT_UNDERLINE:String = "underline";
		
		/**用於表示表情的字符的範圍開始*/
		private const CODE_BEGIN:Number = 57344;
		/**用於表示表情的字符的範圍結束*/
		private const CODE_END:Number = 63743;
		
		/**主文本*/
		private var _content:TextField = new TextField();
		/**默認樣式*/
		private var defaultFormat:TextFormat;
		/**圖片類定義集*/
		private var imageClasses:Array = [];
		/**圖片容器*/
		private var imageContainer:Sprite = new Sprite();
		/**測量占位符用的文本*/
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
		 * 註冊圖片類型
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
			//trace(this, "onChange::::","text:::::::::::::::", content.text);
		}
		
		private function updateImages():void
		{			
			while (imageContainer.numChildren > 0) imageContainer.removeChildAt(0);
			
			var start:int = _content.getLineOffset(_content.scrollV - 1);
			var end:int = _content.getLineOffset(_content.bottomScrollV - 1) + _content.getLineLength(_content.bottomScrollV - 1);
			for (var i:int = start; i < end; i++) {
				createImage(i);
			}
			
			var repString:String = "";
			var arrPatern:Array = _content.text.match(/\/:[0-9]+/);
			var charCode:int = 0;
			if (arrPatern)
			{
				for (var j:int = 0; j < arrPatern.length; j++)
				{
					repString = arrPatern[j];
					repString = repString.substring(2, repString.length);
					//trace("repString::::::::::", repString);
					charCode = CODE_BEGIN + int(repString);
					trace("repString::::::::::",charCode );
					repString = String.fromCharCode(charCode);
					//trace("repString:::charcode:::", repString);
					_content.text = _content.text.replace(/\/:[0-9]+/, repString);
				}
				updateImages();
				
			}
			
		}
		
		private function createImage(index:int):void
		{
			var d:Number = _content.text.charCodeAt(index);
			if (CODE_BEGIN <= d && d <= CODE_END) 
			{
				var c:Class = imageClasses[d - CODE_BEGIN] as Class;
				if (c != null) {					
					var dis:DisplayObject = new c() as DisplayObject;
					//设置字符大小，使用simsun字体各浏览器兼容性好，Arial字体可能出现"□"字符的情况，而且字符宽度不一致
					var tf:TextFormat = new TextFormat("simsun", dis.height + 2, null, false, false, false);
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
					trace("請先使用registerImages方法註冊id為" + (d - CODE_BEGIN) + "的圖片");
				}
			}else{
				_content.setTextFormat(defaultFormat, index, index + 1);
			}
		}
		
		/**
		 * 插入圖片（flash的一切可顯示對象），需要先使用registerImages註冊對象類型
		 * @param	id
		 */
		public function insertImage(id:int):void
		{
			var i:int = _content.caretIndex;//圖片插入的位置
			_content.replaceText(i, i, String.fromCharCode(CODE_BEGIN + id));//在游標位置插入佔位符
			updateImages();
			stage.focus = _content;//恢复文字框的焦點，讓游標在文字框跳動
			//用於添加圖片後输入文字時恢復默認字樣
			if(!_content.hasEventListener(TextEvent.TEXT_INPUT)) _content.addEventListener(TextEvent.TEXT_INPUT, onInput);
		}
		
		private function onInput(e:TextEvent):void 
		{
			trace(this, "onInput:::::::::::::");
			_content.removeEventListener(TextEvent.TEXT_INPUT, onInput);
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
		
		/**
		 * 对选中文本设置样式，如果没有设定beginIndex和endIndex则使用选择的文本
		 * @param	format 目标样式
		 * @param	beginIndex 开始的位置
		 * @param	endIndex 结束的位置
		 */
		public function setTextFormat(format:TextFormat, beginIndex:int = -1, endIndex:int = -1):void
		{
			var b:int = beginIndex == -1 ? _content.selectionBeginIndex : beginIndex;
			var e:int = endIndex == -1 ? _content.selectionEndIndex : endIndex;
			if (b != e) {
				var n:int = b;
				for (var i:int = b; i < e; i++) {
					var c:Number = _content.text.charCodeAt(i);
					if (CODE_BEGIN <= c && c <= CODE_END ) {
						if (n < i) _content.setTextFormat(format, n, i);
						n = i + 1;
						//除了对齐,其他样式都不应用到图片上
						if (format.align != null) _content.setTextFormat(new TextFormat(null, null, null, null, null, null, null, null, format.align), i, i + 1);
					}else if (i == e - 1) {
						_content.setTextFormat(format, n, e);
					}
				}
				updateImages();
			}
			stage.focus = _content;
		}
		
		/**
		 * 对选择文本设置左中右对齐,加粗,斜体和下划线等六种常用样式
		 * @param	type 使用RichTextField.FORMAT_*枚举
		 */
		public function setNormalFormat(type:String):void
		{
			switch (type) {
				case FORMAT_LEFT:
				case FORMAT_CENTER:
				case FORMAT_RIGHT:
					setAlignFormat(type);
				break;
				case FORMAT_BOLD:
				case FORMAT_ITALIC:
				case FORMAT_UNDERLINE:
					setNoAlignFormat(type);
				break;
				default:
			}
		}
		
		private function setAlignFormat(type:String):void
		{
			if (_content.text.length > 0) {
				var b:int = _content.selectionBeginIndex;
				var e:int = _content.selectionEndIndex;
				if (b == _content.length) b = b - 1;  //防止光标在文本末端时出现超出索引范围
				if (e == _content.length) e = e - 1;
				var bl:int = _content.getLineIndexOfChar(b);
				var el:int = _content.getLineIndexOfChar(e);
				//设置对齐格式的字符范围为从被选择的行的头一行的头一个字符到最后一行的最后一个字符
				b = _content.getLineOffset(bl);
				e = _content.getLineOffset(el) + _content.getLineLength(el);
				var format:TextFormat = _content.getTextFormat(b, e);
				format.align = type;
				setTextFormat(format, b, e);
			}else {
				stage.focus = _content;
			}
		}
		
		private function setNoAlignFormat(type:String):void
		{
			if (_content.selectionBeginIndex != _content.selectionEndIndex) {
				var format:TextFormat = _content.getTextFormat(_content.selectionBeginIndex, _content.selectionEndIndex);
				if (format[type] == true) format[type] = false;
				else format[type] = true;
				setTextFormat(format);
			}else {
				stage.focus = _content;
			}
		}

		public function clear():void
		{
			while (imageContainer.numChildren > 0) imageContainer.removeChildAt(0);//清除图片
			_content.text = "";
			stage.focus = _content;
		}
	}
}