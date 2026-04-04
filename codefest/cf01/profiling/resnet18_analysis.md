| Rank | Layer        | Output Shape      | Parameter Count | MACs        |
|------|--------------|-------------------|-----------------|-------------|
| 1    | Conv2d: 1-1  | [1, 64, 112, 112] | 9,408           | 118,013,952 |
| 2    | Conv2d: 3-1  | [1, 64, 56, 56]   | 36,864          | 115,605,504 |
| 3    | Conv2d: 3-4  | [1, 64, 56, 56]   | 36,864          | 115,605,504 |
| 4    | Conv2d: 3-7  | [1, 64, 56, 56]   | 36,864          | 115,605,504 |
| 5    | Conv2d: 3-10 | [1, 64, 56, 56]   | 36,864          | 115,605,504 |

### Arithmetic Intensity Calculation for the Most MAC-Intensive Layer

**Target Layer:** `Conv2d: 1-1`
**Data Type:** FP32 (4 bytes per value)

**1. Total Operations (FLOPs)**
* **MACs:** 118,013,952
* **FLOPs:** Since 1 MAC = 2 Operations (one multiply, one add), total operations = `118,013,952 * 2 = 236,027,904 FLOPs`

**2. Memory Traffic (Bytes)**
Assuming no reuse, we must load the weights, load the input activations, and store the output activations from/to DRAM.

* **Weights Memory:** * Parameter count = 9,408
  * `9,408 * 4 bytes = 37,632 bytes`
* **Input Activation Memory (Image):**
  * Shape = [1, 3, 224, 224] = 150,528 values
  * `150,528 * 4 bytes = 602,112 bytes`
* **Output Activation Memory:**
  * Shape = [1, 64, 112, 112] = 802,816 values
  * `802,816 * 4 bytes = 3,211,264 bytes`
* **Total Memory Traffic:**
  * `37,632 + 602,112 + 3,211,264 = 3,851,008 bytes`

**3. Final Arithmetic Intensity**
* **Formula:** `Total FLOPs / Total Memory Traffic in Bytes`
* **Calculation:** `236,027,904 FLOPs / 3,851,008 bytes`
* **Result:** **61.29 FLOPs/byte**
