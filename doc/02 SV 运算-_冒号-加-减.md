### 语法
1. +：
~~~
data[0 +: 8]  <--等价于--> data[7:0]
data[15 +: 2] <--等价于--> data[16:15]
~~~
2. -：
~~~
data[7 -: 8]  <--等价于--> data[7:0]
data[15 -: 2] <--等价于--> data[15:14]

~~~

3. 注意事项：循环的时候，记得起始地址位，需要乘数据位宽
~~~
bit[127:0] bit_test = 128'h9876_4321_1234_5678_1111_2222_3333_4444

for(int i=0;i<4;i++)

    $display("128bit_test= %0d",bit_tes[i*32 +: 32]); //注意i*32，，易错点
~~~

### 参考
[Verilog +: -:语法](https://link.zhihu.com/?target=https%3A//blog.csdn.net/feiliantong/article/details/107782129)
