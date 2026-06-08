# Milestone 4: Physical Synthesis and Final Benchmarking

This directory contains the final deliverables for the M4 Capstone submission. The RTL in this folder represents the final, fully synthesized architecture that produced the 1.8 GOPS throughput benchmark.

## RTL Updates from M3
The core architecture remains consistent with the M3 pipeline, with strict refinements made to the AXI4-Stream handshake logic to ensure robust backpressure management. The module utilizes a sliding-window dataflow with two internal line buffers and a 3x3 shift-register grid, perfectly saturating the 9 MAC units every clock cycle after an initial 58-cycle warmup latency.

## Deliverables Checklist
* **Final RTL & Testbench:** Located in `rtl/` and `tb/`.
* **Simulation Verification:** `sim/final_run.log` and `sim/final_waveform.png` demonstrate cycle-accurate AXI streaming and a verified 58-cycle initial latency.
* **OpenLane 2 Synthesis:** The `synth/` directory contains the full suite of physical implementation reports (Timing, Area, Power) targeting the Sky130 node at 100 MHz.
* **Benchmarks:** `bench/` contains the raw CSV data, summary analysis, and the annotated roofline plot demonstrating the shift to a compute-bound regime.
* **Design Justification:** `report/design_justification.pdf` contains the comprehensive engineering analysis of the architecture, dataflow, and design tradeoffs.
