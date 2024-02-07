### 1.基础知识
#### 1. snps vip框图
![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/573197ad-f12e-410c-9d57-107ce09ae98b)

#### 2. 安装
- 红框指从SNPS网站下载VIP安装包然后安装在我们Linux环境里并设置一些环境变量等（譬如$DESIGNWARE_HOME），安装后的文件都在$DESIGNWARE_HOME路径下；一般来说公司会有专人做这件事，普通用户没有权限；如果要研究可参考$DESIGNWARE_HOME/vip/svt/common/latest/doc/uvm_install.pdf
- 橙色框指把安装好的VIP再setup到一个指定路径，注意: 我们TB Makefile中设置编译该VIP的+incdir都是这个路径下，并非那个$DESIGNWARE_HOME下的路径；这件事有可能需要我们自己做（我司的环境中已完成这一步，该路径为/nfs/ipdata/vip/synopsys）
- 如果需要执行橙色框的操作，输入$DESIGNWARE_HOME/bin/dw_vip_setup -help会显示帮助，常用选项包括-add，-example，-doc，分别用于setup VIP source files，setup example，setup doc文件
- 安装VIP source file示例
~~~
% cd $DESIGNWARE_HOME/bin
% dw_vip_setup -info home:amba_svt (查看该VIP可用版本、model及example名字),(setup时可选取某个model安装，但一般习惯一股脑把能se的都setup了),(随便在哪新建一个文件随便取名例如suitelist，如图然后保存),(可以一股脑安装好几个VIP，但推荐一次安一个，因为setup时指定的路径是唯一的，如果一次安好几个，它们就混在一起了，比较乱；所以注释掉了不打算这一次安装的VIP的名字)
% dw_vip_setup -path <user dir>/amba_svt -add -suite_list <user dir>/suitelist
对比下$DESIGNWARE_HOME下和setup的这个路径下，VIP文件有什么区别 (大概是，前者文件后缀是svp后者是sv；前者的文件存放层级比较多，后者打平了存放的，比较方便用户编译)
~~~

- 安装example示例
~~~
如下依次操作，来安装example (example非常重要，前期我们对一个VIP的使用不熟悉时，一定会参考example；里面包含了完整的UVM环境/configuration/sequence/tb/makefile/simulation等等)
% cd $DESIGNWARE_HOME/bin
% dw_vip_setup -info home:amba_svt (查看可用example)
% dw_vip_setup -path <user dir>/amba_svt -example amba_svt/tb_axi_svt_uvm_basic_sys -v latest(或具体版本号) -doc(顺便setup doc文件)
(貌似example只能一个一个setup，我还未发现一口气全安的方法)
其实example和doc可以去$DESIGNWARE_HOME下对应的VIP去查看，那里最全
~~~

#### 3. 集成
- 文档:$DESIGNWARE_HOME/vip/svt/amba_svt/latest/doc/axi_svt_uvm_getting_started.pdf
- 文档中手把手教大家包括Makefile编译要incdir的路径和要编译的文件、package中需要import的东西、TB顶层interface的例化、clock&reset、UVM组件的创建、config文件的配置、base sequence&test的编写等内容，基本跟着走一遍集成就没什么问题了

#### 3. 使用
1. 集成完毕并编译通过，紧接着就是怎么在我们的test或sequence中来调用该VIP，让它发送相应的激励，或利用它来check数据正确性
2. 建议先运行example中，跑一个里面TB的仿真，并研究下波形，如果你觉得自己没什么经验时,打开example里的README，会告诉你如何启动这个example TB的仿真,eg
~~~
gmake USE_SIMULATOR=vcsvlog directed_test WAVES=1
~~~
3. SNPS VIP这种商业IP功能非常强大，里面自带的sequence种类非常多，基本可以覆盖我们能想到的所有场景；sequence全部在<上文setup VIP的路径>/amba_svt/src/sverilog/vcs/*_sequence_collection.sv中
4. 不过难免有时也会有我们需要为这个VIP自建sequence的情况（譬如我觉得AXI VIP中sequence都太复杂太randomized了，我就想发一个最简单AXI master single的wr/rd传输），那么就需要我们在自己TB的seq_lib中，新建一些派生自VIP自建sequence(以svt开头的)的新sequence；其中在example中我们就可以借鉴
~~~
% cd $DESIGNWARE_HOME/vip/svt/amba_svt/latest/examples/sverilog/tb_axi_svt_uvm_basic_sys/env
~~~

5. 就是在$DESIGNWARE_HOME/vip/svt/amba_svt/latest/doc下除了pdf教程外，还有一些*_svt_uvm_class_reference的东西，使用firefox打开axi_svt_uvm_class_reference，随便点击网页中任意一个html链接直到出现这个界面

- 这是一个以html形式展示的关于这个VIP的document，所有有关这个VIP中的class、function、task、attribute、UVM继承关系等等都能在这里面找到，在红框处搜索关键字即可
- 举例:
  1. 我们现在想通过AXI slave VIP去获得我们DUT AXI master口发送出的数据
  2. 联想到UVM TLM port的相关知识，我们去找找VIP中的analysis port，这样就可以拿到这个port经过的AXI transaction，继而获得transaction中的payload信息
  3. 我们在TB env中例化的是svt_axi_system_env，我们在网页中搜索它，并更根据我们使用的实际情况一级一级查看，最终找到monitor里面适合的analysis port供我们使用
     ~~~
     1. 搜索svt_axi_system_env,查看详情
     2. 查看public attributes中的 svt_axi_slave_agent slave[$]
     3. 查看类的定义 svt_axi_slave_agent,详情
     4. 查看public attributes中的 svt_axi_port_monitor monitor
     5. 查看svt_axi_port_monitor类的详情
     6. 查看public attributes中的 uvm_analysis_port 5个属性,查看tlm_generic_payload_observer port的描述,闭环     
     ~~~

![image](https://github.com/bulaqi/IC-DV.github.io/assets/55919713/755f33e9-0ec5-401c-a7df-eaafa4bb5111)




### 2.经验
svt --缩写synpsis verif tools

### 3.传送门
