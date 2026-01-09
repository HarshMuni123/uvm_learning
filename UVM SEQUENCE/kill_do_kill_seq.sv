

`include "uvm_macros.svh"
import uvm_pkg::*;


class seq_item extends uvm_sequence_item;
  
  rand bit [2:0] data;
  rand bit response;
  
  `uvm_object_utils_begin(seq_item)
  `uvm_field_int(data,UVM_DEFAULT)
  `uvm_field_int(response,UVM_DEFAULT)
  `uvm_object_utils_end
  
  function new(string name = "seq_item");
    super.new(name);
  endfunction
  
endclass

class core_sequencer extends uvm_sequencer#(seq_item);
  `uvm_component_utils(core_sequencer)
  
  function new(string name = "core_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass

class core_A_seq extends uvm_sequence#(seq_item);
  `uvm_object_utils(core_A_seq)
  `uvm_declare_p_sequencer(core_sequencer)
  
  function new(string name = "core_A_seq");
    super.new(name);
  endfunction
  
  virtual function void do_kill();
    `uvm_info("core_A","SEQ A CLEANUP IN DO_KILL",UVM_LOW)
    super.do_kill();
  endfunction
  
  task body();
    seq_item req;
    lock(p_sequencer);
    req = seq_item::type_id::create("req");
    repeat(3) begin
      start_item(req);
      assert(req.randomize());
      `uvm_info("core_A_LOCK",$psprintf("data sent sequencer A: 0x%0h",req.data),UVM_LOW);
      finish_item(req);
      #15;
    end
    unlock(p_sequencer);
  endtask
  
endclass
  
  
class core_B_seq extends uvm_sequence#(seq_item);
  `uvm_object_utils(core_B_seq)
  
  function new(string name = "core_B_seq");
    super.new(name);
  endfunction
  
  task body();
    seq_item req;
    req = seq_item::type_id::create("req");
    repeat(3) begin
      start_item(req);
      assert(req.randomize());
      `uvm_info("core_B",$psprintf("data sent sequencer B: 0x%0h",req.data),UVM_LOW);
      finish_item(req);
    end
  endtask
  
endclass

class core_driver extends uvm_driver#(seq_item);
  `uvm_component_utils(core_driver)
  
  function new(string name = "core_driver",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    seq_item req;
    forever begin
      seq_item_port.get_next_item(req);
      //`uvm_info("DRV", req.sprint(), UVM_MEDIUM);
      
      seq_item_port.item_done();
    end
  endtask
  
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  
  core_A_seq A_seq;
  core_B_seq B_seq;
  core_sequencer seqr;
  core_driver drv;
  
  function new(string name = "test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    A_seq = core_A_seq::type_id::create("A_seq");
    B_seq = core_B_seq::type_id::create("B_seq");
    seqr = core_sequencer::type_id::create("seqr",this);
    drv = core_driver::type_id::create("drv",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    fork
      begin 
        A_seq.start(seqr);
      end
      begin
        #20;
        B_seq.start(seqr);
      end
    join_none
    #30;
    `uvm_info("TEST","Killing sequence",UVM_LOW)
    A_seq.kill();
    #50;
    phase.drop_objection(this);
  endtask
  
endclass
  
module tb;
  initial run_test();
endmodule
  
