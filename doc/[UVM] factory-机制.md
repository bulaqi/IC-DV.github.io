### 基本知识

### 示例
### 常用函数
set_type_override_by_type(aem_cq_pf_init_squence::get_type(), aem_cq_pf_sequence_case_acq::get_type());  
or  
aem_cq_pf_init_squence::typed_id::set_type_override(aem_cq_pf_sequence_case_acq);  
### 注意事项
- 子类里不能定义新变量，因为使用的时候是按照父类的对象进行访问的
- 子类里面只能重新新方法或者task
### 参考