### 1. 基础知识
- xhost 是用来控制X server访问权限的，这个命令将允许别的用户启动的图形程序将图形显示在当前屏幕上.。
- 你从hostA登陆到hostB上运行hostB上的应用程序时，做为应用程序来说，hostA是client,但是作为图形来说，是在hostA上显示的，需要使用hostA的Xserver,所以hostA是server.因此在登陆到hostB前，需要在hostA上运行xhost +，来使其它用户能够访问hostA的Xserver.
- 指令
~~~
xhost + 是使所有用户都能访问Xserver.
xhost + ip使ip上的用户能够访问Xserver.
xhost + nis:user@domain使domain上的nis用户user能够访问
xhost + inet:user@domain使domain上的inet用户能够访问。
~~~
- eg:
在2台Linux机器之间, 如果设置服务器端配置文件/etc/ssh/sshd_config中包含
X11Forwarding no
客户端配置文件/etc/ssh/ssh_config包含
ForwardX11 yes
则从客户端ssh到服务器端后会自动设置DISPLAY环境变量, 允许在服务器端执行的图形程序将图形显示在客户端上. 在服务器上查看环境变量显示如下(这个结果不同的时候并不相同)

### 2. 经验分享
#### 1. 报错:No protocol specified xhost: unable to open display
- [No protocol specified xhost: unable to open display](https://www.cnblogs.com/vzhangxk/p/11220385.html)
#### 2. xhost 命令
- 用途控制什么人可以访问当前主机上的增强 X-Windows。
- 语法
~~~
xhost [ + | - ] [ Name ]
"+"表示增加，"-"表示去除
xhost + ip （name表示该ip机器可以使用该服务）
~~~
- 描述:xhost 是用来控制X server访问权限的



### 3. 传送门
1. [在Linux下实现弹窗处理](https://xueying.blog.csdn.net/article/details/97235617?spm=1001.2014.3001.5502)
2. [Linux 中 DISPLAY 环境变量设置——本地显示 Linux 服务器GUI程序](https://blog.csdn.net/qq_37698947/article/details/122361495)
3. [linux 下设置display变量](https://wenku.csdn.net/answer/20b8aff9044b4f58940e25d80a4021f3#:~:text=linux%E8%AE%BE%E7%BD%AEX11%20DISPLAY%E5%8F%98%E9%87%8F%201%20%E6%89%93%E5%BC%80%E7%BB%88%E7%AB%AF%E7%AA%97%E5%8F%A3%E3%80%82%202%20%E8%BE%93%E5%85%A5%E4%BB%A5%E4%B8%8B%E5%91%BD%E4%BB%A4%E6%9D%A5%E6%9F%A5%E7%9C%8B%E5%BD%93%E5%89%8D%E7%9A%84%20DISPLAY%20%E5%8F%98%E9%87%8F%E8%AE%BE%E7%BD%AE%EF%BC%9A,%E5%86%8D%E6%AC%A1%E8%BF%90%E8%A1%8C%E4%BB%A5%E4%B8%8B%E5%91%BD%E4%BB%A4%E6%9D%A5%E6%A3%80%E6%9F%A5%20DISPLAY%20%E5%8F%98%E9%87%8F%E6%98%AF%E5%90%A6%E5%B7%B2%E6%AD%A3%E7%A1%AE%E8%AE%BE%E7%BD%AE%EF%BC%9A%20echo%20%24DISPLAY%20%E5%A6%82%E6%9E%9C%E8%BE%93%E5%87%BA%E4%B8%8E%E4%BD%A0%E6%89%80%E8%AE%BE%E7%BD%AE%E7%9A%84%E7%9B%B8%E5%90%8C%EF%BC%8C%E5%88%99%E8%AF%B4%E6%98%8E%20DISPLAY%20%E5%8F%98%E9%87%8F%E5%B7%B2%E6%AD%A3%E7%A1%AE%E8%AE%BE%E7%BD%AE%E3%80%82)
4. [xhost 命令用途](https://blog.csdn.net/li19236/article/details/42213017)
5. [完美解决xhost +报错： unable to open display ""](https://blog.csdn.net/wojiuguowei/article/details/79201845)
6. [xhost 原理](https://www.cnblogs.com/js1314/p/10373332.html)
