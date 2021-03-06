ROOT = $(shell git rev-parse --show-toplevel)
DOCKER_RUN_ROOT=$(ROOT)

export DOCKER_RUN_ROOT

# image_builder - required for all other tasks

image_builder-build: build_tooling-build
	docker build \
    	--file ./image_builder/Dockerfile \
    	--tag wellcome/image_builder:latest \
    	./image_builder

build_tooling-build:
	docker build \
    	--file ./build_tooling/Dockerfile \
    	--tag wellcome/build_tooling:latest \
    	./build_tooling

flake8-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=flake8

tox-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=tox

terraform_wrapper-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=terraform_wrapper

jslint-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=jslint

format_json-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=format_json

publish_lambda-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=publish_lambda


test_lambda-build: image_builder-build
	docker build \
    	--file ./test_lambda/Dockerfile \
    	--tag wellcome/test_lambda:latest \
    	./test_lambda

test_python-build: image_builder-build
	docker build \
    	--file ./test_python/Dockerfile \
    	--tag wellcome/test_python:latest \
    	./test_python

build_test_python-build: image_builder-build
	docker build \
    	--file ./build_test_python/Dockerfile \
    	--tag wellcome/build_test_python:latest \
    	./build_test_python

publish_service-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=publish_service

nginx-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=nginx

finatra_service_base-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=finatra_service_base

sbt_wrapper-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=sbt_wrapper

scalafmt-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=scalafmt

# sqs_freezeray

FREEZERAY = $(ROOT)/sqs_freezeray

$(FREEZERAY)/requirements.txt: $(FREEZERAY)/requirements.in
	docker run --rm --volume $(FREEZERAY):/src --rm micktwomey/pip-tools

sqs_freezeray-build: image_builder-build $(FREEZERAY)/requirements.txt
	./docker_run.py --dind -- wellcome/image_builder:latest --project=sqs_freezeray

# sqs_redrive

SQS_REDRIVE = $(ROOT)/sqs_redrive

$(SQS_REDRIVE)/requirements.txt: $(SQS_REDRIVE)/requirements.in
	docker run --rm --volume $(SQS_REDRIVE):/src --rm micktwomey/pip-tools

sqs_redrive-build: image_builder-build $(SQS_REDRIVE)/requirements.txt
	./docker_run.py --dind -- wellcome/image_builder:latest --project=sqs_redrive

# cache_cleaner

cache_cleaner-build: image_builder-build
	./docker_run.py --dind -- wellcome/image_builder:latest --project=cache_cleaner

# turtlelint

turtlelint/requirements.txt: turtlelint/requirements.in
	docker run --rm --volume $$(pwd)/turtlelint:/src micktwomey/pip-tools

turtlelint-build: turtlelint/requirements.txt
	./docker_run.py --dind -- wellcome/image_builder:latest --project=publish_lambda
