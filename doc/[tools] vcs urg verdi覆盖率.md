### 1.基础知识
#### 1. urg生成report中的option：
~~~
-dir，指定需要拿到的db的hier，
-dbname，指定输出的merge db的hier
-elfile，指定exclusive的file，这样更好计算coverage。
-elfilelist 忽略中每一个.el文件。（Specifies a file containing a list of exclude files）
-noreport，不输出最终的report，只是merge 
-format text/both，指定report的输出格式
-matric [line，cond，fsm，tgl，branch，assert]执行计算的coverage类型
-parallel，并行merge
-full64，以64bit的程序进行merge
-plan，-userdata，-userdatafile，-hvp_no_score_missing，指定hvp相关的生成信息。
~~~

### 传送门
1. [VCS仿真和多个test用urg工具生成coverage文件verdi查看](https://blog.csdn.net/weixin_42058545/article/details/111932681?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-1-111932681-blog-111928703.235^v38^pc_relevant_yljh&spm=1001.2101.3001.4242.2&utm_relevant_index=4)
