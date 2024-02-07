### 1.分类
- 单行宏：  
![image](https://user-images.githubusercontent.com/55919713/229826591-ece43aa8-114b-4de9-b2f7-7ad00a2f259f.png)

- 多行宏： \ 连接多行，最后一行没有\
![image](https://user-images.githubusercontent.com/55919713/229826621-fb4dc792-485c-4942-b7a6-b566b96f13e0.png)  
注意：在行尾的反斜杠“ \ ”之后不能有空格或字符，否则编译器会报错。

### 2.建议使用宏的一种可能方法：
- 你和你的团队成员建立一个宏库。
- 为该库中的宏使用命名约定，例如 <*>_utils（print_byte_utils，等）。
- 将其放在一个名为macro_utils.sv的文件中，并将其include到base package中。
- 在适当的情况下使用这些宏，而不是重复代码，成为您的验证方法论的一部分。

### 3. 语法
- 宏名称  
    宏名称的唯一规则是您可以使用除编译器指令以外的任何名称，即，`define, `ifdef, `endif, `else, `elseif, `include等关键字不能使用。 

- 宏定义符号名称:反引号和引号 + 双反引号 + 反斜杠，反引号和双引号  
   1. ` ” (Backtick and Quotes)反引号和引号\
![image](https://user-images.githubusercontent.com/55919713/229828866-f869e66b-d149-47fc-9492-0c04b56ec984.png)
![image](https://user-images.githubusercontent.com/55919713/229828892-e2f43f0a-41de-4f26-8e1e-e337bcaace6d.png)  
~~~
   `append_front_bad-接受一个参数MOD，期望宏将导致两个字符串MOD和".master"的连接。但是由于使用双引号，输出结果是字符串“MOD.master”，参数没有被替换。

   `append_front_good-这是`append_front_bad的正确版本。通过在双引号前使用反勾号，我们告诉编译器在宏被展开时必须替换参数MOD。
~~~

   2. `` （Double Backtick）双反引号  
      ``本质上是分隔符标记，它帮助编译器清楚地区分宏文本中的参数和字符串的其余部分。
![image](https://user-images.githubusercontent.com/55919713/229829751-4ac88f63-dcd8-4f9b-a199-9aa7c98f9e9d.png)
![image](https://user-images.githubusercontent.com/55919713/229829938-5bb21f9c-2d42-4f8d-841b-1da05ec8292e.png)
![image](https://user-images.githubusercontent.com/55919713/229829970-1668cb8c-304d-4fa8-8064-21c9c3b22376.png)  
我们可以看到ARG1 = 3用于形成变量的名称。（即m_mst_3和mst_3_lcl）

     几个例子综合理解` ”和``的作用。
![image](https://user-images.githubusercontent.com/55919713/229830110-bd8d70ac-8eda-443e-bc0b-c1d6b14743ae.png)
![image](https://user-images.githubusercontent.com/55919713/229830133-09a47fef-26b9-4fd9-965e-991e474159c3.png)
~~~
append_front_2a and 2b-空格字符（' '）和句点字符（'.'）是自然标记定界符，即，编译器可以清楚地标识宏文本中的参数。
`append_front_2c_bad-如果参数附加了非空格或非句点字符，例如`"MOD_master`"中的下划线'_'，则编译器将无法确定参数字符串的MOD结尾。
在`append_front_2c_good中``创建一个在MOD和之间的定界符_master，这就是为什么MOD要正确标识和替换的原因。
`append_middle还有`append_end另外两个示例展示了这一点。
`append_front_3-可以``在自然标记定界符（即空格或句点）之前或之后放置一个，但这没有效果。// 个人表示怀疑，可以测试下
~~~

   3. `\`" （Slashes, Ticks and Quotes）反斜杠，反引号和双引号  
![image](https://user-images.githubusercontent.com/55919713/229833664-0e172dd1-dadf-42d9-bce0-63afba0cf968.png)
![image](https://user-images.githubusercontent.com/55919713/229833702-5ffc3bd2-13bf-4521-868e-459b9f9d5bf9.png)  

   4. 其他  
    - 您可以在宏中调用宏。
    - 允许在宏中使用注释，这没有什么不同。
    - fdef也允许在宏定义中使用，对此也没有什么不同
   5. 传递Args  
     注意事项:
~~~
    1.参数可以具有默认值。 \
    2.您可以通过将该位置保留为空来跳过参数，即使该位置没有默认值也是如此。请参阅``test2(,,)`示例2中显示的内容。  
    3.查看``debug1`并``debug2`。如果您的参数是一个字符串，则是否需要将参数括在双引号中的决定取决于该参数在宏文本中的替换位置。在中``debug1`，MODNAME在宏文本中的引号内，因此program-block在调用宏时我没有将字符串括在引号中。而``debug2`传递的参数是"program-block"因为MODNAME在宏文本中出现在引号之外。 \ 
~~~
![image](https://user-images.githubusercontent.com/55919713/229834749-5451c2c9-cdfa-4316-8cc2-0ec75dc4c20e.png)
![image](https://user-images.githubusercontent.com/55919713/229834785-b6ab3f2c-1205-425b-9214-afb4f15aea80.png)



   6. 宏的风格指南  
     - 如果使用宏定义a function或task使用大写宏名称和小写参数名称。
     - 如果使用宏定义class，代码片段等等-使用小写宏名和大写参数名称。
     - 宏名称中的单词用下划线分隔。
   
   7. 语法总结   
     - 整个团队遵循编码风格一致性。 \
     - 定义函数和任务的宏使用大写宏名称和小写宏参数。\
     - 使用带下划线的单词。\
     - 使用小写宏名称和大写其他所有参数定义例如类，代码段等宏。\
     - 在使用宏时要谨慎，过度使用可能会使代码不可读。\
     - 知道`", ``和 `\ 符号的作用。\
     - 宏定义是全局的。在类中定义宏并不意味着它仅对该类可见。\
     - 在编译log中当心宏重新定义警告。\
     - 编写宏时，请使用本文中的示例作为参考\
 
### 3. 示例
#### 1.宏对于覆盖点(Coverpoint)的用法  \
如果设计验证工程师想要覆盖具有相同宽度的多个变量的walk0 / walk1库(bins)，则他/她可以为需要的walk1 / walk0覆盖库(bins)中的所有此类信号创建并使用宏。\ 
- 宏定义：\
![image](https://user-images.githubusercontent.com/55919713/229835977-50faba10-6d24-4124-a38a-0b561b70c222.png)   
- 宏用法：\
![image](https://user-images.githubusercontent.com/55919713/229836053-7a7bc3ea-c48a-4cdf-a800-2d9755348b80.png)  

#### 2.宏对于覆盖组(Covergroup)的用法  
在验证项目中，很多时候需要在不同的地方编写相同的覆盖范围，例如，在主(master)组件和从属(slave)组件中编写相同的代码。我们可以为覆盖组(Covergroup)定义可以在所有此类组件中使用的通用宏 \
宏定义:\
![image](https://user-images.githubusercontent.com/55919713/229836249-e5001bb8-300c-4274-ae03-a3d25835700f.png) \
宏用法：\
![image](https://user-images.githubusercontent.com/55919713/229836306-700663ef-02c4-4c52-b335-ac5c8fd7bc59.png)  \
"STRING"是"bus_cg_macro"宏的参数。无论在何处使用宏，都应考虑"STRING"参数来替换覆盖组(Covergroup)、覆盖点(Coverpoints)及其库(bins)。  

#### 3.宏在sv断言(Assertion)中的用法  
需要检查在主(master)和从(slave)中，如果不存在复位，则信号值在每个时钟周期都保持变化。我们可以定义一个宏并将其同时用于主(master)和从(slave) \
宏定义：\
![image](https://user-images.githubusercontent.com/55919713/229836501-50f241e9-e665-49b2-978c-6d738bf8a80d.png)
宏用法：\
![image](https://user-images.githubusercontent.com/55919713/229836535-bcec07db-abdf-4170-8e51-da22e0d4220c.png)   \

#### 4.宏在测试案例中的用法
在自检寄存器的写/读测试中，每次读取后，都会根据预期的读取数据检查读取值。考虑到设计的复杂性，我们可能有多个模块，并且对于每个模块，我们可能都有相应的寄存器测试。对于每个此类测试，我们都可以使用一个通用的宏进行自我检查 \
自检宏：\
![image](https://user-images.githubusercontent.com/55919713/229836736-96fc41f3-c239-483e-97a1-d90156052415.png)
宏用法：\
![image](https://user-images.githubusercontent.com/55919713/229836781-50a49d68-8a94-41d1-a318-7def40796b0f.png)


#### 5.宏在程序块中的用法  
用于覆盖多个地方相同的程序块代码的宏。  
程序块的宏：\
![image](https://user-images.githubusercontent.com/55919713/229836862-4e8ce5fb-252a-4d20-8833-2d5c9d36534c.png)   
宏用法：\
![image](https://user-images.githubusercontent.com/55919713/229836929-16e981f7-8325-4321-ac44-bc9ab2ff39bf.png)  


### 4. 参考
  https://blog.csdn.net/weixin_42905573/article/details/109006871