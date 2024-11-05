### 1. 基础知识
#### 1. verdi 比较2个波形
   - 参考:[Verdi使用方法（2）— 高效对比两个波形](https://blog.csdn.net/qq_38113006/article/details/127342442)
   - 经验:
     1. dock 下实现
     2. 默认窗口添加波形wave_1,
     3. 新建dock后,通过tools->new waveform 添加波形wave_2
     4. 切回wave_1,windows 选择dock_to 新建的dock
     5. 然后2个波形在同一dock下,
     6. 右下角的分栏符号调整窗口布局,
     7. 信号同步,Windows->sync all waveform by
   - 注意事项:
     1. 为了更好的同步,建议2个波形,加载相同信号
#### 2. Schematic 查看新模块框架
- 参考 [Verdi-ug --- nschema Tutorial](https://blog.csdn.net/ciscomonkey/article/details/111150152)
#### 3.verdi 单步调试--多线程定位方法
- 在stack 内找到要调试的线程,鼠标选中( )
- 然后F12调试 注意:不能在期望的地方打断点,否则线程还是循环进入,要在将进入的子线程前断点,单步跳入,然后鼠标点击stack,F12 单步
- 注意,进来的时候,待调试的循环和loop_id 匹配后不要再打断点了

#### 4. verdi调试不同的case
- tools -> prefrence -> simulation 修改UVM_TEST 运行选项后,再重新simulation -> invoke simulator


#### 5. verdi不退出界面,添加新的case
- simulation -> kill -> rebuild an resetart
- 实测: 效率比较低,类似完全编译

#### 6. verdi 显示信号类型
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/f9b6c0e9-e1d4-4df2-8d02-2001c73d0faa)



### 2. 经验

### 3. 传送门
#### 3.1 单点特性
1. [verdi调试不同的case](https://mp.weixin.qq.com/s/oxckmBUT8qm0Ysttyu5frA)
2. [verdi不退出界面,添加新的case](https://mp.weixin.qq.com/s/oxckmBUT8qm0Ysttyu5frA)

#### 3.2 专有特性
1. [Verdi用法小结 强烈推荐](https://mp.weixin.qq.com/s?__biz=MzkwNjM5NTM5Mw==&mid=2247485117&idx=1&sn=02408c4d577c4709660b32f2fc8e9b8a&chksm=c0e86cd3f79fe5c523b8dbf83ba0f5fb77d9c38bcd5babc3676aa6e08251f10ea8c54182728c&scene=21#wechat_redirect)
2. [重要:verdi实用技巧](https://mp.weixin.qq.com/s?__biz=MzUyNzA2MDA0OQ==&mid=2247539831&idx=1&sn=a861a96d748be32fd5e38e363fb4b1f0&chksm=fa074149cd70c85f3b507a8b94992b75d89d29045a92925eef61d2e048e6cca22ef0a0cf07fd&mpshare=1&srcid=0522XCa0nM8A7WnGlJyS2aKE&sharer_sharetime=1686885299181&sharer_shareid=c096f846705470267ad9be9442e99eaa&from=singlemessage&scene=1&subscene=10000&clicktime=1686896107&enterid=1686896107&sessionid=0&ascene=1&realreporttime=1686896107658&forceh5=1&devicetype=android-31&version=28002553&nettype=WIFI&abtest_cookie=AAACAA%3D%3D&lang=zh_CN&countrycode=CN&exportkey=n_ChQIAhIQWHcPrn32CYSGr3XmvM%2FEuRLvAQIE97dBBAEAAAAAAOxTBgD6zJgAAAAOpnltbLcz9gKNyK89dVj0BQSgA0nOJgnoz7qTu1%2BjiJo5DnEJ1nXL6BYzTq4%2BkRtG9EaWS8GFBgKxFs%2FgclpKzHVe3kjlKNlSY6I5zFO%2BkPrmIcpFLEglRDCZPqFj0gWvRY4UPLKMXUAx6t26whLaW9Q3P1REN5OPkroOuz5dTidmPkjoSi2XT8CWB01JhfzbnyqwPjld8bvE7XC3q7GwoSgmDIQcnpoUaS5ZwX5pxC0M4IhYwZfkqjRcFDFB6Az0sHfRWIsxnbVo1wzVY8fcwmE5Cuh8Sigf&pass_ticket=c9ebmqsud9Px5XHyMQ%2BOPDQ0KRQWHGdxpgbR8GIMK7%2B2611JXQXY)
3. [verdi常用操作](https://github.com/bulaqi/IC-DV.github.io/wiki/%5B%E5%B7%A5%E5%85%B7%5D-Verdi%E5%B8%B8%E7%94%A8%E6%93%8D%E4%BD%9C)
4. [verdi实用技巧](https://cloud.tencent.com/developer/beta/article/1897270)
5. [实用Verdi 的使用技巧](https://code84.com/819640.html)
6. [Verdi的启动和设置](https://blog.csdn.net/zhajio/article/details/109450318)
7. [verdi实用技巧](https://zhuanlan.zhihu.com/p/427579054)
