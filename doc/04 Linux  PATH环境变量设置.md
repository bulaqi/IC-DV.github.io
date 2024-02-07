### 1 .基础知识 
#### 1. 控制台中设置，
- 不推荐，只对当前的shell 起作用，换一个shell设置就无效了,对所有的用户的都起作用的环境变量
- 直接控制台中输入 ： $PATH="$PATH":/NEW_PATH  (关闭shell Path会还原为原来的path)
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

### 2 . export VS setenv vs set
1. #### export
   - export PATH = $PATH: 目录 修改环境变量， 修改一般只进行追加。不进行原来的内容去掉
   - 可以通过重启终端来恢复PATH
   - 修改这个文件~/.bashrc 能够让环境变量持久生效
     
2. #### setenv
   - 利用env命令查看 Linux 系统 中的环境变量
   - 作为setenv函数,作用：增加或者修改环境变量
   - setenv的影响范围范围: 通过此函数并不能添加或修改 shell 进程的环境变量，或者说通过setenv函数设置的环境变量只在本进程，而且是本次执行中有效。如果在某一次运行程序时执行了setenv函数，进程终止后再次运行该程序，上次的设置是无效的，上次设置的环境变量是不能读到的。
   - 语法 setenv [变量名称] [变量值]
   - setenv修改环境变量, 环境变量可传递给子shell. setenv有点类似于bash中export一个变量
   - unsetenv 变量名 取消设置,不需要$符号修饰
3. #### set,尽量选择setenv
   - set来定义局部变量, 使用setenv可以定义环境变量，局部变量只对本shell有效, 不能传递给子shell，
   
### 传送门
1. [Linux系统设置PATH环境变量(3种方法)](https://www.nhooo.com/note/qa34st.html)
2. [Linux中环境变量的设置——setenv/export](https://blog.csdn.net/qq_41595735/article/details/90239159)
3. [linux配置csh设置环境变量](https://blog.csdn.net/matchbox1234/article/details/107822693)

