﻿package  
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
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
		/**左对齐*/
		public static const FORMAT_LEFT:int = 0;
		/**中对齐*/
		public static const FORMAT_CENTER:int = 1;
		/**右对齐*/
		public static const FORMAT_RIGHT:int = 2;
		/**加粗*/
		public static const FORMAT_BOLD:int = 3;
		/**斜体*/
		public static const FORMAT_ITALIC:int = 4;
		/**下划线*/
		public static const FORMAT_UNDERLINE:int = 5;
		
		/**用于表示表情的字符的范围开始*/
		private const CODE_BEGIN:Number = 57344;
		/**用于表示表情的字符的范围结束*/
		private const CODE_END:Number = 63743;
		
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
			if (CODE_BEGIN <= d && d <= CODE_END) {
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
					trace("请先使用registerImages方法注册id为" + (d - CODE_BEGIN) + "的图片");
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
			_content.replaceText(i, i, String.fromCharCode(CODE_BEGIN + id));//在光标位置插入占位符
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
		
		/**
		 * 对选中文本设置样式，如果是加粗,斜体和下划线则不在表情应用
		 * @param	format 目标样式
		 */
		public function setTextFormat(format:TextFormat):void
		{
			var b:int = _content.selectionBeginIndex;
			var e:int = _content.selectionEndIndex;
			if (b != e) {
				if (format.bold || format.italic || format.underline) {//粗体,斜体和下划线不对表情应用
					var n:int = b;
					for (var i:int = b; i < e; i++) 
					{
						var c:Number = _content.text.charCodeAt(i);
						if (CODE_BEGIN <= c && c <= CODE_END ) {
							if (n < i) {
								_content.setTextFormat(format, n, i);
							}
							n = i + 1;
						}else if (i == e - 1) {
							_content.setTextFormat(format, n, e);
						}
					}
				}else {
					_content.setTextFormat(format, b, e);
				}
				
				updateImages();
			}
			stage.focus = _content;
		}
		
		/**
		 * 对选择文本设置左中右对齐,加粗,斜体和下划线等六种常用样式
		 * @param	type 使用RichTextField.FORMAT_*枚举
		 */
		public function setNormalFormat(type:int):void
		{
			if (_content.selectionBeginIndex != _content.selectionEndIndex) {
				var format:TextFormat = _content.getTextFormat(_content.selectionBeginIndex, _content.selectionEndIndex);
				switch (type) {
					case FORMAT_LEFT:
						format.align = TextFormatAlign.LEFT;
					break;
					case FORMAT_CENTER:
						format.align = TextFormatAlign.CENTER;
					break;
					case FORMAT_RIGHT:
						format.align = TextFormatAlign.RIGHT;
					break;
					case FORMAT_BOLD:
						if (format.bold) {
							format.bold = false;
						}else {
							format.bold = true;
						}
					break;
					case FORMAT_ITALIC:
						if (format.italic) {
							format.italic = false;
						}else {
							format.italic = true;
						}
					break;
					case FORMAT_UNDERLINE:
						if (format.underline) {
							format.underline = false;
						}else {
							format.underline = true;
						}
					break;
					default:
				}
				
				setTextFormat(format);
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