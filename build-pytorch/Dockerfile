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

# Need v1.7.1
RUN git clone -b 'v1.7.1' --single-branch --depth 1 https://github.com/pytorch/pytorch.git

WORKDIR /pytorch

RUN git submodule update --init --recursive
RUN pip install -r requirements.txt
RUN pip install pybind11

# Build Pytorch for latest arch only (makes a smaller image):

ENV TORCH_CUDA_ARCH_LIST="7.5+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
#ENV BUILD_SHARED_LIBS=OFF
ENV DEBUG=0
ENV USE_CUDNN=0
ENV USE_OPENCV=0
ENV USE_NCCL=0
ENV BUILD_TEST=0
ENV USE_FFMPEG=0
ENV USE_MKL=0
ENV USE_MKLDNN=0
ENV USE_DISTRIBUTED=0
ENV USE_IBVERBS=0
#ENV BUILD_PYTHON=OFF
ENV BUILD_CAFFE2=0
ENV BUILD_CAFFE2_OPS=0
ENV BUILD_CAFFE2_MOBILE=0
ENV CAFFE2_USE_CUDA=0
ENV MAX_JOBS=64
ENV BLAS=Eigen 
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

RUN pip wheel .

# once image is built, just copy the wheel over
CMD cp torch-*.whl /output/
