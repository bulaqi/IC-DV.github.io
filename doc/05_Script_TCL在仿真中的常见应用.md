### 1. 添加波形,add_wave xxx.xxx.single
### 2. 添加checkpoint, checkpoint -add "checkpoint_1"
### 3. 运行,run
### 4. stop
### 5. 自动加载rc 文件,  wvRestoreSignal xx.rc

### 6. 常用命令示例
~~~
1.open_db
2.close_db
3.open_file
4.start
5.step
6.next
7.run
8.finish
9.restart
10.stop
11.add_source
12.get
13.force
14.release
15.add_list
16.add_watch
17.add_wave
18.delete_group
19.delete_watch
20.delete_wave
21.compare
22.dump
23.memory
24.save
25.restore
26.save_session
27.open_session
28.config
~~~
### 7. 常用举例
~~~
dump -add {aem_top_tb} -depth 0 -scope "." -aggregates
checkpoint -add "init"
run 1ps
add_wave aem_top_tb.th.dut_inst.aem_core_clk_i #添加信号波形
# force xxx.xxx.xxx 'h70000 -cancel 350us  // 350us 后取消，注意16进制数字必须是'hff 而不是0xfff
# force xxx.xxx.xxx 'h70000  -freeze //保持，未使用过
# force {xxx.xx.xx.xx.addr[63:0]} 'h0777 -deposit //信号有位宽，必须用大括号括起来
checkpoint -add "init 1"
run 10ns
checkpoint -add "init 10ns"
run
~~~

### 传送门
   参考ucli_ug.pdf
