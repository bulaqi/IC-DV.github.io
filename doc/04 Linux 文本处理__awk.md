### 语法
awk是一个强大的文本分析工具，相对于grep的查找，sed的编辑，awk在其对数据分析并生成报告时，显得尤为强大。简单来说awk就是把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行各种分析处理。
~~~
awk [选项参数] 'script' var=value file(s)
或
awk [选项参数] -f scriptfile var=value file(s)
~~~
参数说明：
- -F fs or --field-separator fs 指定输入文件折分隔符，fs是一个字符串或者是一个正则表达式，如-F:。
- -v var=value or --asign var=value 赋值一个用户定义变量。
- -f scripfile or --file scriptfile 从脚本文件中读取awk命令。
### 用法
~~~
awk 动作 文件名
~~~
0. 先准备一个文件test
~~~
➜ cat test 
2 this is a test
3 Are you like awk
This's a test
10 There are orange,apple,mongo
~~~

### 1. 基础用法
1. 输入awk '{print $1,$4}' test
~~~
2 a
3 like
This's 
10 orange,apple,mongo
~~~
这行语句的作用是打印每行的第一个和第四个单词。这里如果是$0的话就是把整行都输出出来。

2. awk -F命令可以指定使用哪个分隔符，默认是空格或者 tab 键：
~~~
➜ awk -F, '{print $2}' test



apple
~~~
可以看出只有最后一行有输出，因为用逗号做分割，之后最后一行被分成了10 There are orange、apple和mongo三项，然后我们要的是第二项。

3. 还可以同时使用多个分隔符：
~~~
➜ awk -F '[ ,]'  '{print $1,$2,$5}' test 
2 this test
3 Are awk
This's a 
10 There apple
~~~
这个例子便是使用空格和逗号两个分隔符。

4. 匹配项中可以用正则表达式，比如：
~~~
➜ awk '/^This/' test
This's a test
~~~
匹配的就是严格以This开头的内容。

5. 还可以取反
~~~
➜ awk '$0 !~ /is/' test 
3 Are you like awk
10 There are orange,apple,mongo
~~~
这一个的结果就是去掉带有is的行，只显示其余部分。
从文件中读取：awk -f {awk脚本} {文件名}，这个很好理解，就不再做解释。

#### 2. 变量
 awk中有不少内置的变量，比如$NF代表的是分割后的字段数量，相当于取最后一个。
~~~
➜ awk '{print $NF}' test            
test
awk
test
orange,apple,mongo
~~~
可以看出都是每行的最后一项。
其他的内置变量还有：
- FILENAME：当前文件名
- FS：字段分隔符，默认是空格和制表符。
- RS：行分隔符，用于分割每一行，默认是换行符。
- OFS：输出字段的分隔符，用于打印时分隔字段，默认为空格。
- ORS：输出记录的分隔符，用于打印时分隔记录，默认为换行符。
- OFMT：数字输出的格式，默认为％.6g。

#### 3. 函数
awk还提供了一些内置函数，方便对原始数据的处理。主要如下：
- toupper()：字符转为大写。
- tolower()：字符转为小写。
- length()：返回字符串长度。
- substr()：返回子字符串。
- sin()：正弦。
- cos()：余弦。
- sqrt()：平方根。
- rand()：随机数

#### 4. 条件
awk允许指定输出条件，只输出符合条件的行。输出条件要写在动作的前面：
~~~
awk '条件 动作' 文件名
~~~
还是刚才的例子，用逗号分隔之后有好几个空白行，我们加上限制条件，匹配后为空的不显示：
~~~
➜ awk -F, '$2!="" {print $2}' test
apple
~~~
可以看到就只剩下apple了。

#### 5. if 语句
awk提供了if结构，用于编写复杂的条件。比如
~~~
➜ awk '{if ($2 > "t") print $1}' test
2
~~~
这一句的完整含义应该是：把每一行按照空格分割之后，如果第二个单词大于t，就输出第一个单词。这里对字符的大小判断应该是基于字符长度和 unicode 编码。
以上这些只是三剑客的基础用法，包括正则表达式也有很多技巧，更多扩展内容网上也很多了，可以自行搜索，或者翻阅下面的参考文章。


### 传送门
1. [Linux 文本处理三剑客：grep、sed 和 awk](https://zhuanlan.zhihu.com/p/110983126)
