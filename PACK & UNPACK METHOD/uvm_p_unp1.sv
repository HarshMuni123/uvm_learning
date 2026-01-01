
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


class packing extends uvm_test;
  `uvm_component_utils(packing)
    
  function new(string path = "packing",uvm_component parent);
    super.new(path,parent);
  endfunction
  
  int m1_val,m2_val,m3_val;
  
  bit m_bits[];
  byte unsigned m_bytes[];
  int unsigned m_int[];
  
  function void build_phase(uvm_phase phase);
    packet pkt,pkt1;
    super.build_phase(phase);
    pkt = packet::type_id::create("pkt");
    pkt1 = packet::type_id::create("pkt1");
    
    assert(pkt.randomize());
    pkt.print();
    
    pkt.pack(m_bits);
    pkt.pack_bytes(m_bytes);
    pkt.pack_ints(m_int);
    
    `uvm_info(get_type_name(),$psprintf("m bits = %0p",m_bits),UVM_LOW);
    `uvm_info(get_type_name(),$psprintf("m bytes = %0p",m_bytes),UVM_LOW);
    `uvm_info(get_type_name(),$psprintf("m int = %0p",m_int),UVM_LOW);
    
    m1_val = pkt1.unpack(m_bits);
    m2_val = pkt1.unpack_bytes(m_bytes);
    m3_val = pkt1.unpack_ints(m_int);
    pkt1.print();
    
    assert(pkt.data == pkt1.data);
    assert(pkt.addr == pkt1.addr);
    
    `uvm_info(get_type_name(),$psprintf("m bits unpack = 0x%0h",m1_val),UVM_LOW);
    `uvm_info(get_type_name(),$psprintf("m bytes unpack = 0x%0h",m2_val),UVM_LOW);
    `uvm_info(get_type_name(),$psprintf("m int unpack = 0x%0h",m3_val),UVM_LOW);
    
  endfunction
  
endclass

module tb;
  initial run_test("packing");
endmodule
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
