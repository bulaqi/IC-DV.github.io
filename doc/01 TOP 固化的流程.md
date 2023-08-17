### 1. scb对比

### 2. 格式化打印文件
### 3. 控制结束main_pahse的措施
### 4. sequence的重载
### 5. 组件间的连接
### 6. config_db的传递参数
### 7. fork 等待某信号,并设置超时等待时间,超时kill掉整个fork块
### 8. 测试用例标准化,用例文件结构:seq_tx, tc, 需要考虑,配置在怎么下,激励如何触发,是否需要多线程
### 9. 组件间的信号传递,层次化的引用,运用get_parent等方法
### 10. 全局配置的设置,全局cfg传递配置,有更新则刷新全局cfg的配置项,有需要则从cfg文件中的数组中读取配置
### 11. config_db用于将用例的配置,传给组件
### 12. 平台用内部信号的传递,尽量都引到interface上,
    1. 在interface中找对应的信号,如果没有可以新声明一个logic 的信号,iner_last
    2. 在th中,assign将dut 接口信号或者信号与接口信号的关联,assign iner_last = tb_top.u_dut.xx_module.last
    3. 实际使用中统一采用vif.xx.sigle(优点:如果后续信号层次或者名称,只需要修改tth中的层次化路径即可) 