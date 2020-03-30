# build stage
# ========================
FROM python:3.7-slim-buster as build
#############################
ENV DOCKER_STAGE=run PYTHONUNBUFFERED=1
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 10.0.130
ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-$CUDA_PKG_VERSION cuda-compat-10-0 cuda-nvrtc-10-0 cuda-nvtx-10-0 \
    cuda-cusparse-10-0 cuda-curand-10-0 cuda-cublas-10-0 cuda-cusolver-10-0 cuda-cufft-10-0 libgomp1 && \
    ln -s cuda-10.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* .cache/

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

COPY requirements.txt .
RUN pip wheel --wheel-dir /wheels --find-links /wheels -r requirements.txt && rm /wheels/torch-*.whl && rm /wheels/cupy*.whl

COPY build-pytorch/torch-1.1.0-cp37-cp37m-linux_x86_64.whl /wheels
COPY build-cupy/cupy-7.3.0-cp37-cp37m-linux_x86_64.whl /wheels

#App
#RUN pip wheel --wheel-dir /wheels --find-links /wheels --no-index .

# run stage
# ===========================
FROM python:3.7-slim-buster as run
#############################
ENV DOCKER_STAGE=run PYTHONUNBUFFERED=1
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 10.0.130
ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-$CUDA_PKG_VERSION cuda-compat-10-0 cuda-nvrtc-10-0 cuda-nvtx-10-0 \
    cuda-cusparse-10-0 cuda-curand-10-0 cuda-cublas-10-0 cuda-cusolver-10-0 cuda-cufft-10-0 libgomp1 && \ 
    ln -s cuda-10.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* .cache/

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"

# Requirements
COPY --from=build /wheels /wheels
RUN pip --no-cache-dir install --find-links /wheels --no-index /wheels/* && rm -rf /wheels

# App code
COPY hello_gpu.py .
COPY hello_gpu.sh .

# Start the App
CMD ./hello_gpu.sh
