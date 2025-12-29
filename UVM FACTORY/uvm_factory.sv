
`include "uvm_macros.svh"
import uvm_pkg::*;

class base extends uvm_component;
  `uvm_component_utils(base)
  
  function new(string path = "base",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("BASE","This is base class",UVM_MEDIUM);
    phase.drop_objection(this);
  endtask
  
endclass
  
class base_error extends base;
  `uvm_component_utils(base_error)
  
  function new(string path = "base_error",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("BASE","This is base error class",UVM_MEDIUM);
    phase.drop_objection(this);
  endtask
  
endclass

class env extends uvm_env;
  `uvm_component_utils(env)
  
  base b;
  
  function new(string path = "env",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    b = base::type_id::create("b",this);
    
    `uvm_info("ENV",$psprintf("Factory component returned :type = %s , path = %s",b.get_type_name(),b.get_full_name()),UVM_MEDIUM);
    
  endfunction
  
  
endclass

class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  
  env e;

  function new(string path = "my_test",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    uvm_factory factory= uvm_factory::get();
    
    super.build_phase(phase);
    
    //set_type_override_by_type(base::get_type(),base_error::get_type());
    factory.set_type_override_by_name("base","base_error");
    factory.print();
    
    e = env::type_id::create("e",this);
    
  endfunction
  
endclass
  
module tb;
  initial run_test("my_test");
endmodule





