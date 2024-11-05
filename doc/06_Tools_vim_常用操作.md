### 常用操作
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/c81778c4-d6e3-4f08-ae6d-6ba8c857558b)

#### 0. Terminal和vim 交互
1. 设置
vim ~/.vimrc，然后在.vimrc文件中输入一行set clipboard=unnamedplus这句话的意思是让vim的剪贴板与外部剪贴板连接
2. 使用
 1. Terminal->vim : 双击选中,vim中 鼠标中间
 2.  vim ->Terminal: y 后,terminal shift+insert,或者选中,中间复制

#### 1. 分屏跳转,ctrl+w+s ,ctrl +w+v
#### 2. 当前窗口最大化: ctrl w |(shift |)  
- 等宽,登高  c_w =
- 最大高度, c_w _
- 最大化, c_w  |
- [N] <c_w>_ 活动窗口设置为N行
- [N] <c_w>_ 活动窗口设置为N列
~~~
1. gvim一般是非同时操作,使用前先按下"Ctrl + w",
2. | 需要用shift + | 实现。
~~~
#### 3. 分屏打开当前目录 :vsp %:p:h  
% 符号代表活动缓冲区的完整文件路径（参见 :h cmdlinespecial ） ， 按 <Tab> 键会将其展开， 使之显示为活动缓冲区的完整
文件路径。 :h修饰符会去除文件名， 但保留路径中的其他部分



###  1. gvim基础
#### 1. 移动、标记、跳转
 1. 字符间跳转：h, j, k, l
 2. 单词间跳转：w e b
 3. 行首行尾跳转,  ^ 0 $
4. 行间移动：#G  1G, gg:

