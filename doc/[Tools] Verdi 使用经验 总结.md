### 1. verdi 单步调试--多线程定位方法
在stack 内找到要调试的线程,选中,然后F12调试
注意:不能在期望的地方打断点,否则线程还是循环进入,要在将进入的子线程前断点,单步跳入,然后鼠标点击stack,F12 单步
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/807e2480-0470-4105-90e4-299b6adc42bb)
