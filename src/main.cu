
#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <cuda_runtime.h>
#include "signal_utils.h"

#define BLOCK_SIZE 256

// CUDA kernel for denoising using moving average filter
__global__ void denoiseSignal(const float* inputSignal, float* outputSignal, int length) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (idx > 0 && idx < length - 1) {
        // Simple moving average filter: averaging over three consecutive points
        outputSignal[idx] = (inputSignal[idx - 1] + inputSignal[idx] + inputSignal[idx + 1]) / 3.0f;
    }
}

void processSignal(const std::string& inputPath, const std::string& denoiseOutputPath, const std::string& recoveryOutputPath) {
    std::vector<float> signal = loadSignal(inputPath);
    int length = signal.size();

    // Allocate memory for device input and output signals
    float* d_input;
    float* d_output;

    cudaMalloc(&d_input, length * sizeof(float));
    cudaMalloc(&d_output, length * sizeof(float));

    // Copy the signal to the device
    cudaMemcpy(d_input, signal.data(), length * sizeof(float), cudaMemcpyHostToDevice);

    // Set up grid and block size for CUDA kernel
    int gridSize = (length + BLOCK_SIZE - 1) / BLOCK_SIZE;

    // Run the denoising kernel
    denoiseSignal<<<gridSize, BLOCK_SIZE>>>(d_input, d_output, length);
    cudaDeviceSynchronize();

    // Copy the result back to host
    std::vector<float> denoisedSignal(length);
    cudaMemcpy(denoisedSignal.data(), d_output, length * sizeof(float), cudaMemcpyDeviceToHost);

    // Save the denoised signal
    saveSignal(denoisedSignal, denoiseOutputPath);

    // Recover the signal by interpolation (simple linear interpolation)
    std::vector<float> recoveredSignal = recoverSignal(denoisedSignal);

    // Save the recovered signal
    saveSignal(recoveredSignal, recoveryOutputPath);

    // Clean up
    cudaFree(d_input);
    cudaFree(d_output);
}

int main() {
    processSignal("data/noisy_signal.csv", "output/denoised_signal.csv", "output/recovered_signal.csv");
    std::cout << "Processing completed.\n";
    return 0;
}
