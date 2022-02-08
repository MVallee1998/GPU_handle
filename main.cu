#include <iostream>
#include <bit>
#include <bitset>
#include <cstdint>

#define MAXFACES 252
#define SIZE_X 198414832
#define RESULT_SIZE (1ul<<32)

using namespace std;

__shared__ int r[2688];
__device__  unsigned int ai[4][210];
__device__ int mi[4][11][210];
__device__ unsigned int X[SIZE_X];
__device__ __managed__ long out[RESULT_SIZE];
__device__ __managed__ int n_out = 0;
struct StructX0 {
    unsigned long X0;
//    unsigned int precalc[1];
};

const unsigned long nbrX0 = 214358881;
unsigned long listX0[nbrX0];


//__global__ void kernel(StructX0 structX0[]) {
//    unsigned int a[4];
//    unsigned int precalc_a = structX0[blockIdx.x].precalc[threadIdx.x / 8];
//    unsigned long X0 = structX0[blockIdx.x].X0;
//    for (int k = 0; k < 4; k++) {
//        a[k] = ai[k][threadIdx.x] | ((precalc_a >> (4 * (threadIdx.x % 8) + k)) & 1u) << 31;
//    }
//    int m[4][11];
//    for (int k = 0; k < 4; k++) {
//        for (int l = 0; l < 11; l++) {
//            m[k][l] = mi[k][l][threadIdx.x];
//        }
//    }
//    bool Ax[4];
//    bool stop;
//    for (unsigned int x: X) {
//        for (int j = 0; j < 4; j++) {
//            Ax[j] = __popc(a[j] & x) & 1;
//        }
//        int count = 0;
//        for (bool j: Ax) {
//            count += __syncthreads_count(j);
//        }
//        if (count > MAXFACES) continue;
//        for (bool j: Ax) {
//            if (j) {
//                for (int k = 0; k < 11; k++) {
//                    if (atomicAdd(r + m[j][k], 1) >= 4) {
//                        stop = true;
//                    }
//                }
//            }
//        }
//        if (__syncthreads_or(stop)) continue;
//        if (threadIdx.x == 0) {
//            out[atomicAdd(&n_out, 1)] = X0 | x;
//        }
//    }
//
//}

//void calculs_GPU(unsigned long A[], unsigned int M[]) {
//    // Enumérer les X0 33
//    unsigned int list_groups[20] = {1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 1, 1, 1, 1};
//    unsigned int list_shifts[20];
//    for (int k = 18; k > -1; k--) {
//        list_shifts[k] += list_groups[k];
//    }
//    cout<<(list_shifts);
//    unsigned long nbrX0 = 36388725375613;
//    StructX0 listX0[nbrX0];
//    unsigned long k = 0;
//    // Précalculer les 33 precalc sur CPU
//    StructX0 precalcTable[nbrX0];
//    // Enumérer les X1 31
//    // lancer le 210 000 000 précalc correspondant à X0 blocks
//    kernel<<<1, 210>>>(precalcTable);
//    for (int i = 0; i < n_out; i++) {
//        cout << out[i];
//        // écrire dans le fichier texte out[k] (printf)
//    }
//}

void increment_vect(unsigned int vect[], const unsigned int ref[], const int size) {
    vect[0] = (vect[0] + 1) % ref[0];
    int k = 0;
    while (vect[k] == 0 and k < size - 1) {
        k += 1;
        vect[k] = (vect[k] + 1) % ref[k];
    }
}

int main() {
    unsigned int list_groups[20] = {1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 1, 1, 1, 1};
    unsigned int list_shifts[20];
    unsigned int list_ref[19];
    list_shifts[19] = 0;
    for (int k = 18; k > -1; k--) {
        list_shifts[k] = list_groups[k + 1] + list_shifts[k + 1];
    }
    unsigned long list_elementary[19][11];
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
    int size = 8;
    unsigned int vect[size];
    for (int k = 0; k < size; k++) {
        vect[k] = 0;
    }
    unsigned long k = 0;
    while (k < nbrX0) {
        unsigned long x = (1ul << 63);
        for (int i = 0; i < size; i++) {
            x |= list_elementary[i][vect[i]];
        }
        listX0[k] = x;
        increment_vect(vect, list_ref, size);
        k++;
    }
    for (unsigned int l : vect){
        cout<<l<<',';
    }
}