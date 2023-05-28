1. sv 约束范围约束的时候，必须inside{[小：大]}， 如果写反编译器不会报错，也不会报约束失败
2. super.configure_phase(),报错，super is not expect in this contex, 原因，**子类名称后忘记逗号**
3. 约束中local的使用，在使用内嵌约束randomize（）with {CONSTRAINT}时，约束体中的变量名的查找顺序默认是从被随机化对象开始查找，但如果调用randomize（）函数局部域中也有同名变量，那就需要使用local::来显式声明该变量来源于外部函数，而非被随机化的对象（在约束中也可用this/super来索引这些变量
4. 队列的长度不要直接作为循环的条件，易错
5 .非类的变量约束,rand 变量能约束类变量,不能约束内的函数变量
6. 语法错误,编译器不会报错:
~~~
task  xx_tc::main_phase(uvm_phae phase);
        int q_rand;//函数内只能定义为变量,不能用rand 修饰
	beign

		//std::randmize(q_rand);
                //std::randomize(q_rand) with(q_randinside{[1:31]};); // 正确,注意语法,编译器不会报错,randomize后有括号,括号内包含q_rand,然后with 约束
                std::randomize() with(q_randinside{[1:31]};); // 语法错误,编译器不会报错,randomize后有括号,括号内包含q_rand,然后with 约束

		$display("q_rand=%0d",q_rand);// 真随机，调用系统函数，
		$display("random_data=%0d",$random);//伪随机
	end
endmodule
~~~
6.约束失败导致的卡死,计算器卡死,导致平台卡死,无波形,固定卡在某个时间点,APB下配置的阶段,定位方向错误,所以, 有错误全文多上下文日志,否则看初始化流程,初步定位卡死的点
solver time out when solving following problem
sof cq_queue[i].depth dist{2:=10,[3:4095]:/30,[5096:65535]:/30,4095:=10}; //范围重复
sof cq_queue[i].depth dist{2:=10,[3:4095]:/30,[5096:65535]:/30,65536:=10};//错误,16bit最多表示65535

7.https://blog.csdn.net/hanshuizhizi/article/details/116521728
~~~
bit[11:0] aq_size;
bit[11:0] sq_size;
bit[31:0] aqa;
constrant aq_size_cons{aq_size dist {2:/10,[3:4095]:/30,4096:/10};}
constrant sq_size_cons{sq_size dist {2:/10,[3:4095]:/30,4096:/10};}
constran  aqa_cons{slove aq_size before aqa;slove sq_size before aqa;}
constrain qu_con {
  //soft aqa == {4'b0,aq_size,4'b0,sq_size}; //易错点,结果[31:28]  [15:12] 不为0
  soft aqa == {{4'b0},aq_size,{4'b0},sq_size}; //知识点:变量或者常量的重复（扩展）与拼接,变量必须用{}括起来再参与拼接
}
~~~

8.复杂的约束,求解器约束失败,系统卡死
在transaction 内有如下约束
~~~
...
	soft cq_queue[0].base_addr[63:12] inside{[64'h500,64'h600]};
	soft cq_queue[0].base_addr[11: 0] == {12{b'0}};
	soft cq_queue[0].depth dist{2:=10,[3:4095]}
	
	foreach(cq_queue[i]) { //cq_queue 深度33
		if(i > 0) {
			//soft cq_queue[i].depth dist {2:10,[3:4095]:/30}; //复杂度太高,求解器无法求出,仿真卡死
			soft cq_queue[i].depth inside {[2:4095]};
			soft cq_queue[i].base_addr == cq_queue[i-1].base_addr + 16* cq_queue[i-1].depth;
		}
	}
...
...
~~~

2种解决方案
1. 将上述计算cq_queue[i].base_addr移至post_randomize
2. 写新类,内部用randc,选择addr的初值

9. for 循环内嵌套foreach
~~~
...
for(int i=0;i<5;i++) begin
	foreach(pf_cfg_pkt_p[i].cq_queue[j]){         //for循环内嵌套forech ,foreach变量j,内循环
		pf_cfg_pkt_p[i].cq_queue[j].depth > 32; 
	}
end
...
~~~

10. 结构体 auto_file 那个函数？
无，不能传递结构体，只能传递函数，函数用file_object实现

11. unpack  数组定位是那个方法？
packer.counter

12.类里面只能是变量初始化和复制,不能在类内直接计算
~~~
class xx_test extends basic_tc4;
int i =5;
int j =8;
if(i>5)                  //编译报错,类内不能直接赋值
  $print("i out rang");  //编译报错,类内不能直接赋值

~~~

13. for 循环内用fork
- 函数传参必须是automatic
- 被调函数也应该是automatic类型,否则被调函数内部变量会被公用
~~~
task cal_exp_burst_cnt();

	for (int i =0 ;i<5; i++) begin
		fork
			automatic int pf_id = i;  //必须是automaitc,否则cal_pf_exp_burst_cnt参数是5
			if(pf_bitmap_en[pf_id])
				cal_pf_exp_burst_cnt(pf_id);
		join_none
	end	
~~~

~~~
task automatic cal_pf_exp_burst_cnt(pf_id);
	int req_split; //如果函数类型不是automatic,则全部子进程公用一套req_split 变量
	...
endtask
~~~

14.慎重使用组合逻辑,监测上升沿
背景:检测某型号的上升沿,采用@(posdege xx),
~~~
while(1) begin
   ...
   @(posdege xx);
   ...
end
~~~
问题:不可靠,组合逻辑内部是有可能出现毛刺,但是波形上不显示(受显示策略的影响)
解决方案:参考逻辑的实现,监测上升沿, if(singe == 1 && singe_1dely == 0)
~~~
while(1) begin
   ...
   @(posdege sys.clk);
   if(singe == 1 && singe_1dely == 0) begin 
   ...
   end
   ...
end
~~~




