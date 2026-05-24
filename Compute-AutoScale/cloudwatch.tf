# ---------------------------------------------------------------------------
# SNS Topic for alarm notifications (optional — only if email provided)
# ---------------------------------------------------------------------------
resource "aws_sns_topic" "alarms" {
  count = var.alarm_email != "" ? 1 : 0
  name  = "${var.tag_name}-alarms"
  tags  = { Name = var.tag_name }
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

locals {
  alarm_actions = var.alarm_email != "" ? [aws_sns_topic.alarms[0].arn] : []
}

# ---------------------------------------------------------------------------
# CPU High → trigger scale-out + notify
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.tag_name}-cpu-high"
  alarm_description   = "ASG average CPU above ${var.cpu_scale_out_threshold}% — scaling out"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 120   # 2-minute window
  evaluation_periods  = 2     # must breach 2 consecutive periods
  threshold           = var.cpu_scale_out_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = concat(
    [aws_autoscaling_policy.scale_out.arn],
    local.alarm_actions
  )

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# CPU Low → trigger scale-in
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.tag_name}-cpu-low"
  alarm_description   = "ASG average CPU below ${var.cpu_scale_in_threshold}% — scaling in"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 120
  evaluation_periods  = 3     # wait longer before scaling in
  threshold           = var.cpu_scale_in_threshold
  comparison_operator = "LessThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# ALB 5xx error rate alarm — catches app/infra errors
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.tag_name}-alb-5xx"
  alarm_description   = "ALB is returning 5xx errors"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.web.arn_suffix
  }

  alarm_actions = local.alarm_actions

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# ALB healthy host count — fires when ALL instances are unhealthy
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "healthy_hosts" {
  alarm_name          = "${var.tag_name}-healthy-hosts"
  alarm_description   = "No healthy instances behind the ALB!"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HealthyHostCount"
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"   # alarm if no data — means no hosts

  dimensions = {
    TargetGroup  = aws_lb_target_group.web.arn_suffix
    LoadBalancer = aws_lb.web.arn_suffix
  }

  alarm_actions = local.alarm_actions

  tags = { Name = var.tag_name }
}

# ---------------------------------------------------------------------------
# CloudWatch Dashboard — one-stop view
# ---------------------------------------------------------------------------

locals {
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x = 0; y = 0; width = 12; height = 6
        properties = {
          title  = "ASG CPU Utilization"
          period = 60
          stat   = "Average"
          metrics = [[
            "AWS/EC2", "CPUUtilization",
            "AutoScalingGroupName", aws_autoscaling_group.web.name
          ]]
          annotations = {
            horizontal = [
              { label = "Scale-Out", value = var.cpu_scale_out_threshold, color = "#ff6961" },
              { label = "Scale-In",  value = var.cpu_scale_in_threshold,  color = "#77dd77" }
            ]
          }
        }
      },
      {
        type   = "metric"
        x = 12; y = 0; width = 12; height = 6
        properties = {
          title  = "ALB Request Count & 5xx Errors"
          period = 60
          metrics = [
            ["AWS/ApplicationELB", "RequestCount",         "LoadBalancer", aws_lb.web.arn_suffix, { stat = "Sum",     label = "Requests" }],
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count","LoadBalancer", aws_lb.web.arn_suffix, { stat = "Sum",     label = "5xx Errors" }]
          ]
        }
      },
      {
        type   = "metric"
        x = 0; y = 6; width = 12; height = 6
        properties = {
          title  = "Healthy Host Count"
          period = 60
          stat   = "Minimum"
          metrics = [[
            "AWS/ApplicationELB", "HealthyHostCount",
            "TargetGroup",  aws_lb_target_group.web.arn_suffix,
            "LoadBalancer", aws_lb.web.arn_suffix
          ]]
        }
      },
      {
        type   = "metric"
        x = 12; y = 6; width = 12; height = 6
        properties = {
          title  = "ALB Target Response Time (p99)"
          period = 60
          stat   = "p99"
          metrics = [[
            "AWS/ApplicationELB", "TargetResponseTime",
            "LoadBalancer", aws_lb.web.arn_suffix
          ]]
        }
      }
    ]
  })
}
resource "aws_cloudwatch_dashboard" "phase3" {
  dashboard_name = "${var.tag_name}-Phase3"
  dashboard_body = local.dashboard_body
}
