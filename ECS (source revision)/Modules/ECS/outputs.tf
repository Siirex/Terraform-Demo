
output "ecs_cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.cluster.arn
}

output "ecs_taskdef_arn" {
  value = aws_ecs_task_definition.task.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.service.name
}

output "sg_ecs_service_id" {
  # value = aws_security_group.sg_service[0].id //error
  value = [ aws_security_group.sg_service.*.id ]
}

