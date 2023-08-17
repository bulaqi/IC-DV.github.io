### 寄存器模型简介
- uvm_block:和 DUT 中的每个寄存器相对应，每个 uvm_reg 的位宽一般和总线位宽一致；
- uvm_reg_field:uvm_reg_field 是寄存器模型的最小单位 , 在 uvm_reg 的build 函数内实例化 , 和 DUT 中每个 register 里的 field对应
- uvm_reg_map ：有一个已经声明好的 default_map地址映射，用于对寄存器的前门访问操作（此块的默认地址映射，当没有为某个寄存器操作指定地址映射且该寄存器可从多个地址映射访问时使用）

### 寄存器模型中的函数
#### 1. uvm_reg_field：uvm_reg_field 是寄存器模型的最小单位 , 在 uvm_reg 的 build 函数内实例化 , 和 DUT 中每个 register 里的 field 对应uvm_reg_field\
成员:
1. rand uvm_reg_data_t value:寄存器模型可以直接访问，也是唯一一个用 rand 修饰的字段，即对寄存器模型里的寄存器进行随机时 value 用来存储随机后的随机值
2. local uvm_reg_data_t m_mirrored:存放认为 DUT 内的实际值
3. local uvm_reg_data_t m_desired:存放期望 DUT 中被存放的值

方法：\
configure：
~~~
parent ：所在 uvm_reg 的指针；
size ：该 field 的 bit 位宽；
lsb_pos ：该 field 的最低有效位相对于 reg 最低有效位的位置；
access ：读写属性；
volatile ：
reset ：复位值；
has_reset ：是否真实被 reset ；
is_rand ：是否随机化；
individually_accessible ：该 field 是否在该 uvm_reg 内是唯一占有 bit 位的域
~~~
get_mirrored_value
~~~
返回当前抽象寄存器模型中的 morror 值，并非 DUT 中寄存器域的实际值；如果 WO 寄存器域段，则拿到 mirror 值为最后一次写入的值；
~~~
need_update：  
~~~
检测在寄存器抽象模型中是否存在 desire 值和 mirror 值不相同的情况，若寄存器模型中的 desire 值被修改，但没有更新到 DUT 中，则该模型认为DUT 中的值过时需要更新，因此返回 TURE ；只是检测是否需要更新，不会执行更新，更新需要通过 uvm_reg::update 来完成
~~~

#### 2. uvm_reg；
uvm_reg 的实现 : （每个寄存器 reg 都继承自 uvm_reg 类）
  - 和 DUT 中的每个寄存器相对应，每个 uvm_reg 的位宽一般和总线位宽一致；
  - 每个 uvm_reg 中有多个 uvm_reg_field ；
1. 声明 rand 类型的 uvm_reg_field ；
2. 需要 factory 机制进行 uvm_object_utils 进行注册；
3. 实现 new 函数；
4. 实现 build 函数；\
   <1> 对每个 uvm_reg_field 进行 create 创建；\
   <2> 调用每个 field 的 configure 函数，所含信息包括该 field 所在 uvm_reg 的指针、该 field 的 bit 位宽大 小、相对于该寄存器的最低有效位、读写类型、 volatile 、 reset 值、是否真实重置、是否随机化、是否在该 uvm_reg 内是唯一占有 bit 位的域段；\

 <html xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"
xmlns="http://www.w3.org/TR/REC-html40">

<head>

<meta name=ProgId content=PowerPoint.Slide>
<meta name=Generator content="Microsoft PowerPoint 15">
<style>
<!--tr
	{mso-height-source:auto;}
col
	{mso-width-source:auto;}
td
	{padding-top:1.0px;
	padding-right:1.0px;
	padding-left:1.0px;
	mso-ignore:padding;
	color:windowtext;
	font-size:18.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Arial;
	mso-generic-font-family:auto;
	mso-font-charset:0;
	text-align:general;
	vertical-align:bottom;
	border:none;
	mso-background-source:auto;
	mso-pattern:auto;}
