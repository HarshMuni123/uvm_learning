

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef int arr_t[3];

class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  arr_t bank[$];
  
  uvm_blocking_get_imp #(arr_t,producer) get_imp;
  
  function new(string path = "prod",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    get_imp = new("get_imp",this);
    bank.push_back('{1,2,3});
    bank.push_back('{5,6,7});
  endfunction
  
  task get(output arr_t data);
    data = bank.pop_front();
    foreach(data[i])
      `uvm_info("prod",$sformatf("prod: served data arr[%0d] = %0d",i,data[i]),UVM_NONE);
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
  consumer c1,c2;
  
  uvm_blocking_get_export #(arr_t) get_export;
  
  function new(string path = "env",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    get_export = new("get_export",this);
    p = producer::type_id::create("p",this);
    c1 = consumer::type_id::create("c1",this);
    c2= consumer::type_id::create("c2",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    c1.get_port.connect(get_export);
    c2.get_port.connect(get_export);
    get_export.connect(p.get_imp);
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












