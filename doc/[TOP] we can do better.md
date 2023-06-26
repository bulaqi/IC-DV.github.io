
### 1. 用例的命名规范,考虑字母序,方便查找
   eg ,aem_dma_split_acq_test.sv
        模块名_用例名_特性名_业务名

### 2. 注重前提的消化spec, 一个步骤都不能少
    1.必须有架构串讲
    2. 开发反串讲
    3. 验证反串讲

### 3. 步骤规范
    验证必须输出验证方案,
   方案需要包含:
    1. 测试平台框图
    2. 配置激励的实现, rm如何获取才dut_cfg 类,dut_cfg如何传递给验证组件, 建议:维护一个aem_top_cfg文件,设置某个部分组件抓取vip monitor_port的端口数据
    3. 业务流的激励,包括trasaction ,sqe,
     eg:用例sqe的总体配置,eg ,pf_bitmap,cq_bitmap,int_ch_bitmap等通用控制,也

### 4. VO和用能覆盖率的部分
    1. 不建议开始搞的很细致,可以从客户使用的角度触发,优先basic fun的功能.


### 传送门:
     1. [搭建一个好平台](https://github.com/bulaqi/IC-DV.github.io/blob/main/doc/%5BTOP%5D%20%20%E6%90%AD%E5%BB%BA%E4%B8%80%E4%B8%AA%E5%A5%BD%E5%B9%B3%E5%8F%B0.md)