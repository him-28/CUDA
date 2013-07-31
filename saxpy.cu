#include <iostream>

// blockDim.x - num threads in a block, .x indicates 1D block labelling
// blockIdx.x - thread index number
// multiplying the above two variables gives start of block
// then add the threadIdx.x offset for the particular thread

__global__ void saxpy_parallel(int n, float a, float *x, float *y)
{
	int i = blockIdx.x*blockDim.x + threadIdx.x;
	if (i<n)  y[i] = a*x[i] + y[i];


}


int main()
{
	int N =10;
	// allocate vectors on host
	int size = N * sizeof(float);
	float* h_x = (float*)malloc(size);
	float* h_y = (float*)malloc(size);
	

	// allocate device memory
	float* d_x; float* d_y;

	cudaMalloc((void**) &d_x, size);
	cudaMalloc((void**) &d_y, size);

	cudaMemcpy(d_x, h_x, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, h_y, size, cudaMemcpyHostToDevice);

	// put values in h_x and h_y

	for (int i = 0;i<=N-1;i++)
	{
		h_x[i]=2;
		h_y[i]=2;
		
	}

	for (int i = 0;i<=N-1;i++)
	{
		std::cout << i << " " <<  h_y[i] << std::endl;
	}
	

	// calculate number of blocks needed for N 
	int nblocks = (N+255)/256;

	// call 
	saxpy_parallel<<<nblocks,256>>>(N,2.0,d_x,d_y);
	
	// Copy results back from device memory to host memory
	// implicty waits for threads to excute
	cudaMemcpy(h_y, d_y, size, cudaMemcpyDeviceToHost);

	// Check for any CUDA errors
  checkCUDAError("cudaMemcpy calls");

	for (int i = 0;i<=N-1;i++)
	{
		std::cout << i << " " <<  d_y[i] << std::endl;
	}



  cudaFree(d_x);
  cudaFree(d_y);

	free(h_x);
	free(h_y);



	return 0;

}

void checkCUDAError(const char *msg)
{
    cudaError_t err = cudaGetLastError();
    if( cudaSuccess != err) 
    {
        fprintf(stderr, "Cuda error: %s: %s.\n", msg, cudaGetErrorString( err) );
        exit(-1);
    }                         
}
