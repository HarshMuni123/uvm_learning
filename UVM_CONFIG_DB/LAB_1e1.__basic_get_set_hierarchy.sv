
`include "uvm_macros.svh"
import uvm_pkg::*;


// transaction

class trnx extends uvm_sequence_item;
  `uvm_object_utils(trnx);
  
  function new(string path="trnx");
    super.new(path);
  endfunction
  
endclass


// driver

class driver extends uvm_driver #(trnx);
  `uvm_component_utils(driver)
  
  int data;
  
  function new(string path="drv",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(int)::get(this,"","data",data))
      `uvm_fatal("drv","data not found");
    `uvm_info("drv",$sformatf("data = %0d",data),UVM_NONE);
                 
  endfunction
  
endclass

// agent

class agent extends uvm_component;
  `uvm_component_utils(agent)
    
  driver drv;
  
  function new(string path="drv",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = driver::type_id::create("drv",this);
  endfunction
  
endclass
  
// env

class env extends uvm_env;
  `uvm_component_utils(env)
    
  agent ag;
  
  function new(string path="env",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ag = agent::type_id::create("ag",this);
  endfunction
  
endclass  
 
// test class

class test extends uvm_test;
  `uvm_component_utils(test)
    
  env e;
  
  function new(string path="test",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    e = env::type_id::create("e",this);
    //// lets see which works
    /// In uvm_config_db, when multiple entries match, the LAST set() WINS — if they are at the same hierarchy level.
    uvm_config_db#(int)::set(this,"*","data",99);
    uvm_config_db#(int)::set(this,"e.ag.drv","data",12); 
    // but this time this one is closer so we get 12 not file,if this line not there, then 5 would print
    uvm_config_db#(int)::set(this,"e.ag","data",5);
    
    
  endfunction
  
endclass  



module tb;
  
  initial begin
    run_test("test");
  end
  
endmodule




  
