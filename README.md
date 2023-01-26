# Presentation
This project contains the CUDA and C++ implementations of "Algorithm 1" in [arxiv:2301.00806](https://arxiv.org/abs/2301.).
# Abstract
We provide a GPU-friendly algorithm for obtaining all weak pseudo-manifolds whose facets are all in an input set of facets satisfying given conditions. We use it here to completely list up toric colorable seed PL-spheres with a few vertices implying the complete characterization of PL-spheres of dimension n−1 with n+4 vertices having maximal Buchstaber numbers.
# Content
The [Data](./Data) folder gathers the input facets for all the necessary dimensions n-1, one for each IDCM orbit.

The [cuda](./cuda) folder gathers the GPU algorithms, with one file for each IDCM orbit and each dimension n-1. Note the changes in the values of aliases (number of active threads, etc...) which changes according to each IDCM orbit for the best suitability to the GPU.

The [C++](./cpp) folder contains the CPU version of the GPU algorithm which was used for comparing the output with the GPU algorithm.
# How to compile and run the algorithm?
## Installing NVIDIA® CUDA® Toolkit
This GPU algorithm was implemented for NVIDIA® graphic cards only.
The installation information can be found on the official [NVIDIA website](https://developer.nvidia.com/cuda-toolkit).
We however advise the users to use Linux for compiling and running the algorithm.
## Compiling the CUDA® algorithm
An example is better than a thousand words, if launched from the root folder of the project, the following command
```bash
/usr/local/cuda-12.0/bin/nvcc ./cuda/main_8_12.cu -arch=sm_86 -o ./build/GPU_exec_8_12
```
will compile the cuda script ``main_8_12.c`` into the executable ``GPU_exec_8_12``,
where:
- ``/usr/local/cuda-12.0/bin/nvcc`` is the path to the CUDA Toolkit ``nvcc`` compiler
- ``./cuda/main_8_12.cu`` is the CUDA script we want to compile and ``-o ./build/GPU_exec_8_12`` is the argument for specifying the output executable
-  ``-arch=sm_86`` represents the architecture of the graphic card used.
For 