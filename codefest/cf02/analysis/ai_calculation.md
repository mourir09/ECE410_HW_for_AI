# Arithmetic Intensity Calculation for Conv2D

**Target Kernel:** `Conv2D` Forward Pass (specifically `_im2col` and the subsequent matrix multiplication)
**Data Type:** FP64 (8 bytes per value, standard NumPy precision)

**Parameters (Derived from the 'small' config in train.py):**
* Batch Size (N) = 32
* Input Channels (C_in) = 1
* Output Channels (C_out) = 8
* Kernel Size (k) = 3 (so k^2 = 9)
* Input Size = 16x16, Padding = 1 -> Output Size (H_out x W_out) = 16x16

**1. Total FLOPs**
* Formula: `2 * N * C_in * k^2 * H_out * W_out * C_out`
* Substitutions: `2 * 32 * 1 * 9 * 16 * 16 * 8`
* Result: **1,179,648 FLOPs**

**2. Bytes Transferred (Assuming no cache reuse)**
* Input Patch Load: `N * C_in * k^2 * H_out * W_out * 8 bytes` = `32 * 1 * 9 * 16 * 16 * 8` = 589,824 bytes
* Weights Load: `C_out * C_in * k^2 * 8 bytes` = `8 * 1 * 9 * 8` = 576 bytes
* Output Store: `N * C_out * H_out * W_out * 8 bytes` = `32 * 8 * 16 * 16 * 8` = 524,288 bytes
* Total Memory Traffic: `589,824 + 576 + 524,288` = **1,114,688 bytes**

**3. Arithmetic Intensity**
* Formula: `Total FLOPs / Total Bytes`
* Result: `1,179,648 / 1,114,688` = **1.058 FLOPs/byte**
