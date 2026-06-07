# Milestone 4 Final Submission

This directory contains the final RTL, testbenches, synthesis configurations, and reports for the compute-bound 2D convolution accelerator.

## File Catalog

* `README.md` - This catalog file. (Supports: M4 folder README checklist item).
* `benchmark.md` - The comprehensive 9-section Design Justification report, detailing Roofline analysis, energy efficiency (298.5 GOPS/W), and physical layout metrics. (Supports: Design Justification report checklist item).
* `rtl/top.sv` - Top-level wrapper integrating the AXI4-Stream adapter and the compute core. (Supports: RTL Source code).
* `rtl/interface.sv` - AXI4-Stream handshake adapter and width converter logic. (Supports: RTL Source code).
* `rtl/compute_core.sv` - The 3x3 sliding-window compute core featuring 25-element line buffers and a fully unrolled pipelined MAC array. (Supports: RTL Source code).
* `tb/tb_top.sv` - End-to-end co-simulation testbench simulating a continuous 100-pixel stream to verify line-buffer warm-up and dataflow. (Supports: Testbench verification).
* `synth/config.json` - OpenLane configuration file for physical synthesis targeting the Sky130 node. (Supports: Physical Synthesis).
