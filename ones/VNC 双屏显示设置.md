1. 设置方法
 1.1. 设置linux 系统支持的分屏率
1）cvt 3820 1024 60 →让系统配置一个分辨率为3820x1024，刷新率为60fps

2）xrandr --newmode "3820x1024_60.00" 325.00 3824 4064 4464 5104 1024 1027 1037 1063 -hsync +vsync →添加一个自定义分辨率模式，newmode 后是自己命名的模式名,模式名后的参数都是执行步骤1）得到的

3）xrandr --addmode VNC-0 "3820x1024_60.00" // 注意是--addmode ,参考资料1中有错误, VNC-0 后有空格 →增加自定义模式到分辨率列表中，执行该操作后，通过xrandr就能看到名为"3820x1024_60.00"的分辨率模式了

4）xrandr --output VNC-0 --mode "3820x1024_60.00" →在当前VNC中使用名为"3820x1024_60.00"的分辨率模式

 

1.2. 打开vpn 的双屏支持 
vncviewer屏幕扩展的设置

2. 传送门
1. [VNC双屏设定（窗口切换，全屏设定···）](https://zhuanlan.zhihu.com/p/654265437)
2. [方法一：通过vncserver来调整分辨率](https://www.cnblogs.com/brianyi/p/8428582.html)
3. [linux 视频输出xrandr设置命令](https://www.cnblogs.com/xuanbjut/p/13815437.html)