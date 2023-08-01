### 1.hdl_path背景
在进行寄存器模型的后门操作时,必须提前设置后门操作路径,register model才能工作(访问design内部寄存器的前提是获取到它);

### 2.register的hdl_path/rtl路径组成
-  reg的base path/block的路径
-  reg本身自己的相对路径(reg的offset_path);
  
#### 1. reg的base path/block的路径;
1. 该path定义在reg所在的block中,也叫block路径;
2. uvm_reg_block中有两个变量可以用来存放block路径,分别为:
   ~~~
   1. root_hdl_paths:
      1.1 string root_hdl_paths[string],
      2.2 通过 set_hdl_path_root 函数进行hdl_path信息的存储;
   2. hdl_paths_pool:
      2.1 uvm_object_string_pool #(uvm_queue#(string)) hdl_paths_pool,
      2.2 通过 add_hdl_path 函数进行hdl_path信息的存储
   ~~~
3. block路径是什么?
   - root_hdl_path: 如果设置了root_hdl_path,那么就是root_hdl_path; 
   - hdl_paths_pool: 如果没有设置,那就是hdl_paths_pool里的信息(详见uvm_reg_block的get_full_hdl_path函数);
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/852de23b-9015-43cc-8054-ab37b15f4721)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/ddd1babb-0b88-41aa-b144-e4eabe619de7)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/b7dc43a2-e7d1-4514-a209-2ab98e2fc99e)

#### 2. reg本身自己的相对路径(reg的offset_path);
1. uvm_reg类中有一个变量m_hdl_paths_pool用于保存reg自身设置的相对路径(通过调用add_hdl_path_slice设置相对路径); 
2. reg的绝对路径为base_path+offset_path;
3. 举例: reg_blk,add_hdl_path("tb"), reg1.add_hdl_path_slice("reg_boot"),最终reg1的绝对路径时tb.reg_boot(实际硬件中路径);
   
### 2. hdl path的指定方法
#### 1. 概述
- uvm_reg_block::configure()与uvm_reg_block::add_hdl_path();
- uvm_reg_file::configure()与uvm_reg_file::add_hdl_path();
- uvm_reg::configure()与uvm_reg::add_hdl_path_slice();
- uvm_mem::configure()与uvm_mem::add_hdl_path_slice

#### 2. uvm_reg_block-add_hdl_path
1. 可以在调用user-defined uvm_reg_block的configure函数时指定hdl路径;
   ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/997579a0-3deb-4161-a86e-64a797b861c8)

3. add_hdl_path可以放置在user-defined uvm_reg_block的build函数内调用;可以通过调用add_hdl_path,添加多个hdl路径;
   ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/83cf363d-3998-4506-a36f-38dba8a9b92b)

4. add_hdl_path函数内的hdl_paths_pool.get("RTL")返回一个关联数组pool中索引为"RTL"的元素所对应的键值uvm_queue#(string);接着,往uvm_queue#(string)中push一个元素-path,也就是hdl path;
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/22ffccd9-cc9f-4d72-a0f0-f86c290821a0)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/c24bdde8-7d0d-4e82-8c78-d44b9da200ec)

   
#### 3. uvm_reg-add_hdl_path_slice
1. add_hdl_path_slice可以放置在user-defined uvm_reg的build函数内调用;
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/d8aebc1c-f01e-4f5d-8aa1-1131a4c5e144)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/9cfee683-d0fd-43b9-aea3-32c7bea574df)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/1cb5d4de-349a-43da-96b6-f8609c0d33ee)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/dae195b4-ef5b-4f08-9b43-69ee24105aaa)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/36e6fa2e-d612-4353-9e97-0a32300866b2)


#### 4.  uvm_reg_block-get_full_hdl_path
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/dbd80f8e-8e43-4ffd-8272-1dd3e49d0288)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/fcb97ca6-59c6-4cef-a84c-4a4f4a3817c4)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/9efc2283-1e8e-45ad-9a45-8f7e8c10b233)
- ![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/8976672f-2c43-403d-a973-6500e407a149)


### 3. 传送门
1. [hdl_path简介](https://www.cnblogs.com/csjt/p/15252851.html)
