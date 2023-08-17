### 1. -v filename
-v 指定一个.v格式的库文件，VCS会来这个文件中找源代码中例化的但在源代码中找不到的module，这里一个文件可以里面包含很多module。
filelist列表中 -v xxx/xxx/fifo.v 表示该文件里面只有一个module，且module名为fifo。
filelist列表中直接引用 xxx/xxx/fifo.v 则对文件中的module名没有限制
### 2. partcomp,fastpartcom
 1. partcomp自动分块编译，只需要加入-partcomp的编译选项即可，应用起来比较简单。
 2. -fastpartcom=jn，n代表并行线程的数量
#### 3.vcs编译重复定义文件问题,-error=noMPD
 1. 在允许覆盖的情况下，消除不报error，用-top指定顶层或加选项-error=noMPD

### 传送门
1. [filelist中常用到的vcs 编译命令](https://blog.csdn.net/weixin_45270982/article/details/104000164?spm=1001.2101.3001.6650.2&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-2-104000164-blog-121585399.235%5Ev36%5Epc_relevant_yljh&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-2-104000164-blog-121585399.235%5Ev36%5Epc_relevant_yljh&utm_relevant_index=3)
2. [VCS 加速编译的方法——VCS Partition Compile](https://blog.csdn.net/hh199203/article/details/123067052)
3. [vcs 分离编译](https://blog.csdn.net/qq_41729871/article/details/125099963)
4. [vcs编译重复定义文件问题](https://blog.csdn.net/zds0901/article/details/119346891)
5. [VCS常用仿真选项开关及步骤总结 强烈推荐](https://mp.weixin.qq.com/s?__biz=MzkwNjM5NTM5Mw==&mid=2247484966&idx=1&sn=1a357b0d89b18d197c2afd57d945d33b&chksm=c0e86c48f79fe55e88bcaeaf29973f0e3624ae26e9443537dc0dd9c32e28c5ba61c6bbda74e9&scene=21#wechat_redirect)
