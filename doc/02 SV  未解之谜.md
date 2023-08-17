axi_data_queue是int的队列，axi_data是长度12的动态数组；
axi_data_queue内有12个数据，期望是全部传给axi_data，实际只传递了6个，原因不详
~~~
foreach(axi_data_queue[i]) begin
   axi_data[i] = axi_data_queue.pop_front();
end
~~~

不要动态的队列的控制循环
