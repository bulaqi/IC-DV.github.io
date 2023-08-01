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
#### 3.寄存器模型的结构(含层次化的regmodel&file)
0. ral 框图
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/042b695d-739b-446b-8b15-5dd0f72fea39)
寄存器模型就是一些类的集合,这些类模拟了DUT中的存储器、寄存器以及寄存器、存储器映射行为.这些类用于产生特定激励,进行功能检查. 
1. normal register model
   ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/89ebcbac-f218-4bf5-80de-e2aabfd95a0f)

3. hierarchical regmodel(含regfile及sub_regmodel)
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/9c780498-f74f-4859-9167-d43255821031)
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/c2089f10-65c5-48a0-9ce4-a874fd4c3a6e)
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/d34d7946-ebf4-4d8f-87be-4d71c9493e13)
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/c6de36b3-096f-4d19-9993-0e0d86e3484f)
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/183d5257-98fd-4977-a5b6-4c7bac1e420e)
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/af3705cf-e7d8-4da8-bb42-8b47fd9276b3)


4. hierarchical regmodel实现方式1(含regfile及sub_regmodel, multi_reg_field)
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/d7070b0f-48a3-48a7-97f5-3926790ea494)

5. hierarchical regmodel实现方式2(含regfile及sub_regmodel, multi_reg_field)
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/6510b61a-3c11-49bb-b872-19ab07036126)


#### 4. regmodel的生成
   由于项目中寄存器数量多,通常使用工具产生和维护UVM寄存器模型,常见工具如下:
- Synopsys VCS自带的ralgen可以产生uvm寄存器模型;
- Paradigm works公司开源的RegWorks Spec2Reg;
#### 5. register model的并行访问
  - 多个并行执行的线程可同时访问register model,但是当访问同一个register时,内部会对这些访问进行串行处理;
  - 每一个register内都有一个旗语,用于确保同一时刻只有一个线程对其进行读写操作; 如果一个线程在执行register访问操作的过程中被显式kill,有必要通过调用uvm_reg::reset()函数release该register的旗语;

### 2. 注意事项
### 3. 传送门
1. [reg model1-简介1](https://www.cnblogs.com/csjt/category/2102623.html)
2. [reg model1-构建](https://www.cnblogs.com/csjt/category/2102624.html)
3. [reg model1-集成](https://www.cnblogs.com/csjt/category/2102625.html)
4. [reg model1-使用](https://www.cnblogs.com/csjt/category/2102626.html)
