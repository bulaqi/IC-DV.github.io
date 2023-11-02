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
  
### 2. 经验

### 3. 传送门
