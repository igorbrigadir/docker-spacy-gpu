FROM nvidia/cuda:10.0-devel-ubuntu16.04
ARG PYTHON_VERSION=3.7
ARG WITH_TORCHVISION=0

# Some dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         software-properties-common bzip2 tcl tk libffi-dev libgomp1 libssl-dev

# Python 3.7
RUN add-apt-repository ppa:deadsnakes/ppa && apt-get update
RUN apt-get install -y python3.7 python3.7-dev
RUN rm /usr/bin/python3 /usr/bin/python3m \
    && ln -s /usr/bin/python3.7 /usr/bin/python \
    && ln -s /usr/bin/python3.7 /usr/bin/python3 \
    && ln -s /usr/bin/python3.7m /usr/bin/python3m
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python get-pip.py

# MKL
#RUN curl -o ~/miniconda.sh -O https://repo.continuum.io/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh && \
#     chmod +x ~/miniconda.sh && \
#     ~/miniconda.sh -b -p /opt/conda && \
#     rm ~/miniconda.sh && \
#     /opt/conda/bin/conda install -y python=$PYTHON_VERSION numpy pyyaml scipy ipython mkl mkl-include ninja cython typing && \
#     /opt/conda/bin/conda install -y -c pytorch magma-cuda100 && \
#     /opt/conda/bin/conda clean -ya
#ENV PATH /opt/conda/bin:$PATH

# Remove nccl, etc need cufft, cublas, curand,
RUN apt-get remove -y libnccl-dev libnccl2 cuda-npp-10-0 cuda-nvgraph-10-0 --allow-change-held-packages

# Need v7.3
RUN git clone -b 'v7.3.0' --single-branch --depth 1 https://github.com/cupy/cupy.git

WORKDIR /cupy

RUN pip install Cython
RUN pip wheel .

# once image is built, just copy the wheel over
CMD cp cupy*.whl /output/
