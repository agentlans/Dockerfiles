FROM pytorch/pytorch:2.8.0-cuda12.8-cudnn9-runtime

# Update, install dependencies, upgrade pip and install python packages in one layer
RUN apt update && \
    apt -y upgrade && \
    DEBIAN_FRONTEND="noninteractive" apt -y install git python3.11-minimal python3-pip && \
    pip install --upgrade pip && \
    pip install https://github.com/turboderp-org/exllamav2/releases/download/v0.3.2/exllamav2-0.3.2+cu128.torch2.8.0-cp311-cp311-linux_x86_64.whl && \
    pip install rich tokenizers && \
    git clone https://github.com/turboderp-org/exllamav2.git && \
    apt -y remove --purge python3-pip git && \
    apt -y autoremove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

COPY Measure.sh .
COPY Quantize.sh .

