#!/bin/bash

# ECR_URL=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Repo Authenticate:
# aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_URL}

# REPOSITORY=${REPOSITORY}

# Build image, đồng thời khai báo một biến 'MESSAGE' (không truyền giá trị)
# Giá trị của biến 'MESSAGE' sẽ được truyền vào trong quá trình định nghĩa container trong Task 'container_definitions.json'
# docker build . -t ${REPOSITORY}:${TAG} \
#   --build-arg MESSAGE=${MESSAGE}

# Add tag & Push image to ECR Repo 
# docker tag ${REPOSITORY}:${TAG} ${ECR_URL}/${REPOSITORY}:${TAG}
# docker push ${ECR_URL}/${REPOSITORY}:${TAG}


# Tag của Docker Image ở đây là nên đặt 1 góa trị cụ thể (v1.0, v2.0, ... ) không cần thiết đặt là "latest"
# ---- Nếu đặt là "latest", các Tag Image "latest" được update tiếp theo không thẻ PUSH lên ECR được (do không thể ghi đè, vì đã thiết lập Repo là "IMMUTABLE")
# ---- ---- Nếu thiết lập ECR Repo là "MUTABLE" thì có thể ghi đè Tag "latest" mới, và để Tag "latest" cũ là <untagged>
# ---- Mặt khác, nếu để tên Tag là giá trị cụ thể, ta có thể dễ dàng chuyển đổi lại các Image Tag cũ hơn (trường hợp Image Tag update không ổn định)

--> Quá trình PUSH image lên CodeCommit Repo thực giờ sẽ thực hiện trên CodeBuid, không thực hiện tại Local nữa, nên file này không cần thiết nữa !!!
