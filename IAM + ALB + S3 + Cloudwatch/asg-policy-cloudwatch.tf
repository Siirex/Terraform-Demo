
resource "aws_autoscaling_policy" "up" {
  name = "asg-instance-up"
  policy_type = "SimpleScaling"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "down" {
  name = "asg-instance-up"
  policy_type = "SimpleScaling"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# Alarm sẽ được kích hoạt nếu tổng mức CPU Utilization của ASG Instances >/= 10% trong 120s:
resource "aws_cloudwatch_metric_alarm" "up" {
  alarm_name = "asg-instance-cpu-alarm-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [ aws_autoscaling_policy.up.arn ]
}

# Alarm sẽ được kích hoạt nếu tổng mức CPU Utilization của ASG Instances </= 3% trong 120s:
resource "aws_cloudwatch_metric_alarm" "down" {
  alarm_name = "asg-instance-cpu-alarm-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "3"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_actions = [ aws_autoscaling_policy.down.arn ]
}