5. 句间移动：)	(
6. 段落间移动：	}	{
7. 标记：m，mark, 
~~~
	ma  将当前行标记为a； `a 跳转到a标记行
	delmark a  删除标记a
~~~
8. 查找: n,N
9. 折叠：marker方式（set foldmethod=marker）
~~~
	zf56G当前行到56行的折叠
	10zf当前行到后十行
	10zf-当前行到前十行
	z0、zd、zD打开折叠
~~~

#### 2.  查找,	？	/	global

#### 3. 基础编辑指令
0. 删除
~~~
shift + ~：将光标所在位置的字母进行大小写转换；
r：替换光标所在的一个字符；
n + r：替换光标所在的n个字符替换；
x：行内删除，向后删除，支持nx，支持p；
X：行内删除，向前删除，支持nX，支持p；
cw：删除当前光标所在单词，并进入插入模式。
~~~
0. 数字增加
~~~
ctrl+ a /ctrl+x
~~~
1. 删除：	x ,d ,dd,D
~~~
	x: 删除光标处的字符；
	xp: 交换光标所在处的字符及其后面字符的位置；
	
	d: 删除命令						
	dd 删除当前行 				
	D删除光标到行尾的字符
~~~
2. 改变: c cc  r R
~~~
	改变命令(c, change)	
	c: 修改      编辑模式输入模式
	cc：删除当行并输入新内容
	
	r：替换光标所在处的字符
	R：逐字符替换
~~~
3. 撤销u ,ctrl+r
~~~
	u 撤销
	ctrl+r撤销此前的撤销
 ~~~
4. 重复:    .  重复之前操作
5.   diff比对操作

6. 数字配合：
~~~
均可结合w、e、b、数字等使用，如：
dw 删除当前单词；
3dw删除当前往后3个单词
3dd删除当前往后3行；
~~~

#### 4. 批量编辑命令
1. 列模式, Ctrl+v, shift+i（左侧插入）或shift+a（右侧插入）或delete批量插入或删除内容,V
例：使用ctrl+v并选中1到10行，按shift+i，输入//，按esc键结束，则第1到10行被注释。
2. 批量替换 :(Range) s/要查找的内容/替换为的内容/修饰符
~~~
1、Range为操作范围，n，m 为对n到m行进行操作，也可用.  $  %等代替。s为替换标志
2、修饰符有g （全局替换，不加则每一行只替换第一次出现）；c（检查）； i（忽略大小写）。
3、分隔符/也可用@或#代替。内容中有操作指令等，可用\转义符
~~~

3. 匹配
~~~
\(\)   子匹配
\1,\2 分别表示之前的子匹配
~~~

4. Global命令基础
~~~
:[range]g/pattern/cmd   
:g/pattern1/, /pattern2/cmd  // 在/p1/, /p2/之间执行cmd
~~~

5. Global 技巧, g v v//d
~~~
:g/A/d	查找并删除所有A，A缺省则为当前查找内容；
小技巧：在查找命令(* 也可以)后输入v//d，可以只显示搜索内容。（v为反转操作）
:g/^.*/mo0	行反序
t（复制行），co（复制行）
:5,10g/^/pu _    从第5行到第10行，在每一行下插入空行
:g/{/ .+1,/}/-1 sort    对被{}包围的文本按字母顺序进行排序。+1代表取下一行，-1代表取上一行
~~~ 

6. Global 技巧混合使用举例
部分匹配下的替换:g/A/s/B/C/ 
在有A的行中，将第一个B替换为C
~~~
:%s/\(A\)\(B\)/&C\2/g
将AB替换为ABCB；\(\)为子匹配，&为之前匹配到的内容，\2为第二次子匹配到的内容。
~~~
在行尾添加； :s/$/;/
在chapter1的下一行添加分割线:
~~~
:g/^chapter1/t. |s/./-/g
~~~

#### 5. 寄存器操作
~~~
qw	打开命令寄存器w		
cmd	输入命令
q	录入命令结束
n@w 	执行n次命令
~~~

### 6. 常用技巧
~~~
Ctrl+w+f
gf
以上两个指令都是打开光标下路径的文件，区别在ctrl+w+f是新打开窗口，wf则是覆盖
v//d
iab 添加常用语句
~~~


### 2.  扩展知识
#### 1. vim中三类文本对象 句，段落，节的区别
1. 句子 : 一个句子以 '.'、'!' 或者 '?' 结尾并紧随着一个换行符、空格或者制表符。
2. 段落 : 一个段落从空行或某一个段落宏命令开始，段落宏由 'paragraphs' 选项里成对出现的字符所定义
3. 小节: 一个小节从首列出现的换页符 (<C-L>) 或某一个小节宏命令开始


### 3. 传送门
0. [vim实用技巧（第二版)](https://blog.csdn.net/saying0101_0010_0000/article/details/114528186#:~:text=1%20%E6%8A%80%E5%B7%A713%20%E5%9C%A8%E6%8F%92%E5%85%A5%E6%A8%A1%E5%BC%8F%E4%B8%AD%E5%8F%AF%E5%8D%B3%E6%97%B6%E6%9B%B4%E6%AD%A3%E9%94%99%E8%AF%AF%202%20%E6%8A%80%E5%B7%A714%20%E8%BF%94%E5%9B%9E%E6%99%AE%E9%80%9A%E6%A8%A1%E5%BC%8F%203%20%E7%BB%93%E8%AF%86%E6%8F%92%E5%85%A5-%E6%99%AE%E9%80%9A%E6%A8%A1%E5%BC%8F,%E9%9A%8F%E6%97%B6%E9%9A%8F%E5%9C%B0%E5%81%9A%E8%BF%90%E7%AE%97%207%20%E6%8A%80%E5%B7%A717%20%E7%94%A8%E5%AD%97%E7%AC%A6%E7%BC%96%E7%A0%81%E6%8F%92%E5%85%A5%E9%9D%9E%E5%B8%B8%E7%94%A8%E5%AD%97%E7%AC%A6%208%20%E6%8A%80%E5%B7%A718%20%E7%94%A8%E4%BA%8C%E5%90%88%E5%AD%97%E6%AF%8D%E6%8F%92%E5%85%A5%E9%9D%9E%E5%B8%B8%E7%94%A8%E5%AD%97%E7%AC%A6%20%E6%9B%B4%E5%A4%9A%E9%A1%B9%E7%9B%AE)
1. [史上最全Vim快捷键键位图（入门到进阶）](https://www.runoob.com/w3cnote/all-vim-cheatsheat.html)
2. [vim中三类文本对象 句，段落，节的区别](https://blog.csdn.net/iteye_3607/article/details/82204909#:~:text=vim%E4%B8%AD%E4%B8%89%E7%B1%BB%E6%96%87%E6%9C%AC%E5%AF%B9%E8%B1%A1%20%E5%8F%A5%EF%BC%8C%E6%AE%B5%E8%90%BD%EF%BC%8C%E8%8A%82%E7%9A%84%E5%8C%BA%E5%88%AB%20iteye_3607%20%E4%BA%8E%202011-11-15%2014%3A59%3A00%20%E5%8F%91%E5%B8%83%201042,%27%3F%27%20before%20the%20spaces%2Ctabs%20or%20end%20of%20line.)
3. [如何在vim中使用系统剪贴板](https://blog.csdn.net/qq_44884716/article/details/111707347)
4. [vim使用 分屏命令、操作分屏](https://www.cnblogs.com/greamrod/p/12565193.html)
5. [Vim的剪贴板“unnamed”和“unnamedplus”设置有什么区别？](http://cn.voidcc.com/question/p-pyanmqcl-bhx.html)
