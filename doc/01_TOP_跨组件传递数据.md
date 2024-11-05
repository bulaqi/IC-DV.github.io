### 1. 基础知识

#### 1. (推荐)config_db传送,传的是句柄 (可靠)
#### 2. (推荐)tlm port传送(可靠)
#### 3. (推荐)通过get_parent层次化的传送(可靠)

#### 4. (不推荐)B组件内声明一个A组件的元素menber_a,A组件内李华menber_a, 在上一层,赋值, b.menber_a = a.menber_a(无法 察觉到每个clk 源信号的变化,建议背景线程,clk 都刷新赋值)

### 2. 传送门
1. [通过uvm_config_db做变量、接口和句柄传递时，需要注意哪些细节？](https://blog.csdn.net/weixin_59038209/article/details/132312651)
