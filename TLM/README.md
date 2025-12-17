# UVM TLM Ports, Exports, and Imps — Producer–Consumer Example

This document explains how **UVM TLM (Transaction-Level Modeling)** communication works using  
**ports, exports, and implementations (imp)**, with a simple **producer → consumer** example.

---

## 1. Why TLM in UVM?

UVM TLM provides:
- **Loose coupling** between components
- **Reusable** and **scalable** testbenches
- Clear **direction of data flow**

Instead of calling methods directly, components communicate through **interfaces (ports)**.

---

## 2. Key TLM Components

### 2.1 Port
- Declares **what a component wants to do**
- Does **not** implement functionality
- Used by **initiator** (producer)

Example:
```systemverilog
uvm_blocking_put_port #(int) port;
+------------+        put(data)        +-------------+
|            | ---------------------> |             |
|  PRODUCER  |                        |  CONSUMER   |
|            |        int data        |             |
+------------+                        +-------------+
      |                                      ^
      |                                      |
      |          port.connect(imp)           |
      +--------------------------------------+


```

