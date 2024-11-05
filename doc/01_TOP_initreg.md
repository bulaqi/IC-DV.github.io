### 1. 基础知识
#### 1. 使用+vcs+initreg+random编译
  1. (本文所说的编译全部指的是elab阶段)选项，用于在整个设计中初始化Verilog变量、寄存器和memory（包括MDA多维数组）——初始化的方式是在0时刻给定一个随机的值，或0或1。
支持的类型包括reg、bit、integer、int、logic
  2. 支持的类型包括reg、bit、integer、int、logic
  3. 在run选项中，需要加如下多种可选的方式
	  ~~~
	  +vcs+initreg+0
	  +vcs+initreg+1
	  +vcs+initreg+random
	  +vcs+initreg+x
	  +vcs+initreg+z
	  ~~~
  4. 第一种就表示整个设计初始化为0值，其它同理。
  5. 根据经验，在后仿真中，为防止X态扩散传播，避免使用+vcs+initreg+x或+vcs+initreg+z。
  6. initreg机制和xprop是两种完全不搭边的仿真机制，所以两者并不是互斥或互相代替的关系
  7. 编译选项和运行选项
     - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/e07c55cd-ab76-48a3-aac1-e49eb4135a95)
     - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/4d10beaf-0357-4813-8682-24d844a1f110)

#### 2. 配置文件实现
  1. 使用配置文件的方式，可对设计中的其中某部分实现initreg初始化，这样的定制化可以实现整个设计初始化的多样性。
  2. 使用+vcs+initreg+config+configfile编译选项
  3. 如果在此基础上，又把+vcs+initreg+config+configfile作为run选项，那么runtime执行的configfile会改写编译阶段的configfile
  4. 配置文件的语法，和覆盖率配置文件语法很像，选择其一即可（一般情况不会用，用上面的全局配置就好
	  ~~~
		defaultvalue x|z|0|1|random|random seed_value
		instance instance_hierarchical_name [x|z|0|1|random|random seed_value]
		tree instance_hierarchical_name depth [x|z|0|1|random|random seed_value]
		module module_name [x|z|0|1|random|random seed_value]
		modtree module_name depth [x|z|0|1|random|random seed_value]
	  ~~~
  5. 通过设置环境变量，可打印实际仿真的初值到仿真目录的vcs_initreg_random_value.txt文件中
	- 1.在.cshrc文件中，增加setenv VCS_PRINT_INITREG_INITIALIZATION 1；
	- 2.在Makefile中，增加export VCS_PRINT_INITREG_INITIALIZATION=1。

  6. eg；默认不加initreg，三方IP NoC内部无复位端寄存器dontStop在初始阶段是X态
        - 默认不加initreg，三方IP NoC内部无复位端寄存器dontStop在初始阶段是X态，图1：
           ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/e85fcc53-e015-43ed-bb35-330db1ade672)
	- 加了initreg+0，NoC内部无复位端寄存器dontStop在初始阶段是0，图2：
           ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/122449e2-d3d8-410f-93d5-e5fc0142f921)

  
### 2. 经验

### 3. 传送门
 1. [VCS +vcs+initreg使用经验汇总](https://blog.csdn.net/develop2006/article/details/124846874)
