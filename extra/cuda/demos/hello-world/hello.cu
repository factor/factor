/*
 World using CUDA
** 
** The string "Hello World!" is mangled then restored using a common CUDA idiom
**
** Byron Galbraith
** 2009-02-18
*/
#include <cuda.h>
#include <stdio.h>

// Prototypes
extern "C" __global__ void helloWorld(char*);

// Host function
int
main(int argc, char** argv)
{
  int i;

  // desired output
  char str[] = "Hello World!";

  // mangle contents of output
  // the null character is left intact for simplicity
  for(i = 0; i < 12; i++)
    str[i] -= i;

  // allocate memory on the device 
  char *d_str;
  size_t size = sizeof(str);
  cudaMalloc((void**)&d_str, size);

  // copy the string to the device
  cudaMemcpy(d_str, str, size, cudaMemcpyHostToDevice);

  // set the grid and block sizes
  dim3 dimGrid(2);   // one block per word  
  dim3 dimBlock(6); // one thread per character
  
  // invoke the kernel
  helloWorld<<< dimGrid, dimBlock >>>(d_str);

  // retrieve the results from the device
  cudaMemcpy(str, d_str, size, cudaMemcpyDeviceToHost);

  // free up the allocated memory on the device
  cudaFree(d_str);
  
  // everyone's favorite part
  printf("%s\n", str);

  return 0;
}

// Device kernel
__global__ void
helloWorld(char* str)
{
  // determine where in the thread grid we are
  int idx = blockIdx.x * blockDim.x + threadIdx.x;

  // unmangle output
  str[idx] += idx;
}
