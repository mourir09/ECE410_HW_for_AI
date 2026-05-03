# HW4AI - Project Milestone 2
## Overview
This repository contains the RTL, testbenches, and simulation artifacts for Milestone 2. The design implements an 8-bit signed Multiply-Accumulate (MAC) compute core wrapped in a fully compliant AXI4-Stream interface.
## Prerequisites & Simulator Version
To reproduce the simulation results from a clean clone, ensure you have the following installed:
* **Simulator:** Icarus Verilog (`iverilog`) and `vvp`
* **Version:** 12.0 (or newer)
* **Waveform Viewer (Optional):** GTKWave, Surfer, or WaveTrace
## Build and Run Instructions
### 1. Compute Core Testbench
This testbench verifies the raw accumulation math of the `INT8` to `INT32` datapath over multiple cycles.
Run the following commands from the root of the repository to compile and simulate:
```bash
iverilog -g2012 -o project/m2/sim/core_sim.vvp project/m2/rtl/compute_core.sv project/m2/tb/tb_compute_core.sv
vvp project/m2/sim/core_sim.vvp
```
### 2. AXI4-Stream Interface Testbench
This testbench wraps the compute core and verifies the TVALID/TREADY handshaking, data unpacking, and backpressure handling capabilities.
Run the following commands from the root of the repository to compile and simulate:
```bash
iverilog -g2012 -o project/m2/sim/interface_sim.vvp project/m2/rtl/compute_core.sv project/m2/rtl/interface.sv project/m2/tb/tb_interface.sv
vvp project/m2/sim/interface_sim.vvp
```
### 3. Generating Simulation Logs
To generate the exact .log files submitted in this repository, pipe the output of the vvp command directly into a text file:
```bash
 vvp project/m2/sim/core_sim.vvp > project/m2/sim/compute_core_run.log
vvp project/m2/sim/interface_sim.vvp > project/m2/sim/interface_run.log
```
