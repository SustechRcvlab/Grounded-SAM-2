# Get version of CUDA and enable it for compilation if CUDA > 11.0
# This solves https://github.com/IDEA-Research/Grounded-Segment-Anything/issues/53
# and https://github.com/IDEA-Research/Grounded-Segment-Anything/issues/84
# when running in Docker
# Check if nvcc is installed
NVCC := $(shell which nvcc)
ifeq ($(NVCC),)
	# NVCC not found
	USE_CUDA := 0
	NVCC_VERSION := "not installed"
else
	NVCC_VERSION := $(shell nvcc --version | grep -oP 'release \K[0-9.]+')
	USE_CUDA := $(shell echo "$(NVCC_VERSION) > 11" | bc -l)
endif

# Add the list of supported ARCHs
ifeq ($(USE_CUDA), 1)
	TORCH_CUDA_ARCH_LIST := "7.0;7.5;8.0;8.6+PTX"
	BUILD_MESSAGE := "I will try to build the image with CUDA support"
else
	TORCH_CUDA_ARCH_LIST :=
	BUILD_MESSAGE := "CUDA $(NVCC_VERSION) is not supported"
endif

IMAGE_NAME := grounded_sam2
IMAGE_TAG  := latest

build-image:
	@echo $(BUILD_MESSAGE)
	docker build --build-arg USE_CUDA=$(USE_CUDA) \
	--build-arg TORCH_ARCH=$(TORCH_CUDA_ARCH_LIST) \
	-t $(IMAGE_NAME):$(IMAGE_TAG) .

run:
	docker run --gpus all -it --rm --net=host --privileged \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v "${PWD}":/home/appuser/Grounded-SAM-2 \
	-e DISPLAY=$DISPLAY \
	--name=gsa \
	--ipc=host -it $(IMAGE_NAME):$(IMAGE_TAG)

# Run in detached mode with named volumes for checkpoints/outputs
run-detached:
	docker compose -f docker-compose.grounded_sam2.yaml up -d

# Stop the detached container
stop:
	docker compose -f docker-compose.grounded_sam2.yaml down

# Build using the compose file (respects USE_CUDA / TORCH_ARCH env vars)
build-compose:
	USE_CUDA=$(USE_CUDA) TORCH_ARCH=$(TORCH_CUDA_ARCH_LIST) \
	docker compose -f docker-compose.grounded_sam2.yaml build

# Open an interactive shell inside the running container
shell:
	docker exec -it grounded_sam2 bash

# Download SAM 2 checkpoints inside the running container
download-sam2-ckpts:
	docker exec grounded_sam2 bash -c "cd checkpoints && bash download_ckpts.sh"

# Download Grounding DINO checkpoints inside the running container
download-gdino-ckpts:
	docker exec grounded_sam2 bash -c "cd gdino_checkpoints && bash download_ckpts.sh"
