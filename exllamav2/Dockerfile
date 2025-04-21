FROM pytorch/pytorch:2.6.0-cuda12.4-cudnn9-runtime
RUN apt update && apt -y upgrade && DEBIAN_FRONTEND="noninteractive" apt -y install git python3.11-minimal python3-pip
RUN pip install -U pip && pip install https://github.com/turboderp-org/exllamav2/releases/download/v0.2.8/exllamav2-0.2.8+cu124.torch2.6.0-cp311-cp311-linux_x86_64.whl
RUN git clone https://github.com/turboderp/exllamav2.git
RUN pip install rich tokenizers
RUN apt -y remove python3-pip git
COPY Measure.sh .
COPY Quantize.sh .
