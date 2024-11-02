### 1. 基础知识
#### 1. 双引号
保护特殊元字符和通配符不被shell解析，但是允许变量和命令的解析，以及转义符的解析。

#### 2. 单引号
单引号内不允许任何变量、元字符、通配符、转义符被shell解析，均被原样输出。
使用双引号或反斜杠转义可显示输出单引号，但是双引号和反斜杠不能被同时使用。如命令：echo “\‘”，输出结果会为（\’），而不是（'）。
单引号可保证其内部所有字符不被shell解析，如单引号与grep、sed、awk命令配合使用，则单引号内部字符将直接发送给grep、sed、awk命令进行正则表达式的解析。使用grep、sed、awk命令时，推荐与单引号配合使用。
~~~
grep "\\\\" file 与 grep '\\' file执行的是相同的命令，解析如下：
第一条命令使用了双引号，允许shell对转义符进行解析，shell把四个\解析成2个\传递给grep，grep再把2个\解析成一个\查找；
第二条命令使用了单引号，shell不允许解析，直接把2个\传递给grep，grep再把2个\转义成一个\查找。
~~~

#### 3. 反引号
反引号的功能是命令替换，在反引号(``) 中的内容通常是命令行，程序会优先执行反引号中的内容，并使用运行结果替换掉反引号处的内容。

#### 4. 无引号
Linux中具有特殊含义的字符均保持他们的特殊含义，如果内容中有命令、变量等，会先把变量、命令解析出结果，然后在输出最终内容来。

但如果字符串中带有空格等特殊字符，则不能完整的输出，需要改加双引号。

一般连续的字符串，数字，路径等可以用。

### 2. 经验
### 3. 传送门
1. [Linux中三种引号(单引号、双引号、反引号)的区别](https://blog.csdn.net/mahoon411/article/details/125426155?spm=1001.2101.3001.6650.1&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-125426155-blog-122901636.235%5Ev38%5Epc_relevant_yljh&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-1-125426155-blog-122901636.235%5Ev38%5Epc_relevant_yljh&utm_relevant_index=2)
