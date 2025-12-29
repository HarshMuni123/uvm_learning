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
  
  uvm_nonblocking_put_port #(packet) prt;
  
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
      if(prt.try_put(pkt)) begin
        `uvm_info("componentA","fifo try put success",UVM_LOW)
        pkt.print();
      end else begin
        `uvm_warning("componentA","fifo full packet dropped")
      end
      #1;
    end
    phase.drop_objection(this);
  endtask
  
endclass
  
class componentB extends uvm_component;
  `uvm_component_utils(componentB)
  
  uvm_nonblocking_get_port #(packet) exprt;
  
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
      if(exprt.try_get(pkt)) begin
      `uvm_info("componentB", "try getsuccess", UVM_LOW)
        pkt.print();
      end else begin
        `uvm_info("componentB", "FIFO empty", UVM_LOW)
      end
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
# KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 0: uvm_test_top.cmp1 [componentA] fifo try put success
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @443 
# KERNEL:   data  integral  3     'h6  
# KERNEL:   addr  integral  4     'h1  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 1: uvm_test_top.cmp1 [componentA] fifo try put success
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @459 
# KERNEL:   data  integral  3     'h1  
# KERNEL:   addr  integral  4     'h8  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(107) @ 2: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_WARNING /home/runner/testbench.sv(46) @ 2: uvm_test_top.cmp1 [componentA] fifo full packet dropped
# KERNEL: UVM_WARNING /home/runner/testbench.sv(46) @ 3: uvm_test_top.cmp1 [componentA] fifo full packet dropped
# KERNEL: UVM_INFO /home/runner/testbench.sv(107) @ 4: uvm_test_top [my_test] used=2 , full=1 , empty = 0
# KERNEL: UVM_WARNING /home/runner/testbench.sv(46) @ 4: uvm_test_top.cmp1 [componentA] fifo full packet dropped
# KERNEL: UVM_INFO /home/runner/testbench.sv(74) @ 5: uvm_test_top.cmp2 [componentB] try getsuccess
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @443 
# KERNEL:   data  integral  3     'h6  
# KERNEL:   addr  integral  4     'h1  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(107) @ 6: uvm_test_top [my_test] used=1 , full=0 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(107) @ 8: uvm_test_top [my_test] used=1 , full=0 , empty = 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(74) @ 10: uvm_test_top.cmp2 [componentB] try getsuccess
# KERNEL: -----------------------------
# KERNEL: Name    Type      Size  Value
# KERNEL: -----------------------------
# KERNEL: pkt     packet    -     @459 
# KERNEL:   data  integral  3     'h1  
# KERNEL:   addr  integral  4     'h8  
# KERNEL: -----------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(107) @ 10: uvm_test_top [my_test] used=0 , full=0 , empty = 1
# KERNEL: UVM_INFO /home/runner/testbench.sv(107) @ 12: uvm_test_top [my_test] used=0 , full=0 , empty = 1
# KERNEL: UVM_INFO /home/runner/testbench.sv(107) @ 14: uvm_test_top [my_test] used=0 , full=0 , empty = 1
# KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 15: uvm_test_top.cmp2 [componentB] FIFO empty
# KERNEL: UVM_INFO /home/runner/testbench.sv(107) @ 16: uvm_test_top [my_test] used=0 , full=0 , empty = 1
# KERNEL: UVM_INFO /home/runner/testbench.sv(107) @ 18: uvm_test_top [my_test] used=0 , full=0 , empty = 1
# KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 20: uvm_test_top.cmp2 [componentB] FIFO empty
# KERNEL: UVM_INFO /home/runner/testbench.sv(107) @ 20: uvm_test_top [my_test] used=0 , full=0 , empty = 1
# KERNEL: UVM_INFO /home/runner/testbench.sv(77) @ 25: uvm_test_top.cmp2 [componentB] FIFO empty
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 25: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 25: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :   20
# KERNEL: UVM_WARNING :    3
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    0
# KERNEL: ** Report counts by id
# KERNEL: [RNTST]     1
# KERNEL: [TEST_DONE]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: [componentA]     5
# KERNEL: [componentB]     5
# KERNEL: [my_test]    10

  */
  
  
