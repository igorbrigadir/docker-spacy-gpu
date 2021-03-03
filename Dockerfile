# syntax = docker/dockerfile:experimental

FROM python:3.7-slim-buster as compile-image
ENV DOCKER_STAGE=build

# Create Spacy Environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install slimmed pytorch (supports CUDA Toolkit 7.5+PTX only)
COPY build-pytorch/torch-1.7.0a0-cp37-cp37m-linux_x86_64.whl .
RUN pip install --force-reinstall torch-1.7.0a0-cp37-cp37m-linux_x86_64.whl

COPY build-cupy/cupy-8.4.0-cp37-cp37m-linux_x86_64.whl .
RUN pip install --force-reinstall cupy-8.4.0-cp37-cp37m-linux_x86_64.whl

COPY requirements.txt .
RUN pip install -r requirements.txt --no-deps

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

# Smaller cuda install than cuda-libraries-11-0 removes: libnpp-11-0, libnvjpeg-11-0.
RUN apt update && apt install -y --no-install-recommends \
    cuda-cudart-11-0 \
    cuda-nvrtc-11-0 \
    libcublas-11-0 \
    libcufft-11-0 \
    libcurand-11-0 \
    libcusolver-11-0 \
    libcusparse-11-0 \
    cuda-compat-11-0 \
    cuda-nvtx-11-0 \
    libgomp1 \
    && ln -s cuda-11.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* .cache/ && \
    rm /usr/local/cuda/targets/x86_64-linux/lib/libcusolverMg.so*

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
