#include <iostream>
#include <bit>
#include <cstring>
#include "../Data/Data_10_14_2.cpp"

using namespace std;

#define NBR_RIDGES 1792
#define RESULT_SIZE (1u<<25)
#define NBR_LOOPS 1
#define DIVISOR 32

struct StructX0 {
    unsigned long X0 = 0ul;
    unsigned int precalc[10] = {0u};
};

const int nbrX0 = NBR_X0;
const int nbrX1 = NBR_X1;
int r[NBR_RIDGES];
unsigned int listX1[nbrX1];
//unsigned long out[RESULT_SIZE];
//int nOut = 0;
StructX0 listX0[nbrX0];


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
    bool first_appeared;
    int count;
    bool Ax[NBR_FACETS];
    bool skip;
    unsigned long X0_val;
    unsigned int a[NBR_FACETS];
    for (int l = 0; l < NBR_LOOPS; l++) {
        for (auto &dataX0: listX0) {
            for (unsigned int &dataPrecalc: dataX0.precalc) {
                dataPrecalc = 0;
            }
        }
        for (auto &dataX0: listX0) {
            X0 = (1ul << 63);
            for (int i = 0; i < sizeVectX0; i++) {
                X0 |= list_elementary[i][vectX0[i]];
            }
            dataX0.X0 = X0;
            increment_vect(vectX0, list_ref, 0, sizeVectX0);
        }
        for (auto &dataX0: listX0) {
            for (int i = 0; i < NBR_FACETS; i++) {
                if ((__popcount(dataX0.X0 & A[i])) & 1u) {
                    dataX0.precalc[i / DIVISOR] |= (1u << (i % DIVISOR));
                }
            }
        }
        for (int i = 0; i < nbrX0; i++) {
            StructX0 dataX0 = listX0[i];
            for (int j = 0; j < NBR_FACETS; j++)
                a[j] = ((A[j] << 33) >> 33) | (((dataX0.precalc[j / DIVISOR] >> (j % DIVISOR)) & 1u) << 31);
            X0_val = dataX0.X0;
            for (unsigned int &X1_val: listX1) {
                memset(r, 0, sizeof(r));
                memset(Ax, false, sizeof(Ax));
                count = 0;
                skip = false;
                for (int j = 0; j < NBR_FACETS; j++) {
                    Ax[j] = __popcount(a[j] & X1_val) & 1;
                    if (Ax[j]) count++;
                    if (count > MAX_NBR_FACETS) {
                        skip = true;
                        break;
                    }
                }
                if (skip) continue;
                for (int j = 0; j < NBR_FACETS; j++) {
                    if (Ax[j]) {
                        for (int k = 0; k < N; k++) {
                            /*If the pseudomanifold condition is not satisfied*/
                            r[M[k][j]]++;
                            if ((r[M[k][j]]) >= 3) {
                                skip = true;
                                break;
                            }
                        }
                    }
                    if (skip) break;
                }
                if (skip) continue;
                cout << '[';
                first_appeared = false;
                for (int j = 0; j < NBR_FACETS; j++) {
                    if (__popcount((X0_val | (unsigned long) (X1_val ^ (1u << 31))) & A[j]) & 1ul) {
                        if (first_appeared) cout << ',';
                        first_appeared = true;
                        cout << F[j];
                    }
                }
                cout << ']' << endl;
            }
        }
    }
    return 0;
}



