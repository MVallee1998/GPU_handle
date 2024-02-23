#include <iostream>
#include <bit>
#include <bitset>
#include <cstdio>
// Compile this script to test if you have correctly installed CUDA Toolkit
int main(){
    int deviceCount;
    cudaGetDeviceCount(&deviceCount);
    int device;
    for (device = 0; device < deviceCount; ++device) {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, device);
        printf("Device %d has compute capability %d.%d.\n",
               device, deviceProp.major, deviceProp.minor);
    }
}
