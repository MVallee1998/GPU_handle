# Presentation
This project contains the CUDA and C++ implementations of **Algorithm 1** in [arxiv:2301.00806](https://arxiv.org/abs/2301.00806) for enumerating weak pseudo-manifolds of Picard number four having maximal Buchstaber number.
# Abstract
We provide a GPU-friendly algorithm for obtaining all weak pseudo-manifolds whose facets are all in an input set of facets satisfying given conditions. We use it here to completely list up toric colorable seed PL-spheres with a few vertices implying the complete characterization of PL-spheres of dimension $n−1$ with $n+4$ vertices having maximal Buchstaber numbers.
# Content
The [Data](./Data) folder gathers the input facets for all the necessary dimensions $n-1$, one for each IDCM orbit. This data was computed using python, since it does not require much computing power.

The [cuda](./cuda) folder gathers the GPU algorithms, with one file for each dimension $n-1$. Note the changes in the values of aliases (number of active threads, etc...) which changes according to each IDCM orbit for the best suitability to the GPU. 

The [C++](./cpp) folder contains the CPU version of the GPU algorithm which was used for comparing the output with the GPU algorithm.

Remember to change the data file you are using as an input in the appropriate ``*.cu`` or ``*.cpp`` script at line 5.
# How to compile and run the algorithm?
### Installing NVIDIA® CUDA® Toolkit
This GPU algorithm was implemented for NVIDIA graphic cards only.
The installation information can be found on the official [NVIDIA website](https://developer.nvidia.com/cuda-toolkit).
We strongly advise the interested reader to use Linux for compiling and running the algorithm.
### Compiling and running the CUDA algorithm
An example is better than a thousand words, if launched from the root folder of the project, the following command
```bash
/usr/local/cuda-12.0/bin/nvcc ./cuda/main_8_12.cu -arch=sm_86 -o ./build/GPU_exec_8_12
```
will compile the cuda script ``main_8_12.cu`` into the executable ``GPU_exec_8_12``,
where:
- ``/usr/local/cuda-12.0/bin/nvcc`` is the path to the CUDA Toolkit ``nvcc`` compiler installed beforehand.
- ``./cuda/main_8_12.cu`` is the CUDA script we want to compile and ``-o ./build/GPU_exec_8_12`` is the argument for specifying the output executable.
- ``-arch=sm_86`` is the argument for specifying the architecture of the graphic card used for running the algorithm, find yours [here](https://developer.nvidia.com/cuda-gpus).

For running it, it suffices to launch the executable ``./build/GPU_exec_8_12`` in the terminal with an output parsing to a file (e.g. ``./build/GPU_exec_8_12 >> ./outputs/GPU_output_8_12.txt``).
### Compiling the C++ algorithm
For compiling, for example launch:
```bash
gpp ./cpp/main_8_12.cpp -o ./build/CPU_exec_8_12
```
For running it, it suffices to launch the executable ``./build/CPU_exec_8_12`` in the terminalwith an output parsing to a file (e.g. ``./build/CPU_exec_8_12 >> ./outputs/CPU_output_8_12.txt``)..

# What to do with the output of the algorithm ?
The algorithm outputs all weak pseudo manifolds having their facets in a given set and satisfying the upper bound conjecture.
These simplicial complexes are pure and encoded as the list of their facets in a binary form.
For example the binary array ``[3,5,6]`` represents the simplicial complex whose facets are ``[[1,2],[1,3],[2,3]]``, it is the boundary of a 2-simplex having vertices ``1,2,3``.
See the aforementioned article for what is left to perform in order to obtain the complete list of seed PL-spheres of Picard number 4 having maximal Buchstaber number. 

# The results obtained with this algorithm
Find in the [Results](./Results) folder the complete database (up to simplicial isomorphisms) of Seed PL-spheres of Picard number $p$ smaller or equal to four having maximal Buchstaber number.
The name format of the files is ``CSPLS_n_m`` where $n-1$ represents the dimension and $m$ the number of vertices, the letters ``CSPLS`` stand for _Colorizable Seed PL-Spheres_. 
Once more, these text files store the PL-spheres as the array of the binary representation of their facets.
Their quantity is as follows:

| p⟍n | $1$ | $2$ | $3$ | $4$    | $5$   | $6$   | $7$    | $8$   | $9$   | $10$ | $11$ | $>11$ | total  |
|-----|-----|-----|-----|--------|-------|-------|--------|-------|-------|------|------|-------|--------|
| $1$ | $1$ |     |     |        |       |       |        |       |       |      |      |       | $1$    |
| $2$ |     | $1$ |     |        |       |       |        |       |       |      |      |       | $1$    |
| $3$ |     | $1$ | $1$ | $1$    |       |       |        |       |       |      |      |       | $3$    |
| $4$ |     | $1$ | $4$ | $20+1$ | $142$ | $733$ | $1190$ | $776$ | $243$ | $39$ | $4$  |       | $3153$ |

Notice the $+1$ for $p=4,m=8$ which is not in the file [CSPLS_4_8](./Results/CSPLS_4_8) and which represents a product of simplices.
