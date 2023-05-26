### 总体思路
1. 确认时class 还是sequence,
2. 跳入后看属性,然后看是否可以配置
### 举例
#### 1.squence 举例,
1.确认平台代码是寄存vip的seq,svt_axi_master_base_sequence;
2.vip html 首页 点击sequence 标签,找到svt_axi_master_base_sequence 类
3.类内是fuction attribute 等组成,  查看attribute,cfg 属性,类型是svt_axi_port_configuration, 如果需要配置,需要查看svt_axi_port_configuration类的定义.
4. 跳转进入svt_axi_port_configuration,有class menber groupings,menber funciton,attrabute等,attrabue内有data_width,addr_width,axi_interface_type

#### 2.类举例
1.平台内的axi 配置类是svt_axi_system_configuration
2. vip html首页搜索,class页签下的
3. 该类的master_cfg属性是,rand svt_axi_port_configuration类似
4.后续参考seq的举例
