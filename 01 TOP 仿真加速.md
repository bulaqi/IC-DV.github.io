### 1. 知识点
0. 调试阶段关闭不必要的选项，xproc,jitter,cov，debug_all等，
1. 多核并行仿真：使用 -j 选项来指定处理器的数量以加速仿真。例如，-j4 表示使用4个处理器进行并行仿真。
2. 细粒度并行性 (FGP)：通过 -fgp 选项启用，可以与 -j 选项结合使用以进一步提升仿真速度。例如，vcs -fgp -full64 <otherOptions>% simv -fgp=num_threads:4,num_fsdb_threads:4。
3. 使用 save/restore 机制：在仿真过程中定期保存状态，以便在出现问题时可以从最近的保存点恢复，而不必重新仿真。
4. 避免在循环中进行不必要的计算：例如，循环条件中不要包含计算，与循环因子无关的计算应在循环外完成，避免在循环中进行数据引用。
5. 优化数据结构：使用结构体代替类，减少动态对象的创建和销毁，以减少内存管理开销。
6. 减少动态任务或函数的唤醒：动态任务或函数的执行可能导致仿真器禁用优化，尽量减少它们的执行。
7. 使用回调函数优化随机约束：使用 pre_randomize() 和 post_randomize() 函数避免低效的约束行为。
8. 减少条件判断和字符串处理：在UVM中使用 report 管理机制，根据 verbosity 等级判断是否需要打印信息或进行字符串格式处理。
9. 合理使用阻塞和非阻塞赋值：避免在阻塞赋值语句的左侧或右侧放置延时，这可能导致仿真效率降低。
10. 优化仿真调度：理解 SystemVerilog 的 event-driven 仿真模型，优化事件处理以提高仿真速度。
11. 减少对函数/任务的调用：每次调用函数或任务都会操作堆栈数据，这可能导致仿真变慢，应尽量减少这类调用。
12. 硬件仿真加速平台：使用如 Veloce 这样的硬件仿真加速平台，以提高仿真速度。
13. JVM 优化：更换 JVM 可以提高编译速度，例如使用 GraalVM 替代其他 JVM。
14.分布式仿真：采用分布式仿真技术，可以显著提高仿真速度，尤其适用于带宽密集型应用

### 2. 经验
### 3. 传送门
1. [vcs-accelerate] (https://francisz.cn/2020/10/11/vcs-accelerate)
2. [验证仿真提速系列--SystemVerilog编码层面提速的若干策略](https://zhuanlan.zhihu.com/p/384492472)
3. [SystemVerilog仿真速率提升_vivado systemverilog仿真速度](https://blog.csdn.net/Michael177/article/details/125473167)
4. [DVCon-US-2020】以接口为中心的软硬件协同SoC验证](https://developer.aliyun.com/article/1072936)
5. [[SV]Verilog仿真中增加延时的方法总结及案例分析 - CSDN博客](https://blog.csdn.net/gsjthxy/article/details/106029996)
6. [为什么我的SystemVerilog仿真还是很慢？ - CSDN博客](https://blog.csdn.net/kevindas/article/details/107753486)
7. [SystemVerilog LRM 学习笔记 -- SV Scheduler仿真调度 ](https://blog.csdn.net/wonder_coole/article/details/82182850)
8. [使用 Veloce 加快网络 ASIC 验证速度 - Siemens Resource](https://resources.sw.siemens.com/zh-CN/white-paper-faster-network-verification-with-veloce)
9. [编译与仿真加速 - XiangShan 官方文档](https://xiangshan-doc.readthedocs.io/zh-cn/latest/tools/compile-and-sim/)
10 [：VCS：助力英伟达开启Multi-Die系统仿真二倍速 - Synopsys](https://www.synopsys.com/zh-cn/blogs/chip-design/vcs-multi-die.html)
