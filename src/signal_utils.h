
#ifndef SIGNAL_UTILS_H
#define SIGNAL_UTILS_H

#include <iostream>
#include <fstream>
#include <vector>

// Load signal data from CSV file
std::vector<float> loadSignal(const std::string& path) {
    std::ifstream file(path);
    std::vector<float> signal;
    float value;
    while (file >> value) {
        signal.push_back(value);
    }
    return signal;
}

// Save signal data to CSV file
void saveSignal(const std::vector<float>& signal, const std::string& path) {
    std::ofstream file(path);
    for (float value : signal) {
        file << value << ",";
    }
    file.close();
}

// Simple recovery using linear interpolation for missing values
std::vector<float> recoverSignal(const std::vector<float>& signal) {
    std::vector<float> recovered = signal;
    for (size_t i = 0; i < signal.size(); ++i) {
        if (signal[i] == 50) {  // Assuming 50 is an anomaly in the signal
            if (i > 0 && i < signal.size() - 1) {
                recovered[i] = (signal[i - 1] + signal[i + 1]) / 2.0f; // Linear interpolation
            }
        }
    }
    return recovered;
}

#endif // SIGNAL_UTILS_H
