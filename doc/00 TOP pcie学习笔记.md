### 1. 知识点
#### 1. 入门第一课
1. result
2. 
### 2. 经验
#### 1. 常识. 
1. BAR是地址base_size，size后续在驱动软件内存储
2. BAR 空间的获取，BAR寄存器先写全F，后读，如果是1，代表可配范围，相当于获取size，然后主机软件总体分配地址，重新写BAR
3. PCIE设备树的bar类似套娃，上层范围地址一定包含下层全部地址范围
4. PCIE 最大是X16插槽，可以向下兼容，
5. 1条line包含一个rx/tx接口，
6. pcie带宽指的是双向总的带宽，
7. PCIe Spec 中明确指出，IO 地址空间只是为了兼容早期的 PCI 设备（Legacy Device），在新设计中都应当使用 MMIO，因为 IO 地址空间可能会被新版本的 PCI Spec 所抛弃
8. 主机访问pcie 设备的
   - 配置空间：是通过CFG_MSG 类型的TLP 包实现的
   - MEM: ADDR 路由
   - MSG: 隐式路由，这正是通过 Message 的机制来实现原PCI的边带信号
   - ![image](https://github.com/user-attachments/assets/648f12de-afa8-4a08-82b5-e774c77f4210)

9.  

#### 2. RC vip 经验
1. 日志分类： tl（事务处） dll（数据链路层） phy（物理层） 层
2. 枚举前后分解:result
3. CFGW ：枚举bar地址


### 3. 传送门
1. 
