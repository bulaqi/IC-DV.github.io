### 1. 基础知识
### 2. 经验
1. 注意gVim需要能够获取 shell的环境变量
2. 先确定UVM_HONME 和 WORK_HOME 环境变量(用例filelist 需要使用的 )
3. 其实可以先看该书籍源码的readme,step by step
4. 用例的run_tc 脚本的vcs仿真部分，需要添加bsub 和-full64 选项
5. 运行时候，./simv +UVM_TESENAME=my_case0, 注意不加.sv 后缀
   
### 3. 传送门:
1. [如何使用VCS和verdi跑通《UVM实战》上的例子](https://blog.csdn.net/sinat_41774721/article/details/123903999)
2. [uvm包的环境搭建以及跑通uvm实战中的示例代码
](https://blog.csdn.net/rainforants/article/details/136317783?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-0-136317783-blog-123903999.235^v43^pc_blog_bottom_relevance_base5&spm=1001.2101.3001.4242.1&utm_relevant_index=3)
3. [【手把手带你学UVM】~ 记录遇到的一切错误](https://blog.csdn.net/qq_40549426/article/details/125815312)
