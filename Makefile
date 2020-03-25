MODEL_NAME = "en_trf_distilbertbaseuncased_lg-2.2.0"
MODEL_DOWNLOAD = "https://github.com/explosion/spacy-models/releases/download/${MODEL_NAME}/${MODEL_NAME}.tar.gz"
MODEL_PATH = "${MODEL_NAME}/en_trf_distilbertbaseuncased_lg/${MODEL_NAME}"

all: install build run

install:
	@echo "Downloading Model..."
	if [ -d "model" ]; then echo "Directory exists."; else mkdir model; fi
	if [ -d "model/${MODEL_NAME}" ]; then echo "Model exists."; else wget -qO- ${MODEL_DOWNLOAD} | tar --directory ${PWD}/model --strip-components=2 -xzf - ${MODEL_PATH}; fi

build:
	@echo "Build Pytorch 1.1.0..."
	DOCKER_BUILDKIT=1 docker build -t pytorch:slim build-pytorch/
	docker run --name build-pytorch --runtime=nvidia --rm -it --gpus all -v ${PWD}/build-pytorch:/output pytorch:slim
	@echo "Build Docker Image..."
	DOCKER_BUILDKIT=1 docker build -t spacygpu:latest .

run:
	@echo "Run Test:"
	docker run --name spacygpu --rm -it --gpus all -v ${PWD}/model:/model spacygpu:latest
