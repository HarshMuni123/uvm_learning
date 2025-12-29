`include "uvm_macros.svh"
import uvm_pkg::*;

class packet extends uvm_object;
  //`uvm_object_utils(packet)
  
  rand logic [3:0] addr;
  rand logic [2:0] data;
  
  function new(string path = "packet");
    super.new(path);
  endfunction
  
  `uvm_object_utils_begin(packet)
  `uvm_field_int(data,UVM_DEFAULT);
  `uvm_field_int(addr,UVM_DEFAULT);
  `uvm_object_utils_end


              
endclass

class componentA extends uvm_component;
  `uvm_component_utils(componentA)
  
  uvm_blocking_put_port #(packet) prt;
  
  function new(string path = "componentA",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    prt = new("prt",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    packet pkt;
    phase.raise_objection(this);
    repeat(5) begin
    pkt = packet::type_id::create("pkt");
    assert(pkt.randomize());
    prt.put(pkt);
      `uvm_info("componentA", "Sending packet", UVM_LOW);
      pkt.print(uvm_default_line_printer);
      #1;
    end
    phase.drop_objection(this);
  endtask
  
endclass
  
class componentB extends uvm_component;
  `uvm_component_utils(componentB)
  
  uvm_blocking_get_port #(packet) exprt;
  
  function new(string path = "componentB",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    exprt = new("exprt",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    packet pkt;
    phase.raise_objection(this);
    repeat(5) begin
      #5;
    exprt.get(pkt);
      `uvm_info("componentB", "Recieving packet", UVM_LOW);
    pkt.print();
    end
    phase.drop_objection(this);
  endtask
  
endclass
  
class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  componentA cmp1;
  componentB cmp2;
  
  uvm_tlm_fifo #(packet) tlm_fifo;
  
  function new(string path = "my_test",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    cmp1 = componentA::type_id::create("cmp1",this);
    cmp2 = componentB::type_id::create("cmp2",this);
    tlm_fifo = new("tlm_fifo",this,2);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    repeat(10) begin
      #2;
      `uvm_info("my_test",$sformatf("used=%0d , full=%0d , empty = %0d",tlm_fifo.used(),tlm_fifo.is_full(),tlm_fifo.is_empty()),UVM_LOW);
    end
    phase.drop_objection(this);
  endtask
  
  function void connect_phase(uvm_phase phase);
    cmp1.prt.connect(tlm_fifo.put_export);
    cmp2.exprt.connect(tlm_fifo.get_export);
  endfunction
  
endclass


module tb;
  initial run_test("my_test");
endmodule
  
/*
# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test my_test...
# KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 0: uvm_test_top.cmp1 [componentA] Sending packet
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @443 
# KERNEL:   data  integral  3     'h6  
# KERNEL:   addr  integral  4     'h1  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 1: uvm_test_top.cmp1 [componentA] Sending packet
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @459 
# KERNEL:   data  integral  3     'h1  
# KERNEL:   addr  integral  4     'h8  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(101) @ 2: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(101) @ 4: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 5: uvm_test_top.cmp2 [componentB] Recieving packet
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @443 
# KERNEL:   data  integral  3     'h6  
# KERNEL:   addr  integral  4     'h1  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 5: uvm_test_top.cmp1 [componentA] Sending packet
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @464 
# KERNEL:   data  integral  3     'h5  
# KERNEL:   addr  integral  4     'h9  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(101) @ 6: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(101) @ 8: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 10: uvm_test_top.cmp2 [componentB] Recieving packet
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @459 
# KERNEL:   data  integral  3     'h1  
# KERNEL:   addr  integral  4     'h8  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(101) @ 10: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 10: uvm_test_top.cmp1 [componentA] Sending packet
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @473 
# KERNEL:   data  integral  3     'h3  
# KERNEL:   addr  integral  4     'h1  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(101) @ 12: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(101) @ 14: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 15: uvm_test_top.cmp2 [componentB] Recieving packet
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @464 
# KERNEL:   data  integral  3     'h5  
# KERNEL:   addr  integral  4     'h9  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 15: uvm_test_top.cmp1 [componentA] Sending packet
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @482 
# KERNEL:   data  integral  3     'h6  
# KERNEL:   addr  integral  4     'h0  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(101) @ 16: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(101) @ 18: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 20: uvm_test_top.cmp2 [componentB] Recieving packet
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @473 
# KERNEL:   data  integral  3     'h3  
# KERNEL:   addr  integral  4     'h1  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(101) @ 20: uvm_test_top [my_test] used=1 , full=0 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(71) @ 25: uvm_test_top.cmp2 [componentB] Recieving packet
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @482 
# KERNEL:   data  integral  3     'h6  
# KERNEL:   addr  integral  4     'h0  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 25: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 25: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :   23
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    0
# KERNEL: ** Report counts by id
# KERNEL: [RNTST]     1
# KERNEL: [TEST_DONE]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: [componentA]     5
# KERNEL: [componentB]     5
# KERNEL: [my_test]    10
# KERNEL: 
*/  
  
  
