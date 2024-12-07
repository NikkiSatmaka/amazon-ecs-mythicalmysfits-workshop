#!/usr/bin/env bash

export AWS_PROFILE="awslab"

AWS_REGION="us-east-1"
IMAGE_NAME="monolith-service"
IMAGE_TAG="latest"
PORT="8080"

if ! grep -q "^\[${AWS_PROFILE}\]" ~/.config/aws/credentials; then
    echo "Error: AWS profile '${AWS_PROFILE}' does not exist."
    exit 1
fi

TABLE_NAME=$(aws dynamodb list-tables | jq -r '.TableNames[0]')
AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
AWS_SESSION_TOKEN=$(aws configure get aws_session_token)

REPO_NAME=${IMAGE_NAME}
REPO_URI=${REPO_NAME}
FULL_IMAGE_URI="${REPO_URI}:${IMAGE_TAG}"

if ! docker images | grep -q "^${REPO_NAME}\s*${IMAGE_TAG}"; then
    echo "Error: Docker image '${FULL_IMAGE_URI}' does not exist"
    exit 1
fi

echo "Running Docker locally..."
docker run --rm --network common -p ${PORT}:80 \
    -e AWS_DEFAULT_REGION="${AWS_REGION}" \
    -e DDB_TABLE_NAME="${TABLE_NAME}" \
    -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
    -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
    -e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
    --name "${IMAGE_NAME}" \
    ${FULL_IMAGE_URI}
