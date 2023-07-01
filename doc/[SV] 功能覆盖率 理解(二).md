### 1. 功能覆盖率方法
#### 1. 背景: 在subsystem中定义功能覆盖率的covergroup时，经常会有一个covergroup中定义30多个coverpoint，这些coverpoint的bins完全相同，仅在被采样的信号名字上有不同
如下所示：
~~~
covergroup cov_speed_mode();
	option.per_instance = 1;
	
	port0: coverpoint vif.link_speed_port[0]{
	bins gen1={1};
	bins gen2={2};
	bins gen3={3};
	bins gen4={4};}
	.
	.
	.
	Port31: coverpoint vif.link_speed_port[31]{
	bins gen1={1};
	bins gen2={2};
	bins gen3={3};
	bins gen4={4};}
endgroup
~~~
#### 2. 存在的问题:上图这样的顺序定义造成Code篇幅很长，并且不方便批量修改，
#### 3.  解决方案
#### 3.1 定义带ref类型参数的covergroup，并且option.per_instance为1，和上图相比covegroup篇幅缩减很多
~~~
covergroup cov_speed_mode(ref logic[3:0] port_id_x);
	option.per_instance = 1;
	
	coverpoint  port_id_idx{
	bins gen1={1};
	bins gen2={2};
	bins gen3={3};
	bins gen4={4};}
endgroup
~~~
说明：
1. 定义为ref类型参数，可以使对形参的操作实际都是对实参执行，保证整个仿真过程中被采样信号和covergroup的直接联系。
2. per_instance设为1，使覆盖率结果和实例化个数对应，否则只会生成一个覆盖率结果

#### 3.2  注意该covergroup的定义的位置，需要放在class pcie_225_top_coverage之外，不能位于class pcie_225_top_coverage内部，否则无法进行多次实例化
~~~
covergroup cov_speed_mode(ref logic[3:0] port_id_x);
…
endgroup

class pcie_225_top_coverage
…
Endclass
~~~

~~~
说明：为了能多次实例化covergroup，对它的定义必须在class top_coverage的外面，原因大概如下
When you have an embedded covergroup (declare a covergroup inside the class), the covergroup object and class object are merged into a single object. That is why the cg constructor has to be inside the class constructor, and you are not allowed to declare multiple instances of an embedded covergroup.
If you really want multiple covergroup instances for a single class object, you will have to declare the covergroup outside the class, and pass all the coverpoint data through arguments to the covergroup's constructor.
~~~

#### 3.3  在class 内部定义一个中间变量，类型和covergroup端口参数类型一致
~~~
logic[3:0]  port_id_path[32] 
~~~
#### 3.4  在class内部对cover group进行多次实例化
~~~
cov_speed_mode  cov_spee_mode[32]; 
~~~
#### 3.5  在class的build_phase中进行多次new
~~~
foreach(cov_spee_mode[i])begin
  port_id_path = vif.link_speed_port[i];
  cov_speed_mode[i] = new(port_id_path[i]);
end
~~~
~~~
说明：定义在build_phase中，是因为这里用到了vif，而build_phase的首行已经通过get的方法获得了vif的有效信息。
注意new的时候，传递的参数是中间变量port_id_path[i]，而不是直接传递vif.link_speedd_port[i], 因为仿真器暂不支持传递virtual interface类型的数组到ref类型的端口上，所以这里对vif数组进行拆分到中间变量。通过这种方法，covergroup操作的是中间变量port_id_path,而不是interface信号。

~~~
#### 3.6  在class的run_phase中进行sample
~~~
forever begin
	@(posedge vif.sample_clk iff (合适的采样条件));
	foreach(cov_speed_mode[i])begin
		port_id_path = vif.link_speed_port[i];
		cov_speed_mode[i].sample();
	end
end 
~~~


~~~
说明：注意在每次sample之前， 都对中间变量port_id_path进行赋值，这还是因为上一步骤中new的时候，covergroup操作的是中间变量port_id_path,而不是interface信号，但port_id_path本身和DUT上的信号没有实时连接，所以在每次sample之前单独赋值一次，让DUT信号通过interface到中间变量，最终能被cover group获得。
~~~
通过以上步骤实现了定义一组covergroup，实例化为32组，并通过传递不同的被采样信号收集功能覆盖率。
#### 4.  总结
上述方法适用于大量coverpoint重复定义的场景，对于coverpoint不重复的情况，仍使用原来的方法。
已经写好的covergroup可以暂不修改，避免影响回归进度，正在新增的covergroup可以采用上述方法。
具体代码已上传，可以在atb目录下grep关键字cov_speed_mode获得更具体的信息。
