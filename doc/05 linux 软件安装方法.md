### 1.基础知识
#### 1. 软件包分类
##### 1. 源包
1. what:
  指C语言开发的源代码文件的一个压缩包（.tar.gz或.tar.bz2）。源码包的编译使用Linux系统里的编译器gcc，利用该编译器可以把源码包变成可执行的二进制文件
##### 2. 二进制包
1. 分类(RPM包 vs DPKG包)
   - RPM包： Red Hat开发的包管理系统。CentOS、Redhat、Fedora等。软件包文件后缀是".rpm"
   - DPKG包: Debian Linux开发出来的包管理机制，主要应用在Debian和Unbuntu系统中。软件包文件后缀是".deb"
2. 依赖
   - 是RPM包管理器还是DPKG包管理器，都存在软件包依赖问题
   - 解决方案:提供在线安装方式
4. 在线安装方式:
   基于RPM包 -->管理机制开发出了YUM在线安装机制;
   基于DPKG包-->管理机制开发出了APT在线安装机制
##### 3. 其他包管理器
pip --> pip 是 Python 包管理工具，该工具提供了对Python 包的查找、下载、安装、卸载的功能
npm --> NPM是随同NodeJS一起安装的包管理工具,允许用户从NPM服务器下载别人编写的第三方包到本地使用
brew --> 是MacOS上的包管理工具，可以简化 macOS 和 Linux 操作系统上软件的安装

### 2.注意事项
### 3. 传送门
1. [CentOS 7安装软件的三种方式（RPM、YUM、源码包)](https://blog.csdn.net/hawava/article/details/116275103)
