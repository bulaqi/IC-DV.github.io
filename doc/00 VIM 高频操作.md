 系统快捷键
CTRL+N      自动扩展字符串  
*:  自动查找鼠标位置当前的字符串
gf:   (go to file)显示光标处的文件
:b1（bn）返回前一次的显示
:r !命令  //在 vim 中执行系统命令，并把命令结果导入光标所在行
:r 文件名 把文件内容导入到光标位置
:e ctrl+d 查看当前目录下的文件
:explore  打开当前目录文件
:ctrl + d  查看可选命令

 个人配置
 :map ui i `uvm_info("TRACE", $sformatf("",), UVM_LOW)
 :map ue i `uvm_error(get_full_name(), $sformatf("",))
 :map uf i `uvm_fatal(get_full_name(), $sformatf("",))
 :map cc :s/^/\/\//    //cc ---> 注释当前行；nc：取消当前行的注释
 :map nc :s/^\/\///   
 :map sx :x!     // 保存后退出



 map 中ctr的表达, Ctrl+P ---> “^P”为定义快捷键Ctrl+P
