### 1. 知识点：
    SV 默认是静态变量，在for 循环内fork 需要特别注意
### 2. 解决方案：
    利用 **动态变量传参**,必须通过automatic 类型变量传递到子函数
### 3. 参考代码:
~~~
task cq_rm_proc::cq_proc(int ch_id);
    $display("cq_proc : ch_id=%0d",ch_id);

endtasK

task cq_rm_proc::run_phase(uvm_phase pahse);

    for(int i= 0;i<5;i++) begin
        fork
            automatic int k =i；
            cq_proc(k);
            //cq_proc(i);  // 直接传递i ,发生错误，cq_proc传递的i值等于5
        join_none
    end
endtask
~~~

#### 4. 传送门
1. [fork-join_none与循环语句共同使用的行为探究](https://link.zhihu.com/?target=https%3A//blog.csdn.net/moon9999/article/details/104207565)