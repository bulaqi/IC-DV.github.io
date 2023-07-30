### 0. 背景
理想的验证环境是在被移植做水平复用或者垂直复用时，应当**尽可能少地修改模块验证环境本身，只在外部做少量的配置，或者定制化修改就可以嵌入到新的环境中**。
要做到这一点，
1. 一方面我们可以通过顶层环境的配置对象自顶向下进行配置参数传递，
2. 另外一方面我们可以在测试程序不修改原始类的情况下注入新的代码。
   
eg，当我们需要修改stimulator的行为时，有两种选择:
1. 一个是修改父类，但针对父类的会传播到其它子类；
2. 另外一个选择是在父类定义方法时，预留回调函数入口，使得在继承的子类中填充回调函数，就可以完成对父类方法的修改。 

### 1. 分类 SV_Call_back VS  uvm_call_back
#### 1. SV_Call_bcck
1. 注意事项
- 1. 预留回调函数入口；
- 2. 定义回调类/回调函数；
- 3. 例化环境时添加回调函数实例
2. eg
~~~
virtual class Driver_cbs; // Driver回调虚类，不能例化，但可以继承
    virtual task pre_tx(ref Transaction tr,ref bit drop);
    //默认不做操作
    endtask 
    virtual task post_tx(ref Transaction tr); 
    //默认不做操作 
    endtask
endclass 
 
class Driver;
    Driver_cbs cbs[$]; 
    task run(); 
        bit drop;
        Transaction tr; 
        forever begin
            drop= 0; 
            agt2drv.get(tr);
            foreach (cbs[i]) cbs[i].pre_tx(tr,drop); //预留回调函数入口
            if (drop) continue;    //跳转到入口
            transmit (tr);
            foreach (cbs[i]) cbs[i].post_tx(tr);  //预留回调函数入口
        end
    endtask 
endclass 
 
class  Driver_cbs_drop extends Driver_cbs; //定义回调函数
    virtual task  pre_tx(ref Transaction tr,ref bit drop );
    //  1/100 的传输事务丢弃概率
    drop=($urandom_range(0,99)==0);
    endtask
endclass
 
program automatic test;
    Environment env;
    initial begin
        env=new();
        env.gen_cfg();
        env.build();
        begin//创建回调对象并且植入driver
            Driver_cbs_drop dcd=new();
            env.drv.cbs.push_back(dcd);
        end
        end.run();
        env.wrap_up();
    end
endprogram

#### 1. uvm_call_back
### 2. 注意事项
### 3. 传送门
1. [SV--回调函数](https://blog.csdn.net/weixin_45680021/article/details/126195268)
