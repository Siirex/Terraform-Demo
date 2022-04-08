
output "public-subnets-cidr" {
  value = module.vpc.public_subnets
}

output "private-subnets-cidr" {
  value = module.vpc.private_subnets
}

output "alb-dns-name" {
  value = module.webserver-cluster.dns_alb
}

/*
output "db-endpoint" {
  value = module.database.db_endpoint
}
*/