<!-- TOC -->
- [1. Compile](#1-compile)
- [2. Elaborate](#2-elaborate)
- [3. Simulate](#3-simulate)

<!-- /TOC -->

###  1. 【概述】
- VCS的仿真可以分为3个步骤：compile、elaborate和simulation，所以makefile脚本中也需要有这3个重要部分，脚本在平台中可以看到，后面会逐一对脚本功能进行介绍。
#### 1. Compile
将硬件语言编译成库的过程，具体来说可能会涉及3中不同类型的文件：verilog、VHDL和SystemVerilog。这三种文件的编译方法：verilog使用的是vlogan命令，systemverilog使用的也是vlogan命令，但是要添加-sverilg选项，VHDL使用的则是vhdlan这个命令。编译的过程中verilog文件可能会涉及到xilinx的IP或者硬核，这时候需要通过synopsys_sim.setup这个文件来指定IP库的位置，如下图所示，首先需要链接指定的IP库，其次声明当前编译库路径，和modelsim中的vlib和vmap是同样道理
图1.1.2-2 自定义synopsys_sim.setup
自定义的setup文件需要放在与makefile脚本同目录的路径下。VCS参考手册对synopsys_sim.setup文件搜索路径给出详细解释，可以看到VCS编译工具在运行时会依照先后顺序从以下3个路径查找synopsys_sim.setup文件。
图1.1.2-3 VCS手册定义setup文件搜索路径
所以只需要将synopsys_sim.setup文件放置在与makefile相同的目录下即可，VCS工具会自动搜索并识别IP库的位置。下图为makefile脚本中的compile部分，主要是指定临时编译库和编译Verilog文件
![image](https://user-images.githubusercontent.com/55919713/224054008-553486aa-7282-4197-99fa-7f3b8111a4eb.png)\
图1.1.2-4 compile部分脚本

#### 2. Elaborate
上面生成的库文件，以及可能用到的xilinx IP的库文件，生成仿真的可执行文件。具体的脚本如下，主要需要指定设计的bench顶层和全局复位的glbl模块，如果需要dump波形，还需要在编译中通过-P指定verdi的$fsdbDump函数的库，最后生成.o后缀的可执行文件用于最后的simulate步骤
![image](https://user-images.githubusercontent.com/55919713/224054117-a3f2a4c8-e286-458c-b4ba-855d6dc3ecce.png)\


#### 3. Simulate
这一步就是执行上面生成的simv.o可执行文件，进行仿真。由于需要生成适用于verdi的fsdb文件，所以在bench中还需要添加任务语句。Simulate部分脚本和bench如下所示。\
![image](https://user-images.githubusercontent.com/55919713/224054279-a0261f4c-c4f4-41c9-9a9d-22c2d7da23ea.png)\
图1.1.2-6 simulate部分脚本\
![image](https://user-images.githubusercontent.com/55919713/224054363-989d3724-48c1-49da-9d05-4fa3080ed998.png)\
图1.1.2-7 bench中设置fsdb波形

###  2. 【易错问题】
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

### 3. 调试
1. “-n” “--just-print” “--dry-run” “--recon” 不执行参数,eg,make .shadow/compile_vip_pkg

### 4. 参考：
1. [基于makefile脚本的VCS仿真平台](https://zhuanlan.zhihu.com/p/280702874#:~:text=1.1%20%E3%80%81VCS%E4%BB%BF%E7%9C%9F%E6%B5%81%E7%A8%8B)
2. [Makefile 中:= ?= += =的区别](https://www.cnblogs.com/wanqieddy/archive/2011/09/21/2184257.html)
3. [Makefile常用调试方法](https://www.cnblogs.com/LoTGu/p/5936465.html)
4. [Make file 换行符（反斜杠\）的用法](https://blog.csdn.net/weixin_49546923/article/details/123729363)
