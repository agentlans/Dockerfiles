# --- STAGE 1: Builder ---
FROM nvidia/cuda:12.8.0-devel-ubuntu24.04 AS builder

# Install build dependencies + BLIS development headers
RUN apt-get update && apt-get install -y \
    git cmake curl ccache libssl-dev build-essential pkg-config python3-pip \
    libblis-dev

# Setup CUDA stubs for compilation
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:$LD_LIBRARY_PATH

WORKDIR /app

# Clone llama.cpp and ensure it updates to the latest master
RUN git clone https://github.com/ggml-org/llama.cpp && \
    cd llama.cpp && \
    git pull origin master
WORKDIR /app/llama.cpp

# Build llama.cpp with CUDA and BLIS
ENV CMAKE_OPTIONS="-DGGML_CUDA=ON \
    -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME \
    -DGGML_CUDA_F16=ON \
    -DGGML_CUDA_FA_ALL_QUANTS=ON \
    -DCMAKE_CUDA_ARCHITECTURES='61;75;86;89;120-real;120-virtual' \
    -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs"

RUN cmake -B build $CMAKE_OPTIONS -DLLAMA_BUILD_EXAMPLES=ON && \
    cmake --build build --config Release -j$(nproc)

# Build llama-cpp-python wheel with matching CUDA and BLIS options
ENV CMAKE_ARGS="-DGGML_CUDA=ON -DGGML_BLAS=ON -DGGML_BLAS_VENDOR=FLAME -DGGML_CUDA_F16=ON -DCMAKE_CUDA_ARCHITECTURES='61;75;86;89;120-real;120-virtual'"
ENV FORCE_CMAKE=1
RUN pip wheel llama-cpp-python[server] --wheel-dir=/app/wheels

# --- STAGE 2: Runtime ---
FROM nvidia/cuda:12.8.0-runtime-ubuntu24.04

# Install runtime dependencies + BLIS shared library (libblis4)
RUN apt-get update && apt-get install -y \
    python3-pip python3-venv curl \
    libblis4 libssl3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/llama.cpp

# Copy compiled binaries from builder
COPY --from=builder /app/llama.cpp/build/bin /app/llama.cpp/bin

COPY --from=builder /app/llama.cpp/*.py /app/llama.cpp/
COPY --from=builder /app/llama.cpp/conversion /app/llama.cpp/conversion
COPY --from=builder /app/llama.cpp/gguf-py /app/llama.cpp/gguf-py

# Copy and install the wheels
COPY --from=builder /app/wheels /app/wheels
RUN pip install /app/wheels/*.whl --break-system-packages

# Copy requirements and dependency folders
COPY --from=builder /app/llama.cpp/requirements.txt .
COPY --from=builder /app/llama.cpp/requirements ./requirements 

# Install python requirements
RUN pip3 install -r requirements.txt --break-system-packages && pip3 install --upgrade transformers --break-system-packages 

# Environment setup
ENV LD_LIBRARY_PATH=/app/llama.cpp/bin:$LD_LIBRARY_PATH

# Copy user scripts
COPY QuantizeTextModel.sh .
RUN chmod +x *.sh

# Default command (can be overridden)
CMD ["/bin/bash"]
