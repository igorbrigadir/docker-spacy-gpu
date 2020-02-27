FROM nvidia/cuda:10.0-cudnn7-runtime-ubuntu18.04

# Setup Python
ARG DEBIAN_FRONTEND=noninteractive
# Pick up some python and CUDA toolkit dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common curl bzip2 tcl tk libffi-dev libgomp1 libssl-dev \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update
RUN apt-get install -y python3.7 python3.7-dev
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm /usr/bin/python3 /usr/bin/python3m \
    && ln -s /usr/bin/python3.7 /usr/bin/python \
    && ln -s /usr/bin/python3.7 /usr/bin/python3 \
    && ln -s /usr/bin/python3.7m /usr/bin/python3m
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python get-pip.py

# Requirements
COPY requirements.txt /app/
WORKDIR /app

# App dependencies
RUN pip3 install -r requirements.txt

# Model
RUN python -m spacy download --user en_trf_distilbertbaseuncased_lg

# App code
COPY . /app
WORKDIR /app

# Start the App
CMD ["python", "/app/hello_gpu.py"]
