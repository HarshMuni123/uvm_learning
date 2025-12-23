

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef int arr_t[3];

class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  arr_t arr = '{1,2,3};
  
  uvm_blocking_get_imp #(arr_t,producer) get_imp;
  
  function new(string path = "prod",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    get_imp = new("get_imp",this);
  endfunction
  
  task get(output arr_t arr);
    arr = this.arr;
    foreach(arr[i])
      `uvm_info("prod",$sformatf("prod: served data arr[%0d] = %0d",i,arr[i]),UVM_NONE);
  endtask
  
endclass


class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  uvm_blocking_get_port #(arr_t) get_port;
  
  function new(string path = "con",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    get_port = new("get_port",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    arr_t rcvd;
    
    phase.raise_objection(this);
    
    get_port.get(rcvd);
    `uvm_info("CONSUMER", $sformatf("Received %p", rcvd), UVM_NONE);
    
    phase.drop_objection(this);
  endtask
  
endclass


class env extends uvm_env;
  `uvm_component_utils(env)
  
  producer p;
  consumer c;
  
  function new(string path = "env",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    p = producer::type_id::create("p",this);
    c = consumer::type_id::create("c",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    c.get_port.connect(p.get_imp);
  endfunction
  
endclass



class test extends uvm_test;
  `uvm_component_utils(test)
  
  env e;
  
  function new(string path = "test",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    e = env::type_id::create("e",this);
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction
  
endclass


module tb;
  
  initial begin
    run_test("test");
  end
  
endmodule












