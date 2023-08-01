### 1. 基础知识
#### 1. 背景
1. 框图
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/25165f5b-2366-4aa8-b5e8-c5de11c05f19)
2. 寄存器模型RAL(RAL, register abstract layer)是一组高度抽象的类,用来对DUT中具有地址映射的寄存器和存储器进行建模;
3. 寄存器模型,要能模拟任意数量的寄存器域操作、副作用以及不同寄存器间的交互作用.

#### 2. 为什么要寄存器?
1 .寄存器建模 是 在软件的世界里面复刻RTL中的寄存器.
- 为软件所用,方便软件观测,方便软件使用。软件指的是整个验证环境所构造出来的面向对象的世界。
- 有了寄存器模型，RM可以很方便的获取到当前RTL的功能配置和状态，
- 也可以方便的收集到对寄存器各个域段甚至位的测试覆盖情况等等。
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/9132b0af-6460-4375-8ea8-324c25e55890)
2. 寄存器模型充当验证平台(尤其是uvm_component)与DUT之间寄存器访问操作的桥梁,简化了寄存器访问的流程
- 背景:reference model里面需要读取寄存器的值,在没有寄存器模型之前,需要考虑怎么在reference model里启动一个sequence以及怎么将sequence读回的值返回给reference model.
- 对比:
  - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/1bcb413a-fab5-419b-8de3-c9c55ee9c489)
  - 注1:不使用ral的register sequence(只支持frontdoor);
  - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/5aa02bb8-96cb-405b-a107-059daecff859)
  - 注2:使用ral的register sequence(支持frontdoor与backdoor);
  - ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/40cc4e66-6447-42dd-b64e-1f552389dcb5)
3. 寄存器模型完成启动sequence以及将读结果返回等操作;
4. 寄存器模型的本质是重新定义了验证平台与DUT的寄存器接口;





### 2. 注意事项
### 3. 传送门
1. [reg model1-简介1](https://www.cnblogs.com/csjt/category/2102623.html)
2. [reg model1-构建](https://www.cnblogs.com/csjt/category/2102624.html)
3. [reg model1-集成](https://www.cnblogs.com/csjt/category/2102625.html)
4. [reg model1-使用](https://www.cnblogs.com/csjt/category/2102626.html)
