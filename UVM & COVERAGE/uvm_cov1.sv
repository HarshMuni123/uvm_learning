

`include "uvm_macros.svh"
import uvm_pkg::*;


class packet extends uvm_object;

  rand bit [2:0] data;
  rand bit [3:0] addr;
  
  function new(string path = "packet");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(packet)
  `uvm_field_int(data,UVM_DEFAULT)
  `uvm_field_int(addr,UVM_DEFAULT)
  `uvm_object_utils_end
  
endclass



class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  uvm_analysis_port #(packet) prod_port;

  function new(string path = "producer",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    prod_port = new("prod_port",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    packet pkt;
    phase.raise_objection(this);
    repeat(20) begin
      pkt = packet::type_id::create("pkt");
      assert(pkt.randomize());
      //`uvm_info("PROD",$psprintf("Producer data sent: data = %0d , addr = %0d",pkt.data,pkt.addr),UVM_LOW);
      prod_port.write(pkt);
      #5;
    end
    phase.drop_objection(this);
  endtask

endclass
  
  
  
class coverage extends uvm_subscriber #(packet);
  `uvm_component_utils(coverage)
  
  packet pkt;
  
  covergroup c_pkg;
    option.per_instance = 1;
    option.name = "consumer coverage";
    
    addr_cp:coverpoint pkt.addr {
      bins low = {[0:3]};
      bins mid = {[4:7]};
      bins high = {[8:15]};
    }
    
    data_cp:coverpoint pkt.data;
    
    cross addr_cp,data_cp;
    
  endgroup
  
  function new(string path = "coverage",uvm_component parent);
    super.new(path,parent);
    c_pkg = new();
  endfunction
  
  function void write(packet t);
    pkt = t;
    //`uvm_info("COV",$psprintf("Data sampled: data = %0d , addr = %0d",t.data,t.addr),UVM_LOW);
    c_pkg.sample();
  endfunction

  
endclass


class env extends uvm_env;
  `uvm_component_utils(env)
  
  producer p;
  coverage cov;
  
  function new(string path = "env",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p = producer::type_id::create("p",this);
    cov = coverage::type_id::create("cov",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    p.prod_port.connect(cov.analysis_export);
  endfunction
  
endclass
  
  
class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  env e;

  function new(string name = "my_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    e = env::type_id::create("e", this);
  endfunction
  
endclass

 
module tb;
  initial run_test("my_test");
endmodule

/*
vsim +access+r;
run -all;
acdb save;
acdb report -db fcover.acdb -txt -o cov.txt -verbose
exec cat cov.txt;
exit

*/
  
  
  
