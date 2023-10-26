### Dump波形命令

#### 1. $fsdbDumpfile(fsdb_name[,limit_size])
指定波形文件名，第二个参数可选择用来限制波形的大小(MB)。$fsdbDumpfile(“tb_top.fsdb”，500);
其中文件名可能被$fsdbDumpvars覆盖。

#### 2. $fsdbDumpvars([depth, instance][, “option”])*

depth表示要加载波形的层次；
~~~
0表示当前instance下的所有变量一级其他module实例的波形，
1表示当前instance中的变量的波形，不包括当前instance中的其他module实例的波形，
2表示包含当前instance以及其中的第一级子instance的波形；以此类推。
~~~
instance指定要加载波形的module名。
option加载波形的选项，如：
+IO_Only – 只加载IO port信号；
+Reg_Only – 只加载reg类型信号；
+mda – 加载memory和MDA信号；
+packedmda – 加载packed MDA；
+struct – 加载structs；
+parameter – 加载parameter；
+fsdbfile+filename – 指定fsdb文件名字。


#### 3. $fsdbDumpon/$fsdbDumpoff([“option”])
控制波形加载的开始和结束；
$fsdbDumpoff之后，将停止记录信号值的变化，直到$fsdbDumpon，从当前时刻开始记录信号值的变化。
option—选项，如：
+fsdbfile+filename – 指定将特定文件的波形加载打开与关闭，如果不指定，则默认指当前仿真所有的波形文件；

#### 4. $fsdbAutoSwitchDumpfile(file_size, “fsdb_name”, number_of_files[, “log_file_name”, “+fsdb+no_overwrite”])
当波形的大小达到限制后自动以一个新的波形文件起始加载波形；
在所有的波形文件加载完成后，会创建一个virtual FSDB文件，查看波形时只需要加载此文件就可以合并所有的波形文件。
file_size—波形文件大小限制，单位为MB，最小为10M，若值小于10M则默认10M；
file_name—波形文件的名字，在实际加载波形时，文件名为file_name_000.fsdb file_name_001.fsdb…；
number_of_files—最多可以加载多少个file_size这么大的波形文件，如果写为0，则默认没有限制；
log_file_name—指定log文件的名字；
+fsdb+no_overwrite—当number_of_files限制的个数达到时停止dump波形；

#### 5. $fsdbDumpflush()
在仿真过程中强制将信号值加载到波形中，便于在仿真过程中查看波形；

#### 6.$fsdbDumpFinish()
在仿真过程中调用，停止dump波形；

#### 7.$fsdbSwitchDumpfile(“new_file_name”[, “+fsdbfile+src_file”])
关闭现有的波形文件，以一个新的文件名开始加载波形；
new_file_name—创建一个新的波形文件，将波形加载到这个文件中；
+fsdbfile+src_file—指定要停止加载并关闭的波形文件， 这个参数不指定时，将默认使用当前正在加载的波形文件；
#### 8.$fsdbDumpvarsByFile(“text_file_name”[, “option”])
类似于$fsdbDumpvars，这个方法支持将需要加载波形的instance写在文件中。
text_file_name—文本文件，指定要dump波形的instance；
option—同$fsdbDumpvars中的option参数；
#### 8. $fsdbDumpSVA(depth,instance,"option")，dump指定模块的assertion
- $fsdbDumpSVA(1,system.arbiter,"+fsdbfile=SVA.fsdb"),将该instance下所有assert全部dump到该fsdb中  可以用+fsdbfile=SVA.fsdb dump到新的fsdb文件中


### 传送门
[Verdi使用简介及Dump波形命令](https://blog.csdn.net/jh18355358269/article/details/113578990)
