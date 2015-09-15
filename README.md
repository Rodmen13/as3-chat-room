#图文混排组件(RichTextField) v1.0
as3版的图文混排组件，支持flash的所有显示对象，支持复制粘贴剪切功能，要求使用flash11及以上版本发布

##如何使用

var rtf:RichTextField = new RichTextField(200, 100, new TextFormat("Microsoft YaHei", 14));

rtf.registerImage(100, ImageClass);

rtf.insertImage(100);

##API
1.registerImage //注册图片类型

2.insertImage //在光标位置插入图片

3.editable //设置是否可手动编辑

4.content //获取textField的引用

5.clear //清除图片和文字

6.setTextFormat //在指定范围内设置文本样式，如果不指定则对选择的内容进行设置

7.setNormalFormat //对选择的行应用常用的对齐、加粗、斜体和下划线样式
