### 1. 系统快捷键
#### 1. 编辑常用命令
~~~
。     重复上次修改
；     重复上次查找
cw    在光标的处开始，到位删除，重新输入
ea    在该word后修改

dt;    删除；字符前的word
ve    从此处选择到词尾

`.    跳到上次修改点 


ma    创建 局部 位置标记a, 跳回`a
mA    创建 全局 位置标记(文件件跳转),跳回`A


CTRL+N      自动扩展字符串

*:  自动查找鼠标位置当前的字符串
gf:   (go to file)显示光标处的文件
gd:   高亮
~~~~

#### 2. 运行命令
~~~

:e ctrl+d 查看当前目录下的文件
:Ve  打开当前文件的目录
:explore  打开当前目录文件

:b1（bn）返回前一次的显示
:r !命令  //在 vim 中执行系统命令，并把命令结果导入光标所在行
:r 文件名 把文件内容导入到光标位置

:ctrl + d  查看可选命令
ctrl+p/ ctrl+n  字符自动补齐( 强烈推荐)
~~~

#### 3. 其他
1： 1 ctlr+g: 显示当前文件绝对路径

#### 3. 个人配置
~~~
 :map ui i `uvm_info("TRACE", $sformatf("",), UVM_LOW)
 :map ue i `uvm_error(get_full_name(), $sformatf("",))
 :map uf i `uvm_fatal(get_full_name(), $sformatf("",))
 :map cc :s/^/\/\//    //cc ---> 注释当前行；nc：取消当前行的注释
 :map nc :s/^\/\///   
 :map sx :x!     // 保存后退出



 map 中ctr的表达, Ctrl+P ---> “^P”为定义快捷键Ctrl+P
~~~
