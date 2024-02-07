### 1.知识点
1. 使用"phase.jump(uvm_reset_phase::get());"
### 2. 注意事项
1. phase.jump的时候前后不需要drop_objection
2. 如果jump 到rset_phase 内,请在reset_phase内添加复位流程,包括使能内部时钟使能寄存器

### 传送门
1. [UVM：5.1.7 phase 的跳转](https://blog.csdn.net/tingtang13/article/details/46516393)
2. [phase跳转时sequence的复位](https://zhuanlan.zhihu.com/p/60576096)
