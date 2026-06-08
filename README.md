# ECE 410/510 Capstone: AI Hardware Accelerator

**Author:** Michael Ngo
**Term:** Spring 2026

## Project Overview
This repository contains the complete RTL design, verification, and physical synthesis of a custom hardware accelerator for 3x3 spatial convolutions. Designed as the final capstone project for ECE 410/510, the architecture successfully shifts a memory-bound software kernel into a compute-bound silicon powerhouse.

## Final Architecture Specs
* **Kernel:** 3x3 Convolution (Edge Detection / Image Processing)
* **Precision:** 8-bit fixed-point inputs/weights, 32-bit accumulation
* **Interface:** AMBA AXI4-Stream (`s_axis` / `m_axis`)
* **Dataflow:** Hybrid Weight-Stationary / Input-Stationary with internal line buffering
* **Target Node:** Skywater 130nm (Sky130) via OpenLane 2
* **Target Frequency:** 100 MHz

## Final Performance Benchmarks
By successfully caching overlapping row data via internal shift registers, the hardware accelerator achieved massive efficiency gains over the M1 software baseline:
* **Throughput:** 1.8 GOPS (Giga-Operations Per Second)
* **Arithmetic Intensity:** 18.0 Ops/Byte (Compute-Bound)
* **Speedup:** 36x faster than software execution
* **Energy Efficiency:** ~2.1 mJ per frame (vs 45.0 mJ in software)

## Directory Structure
* `project/m1/` - Software profiling and baseline measurements
* `project/m2/` - Algorithmic modeling and precision analysis
* `project/m3/` - Initial RTL pipeline design
* `project/m4/` - Final physical synthesis, verification, and benchmark reports
