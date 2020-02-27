install:
	pip3 install -r requirements.txt

build:
	docker build -t spacygpu:latest .

run:
	docker run --name spacygpu --rm -it --gpus all spacygpu:latest
