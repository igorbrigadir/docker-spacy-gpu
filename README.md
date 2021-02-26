# Spacy Transformers with GPU support in Docker

Minimal image for GPU Docker container that runs [SpaCy Transformers](https://github.com/explosion/spacy-transformers). To use docker-compose you need [nvidia-docker](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-2.0)) runtime.

The models are stored in a `/model` volume outside the container, so make sure that downloads first with `make model`.

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
