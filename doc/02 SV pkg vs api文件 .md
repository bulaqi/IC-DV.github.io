### 1. 基础
#### 1. package
- 概述:可以将公共的数据打包到pkg, 使用的时候import后直接使用,eg aem_cq_seq_api_pkg.sv
- 数据结构: package xxx; end package
- 可封装的数据: 类,函数 , class ,task,,function, 声明
- 常用到的场景: seq_lib 对axi vip 接口封装, 实现业务面的wr rd,在其他地方import 后灵活使用

#### 2. env 各个组件用公共方法封装
- 数据结构: 无数据接口,sv 文件内内置方法
- 可以封装的数据: 结构,方法
- 应用场景: env 各个组件用公共方法封装


### 2. 传送门
