
`include "uvm_macros.svh"
import uvm_pkg::*;


// TLM PART 3 -- Multi - Port

typedef int arr_t[3];

class producer extends uvm_component;
  
  `uvm_component_utils(producer)
  arr_t arr;
  
  uvm_blocking_put_port #(arr_t) port;
  
  function new(string path = "prod",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    port = new("port",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    	port.put(arr);
    phase.drop_objection(this);
  endtask
  
endclass


// consumer


class consumer extends uvm_component;
  
  `uvm_component_utils(consumer)
  
  uvm_blocking_put_imp #(arr_t,consumer) imp;
  
  function new(string path = "con",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    imp = new("imp",this);
  endfunction
  
  task put(arr_t arr);
    foreach(arr[i]) 
      `uvm_info("con",$sformatf("CON: DATA REC arr[%0d] = %0d",i,arr[i]),UVM_NONE);
  endtask
    
  
endclass

    
// env


class env extends uvm_env;
  `uvm_component_utils(env)
  
  uvm_blocking_put_export #(arr_t) exp;
  
  producer p1;
  producer p2;
  consumer c;
  
  function new(string path = "env",uvm_component parent);
    super.new(path,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    exp = new("exp",this);
    p1 = producer::type_id::create("p1",this);
    p2 = producer::type_id::create("p2",this);
    c = consumer::type_id::create("c",this);
    p1.arr = '{1,2,3};
    p2.arr = '{5,6,7};
  endfunction
    
  virtual function void connect_phase(uvm_phase phase);
    p1.port.connect(exp);
    p2.port.connect(exp);
    exp.connect(c.imp);
  endfunction
  
endclass



    
// env


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


// testbench

module tb;
  
  initial begin
    run_test("test");
  end
  
endmodule
    
    
    
    
    
    
    
