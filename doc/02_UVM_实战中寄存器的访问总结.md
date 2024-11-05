### 1. 基础知识
### 2. 经验
1. 层次化找到该寄存器，然后调用read/write函数， xx_reg_model.xxx_block.RESISTER_BANK_CLOCK_EANBEL_SET.write(status,32'h,UVM_FRONTDOOR);
2. 寄存器模型的实现：
   -  seq_lib:封装，read/write_reg, 入参参数是寄存器名，和读写的值，在函数内部变量中遍历，根据寄存器字符串名称找到该寄存器get_reg_by_name，类型uvm_reg类型，然后调用xx_reg.write()/或者read函数，默认是前门，可以选择后门访问
   -  base_test: 思路和上述类似， 也需要独立实现一份
3. 纯seq方式的实现
   - seq_lib:在seq_lib 下的base_sequence_base 内封装公共函数，ahb_single_write/read 函数,调用ahb_single_write_squence，供seq内部使用，
   -  base_test内也新建封装函数，函数内部例化ahb_single_write_squence，实现配置
   -  ahb_single_write_squence 是在seq_lib下atb 自动生成的seq，是根据addr 读写寄存器,一般在amba_seq_lib 下由工具实现

### 3. 传送门
