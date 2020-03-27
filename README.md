# Spacy Transformers with GPU support in Docker

Minimal image for deploying GPU Docker containers that run [SpaCy Transformers](https://github.com/explosion/spacy-transformers). To use docker-compose you need [nvidia-docker](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-2.0)) runtime.

This also builds pytorch 1.1.0 and cupy 7.3.0 without cuDNN and a bunch of other dependencies that don't impact spacy transformers much, saving a lot of space. The final image is `1.86 GB`. Building these images for the first time takes a while. You end up with something that's essentially a mix of `python3.7-slim-buster` and `nvidia/cuda:10.0-base`.

To build all the containers:

```
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

```
nvidia-docker run --name spacygpu --rm -it -v ${PWD}/model:/model spacygpu:latest
```

or

```bash
docker run --name spacygpu --runtime=nvidia --rm -it --gpus all -v ${PWD}/model:/model spacygpu:latest
```
