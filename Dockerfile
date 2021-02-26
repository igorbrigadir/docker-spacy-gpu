# syntax = docker/dockerfile:experimental

FROM python:3.7-slim-buster as compile-image
ENV DOCKER_STAGE=build

# Create Spacy Environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install -r requirements.txt

FROM python:3.7-slim-buster as run-image
ENV DOCKER_STAGE=run

ARG DEBIAN_FRONTEND=noninteractive

# Install CUDA
RUN apt update && apt install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl

ENV CUDA_VERSION 11.0.3

RUN apt update && apt install -y --no-install-recommends \
    cuda-libraries-11-0=11.0.3-1 \
    cuda-cudart-11-0=11.0.221-1 \
    cuda-compat-11-0 \
    cuda-nvrtc-11-0 \
    cuda-nvtx-11-0=11.0.167-1 \
    libcusparse-11-0=11.1.1.245-1 \
    libcublas-11-0=11.2.0.252-1 \
    libgomp1 \ 
    && ln -s cuda-11.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* .cache/

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"

# Spacy Environment
COPY --from=compile-image /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

# App 
COPY hello_gpu.py .
CMD ["python", "hello_gpu.py"]
