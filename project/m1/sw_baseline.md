# Software Baseline Benchmark

### Environment and Platform Details
To ensure strict reproducibility for the final M4 hardware comparison, the software baseline was profiled on the following host environment:
* **Host Hardware:** MacBook Air 
* **Operating System:** macOS
* **Python Version:** Python 3.9
* **Profiling Tool:** Built-in `cProfile` module

### Algorithm Configuration
The baseline was generated using the pure NumPy `cnn_backprop` implementation with the following configuration:
* **Dataset:** Synthetic (generated internally, zero dependencies)
* **Network Config:** `small` (1 Conv2D layer with 8 filters of 3x3)
* **Input Shape:** (1, 16, 16)
* **Batch Size:** 32
* **Epochs:** 3

### Execution Command
The profile data was captured by running the following command from within the `cnn_backprop` directory:
\`\`\`bash
python3 -m cProfile -s cumtime train.py --data synthetic --epochs 3 > ../codefest/cf02/profiling/project_profile.txt
\`\`\`

### Bottleneck Identification
The profiling output confirms that the pure software implementation is severely bottlenecked by the spatial loops in the `_im2col` operation within the `Conv2D` layer. The host CPU spends the vast majority of its cumulative execution time inside this specific method due to redundant memory fetches and a lack of hardware-level parallelization.
