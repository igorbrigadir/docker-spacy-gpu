FROM nvidia/cuda:11.0-devel-ubuntu18.04
ARG PYTHON_VERSION=3.7
ARG WITH_TORCHVISION=0

# Some dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential cmake git curl ca-certificates \
         software-properties-common bzip2 libffi-dev libgomp1 libssl-dev

# For MKL, add mkl mkl-include
RUN curl -L -o ~/miniconda.sh -O https://repo.continuum.io/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh && \
     chmod +x ~/miniconda.sh 
RUN  ~/miniconda.sh -b -p /opt/conda && rm ~/miniconda.sh
RUN  /opt/conda/bin/conda install -y python=$PYTHON_VERSION nomkl numpy pyyaml scipy ipython ninja cython typing && \
     /opt/conda/bin/conda install -y -c pytorch magma-cuda110 && \
     /opt/conda/bin/conda clean -ya
ENV PATH /opt/conda/bin:$PATH

# Remove nccl, etc. need cufft, cublas, curand, cusolver
RUN apt-get remove -y libnccl-dev libnccl2 libnpp-11-0 --allow-change-held-packages

# Need v8.4.0
RUN git clone -b 'v8.4.0' --single-branch --depth 1 https://github.com/cupy/cupy.git

WORKDIR /cupy

RUN git submodule update --init --recursive

# Build cupy with subset of libraries:

ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

RUN pip install Cython

RUN pip wheel .

# once image is built, just copy the wheel over
CMD cp cupy*.whl /output/
