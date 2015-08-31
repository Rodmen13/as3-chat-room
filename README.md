#图文混排组件(RichTextField) v1.0
as3版的图文混排组件，支持flash的所有显示对象，支持复制粘贴剪切功能，要求使用flash11及以上版本发布

##如何使用
//实例化宽200，高100，微软雅黑字体，字号14的组件
var rtf:RichTextField = new RichTextField(200, 100, new TextFormat("Microsoft YaHei", 14));
//使用标识100，类型ImageClass来注册图
rtf.registerImage(100, ImageClass);
//在光标位置插入标识为100的图
rtf.insertImage(100);

##API
registerImage //注册图片类型
insertImage //在光标位置插入图片
editable //设置是否可手动编辑
content //获取textField的引用
clear //清除图片和文字
