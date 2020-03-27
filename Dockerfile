FROM nvidia/cuda:10.0-base

# Setup Python
ARG DEBIAN_FRONTEND=noninteractive
# Pick up some python and CUDA toolkit dependencies. exclude libnccl2=2.4.8-1+cuda10.0, cuda-npp-10-0 cuda-nvgraph-10-0
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common curl bzip2 tcl tk libffi-dev libgomp1 libssl-dev \
    cuda-nvrtc-10-0 cuda-nvtx-10-0 \
    cuda-cusparse-10-0 cuda-curand-10-0 cuda-cublas-10-0 cuda-cusolver-10-0 cuda-cufft-10-0 \
    && add-apt-repository ppa:deadsnakes/ppa && apt-get update && apt-get purge -y python3.6 && apt-get install -y python3.7

RUN rm /usr/bin/python3 /usr/bin/python3m \
    && ln -s /usr/bin/python3.7 /usr/bin/python && ln -s /usr/bin/python3.7 /usr/bin/python3 && ln -s /usr/bin/python3.7m /usr/bin/python3m
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python get-pip.py
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* .cache/

# Install Pytorch 1.1.0 first:
COPY build-pytorch/torch-1.1.0-cp37-cp37m-linux_x86_64.whl .
RUN pip3.7 --no-cache-dir install torch-1.1.0-cp37-cp37m-linux_x86_64.whl && rm torch-1.1.0-cp37-cp37m-linux_x86_64.whl

# All other dependencies, remove cupy-cuda100 with extra cuda libraries we don't want
COPY requirements.txt .
RUN pip3.7 --no-cache-dir install -r requirements.txt && pip3.7 uninstall cupy-cuda100 -y

# Install Cupy 7.3.0 without NCCL or NPP etc
COPY build-cupy/cupy-7.3.0-cp37-cp37m-linux_x86_64.whl .
RUN pip3.7 --no-cache-dir install cupy-7.3.0-cp37-cp37m-linux_x86_64.whl && rm cupy-7.3.0-cp37-cp37m-linux_x86_64.whl

# App code
COPY hello_gpu.py .
COPY hello_gpu.sh .

# Start the App
CMD ./hello_gpu.sh
