

/// UVM TESTBENCH

`include "uvm_macros.svh"
import uvm_pkg::*;

// transaction class --- track of rtl i/o ports

class transaction extends uvm_sequence_item;

  rand bit [3:0] a;
  rand bit [3:0] b;
  bit [4:0] y;
  
  function new(string path = "transaction");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(transaction)
  	`uvm_field_int(a,UVM_DEFAULT)
  	`uvm_field_int(b,UVM_DEFAULT)
  	`uvm_field_int(y,UVM_DEFAULT)
  `uvm_object_utils_end
  
  
endclass

// sequence -- gen stimuli

class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)
  
  transaction t;
  
  function new(string path = "generator");
    super.new(path);
  endfunction
  
  virtual task body();
   // t = transaction::type_id::create("t");
    repeat(10) begin
    t = transaction::type_id::create("t");
    start_item(t);
      assert(t.randomize()) else `uvm_error("gen","Randomization failed");
      `uvm_info("gen",$sformatf("Data send to Driver a :%0d , b :%0d",t.a,t.b), UVM_NONE);
      finish_item(t);
      
    end
  endtask
  
endclass
  
// driver class --- stimuli to due via interface

class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)
  
  transaction tc;
  virtual adder_if aif;
  
  function new(string path = "driver",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    tc = transaction::type_id::create("tc");
    
    if(!uvm_config_db#(virtual adder_if)::get(this,"","aif",aif))
      `uvm_error("drv","drv unable to sent config db");
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(tc);
      aif.a <= tc.a;
      aif.b <= tc.b;
      `uvm_info("drv", $sformatf("Trigger DUT a: %0d ,b :  %0d",tc.a, tc.b), UVM_NONE);
      seq_item_port.item_done();
      #10;
    end
  endtask
  
endclass
  
// monitor class --- rcv from dut via interface

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  uvm_analysis_port #(transaction) send;
  
  transaction t;
  virtual adder_if aif;
  
  function new(string path = "monitor",uvm_component parent);
    super.new(path,parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    send = new("new",this);
    t = transaction::type_id::create("t");
    
    if(!uvm_config_db #(virtual adder_if)::get(this,"","aif",aif)) 
   `uvm_error("MON","Unable to access uvm_config_db");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      #10;
      t.a = aif.a;
      t.b = aif.b;
      t.y = aif.y;
    `uvm_info("MON", $sformatf("Data send to Scoreboard a : %0d , b : %0d and y : %0d", t.a,t.b,t.y), UVM_NONE);
      send.write(t);
    end
  endtask
  
endclass

// scoreboard class --- compares


class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp #(transaction,scoreboard) imp;
  
  transaction tr;
  
  function new(string name = "scoreboard",uvm_component parent);
    super.new(name,parent);
    imp = new("imp",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    tr = transaction::type_id::create("tr");
  endfunction
  
  virtual function void write(input transaction t);
    tr = t;
    
    `uvm_info("SCO",$sformatf("Data rcvd from Monitor a: %0d , b : %0d and y : %0d",tr.a,tr.b,tr.y), UVM_NONE);
    
    if(tr.y == tr.a + tr.b) 
      `uvm_info("SCO","Test Passed", UVM_NONE)
   else
       `uvm_info("SCO","Test Failed", UVM_NONE)
   endfunction
    
endclass  
  
// agent class --- connect drv mon seqr

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  monitor mon;
  driver drv;
  uvm_sequencer #(transaction) seqr;
  
  function new(string name = "agent",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    mon = monitor::type_id::create("mon",this);
    drv = driver::type_id::create("drv",this);
    seqr = uvm_sequencer #(transaction)::type_id::create("seqr",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass

// env class --- connect sco ag

class env extends uvm_env;
  `uvm_component_utils(env)
  
  agent ag;
  scoreboard sc;
  
  function new(string name = "env",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    ag = agent::type_id::create("ag",this);
    sc = scoreboard::type_id::create("sc",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    ag.mon.send.connect(sc.imp);
  endfunction

endclass

// test class --- final


class test extends uvm_test;
  `uvm_component_utils(test)
  
  env e;
  generator gen;
  
  function new(string name = "test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    e = env::type_id::create("e",this);
    gen = generator::type_id::create("gen",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    gen.start(e.ag.seqr);
    #10;
    phase.drop_objection(this);
  endtask

endclass

/////////// testbench


module tb;
  
  adder_if aif();
  
  adder dut (.a(aif.a),.b(aif.b),.y(aif.y));
  
  initial begin
    uvm_config_db#(virtual adder_if)::set(null,"uvm_test_top.e.ag.*","aif",aif);
    run_test("test");
  end
  
  
endmodule








