
IMDS_TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 600")
export INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $IMDS_TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)

aws ec2 modify-instance-attribute --region ${region} --instance-id $INSTANCE_ID --source-dest-check "{\"Value\": false}"

