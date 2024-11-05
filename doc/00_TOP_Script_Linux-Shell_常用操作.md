### 0. lsof lsof(list open files)可以列出当前系统中进程打开的所有文件
  - lsof +D .// 列出当前目录下打开的文件

### 1. moudle的使用
### 2. 查找某文件名后删除： find ../tc -name "icrun.cfg" -delete
### 3. linux sed命令 批量替换目录下的所有文件
#### 1. 批量查找某个目录下包含待查找内容的行并显示查找内容在所在文件中的行号，例如：
~~~
grep -rn "要查找的文本" ./    //-r：递归查找子目录中的文件
grep -rn "dist_cq_rm" --include "*.sv" ./  //-r：递归查找子目录中sv的文件 // 推荐
~~~
#### 2. 批量查找并替换当前目录下的文件内容
~~~
sed -i "s/要查找的文本/替换后的文本/g" `grep -rl "要查找的文本" ./`   //-l 是list
grep -rl "qu_con_mode" ./* | xargs sed -i "s/qu_con_mode/host_cq_qu_depth_mode/g"
~~~
#### 3. 批量查找并替换任意目录下的文件内容。
~~~
sed -i "s/要查找的文本/替换后的文本/g" `grep -rl "要查找的文本" /任意目录`
~~~
### 4.grep 参数说明
~~~
-i：忽略大小写进行匹配。
-v：反向查找，只打印不匹配的行。
-n：显示匹配行的行号。
-r：递归查找子目录中的文件。
-l：只打印匹配的文件名。
-c：只打印匹配的行数。
~~~
grep -rn
grep -rl
### 5.mkdir 
mkdir -p xx //-p 确保目录名称存在，不存在的就建一个
### 6.强制执行命令,无需确认,命令前加\
\rm core.sv 
### 7. wc -l 统计行数
bjobs -w | wc -l 
[linux下wc -l 命令](https://blog.csdn.net/Moonlight_16/article/details/125527386)
### 8. grep 的组合使用
~~~
grep -rn  axi_master_wr_sequence  *axi*
~~~
### 9. find 命令和grep 的组合使用
~~~
find -type f -name "*.sv" | grep -rn  axi_master_wr_sequence
find  -name "*.sv" | grep -rn  axi_master_wr_sequence
find 命令参数解析
-name pattern：按文件名查找，支持使用通配符 * 和 ?。
-type type：按文件类型查找，可以是 f（普通文件）、d（目录）、l（符号链接）等
~~~

### 10. kill,pkill, xkill
- kill命令会发送一个信号给该pid的进程。 // kill 6228
- pkill命令，它可以基于进程的名字或者其他的属性来杀掉进程. // pkill terminal
- xkill,图形化杀进程,xkill会将鼠标指针变成一个特殊符号，类似于“X”。只需在你要杀掉的窗口上点击，它就会杀掉它与server端的通信，
- [精通Linux的“kill”命令](https://linux.cn/article-2116-1.html)
- [如何使用xkill命令杀掉Linux进程/未响应的程序](https://linux.cn/article-5605-1.html)
