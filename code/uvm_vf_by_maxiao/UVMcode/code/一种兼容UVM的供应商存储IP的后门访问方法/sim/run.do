	rm  *.log -rf csrc
	vcs -timescale=1ns/1ns \
        -sverilog \
		${UVM_HOME}/src/dpi/uvm_dpi.cc \
		-CFLAGS -DVCS \
        -debug_all \
		-f filelist/dut.f \
		-f filelist/tb.f \
		-l com.log 

	./simv -l sim.log +UVM_TESTNAME=virtual_sequence_test

