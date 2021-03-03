MODEL_NAME = "distilbert-base-nli-stsb-mean-tokens"

all: pytorch cupy install build run

pytorch:
	@echo "Making Pytorch 1.7.1 slim version..."
	if [ ! -z $$(docker images pytorch:slim -q) ]; then echo "Pytorch builder exists"; else DOCKER_BUILDKIT=1 docker build -t pytorch:slim build-pytorch/; fi
	if [ -f "${PWD}/build-pytorch/torch-1.7.1-cp37-cp37m-linux_x86_64.whl" ]; then echo "Torch 1.7.1 exists."; else docker run --name build-pytorch --rm -v ${PWD}/build-pytorch:/output pytorch:slim; fi

cupy:
	@echo "Making Cupy 8.4.0 slim version..."
	if [ ! -z $$(docker images cupy:slim -q) ]; then echo "Cupy builder exists"; else DOCKER_BUILDKIT=1 docker build -t cupy:slim build-cupy/; fi
	if [ -f "${PWD}/build-cupy/cupy-8.4.0-cp37-cp37m-linux_x86_64.whl" ]; then echo "Cupy 8.4.0 exists."; else docker run --name build-cupy --rm -v ${PWD}/build-cupy:/output cupy:slim; fi

install:
	@echo "Download ${MODEL_NAME} Transformer Model..."
	if [ -d "model" ]; then echo "Directory exists."; else mkdir model; fi
	if [ -d "model/${MODEL_NAME}" ]; then echo "Model exists."; else cd model && git lfs install && git clone https://huggingface.co/sentence-transformers/${MODEL_NAME}; fi

build:
	@echo "Build Docker Image..."
	DOCKER_BUILDKIT=1 docker build -t spacygpu:latest .

run:
	@echo "Run Test:"
	docker run --name spacygpu --rm -it --gpus all -v ${PWD}/model:/model spacygpu:latest
