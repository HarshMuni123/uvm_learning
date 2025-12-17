`include "uvm_macros.svh"
import uvm_pkg::*;

class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  int data = 12;
  uvm_blocking_put_port #(int) port;
  
  function new(input string path = "producer",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    port = new("port",this);                   
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("PROD", $sformatf("PROD: DATA SENT = %0d", data), UVM_NONE);
    port.put(data);
    phase.drop_objection(this);
  endtask
  
  
endclass

class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  int data = 12;
  uvm_blocking_put_imp #(int,consumer) imp;
  
  function new(input string path = "consumer",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    imp = new("imp",this);                   
  endfunction
  
  task put(input int datar);
    `uvm_info("CON",$sformatf("DATA RCVD = %0d", datar), UVM_NONE);
  endtask
  
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  
  producer p;
  consumer c;
  
  function new(input string path = "env",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    p = producer::type_id::create("p",this);
    c = consumer::type_id::create("c",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    p.port.connect(c.imp);
  endfunction
  
endclass

class test extends uvm_test;
  `uvm_component_utils(test)
  
  env e;
  
  function new(input string path = "test",uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    e = env::type_id::create("e",this);
  endfunction 
  
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction
  
  
endclass

module tb;
  
  initial begin
    run_test("test");
  end
  
endmodule
            

                               
