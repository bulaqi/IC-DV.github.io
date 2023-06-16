### 1. 前言
在Linux中，当同一款编辑器、运行库、软件存在多个版本且多个版本都需要在不同的场景或人员使用时，配置这些内容的环境变量是一个非常繁琐的过程，而Moudle工具则提供了一个简单快速的方法，Moudle全称为module-environment，是一个专门管理环境变量的工具。
### 2. 官网
Moudle官网：https://modules.readthedocs.io/en/latest/module.html
### 3. 安装
Moudle工具是基于TCL（8.4以上版本）工具的，目前module工具为4.4.1，基于tcl8.5或更高版本，而module3.X版本则基于tcl8.4版本，Redhat6系列yum安装的tcl为8.5版本。\
Moudle工具可以使用二进制编译安装，也可以使用yum/apt快速安装，\
Redhat/Centos使用：yum install environment-modules；\
ubuntu等使用：apt-get install environment-modules安装
### 4. 初始化
安装module工具后，你会发现它并不是一个可执行的二进制文件，你需要对module工具进行一次初始化。\
在/usr/share/modules/init(注意此处，可能是module也可能是modules)内部你可以找到针对各个脚本的二进制初始化文件，找到你当前的脚本，source这个二进制文件，例如你是bash脚本，source /usr/share/modules/init/bash之后，你就可以使用module工具了。
### 5. 基本命令 (通过命令你可以看出我为什么module和modules傻傻不分了）
- module avail显示可以使用的模块
- module load/add 加载模块
- module unload/rm卸载模块
- module list显示已经加载的模块
-在整个module都配置好后，这四个命令基本上可以满足所有的使用要求，而module的更多详细命令和使用方法，我们会在以后的文章中说明。

