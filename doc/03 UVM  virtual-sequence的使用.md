![image](https://user-images.githubusercontent.com/55919713/223030949-4c41b899-a9a1-4c0f-9bcf-d45610910918.png)   

为了使用virtual sequence， 一般需要一个**virtual sequencer**。 virtual sequencer里面包含指向其他真实sequencer的指针：
![image](https://user-images.githubusercontent.com/55919713/223041640-6aee7d46-9fa9-4533-88b9-36478652fce4.png)   

在base_test中， 实例化vsqr， 并将相应的sequencer赋值给vsqr中的sequencer的指针：
![image](https://user-images.githubusercontent.com/55919713/223042063-2c4b236e-f278-49ee-a793-03c7f32b011e.png)     

在virtual sequene中则可以使用uvm_do_on系列宏来发送transaction：
![image](https://user-images.githubusercontent.com/55919713/223042614-e9474405-2909-4214-ac7c-c59e444f833f.png)        
在case0_vseq中， 先使用uvm_do_on_with在p_sequencer.sqr0上发送一个最长包， 当其发送完毕后， 再启动drv0_seq和drv1_seq。 这里的drv0_seq和drv1_seq非常简单， 两者之间不需要为同步做任何事情：
   
![image](https://user-images.githubusercontent.com/55919713/223040675-d64b440a-aa88-4f93-982f-901b11370224.png)   

在使用uvm_do_on宏的情况下， 虽然seq0是在case0_vseq中启动， 但是它最终会被交给p_sequencer.p_sqr0， 也即env0.i_agt.sqr 而不是v_sqr。 这个就是virtual sequence和virtual sequencer中virtual的来源。 它们各自并不产生transaction， 而只是控制其他的sequence为相应的sequencer产生transaction。   

**virtual sequence和virtual sequencer只是起一个调度的作用。 由于根本不直接产生transaction， 所以virtual sequence和virtual sequencer在定义时根本无需指明要发送的transaction数据类型。**
如果不使用uvm_do_on宏， 那么也可以手工启动sequence， 其效果完全一样。 手工启动sequence的一个优势是可以向其中传递一些值：  
![image](https://user-images.githubusercontent.com/55919713/223040792-d9566afb-02ad-416a-91ab-76d77002dbe0.png)     

在read_file_seq中， 需要一个字符串的文件名字， 在手工启动时可以指定文件名字， 但是uvm_do系列宏无法实现这个功能，因为string类型变量前不能使用rand修饰符。 这就是手工启动sequence的优势。   

在case0_vseq的定义中， 一般都要使用uvm_declare_p_sequencer宏。 这个在前文已经讲述过了， 通过它可以引用sequencer的成员变量。

**回顾一下**，为了解决sequence的同步， 之前使用send_over这个全局变量的方式来解决。 那么在virtual sequence中是如何解决的呢？ 事实上这个问题在virtual sequence中根本就不是个问题。 由于virtual sequence的body是顺序执行， 所以只需要先产生一个最长的包， 产生完毕后再将其他的sequence启动起来， 没有必要去刻意地同步。 这只是virtual sequence强大的调度功能的一个小小的体现。   

virtual sequence的使用可以减少config_db语句的使用。 由于config_db::set函数的第二个路径参数是字符串， 非常容易出错，所以减少config_db语句的使用可以降低出错的概率。 在上节中， 使用了两个uvm_config_db语句将两个sequence送给了相应的sequencer作为default_sequence。 假如验证平台中的sequencer有多个， 如10个， 那么就需要写10个uvm_config_db语句， 这是一件很令人厌烦的事情。 使用virtual sequence后可以将这10句只压缩成一句：  

![image](https://user-images.githubusercontent.com/55919713/223040861-60c44dec-5f2c-43b3-8355-66ca8fe205a0.png)  


