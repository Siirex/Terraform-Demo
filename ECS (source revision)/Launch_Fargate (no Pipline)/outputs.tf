
output "alb_dns_name" {
  value = module.alb.dns_name
}

output "codecommit_repo_url" {
  value = module.repo_app.repo_url
}


