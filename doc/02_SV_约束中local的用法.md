### 1. 基础
- 在使用内嵌约束randomize（）with {CONSTRAINT}时，约束体中的变量名的查找顺序默认是从被随机化对象开始查找，但如果调用randomize（）函数局部域中也有同名变量，那就需要使用local::来显式声明**该变量来源于外部函数**，而非被随机化的对象（在约束中也可用this/super来索引这些变量）

- 但如果调用randomize（）函数局部域中也有同名变量，那就需要使用local::来显式声明该变量来源于外部函数，而非被随机化的对象（在约束中也可用this/super来索引这些变量）
### 2. 示例
~~~
class chnl_generator;
    rand int pkt_id = -1;
    rand int ch_id = -1;
    rand int data_nidles = -1;
    rand int pkt_nidles = -1;
    rand int data_size = -1;
    rand int ntrans = 10;
    constraint cstr{
      soft ch_id == -1;
      soft pkt_id == -1
      soft data_size == -1;
      soft data_nidles == -1;
      soft pkt_nidles == -1;
      soft ntrans == 10;

      task send_trans();
          chnl_trans req, rsp;
          req = new();
          assert(req.randomize with {local::ch_id >= 0 -> ch_id == local::ch_id; //此处local::id指来自chnl_generator的ch_id
                                 local::pkt_id >= 0 -> pkt_id == local::pkt_id;
                                 local::data_nidles >= 0 -> data_nidles == local::data_nidles;
                                 local::pkt_nidles >= 0 -> pkt_nidles == local::pkt_nidles;
                                 local::data_size >0 -> data.size() == local::data_size; 
                               })
      endtask
endclass

~~~

### 3. 分析：
data表示变量：
- 当task没有传递参数时，local::data表示chnl_generator::data
- 当task有传递参数时，local::data表示任务传递进来的参数
- local:: 表示“域”，而不是句柄，可以用local::this表示调用randmize() 函数的对象句柄。
约束体with{约束}中的变量名查找顺序默认是从被随机化对象开始查找。如果调用randomize()函数局部域中也有同名变量，那就需要使用 local:: 来显式声明该变量来源于外部函数，而非被随机化的对象。



### 4. 参考
 [sv 约束中的local用法](https://blog.csdn.net/sinat_41774721/article/details/122328741)