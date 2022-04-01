
#!/bin/bash

# Xem tất cả danh mục instance metadata từ bên trong Instance đang chạy từ URL: http://169.254.169.254/latest/meta-data/
# Đọc thêm: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
# Từ đó, ta trích xuất được Instance_ID của NAT_instance này:
IMDS_TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 600")
export INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)

# Để NAT_instance có thể forward các packets từ Private Subnet ra và trở lại, cần phải tắt attribute "SrcDestCheck" cho Instance
# Do đó, cần phải thay đổi bằng lệnh CLI "modify-instance-attribute"
aws ec2 modify-instance-attribute --region ${region} --instance-id $INSTANCE_ID --source-dest-check "{\"Value\": false}"

# Chú ý, việc sửa đổi attribute của EC2 Instance cần phải được ỦY QUYỀN cho phép "thay đổi các thuộc tính riêng" trong IAM!!!
# Vì vậy, trước tiên phải nhận được mã thông báo ủy quyền, sau đó tập lệnh .sh này thực hiện truy vấn với mã thông báo này - thay đổi thuộc tính của NAT_instance.
