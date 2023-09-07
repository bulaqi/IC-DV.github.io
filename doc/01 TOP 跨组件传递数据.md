### 1. 基础知识

#### 1. config_db传送,传的是句柄 (可靠)
#### 2. tlm port传送(可靠)
#### 2. 通过get_parent层次化的传送(可靠)

#### 3. B组件内声明一个A组件的元素menber_a,A组件内李华menber_a, 在上一层,赋值, b.menber_a = a.menber_a(无法 察觉到每个clk 源信号的变化,建议背景线程,clk 都刷新赋值)

### 2. 传送门
