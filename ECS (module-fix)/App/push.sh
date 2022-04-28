#!/bin/bash

# Vì file "push_iamge_ecr.sh" chứa thông tin xác thực IAM User, nên phải cấp quyền chỉ execute cho nó:
chmod +x ../push_iamge_ecr.sh

# Truyền values cho các ENV trong file push image container lên ECR Repo 
ACCOUNT_ID=99999999999 REGION=ap-southeast-1 REPOSITORY=terraform TAG=v1.0 ./push_iamge_ecr.sh
