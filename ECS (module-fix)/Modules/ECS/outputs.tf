
output "ecs_cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "sg_ecs_service_id" {
  # value = aws_security_group.sg_service[0].id //error
  value = [ aws_security_group.sg_service.*.id ]
}
