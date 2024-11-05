### 基础知识
1. 对象: 则是类的实例
2. 句柄: 指向对象的“指针”，通过对象的句柄来访问对象
3. 句柄和对象在函数调用时的传递，看下面两个函数的区别：
~~~
function pass_handle(A x_handle);
//此函数传递的时A类型的句柄，函数内可以通过该句柄访问调用者对象的变量
//函数内该句柄重新指向新的对象时，也不会影响调用者传递的对象
endfunction

function pass_handle(ref A x_handle);
//函数内该句柄重新指向新的对象时，会影响调用者传递的对象
endfunction
~~~

### 传送门
1. [Systemverilog中的句柄和对象](https://zhuanlan.zhihu.com/p/462213499)
