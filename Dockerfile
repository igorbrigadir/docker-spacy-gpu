FROM nvidia/cuda:10.0-runtime

# Setup Python
ARG DEBIAN_FRONTEND=noninteractive
# Pick up some python and CUDA toolkit dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common curl bzip2 tcl tk libffi-dev libgomp1 libssl-dev \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update
RUN apt-get install -y python3.7 python3.7-dev
RUN rm /usr/bin/python3 /usr/bin/python3m \
    && ln -s /usr/bin/python3.7 /usr/bin/python \
    && ln -s /usr/bin/python3.7 /usr/bin/python3 \
    && ln -s /usr/bin/python3.7m /usr/bin/python3m
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python get-pip.py
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Pytorch 1.1.0 first:
COPY build-pytorch/torch-1.1.0-cp37-cp37m-linux_x86_64.whl .
RUN pip3 --no-cache-dir install torch-1.1.0-cp37-cp37m-linux_x86_64.whl && rm torch-1.1.0-cp37-cp37m-linux_x86_64.whl

# All other dependencies
COPY requirements.txt .
RUN pip3 --no-cache-dir install -r requirements.txt

# Model is in a volume

# App code
COPY hello_gpu.py .

# Start the App
CMD ["python", "hello_gpu.py"]
