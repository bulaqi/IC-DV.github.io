
### 0. eg.说明
![image](https://user-images.githubusercontent.com/55919713/221829352-a6b59353-4e41-4f8c-9fb8-dff4d56e57c5.png)

### 1. 概述
#### 1. config_db的set和get函数都有四个参数，这两个函数的第三个参数必须完全一致。  
#### 2. set函数
  1. 第四个参数表示要将哪个interface通过config_db传递给my_driver，get函数的第四个参数表示把得到的interface传递给哪个my_driver的成员变量。   
  2. set函数的第二个参数表示的是路径索引，即在2.2.1节介绍uvm_info宏时提及的路径索引。在top_tb中通过run_test创建了一个my_driver的实例，那么这个实例的名字是什么呢？答案是uvm_test_top：UVM通过run_test语句创建一个名字为uvm_test_top的实例。
  3. 在top_tb中通过config_db机制的set函数设置virtual interface时， set函数的第一个参数为null。 在这种情况下，
UVM会自动把第一个参数替换为uvm_root： ： get（ ） ， 即uvm_top。 换句话说， 以下两种写法是完全等价的：
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/3f1c53fb-d703-4c0a-97f2-924bcdbc7346)

#### 3. get函数
  1. 第一个参数和第二个参数联合起来组成路径。
  2. 第一个参数也必须是一个uvm_component实例的指针，
  3. 第二个参数是相对此实例的路径。 一般的， 如果第一个参数被设置为this， 那么第二个参数可以是一个空的字符串。
  4. 第三个参数就是set函数中的第三个参数， 这两个参数必须严格匹配，
  5. 第四个参数则是要设置的变量。
     
### 2. 备注：
- set函数与get函数让人疑惑的另外一点是其古怪的写法。使用双冒号是因为这两个函数都是静态函数。  
- 而uvm_config_db#（virtual my_if）则是一个参数化的类，其参数就是要寄信的类型，这里是virtual my_if。
