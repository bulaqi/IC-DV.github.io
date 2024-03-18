### 1.如何评估一个平台的复杂度
1. 输入激励的个数
2. 参考模型中有关仲裁,fifo缓存处理
3. dut内设计时间的计算

### 2.好平台的若干项措施
1. 平台结构,VIP数据的获取
   
3. 不同组件如何获取DUT的全局配置,建议采用gloab.cfg文件,eg:通过ahb配置aem_region0_addr
- 思路:可以建立一个全局的配置类,该类内包含全部寄存,内部组件需要任何寄存器的值都从该类内获取
   1. 方法1: 平台可以通过监控总线数据,刷新该全局类的寄存器
   2. 方法2: 用例之间写该配置类的值
     
4. 合理的用例结构,可以快速开发的用例
  - 采用原华为的用例模板,和当前开发各种seq结合的方法,快速构建用例
  - 如果seq发包需要用task 封装,请重复考虑传参的全面性,建议:1:tc_cfg_struct_class 类,承载bit_map_en的用例控制结构图, 2.dut_cfg_seq类,传递配置信息 3.一个控制发包seq的类,eg,顺序发,rand发,全部发等场景

5. 充分考虑开发平台的可测试性,按照功能将关键信息打印至不同文件中
  - 打印用例中的激励, 在transaction中实现print_函数
  - 打印配置,在配置tranaction内实现print函数,打印初始化, 在实际发送的seq打印下发给dut的配置
  - 打印rm中收到的报文数据
  - 打印scb exp act的数据
    
6. 借助脚本,效率会更高
  开发bscb,将scb组件中的收到的exp和act报文数据,用becompare比较

7. 检查尽量黑盒测试,测试过程尽量不借助dut信号,确保scb中优先收到exp数据比act数据早
8. 严格按照VO表进行推进,欢迎有新想法,新想法可以先记录,完成计划任务后再补新idea,要详细开发和架构多轮评审的意义
9. dut全部的寄存 生成一个类,生成transaction;然后用该类生成dut_transaction
10. 平台数据的比较, dut的过程记录新建2个类exp类和act类,在env内,类型uvm_objection,在shut_down_phase 调用compare函数比较
    - exp类: 包含rm 计算值送入exp类,或者用例输入的类
    - act类: 包含dut接口寄存器和act 口输出的数据
11. 重复考虑功能覆盖率，将需要采集的数据封装成class, 通过tlm 传到 cov 组件
12. 平台搭建，考虑reset的时候复位，需要清理环境的全局统计数据，否则重启后数据对比失败
13. 典型seq， 需要尽可能的考虑到每次参数都可以被传参修改，细化约束
14.  reset平台需要重复考虑，是否是采用jump_phase 还是用run_phase 模块控制
15.  平台尽量通用传输，未使能的通道，请设计设计走特殊分支；
16.  激励seq 应该分层应该合理，尽量在可能得最顶层用不同的id参数隔离，子函数通过层层传递的参数并行工作， 注意下层都需要用automatic 修改task/function
      
### 3. 传送门:
[we can do better](https://github.com/bulaqi/IC-DV.github.io/blob/main/doc/%5BTOP%5D%20we%20can%20do%20better.md)
