# 1. transaction内约束结构体的注意事项
- 1.注意位宽一定要一致
- 2.数据结构的变量，和数据的都要是rand类型(双双都是rand类型)
- 3.循环复制需要消息，建议用低地址加，而不是用高地址减，并且最高的需要溢出保护。

# 2. 示例
~~~
typedef struct {
	rand bit[63:0] base_addr;
	rand bit[32:0] depth;
} queue_reg_cfg_s;

class pf_cfg_pkt extends uvm_sequnence_item
	rand queue_reg_cfg_s iocq_ring[32]; //此处也需要rand
	// 此处正确
	constraint iocq_rang_cons{
		iocq_ring[0].base_addr inside {[63'h10_0000:63'h30_0000]};
		iocq_ring[0].depth inside {[100:300]};
		foreach(iocq_ring[i]){		
			if(i==32) {
				iocq_ring[32].base_addr == iocq_ring[31].base_addr + 4*4*iocq_ring[31].depth;   //在transaction内不能之间约束数组之间的依赖，因为此时没有randomize,前一个元素还未随机出内容
				iocq_ring[32].depth inside {[100:300]};
			} else{
				iocq_ring[i+1].base_addr == iocq_ring[i].base_addr+4*4*iocq_ring[i].depth;
				iocq_ring[i+1].depth inside {[100:300]};				
			}
			
		}
	}
	 
	// 注释代码错误，约束失败，原因不明
	//constraint iocq_rang_cons{
	//		if(i<1) {
	//			iocq_ring[i].base_addr == {[63'h10_0000:63'h30_0000]}; 
	//			iocq_ring[i].depth inside {[100:300]};
	//		} else{
	//			iocq_ring[i].base_addr == iocq_ring[i-1].base_addr+4*4*iocq_ring[i-1].depth;
	//			iocq_ring[i].depth inside {[100:300]};				
	//		}
	//		
	//	}
	//}
endclass
~~~
