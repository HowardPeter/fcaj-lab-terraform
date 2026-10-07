resource "aws_lightsail_database" "main" {
  relational_database_name = "Workshop-DB-Instance"
  availability_zone        = var.availability_zone
  master_database_name     = "dbWordPress"
  master_password          = "Sunny2DAY!"
  master_username          = "LightsailAdmin"
  blueprint_id             = "mysql_8_4"
  bundle_id                = "micro_2_0"

  # Lab cleanup, destroy ngay không cần tạo snapshot
  skip_final_snapshot = true
  # final_snapshot_name = "wordpress-db-final-snapshot"

  tags = {
    dbName = "dbWordPress"
  }
}

resource "aws_lightsail_instance" "wordpress" {
  name              = "Workshop-WordPress"
  availability_zone = var.availability_zone
  blueprint_id      = "ubuntu_24_04"
  bundle_id         = "micro_3_0"

  user_data = templatefile("${path.module}/launch_script.sh", {})

  add_on {
    type          = "AutoSnapshot"
    snapshot_time = "06:00"
    status        = "Enabled"
  }
}

resource "aws_lightsail_static_ip" "main" {
  name = "Workshop-WordPress-IP"
}

resource "aws_lightsail_static_ip_attachment" "main" {
  static_ip_name = aws_lightsail_static_ip.main.name
  instance_name  = aws_lightsail_instance.wordpress.name
}

resource "aws_lightsail_instance_public_ports" "main" {
  instance_name = aws_lightsail_instance.wordpress.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidrs     = ["0.0.0.0/0"]
  }

  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidrs     = ["0.0.0.0/0"]
  }
}

resource "awscc_lightsail_alarm" "burst_50" {
  alarm_name              = "wordpress-burst-capacity-50"
  monitored_resource_name = aws_lightsail_instance.wordpress.name

  metric_name         = "BurstCapacityPercentage"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = 50

  evaluation_periods = 1

  # contact_protocols     = ["Email"]
  notification_triggers = ["ALARM"]
}

resource "awscc_lightsail_alarm" "burst_25" {
  alarm_name              = "wordpress-burst-capacity-25"
  monitored_resource_name = aws_lightsail_instance.wordpress.name

  metric_name         = "BurstCapacityPercentage"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = 25

  evaluation_periods = 1

  # contact_protocols     = ["Email"]
  notification_triggers = ["ALARM"]
}