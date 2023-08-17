### 基础概念
#### 1. pack_bytes/unpack_bytes  
* pack_bytes函数用于将所有的字段打包成byte流\
~~~
function int pack_bytes (ref byte unsigned bytestream[], input uvm_packer packer = null)
~~~

* unpack_bytes函数用于将一个byte流逐一恢复到某个类的实例中\


#### 2.pack/unpack    
* pack函数用于将所有的字段打包成bit流 \
~~~
function int pack (ref bit bitstream[], input uvm_packer packer = null)
~~~

* unpack函数用于将一个bit流逐一恢复到某个类的实例中\


####  3. pack_ints/unpack_ints
* pack_ints函数用于将所有的字段打包成int（ 4个byte， 或者dword） 流\
~~~
function int pack_ints (ref int unsigned intstream[], input uvm_packer packer = null)
~~~

* unpack_ints函数用于将一个int流逐一恢复到某个类的实例中\


####  4. 回调函数do_pack/do_unpack
* do_pack（）方法由pack（），pack_bytes（）和pack_ints（）方法调用。 do_pack（）用于使用uvm_packer策略对象打包jelly_bean_transaction对象的每个属性。请参阅[寄存器抽象](https://blog.csdn.net/zhajio/article/details/79976431)了解每个属性是如何打包的。打包器决定如何包装。我们必须调用super.do_pack（）来打包超类的属性（第5行）
~~~
   virtual function void do_pack( uvm_packer packer );
      bit       R1; // reserved bit
      bit [5:0] R6; // reserved bits
 
      super.do_pack( packer );
      packer.pack_field_int( .value( flavor     ), .size( 3 ) );
      packer.pack_field_int( .value( color      ), .size( 2 ) );
      packer.pack_field_int( .value( sugar_free ), .size( 1 ) );
      packer.pack_field_int( .value( sour       ), .size( 1 ) );
      packer.pack_field_int( .value( R1         ), .size( 1 ) );
      packer.pack_field_int( .value( taste      ), .size( 2 ) );
      packer.pack_field_int( .value( R6         ), .size( 6 ) );
   endfunction: do_pack
~~~
* do_unpack
do_unpack（）方法由unpack（），unpack_bytes（）和unpack_ints（）方法调用。 do_unpack（）用于使用uvm_packer策略对象解压jelly_bean_transaction对象的每个属性。分包器决定了拆包应该如何完成。我们必须调用super.do_unpack（）来解压超级类的属性（第5行）。
~~~
   virtual function void do_unpack( uvm_packer packer );
      bit       R1; // reserved bit
      bit [5:0] R6; // reserved bits
 
      super.do_unpack( packer );
      flavor     = flavor_e'( packer.unpack_field_int( .size( 3 ) ) );
      color      = color_e '( packer.unpack_field_int( .size( 2 ) ) );
      sugar_free =            packer.unpack_field_int( .size( 1 ) );
      sour       =            packer.unpack_field_int( .size( 1 ) );
      R1         =            packer.unpack_field_int( .size( 1 ) );
      taste      = taste_e '( packer.unpack_field_int( .size( 2 ) ) );
      R6         =            packer.unpack_field_int( .size( 6 ) );
   endfunction: do_unpack
~~~

### 注意事项