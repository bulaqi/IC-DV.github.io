### 1.查看磁盘空间
~~~
df -lh
~~~
### 2.如果是磁盘空间不足，则查找具体占用磁盘的文件
~~~
du -lh --max-depth=1
~~~
### 3.查看内存使用情况
~~~
free -m // -m内存单位为MB
~~~
当free值较小时，则要注意内存的使用，是否需要加内存

### 4.查看CPU使用情况
~~~
top

~~~
主要查看第三行CPU的使用情况

us, user：运行(未调整优先级的) 用户进程占用百分比
sy，system：运行内核进程占用百分比
ni，niced：运行已调整优先级的用户进程占用百分比
id，idle：空闲CPU百分比
wa，IO wait：用于等待IO完成占用百分比
hi：处理硬件中断的占用百分比
si：处理软件中断的占用百分比
st：这个虚拟机被hypervisor偷去的占用百分比
可用shift+p对进程使用CPU进行排序，找到CPU占用较高的进程
top命令还可以查看内存的使用情况，可用shift+m对进程使用内存情况进行牌型

### 5.查看IO使用情况
~~~
iostat -x 10   //每隔10s一次
~~~
该命令可以查看IO使用情况，也可以查看CPU占用情况
如果没有安装，可执行yum install -y sysstat安装

**CPU 属性值**\
- %user：运行(未调整优先级的) 用户进程占用百分比
- %nice：运行已调整优先级的用户进程占用百分比
- %system：运行内核进程占用百分比
- %iowait：用于等待IO完成占用百分比
- %steal：这个虚拟机被hypervisor偷去的占用百分比
- %idle：CPU空闲时间百分比

如果%iowait的值过高，表示硬盘存在I/O瓶颈，
%idle值高，表示CPU较空闲，
如果%idle值高但系统响应慢时，有可能是CPU等待分配内存，此时应加大内存容量。

%idle值如果持续低于10，那么系统的CPU处理能力相对较低，表明系统中最需要解决的资源是CPU

**磁盘属性值**\
- rrqm/s：每秒进行 merge 的读操作数目，即 rmerge/s
- wrqm/s：每秒进行 merge 的写操作数目，即 wmerge/s
- r/s：每秒完成的读 I/O 设备次数，即 rio/s
- w/s：每秒完成的写 I/O 设备次数，即 wio/s
- rsec/s：每秒读扇区数，即 rsect/s
- wsec/s：每秒写扇区数，即 wsect/s
- rkB/s：每秒读 K 字节数，是 rsect/s 的一半，因为扇区大小为 512 字节
- wkB/s：每秒写 K 字节数，是 wsect/s 的一半
- avgrq-sz：平均每次设备 I/O 操作的数据大小(扇区)
- avgqu-sz：平均 I/O 队列长度
- await：平均每次设备 I/O 操作的等待时间(毫秒)
- svctm：平均每次设备 I/O 操作的服务时间(毫秒)
- %util：一秒中有百分之多少的时间用于 I/O 操作，或者说一秒中有多少时间 I/O 队列是非空的

如果 %util 接近 100%，说明产生的I/O请求太多，I/O系统已经满负荷，该磁盘可能存在瓶颈。\
如果 svctm 比较接近 await，说明 I/O 几乎没有等待时间\
如果 await 远大于 svctm，说明I/O 队列太长，io响应太慢，则需要进行必要优化\
如果avgqu-sz比较大，也表示有当量io在等待

**若想看具体占用IO较高进程，可用iotop命令查看**
————————————————
版权声明：本文为CSDN博主「小小学编程」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/qq_35344198/article/details/98659317