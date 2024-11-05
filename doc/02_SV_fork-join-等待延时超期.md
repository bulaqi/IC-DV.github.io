### 1. 基本概念
fork join 等待延时超期
![image](https://user-images.githubusercontent.com/55919713/230804569-92c37201-77f1-4f09-8426-afdc40eaa58d.png)

### 2. 注意事项
在#wait 行，需要注意，VCS编译需要用begin end 括起来，否则没有参与读寄存器过程，原因待分析
