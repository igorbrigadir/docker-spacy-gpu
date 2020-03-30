# Spacy Transformers with GPU support in Docker

Minimal image for deploying GPU Docker containers that run [SpaCy Transformers](https://github.com/explosion/spacy-transformers). To use docker-compose you need [nvidia-docker](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-2.0)) runtime.

The models are stored in a `/model` volume outside the container, so make sure that downloads first with `make model`.

This also builds pytorch 1.1.0 with a subset of libraries and cupy 7.3.0 without cuDNN and a bunch of other dependencies that don't impact spacy transformers much, saving a lot of space. the use case is simple embedding, not training models so a lot of extra libraries can be removed.

The final image is `1.26 GB`. Building these images for the first time takes a while. You end up with something that's essentially a mix of `python3.7-slim-buster` and `nvidia/cuda:10.0-base`, with PyTorch, Cupy, and Spacy Transformers.

First, enable [Docker Experimental](https://github.com/docker/docker-ce/blob/master/components/cli/experimental/README.md#use-docker-experimental). To build all the containers:

```bash
make
```

To run the test:

```bash
make run
```

or

```bash
docker-compose up
```

or

```bash
nvidia-docker run --name spacygpu --rm -it -v ${PWD}/model:/model spacygpu:latest
```

or

```bash
docker run --name spacygpu --runtime=nvidia --rm -it --gpus all -v ${PWD}/model:/model spacygpu:latest
```
