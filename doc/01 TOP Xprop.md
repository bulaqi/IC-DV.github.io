### 1. 基础知识
#### 0. 验证的x态概述
1. 越早的发现bug，所消耗的成本也越低的，
2. 故VCS的X-Propagation功能可以更接近Gate-level的X态传播行为，
3. 是一种在后仿之前debug的低成本仿真策略。
  
#### 1. X态是什么
1. X态概述
   - X是不定态，亚稳态，可能为0/1/Z，常见于未复位的寄存器，锁存器和Memory；
   - X态出现在仿真中（包括RTL前仿真，门级后仿真及低功耗仿真），若仿真过程中出现X态，表明会有极大的Bug风险，要竭力避免
   - X态传播：指X态作为触发/控制条件或者逻辑输入时，引起其他逻辑输出为X态。
2. X态产生原因
    - 无初始化：未初始化的变量，比如logic/reg，在被复位或确定的值被锁定之前，保持X态；
    - 信号多驱或总线竞争：将多个输入驱动到同一个变量上，多个驱动存在冲突时，表现X态；
    - 位选择或数组索引越界返回X态；
    - 模块输入端口未连接(未赋值或tie)
    - setup/hold timing violation：跨时钟域逻辑；
    - testbench注入X态；


3. X态设计上避免发生
   - 使用二态变量；这个指的是使用wire和reg类型；在设计上；
   - 设计上进行复位操作，控制通路寄存器必选带复位，数据通路寄存器可以不带复位；
   - 验证tb_top例化DUT时接口input信号赋初值，一般是在tb_top层直接定义wire信号，然后进行例化连接，最后比如激励打的都是这个中间wire信号；
   - 仿真时利用initreg和inimem选项对reg和Memory进行初始化；
   - RTL model中添加针对X的assertion，及时发现X态上报并消除；
   - if-else或case使用确定写法，或者assign + 表达式来替代；
        ~~~
        if-else/case VS assign
        RTL仿真中，对if-else/case及assign对X态不同的行为：
        if(x) 默认x=0，走else分支，不传播X态；
        case(x)，若存在default分支，则走default分支，否则不会匹配到任何分支；
        assign c = sel ? a : b; 若sel = x，则输出x，从而将X态传播出去；
        ~~~
    - 从上面来看，if-else和case不能传播X态，无法暴露X态传播问题；assign +表达式的方式能够传递X态；另外从时序和面积角度来看，if-else和case会被综合为带有优先级的选择电路，不利于时序和面积，在纯组合逻辑下，使用assign

#### 2. X-Propagation选项
1. Xprop策略–即仿真选项
   - xprop是为了扩散X态传播，把不传播不定态的情形，强制传播出去，从而尽早暴露Bug；
   - xprop检查有三种模式，按照从悲观到乐观的顺序：xmerge –>tmerge（常用）–>Vmerge(默认，无传播)；
   - xmerge: 
        ~~~
        1. 它假设任何输入信号中的X都会无条件地传播到输出,
        2. 当控制信号未知时，输出信号的值将始终为X，无论其他信号的值如何
        3. xmerge：最悲观，一直传递下去；
        ~~~
   - tmerge: 接近实际硬件行为或门仿 <**最常用**>
        ~~~
        1. 它考虑到当控制信号未知时，输出信号的值将取决于其他已知信号的值以及输出信号当前的状态。
        2. 如果控制信号为X，那么输出信号的值将依赖于输出信号当前的值和数据信号的值，可能会导致X的传播，也可能不会
        ~~~
   - vmerge:遵守Verilog/VHDL对于X态处理行为；<**默认值，等同于不添加该选项>**
        ~~~
        1. 它假设如果输入信号中有X，但只要有一个确定的信号值，那么输出就有可能是确定的，不会无条件地传播X。
        2. 当控制信号未知时（即为X），输出信号的值保持不变，即使其他输入信号已知。
        ~~~
   - xprop 实战
      1. vcs‑xprop[=tmerge|xmerge|xprop_config_file],xprop_config_file(这是一个带具体路径的文件) 用以针对特定 instance 进行特定模式的 xprop 监测或开关特定instance 的 xprop 检测，
      2. 其示例用法如下：
          ~~~
          tree{top}
          instance{top.A}{xpropOn};
          instance{top.B}{xpropOff};
          module{C}{xpropOff};
          merge=tmerge;
          ~~~
