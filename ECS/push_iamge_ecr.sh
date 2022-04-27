#!/bin/bash

ECR_URL=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Repo Authenticate:
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URL}

REPOSITORY=${REPOSITORY}

# Build image, đồng thời khai báo một biến 'MESSAGE' (không truyền giá trị)
# Giá trị của biến 'MESSAGE' sẽ được truyền vào trong quá trình định nghĩa container trong Task 'container_definitions.json'
docker build . -t ${REPOSITORY}:${TAG} \
  --build-arg MESSAGE=${MESSAGE}

# Add tag & Push image to ECR Repo 
docker tag ${REPOSITORY}:${TAG} ${ECR_URL}/${REPOSITORY}:${TAG}
docker push ${ECR_URL}/${REPOSITORY}:${TAG}

