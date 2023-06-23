### 1. Sed
 命令的作用是利用脚本来处理文本文件
 ~~~
sed [-hnV][-e<script>][-f<script文件>][文本文件]
 ~~~
参数说明：
- -e<script>或--expression=<script> **以选项中指定的 script 来处理输入的文本文件，这个-e可以省略，直接写表达式**。
- -f<script文件>或--file=<script文件>以选项中指定的 script 文件来处理输入的文本文件。
- -h或--help显示帮助。
- -n 或 --quiet 或 --silent 仅显示 script 处理后的结果。
- -V 或 --version 显示版本信息。

动作说明：
- a：新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一行)～
- c：取代， c 的后面可以接字串，这些字串可以取代 n1,n2 之间的行！
- d：删除，因为是删除啊，所以 d 后面通常不接任何咚咚；
- i：插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行)；
- p：打印，亦即将某个选择的数据印出。通常 p 会与参数 sed -n 一起运行～
- s：取代，通常这个 s 的动作可以搭配正规表示法，例如 1,20s/old/new/g 。

### 举例
0. 准备文件
~~~
➜ cat test 
HELLO LINUX!  
Linux is a free unix-type opterating system.  
This is a linux testfile!  
Linux test
~~~

1. 增加内容
   使用命令sed -e 3a\newLine testfile这个命令的意思就是，在第三行后面追加newLine这么一行字符，字符前面要用反斜线作区分
~~~
➜ sed -e 3a\newline test  
HELLO LINUX!  
Linux is a free unix-type opterating system.  
This is a linux testfile!  
newline
Linux test
~~~
但是注意，这个只是将文字处理了，没有写入到文件里，文件里还是之前的内容
其实 a 前面是可以匹配字符串，比如我们只想在出现 Linux 的行后面追加，就可以：sed -e /Linux/a\newline test 两个斜线之间的内容是需要匹配的内容。可以看出，只有第二、第四行有Linux，所以结果如下：
~~~
➜ sed -e /Linux/a\newline test 
HELLO LINUX!  
Linux is a free unix-type opterating system.  
newline
This is a linux testfile!  
Linux test 
newline
~~~
这里用双引号把整个表达式括起来也可以，还方便处理带空格的字符。
~~~
sed -e /Linux/a\newline test等效于sed "/Linux/a newline" test
~~~

2. 插入内容
   跟 a 类似，sed 3i\newline test是在第三行前面插入newline:
~~~
➜ sed 3i\newline test
HELLO LINUX!  
Linux is a free unix-type opterating system.  
newline
This is a linux testfile!  
Linux test
~~~
sed /Linux/i\newline test是在所有匹配到Linux的行前面插入：
~~~
➜ sed /Linux/i\newline test
HELLO LINUX!  
newline
Linux is a free unix-type opterating system.  
This is a linux testfile!  
newline
Linux test
~~~

3. 删除
删除的字符是d，用法跟前面也很相似，就不赘述
~~~
➜ sed '/Linux/d' test      
HELLO LINUX!  
This is a linux testfile!
~~~

4. 替换 c
替换也是一样，字符是c
~~~
➜ sed '/Linux/c\Windows' test                   
HELLO LINUX!  
Windows
This is a linux testfile!  
Windows
~~~
5.替换 s
替换还有个字符是 s，但是用法由不太一样了，
1. 最常见的用法：sed 's/old/new/g'其中old代表想要匹配的字符，new是想要替换的字符，比如 
~~~
➜ sed 's/Linux/Windows/g' test
HELLO LINUX!  
Windows is a free unix-type opterating system.  
This is a linux testfile!  
Windows test
~~~
这里/g的意思是一行中的每一次匹配，因为一行中可能匹配到很多次。我们拿一个新的文本文件做例子
~~~
➜ cat test2
aaaaaaaaaaa
bbbbbabbbbb
cccccaacccc
~~~
2. 假设我们想把一行中的第三次及以后出现的a变成大写A，那应该这么写：
~~~
➜ sed 's/a/A/3g' test2
aaAAAAAAAAA
bbbbbabbbbb
cccccaacccc
~~~

3. s还有很多用法，还是回到第一个文件，比如可以用/^/和/$/分别代表行首和行尾：
~~~
➜ sed 's/^/###/g' test
###HELLO LINUX!  
###Linux is a free unix-type opterating system.  
###This is a linux testfile!  
###Linux test 

➜ sed 's/$/---/g' test
HELLO LINUX!  ---
Linux is a free unix-type opterating system.  ---
This is a linux testfile!  ---
Linux test ---
~~~
这个其实就是正则表达式的语法，其他类似语法还有：
- ^ 表示一行的开头。如：/^#/ 以#开头的匹配。
- $ 表示一行的结尾。如：/}$/ 以}结尾的匹配。
- \< 表示词首。 如：`\ 表示以 abc 为首的詞。
- \> 表示词尾。 如：abc\> 表示以 abc 結尾的詞。
- . 表示任何单个字符。
- * 表示某个字符出现了0次或多次。
- [ ] 字符集合。 如：[abc] 表示匹配a或b或c，还有 [a-zA-Z] 表示匹配所有的26个字符。如果其中有^表示反，如 [^a] 表示非a的字符

4. 还可以在字符前面增加行号或者匹配。什么意思呐？比如你想在第一和第二行后面增加一行内容newline
~~~
➜ sed '1,2a\newline' test
HELLO LINUX!  
newline
Linux is a free unix-type opterating system.  
newline
This is a linux testfile!  
Linux test
~~~

5. 不止可以用数字来限定范围，还可以用匹配来限定，只需要用//括起来
~~~
➜ sed '/LINUX/,/linux/i\test' test
test
HELLO LINUX!  
test
Linux is a free unix-type opterating system.  
test
This is a linux testfile!  
Linux test
~~~
从匹配到LINUX的那一行，到匹配到linux的那一行，也就是 123 这三行，都做插入操作。

6. 多个匹配
用-e命令可以执行多次匹配，相当于顺序依次执行两个sed命令：
~~~
➜ sed -e 's/Linux/Windows/g' -e 's/Windows/Mac OS/g' test
HELLO LINUX!  
Mac OS is a free unix-type opterating system.  
This is a linux testfile!  
Mac OS test
~~~
这个命令其实就是先把Linux替换成Windows，再把Windows替换成Mac OS。
写入文件
上面介绍的所有文件操作都支持在缓存中处理然后打印到控制台，实际上没有对文件修改。想要保存到原文件的话可以用> file或者-i来保存到文件
