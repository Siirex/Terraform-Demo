
owner = "hoangminh"

access-key = ""
secret-key = ""

region = "ap-southeast-1"
azs = [ "ap-southeast-1a", "ap-southeast-1b" ]

cidr-vpc = "10.1.0.0/16"
cidr-public-subnet = [ "10.1.3.0/24", "10.1.4.0/24" ]
cidr-private-subnet = [ "10.1.1.0/24", "10.1.2.0/24" ]

ami-webserver = "ami-0356b1cd4aa0ee970" // CentOS 7
ami-nat-instance-bastion = "ami-6aa38238" // with region ap-southeast-1
instance-type = "t2.micro"

db-name = "terraform"
db-username = "hoangminh"
db-pass = "19981998"

/*

  us-east-1:
    "AMI": "ami-184dc970"
  us-west-1:
    "AMI": "ami-a98396ec"
  us-west-2:
    "AMI": "ami-290f4119"
  eu-west-1:
    "AMI": "ami-14913f63"
  eu-central-1:
    "AMI": "ami-ae380eb3"
  sa-east-1:
    "AMI": "ami-8122969c"
  ap-southeast-1:
    "AMI": "ami-6aa38238"
  ap-southeast-2:
    "AMI": "ami-893f53b3"
  ap-northeast-1:
    "AMI": "ami-00d29e4cb217ae06b"
  ap-northeast-2:
    "AMI": "ami-0185fd13b4270de70"

*/