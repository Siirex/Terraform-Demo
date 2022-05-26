
output "codedeploy_app_name" {
  value = aws_codedeploy_app.deploy_ecs.name
}

output "codedeploy_deployment_group_name" {
  value = aws_codedeploy_deployment_group.deploy_ecs.deployment_group_name
}
