#include <iostream>
#include <bit>
#include <bitset>
#include <cstdint>
#include "Data.cpp"

#define MAX_NBR_FACETS 252
#define NBR_RIDGES 2688
#define NBR_FACETS 840
#define NBR_X0 1771561
#define NBR_X1 198414832
#define NBR_LOOPS 121
#define RESULT_SIZE (1ul<<20)

using namespace std;

struct StructX0 {
    unsigned long X0 = 0ul;
    unsigned int precalc[27] = {0u};
};

const int nbrX0 = NBR_X0;
const int nbrX1 = NBR_X1;
__shared__ int r[NBR_RIDGES];
unsigned int ai_host[4][210];
__device__ unsigned int ai_device[4][210];
int mi_host[4][11][210];
__device__ int mi_device[4][11][210];
unsigned int X1_host[nbrX1];
__device__ unsigned int X1_device[nbrX1];
unsigned long out_host[RESULT_SIZE];
__device__ __managed__ unsigned long out_device[RESULT_SIZE];
int n_out_host = 0;
__device__ __managed__ int n_out_device = 0;
StructX0 host_listX0[nbrX0];
__device__ __managed__ StructX0 device_listX0[nbrX0];


__global__ void kernel(StructX0 structX0[]) {
    unsigned int a[4];
    unsigned int precalc_a = structX0[blockIdx.x].precalc[threadIdx.x / 8];
    unsigned long X0 = structX0[blockIdx.x].X0;
    for (int k = 0; k < 4; k++) {
        a[k] = ai_device[k][threadIdx.x] | ((precalc_a >> (4 * (threadIdx.x % 8) + k)) & 1u) << 31;
    }
    int m[4][11];
    for (int k = 0; k < 4; k++) {
        for (int l = 0; l < 11; l++) {
            m[k][l] = mi_device[k][l][threadIdx.x];
        }
    }
    bool Ax[4];
    bool stop=false;
    for (unsigned int X1: X1_device) {
        if (threadIdx.x==0) {
            memset(r,0,sizeof(r));
        }
        __syncthreads();
        for (int j = 0; j < 4; j++) {
            Ax[j] = __popc(a[j] & X1) & 1;
        }
        int count = 0;
        for (bool j: Ax) {
            count += __syncthreads_count(j);
        }
        if (count > MAX_NBR_FACETS) continue;
        for (int j=0;j<4;j++) {
            if (stop) continue;
            if (Ax[j]) {
                for (int k = 0; k < 11; k++) {
                    if (atomicAdd(r + m[j][k], 1) >= 4) {
                        stop = true;
                        continue;
                    }
                }
            }
        }
        if (__syncthreads_or(stop)) continue;
        if (threadIdx.x == 0) {
            out_device[atomicAdd(&n_out_device, 1)] = (X0 | (unsigned long) (X1^(1u<<31)));
        }
    }

}

void increment_vect(unsigned int vect[], const unsigned int ref[], const int starting_index, const int size) {
    vect[0] = (vect[0] + 1) % ref[starting_index];
    int k = 0;
    while (vect[k] == 0 and k < size - 1) {
        k += 1;
        vect[k] = (vect[k] + 1) % ref[starting_index + k];
    }
}


int main() {
    int sizeVectX0 = 8;
    unsigned int vectX0[sizeVectX0];
    for (int k = 0; k < sizeVectX0; k++) vectX0[k] = 0;
    int sizeVectX1 = 11;
    unsigned int vectX1[sizeVectX1];
    for (int k = 0; k < sizeVectX1; k++) vectX1[k] = 0;
    unsigned int list_groups[20] = {1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 1, 1, 1, 1};
    unsigned int list_shifts[20];
    unsigned int list_ref[19];
    unsigned long list_elementary[19][11] = {};
    unsigned long X0;

    //Initialiser les matrices ai et mi
    for (int k = 0; k < NBR_FACETS; k++) {
        ai_host[k % 4][k / 4] = (unsigned int) ((A[k] << 32) >> 32);
    }
    cudaMemcpyToSymbol(ai_device, ai_host, sizeof(ai_host));
    for (int k = 0; k < NBR_FACETS; k++) {
        for (int l = 0; l < 11; l++) {
            mi_host[k % 4][l][k / 4] = M[l][k];
        }
    }
    cudaMemcpyToSymbol(mi_device, mi_host, sizeof(mi_host));
    //Initialiser les shifts et les générateurs de combinaison linéaire
    list_shifts[19] = 0;
    for (int k = 18; k > -1; k--) {
        list_shifts[k] = list_groups[k + 1] + list_shifts[k + 1];
    }
    for (int i = 0; i < 19; i++) {
        int position = 0;
        for (int j = 0; j < (1ul << (list_groups[i + 1])); j++) {
            if (__popcount(j) <= 2) {
                unsigned long jl = j;
                list_elementary[i][position] = (jl << list_shifts[i + 1]);
                position += 1;
            }
        }
        list_ref[i] = position;
    }
    //Initialiser les X1
    unsigned int X1;
    for (unsigned int &X1_val: X1_host) {
        X1 = 1u<<31;
        for (int i = 0; i < sizeVectX1; i++) {
            X1 |= (unsigned int) (list_elementary[i + sizeVectX0][vectX1[i]]);
        }
        X1_val = X1;
        increment_vect(vectX1, list_ref, sizeVectX0, sizeVectX1);
    }
    cudaMemcpyToSymbol(X1_device, X1_host, sizeof(X1_host));
    for (int l=0;l<NBR_LOOPS;l++){
        for (int index = 0; index < nbrX0; index++) {
            X0 = (1ul << 63);
            for (int i = 0; i < sizeVectX0; i++) {
                X0 |= list_elementary[i][vectX0[i]];
            }
            increment_vect(vectX0, list_ref, 0, sizeVectX0);
        }
        for (int index = 0; index < nbrX0; index++) {
            for (int i=0;i<210;i++){
                for(int k=0;k<4;k++){
                    host_listX0[index].precalc[i/8] |= ((__popcount(host_listX0[index].X0 & A[i*4+k])) & 1u) << (4*(i % 8)+k);
                }
            }
        }
        cudaMemcpyToSymbol(device_listX0, host_listX0, sizeof(host_listX0));
        kernel<<<1, 210>>>(device_listX0);
        cudaError_t cudaerr = cudaDeviceSynchronize();
        if (cudaerr != cudaSuccess)
            printf("kernel launch failed with error \"%s\".\n",
                   cudaGetErrorString(cudaerr));
        for(int s=0;s<sizeVectX0;s++){
            cout<<vectX0[s]<<',';
        }
        cout<<'\n';
    }
    cudaMemcpyFromSymbol(&n_out_host, n_out_device, sizeof(n_out_device));
    cudaMemcpyFromSymbol(&out_host, out_device, sizeof(out_device));
    cout<<(n_out_host)<<'\n';
    for (int i = 0; i < n_out_host; i++) {
        cout << out_host[i]<<'\n';
    }
}