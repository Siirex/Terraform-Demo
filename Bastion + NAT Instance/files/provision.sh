#!/bin/bash -ex
yum -y update
yum -y install httpd php mysql php-mysql
chkconfig httpd on
service httpd start

# Tạo Path /var/www/html/healthcheck/index.html để ALB có thể truy cập vào để Health Check
cd /var/www/html
mkdir healthcheck
cd healthcheck/
touch index.html

# Application
cd /var/www/html
wget https://s3-us-west-2.amazonaws.com/us-west-2-aws-training/awsu-spl/spl-13/scripts/app.tgz
tar xvfz app.tgz
chown apache:root /var/www/html/rds.conf.php