2. 仿真的注意事项
   - **-xprop 一般不能跟 +vcs+initreg+0/1/random 同时使用**，因为 +vcs+initreg+0/1/random 会把 Verilog 的变量、寄存器及 Memory 初始值设置为 0 或 1 等非 X 状态，这样就测不到初始 X 态了。
   - 若未指定 -xprop，默认为 vmerge，即默认不存在 X 态传播问题，也不进行检查。
   - 若定义了 -xprop 但未指定具体模式，默认为 tmerge，即采用接近真实电路的 X 态传播模式并
   - Xprop查看
        ~~~
        1. 一方面最直观的就是在查看波形的时候顺带就check出来了。是最直接也是最经常使用的方法； 
        2. 另外通过查看相关report来查看。
        3. vcs 在编译、仿真两个阶段均提供了相关手段来检查相关 instance 的 xprop 开关情况：
        4. 若在编译阶段使能了 xprop，编译完成之后会生成一个 xprop.log 来报告 if/case 状态、always 边沿触发等条件的 xprop 检查开关情况。
        5. simv 仿真阶段添加仿真选项 -report=xprop[+exit] 能生成 xprop_config.report，便于在仿真后对 xprop 检查情况进行确认。若采用 -report=xprop+exit，在检测完 xprop 状态情况后后立即终止仿真。
        ~~~

3. 什么阶段使用X-prop
   - smoke–功能VO阶段完成；较后期收集覆盖率打开Xprop选项；X态传播不能不做，但是也不宜早做；
   - 原因
     1. 验证初期datapath或sanity期间，并不想看到太多X态，影响功能debug，在这里默认不启用xprop；
     2. 带有xprop是4态仿真，比不带xprop的2态仿真更慢；
     3. RTL 仿真前期不开启 xprop，以尽快调通 sanity/smoke case 及主要 datapath。
     4. RTL 仿真后期建议开启 xprop，提前排除部分 X 态。排除X态传播导致的芯片Bug，尤其是控制通路上的X态传播；
   
4. Debug trace x
   - trace X是指追踪X态产生的源头。利用Verdi自动追踪组合逻辑，锁存器，触发器等的X态传播源头。
   - Verdi Trace X有两种途径：
     1. 一种是在Verdi GUI内Trace；
     2. 一种是直接利用Verdi的TraceX工具直接Trace–不常用，可忽略。
   - Verdi GUI Trace
       1.手动Trace X：
       ~~~
       把出现 X 态的信号 A 拖到 nWave 窗口
       nWave 窗口 Cursor 点在 X 态信号 0/1 -> X 跳变沿的地方
       在源代码窗口左键双击该信号 A，追踪其 Driver
       检查 A 的 Driver (控制信号、触发条件、逻辑输入等) 是否存在 X 态
       重复以上步骤，直到找到 X 态产生的源头
       ~~~
       
       2.自动Trace X
       ~~~
       把出现 X 态信号 A 拖到 nWave 窗口
       nWave 窗口Cursor 点在 X 态信号 0/1 -> X 跳变沿的地方
       nWave 窗口右键单击该信号的波形，或源代码窗口右键单击该信号
       选择 Trace X，弹出 Trace X Settings 窗口
       窗口勾选所需的 Trace X 相关设置。默认 View Options 为 Flow View，此处我们也可以改为 nWave View
       左键单击 Trace，开始 Trace X，Trace 结果一方面显示在 Flow/nWave 窗口内，一方面显示在 tTraceXRst 窗口内（Note 提示 X 的大致出现原因）
       ~~~
       3.Verdi 的 traceX 工具
       除了在 GUI 内进行 X 态追踪，Verdi 还提供了 traceX 工具来追踪 X 态。
       ~~~
       设置变量打开 traceX 工具，setenv VERDI_TRACEX_ENABLE
       采用以下命令追踪 X 态
       未提供 X 态信号列表：traceX -lca -ssf xxx.fsdb
       提供了 X 态信号列表：traceX -lca -ssf xxx.fsdb -signal_file signal.list若需要手段加载 database，还需要添加选项 -dbdir simv.daidir
       查看 trx_report.txt 查看 Trace 结果
       ~~~

