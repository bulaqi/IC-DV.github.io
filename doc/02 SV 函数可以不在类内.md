### 知识点：
sv函数可以不写在类内

### 背景：
env 下的多个组件需要一套公用的方法，如果分别写在类内，代码冗余度差

### 解决方案：
将公用的方法写在一个文件内xx_api.sv，各个组件包含该文件


### 注意事项
函数需要定义为automatic类型，目的是，防止多线程访问出错
~~~
task atuomatic  get_sq_head();
endtask
~~~

### 参考
[SV中的automatic与static](https://blog.csdn.net/better_xiaoxuan/article/details/79015165)