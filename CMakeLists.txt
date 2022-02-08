cmake_minimum_required(VERSION 3.21)
set(CMAKE_CUDA_COMPILER /tempo/cuda/bin/nvcc)
set(CUDAToolkit_ROOT /tempo/cuda/bin)
project(GPU_handle CUDA)

set(CMAKE_CUDA_STANDARD 14)

add_executable(GPU_handle main.cu)

set_target_properties(GPU_handle PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)
