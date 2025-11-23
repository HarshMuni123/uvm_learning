`include "uvm_macros.svh"
import uvm_pkg::*;

class obj extends uvm_object;

  rand bit [3:0] a;

  `uvm_field_utils_begin(obj)
    `uvm_field_int(a, UVM_DEFAULT)
  `uvm_field_utils_end

  function new(string name = "obj");
    super.new(name);
  endfunction

endclass

module tb;

  obj o;

  initial begin
    o = new("obj");
    o.randomize();
    o.print();
  end

endmodule
