#include <iostream>
#include <bit>
#include <bitset>
#include "../Data/Data_9_13_6.cpp"

#define NBR_RIDGES 1210 //first multiple of 220 larger than 1190
#define NBR_LOOPS 121 //out of 121
#define RESULT_SIZE (1u<<25)
#define SUB_BLOCK 4
#define DIVISOR (32/SUB_BLOCK)
#define BLOCK_SIZE 110

using namespace std;

struct StructX0 {
    unsigned long X0 = 0ul;
    unsigned int precalc[14] = {0u};
};
const int nbrX0 = NBR_X0;
const int nbrX1 = NBR_X1;
__shared__ int r[NBR_RIDGES];
__device__ __managed__  unsigned int ai[SUB_BLOCK][BLOCK_SIZE];
__device__ __managed__  int mi[SUB_BLOCK][N][BLOCK_SIZE];
__device__ __managed__  unsigned int listX1[nbrX1];
__device__ __managed__  unsigned long out[RESULT_SIZE];
__device__ __managed__  int nOut = 0;
__device__ __managed__  StructX0 listX0[nbrX0];

__global__ void kernel(StructX0 structX0[]) {
    unsigned int a[SUB_BLOCK];
    unsigned int precalc_a = structX0[blockIdx.x].precalc[threadIdx.x / DIVISOR];
    unsigned long X0 = structX0[blockIdx.x].X0;
    for (int k = 0; k < SUB_BLOCK; k++) {
        a[k] = ai[k][threadIdx.x] | (((precalc_a >> (SUB_BLOCK * (threadIdx.x % DIVISOR) + k)) & 1u) << 31);
    }
    int m[SUB_BLOCK][N];
    for (int k = 0; k < SUB_BLOCK; k++) {
        for (int l = 0; l < N; l++) {
            m[k][l] = mi[k][l][threadIdx.x];
        }
    }
    int count;
    bool Ax[SUB_BLOCK];
    bool stop;
    for (unsigned int X1: listX1) {
        stop = false;
        for (int i = 0; i < NBR_RIDGES; i += BLOCK_SIZE) r[i + threadIdx.x] = 0;
        __syncthreads();
        for (int j = 0; j < SUB_BLOCK; j++) {
            Ax[j] = __popc(a[j] & X1) & 1;
        }
        count = 0;
        for (bool j: Ax) {
            count += __syncthreads_count(j);
        }
        if (count > MAX_NBR_FACETS) continue;
        for (int k = 0; k < SUB_BLOCK; k++) {
            if (stop) break;
            if (Ax[k]) {
                for (int t = 0; t < N; t++) {
                    if (atomicAdd(r + m[k][t], 1) >= 2) {
                        stop = true;
                        break;
                    }
                }
            }
        }
        if (__syncthreads_or(stop)) continue;
        if (threadIdx.x == 0) {
            out[atomicAdd(&nOut, 1)] = (X0 | (unsigned long) (X1 ^ (1u << 31)));
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
    unsigned int vectX0[sizeVectX0];
    for (int k = 0; k < sizeVectX0; k++) vectX0[k] = 0;
    unsigned int vectX1[sizeVectX1];
    for (int k = 0; k < sizeVectX1; k++) vectX1[k] = 0;
    unsigned int list_shifts[NBR_GROUPS];
    unsigned int list_ref[NBR_GROUPS - 1];
    unsigned long list_elementary[NBR_GROUPS - 1][11];
    unsigned long X0;
    //Initialiser les matrices ai et mi
    for (int k = 0; k < NBR_FACETS; k++) {
        ai[k % SUB_BLOCK][k / SUB_BLOCK] = ((A[k] << 33) >> 33);
    }
    for (int k = 0; k < NBR_FACETS; k++) {
        for (int l = 0; l < N; l++) {
            mi[k % SUB_BLOCK][l][k / SUB_BLOCK] = M[l][k];
        }
    }
    //Initialiser les shifts et les générateurs de combinaison linéaire
    list_shifts[NBR_GROUPS - 1] = 64 - NBR_GENERATORS;
    for (int k = NBR_GROUPS - 2; k > -1; k--) {
        list_shifts[k] = list_groups[k + 1] + list_shifts[k + 1];
    }
    for (int i = 1; i < NBR_GROUPS; i++) {
        int position = 0;
        for (int j = 0; j < (1ul << (list_groups[i])); j++) {
            if (__popcount(j) <= 2) {
                unsigned long jl = j;
                list_elementary[i - 1][position] = (jl << list_shifts[i]);
                position += 1;
            }
        }
        list_ref[i - 1] = position;
    }
    //Initialiser les listX1
    unsigned int X1;
    for (unsigned int &X1_val: listX1) {
        X1 = 1u << 31;
        for (int i = 0; i < sizeVectX1; i++) {
            X1 |= (list_elementary[i + sizeVectX0][vectX1[i]]);
        }
        X1_val = X1;
        increment_vect(vectX1, list_ref, sizeVectX0, sizeVectX1);
    }
    bool last_one_copied = false;
    bool first_appeared;
    for (int l = 0; l < NBR_LOOPS; l++) {
        for (auto & dataX0 : listX0) {
            for (unsigned int &dataPrecalc:dataX0.precalc){
                dataPrecalc=0;
            }
        }
        last_one_copied = false;
        for (auto & dataX0 : listX0) {
            X0 = (1ul << 63);
            for (int i = 0; i < sizeVectX0; i++) {
                X0 |= list_elementary[i][vectX0[i]];
            }
            dataX0.X0 = X0;
            increment_vect(vectX0, list_ref, 0, sizeVectX0);
        }
        for (auto & dataX0 : listX0) {
            for (int i = 0; i < BLOCK_SIZE; i++) {
                for (int k = 0; k < SUB_BLOCK; k++) {
                    if ((__popcount(dataX0.X0 & A[i * SUB_BLOCK + k])) & 1u) {
                        dataX0.precalc[i / DIVISOR] |= (1u << (SUB_BLOCK * (i % DIVISOR) + k));
                    }
                }
            }
        }
        kernel<<<NBR_X0, BLOCK_SIZE>>>(listX0);
        cudaError_t cudaerr = cudaDeviceSynchronize();
        if (cudaerr != cudaSuccess)
            printf("kernel launch failed with error \"%s\".\n",
                   cudaGetErrorString(cudaerr));
        if (nOut > (1u << 23)) {
            for (int i = 0; i < nOut; i++) {
                first_appeared = false;
                cout << '[';
                for (int j = 0; j < NBR_FACETS; j++) {
                    if (__popcount(out[i] & A[j]) & 1ul) {
                        if (first_appeared) cout << ',';
                        first_appeared = true;
                        cout << F[j];
                    }
                }
                cout << ']' << '\n';
            }
            nOut = 0;
            last_one_copied = true;
        }

    }
    if (not last_one_copied) {
        for (int i = 0; i < nOut; i++) {
            cout << '[';
            first_appeared = false;
            for (int j = 0; j < NBR_FACETS; j++) {
                if (__popcount(out[i] & A[j]) & 1ul) {
                    if (first_appeared) cout << ',';
                    first_appeared = true;
                    cout << F[j];
                }
            }
            cout << ']' << '\n';
        }
    }
    return 0;
}