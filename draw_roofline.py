import matplotlib.pyplot as plt
import numpy as np
import os

os.makedirs("codefest/cf02/profiling", exist_ok=True)

# Hardware 1: Host CPU 
cpu_peak_flops = 100  # GFLOP/s 
cpu_peak_bw = 50      # GB/s

# Hardware 2: Hypothetical Custom Accelerator
# Lower total compute, but massively high ON-CHIP SRAM bandwidth
hw_peak_flops = 20    # GFLOP/s 
hw_peak_bw = 400      # GB/s

ai_kernel = 1.058 # From our manual calculation

def plot_roofline(peak_flops, peak_bw, label, color):
    ai_vals = np.logspace(-2, 3, 500)
    perf = np.minimum(peak_flops, peak_bw * ai_vals)
    plt.plot(ai_vals, perf, label=label, color=color, linewidth=2)

plt.figure(figsize=(10, 6))

plot_roofline(cpu_peak_flops, cpu_peak_bw, "Host CPU Baseline", "blue")
plot_roofline(hw_peak_flops, hw_peak_bw, "Custom Accelerator (SRAM Buffered)", "red")

# Plot Software Kernel
cpu_perf = min(cpu_peak_flops, cpu_peak_bw * ai_kernel)
plt.scatter(ai_kernel, cpu_perf, color='blue', s=100, zorder=5)
plt.annotate(f"Software Kernel\n(AI: {ai_kernel:.2f})", 
             (ai_kernel, cpu_perf), textcoords="offset points", xytext=(10,-25), color='blue')

# Plot Hardware Kernel
hw_perf = min(hw_peak_flops, hw_peak_bw * ai_kernel)
plt.scatter(ai_kernel, hw_perf, color='red', s=100, zorder=5)
plt.annotate(f"HW Accelerated Kernel\n(AI: {ai_kernel:.2f})", 
             (ai_kernel, hw_perf), textcoords="offset points", xytext=(10,10), color='red')

plt.xscale('log')
plt.yscale('log')
plt.xlabel('Arithmetic Intensity (FLOP/byte)')
plt.ylabel('Performance (GFLOP/s)')
plt.title('Project Roofline: CNN Conv2D Kernel')
plt.grid(True, which="both", ls="--", alpha=0.5)
plt.legend()

output_path = "codefest/cf02/profiling/roofline_project.png"
plt.savefig(output_path, dpi=300, bbox_inches='tight')
print(f"Success! Saved to {output_path}")