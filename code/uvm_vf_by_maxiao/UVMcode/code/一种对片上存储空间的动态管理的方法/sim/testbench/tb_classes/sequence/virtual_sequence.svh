
class virtual_sequence extends uvm_sequence #(uvm_sequence_item);
   `uvm_object_utils(virtual_sequence)

   reset_sequence reset_seq;
   random_sequence random_seq;
   bus_sequence bus_seq;

   sequencer sequencer_h;
   bus_sequencer bus_sequencer_h;

   function new(string name = "virtual_sequence");
      super.new(name);
      reset_seq = reset_sequence::type_id::create("reset_seq");
      random_seq = random_sequence::type_id::create("random_seq");
      bus_seq = bus_sequence::type_id::create("bus_seq");
   endfunction : new

   task body();
      reset_seq.start(sequencer_h);
      #100ns;
   	  //bus_seq.start(bus_sequencer_h);
   	  random_seq.start(sequencer_h);
   endtask : body
endclass : virtual_sequence
