# 1.背景
![image](https://user-images.githubusercontent.com/55919713/225830972-ffbaecac-69de-4e51-b37f-1c95b44f53d5.png) \
\
参考：https://link.zhihu.com/?target=https%3A//www.dazhuanlan.com/flamingrock/topics/1212210

# 2.分析
## 2.1 active
- 包含所有的 component， 比如 sequencer、driver、monitor；
- 数据可以通过 driver 来驱动 DUT
## 2.2 passive
- 只包含 monitor 和 coverage group 等；
- 用于 checker 和 coverage

# 3.特殊说明
【TIPS】DUT AXI作为输出口时，测试平台AXI_VIP 组件 slave方式，应该设置为**active模式**接收数据\
原因：axi写数据后有**response**,需要drive发送，如果设置为passive模式，则无法发送response信号，出现错误