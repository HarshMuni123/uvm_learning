
`include "uvm_macros.svh"
import uvm_pkg::*;

  
/// ------------CHILD CLASS B----------

class B_class extends uvm_component;
  `uvm_component_utils(B_class)
  
  int data;
  
  function new(string path="B_class",uvm_component parent);
    
    super.new(path,parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(int)::get(this,"","data",data))
      `uvm_error(get_type_name(),"DATA IN B NOT RCVD")
    else
      `uvm_info(get_type_name(),$sformatf("DATA RCVD IN B: %0d",data),UVM_NONE);

    
  endfunction
  
  
endclass

/// ------------CHILD CLASS C----------

class C_class extends uvm_component;
  `uvm_component_utils(C_class)
  
    int data;
 
  function new(string path="C_class",uvm_component parent);
    
    super.new(path,parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(int)::get(this,"","data",data))
      `uvm_error(get_type_name(),"DATA IN C NOT RCVD")
    else
      `uvm_info(get_type_name(),$sformatf("DATA RCVD IN C: %0d",data),UVM_NONE);

    
  endfunction
  
endclass

/// ------------PARENT CLASS A----------

class A_class extends uvm_component;
  `uvm_component_utils(A_class)
  
  B_class b;
  C_class c;
  
  function new(string path="A_class",uvm_component parent);
    
    super.new(path,parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    b = B_class::type_id::create("b",this);
    c = C_class::type_id::create("c",this);

  endfunction
  
endclass

/// ------------ ENV CLASS ----------

class env extends uvm_env;
  `uvm_component_utils(env)

  A_class A;

  function new(string path="env",uvm_component parent);
    
    super.new(path,parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    A = A_class::type_id::create("A",this);
    
  endfunction

endclass


/// ------------ TEST CLASS ----------

class test extends uvm_test;
  `uvm_component_utils(test)

  env e;

  function new(string path="test",uvm_component parent);
    
    super.new(path,parent);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    e = env::type_id::create("e",this);
    
    //uvm_config_db#(int)::set(this,"e.A.*","data",33);
    uvm_config_db#(int)::set(this,"e.A.b","data",33);
    uvm_config_db#(int)::set(this,"e.A.c","data",12);
    
  endfunction

endclass

/// ------------ MODULE ----------


module tb;
  
  initial begin
    
    run_test("test");
    
  end
  
endmodule
