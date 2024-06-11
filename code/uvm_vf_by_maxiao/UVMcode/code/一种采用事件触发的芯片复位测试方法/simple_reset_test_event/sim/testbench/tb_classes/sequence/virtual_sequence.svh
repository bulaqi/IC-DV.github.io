
class virtual_sequence extends uvm_sequence #(uvm_sequence_item);
   `uvm_object_utils(virtual_sequence)

   random_sequence random_seq;
   bus_sequence bus_seq;

   sequencer sequencer_h;
   bus_sequencer bus_sequencer_h;

   function new(string name = "virtual_sequence");
      super.new(name);
      random_seq = random_sequence::type_id::create("random_seq");
      bus_seq = bus_sequence::type_id::create("bus_seq");
   endfunction : new

   task body();
   	  random_seq.start(sequencer_h);
   	  bus_seq.start(bus_sequencer_h);
   endtask : body
endclass : virtual_sequence
