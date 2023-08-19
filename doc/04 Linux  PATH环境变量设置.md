### 1 .基础知识 
#### 1. 控制台中设置，不赞成这种方式，因为他只对当前的shell 起作用，换一个shell设置就无效了,对所有的用户的都起作用的环境变量
直接控制台中输入 ： $PATH="$PATH":/NEW_PATH  (关闭shell Path会还原为原来的path)
#### 2.修改bashrc文件，这种方法更为安全，它可以把使用这些环境变量的权限控制到用户级别，这里是针对某一特定的用户，如果你需要给某个用户权限使用这些环境变量，你只需要修改其个人用户主目录下的 .bashrc文件就可以了
~~~
vi /etc/profile
~~~
在/etc/profile的最下面添加：  export  PATH="$PATH:/NEW_PATH"

#### 3. 修改bashrc文件，这种方法更为安全，它可以把使用这些环境变量的权限控制到用户级别，这里是针对某一特定的用户，如果你需要给某个用户权限使用这些环境变量，你只需要修改其个人用户主目录下的 .bashrc文件就可以了
~~~
vi ~/.bashrc
~~~
在下面添加：
~~~
Export PATH="$PATH:/NEW_PATH"
~~~
### 传送门
1. [Linux系统设置PATH环境变量(3种方法)](https://www.nhooo.com/note/qa34st.html)
