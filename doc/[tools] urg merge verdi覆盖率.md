### 1.基础知识
#### 1. urg生成report中的option：
~~~
-dir，指定需要拿到的db的hier，
-dbname，指定输出的merge db的hier
-elfile，指定exclusive的file，这样更好计算coverage。// 重点
-elfilelist 忽略中每一个.el文件。（Specifies a file containing a list of exclude files） //重点
-noreport，不输出最终的report，只是merge 
-format text/both，指定report的输出格式
-matric [line，cond，fsm，tgl，branch，assert]执行计算的coverage类型
-parallel，并行merge
-full64，以64bit的程序进行merge
-plan，-userdata，-userdatafile，-hvp_no_score_missing，指定hvp相关的生成信息。
~~~

#### 2. 只收集某些模块的toggle数据
可以通过在-cm_hier文件中收集coverage中排除的模块的端口收集 toggle coverage。
eg:假设不想收集模块foo（及其下的任何信号或层次结构）的code coverage。 为此，请在-cm_hier文件中添加-moduletree foo。
~~~
-moduletree foo
begin tgl(portsonly)
+module foo
end
~~~
假设顶层中例化了几个IP(IP1 IP2 IP3)，以及一些胶水逻辑，但是我们不想收集IP0 IP1的code coverage，仅仅收集IP3的端口的toggle coverage，以及胶水逻辑的code coverage，那么可以在-cm_hier后跟如下配置文件。
~~~
+tree dut
-moduletree IP1
-moduletree IP2
-moduletree IP3
 
begin tgl(portsonly)
+module IP3
end
~~~

### 2. 使用
1. verdi 查看覆盖率,el 文件为filelist
   ~~~
   verdi -cov -covdir xxx.vdb -elfilelist xx_ex_list     //备注:其中xx_ex_list包含需要加载的el文件的绝对路径
   ~~~

### 传送门
1. [VCS仿真和多个test用urg工具生成coverage文件verdi查看](https://blog.csdn.net/weixin_42058545/article/details/111932681?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-111932681-blog-111928703.235^v38^pc_relevant_yljh&spm=1001.2101.3001.4242.2&utm_relevant_index=4)
2. [仅仅收集某模块的端口上的toggle coverage](https://blog.csdn.net/hungtaowu/article/details/123182141)
