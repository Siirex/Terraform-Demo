
# https://www.wbotelhos.com/aws-ecs-with-terraform

# https://dev.to/thnery/create-an-aws-ecs-cluster-using-terraform-g80

# Infra cung cấp môi trường ECS với 2 cơ chế compatibilities "EC2" & "FARGATE", với Cluster gồm:

- Sử dụng Launch_type là "EC2": 1 Instance (AutoScale), trong đó chạy 1 [service] liên kết 1 [task], task đó (task-test) chứa 1 [container] chạy Web service

    > ASG Instance được đặt trong vùng Public Subnets, và được ALB forward request đến [container]

- Sử dụng Launch_type là "FARGATE": AWS sẽ cung cấp môi trường (instances) để chạy Docker Container, trong đó chạy 1 [service] liên kết 1 [task], task đó (task-test__fargate) chứa 1 [container] chạy Web service

    > Môi trường triển khai được AWS cung cấp sẽ đạt trong vùng Private Subnets (cách ly hoàn toàn với Internet), nhưng vẫn được ALB trọc vào và forward request đến [container] trong đó


# Các bước thực hiện:

0. Test Docker image (/appliction) <sh test.sh

1. Terraform init

2. Tạo ECR Repo <terraform apply -target=aws_ecr_repository.ecr

3. Push image to ECR <sh push.sh
