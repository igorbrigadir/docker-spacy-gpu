MODEL_NAME = "en_trf_distilbertbaseuncased_lg-2.2.0"
MODEL_DOWNLOAD = "https://github.com/explosion/spacy-models/releases/download/${MODEL_NAME}/${MODEL_NAME}.tar.gz"
MODEL_PATH = "${MODEL_NAME}/en_trf_distilbertbaseuncased_lg/${MODEL_NAME}"

all: install build run

data:
	@echo "Downloading Transformer Model..."
	if [ -d "model" ]; then echo "Directory exists."; else mkdir model; fi
	if [ -d "model/${MODEL_NAME}" ]; then echo "Model exists."; else wget -qO- ${MODEL_DOWNLOAD} | tar --directory ${PWD}/model --strip-components=2 -xzf - ${MODEL_PATH}; fi

pytorch:
	@echo "Making Pytorch 1.1.0 slim version..."
	if [ ! -z $$(docker images pytorch:slim -q) ]; then echo "Pytorch builder exists"; else DOCKER_BUILDKIT=1 docker build -t pytorch:slim build-pytorch/; fi

cupy:
	@echo "Making Cupy 7.3.0 slim version..."
	if [ ! -z $$(docker images cupy:slim -q) ]; then echo "Cupy builder exists"; else DOCKER_BUILDKIT=1 docker build -t cupy:slim build-cupy/; fi

install: data pytorch cupy

build:
	if [ -f "${PWD}/build-pytorch/torch-1.1.0-cp37-cp37m-linux_x86_64.whl" ]; then echo "Torch 1.1.0 exists."; else docker run --name build-pytorch --rm -v ${PWD}/build-pytorch:/output pytorch:slim; fi
	if [ -f "${PWD}/build-cupy/cupy-7.3.0-cp37-cp37m-linux_x86_64.whl" ]; then echo "Cupy 7.3.0 exists."; else docker run --name build-cupy --rm -v ${PWD}/build-cupy:/output cupy:slim; fi
	@echo "Build Docker Image..."
	DOCKER_BUILDKIT=1 docker build -t spacygpu:latest .

squash:
	docker save spacygpu:latest > spacygpu.tar
	sudo docker-squash -i spacygpu.tar -o squashed.tar -t spacygpu:squash -verbose
	docker import squashed.tar spacygpu:squash
	rm spacygpu.tar squashed.tar

run:
	@echo "Run Test:"
	docker run --name spacygpu --rm -it --gpus all -v ${PWD}/model:/model spacygpu:latest
