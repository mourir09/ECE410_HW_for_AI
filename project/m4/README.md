# Milestone 4: Physical Synthesis and Final Benchmarking

**Author:** Michael Ngo
**Course:** ECE 410/510 Capstone

This directory contains the final RTL, physical synthesis reports, benchmarks, and documentation for the M4 hardware accelerator submission.

## File Catalog

### RTL (`project/m4/rtl/`)
* `rtl/top.sv` - Top-level module instantiating the streaming interface and the unrolled compute engine. *(Supports: RTL Design)*
* `rtl/interface.sv` - AXI4-Stream handshake logic and shift-register/line buffer memory hierarchy. *(Supports: Hardware interface report section)*
* `rtl/compute_core.sv` - Combinational 9-MAC unrolled compute engine for 3x3 convolutions. *(Supports: Dataflow and architecture report section)*

### Testbench (`project/m4/tb/`)
* `tb/tb_top.sv` - Self-checking SystemVerilog testbench injecting random AXI backpressure to stress internal state retention. *(Supports: Verification report section)*

### Simulation (`project/m4/sim/`)
* `sim/final_run.log` - Icarus Verilog console output proving successful pipeline execution and a 58-cycle warmup latency. *(Supports: Verification report section)*
* `sim/final_waveform.png` - Annotated VCD screenshot demonstrating valid data output and cycle-accurate AXI handshakes. *(Supports: Figures referenced in the report committed)*

### Synthesis (`project/m4/synth/`)
* `synth/config.json` - OpenLane 2 configuration dictating the 100 MHz clock period and Sky130 target node. *(Supports: OpenLane 2 configuration committed)*
* `synth/openlane_run.log` - Captured stdout/stderr from the OpenLane 2 physical implementation flow. *(Supports: OpenLane run log committed)*
* `synth/timing_report.txt` - Post-routing Static Timing Analysis (STA) showing positive slack at 100 MHz. *(Supports: Timing report with critical path and slack)*
* `synth/area_report.txt` - Standard cell count breakdown highlighting the area dominance of the line buffers. *(Supports: Area report with cell counts and total area)*
* `synth/power_report.txt` - Estimated dynamic and static leakage power. *(Supports: Power report with estimate)*

### Benchmarks (`project/m4/bench/`)
* `bench/benchmark_data.csv` - Raw numerical values comparing the software baseline to the hardware execution. *(Supports: Raw measurement data committed)*
* `bench/benchmark.md` - Analysis of the 1.8 GOPS throughput and the calculated 36x speedup. *(Supports: Benchmark comparison / Speedup vs M1)*
* `bench/roofline_final.png` - Log-log plot showing the architecture operating at 18.0 Ops/Byte in the compute-bound region. *(Supports: Final roofline plot)*

### Report (`project/m4/report/`)
* `report/design_justification.pdf` - Comprehensive engineering analysis detailing the shift from memory-bound to compute-bound performance. *(Supports: Report committed as PDF)*
* `report/figures/` - Directory holding isolated image assets referenced in the final PDF. *(Supports: Figures referenced in the report committed)*
