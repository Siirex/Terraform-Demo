
resource "aws_codedeploy_app" "deploy_ecs" {
  name = var.deploy_app_ecs_name
  compute_platform = var.deploy_ecs_platform
}

resource "aws_codedeploy_deployment_group" "deploy_ecs" {
  app_name = aws_codedeploy_app.deploy_ecs.name
  deployment_config_name = var.deployment_config_ecs
  deployment_group_name = var.deployment_group_ecs_name
  service_role_arn = var.codedeploy_for_ecs_role_arn

  # Tự động khôi phục lại Deployment Group khi xuất hiện các events:
  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_FAILURE"] //triển khai không thành công
    # events = ["DEPLOYMENT_STOP_ON_ALARM"] //đạt đến ngưỡng giám sát chỉ định
  }

  blue_green_deployment_config {

    # Thông tin về hành động cần thực hiện khi các phiên bản mới được cung cấp sẵn sàng nhận lưu lượng truy cập
    deployment_ready_option {
      # Khi nào cần định tuyến lại lưu lượng truy cập từ môi trường ban đầu (Blue) sang môi trường thay thế (Green)?
      action_on_timeout = "CONTINUE_DEPLOYMENT" //--> Restriger phiên bản mới với LB, ngay sau khi bản sửa đổi ứng dụng mới được cài đặt trên các phiên bản trong môi trường thay thế.
    }

    # Thông tin về cách các phiên bản được cung cấp cho môi trường thay thế (Green)
    green_fleet_provisioning_option {
      
    }

    # Thông tin về việc có chấm dứt các phiên bản trong môi trường ban đầu (Blue)
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE" //các phiên bản được kết thúc sau một thời gian chờ được chỉ định.
      termination_wait_time_in_minutes = 5 //số minutes phải đợi sau khi triển khai thành công.
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    # Rolling Update (xung đột với target_group_pair_info)
    /*
    target_group_info {
      name = aws_lb_target_group.ecs.name
    }
    */

    # Bule/Green Deployment
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = var.listener_arns
      }
      target_group {
        name = var.blue_target_name
      }
      target_group {
        name = var.green_target_name
      }
    }
  }
}