.oa1
	{border-top:1.0pt solid white;
	border-right:1.0pt solid white;
	border-bottom:3.0pt solid white;
	border-left:1.0pt solid white;
	background:#DCE6F2;
	mso-pattern:auto none;
	text-align:center;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa2
	{border-top:1.0pt solid white;
	border-right:1.0pt solid white;
	border-bottom:3.0pt solid white;
	border-left:1.0pt solid white;
	background:#DCE6F2;
	mso-pattern:auto none;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa3
	{border-top:3.0pt solid white;
	border-right:1.0pt solid white;
	border-bottom:1.0pt solid white;
	border-left:1.0pt solid white;
	background:#D0D8E8;
	mso-pattern:auto none;
	text-align:center;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa4
	{border-top:3.0pt solid white;
	border-right:1.0pt solid white;
	border-bottom:1.0pt solid white;
	border-left:1.0pt solid white;
	background:#D0D8E8;
	mso-pattern:auto none;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa5
	{border:1.0pt solid white;
	background:#E9EDF4;
	mso-pattern:auto none;
	text-align:center;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa6
	{border:1.0pt solid white;
	background:#E9EDF4;
	mso-pattern:auto none;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa7
	{border:1.0pt solid white;
	background:#D0D8E8;
	mso-pattern:auto none;
	text-align:center;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa8
	{border:1.0pt solid white;
	background:#D0D8E8;
	mso-pattern:auto none;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
-->
</style>
</head>

<body>
<!--StartFragment-->



configure | 包含所在uvm_reg_block的指针，以及后门路径；
-- | --
set | 仅更新regmodel中的desired值，并未真正写入DUT的寄存器中
get | 仅得到regmodel中的desired值，没有真正读到DUT中的真实value
write | 使用指定的访问路径方式(前门/后门访问)，将值写入和regmodel相对应的DUT中的寄存器中(其中RO寄存器不会被写入值)
read | 使用指定的访问路径方式(前门/后门访问)，读取和regmodel相对应的DUT中的寄存器的值（clear-on-read   bits in the registers will be set to zero.）
poke | 使用指定的后门路径访问将值存入与regmodel对应的DUT寄存器中
peek | 使用指定的后门路径对与regmodel对应的DUT寄存器中的值进行采样
update | 更新DUT中寄存器的值，匹配regmodel中的desired值(与mirror功能相反)，若DUT寄存器的值相较于regmodel中的值已过时，则更新DUT中寄存器的值—— uvm_reg::needs_update()——可使用前门或者后门poke来更新
mirror | 读取寄存器并更新/检查其镜像值。   如果check为UVM_CHECK，则读取寄存器并可选地将读回值与当前镜像值进行比较；若寄存器的field通过uvm_reg_field::set_compare()禁用，则不会被check；   可以使用uvm_reg::predict更新mirror值；
predict | 更新寄存器中的mirror值



<!--EndFragment-->
</body>

</html>

#### 3. uvm_block
![image](https://user-images.githubusercontent.com/55919713/230092154-19542bc0-bd2b-4709-8c38-dae340be5d9c.png)
<html xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"
xmlns="http://www.w3.org/TR/REC-html40">

<head>

<meta name=ProgId content=PowerPoint.Slide>
<meta name=Generator content="Microsoft PowerPoint 15">
<style>
<!--tr
	{mso-height-source:auto;}
col
	{mso-width-source:auto;}
td
	{padding-top:1.0px;
	padding-right:1.0px;
	padding-left:1.0px;
	mso-ignore:padding;
	color:windowtext;
	font-size:18.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Arial;
	mso-generic-font-family:auto;
	mso-font-charset:0;
	text-align:general;
	vertical-align:bottom;
	border:none;
	mso-background-source:auto;
	mso-pattern:auto;}
.oa1
	{border-top:1.0pt solid white;
	border-right:1.0pt solid white;
	border-bottom:3.0pt solid white;
	border-left:1.0pt solid white;
	background:#DCE6F2;
	mso-pattern:auto none;
	text-align:center;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa2
	{border-top:1.0pt solid white;
	border-right:1.0pt solid white;
	border-bottom:3.0pt solid white;
	border-left:1.0pt solid white;
	background:#DCE6F2;
	mso-pattern:auto none;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa3
	{border-top:3.0pt solid white;
	border-right:1.0pt solid white;
	border-bottom:1.0pt solid white;
	border-left:1.0pt solid white;
	background:#D0D8E8;
	mso-pattern:auto none;
	text-align:center;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa4
	{border-top:3.0pt solid white;
	border-right:1.0pt solid white;
	border-bottom:1.0pt solid white;
	border-left:1.0pt solid white;
	background:#D0D8E8;
	mso-pattern:auto none;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa5
	{border:1.0pt solid white;
	background:#E9EDF4;
	mso-pattern:auto none;
	text-align:center;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa6
	{border:1.0pt solid white;
	background:#E9EDF4;
	mso-pattern:auto none;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa7
	{border:1.0pt solid white;
	background:#D0D8E8;
	mso-pattern:auto none;
	text-align:center;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
.oa8
	{border:1.0pt solid white;
	background:#D0D8E8;
	mso-pattern:auto none;
	vertical-align:top;
	padding-bottom:3.6pt;
	padding-left:7.2pt;
	padding-top:3.6pt;
	padding-right:7.2pt;}
-->
</style>
</head>

<body>
<!--StartFragment-->



reset | Reset 所有当前block和子block的寄存器值；   包括mirror值，desire值，value值；   并不能真正的对DUT中的寄存器值进行配置，只是针对域的抽象类中的镜像值
-- | --
create_map | 创建该block的一个地址映射(address map)：   该map的名字，基地址，基地址对应总线的byte位宽，大小端；
find_block | 找到层次结构与指定名称相匹配的第一个block
get_blocks | 获取当前block中实例化的子block，若传参值hire为TURE，则包含层次结构下的所有子block
get_registers | 获取该block例化的所有寄存器，参数为UVM_NO_HIRE，则不会获取子block中的寄存器
add_submap | 添加一个地址映射，基于指定的基地址；参数包括地址映射的偏移地址
get_reg_by_name | 查找具有指定名称的寄存器



<!--EndFragment-->
</body>

</html>


### 寄存器模型在TB中的集成

### 注意事项

### 示例

### 引用