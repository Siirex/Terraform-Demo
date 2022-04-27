
resource "aws_ecs_cluster" "cluster" {
  name = "stage-test"

  # Đảm bảo thông tin chi tiết về container được bật trên Cluster
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  lifecycle {
    create_before_destroy = true
  }
}
