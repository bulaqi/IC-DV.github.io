makefile
~~~
USER_OPTS ?=
...
ifeq ($(USER_OPTS),fsdb)
	RUN_OPTION ?= +fsdb //注意此处是+
endif
...

ifneq ($(RUN_OPTION),)
	RUN_OPTS += $(RUN_OPTION)
endif

...
.PHONY:run
run:.shadow/dpi_c_comp check_simv
    $(RUN_CMD) $(DEBUGGER) $(RUN_OPTS) $(COVRAGE_RUN_OPTION) $(PA_RUN_OPTION) -l $(RUN_LOG)
...
~~~


xx_top_tb.sv
~~~
initial
begin
	if($test$plusargs("fsdb")) begin
			$fsdbDumpfile("testname.fsdb");  //记录波形，波形名字testname.fsdb
	    	$fsdbDumpvars("+all");  //+all参数，dump SV中的struct结构体
	    	$fsdbDumpon();   
	end
end
~~~

make run UVM_TEST_NAME=aem_cq_sanity USER_OPTS=fsdb

