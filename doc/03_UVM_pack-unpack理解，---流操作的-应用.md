
cqe_pkt.pack(cqe_data_bit_arrary); //cqe_data_bit_arrary[7:0] 是cqe_pkt的注册的最后一个字节
cqe_pkt.pack_ints(cqe_data_int_arrary); //cqe_data_int_arrary[0] 是cqe_pkt的注册的第一个字节

~~~

~~~