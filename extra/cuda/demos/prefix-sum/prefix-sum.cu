#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

static const int LOG_BANK_COUNT = 4;

static inline __device__ __host__ unsigned shared_offset(unsigned i)
{
    return i + (i >> LOG_BANK_COUNT);
}

static inline __device__ __host__ unsigned offset_a(unsigned offset, unsigned i)
{
    return shared_offset(offset * (2*i + 1) - 1);
}

static inline __device__ __host__ unsigned offset_b(unsigned offset, unsigned i)
{
    return shared_offset(offset * (2*i + 2) - 1);
}

static inline __device__ __host__ unsigned lpot(unsigned x)
{
    --x; x |= x>>1; x|=x>>2; x|=x>>4; x|=x>>8; x|=x>>16; return ++x;
}

template<typename T>
__global__ void prefix_sum_block(T *in, T *out, unsigned n)
{
    extern __shared__ T temp[];

    int idx = threadIdx.x;
    int blocksize = blockDim.x;

    temp[shared_offset(idx            )] = (idx             < n) ? in[idx            ] : 0;
    temp[shared_offset(idx + blocksize)] = (idx + blocksize < n) ? in[idx + blocksize] : 0;

    int offset, d;
    for (offset = 1, d = blocksize; d > 0; d >>= 1, offset <<= 1) {
        __syncthreads();
        if (idx < d) {
            unsigned a = offset_a(offset, idx), b = offset_b(offset, idx);
            temp[b] += temp[a];
        }
    }

    if (idx == 0) temp[shared_offset(blocksize*2 - 1)] = 0;

    for (d = 1; d <= blocksize; d <<= 1) {
        offset >>= 1;
        __syncthreads();

        if (idx < d) {
            unsigned a = offset_a(offset, idx), b = offset_b(offset, idx);
            unsigned t = temp[a];
            temp[a] = temp[b];
            temp[b] += t;
        }
    }
    __syncthreads();

    if (idx             < n) out[idx            ] = temp[shared_offset(idx            )];
    if (idx + blocksize < n) out[idx + blocksize] = temp[shared_offset(idx + blocksize)];
}

template<typename T>
void prefix_sum(T *in, T *out, unsigned n)
{
    char *device_values;
    unsigned n_lpot = lpot(n);
    size_t n_pitch;

    cudaError_t error = cudaMallocPitch((void**)&device_values, &n_pitch, sizeof(T)*n, 2);
    if (error != 0) {
        printf("error %u allocating width %lu height %u\n", error, sizeof(T)*n, 2);
        exit(1);
    }

    cudaMemcpy(device_values, in, sizeof(T)*n, cudaMemcpyHostToDevice);

    prefix_sum_block<<<1, n_lpot/2, shared_offset(n_lpot)*sizeof(T)>>>
        ((T*)device_values, (T*)(device_values + n_pitch), n);

    cudaMemcpy(out, device_values + n_pitch, sizeof(T)*n, cudaMemcpyDeviceToHost);
    cudaFree(device_values);
}

int main()
{
    sranddev();

    static unsigned in_values[1024], out_values[1024];

    for (int i = 0; i < 1024; ++i)
        in_values[i] = rand() >> 21;

    prefix_sum(in_values, out_values, 1024);

    for (int i = 0; i < 1024; ++i)
        printf("%5d => %5d\n", in_values[i], out_values[i]);

    return 0;
}
