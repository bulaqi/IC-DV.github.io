### 1. 基础知识
#### 1. 基础操作
##### 1. 快捷鍵re-map.快速生成`uvm_info()的代碼：
- 在.vimrc中，添加如下定義：
~~~
 :map ui i `uvm_info("TRACE", $sformatf("",), UVM_LOW)
 :map ue i `uvm_error(get_full_name(), $sformatf("",))
 :map uf i `uvm_fatal(get_full_name(), $sformatf("",))
~~~


##### 2. 像Windows操作一樣使用gvim，例如製作Ctrl+A（全選）這樣的操作
~~~
:map cc :s/^/\/\//    //cc ---> 注釋當前行；  nc：取消當前行的注釋
:map nc :s/^\/\///   
:map sx :x!
map ggVGY 製作Ctrl+A（全選）這樣的操
~~~

##### 3. 按鍵綁定：
~~~
復合命令： A，    等效命令：  $a,   功能是在行尾插入。
~~~

##### 4. 好用的快捷鍵：

      guu：轉換為小寫，gUU：轉換為大寫，g~：反轉大小寫。

  4、矩形操作（也叫可視模式）    

        ：激活面向行的可視模式    

     ：激活面向列的可視模式

      gv：重選上次的高亮區域

##### 5. VIM中自定義字體

     在.vimrc文件中添加如下語句： set  guifont = Monospace\ 12

     可以根據自己的喜好定義不同的字體。
##### 6.光标自动移动到匹配的括号内 
~~~
imap () ()<Left>
 
imap [] []<Left>
 
imap {} {}<Left>
 
imap "" ""<Left>
 
imap " "<Left>
~~~

##### 7.自動折行：

      set wrap

      set textwidth=120

      set formatoptions+=mM

      在.vimrc中加入上述設定后，選中已經存在的未斷行的對象，按快捷鍵：gq即可實現120字符斷行（折行）。

##### 2. 在GVIM中自定義function
實現給文件插入固定的表頭的功能，加入下面的代碼，按快捷鍵F2就會給文件插入下面的Lines：
~~~
command Ahead : call Addheader()
 
function Addheader()
  call append(0, "//")
  call append(1, "//                          Design Information                      //")
  call append(2, "//")
  call append(3, "//Organization : Company,Division")
  call append(4, "//Project: ")
  call append(5, "//Copyright 2017 (c)")
  call append(6, "//")
  call append(9, "/// Main Procedures:")
  call append(12, "/// @file")
  call append(13, "/// @par $Id: $")
  call append(14, "/// @par $Author: $")
  call append(15, "/// @par $Change: $")
  call append(16, "/// @par $DateTime: $")
  call append(17, "//")
  call append(18, "")
endfunction
 
map <F2> : call Addheader() <CR>:13<CR>o
~~~     


#### 3. 工作中常用的vim技巧

CTRL+N      自动扩展字符串  

*:  自动查找鼠标位置当前的字符串

gf:   (go to file)显示光标处的文件

:b1（bn）返回前一次的显示

统计单词数：  :%s/word/&/g    其实就是原词替换原词会做成功统计

可以定义快捷键简化，格式为：

:map 快捷键 执行命令

如定义快捷键Ctrl+P为在当前行行首添加“#”注释，可以执行：

:map ^P I//

“^P”为定义快捷键Ctrl+P， “I//”就是此快捷键要触发的动作，“I”为在光标所在行行首插入，“//”为要输入的字符，“”表示退回命令模式，“”要逐个字符键入，不可直接按键盘的“Esc”键。执行成功后，直接在任意需要注释的行上按“Ctrl+P”就自动会在行首加上“//”号了非常方便。

如果要取消此快捷键，只需输入命令：

:unmap ^P

:map i{ea}
在这个命令中:map是vi中的命令，而F5则是说将下面的命令与F5键绑定，后面的则是具体的命令内容，i{是说插入字符{，然后退回到命令状态。
e是移到单词的结尾处，a}则是增加字符}然后退至命令状态。
在我们做过这样的工作以后我们就可以来执行我们的命令了，我们将光标定位在一个单词上，例如amount，按下F5键，我们就会发现这时就变成了{amo
unt}的形式。

命令“ab”

:ab 替代符 原始信息

示例如下：:ab sammail sam_helen@vip.163.com

执行之后，在输入模式任何地方录入“sammail”，再敲任意字母符号或者回车空格，咔嚓一下，利马就变成“sam_helen@vip.163.com”，那真是相当的方便啊！

:! command

任何命令的结果导入到当前编辑文件中，格式为：

:r !命令

配置文件.vimrc
前面提到的快捷键、ab命令等的应用，设置后只在当前编辑文件中有效，如果想让它永久生效需要编辑用户宿主目录下的.vimrc文件，如你是root用户，则编辑/root/.vimrc（此文件默认不存在）。
写入你常用的设置命令即可，如：

:set nu

:map ^M isam_helen@vip.163.com

:ab sammail limingkillyou@163.com

以后就永久生效了。


### 2. 经验
### 3. 传送门
1. [.vimrc 详细配置(强力推荐)](https://xueying.blog.csdn.net/article/details/99691936?spm=1001.2014.3001.5502)
2. [GVIM使用技巧总结(强力推荐)](https://xueying.blog.csdn.net/article/details/88410151?spm=1001.2014.3001.5502)
