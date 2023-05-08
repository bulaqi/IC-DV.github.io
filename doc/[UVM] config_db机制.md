
![image](https://user-images.githubusercontent.com/55919713/221829352-a6b59353-4e41-4f8c-9fb8-dff4d56e57c5.png)


config_db的set和get函数都有四个参数，这两个函数的第三个参数必须完全一致。  
set函数的第四个参数表示要将哪个interface通过config_db传递给my_driver，get函数的第四个参数表示把得到的interface传递给哪个my_driver的成员变量。   
set函数的第二个参数表示的是路径索引，即在2.2.1节介绍uvm_info宏时提及的路径索引。在top_tb中通过run_test创建了一个my_driver的实例，那么这个实例的名字是什么呢？答案是uvm_test_top：UVM通过run_test语句创建一个名字为uvm_test_top的实例。  

备注：
set函数与get函数让人疑惑的另外一点是其古怪的写法。使用双冒号是因为这两个函数都是静态函数。  
而uvm_config_db#（virtual my_if）则是一个参数化的类，其参数就是要寄信的类型，这里是virtual my_if。