5. X 态怎么处理？
    - 如果 X 态没有传播，无需处理。
    - 如果 X 态发生传播，但后续有 X 态保护电路，无需处理。
    - 如果 X 态发生传播，且后续没有 X 态保护电路，需要从根源上消除 X 态。


### 3. 不同语法在xprop的实际分析
#### 1. 概述
- ![image](https://github.com/user-attachments/assets/ebf7fe0a-3144-4038-bc8b-06fa7e0a72f3)

#### 2. assgin语句
##### 1. 概述
1. assign是对xprop选项 **最不敏感** 的语法，
2. 无论是在哪种xprop配置反应 **都一样** 的
3. 对于逻辑运算，assign遵循合理X态规则：**如果能确定数值，则传播确定值，否则传播X态**（个人理解是，某些场景下，跳过三目运算的选择）。
4. 具体的规则如下：
   ~~~
   x & 1 = x
   x | 1 = 1
   x & 0 = 0
   x | 0 = x
   x ^ 0 = x
   x ^ 1 = x
   ~~~
5. eg:
   ~~~
   //test0
   logic t0_sel0, sel1;
   initial begin
       t0_sel0 = 1'b0;
       `DELAY(20, clk);
       t0_sel0 = 1'bx;
   end

   wire t0_xend0 = t0_sel0 & 1'b1;
   wire t0_xend1 = t0_sel0 | 1'b1;
   wire t0_xend2 = t0_sel0 & 1'b0;
   wire t0_xend3 = t0_sel0 | 1'b0;
   wire t0_xend4 = t0_sel0 ^ 1'b1;
   wire t0_xend5 = t0_sel0 ^ 1'b0;
   wire t0_xend6 = (t0_sel0 == t0_sel0);
   wire t0_xend7 = (t0_sel0 === t0_sel0);
   ~~~
6. 波形分析：
     - -xprop=vmerge/tmerge/xmerge波形均一致：
     - ![image](https://github.com/user-attachments/assets/cdcc3342-4ccf-4329-9935-2c8161b3a835)


7. assign语法特殊注意，感觉不合理（仅仅从RTL角度而不是仿真角度），会呈现X态
     - 被测代码
        ~~~
        wire t0_xend6 = (t0_sel0 == t0_sel0)
        ~~~
     - 而对于`===`则会反馈为1，这个也算是很“著名”的`==`和`===`的区别，感兴趣的可以自行查阅：
       - ![image](https://github.com/user-attachments/assets/8f882c97-96ff-4c64-a22e-b8ce38f84425)
       - `==` vs`===`:
         - `==`： 4值参与比较，只有0和1才会相等，其余混排结果都是x
         - `===`：绝对相等比较，4值参与比较，状态都必须相等才为1，否则是0，结果inside{0,1},
##### 2. 控制通路
   1. assign对于选择逻辑，配置为vmerge和tmerge遵循的规则仍然是如果能确定数值，则传播确定值，否则传播X态
      - demo
         ~~~
         wire t2_en2 = t0_sel0 ? t2_data0 : t2_data1;
         ~~~
      - vmerge和tmerge的波形如下：（优先级平等的选择，如果能确定数值，则传播确定值，否则传播X态）
         - ![image](https://github.com/user-attachments/assets/e4cbc527-ed19-4e74-b024-2bd8604f6a85)

      - 而xmerge的波形如下：
         - ![image](https://github.com/user-attachments/assets/74fd1f6c-dd82-4fcb-9c05-1bd3e85b5387)

##### 3. 数据通路
1. 注意，在xmerge配置下，如果X态出现在**数据**内那就不无脑X而是合理X了：
   - demo
      ~~~
      wire t2_en3 = t2_data0 ? t0_sel0 : t2_data1;
      ~~~
   - wave
      - ![image](https://github.com/user-attachments/assets/19de5170-4296-4cea-ab68-33b0e8c804d5)


#### 3. case语句
##### 1.控制通路
   1. 测试代码
       ~~~
       always @* begin
           case(t0_sel0) 
               0 : t2_en1 = t2_data0;
               1 : t2_en1 = t2_data1;
               default: t2_en1 = t2_data0;
           endcase
       end
       ~~~
   2. 仿真结果
      - vmerge仿真结果：(尽量的确定出结果,**冲突后保持原值**，即分支1的值)
         - ![image](https://github.com/user-attachments/assets/bdbc1954-8213-49f0-987f-5229ad979ec5)

      - tmerge仿真结果：（尽量merge,如果冲突，否则x传播）
        - ![image](https://github.com/user-attachments/assets/94068f53-f40f-49d1-a4d4-fdb45ca2a480)

      - xmerge仿真结果：（暴力x）
        - ![image](https://github.com/user-attachments/assets/ced2536c-104d-4721-8737-4ebfa28e4a36)

   3. 总结一下规律，case(sel)选择a or b：
      - 个人认为tmerge是最为合理的策略。而对于X态在数据中的情况，无论什么配置case都是如实的将X态传播出来，
      - ![image](https://github.com/user-attachments/assets/70dd6eea-94d0-4765-8a8f-63e18a408b1e)

##### 2. 数据通路x
   - 而对于X态在数据中的情况，无论什么配置case都是如实的将X态传播出来，比如这个代码：
   - eg
       ~~~
       always @* begin
           case(t2_data0) 
               0 : t2_en4 = t0_sel0;
               1 : t2_en4 = t2_data1;
               default: t2_en4 = t2_data0;
           endcase
       end
       ~~~
   - xmerge的仿真结果也是这样的
     - ![image](https://github.com/user-attachments/assets/86743378-64dc-4516-b7e6-1acbe8475098)  

#### 4. if_else
##### 1. 控制通路x
1. 被测代码
   ~~~
   always @* begin
       if(t0_sel0)begin
           t2_en0 = t2_data0;
       end
       else begin
           t2_en0 = t2_data1;
       end
   end
   ~~~
2. 仿真结果
     - vmerge仿真结果（x态，选else分支）：
       - ![image](https://github.com/user-attachments/assets/9666ed6a-773c-4299-b579-cf445da34b4f)

     - tmerge仿真结果：
       - ![image](https://github.com/user-attachments/assets/b8cdff56-4351-415e-981b-3f905f751733)

     - xmerge仿真结果：
        - ![image](https://github.com/user-attachments/assets/691f17fa-a5c6-4b9f-86b2-4e548c906224)

3. 总结
   - if_else时vmerge选择的是else分支，而case是选择"不变"策略；
   - tmerge和xmerge的结果则是和case语句相同的。
   - if(sel) a else b的选择语句结果：
   - ![image](https://github.com/user-attachments/assets/07f60a51-85b1-4b92-8f3e-045f35879b6e)

##### 2. 数据通路x
1. 无论什么配置if-else语句也是如实的将X态反馈出来：
    ~~~
    always @* begin
        if(t2_data0)begin
            t2_en5 = t0_sel0;
        end
        else begin
            t2_en5 = t2_data1;
        end
    end
    ~~~
    ![image](https://github.com/user-attachments/assets/11b6061a-9c5f-4f15-b33c-d9119eb042d8)


### 2. 经验
xprop是VCS中的编译参数，在项目中用法：
~~~
tree                     {tb_top}         {xpropoff}
instance             {tb_top.dut}    {tmerge}
instance             {tb_top.dut}    {xpropon}
instance             {tb_top.dut.serdes_pinmux_be_u0.xxx.xxx.xxx}  {tmergeoff}
~~~

### 3. 传送门
 1. [X态及Xprop解决策略](https://blog.csdn.net/li_kin/article/details/135564661)
 2. [【芯片验证】RTL仿真中X态行为的传播 —— 从xprop说起](https://zhuanlan.zhihu.com/p/661652222)
 3. [SystemVerilog 中的相等运算符：== or === ？](https://www.cnblogs.com/bitlogic/p/14589903.html)
