# ECE410 Hardware Accelerator: 2D Convolution

This repository contains the hardware design, verification, and physical synthesis of a 2D convolution accelerator utilizing an AXI4-Stream interface. The final architecture features a fully pipelined, sliding-window compute core with on-chip line buffers, successfully shifting the design into the compute-bound region of the Roofline model (9.0 Ops/byte) and achieving a peak throughput of 1.8 GOPS.

* **[Milestone 4 (M4) Submission Details](project/m4/README.md)**
* **[Design Justification & Roofline Report](project/m4/benchmark.md)**
