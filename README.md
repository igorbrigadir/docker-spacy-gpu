# docker-spacy-gpu

Minimal image for deploying GPU Docker containers that run SpaCy. To use docker-compose you need [nvidia-docker](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-2.0)) runtime.

To run the test:

```bash
make
```

or

```bash
docker-compose up
```

or

```bash
docker run --name spacygpu --runtime=nvidia --rm -it --gpus all -v ${PWD}/model:/model spacygpu:latest
```
