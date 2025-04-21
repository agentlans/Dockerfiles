FROM intel/oneapi-basekit AS builder

# Install dependencies
RUN apt-get update && apt-get install -y wget
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
RUN dpkg -i cuda-keyring_1.1-1_all.deb && rm cuda-keyring_1.1-1_all.deb
RUN apt-get update && apt-get install -y git cmake nvidia-cuda-toolkit curl ccache libcurl4-openssl-dev

# Download llama.cpp
WORKDIR /app
RUN git clone https://github.com/ggerganov/llama.cpp

WORKDIR /app/llama.cpp

# Configure environment
ENV GGML_CUDA_ENABLE_UNIFIED_MEMORY=1
ENV CMAKE_OPTIONS="-DGGML_CUDA=ON \
    -DGGML_BLAS=ON \
    -DGGML_BLAS_VENDOR=Intel10_64lp \
    -DCMAKE_C_COMPILER=icx \
    -DCMAKE_CXX_COMPILER=icpx \
    -DGGML_CUDA_F16=ON \
    -DCMAKE_CUDA_ARCHITECTURES='61;75;86;89' \
    -DGGML_CUDA_FA_ALL_QUANTS=ON"

# Build llama.cpp
RUN cmake -B build $CMAKE_OPTIONS -DLLAMA_BUILD_EXAMPLES=ON && cmake --build build --config Release -j$(nproc)

FROM intel/oneapi-runtime

# Install dependencies
RUN apt-get update && apt-get install -y wget
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
RUN dpkg -i cuda-keyring_1.1-1_all.deb && rm cuda-keyring_1.1-1_all.deb
RUN apt-get update && apt -y install python3-pip libcudart12 libcublas12

# Copy llama.cpp build artifacts
COPY --from=builder /app/llama.cpp /app/llama.cpp
WORKDIR /app/llama.cpp

# Install Python dependencies
RUN pip3 install -r requirements.txt --break-system-packages

# Install llama-cpp-python
ENV CMAKE_ARGS="-DLLAMA_CUBLAS=OFF -DCMAKE_PREFIX_PATH=/app/llama.cpp/build"
RUN pip install llama-cpp-python[server] --no-cache-dir --break-system-packages

# Copy the quantization script
COPY QuantizeTextModel.sh .
RUN chmod +x *.sh
