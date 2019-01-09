#圖文混合組件(RichTextField) v1.0
as3版的圖文混合組件，支持flash的所有顯示物件，支持複製貼上剪下功能，要求使用flash11及以上版本發布

##如何使用

var rtf:RichTextField = new RichTextField(200, 100, new TextFormat("Microsoft YaHei", 14));

rtf.registerImage(100, ImageClass);

rtf.insertImage(100);

##API
1.registerImage //註冊圖片類型

2.insertImage //在光標位置插入图片

3.editable //設置是否可手動編輯

4.content //取得textField的參考

5.clear //清除圖片和文字

6.setTextFormat //在指定範圍内設置文字格式，如果不指定範圍則對選擇的內容進行設置

7.setNormalFormat //對選擇的行套用常用的對齊、加粗、斜體和加底線樣式
