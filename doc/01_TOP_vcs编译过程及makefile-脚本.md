###  1. 概述
以Makefile启动VCS为例来讲解如何使用命令参数，VCS编译文件会引入过多参数，试想如果我们每次都需要终端中敲击过多参数才能运行一次VCS，那么效率显然是很低的，于是通过脚本语言存储参数从而简化操作指令是必要的，于是Makefile派上了用场。
我们通常会将参数写入到Makefile中，然后通过脚本简化命令成make run_vcs来一步完成VCS的编译连接运行，这称为一步法（首参数是vcs）。

###  2. VCS的常用命令参数
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/636de224-7d71-43ac-b66f-2d1f06781243)
注意：incdir文件的时候，只能包含文件夹下的文件，而不包括下级文件夹的内容（如果要包含下级文件夹的内容，需要写+incdir+uvm/{test，test/basic_test}，这样就包括了uvm下test文件中的文件，同时包含了uvm下test下basic_test中的文件） 
###  3. VCS的三步编译
#### 1. 一步法
对设计/验证文件用VCS做编译检查时，可以只用一些简单的VCS指令来实现。以下操作适合不涉及仿真，仅仅检查当前写的文件是否有错时使用。
如果在编译后还需要启动仿真（前提：具备验证环境），且文件繁多，且需要添加更多的控制参数，那么需要使用Makefile，以下是一步法的Makefile编写示例
一步法Makefile编写示例：
通过-R选项将编译与仿真操作合并，从而实现一步法1
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/10f2a8fe-b368-4548-b0d7-3ff7da0dd049)

#### 2. 两步法
我们有时会将编译与仿真拆分，在编译完成生成simv文件后，再运行仿真执行simv文件，称为两步法。
两步法Makefile编写示例：
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/bbed833a-22ef-4f04-bd0f-5ccae8ae1f24)
补充：-gui参数是可选的，控制打开图形化界面，可以打开verdi或dve，dve是vcs原生的，而verdi用的比较广泛
#### 3. 三步法
三步法相比于两步法将编译（compile）拆分成了分析（analysis）和细化（elaborate），一般是在面对多文件类型编译时（比如有verilog也有VHDL）用到。实际上这是按照VCS实际运行过程来划分步骤的，VCS运行的过程是将编译通过的文件临时存储，然后通过细化成为可执行的文件.simv，最后通过执行.simv文件即可完成文件的编译与仿真。

在Makefile中先实现分析命令（首参数是vlogan或vhdlan，分别编译verilog和VHDL文件，这里的an是analysis的缩写），再实现细化命令（首参数是vcs），最后实现仿真命令。
三步法Makefile编译示例
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/6bfa2963-1bf2-4837-a6d0-19e3fe029111)

#### 4.常见错误
cannot find vcs compiler

不用Makefile编译，时常会少打一些编译参数，比如缺少-full64，则会报cannot find vcs compiler。另外如果编译sv文件，不加-sverilog则会报syntax error（语法错误）
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/79389799-2fa3-451a-b5c9-eabef3f6cfe5)



###  4. 易错问题
#### 1.  = ?= :?的区别:
- = 是最基本的赋值, make会将整个makefile展开后，再决定变量的值。也就是说，变量的值将会是整个makefile中最后被指定的值。
- := 是覆盖之前的值,:=”表示变量的值决定于它在makefile中的位置，而不是整个makefile展开后的最终值 [易错]
- ?= 是如果没有被赋值过就赋予等号后面的值
- += 是添加等号后面的值
#### 2.  编译文件换行--反斜线 
注意点
- 末尾加“\”
- 第二行前不得为tab键，空格即可
~~~ 
all :
	@for subdir in $(SUBDIRS);\
    do $(MAKE) -C $(DIR)/$$subdir || exit 1;\
    done
~~~
#### 3. 需要注意编译问题,是否归于tb,vip,还是dut,在那个部分编译
#### 4. strip用法
~~~
#$(strip <string> )
#名称：去空格函数——strip。
#功能：去掉<string>字串中开头和结尾的空字符,并将中间的多个连续空字符(如果有的话)合并为一个空字符。
#返回：返回被去掉空格的字符串值。
#说明: 空字符包括　空格,tab等不可显示的字符
#把字串" abc"开头的空格去掉,结果是"abc"。
str1 :=    abc
str2 := abc      
str3 := a   b  c
all:
    @echo bound$(strip $(str1))bound
    @echo bound$(strip $(str2))bound
    @echo bound$(strip $(str3))bound
~~~

### 5. 调试
1. “-n” “--just-print” “--dry-run” “--recon” 不执行参数,eg,make .shadow/compile_vip_pkg

### 6. 参考：
1. [Makefile使用教程_推荐](https://blog.csdn.net/weixin_55225128/article/details/128514273)
2. [【数字IC快速入门】Makefile脚本了解](https://blog.csdn.net/weixin_38967029/article/details/125906452)
3. [Makefile 中:= ?= += =的区别](https://www.cnblogs.com/wanqieddy/archive/2011/09/21/2184257.html)
4. [Makefile常用调试方法](https://www.cnblogs.com/LoTGu/p/5936465.html)
5. [Make file 换行符（反斜杠\）的用法](https://blog.csdn.net/weixin_49546923/article/details/123729363)
6. [基于makefile脚本的VCS仿真平台](https://zhuanlan.zhihu.com/p/280702874#:~:text=1.1%20%E3%80%81VCS%E4%BB%BF%E7%9C%9F%E6%B5%81%E7%A8%8B)
