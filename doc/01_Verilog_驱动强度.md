### 1.基础知识
#### 1.概述
1. net类型的变量还可以定义强度，因而可以更精确的建模。
2. net的强度来自于动态net驱动器的强度。在开关级仿真时，当net由多个驱动器驱动且其值互相矛盾时，可常用强度的概念来描述这种逻辑行为。
3. 常用的如下
~~~
(strength0, strength1)
(strength1, strength0)
(strength0)------------pulldown primitives only
(strength1)------------pullup primitives only
(chargestrength)------trireg nets only
strength0 = {supply0/strong0/pull0/weak0/highz0}强度由左至右依次减弱
strength1 = {supply1/strong1/pull1/weak1/highz1}强度由左至右依次减弱
chargestrength = {large/medium/small}
~~~

### 2. 经验
### 3. 传送门
1. [Verilog中强度strength的用法](https://blog.csdn.net/Michael177/article/details/122483862)
