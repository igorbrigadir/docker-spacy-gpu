MODEL_NAME = "en_trf_distilbertbaseuncased_lg-2.2.0"
MODEL_DOWNLOAD = "https://github.com/explosion/spacy-models/releases/download/${MODEL_NAME}/${MODEL_NAME}.tar.gz"
MODEL_PATH = "$(MODEL_NAME)/en_trf_distilbertbaseuncased_lg/${MODEL_NAME}"

all: install build run

install:
	@echo "Downloading Model..."
	if [ -d "model" ]; then echo "Directory exists."; else mkdir model; fi
	if [ -d "model/${MODEL_NAME}" ]; then echo "Model exists."; else wget -qO- ${MODEL_DOWNLOAD} | tar --directory ${PWD}/model --strip-components=2 -xzf - ${MODEL_PATH}; fi

build:
	docker build -t spacygpu:latest .

run:
	docker run --name spacygpu --rm -it --gpus all -v ${PWD}/model:/model spacygpu:latest
