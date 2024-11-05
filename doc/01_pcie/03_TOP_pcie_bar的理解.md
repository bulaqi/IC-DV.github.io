### 基础概念
1. AEM每一个Controller的NVMe寄存器的BAR空间分布如下表所示
寄存器组	          BAR#	BAR偏移	大小
Controller Register	0	    0x0	   8KB
MSI-X Table        	0	   0x2000	 528B
PBA	                0	   0x2210	 8B
Reserved	          0	   0x2218	 8KB-536B

2.ELBI接口通过Function Number、BAR Number和Addr进行寻址，Function Number在AEM顶层通过映射表转化为对某一个Controller的访问，因此Controller的ELBI接口仅采用BAR Number和Addr进行寻址，与上表中的BAR#和BAR偏移对应

3. bar 地址

4. bdf


#### 传送门
https://zhuanlan.zhihu.com/p/445866515
https://zhuanlan.zhihu.com/p/611965529