### 6. 工具的使用
Module工具依托于MODULEPATH这个环境变量来查找配置信息目录，也就是说你在设置好目录结构，配置好环境变量后，只需要设置这一个module的环境变量，那么module工具就会自动去查找这个路径下的所有配置信息。
### 7. modulefiles文件编写
在第六节我们说了MODULEPATH的作用，那么这节我们讲述一下modulefile也就是配置文件的目录结构和写法。\
通常我们会将同一类的软件、库等内容放在同一个目录，假设目录名为/soft，在soft目录下包含gcc、python、java等常用工具，而gcc又包含4.8.4、4.9.3、4.9.7三个版本，python包含2.7、3.6两个版本、java包含1.6、1.7、1.8三个版本，那么它的目录结构如下：\
![image](https://user-images.githubusercontent.com/55919713/236455447-850e7959-258a-42b7-8aea-d50a4d045242.png)\
那么soft目录即为MODULEPATH变量设置的目录，最后面的版本文件为modulefile，我们只需要安装这种目录格式创建目录和文件即可。\
在编写modulefile文件时的几个注意事项，例如我要编写4.8.4这个文件，注意，这个文件时gcc4.8.4的环境变量配置文件，不是gcc的存放路径。它必须是一个文件、而不是一个文件夹。
#### 7.1 在文件开头一定要写上
~~~
#%Module1.0
~~~
这个是识别这个文件为modulefile的，没有他这个文件不会被识别
#### 7.2 prepend-path要修改的环境变量路径
这个命令会把工具路径添加到环境变量的前面
#### 7.3 setenv 环境变量名 值
这个命令会把你需要的环境变量配置到系统中\
请看以下示例：gcc/4.8.4 （这个工具我安装在/software/gcc/4.8.4/下）
~~~
#%Module1.0
setenv GCC_HOME /software/gcc/4.8.4/
prepend-path PATH /software/gcc/4.8.4/bin
~~~
这就是一个gcc4.8.4的环境变量配置，我们将所有的环境变量配置好之后，使用modue avail命令即可查看到相应信息，如下所示：\
![image](https://user-images.githubusercontent.com/55919713/236456314-84ad970a-c83c-40b3-809d-a885aa8ee2e2.png) \
使用module load 载入相应的工具和版本\
![image](https://user-images.githubusercontent.com/55919713/236456360-236302ab-f35c-4030-85f1-9336cf8e9f3a.png)\
使用module list查看载入的工具和版本 \
![image](https://user-images.githubusercontent.com/55919713/236456419-893c69e4-bd49-417f-b9ea-48a30affd478.png)\
使用module show 工具/版本 来查看相应配置信息（非常用命令）\
![image](https://user-images.githubusercontent.com/55919713/236456455-2020d449-a898-4ba7-a3c4-1e514d3f479c.png)\
这时候我们可以echo $PATH来查看是否将gcc路径添加到了PATH路径中\
![image](https://user-images.githubusercontent.com/55919713/236456509-b5181c93-97a4-4110-ac04-7439636e4563.png)\
使用echo $GCC_HOME查看是否已经设置好此环境变量\
![image](https://user-images.githubusercontent.com/55919713/236456542-1c53b14d-d992-46c8-a590-c7b41c178c5d.png)\
这时候代表你的目录设置、modulefile都没有问题，只要软件/工具等存放的路径没有问题，那么即可正常使用。

### 8. 多路径
MODULEPATH可以设置为多个路径，例如我设置/soft、/soft1、/soft2都是工具、软件等脚本的存放路径，那么我就可以设置MODULEPATH为多个路径，路径之间用冒号分割。\
![image](https://user-images.githubusercontent.com/55919713/236456611-62bfc35f-3d62-40bc-9ba6-d64d2c42bf22.png)\
这时候我们module avail来查看信息，即可看到如下\
![image](https://user-images.githubusercontent.com/55919713/236456647-26d3b2c3-a141-4b21-9b50-438dc44871c6.png)\
注意：千万不要出现软件名和版本一样的modulefile
### 9.默认版本
在module avail中，我们可以设置默认版本，例如我想将gcc 4.9.3设置为默认版本，当我module load gcc的时候，就直接载入4.9.3版本，我们可以使用.version文件来控制这个默认信息。

在modulefile同级目录下创建.version文件，看清楚，前面有个点，写法如下
~~~
#%Module1.0
set ModulesVersion "4.9.3"
~~~
![image](https://user-images.githubusercontent.com/55919713/236456756-49f2114b-e424-4944-bf93-6c9d4b2469d7.png)\
使用module avail查看信息\
![image](https://user-images.githubusercontent.com/55919713/236456817-33880582-2b95-4b09-a016-b2edd43ee6a0.png)\
在4.9.3版本后面多了一个（default）\
删除我们刚才载入的4.8.4\
![image](https://user-images.githubusercontent.com/55919713/236456878-be0c6fdf-f52b-4a6e-90a4-c3035c85c0c6.png)\
载入默认的gcc版本\
![image](https://user-images.githubusercontent.com/55919713/236456927-a0d0454c-758b-470c-8f20-de09d62e26d9.png)\
注意：由于moudle只能载入同类工具、库的某一个版本，删除的时候就直接说明删除的工具、库就可以了，后面不需要带版本号。

### 10.全局控制
由于module的特性问题，如果在公司内使用，你可能需要所有的使用人员设置一个统一的初始脚本，无论是bash还是csh，通常我们建议建立一个用户可读的统一脚本文件，然后link到每个使用人员的家目录下的初始脚本。\
例如我们建立为csh建立一个统一的csh.cshrc文件。Link给zhangsan\
~~~
ln -s csh.cshrc /home/zhangsan/.cshrc
~~~
我们可以在统一的初始脚本中加入source ./cshrc.own \
那么用户只需要在家目录创建一个cshrc.own的文件所谓个性化脚本文件即可

### 工作中常用命令
- module av regel
- module load regel
- moduel list
### 参考
[linux中module工具的使用介绍](https://blog.csdn.net/Michael177/article/details/121152904)
[Linux下Moudle工具的介绍与使用](https://blog.csdn.net/xiaoxiaole0313/article/details/105283411)
