# Project Proposal: Heilmeier Questions Draft
**Target Algorithm:** INT8 Quantized Depthwise Separable Convolutions (MobileNet)
**Target Interface:** SPI

### 1. What are you trying to do? Articulate your objectives using absolutely no jargon.
I am designing a custom hardware chiplet that acts as a specialized co-processor to speed up image recognition tasks on small, low-power devices. It will communicate with a standard microcontroller using a simple, 4-wire SPI connection, taking over the heavy math required to process images.

### 2. How is it done today, and what are the limits of current practice?
Currently, small microcontrollers in smart devices (like smart locks or remote sensors) run these AI models entirely in software on their main CPU. The limit of this practice is that general-purpose CPUs are slow and inefficient at processing AI math. This bottleneck causes slow reaction times and drains the batteries of edge devices very quickly. 

### 3. What is new in your approach and why do you think it will be successful?
Instead of relying on the microcontroller's general CPU, I am offloading the specific math (convolutions) to a dedicated, custom-built hardware accelerator. By compressing the AI model's data into smaller 8-bit integers (INT8 quantization), the custom hardware can process the data significantly faster while using a fraction of the power and chip area. I believe this will be successful because SPI provides a simple, easily verified communication bridge, allowing the hardware to focus entirely on efficient math execution.
