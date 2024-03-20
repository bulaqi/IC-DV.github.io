### 1. 基础知识
### 2. 经验
1. xx_reg_model.xxx_block.RESISTER_BANK_CLOCK_EANBEL_SET.write(status,32'h,UVM_FRONTDOOR);
2.
   - seq_lib:在seq_lib 下的base_sequence_base 内封装公共函数，ahb_single_write/read 函数,调用ahb_single_write_squence，供seq内部使用，
   -  base_test内也新建封装函数，函数内部例化ahb_single_write_squence，实现配置
   -  ahb_single_write_squence 是在seq_lib下atb 自动生成的seq，是根据addr 读写寄存器,一般在amba_seq_lib 下由工具实现
4. 
### 3. 传送门
