# UVM Pack & Unpack Methods – Complete Guide

## Overview

In **UVM (Universal Verification Methodology)**, *pack* and *unpack* methods are used to **serialize and de-serialize transaction objects**.  
They convert class-based objects into a linear stream of bits/bytes/ints and back.

This mechanism is heavily used in:
- TLM communication
- Scoreboards
- Predictors
- Register modeling
- Recording and debugging
- Sending transactions across interfaces or layers

---

## Why Pack / Unpack Exists

SystemVerilog classes are **not directly transferable** across:
- Analysis ports
- TLM FIFOs
- Comparisons
- File dumps
- Predictors

UVM solves this by:
1. **Packing** an object into a linear representation
2. **Transferring / storing / comparing** the data
3. **Unpacking** it back into an object

---

## Basic Flow

Object → Pack → Bit/Byte/Int Stream
Stream → Unpack → Object

---

## Where Pack/Unpack Is Used

| Use Case | Why |
|--------|-----|
| TLM communication | Serialize transactions |
| Scoreboard | Compare expected vs actual |
| Predictor | Decode bus activity |
| Register Model | Map registers to transactions |
| Recording | Store transaction history |
| Debug | Print raw transaction content |

---

## Core Methods Involved

### `do_pack(uvm_packer packer)`
- Packs object fields into a stream
- Automatically called by UVM

### `do_unpack(uvm_packer packer)`
- Unpacks stream back into object fields
- Automatically called by UVM

You **override these methods only if**:
- You need custom packing order
- You skip fields
- You handle dynamic arrays manually

---

## Automatic Packing (Recommended)

Most users rely on **UVM field macros**:

```systemverilog
class my_txn extends uvm_sequence_item;
  rand bit [7:0] addr;
  rand bit [31:0] data;

  `uvm_object_utils_begin(my_txn)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end
endclass


UVM automatically:
Packs
Unpacks
Copies
Compares
Prints


Summary of Pack/Unpack APIs
Method	Description
pack()	Packs into bit array
unpack()	Unpacks from bit array
pack_bytes()	Packs into byte array
unpack_bytes()	Unpacks from byte array
pack_ints()	Packs into int array
unpack_ints()	Unpacks from int array
do_pack()	User-overridable pack logic
do_unpack()	User-overridable unpack logic
