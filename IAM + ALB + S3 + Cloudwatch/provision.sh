#!/bin/bash -ex
yum -y update
yum -y install httpd php mysql php-mysql
chkconfig httpd on
service httpd start

# Target group page for Health Check
cd /
mkdir healthcheck
cd /healthcheck
touch index.html

# Test
cd /
mkdir bucket-data
cd /bucket-data
echo '<h1>upload from Local done</h1>' > ./upload.html

# Upload file to Bucket (default, uploaded files do not have public access, can set permission)
aws s3 cp upload.html s3://${bucket}/ --acl public-read

# Get file to Bucket
aws s3 cp s3://${bucket}/${object} ./

# Application
cd /var/www/html
wget https://s3-us-west-2.amazonaws.com/us-west-2-aws-training/awsu-spl/spl-13/scripts/app.tgz
tar xvfz app.tgz
chown apache:root /var/www/html/rds.conf.php
