DOCKER_COMPOSE=docker-compose.yml
DOCKERFILE=Dockerfile
DOCKER_REGISTRY=ghcr.io
DOCKER_REPOSITORY=${DOCKER_REGISTRY}/auto-gpt/sandbox

PYTHON_DEPENDENCIES=requirements.txt


IMAGE_TAG=$(shell cat $(DOCKERFILE) $(PYTHON_DEPENDENCIES) | md5sum | cut -d ' ' -f 1)
IMAGE_URL=$(DOCKER_REPOSITORY):$(IMAGE_TAG)

DOCKER_COMPOSE_RUN=docker-compose -f $(DOCKER_COMPOSE) run --rm sandbox

.PHONY: image
image: $(DOCKERFILE) $(PYTHON_DEPENDENCIES)
	echo building ${IMAGE_URL}
	docker build -t ${IMAGE_URL} -f $(DOCKERFILE) .
	docker tag ${IMAGE_URL} ${DOCKER_REPOSITORY}:latest

.PHONY: compose
compose: image

.PHONY: shell
bash: compose
	${DOCKER_COMPOSE_RUN} /bin/bash

.PHONY: test
test: compose pytest

.PHONY: lint
test: compose flake8 black-check

.PHONY: format
format: black isort

.PHONY: black
black: compose
	${DOCKER_COMPOSE_RUN} black .

.PHONY: black-check
black-check: compose
	${DOCKER_COMPOSE_RUN} black --check .

.PHONY: flake8
flake8: compose
	${DOCKER_COMPOSE_RUN} flake8 .

.PHONY: isort
isort: compose
	${DOCKER_COMPOSE_RUN} isort .

.PHONY: pytest
pytest: compose
	${DOCKER_COMPOSE_RUN} pytest

.PHONY: pyright
pyright: compose
	${DOCKER_COMPOSE_RUN} pyright

.PHONY: run
run: compose
	${DOCKER_COMPOSE_RUN}