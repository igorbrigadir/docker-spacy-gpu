MODEL_NAME = "distilbert-base-nli-stsb-mean-tokens"

all: install build run

install:
	@echo "Download ${MODEL_NAME} Transformer Model..."
	if [ -d "model" ]; then echo "Directory exists."; else mkdir model; fi
	if [ -d "model/${MODEL_NAME}" ]; then echo "Model exists."; else cd model && git lfs install && git clone https://huggingface.co/sentence-transformers/${MODEL_NAME}; fi

build:
	@echo "Build Docker Image..."
	DOCKER_BUILDKIT=1 docker build -t spacygpu:latest --squash .

run:
	@echo "Run Test:"
	docker run --name spacygpu --rm -it --gpus all -v ${PWD}/model:/model spacygpu:latest
