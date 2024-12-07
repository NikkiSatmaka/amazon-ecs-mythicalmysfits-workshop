#!/usr/bin/env bash

IMAGE_NAME="monolith-service"
IMAGE_TAG="latest"

FULL_IMAGE_URI="${IMAGE_NAME}:${IMAGE_TAG}"

echo "Building Docker image..."
docker build --network host -t "${FULL_IMAGE_URI}" .
