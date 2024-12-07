#!/usr/bin/env bash

export AWS_PROFILE="awslab"

AWS_REGION="us-east-1"
SERVICE_TYPE="mono"
IMAGE_TAG="latest"

if ! grep -q "^\[${AWS_PROFILE}\]" ~/.config/aws/credentials; then
    echo "Error: AWS profile '${AWS_PROFILE}' does not exist."
    exit 1
fi

if ! command -v docker-credential-ecr-login >/dev/null 2>&1; then
    echo "Amazon ECR Docker Credential Helper does not exist."
    echo "Install it from https://github.com/awslabs/amazon-ecr-credential-helper"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_NAME=$(aws ecr describe-repositories | jq -r '.repositories[].repositoryName' | rg ${SERVICE_TYPE})
REPO_URI=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}
FULL_IMAGE_URI="${REPO_URI}:${IMAGE_TAG}"

echo "Building Docker image..."
docker build --network host -t "${FULL_IMAGE_URI}" .

echo "Pushing Docker image to AWS ECR..."
docker push "${FULL_IMAGE_URI}"
