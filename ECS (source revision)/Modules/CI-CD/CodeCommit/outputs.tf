
output "repo_url" {
  value = aws_codecommit_repository.repo.clone_url_http
}

output "repo_arn" {
  value = aws_codecommit_repository.repo.arn
}
